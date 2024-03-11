-------------------------------------------------------
-- ON le 08/03/2024 --
-------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 44 LE.
-- Function F7 :  F7_ReadyII.vhd
-------------------------------------------------------
-- Generate a 1KHz 'CLKSLOW' and 'READY' signal after 
-- 500ms delay at intial startup.
--
-- The input clock is FSo (12k to 1536k) and SR value.
-- Then we divide FSo with the right value (depending on SR)
-- to always have CLKSLOW=1kHz
-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity F7_ReadyII is
    Port (
        FSo		    :in			    STD_LOGIC ;-- Audio input clock (12k to 1536k, depend on SR value).
        SR  		:in integer  range 0 to 7 ;-- Sample rate value selection bits (3)
		CLKSLOW		:buffer		    STD_LOGIC ;-- 1kHz slow clock output
		READY		:buffer		    STD_LOGIC  -- Ready signal, active high after 500ms delay from initial startup.
        );
end F7_ReadyII;

architecture Behavioral of F7_ReadyII is
signal counter	: integer range 1 to 512 :=1 ; -- counter for delayed Ready signal
signal toggle	: integer range 1 to 768 :=1 ; -- counter for CLKSLOW toggle each half of period
signal slowcnt	: integer range 1 to 768 :=1 ; -- FSo divider counter

begin

process (FSo,SR,READY,slowcnt,toggle,CLKSLOW)
begin
    -- SR value change divider value to get same CLKSLOW value (1kHz)
    case SR is
        when 0 => toggle <=6   ;-- FSo=12k
        when 1 => toggle <=12  ;-- FSo=24k
        when 2 => toggle <=24  ;-- FSo=48k
        when 3 => toggle <=48  ;-- FSo=96k
        when 4 => toggle <=96  ;-- FSo=192k
        when 5 => toggle <=192 ;-- FSo=384k
        when 6 => toggle <=384 ;-- FSo=768k
        when 7 => toggle <=768 ;-- FSo=1536k
    end case;
    --
	if rising_edge(FSo) then
		-- slow clock from clkin
		if  slowcnt=toggle	then
			CLKSLOW <= not CLKSLOW ; -- invert CLKSLOW
			slowcnt <= 1 ; -- reset slowcnt counter
		else
			slowcnt <= slowcnt + 1 ; -- increment slowcnt counter
		end if;
	end if;
    -- 1kHz slow clock is used to generate 500ms delayed Ready signal. 
	if falling_edge(CLKSLOW) then
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