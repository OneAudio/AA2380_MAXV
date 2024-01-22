-----------------------------------------------------------------
-- O.N 08/2017
-- The Attenuator is set directly according to dB level read
-- 8 bits ADC data come in muxed mode.
-- Difference Ch0-Ch1 is made each clkSAR period
-- and give directly attenuation value.
-- TAKE 96 LE
-- add output for dBV sign display
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
 
 entity SAR_ADC_v2 is
    Port ( 
--          clk2kHz			: in  std_logic; -- 2kHz clock (unused)
          clkSAR      		: in  std_logic; -- Read ADC clock = 2Hz
          Mode				: in  std_logic; -- Manual(0) or auto mode control (1)
          MANUAL			: in std_logic_vector (7 downto 0); -- manual mode relays control or dBV setting
          ADC_data_valid 	: in  std_logic; -- data valid signal (to latch channel data)
          ADC_channel    	: in  std_logic; -- ADC Channel 0/1 input 
          ADC_data       	: in  std_logic_vector (7 downto 0); -- ADC DATA for both channels
          RELAYS            : buffer std_logic_vector(7 downto 0); -- Attenuator control (8 bits)
          dBV_Disp			: out std_logic_vector(7 downto 0); -- Display dB Level
          Minus         :out std_logic ; -- Sign output, 1= negative dBV 0 = positive dBV. 
          XdBVsetting  : out unsigned (7 downto 0) ; -- Test output
          XDelta  : out unsigned (7 downto 0); -- Test output
          XdBVscaled  : out signed (7 downto 0)  -- Test output 
 --         XNEG : out unsigned (7 downto 0);  -- Test output
 --         XPOSIT  : out unsigned (7 downto 0);  -- Test output
 --        dBVdisplay : out std_logic_vector(7 downto 0) -- display dBV output
    ); 
 end SAR_ADC_v2;
 
architecture AutoTrack of SAR_ADC_v2 is

signal u_ch0_data       : unsigned(7 downto 0) ; -- unsigned value of ADC channel 0
signal u_ch1_data       : unsigned(7 downto 0) ; -- unsigned value of ADC channel 1
signal dBVscaled       	: signed(7 downto 0) ; -- unsigned value of ADC ch1-ch0 = Gain/offset corrected outpu dBV amplitude
signal Delta       		: unsigned(7 downto 0) ; -- Vout - dBV setting (error)
signal dBVsetting      	: unsigned(7 downto 0) ; -- Set value of dBV in auto mode
signal REL				: unsigned(7 downto 0) :=x"FF" ; -- default value of attenuator is maxi  (-127.5dB)
signal dBVdisplay		: std_logic_vector (7 downto 0);


begin 

----Test signals
XdBVsetting <= dBVsetting ;
XDelta <= Delta;
XdBVscaled <= dBVscaled;
-----------------

-------------------------------------------------------
-- ADC channels demux and latched  with ADC_data_valid
-------------------------------------------------------
process(ADC_data,ADC_data_valid,ADC_channel)
begin 
  if falling_edge(ADC_data_valid) then
	dBVscaled 	<= signed(u_ch1_data - u_ch0_data) ; -- ch0 - ch1
    if  ADC_channel='0'  then
      u_ch0_data 	<= unsigned (ADC_data(7 downto 0)); -- Channel 0 is offset value
    else
      u_ch1_data 	<= unsigned (ADC_data(7 downto 0)); -- Channel 1 is dBV value from AD8310
    end if;
  end if;
end process;

-------------------------------------------------------
-- Error calculation for attenuator set to give
-- right dBV selected value by setting
-- and limit value to avoid wrong negative results
-- dBVscaled 180 for -90dBV to 20 for +10dBV and sign.
-------------------------------------------------------
process(clkSAR,dBVscaled,dBVsetting)
begin
    if rising_edge(clkSAR) then --Synchronize all to clkSAR
    	if	mode = '1' then -- auto level tracking enable
			dBVsetting	<=	unsigned (MANUAL(7 downto 0));
--			RELAYS <= std_logic_vector (REL);
			dBV_Disp	<=	 std_logic_vector(dBVscaled) ; -- direct dBV display in auto mode (+10/-90dBV).
				if 	dBVscaled >= 0 then
			 		dBVdisplay <= std_logic_vector(dBVscaled) ; -- Positive dBV value
					Minus <= '0' ; -- "-" sign is off
				else 
					dBVdisplay <= std_logic_vector (1 + not(dBVscaled)) ; -- Negative dBV value
					Minus <= '1' ; -- "-" sign is on 
				end if;
				RELAYS    <=   	MANUAL; -- Relays drived directly by counter
				dBV_Disp  <=	dBVdisplay;
		else	 -- Manual mode
				RELAYS    <=   MANUAL; -- Relays drived directly by counter
				dBV_Disp	<=	 MANUAL; -- Manual attenuation control in 0.5dB step (0 to -127.5 dB)
		end if;
    end if;
end process;

-------------------------------------------------------
-- Proportinal only regulation loop
--- not ok yet!
-------------------------------------------------------
--process(clkSAR,dBVscaled,dBVsetting)
--begin
--  if rising_edge(clkSAR) then --Synchronize all to clkSAR
--    if    dBVscaled > dBVsetting then
--          REL <= dBVscaled - dBVsetting ;
--    elsif dBVscaled < dBVsetting then
--          REL <= dBVscaled + dBVsetting ;
--    else  REL <= REL ;
--    end if;
--  end if;
--end process;

end architecture;
