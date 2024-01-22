-----------------------------------------------------------------
-- O.N - 10/12/2017
-- take 8 LE
-- If /dBV_CALIB input is low, toggle each 5s between 0dB and -80dB
-- attenuation level regardless of actual configuration
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

 entity dBVCalibration is
    Port (
          Clk100mHz 	: in  	std_logic; -- 0.1Hz clock
          ndBVCalib	: in 	std_logic; -- calibration input with internal pull-up (active low)
	  RELAYS_IN 	: in 	std_logic_vector (7 downto 0); -- attenuator relays drive input 
          RELAYS_OUT    : out	std_logic_vector (7 downto 0)  -- attennuator relays drive output
    );
 end dBVCalibration;

architecture Attenuator of dBVCalibration is

signal wclock : std_logic_vector (7 downto 0);--

begin

---------------------------------------------------------
-- Calibrating process when ndBVCalib is active (=0).
-- Set attenuation to 0 or -80dB each 5s.
---------------------------------------------------------
process (ndBVCalib,RELAYS_IN,wclock,Clk100mHz)
begin

wclock <= (others => Clk100mHz);--convert clock100mHz in vector

case ndBVCalib is
	when	'1' => RELAYS_OUT <= RELAYS_IN ;-- relays driven directly
	when	'0' => RELAYS_OUT <= x"A0" and wclock ;-- -80dB/0dB value toggle at clk100mHz rate for calibrating
end case;
end process;   

end architecture;
