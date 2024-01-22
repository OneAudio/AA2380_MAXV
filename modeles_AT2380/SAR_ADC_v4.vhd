-----------------------------------------------------------------
-- O.N 23/08/2017
-- The Attenuator is set directly according to dB level read
-- 8 bits ADC data come in muxed mode.
-- Difference Ch0-Ch1 is made each clkSAR period
-- and give directly attenuation value.
-- TAKE xx LE
-- New :
-- Adding output for dBV sign display
-- Display refresh rate is 8Hz and Relays refresh rate is 2Hz.
-- + Improve dBV resolution to 0.5dBV (9bits ADC data width)
-- + New  input to enable servo amplitude control or not in auto mode.
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
 
 entity SAR_ADC_v4 is
    Port ( 
          clk8Hz			: in  std_logic; -- 8Hz clock (displayed value refresh)
          clkSAR      		: in  std_logic; -- Read ADC clock = 2Hz
          Mode				: in  std_logic; -- Manual(0) or auto mode control (1)
          servo       : in  std_logic; -- Servo control enable in (0= no servo, 1=servo dBV amplitude control)
          MANUAL			: in std_logic_vector (7 downto 0); -- manual mode relays control or dBV setting
          ADC_data_valid 	: in  std_logic; -- data valid signal (to latch channel data)
          ADC_channel    	: in  std_logic; -- ADC Channel 0/1 input 
          ADC_data       	: in  std_logic_vector (8 downto 0); -- ADC DATA for both channels
          RELAYS            : buffer std_logic_vector(7 downto 0); -- Attenuator control (8 bits)
          dBV_Disp			: out std_logic_vector(7 downto 0); -- Display dB Level
          Minus         :out std_logic  -- Sign output, 1= negative dBV 0 = positive dBV. 
--          XdBVsetting  : out unsigned (7 downto 0) -- Test output
--          XDelta  : out unsigned (7 downto 0); -- Test output
--          XdBVscaled  : out signed (7 downto 0)  -- Test output 
 --         XNEG : out unsigned (7 downto 0);  -- Test output
 --         XPOSIT  : out unsigned (7 downto 0);  -- Test output
		); 
 end SAR_ADC_v4;
 
architecture AutoTrack of SAR_ADC_v4 is

signal u_ch0_data       : unsigned(8 downto 0) ; -- unsigned value of ADC channel 0
signal u_ch1_data       : unsigned(8 downto 0) ; -- unsigned value of ADC channel 1
signal dBVscaled       	: signed(8 downto 0) ; -- unsigned value of ADC ch1-ch0 = Gain/offset corrected outpu dBV amplitude
signal REL				: std_logic_vector (7 downto 0) :=x"FF" ; -- default value of attenuator is maxi  (-127.5dB)
signal XREL				: unsigned (7 downto 0) :=x"FF" ; -- attenuator value calculated for amplitude control.
signal dBVdisplay		: std_logic_vector (8 downto 0);
signal Vmeas           : unsigned (7 downto 0);-- dBV scaled measurement 0..200 for -90 to +10dBV
signal Vsett           : unsigned (7 downto 0);-- unsigned value of MANUAL


begin 

----Test signals
--XdBVsetting <= dBVsetting ;
-- XDelta <= Delta;
--XdBVscaled <= dBVscaled;
-----------------

-------------------------------------------------------
-- ADC channels demux and latched  with ADC_data_valid
-------------------------------------------------------
process(ADC_data,ADC_data_valid,ADC_channel)
begin 
  if falling_edge(ADC_data_valid) then
	dBVscaled 	<= signed(u_ch1_data - u_ch0_data) ; -- ch0 - ch1 (result is signed for -180/+20 for -90 to +10dBV)
    if  ADC_channel='0'  then
      u_ch0_data 	<= unsigned (ADC_data(8 downto 0)); -- Channel 0 is offset value
    else
      u_ch1_data 	<= unsigned (ADC_data(8 downto 0)); -- Channel 1 is dBV value from AD8310
    end if;
  end if;
end process;

-------------------------------------------------------
-- dBVscaled 180 for -90dBV to 20 for +10dBV and sign.
-- Note :
-- dB display is refreshed at clk8Hz rate,
-- but attenuator control is refreshed only clkSAR rate
-- to avoid fast relays drive.
-- 9 bits ADC data for 0.5dBV resolution.
-------------------------------------------------------
process(clk8Hz,clkSAR,dBVscaled)
begin
    if rising_edge(clk8Hz) then --Synchronize all to clk8Hz
    	if	mode = '1' then -- auto level tracking enable
				if 	dBVscaled >= 0 then
			 		dBVdisplay <= std_logic_vector(dBVscaled) ; -- Positive dBV value
					Minus <= '0' ; -- "-" sign is off
				else 
					dBVdisplay <= std_logic_vector (1 + not(dBVscaled)) ; -- Negative dBV value
					Minus <= '1' ; -- "-" sign is on 
				end if;
				REL    <=   	MANUAL; -- Relays drived directly by counter
				dBV_Disp  <=	dBVdisplay(7 downto 0); -- MSB removed for 8 bits output.
		else	 -- Manual mode
				REL       <=   MANUAL; -- Relays drived directly by counter
				dBV_Disp	<=	 MANUAL; -- Manual attenuation control in 0.5dB step (0 to 255 for 0dB to -127.5 dB)
		end if;
end if;  
end process;

-------------------------------------------------------
-- Proportinal only regulation loop
--- not ok yet!
-------------------------------------------------------
process(clkSAR,dBVscaled,Vmeas,Vsett,XREL,MANUAL)
begin
Vsett <= unsigned (MANUAL); -- unsigned convertion 8 bits counter (must be limited to 200)
Vmeas <= unsigned(dBVscaled(7 downto 0) + 180) ; -- add +180 offset for converting -90/+10dBV(-180/+20lsb) to 0/200 range.
  if rising_edge(clkSAR) then --Synchronize all to clkSAR
    if    Vmeas > Vsett then -- error is positive
          XREL <= XREL + (Vmeas - Vsett) ; -- new attenuator value is old + error
    elsif Vmeas < Vsett then -- error is negative
          XREL <= XREL - (Vmeas + Vsett) ; -- new attenuator value is old - error
    else  XREL <= XREL ; -- when Vmeas=dBVsetting, no attenuator value change ! 
    end if;
  end if;
end process;


-------------------------------------------------------
-- Attenuator relays drive selection
-------------------------------------------------------
process (clkSAR,REL,XREL,mode,servo)
begin
  if  rising_edge(clkSAR) then --REL signal is reclocked to 2Hz for lower refreshing rate.
    if  servo='1' and mode ='1' then  -- Auto mode and servo are enable
        RELAYS <= std_logic_vector(XREL); -- Attenuator Relays are drived by servo control  
    else
        RELAYS <=  REL; -- Attenuator relays are driven by counter only.
    end if;  
  end if;
end process;

end architecture;
