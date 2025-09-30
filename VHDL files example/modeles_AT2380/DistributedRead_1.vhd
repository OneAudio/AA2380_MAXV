------------------------------------------------------------------
-- ON le 14/05/2017
-- Function to read data from LT2380-24 ADC using the distributed
-- readind protocol
---
--- Explanation :
--
--
--
--
--
--
--
--
--
-----------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DistributedRead_1 is
port(
  clock         : in  std_logic; -- 9.304 MHz input clock
  FSmax         : in  std_logic; -- Maximum sampling clock (1536 kHz)
  AVG           : in std_logic_vector(2 downto 0); -- averaging rati (1 to 128) 
  DATAO 	     	: out std_logic_vector(23 downto 0)); --ADC parrallel output data
  --- ADC control signals
  cnv           : out std_logic ; -- ADC enable conv signal
  sck           : out std_logic ; -- ADC clock
  busy          : in std_logic  ; -- ADC busy signal
  sdo           : in std_logic  ; -- ADC data output
 
end DistributedRead_1;

architecture Behavioral of DistributedRead_1 is



begin







end behavioral;
