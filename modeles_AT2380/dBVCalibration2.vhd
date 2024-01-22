-----------------------------------------------------------------
-- O.N - 14/12/2017
-- take  8 LE
-- If /dBV_CALIB input is low, toggle each 5s between 0dB and -80dB
-- attenuation level regardless of actual configuration
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

 entity dBVCalibration2 is
    Port (
         Clk50mHz 	: in  	std_logic; -- 0.05Hz clock
         ndBVCalib	: in 	std_logic; -- calibration input with internal pull-up (active low)
			RELAYS_IN 	: in 	std_logic_vector (7 downto 0); -- attenuator relays drive input 
         RELAYS_OUT    : out	std_logic_vector (7 downto 0)  -- attennuator relays drive output
    );
 end dBVCalibration2;

architecture Attenuator of dBVCalibration2 is


begin
---------------------------------------------------------
-- Calibrating process when ndBVCalib is active (=0).
-- Set attenuation to 0 or -80dB each 5s.
---------------------------------------------------------


process (ndBVCalib,RELAYS_IN,Clk50mHz)
begin	
	if	ndBVCalib = '1' then
		RELAYS_OUT <= RELAYS_IN ;-- relays driven directly
	else
		if	Clk50mHz='0' then
			RELAYS_OUT <= x"00"; -- 0dB value toggle at div2 rate for calibrating process
		else
			RELAYS_OUT <= x"A0"; -- -80dB/0dB value toggle at clk100mHz rate for calibrating
										-- heax value are double og attenuation: A0= 160 =(2x80)
		end if;
	end if;
end process;   
end architecture;
