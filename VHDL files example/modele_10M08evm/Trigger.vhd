--------------------------------------------------------------------------------
-- ON le 06/03/2017 -- pour LTC2380-24
-- This function allow to discriminate the fundamental input frequency
-- by comparing instantaneous value of the signal (datain) with the level of 
-- +/- 1/4 of the peak values.
-- Then, the square wave output signal  (Trig) change at same frequency than
-- the fundamental of input signal.
-- This signal is made to be send on "frequency metering function" that will
-- display the input frequency.
-- The "sat" output allow to indicate digital saturation of the signed input. 
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all ;

ENTITY Trigger IS
  PORT(
		Clock		 : IN  STD_LOGIC; --system clock (48-96 or 192kHz)
		Refresh		: IN  STD_LOGIC; -- Refresh input (4 Hz)
		DATAIN    	: IN signed(23 DOWNTO 0); -- 24 bits signed input data
		DC			: IN signed(23 DOWNTO 0); -- 24 bits DC value for triggering threshold compensation
		TRIG		: OUT STD_LOGIC; -- Trigger output
		saturation	: OUT STD_LOGIC; -- saturation indictaor
		peakp_slow	: buffer signed(23 downto 0);-- Peak value of input signal (test only)	
		peakm_slow	: buffer signed(23 downto 0);
		pkm     	: buffer signed(23 downto 0);
		pkp     	: buffer signed(23 downto 0);
		PTh         : out signed(23 downto 0);
		Nth         : out signed(23 downto 0);
		dataAC		: out signed(23 downto 0)
		);
END Trigger;

Architecture Behavioral of Trigger is
--signal	pkp 		: signed(23 downto 0); -- Positive peak value.
--signal	pkm 		: signed(23 downto 0); -- Negative peak value.
signal clear			: std_logic :='0'  ; -- Clear of fisrt FF.
signal sat				: std_logic :='0'  ; -- saturation indicator
signal Pthreshold		: signed(23 downto 0);
signal Nthreshold 		: signed(23 downto 0);
signal Qa				: std_logic :='0'  ; -- First FF output of pulse generator triggered by Refresh clock.
--signal peakp_slow 	: signed (23 downto 0);--Sampled by  refresh positive peak value
--signal peakm_slow 	: signed (23 downto 0);--Sampled by  refresh negative peak value.
signal datainac			:  signed(23 downto 0);


----------------------------------------------------------
--Calcultate +/-peak value in real time and saturation  --
----------------------------------------------------------
begin
  datainac <= (datain -DC);
  dataAC <= datainac ;
  Pth <= Pthreshold;
  Nth <= Nthreshold;

	process begin
    wait until rising_edge(Clock);
     if clear='1' then      -- Peak are cleared at each rising edge of Refresh.
        pkp <= x"000000";
		pkm <= x"000000";
        Sat<= '0' ;
      elsif datainac > pkp then -- positive peak detection
        pkp <= datainac ;
      elsif datainac < pkm then -- negative peak detection
        pkm <= datainac ;
      elsif pkp=x"7FFFFF" or pkm=x"800000"  then -- Saturation limit of signed input
		Sat <= '1';
      end if;    
   end process;

-------------------------------------------------------
--Peak values is stored at each rising edge of refresh
-------------------------------------------------------
process (Refresh)
begin
	if Refresh'event and Refresh ='1' then
	peakp_slow <= (pkp);
	peakm_slow <= (pkm);
	saturation <= (sat);
	Pthreshold <= (("00" & (Pkp (23 downto 2))));-- + peak Divide by 4
	Nthreshold <= (("11" & (Pkm (23 downto 2))));-- - peak Divide by 4
	end if;
end process;

----------------------------------------------------------------------
--Compare signed input value with +/-1/4 of sampled peak value
-- with DC part of signal compensated
----------------------------------------------------------------------

   process begin
	wait until rising_edge(Clock);
		if datainac > Pthreshold then		-- data > +1/4 peakslow => tri=1
		TRIG <= '1' ;
		elsif datainac < Nthreshold then	-- data < -1/4 peakslow => tri=1
   		TRIG <= '0' ;
		end if;
	end process;

-----------------------------------------
-- Generate a one clk cycle pulse for each 
-- rising edge of Refresh clock. 
-----------------------------------------
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
    
