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
			  ncpuaddr_myio : in STD_LOGIC;
			  cpudata : in STD_LOGIC_VECTOR (7 downto 0);
           latchen : out  STD_LOGIC;
			  
			  -- RAM interface
           nramcs : out  STD_LOGIC_VECTOR (2 downto 0);
			  nromcs : out STD_LOGIC;
			  nromoe : out std_logic;
			  
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
				
		-- originally GAL-internal signals
		signal slowsel: std_logic := '0';
		signal islow64k:	std_logic := '0';
		signal islow512k:	std_logic := '0';
		signal ioselx:	std_logic := '0';
		signal memselx: std_logic := '0';
				
		-- "new" stuff that hasn't been in the v1 version
		signal validaddr: std_logic := '0';
		signal myregister: std_logic := '0';
		
		signal nc8phi2: std_logic := '0';
		signal cpuclkint: std_logic := '0';
		
		-- internal state
      -- signal clkdiv: std_logic_vector (1 downto 0);   -- clock divisor index
      signal slowclk: std_logic := '0';                  -- when 1 then only slow clock speed is allowed
      signal orig64k: std_logic := '1';                  -- when 1 low 64k are mapped to PET (otherwise I/O, video only)
		signal hidebogus: std_logic := '0';						-- when 1, bogus CPU accesses are passed to the bus
		signal fastvread: std_logic := '0';						-- when 1, reads from video come from fast RAM
		
      --      writes are passed through to fast RAM (with slow access)
      signal bootrom: std_logic := '0';                  -- when 1, map expansion ROM to low 64k; initialied to jumper
      signal prgrom: std_logic := '0';                   -- when 1, allow writes to ROM (in system programming)
      signal wprotect: std_logic_vector (1 downto 0); 	-- when 1, write protect fast RAM map

		signal phi2: std_logic := '0';							-- internal phi2 signal, abstracting polaritiy of input
		
		signal diagtoggle : std_logic;
		signal isrom : std_logic;
		signal isbus : std_logic;
		signal isslow : std_logic;
		
		signal isslowvid : std_logic;
		signal isfastvid : std_logic;
