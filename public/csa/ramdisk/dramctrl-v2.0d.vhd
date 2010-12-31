----------------------------------------------------------------------------------
-- Company:			n/a 
-- Engineer: 		A.Fachat
-- 
-- Create Date:    14:19:31 01/08/2010 
-- Design Name: 	 CS/A65 RAMDisk DRAM controller
-- Module Name:    dramctrl - Behavioral 
-- Project Name: 
-- Target Devices: XC95**
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.02 - 
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dramctrl is
    Port ( data : inout  STD_LOGIC_VECTOR (7 downto 0);
           regsel : in  STD_LOGIC_VECTOR (3 downto 0);
           Nphi2 : in  STD_LOGIC;
           Nsel : in  STD_LOGIC;
           rNw : in  STD_LOGIC;
           Nres : in  STD_LOGIC;
           NB8phi2 : in  STD_LOGIC;
           maddr : out  STD_LOGIC_VECTOR (10 downto 0);
           rnwdata : out  STD_LOGIC;
           ndataen : out  STD_LOGIC;
           Ncas : out  STD_LOGIC_VECTOR (3 downto 0);
           Nras : out  STD_LOGIC_VECTOR (3 downto 0);
           mrNw : out  STD_LOGIC;
           Led : out  STD_LOGIC_VECTOR (7 downto 0)
		);
end dramctrl;

architecture Behavioral of dramctrl is

   -- data bus internal
	signal datain: std_logic_vector (7 downto 0);
	signal dataout: std_logic_vector (7 downto 0);
	
	-- clock internal
	signal B8phi2: std_logic;
	signal phi2: std_logic;
	
	-- internal state signals
	signal bank: std_logic_vector (7 downto 0);
	signal page: std_logic_vector (7 downto 0);
	signal byte: std_logic_vector (7 downto 0);
	-- refcnt has the upper 10 bits as counter
	-- and the lowest two as bank select (we need 512cycles/8ms,
	-- so we can afford to refresh every 8th cycle only)
	signal refcnt: std_logic_vector (13 downto 0);
	
	-- pseudo shift register, shifting on both edges of B8phi2
	signal phi2D1: std_logic :='0';
	signal phi2D2: std_logic :='0';
	signal phi2D3: std_logic :='0';
	signal phi2D4: std_logic :='0';
	
	-- internal variables
	signal rnwInt: std_logic :='0';
	signal casInt: std_logic :='0';
	signal rasInt: std_logic :='0';
	signal muxInt: std_logic :='0';
	
	signal dataRegister: std_logic;
	signal dataAccess: std_logic;
	signal dataout_en: std_logic;
	
	signal MRnW_int: std_logic;
