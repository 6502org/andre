----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:24:28 02/15/2010 
-- Design Name: 
-- Module Name:    csacpu816v2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
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

entity csacpu816v2 is
    Port ( 
			  
			  -- clock inputs
           nphi2 : in  STD_LOGIC;
           c8phi2 : in  STD_LOGIC;
			  
			  -- clock output
			  dphi2 : out STD_LOGIC;		-- 2phi2
			  
			  -- bus interface
           brdy : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           nslowdaten : out  STD_LOGIC;
           niosel : out  STD_LOGIC;
           nmemsel : out  STD_LOGIC;
			  xma16: out STD_LOGIC;
			  be: in STD_LOGIC;
			  
			  -- cpu interface
           cpurdy : out  STD_LOGIC;
           cpuvda : in  STD_LOGIC;
           cpuvpa : in  STD_LOGIC;
			  cpurnw : in  STD_LOGIC;
           cpuaddr_64k : in  STD_LOGIC_VECTOR (23 downto 16);
			  cpuaddr_2k : in STD_LOGIC_VECTOR (15 downto 11);
			  cpuaddr_0 : in STD_LOGIC_VECTOR (3 downto 0);
			  cpuaddr_myio : in STD_LOGIC;
			  cpudata : inout STD_LOGIC_VECTOR (7 downto 0);
           latchen : out  STD_LOGIC;
			  
			  -- RAM interface
           nramcs : out  STD_LOGIC_VECTOR (2 downto 0);
			  nromcs : out STD_LOGIC;
			  
			  -- extra
			  bootromin : in STD_LOGIC;			-- enables bootrom
			  
			  -- diagnosis output
			  diag : out STD_LOGIC
			  
			  );
end csacpu816v2;

architecture Behavioral of csacpu816v2 is

		signal q3: 		std_logic := '1';
		signal q7: 		std_logic := '1';
		signal xq3: 	std_logic := '1';
		signal xq7:		std_logic := '1';
		signal rsl:		std_logic := '0';
		signal srdy:	std_logic := '0';
		signal rdyint:	std_logic := '0';
		signal nsl:		std_logic := '0';
		signal drdy:	std_logic := '0';
		signal rrdy:	std_logic := '0';
		signal isvideo:	std_logic := '0';
		signal isio:	std_logic := '0';
		signal slowmem: std_logic := '0';
		signal dsl:		std_logic := '0';
				
		signal nmemselint: std_logic := '1';
		signal nioselint: std_logic := '1';
				
		-- shift register
		signal sa:		std_logic := '0';
		signal sb:		std_logic := '0';
		signal sc:		std_logic := '0';
		signal sd:		std_logic := '0';
		signal se:		std_logic := '0';
		signal sf:		std_logic := '0';
		signal sg:		std_logic := '0';
		signal sh:		std_logic := '0';
		signal sa2:		std_logic := '0';
				
		-- originally GAL-internal signals
		signal slowsel: std_logic := '0';
		signal islow64k:	std_logic := '0';
		signal islow512k:	std_logic := '0';
		signal ioselx:	std_logic := '0';
		signal memselx: std_logic := '0';
		signal isorig: std_logic := '0';
				
		-- "new" stuff that hasn't been in the v1 version
		signal validaddr: std_logic := '0';
		signal myregister: std_logic := '0';
		
		signal nc8phi2: std_logic := '0';
		signal cpuclkint: std_logic := '0';
		
		signal phi0D2: std_logic := '0';
		
		-- internal state
      -- signal clkdiv: std_logic_vector (1 downto 0);   -- clock divisor index
      signal slowonly: std_logic := '1';                 -- when 1 then only slow access is allowed
      signal slow64k: std_logic := '1';                  -- when 1 low 64k are mapped to PET (otherwise I/O, video only)
		
      --      writes are passed through to fast RAM (with slow access)
      signal bootrom: std_logic := '0';                  -- when 1, map expansion ROM to low 64k; initialied to jumper
      signal prgrom: std_logic := '0';                   -- when 1, allow writes to ROM (in system programming)
      signal wprotect: std_logic_vector (1 downto 0); -- when 1, write protect fast RAM map

		signal phi2: std_logic := '0';							-- internal phi2 signal, abstracting polaritiy of input
begin

   phi2 <= not(nphi2);
	
	nc8phi2 <= not(c8phi2);
	cpuclkint <= nc8phi2 or not(rdyint);
	phi0D2 <= sb;
	
	-- shift register
	DoSr: process(nc8phi2, phi2)
	begin
		if (rising_edge(nc8phi2)) then
			sh <= sg;
			sg <= sf;
			sf <= se;
			se <= sd;
			sd <= sc;
			sc <= sb;
			sb <= sa;
			sa <= phi2;
		end if;
	end process DoSr;
	
