----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:51:51 02/27/2011 
-- Design Name: 
-- Module Name:    blitter - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity blitter is
    Port ( 
			  A : in  STD_LOGIC_VECTOR (3 downto 0);
           Nphi2 : in  STD_LOGIC;
           Nboard : in  STD_LOGIC;
           wnr : in  STD_LOGIC;
           Ndtw : out  STD_LOGIC;
           Ndtr : out  STD_LOGIC;
           Nwlda : out  STD_LOGIC_VECTOR (2 downto 0);
           Nwsta : out  STD_LOGIC_VECTOR (2 downto 0);
           Ndbus : out  STD_LOGIC_VECTOR (2 downto 0);
           Nrlda : out  STD_LOGIC;
           Nrsta : out  STD_LOGIC;
           Nwldi : out  STD_LOGIC;
           Nrldi : out  STD_LOGIC;
           Nwsti : out  STD_LOGIC;
           Nrsti : out  STD_LOGIC;
			  Nrdinc : out STD_LOGIC;
			  Nnullinc : out STD_LOGIC;
           Nrcnt : out  STD_LOGIC;
           Nwcnt : out  STD_LOGIC;
           Nwctrl : out  STD_LOGIC;
           fetchNstore : out  STD_LOGIC;
           Nactive : out  STD_LOGIC;
			  cntend : in std_logic;
			  Nres : in std_logic;
			  datadir : out std_logic
			  );
end blitter;

architecture Behavioral of blitter is

	signal board : std_logic;
	signal cpurd : std_logic;
	signal cpuwr : std_logic;
	signal reset : std_logic;
	signal phi2 : std_logic;
	
	signal active : std_logic;
	signal fetch : std_logic;
	signal store : std_logic;
	
	signal rlda : std_logic;
	signal rsta : std_logic;
	signal rldi : std_logic;
	signal rsti : std_logic;
	signal rdinc : std_logic;
	signal nullinc : std_logic;
	signal wlda : std_logic_vector(2 downto 0);
	signal wsta : std_logic_vector(2 downto 0);
	signal dbus : std_logic_vector(2 downto 0);
	signal wldi : std_logic;
	signal wsti : std_logic;
	signal dtr : std_logic;
	signal dtw : std_logic;
	signal wcnt : std_logic;
	signal rcnt : std_logic;
	signal wctrl : std_logic;
	signal datain : std_logic;

	-- intermediary signals
	signal im_active1 : std_logic;
	signal im_active2 : std_logic;
begin
	--------------------------------------------------------
	-- intern vs. extern signals
	board <= not(Nboard);
	cpurd <= not(wNr);
	cpuwr <= wNr;
	reset <= not(Nres);
	phi2 <= not(Nphi2);
	
	Nrlda <= not(rlda);
	Nrsta <= not(rsta);
	Nrldi <= not(rldi);
	Nrsti <= not(rsti);
	Nrdinc <= not(rdinc);
	Nnullinc <= not(nullinc);
	Nwlda <= not(wlda);
	Nwsta <= not(wsta);
	Nwldi <= not(wldi);
	Nwsti <= not(wsti);
	Ndtw <= not(dtw);
	Ndtr <= not(dtr);
	Nwcnt <= not(wcnt);
	Nrcnt <= not(rcnt);
	Nwctrl <= not(wctrl);
	Nactive <= not(active);
	fetchNstore <= fetch;
	Ndbus <= not(dbus);
	datadir <= datain;
	
	--------------------------------------------------------
	-- timing control
	
	do_active1: process(cntend, reset, phi2, wctrl)
	begin
		if (reset = '1') then
			im_active1 <= '1';
		elsif (wctrl = '1') then
			im_active1 <= '0';
		elsif (rising_edge(cntend)) then
			im_active1 <= '1';
		end if;
	end process;
	do_active2: process(im_active1, phi2, reset)
	begin
		if (reset = '1') then
			im_active2 <= '1';
		elsif (falling_edge(phi2)) then
			im_active2 <= im_active1;
		end if;
	end process;
	active <= not(im_active1) and not(im_active2);

	do_fetch: process(wctrl, phi2, active)
	begin
		if (active = '0' or wctrl = '1') then
			fetch <= '1';
		elsif (falling_edge(phi2)) then
			fetch <= not(fetch);
		end if;
	end process;
	store <= not(fetch);
	
	--------------------------------------------------------
	-- logic part, replacement of the two PALs in v2.0
	
	datain <= (active and fetch) or (not(active) and board and cpuwr);
	
	rlda <= (active and fetch) or (not(active) and not(A(3)) and not(A(2)) and board and cpurd);
	rsta <= (active and store) or (not(active) and not(A(3)) and A(2) and board and cpurd);
	rldi <= (active and fetch) 
			or (not(active) and A(3) and not(A(2)) and not(A(1)) and board and cpurd);
	rsti <= (active and store)
			or (not(active) and A(3) and not(A(2)) and A(1) and board and cpurd);
	rdinc <= not(active) and A(3) and not(A(2)) and board and cpurd;
	
	nullinc <= not(active) and not(A(3)) and board and cpurd;
	
	wlda(0) <= phi2 and ((active and fetch) 
			or (not(active) and not(A(0)) and not(A(1)) and not(A(2)) and not(A(3)) 
				and board and cpuwr));
	wlda(1) <= phi2 and ((active and fetch) 
			or (not(active) and A(0) and not(A(1)) and not(A(2)) and not(A(3)) 
				and board and cpuwr));
	wlda(2) <= phi2 and ((active and fetch) 
			or (not(active) and not(A(0)) and A(1) and not(A(2)) and not(A(3)) 
				and board and cpuwr));

	wsta(0) <= phi2 and ((active and store) 
			or (not(active) and not(A(0)) and not(A(1)) and A(2) and not(A(3)) 
				and board and cpuwr));
	wsta(1) <= phi2 and ((active and store) 
			or (not(active) and A(0) and not(A(1)) and A(2) and not(A(3)) 
				and board and cpuwr));
	wsta(2) <= phi2 and ((active and store) 
			or (not(active) and not(A(0)) and A(1) and A(2) and not(A(3)) 
				and board and cpuwr));
	
	wldi <= phi2 and not(active) and A(3) and not(A(2)) and not(A(1)) and not(A(0))
			and board and cpuwr;
	wsti <= phi2 and not(active) and A(3) and not(A(2)) and A(1) and not(A(0))
			and board and cpuwr;
	
	dtw <= phi2 and active and fetch;
	dtr <= active and store;
					
	wcnt <= phi2 and not(active) and A(3) and A(2) and not(A(1)) and not(A(0))
			and board and cpuwr;
	rcnt <= not(active) and A(3) and A(2) and not(A(1)) and not(A(0))
			and board and cpurd;
	
	wctrl <= phi2 and not(active) and A(3) and A(2) and A(1) and A(0)
			and board and cpuwr;
			
	dbus(0) <= not(active) and not(A(3)) and not(A(1)) and not(A(0)) and board;
	dbus(1) <= not(active) and not(A(3)) and not(A(1)) and A(0) and board;
	dbus(2) <= not(active) and not(A(3)) and A(1) and not(A(0)) and board;
	
end Behavioral;

