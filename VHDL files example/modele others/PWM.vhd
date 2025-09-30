--------------------------------------------------------------------------------
-- O.N -14/05/19  **OSVA**  AA2380v1 TEST
-- take xx LE
--
-- Generate 2 PWM outputs .
--
--------------------------------------------------------------------------------
library  IEEE;
use  IEEE.STD_LOGIC_1164.ALL;
use  ieee.numeric_std.all;

entity  PWM  is
port(
        CLOCK_PWM       :	in std_logic  ;           -- PWM clock (128x PWM frequency)
        DTY_CYCLE       :	in unsigned(6 downto 0)  ;-- Duty cyle
        PWM             :	buffer std_logic ;        -- PWM output
        nPWM            :	buffer std_logic ;        -- inverted PWM output
        FPWM           :	buffer std_logic          -- base PWM frequency
        );
end  PWM;

ARCHITECTURE DESCRIPTION OF PWM IS

signal counter   : integer range 0 to 127  := 0 ; -- PWM frequency divider
signal Duty       : integer range 0 to 127  := 0 ; --

BEGIN
--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
process(CLOCK_PWM,counter,Duty,DTY_CYCLE,PWM)
begin
Duty <= to_integer(DTY_CYCLE) ;
  if    rising_edge(CLOCK_PWM) then
        -- base PWN frequency generator.
        counter <= counter + 1  ; -- increment counter
        if    counter>63  then
              FPWM <= '0' ;
        else
              FPWM <= '1' ;
        end if;
        --
        -- PWM output generator from duty cycle input.
        if    counter >= Duty then -- compare counter value to duty input.
              PWM <= '0' ;
        else
              PWM <= '1' ;
        end if;
  end if;
nPWM <= not PWM; -- inverted output.
end process;

END DESCRIPTION;