begin

   phi2 <= not(nphi2);
	
	nc8phi2 <= not(c8phi2);
	cpuclkint <= nc8phi2 or not(rdyint);
	
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
	
	-- use '1' to emulate the bogus 6502 CPU accesses
	-- actually the PET beep is already noticably "faster" just without the bogus accesses
	validaddr <= not(hidebogus) or cpuvda or cpuvpa;
	
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

		-- GAL replacement
		slowsel <= not(nsl) or dsl;

	-----------------------------------------------------------------------------------------------
	
	-- control signal outputs
		
	-- latch enable
	latchen <= not(cpuclkint);
	
	-- bus data driver
	-- if restricted to low 64k (fixed '573 replacement) you can also do
	--	nslowdaten <= be or myregister;
	-- write only, thus myregister not needed
	nslowdaten <= (nmemselint and nioselint)			-- either bus memory or io selected
					or be											-- and not disabled from the bus
					or (not(cpuclkint));						-- and not databus used by high addr byte from CPU

	-- XOR A16 to map bus $1xxxx video RAM into low 64k
	xma16 <= isslowvid or cpuaddr_64k(16);
		
	-----------------------------------------------------------------------------------------------

	Do512k: process(cpuaddr_64k)
	begin
		-- lowest 512k address space
		if (cpuaddr_64k(23 downto 19) = "00000") then
			islow512k <= '1';
		else
			islow512k <= '0';
		end if;
	end process;
	
	Do64k: process(islow512k, cpuaddr_64k)
	begin
		-- lowest 64k address space
		if (islow512k = '1' and cpuaddr_64k(18 downto 16) = "000") then
			islow64k <= '1';
		else
			islow64k <= '0';
		end if;
	end process;
		
	-- io area selection
	DoIo: process(cpuaddr_2k, islow64k)
	begin
		if (islow64k = '1' and cpuaddr_2k = "10000") then
			isvideo <= '1';
		else
			isvideo <= '0';
		end if;

		if (islow64k = '1' and cpuaddr_2k = "11101") then
			isio <= '1';
		else
			isio <= '0';
		end if;
	end process;

	-- isrom is one when the board ROM should be accessed
		
	 RomSel: process(cpuaddr_64k, cpurnw, prgrom, bootrom, 
						isio, isvideo, islow64k)
	 begin
		-- uppermost 512k, boot rom
		-- i.e. $F8xxxx-$FFxxxx
		if (cpuaddr_64k(23 downto 19) = "11111") then
			-- uppermost 512k, write only if allowed by prgrom
			isrom <= cpurnw or prgrom;
		else
			-- boot rom (read only anyway)
			if (islow64k = '1'
				and cpurnw = '1'
				and bootrom = '1'
				and isio = '0'
				and isvideo = '0'
				) then
				-- low 64k, bootrom, read only, not I/O and not video
				isrom <= '1';
			else
				isrom <= '0';
			end if;
		end if;
	end process RomSel;

	DoVideo: process(isvideo, cpurnw, fastvread)
	begin
		if (isvideo = '0') then
			isslowvid <= '0';
			isfastvid <= '0';
		else
			if (cpurnw = '0' or fastvread = '0') then
				isslowvid <= '1';
				isfastvid <= '0';
			else
				isslowvid <= '0';
				isfastvid <= '1';
			end if;
		end if;
	end process;
			
	-- bus is for all non-IO bus accesses
	DoBus: process(cpuaddr_64k, islow64k, isvideo, orig64k, isio, bootrom) 
	begin
		if (
				(cpuaddr_64k(23 downto 20) = "1110") 							-- bus mirror at $Exxxx
				or (islow64k = '1' and orig64k = '1' and bootrom = '0'	-- lowest 64k if slow64k and not bootrom
					and isio = '0' and isvideo = '0')							-- and not IO or video
			) then
			isbus <= '1';
		else
			isbus <= '0';
		end if;
	end process;

	DoSlow: process(isbus, isio, isrom, slowclk, isslowvid) 
	begin
		if (
				isbus	= '1'						-- bus is always slow
				or isio = '1'					-- io also always slow
				or isrom = '1'					-- rom also
				or isslowvid = '1'			-- slow video access
				or slowclk = '1'				-- or config says to slow
			) then
			isslow <= '1';
		else
			isslow <= '0';
		end if;
	end process;
	
	-----------------------------------------------------------------------------------------------

	-- internal memsel signal (preparation for the CS/A bus)
	memselx <= isbus or isslowvid;
				
	-- internal iosel signal (preparation for the CS/A bus)
	ioselx <= isio;

	-- qualify iosel and memsel with slowsel
	nioselint <= not(slowsel and ioselx);
	nmemselint <= not(slowsel and memselx);

	-- output signals
	niosel <= nioselint;
	nmemsel <= nmemselint;
						
	-- control signal to initiate RDY CPU handling, to slow CPU down for slow access
	slowmem <= validaddr and drdy and reset and isslow;
	
	-----------------------------------------------------------------------------------------------		 -----------------------------------------------------------------------------------------------
	-- memory select lines

	-- ram0 is always selected on write as well, but on read only where not slowdetected
	-- each one has 512k
		 Ram0Sel: process(cpuclkint, cpurnw, reset, validaddr,
													bootrom, cpuaddr_2k, 
													islow64k, wprotect,
													islow512k, isio, isbus,
													cpuaddr_64k, isslowvid, isfastvid)
	begin
		if (reset = '0' or validaddr = '0' or cpuclkint = '0') then
			-- do not select it on reset, no valid access, addr above 512k,
			-- and phi2 not active
			nramcs(0) <= '1';
		else
			if (islow512k = '1') then
				-- so here it is: phi2 active, low 512k, valid access
				if islow64k = '0' then
					-- always select it in 64k-512k
					nramcs(0) <= '0';
				else
					-- valid access in the lowest 64k
					-- check for reads
					if (cpurnw = '1' and 
							(bootrom = '1' or isbus = '1' or isio = '1' or isslowvid = '1')
						) then
						-- if bootrom or IO or bus memory enabled, then read from there
						-- i.e. do not select RAM. Write through is handled below
						-- 
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
									nramcs(0) <= '1';                               -- no access, should not happen
					  end case;
					end if;  -- read/bootrom/orig
				 end if;
			  elsif (cpuaddr_64k(23 downto 19) = "11110") then
				 nramcs(0) <= '0';		-- ok, RAM mirror at $F0xxxx-$F7xxxx
			  else
				 nramcs(0) <= '1';		-- not selected
			  end if;
			end if; -- endif reset check

		 end process Ram0Sel;


		-- mask romaddr with phi2
		nromcs <= not(phi2 and isrom);
		nromoe <= not(cpurnw);
		
		-- RAM @ 512k-1M; always in the range cpuaddr_64k=00001xxx
		nramcs(1) <= not(validaddr
					and cpuclkint and not(cpuaddr_64k(23)) 
					and not(cpuaddr_64k(22)) and not(cpuaddr_64k(21)) 
					and not(cpuaddr_64k(20)) and cpuaddr_64k(19)
					);

		-- RAM @ 1M-1.5M; always inthe range  couaddr_64k=00010xxx
		nramcs(2) <= not(validaddr
					and cpuclkint and not(cpuaddr_64k(23)) 
					and not(cpuaddr_64k(22)) and not(cpuaddr_64k(21)) 
					and cpuaddr_64k(20) and not(cpuaddr_64k(19))
					);

	
	-----------------------------------------------------------------------------------------------
	-- CPU access to config registers

	-- must use isio, as ncpuaddr_myio is on system bus side
	myregister <= islow64k and isio and not(ncpuaddr_myio)
						and cpuaddr_0(0) and cpuaddr_0(1) and cpuaddr_0(2) and cpuaddr_0(3);

	 DoWriteAccess: process(cpuclkint, reset, bootromin)
	 begin
				if (reset = '0') then
						  hidebogus <= '0';
						  slowclk <= '1';
						  orig64k <= '1';
						  bootrom <= bootromin;
						  prgrom <= '0';
						  wprotect <= "00";
						  fastvread <= '0';
						  
						  diagtoggle <= '0';
				elsif (falling_edge(cpuclkint) and cpurnw = '0') then
						  if (myregister = '1') then
								
								diagtoggle <= not(diagtoggle);
								
								-- write $00efff
								wprotect <= cpudata(1 downto 0);
								fastvread <= cpudata(2);
								hidebogus <= cpudata(3);
								slowclk <= cpudata(4);
								orig64k <= cpudata(5);
								bootrom <= cpudata(6);
								prgrom <= cpudata(7);		

								diag <= diagtoggle;
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
--								and ncpuaddr_myio = '0'
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

