-----------------------------------------------------------------
-- O.N 
-- Dual bicolor LEDs function decoder
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
 
 entity LED_decode is
    Port ( 
          Mode      : in  std_logic; -- Auto/Manu mode 
          EN_Clk	: in  std_logic; -- Enable oscillator signal
          LED1red   : out std_logic; -- 
          LED1green : out std_logic; --           
          LED2red   : out std_logic; -- 
          LED2green : out std_logic -- 
    );
 end LED_decode;
 
architecture decoder of LED_decode is

begin

LED1red		<= Mode ; -- red in Auto mode
LED1green 	<= not Mode; -- green in Manual mode
LED2red 		<= not EN_Clk; -- red led when locked
LED2green	<= EN_Clk  ; -- green when unlocked

end architecture;
