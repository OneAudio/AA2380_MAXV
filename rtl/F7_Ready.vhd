-------------------------------------------------------
-- ON le 19/08/2019 -- Use generic inputs
-------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 52 LE.
-- Function F7 :  F7_Ready.vhd
-------------------------------------------------------
-- Generate ready signal after a delay from main clock.
-- You can choose :
-- ==> CLKVAL in Hz (input clock frequency)
-- ==> DELAY  in ms (output delay in ms).
-- ==> FSLOW in Hz (slow frequency output).
-- 
-- Note: Take 52 LE for :
-- CLKVAL=1562500 Hz, FSLOW=50Hz and DELAY=100ms
-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity F7_Ready is
Generic(
CLKVAL	:	natural := 1562500 	;	-- input frequency in Hz
FSLOW	:	natural := 50		;	-- output slow frequency in Hz.
DELAY	:	natural := 100		 	-- ready output delay in ms
); 
    Port (
        CLKIN		:in			STD_LOGIC ;-- input clock 
        READY  		:buffer		STD_LOGIC ;-- Ready output signal (active high)
		CLKSLOW		:buffer		STD_LOGIC :='1' -- output slow clock (derivated from CLKIN).
        );
end F7_Ready;

architecture Behavioral of F7_Ready is
signal counter	: integer range 0 to FSLOW :=0 ; -- max count value
signal cnt		: integer range 0 to FSLOW :=0	; -- cnt value of timer.
signal toggle	: integer range 0 to (CLKVAL/2) :=0 ; -- toggle bit
signal slowcnt	: integer range 0 to CLKVAL :=0 ; -- CLKSLOW toggle counter

begin

toggle	<=	CLKVAL / (2 * FSLOW) ; -- Calculate number of CLKVAL period before to toggle
cnt 	<=  (FSLOW*DELAY)/1000 ; -- calculate number of clkval period to reach delay

process (CLKIN,ready,slowcnt,toggle,CLKSLOW)
begin
	if rising_edge(CLKIN) then
		-- slow clock from clkin
		if  slowcnt=toggle	then
			CLKSLOW <= not CLKSLOW ; -- invert CLKSLOW
			slowcnt <= 0 ; -- reset slowcnt counter
		else
			slowcnt <= slowcnt + 1 ; -- increment slowcnt counter
		end if;
	end if;
	if falling_edge(CLKSLOW) then
		-- ready single pulse at startup
		if  counter < (cnt-1) then
			Ready   <= '0' ;-- Ready signal not active
			counter <= counter +1; -- increment counter
	    else
		 	Ready <= '1'; -- Ready active
		end if;
	end if;
end process;

end Behavioral;