--	DoSr2: process(c8phi2, sa)
--	begin
--		if (rising_edge(c8phi2)) then
--			sa2 <= sa;
--		end if;
--	end process DoSr2;
	
	-- use '1' to emulate the bogus 6502 CPU accesses
	-- actually the PET beep is already noticably "faster" just without the bogus accesses
	validaddr <= cpuvda or cpuvpa;
	
	-- logic equations internal signals
	q3 <= sb or sh;
	q7 <= sd or sg;
	
	xq3 <= q3 or rdyint;
	xq7 <= q7 or nsl;

	-- 2phi2 generation
	dphi2 <= phi2 xor sb;
		
	DoRsl: process(xq3, nc8phi2)
	begin
		if (falling_edge(nc8phi2)) then
			rsl <= not(xq3);
		end if;
	end process DoRsl;
	
	DoSsl: process(xq7, nc8phi2, brdy)
	begin
		if (brdy = '0') then
			srdy <= '0';
		elsif (rising_edge(nc8phi2)) then
			srdy <= not(xq7);
		end if;
	end process DoSsl;
	
	-- latch
	DoRdy: process(srdy, rrdy)
	begin
		if (srdy = '1') then
			rdyint <= '1';
		elsif (rrdy = '1') then 
			rdyint <= '0';
		end if;
	end process DoRdy;
	
	-- latch
	DoSl: process(srdy, rsl)
	begin
		if (srdy = '1') then
			nsl <= '1';
		elsif (rsl = '1') then 
			nsl <= '0';
		end if;
	end process DoSl;

	cpurdy <= rdyint;
	
	DoDrdy: process(rdyint, nc8phi2)
	begin
		if (falling_edge(nc8phi2)) then
			drdy <= rdyint;
		end if;
	end process DoDrdy;
	
	DoRrdy: process(slowmem, nc8phi2)
	begin
		if (rising_edge(nc8phi2)) then
			rrdy <= slowmem;
		end if;
	end process DoRrdy;
	
	DoDsl: process(nsl, c8phi2)
	begin
		if (rising_edge(c8phi2)) then
			dsl <= not(nsl);
		end if;
	end process DoDsl;
	
	-- latch enable
	latchen <= not(nc8phi2 or not(rdyint));
	
	-- bus data driver
	-- if restricted to low 64k (fixed '573 replacement) you can also do
	--	nslowdaten <= be or myregister;
	nslowdaten <= (nmemselint and nioselint)			-- either bus memory or io selected
					or myregister								-- but not my own register
					or be											-- and not disabled from the bus
					or (not(cpuclkint));						-- and not databus used by high addr byte from CPU
	
	-- io area selection
	DoIo: process(cpuaddr_2k, cpuaddr_64k, slow64k, bootrom)
	begin
		if (cpuaddr_2k = "10000") then
			isvideo <= '1';
		else
			isvideo <= '0';
		end if;

		if (cpuaddr_2k = "11101") then
			isio <= '1';
		else
			isio <= '0';
		end if;
		
		if (cpuaddr_64k(23 downto 19) = "00000") then
			islow512k <= '1';
		else
			islow512k <= '0';
		end if;

		if (islow512k = '1' and cpuaddr_64k(18 downto 16) = "000") then
			islow64k <= '1';
		else
			islow64k <= '0';
		end if;

		-- use orig system always for video and I/O, plus when config is orig64k and not boot rom
		if (islow64k = '1'
			and (isio = '1'
				or isvideo = '1'
				or (slow64k = '1'
				  and bootrom = '0')
				 )
			) then
			isorig <= '1';
		else
			isorig <= '0';
		end if;

	end process DoIo;
	
		
		 -----------------------------------------------------------------------------------------------
		 -- memory select lines

		 -- ram0 is always selected on write as well, but on read only where not slowdetected
		 -- each one has 512k
		 MemSel: process(cpuclkint, cpuaddr_64k, cpurnw, reset, validaddr,
													prgrom, bootrom, cpuaddr_2k, 
													islow64k, wprotect,
													islow512k, isorig, isio, isvideo, slow64k)
		 begin
					if (reset = '0' or validaddr = '0' or cpuclkint = '0') then
							  nramcs(0) <= '1';
							  nromcs <= '1';
					else
							  -- bank 0 ram, 0-512k
							  if (islow512k = '1')
										 then
										 if islow64k = '1' then
													if (cpurnw = '1' and (bootrom = '1' or isorig = '1')) then
															  -- if read, but bootrom or isorig enabled, then not selected
															  nramcs(0) <= '1';
													else
															  -- write, or read and not bootrom and not isorig
															  -- check write protect in low 64k
															  case wprotect is
																		 when "00" =>
																					nramcs(0) <= '0';               -- no write protect
																		 when "01" =>
																					if (cpuaddr_2k(15) = '1'
																							  and (cpuaddr_2k(14) = '1'
																										 or cpuaddr_2k(13) = '1')) then
																							  nramcs(0) <= not(cpurnw);               -- write protected $a000-$ffff
																					else
																							  nramcs(0) <= '0';       -- ok
																					end if;
																		 when "10" =>
																					if (cpuaddr_2k(15) = '1'
																							  and cpuaddr_2k(14) = '1') then
																							  nramcs(0) <= not(cpurnw);               -- write protected $c000-$ffff
																					else
																							  nramcs(0) <= '0';       -- ok
																					end if;
																		 when "11" =>
																					if (cpuaddr_2k(15) = '1'
																							  and cpuaddr_2k(14) = '1'
																							  and cpuaddr_2k(13) = '1') then
																							  nramcs(0) <= not(cpurnw);               -- write protected $e000-$ffff
																					else
																							  nramcs(0) <= '0';       -- ok
																					end if;
																		 when others =>
																					nramcs(0) <= '1';                                               -- no access, should not happen
															  end case;
													end if;  -- read/bootrom/orig
										 else    -- if islow64k
													-- 64k-512k
													nramcs(0) <= '0';
										 end if;
							  else
										 nramcs(0) <= '1';
							  end if;

							  -- uppermost 512k, boot rom
							  if (cpuaddr_64k(23 downto 19) = "11111")
										 then
										 -- uppermost 512k, write only if allowed by prgrom
										 nromcs <= not( cpurnw or prgrom );
							  elsif (islow64k = '1'
													and cpurnw = '1'
													and bootrom = '1'
													and isio = '0'
													and isvideo = '0'
													) then
													-- low 64k, bootrom, read only, not I/O and not video
													nromcs <= '0';
							  else
										 nromcs <= '1';
							  end if;
					end if;

		 end process MemSel;

	-- RAM @ 512k-1M
	nramcs(1) <= not(
					cpuclkint and not(cpuaddr_64k(23)) 
					and not(cpuaddr_64k(22)) and not(cpuaddr_64k(21)) 
					and not(cpuaddr_64k(20)) and cpuaddr_64k(19)
					);

	-- RAM @ 1M-1.5M
	nramcs(2) <= not(
					cpuclkint and not(cpuaddr_64k(23)) 
					and not(cpuaddr_64k(22)) and not(cpuaddr_64k(21)) 
					and cpuaddr_64k(20) and not(cpuaddr_64k(19))
					);

	-- GAL replacement
	slowsel <= not(nsl) or dsl;
	
	memselx <= (islow64k and isvideo)							-- video memory always
				or (islow64k and slow64k and not(bootrom) and not(isio))		-- is slow64k then in low64, but not io area
				or (cpuaddr_64k(23) and cpuaddr_64k(22) and cpuaddr_64k(21) and not(cpuaddr_64k(20))) -- $exxxxx
				;
				
	ioselx <= islow64k and isio;
						
	niosel <= nioselint;
	nioselint <= not(slowsel and ioselx);
	nmemsel <= nmemselint;
	nmemselint <= not(slowsel and memselx);
	
	slowmem <= validaddr and drdy and reset
				and (ioselx or memselx or slowonly);
	
	xma16 <= (islow64k and isvideo) or cpuaddr_64k(16);
	
	-----------------------------------------------------------------------------------------------
	-- CPU access to config registers

	 DoWriteAccess: process(cpuclkint, reset, bootromin)
	 begin
				if (reset = '0') then
						  slowonly <= '1';
						  slow64k <= '1';
						  bootrom <= bootromin;
						  prgrom <= '0';
						  wprotect <= "00";
				elsif (falling_edge(cpuclkint) and cpurnw = '0') then
						  if (islow64k = '1'
								and isio = '1'
								and cpuaddr_myio = '1'
								and cpuaddr_0 = "1111"
								) then
								-- write $00efff
								wprotect <= cpudata(3 downto 2);
								slowonly <= cpudata(4);
								slow64k <= cpudata(5);
								bootrom <= cpudata(6);
								prgrom <= cpudata(7);
						  end if;
				end if;
	 end process DoWriteAccess;

--	 DoReadAccess: process(cpuclkint, phi0D2, reset)
--	 begin
--				if (reset='0' or cpuclkint = '0') then
--						  -- cpudata <= "ZZZZZZZZ";
--						  cpudata <= (cpudata'range => 'Z');
--						  myregister <= '0';
--	  diag <= '1';
--				elsif (rising_edge(phi0D2) and cpurnw = '1') then
--						  if (islow64k = '1'
--								and isio = '1'
--								and cpuaddr_myio = '1'
--								and cpuaddr_0 = "1111"
--								) then
--								-- read $00efff
--								myregister <= '1';
--								cpudata <= (prgrom, bootrom, slow64k, slowonly, wprotect(1), wprotect(0), '1', '1');
--	  diag <= '0';
--						  end if;
--				end if;
--	 end process DoReadAccess;

end Behavioral;

