-----------------------------------------------------------------------------------
-- ON le 06/03/2017 -- pour LTC2380-24
-- This function allow to discriminate the fundamental input frequency
-- by comparing instantaneous value of the signal (datain) with the level of 
-- +/- 1/4 of the peak values.No trig available if peak of signal is below -90dBFS.
-- Then, the square wave output signal  (Trig) change at same frequency than
-- the fundamental of input signal.
-- This signal is made to be send on "frequency metering function" that will
-- display the input frequency.
-- The "sat" output allow to indicate digital saturation of the signed input.
--- Take 152 LE. 
------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all ;

ENTITY Trigger1 IS
  PORT(
		Clock		 : IN  STD_LOGIC; --system clock (48-96 or 192kHz)
		Refresh		: IN  STD_LOGIC; -- Refresh input (4 Hz)
		DATAIN    	: IN signed(23 DOWNTO 0); -- 24 bits signed input data
		TRIG		: OUT STD_LOGIC; -- Trigger output
		saturation	: OUT STD_LOGIC -- saturation indicator
--		pkm     	: buffer signed(23 downto 0); 	-- Test only
--		pkp     	: buffer signed(23 downto 0);	-- Test only
--		PTho         : out signed(23 downto 0);		-- Test only
--		Ntho         : out signed(23 downto 0)		-- Test only
--		TRIG2		: OUT STD_LOGIC; -- 2nd trigger output
--		TRIG3		: OUT STD_LOGIC -- 2nd trigger output
		);
END Trigger1;

Architecture Behavioral of Trigger1 is
signal clear			: std_logic :='0'  ; -- Clear of fisrt FF.
signal sat				: std_logic :='0'  ; -- saturation indicator
signal Pkps				: signed(23 downto 0); -- Stored peak value
signal Pkms				: signed(23 downto 0); -- Stored peak value
signal Pkp				: signed(23 downto 0); -- peak value
signal Pkm				: signed(23 downto 0); -- peak value
signal Pth				: signed(23 downto 0); -- Positive threshold detection
signal Nth 				: signed(23 downto 0); -- Negative threshold detection
signal Qa				: std_logic :='0'  ; -- First FF output of pulse generator triggered by Refresh clock.

----------------------------------------------------------
-- Calcultate +/-peak value for each input sample 
-- and detect saturation  
----------------------------------------------------------
begin
--	Ptho <= pkms;
--	Ntho <= Pkps;
	process (clock,clear)
begin
	if rising_edge(Clock) then 
		if clear = '0' then
		  	if 		datain > pkp then -- positive peak detection
					pkp <= datain ;
			elsif	datain < pkm then -- negative peak detection
					pkm <= datain ;
			end if;
			if 		pkp=x"7FFFFF" or pkm=x"800000"  then -- Saturation limit of signed input
					Sat <= '1';
			else
			SAT <= '0';
			end if;
		else
		pkp <= x"000000"; -- Peaks are cleared at each rising edge of Refresh.
		pkm <= x"000000";
        Sat <= '0' ; -- Sat clear at each rising edge of Refresh.
		end if; 	
	end if; 
end process;

------------------------------------------------------------------------
----Compare input value from 0 value
------------------------------------------------------------------------
--
--   process begin
--	wait until rising_edge(Clock);
--		if datain > 0 then		-- data > 0 => trig2=1
--		TRIG2 <= '1' ;
--		elsif datain < 0 then	-- data < 0 => trig2=0
--   		TRIG2 <= '0' ;
--		end if;
--	end process;
--
------------------------------------------------------------------------
----Compare input value from -80dBFS value
------------------------------------------------------------------------
--
--   process begin
--	wait until rising_edge(Clock);
--		if datain > 1000 then		-- data > 1000 => trig3=1
--		TRIG3 <= '1' ;
--		elsif datain < -1000 then	-- data < -1000 => trig3=0
--   		TRIG3 <= '0' ;
--		end if;
--	end process;

-----------------------------------------------------------------------
-- Peak values are stored at each falling edge of refresh
-- Thresold limits are equal to +/- 25% of peaks ( div by 4).
-----------------------------------------------------------------------
process (Refresh)
begin
	if falling_edge(Refresh) then
--	if clear = '1' then
	saturation <= (sat);
	Pth  <= (("00" & (Pkp (23 downto 2))));-- + peak Divided by 4
	Nth  <= (("11" & (Pkm (23 downto 2))));-- - peak Divided by 4
	Pkps <= Pkp ; --Pkp value stored
	Pkms <= Pkm ; --Pkm value stored
	end if;
end process;

-----------------------------------------------------------------------------
-- Trig output:
-- Compare signed input value with +/-1/4 of sampled peak value
-- with DC part of signal compensated
--The trig output is valid only for peaks level more than +/- 255 LSB (-96dB).
------------------------------------------------------------------------------
process 
begin
	wait until rising_edge(Clock);
		if Pkps > x"0000FF" or Pkms < x"FFFF01" then -- Minimum level of peak
			if 		datain > Pth then		
					TRIG <= '1' ; -- data > +1/4 peakslow => trig=1
			elsif 	datain < Nth then	
					TRIG <= '0' ; -- data < -1/4 peakslow => trig=0
			end if;
		else
		TRIG <= '0'; -- Trig=0 for peak value below -90dBFS
		end if;
	end process;

----------------------------------------------------
-- Generate a one clk cycle pulse (clear) for each 
-- rising edge of Refresh clock. 
----------------------------------------------------
process (Refresh, clear)
begin
if clear='1' then
	Qa <= '0';
elsif (Refresh'event and Refresh='1') then
	Qa <= '1';
end if;
end process;

process (Clock)
begin
if Clock'event and Clock ='1' then
clear<= Qa;
end if;
end process;

end Behavioral;
    
