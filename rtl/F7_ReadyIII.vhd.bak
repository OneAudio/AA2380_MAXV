-------------------------------------------------------
-- ON le 21/04/2025 --
-------------------------------------------------------
-- Intel MAXV 5M570 CPLD Take ?? LE.
-- Function F7 :  F7_ReadyIII.vhd
-------------------------------------------------------
-- Generate a 1KHz 'CLKSLOW' and 'READY' signal after 
-- 500ms delay at intial startup.
--
-- The input clock is 1536k or 1411.2MHz
-- Then we divide FSo with the right value (depending on SR)
-- to always have CLKSLOW=1kHz
-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity F7_ReadyIII is
    Port (
        clear       :in			    STD_LOGIC ;-- clear input
        FSo		    :in			    STD_LOGIC ;-- MCLK divided by 64 ( 1536k or 1411.2MHz).
		CLK_1kHz    :buffer		    STD_LOGIC ;-- 1kHz clock output
		READY		:buffer		    STD_LOGIC  -- Ready signal, active high after 500ms delay from initial startup.
        );
end F7_ReadyIII;

architecture Behavioral of F7_ReadyIII is
signal counter	: integer range 0 to 511 :=1 ; -- counter for delayed Ready signal
signal slowcnt	: integer range 0 to 767 :=1 ; -- FSo divider counter

begin

process (FSo,READY,slowcnt,CLK_1kHz,clear)
begin
    --
    if clear='1' then
        slowcnt <= 0 ; -- reset counter
	elsif rising_edge(FSo) then
		-- slow clock from clkin
		if  slowcnt=767	then
			CLK_1kHz <= not CLK_1kHz ; -- invert CLKSLOW
			slowcnt <= 0 ; -- reset slowcnt counter
		else
			slowcnt <= slowcnt + 1 ; -- increment slowcnt counter
		end if;
	end if;
    -- 1kHz slow clock is used to generate 500ms delayed Ready signal.
    if  clear='1' then
        counter <= 0 ; -- reset counter 
	elsif falling_edge(CLK_1kHz) then
		-- ready single pulse at startup
		if  counter < 500 then
			Ready   <= '0' ;       -- Ready signal not active
			counter <= counter +1; -- increment counter
	    else
		 	Ready <= '1';          -- Ready active
		end if;
	end if;
end process;

end Behavioral;