begin

	------------------ master timing
	
	B8phi2 <= not(NB8phi2);
	phi2 <= not(Nphi2);
	
	-- master timing. Create delayed shift 2phi2 signals using 8phi2
	Delay1 : process(B8phi2) 
	begin
		if (rising_edge(B8phi2)) then
			phi2D1 <= phi2;
		end if;
	end process Delay1;
	Delay2 : process(B8phi2) 
	begin
		if (falling_edge(B8phi2)) then
			phi2D2 <= phi2D1;
		end if;
	end process Delay2;
	Delay3 : process(B8phi2) 
	begin
		if (rising_edge(B8phi2)) then
			phi2D3 <= phi2D2;
		end if;
	end process Delay3;
	Delay4 : process(B8phi2) 
	begin
		if (falling_edge(B8phi2)) then
			phi2D4 <= phi2D3;
		end if;
	end process Delay4;
	IntVars : process (phi2, B8phi2, phi2D1, phi2D2, phi2D3, phi2D4)
	begin
		rnwInt <= phi2 xor phi2D1;
		rasInt <= phi2 xor phi2D2;
		muxInt <= phi2 xor phi2D3;
		casInt <= phi2 xor phi2D4;
	end process IntVars;
		
	------------------ register access from CPU

	datain <= data;

	data <= dataout when (dataout_en = '1') else (others => 'Z'); 
	
	dataP: process(phi2, Nsel, rNw, dataRegister)
	begin
	 if (phi2 = '1' 
		and Nsel = '0' 
		and rNw = '1' 
		and dataRegister = '0'
		) then
		dataout_en <= '1';
	 else
		dataout_en <= '0';
	 end if;
	end process;

	-- read any of the registers
	ReadReg : process(regsel, byte, page, bank)
		begin
			case regsel is
				when "0001" => 
					dataout <= byte;
				when "0010" =>
					dataout <= page;
				when "0011" =>
					dataout <= bank;
				when others =>
					-- this must be high-Z, all-zeros breaks (mangles data)
					dataout <= "ZZZZZZZZ";
					--dataout <= (others => '0'); 
			end case;
	end process ReadReg;
	
	-- write register
	BankReg : process(Nres, phi2, Nsel, rNw, datain, regsel)
		begin 
		if (Nres = '0') then				-- reset
			bank <= "00000000";
			page <= "00000000";
			byte <= "00000000";
		elsif falling_edge(phi2) and Nsel = '0' then
			if (regsel = "0000") then
				-- both read and write
				byte <= byte + 1;
			elsif (rNw = '0') then
				-- write path
				case regsel is
					when "0001" => 
						byte <= datain;
					when "0010" =>
						page <= datain;
					when "0011" =>
						bank <= datain;
					when others =>
				end case;
			end if;
		end if;
	end process BankReg;
	
	------------------ refresh counter

	-- count the refresh counter
	CntRefresh : process(phi2, Nres)
	begin
		if (Nres = '0') then
			refcnt <= (others => '0');
		elsif (rising_edge(phi2)) then
			refcnt <= refcnt + 1;
		end if;
	end process CntRefresh;

	------------------ DRAM signal output

	MA_Out : process(phi2, muxInt, refcnt, byte, page, bank)
	begin
		if (phi2 = '0') then
			maddr <= refcnt(13 downto 3);
		else
			if (muxInt = '0') then
				maddr(0) <= byte(0);
				maddr(1) <= byte(1);
				maddr(2) <= byte(2);
				maddr(3) <= byte(3);
			
				maddr(4) <= byte(4);
				maddr(5) <= byte(5);
				maddr(6) <= byte(6);
				maddr(7) <= byte(7);
			
				maddr(8) <= bank(0);
				maddr(9) <= bank(2);
				maddr(10)<= bank(4);
			else
				maddr(0) <= page(0);
				maddr(1) <= page(1);
				maddr(2) <= page(2);
				maddr(3) <= page(3);
			
				maddr(4) <= page(4);
				maddr(5) <= page(5);
				maddr(6) <= page(6);
				maddr(7) <= page(7);
			
				maddr(8) <= bank(1);
				maddr(9) <= bank(3);
				maddr(10)<= bank(5);
			end if;
		end if;
	end process MA_Out;
	
	RAS_Out : process(phi2, rasInt, bank, dataAccess, refcnt)
	begin
		if (phi2 = '0') then
			-- refresh 
			if (refcnt(0) = '0') then
				Nras <= "1111";	-- pause cycle
			else
				-- for each bank one cycle in turn to refresh
				case refcnt(2 downto 1) is
					when "00" =>
						Nras <= ('1', '1', '1', rasInt);
					when "01" =>
						Nras <= ('1', '1', rasInt, '1');
					when "10" =>
						Nras <= ('1', rasInt, '1', '1');
					when "11" =>
						Nras <= (rasInt, '1', '1', '1');
					when others =>
						Nras <= "1111";
				end case;
			end if;
			--Nras <= (rasInt, rasInt, rasInt, rasInt);
		else
			-- CPU access
			if (dataAccess = '0') then
				-- reset or not selected
				Nras <= "1111";
			else
				-- for each bank
				case bank(7 downto 6) is
					when "00" =>
						Nras <= ('1', '1', '1', rasInt);
					when "01" =>
						Nras <= ('1', '1', rasInt, '1');
					when "10" =>
						Nras <= ('1', rasInt, '1', '1');
					when "11" =>
						Nras <= (rasInt, '1', '1', '1');
					when others =>
						Nras <= "1111";
				end case;
			end if; -- if reset
		end if; -- if refresh
	end process RAS_Out;

	CAS_Out : process(casInt, bank, dataAccess)
	begin
		if (dataAccess = '0') then
			-- refresh or not selected or reset
			Ncas <= "1111";
		else
			-- for each bank
			case bank(7 downto 6) is
				when "00" =>
					Ncas <= ('1', '1', '1', casInt);
				when "01" =>
					Ncas <= ('1', '1', casInt, '1');
				when "10" =>
					Ncas <= ('1', casInt, '1', '1');
				when "11" =>
					Ncas <= (casInt, '1', '1', '1');
				when others =>
					Ncas <= "1111";
			end case;
		end if;
	end process CAS_Out;

	-- data register access
	
	dataRegister <= not(regsel(0) or regsel(1) or regsel(2) or regsel(3));
	
	dataAccess <= not(Nsel) and phi2 and Nres and dataRegister;

	-- mask with casInt, so driver does not need to drive one value (residual value) 
	-- then the other (real value from RAM), this gives power ripple effects
	-- with a 74ALS245 (instead of a 74LS245) ... but breaks 74LS245...
	-- Ndataen <= not(dataAccess) or casInt;
	Ndataen <= not(dataAccess);
	
	rnwdata <= rNw or not(dataAccess);
	-- rnwdata <= MRnW_int;
	
	MRnW_P : process(rNw, phi2, rnwInt) 
	begin
		-- sample the r/-w line shortly after phi2 changes, so we have a stable 
		-- r/-w line for the whole cycle
		if (falling_edge(rnwInt)) then
			MRnW_int <= rNw or not(phi2) or not(dataAccess);
		end if;
	end process;
	MRnW <= MRnW_int;
		
	------------------ give byte out to LEDs
	Byte_Out : process (byte)
	begin 
		led <= byte;
	end process Byte_Out;
	
end Behavioral;

