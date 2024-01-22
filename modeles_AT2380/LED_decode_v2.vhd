-----------------------------------------------------------------
-- O.N 14/10/2017
-- Dual bicolor LEDs function decoder
-- take 4 LE
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
 
 entity LED_decode_v2 is
    Port ( 
          EN_Clk	: in  std_logic; -- Enable oscillator signal
          err_signP  	: in  std_logic; -- positive error in auto track mode
          err_signN  	: in  std_logic; -- negative error in auto track mode
	  Mode1		: in  std_logic; -- 0= Manual 1= Auto(track)
	  Mode2		: in  std_logic; -- 0= normal 1= dBV measurement
          LED1 		: out std_logic_vector(1 downto 0); -- Bicolor led drive (MSB =green / LSB =red)
          LED2		: out std_logic_vector(1 downto 0) --  Bicolor led drive (MSB =green / LSB =red)          
    );
 end LED_decode_v2;
 
architecture decoder of LED_decode_v2 is


begin
-- LED colors are : 
-- off=00 red="01" green="10" orange="11"

-- LED1 definition :
LED1 <= "00" when (EN_Clk='0') else  --leds OFF when quiet mode active
	"10" when (Mode2 ='0') else  -- green in normal mode display
	"01" when (Mode2 ='1' );     -- red in dBV display

--LED2 definition :
-- error LED = red:positive /  green: negative / off: no error
LED2 <=  "00" when (EN_Clk='0') else  
	(err_signN & err_signP)	when (Mode1='1') else -- 
			"11" 	when (Mode1='0');
		  
		  
		  

end architecture;
