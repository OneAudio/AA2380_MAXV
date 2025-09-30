-----------------------------------------------------------------
-- O.N 28/09/2017 - SAR_ADC_v12
--
-- The Attenuator is set directly according to dB level read
-- 8 bits ADC data come in muxed mode.
-- TAKE 134 LE
-- 
-- New :
-- Adding output for dBV sign display
-- Display refresh rate is 8Hz and Relays refresh rate is 2Hz.
-- + Improve dBV resolution to 0.5dBV (9bits ADC data width)
-- 
--                  !!Test Module !!
-- ++ Big modifications to reduce time between ADC dBV reading and
-- calculated attenuator setting.
-- !! V10 is tested and amplitude control work OK !!
-- New in v11 (to be tested):
-- Allow to display dBV measurement or dBV setting in auto mode,
-- because measurement is slow (refreshed at relays control speed).
--
-- Now, ADC data (dBVscaled) come from a new function "ADC_MCP3202_Burst".
-- It compute the difference between both channels (measure-offset) and
-- made 32 samples averaging for lowering noise.
-- It provide then clean signed data with -180/+20 scale for -90/+10 dBV
-- with 0.5dBV resolution.
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


 entity SAR_ADC_v12 is
    Port (
          clk8Hz			   : in  std_logic; -- 8Hz clock (displayed value refresh)
          clkSAR         : in  std_logic; -- Read ADC clock = 2Hz
          Mode				   : in  std_logic; -- Manual(0) or auto mode control (1)
          MANUAL			   : in std_logic_vector (7 downto 0); -- manual mode relays control or dBV setting
          dBVscaled      : in  signed (8 downto 0); -- ADC dBV value (-180 +20 for -90 to +10dBV)
          RELAYS         : buffer std_logic_vector(7 downto 0); -- Attenuator control (8 bits)
          dBV_Disp			 : out std_logic_vector(7 downto 0); -- Output to display dB Level
          Minus          : out std_logic;  -- Sign output, 1= negative dBV 0 = positive dBV.
          Vmesure        : out unsigned (7 downto 0);-- Test output
          Verror         : out unsigned (7 downto 0);-- Test output
          LEDerror       : out std_logic;
          Measure_nSett  : in std_logic ; -- Auto mode display selection 
--          XdBVsetting  : out unsigned (7 downto 0) -- Test output
--          XDelta  : out unsigned (7 downto 0); -- Test output
          xrelay         : out unsigned (7 downto 0);  --Test output
          XdBVscaled     : out signed (8 downto 0)  -- Test output
 --         XNEG : out unsigned (7 downto 0);  -- Test output
 --         XPOSIT  : out unsigned (7 downto 0);  -- Test output
		);
 end SAR_ADC_v12;

architecture AutoTrack of SAR_ADC_v12 is

signal REL			       : std_logic_vector (7 downto 0) :=x"FF" ; -- default value of attenuator is maxi  (-127.5dB)
signal XREL				     : unsigned (7 downto 0) :=x"FF" ; -- attenuator value calculated for amplitude control.
signal dBVdisplay		   : std_logic_vector (8 downto 0); -- absolute 9 bits dBV values with 0.5dB resolution
signal Vmeas           : unsigned (7 downto 0);-- dBV scaled measurement 0..200 for -90 to +10dBV
signal Vsett           : unsigned (7 downto 0);-- unsigned value of MANUAL
signal error           : unsigned (7 downto 0);--
signal error_sign		   : integer range 0 to 2; --
signal ManuScaled      : signed (8 downto 0);--
signal dBV_dispA       : std_logic_vector (8 downto 0);-- 9 bit temporary value of dBV_Disp



begin

----Test signals
Vmesure <= Vmeas ;
Verror  <= error;
--XdBVsetting <= dBVsetting ;
-- XDelta <= Delta;
XdBVscaled <= dBVscaled;
xrelay <= XREL;
-----------------

-- unsigned convertion of 8 bits setting counter 
-- (must be limited to 200 in auto mode ?)
Vsett <= unsigned (MANUAL);

-------------------------------------------------------
--                    OLD BLOCK
-- dBVscaled 180 for -90dBV to 20 for +10dBV and sign.
-- Note :
-- dB display is refreshed at clk8Hz rate,
-- but attenuator control is refreshed only clkSAR rate
-- to avoid fast relays drive.
-- 9 bits ADC data for 0.5 dBV resolution.
-------------------------------------------------------
-- process(clk8Hz,clkSAR,dBVscaled)
-- begin
--     if rising_edge(clk8Hz) then --Synchronize all to clk8Hz
--     	if	mode = '1' then -- auto level tracking enable
--          case dBVnBin is -- FOR TEST ONLY
--              when '1' =>  dBV_Disp <= dBVdisplay(7 downto 0) ; -- dBV measurement is displayed
--                               REL  <= MANUAL; -- Relays are directly driven by counter
--              when '0' =>  dBV_Disp <= MANUAL   ; -- counter value is displayed (0..200 => 0 .. 99)
--                                REL <= REL; -- Relays are freezed
--          end case;
--          if 	dBVscaled >= 0 then
--   			 		  dBVdisplay <= std_logic_vector(dBVscaled) ; -- Positive dBV value
--   			   	  Minus <= '0' ; -- "-" sign is off
--   			 else
--   					  dBVdisplay <= std_logic_vector (1 + not(dBVscaled)) ; -- Negative dBV value
--   					  Minus <= '1' ; -- "-" sign is on
--   			 end if;
--   		else	 -- Manual mode
--     			dBV_Disp	<=	 MANUAL; -- Manual attenuation control in 0.5dB step (0 to 255 for 0dB to -127.5 dB)
--     			REL  <= MANUAL; -- Relays drived directly by counter
-- 		end if;
-- end if;
-- end process;


--------------------------------------------------------------------
--                      !!! NEW !!!
--
-- Counter value is converted for dBV setting display (-180/+20)
-- for real -90.0 dBV to +10.0dBV displayed
--
-- This function allow the display of counter value in manual control mode
-- from 0 to -127.5.
-- In Auto-track mode, we can display the dBV setting (that have a fast
-- updated value) or the dBV measurement  with lower updated value
-- because relays are only driven at slow rate (2Hz).
-- The signal "Set_nMeas" allow to select what is displayed in auto mode,
-- measurement or setting.
--------------------------------------------------------------------
process(clk8Hz,Vsett,ManuScaled,dBVscaled,mode,Measure_nSett)
begin
    if rising_edge(clk8Hz) then
    -- add -180 LSB offset to counter value to get -180/+20 value to be displayed
    ManuScaled <= signed (('0' & Vsett) - 180) ; -- add 1 MSB to Vsett and shift to -180 for 0..200 lsb = -180..+20 lsb 
       	if	mode = '0' then -- Manual mode enable
       	    dBV_Disp	<=	 MANUAL; -- Manual attenuation control in 0.5dB step (0 to 255 for 0dB to -127.5 dB)
      	else               -- Auto tracking mode enable
      	    dBV_Disp	<=	 dBV_dispA (7 downto 0); -- dBV Measurement or dBV setting  display (+20 to -180 for +10dB to -90 dBV) / MSB removed.
          	if    Measure_nSett = '1' then -- In Auto mode : Display dBV measurement
                if 	  dBVscaled >= 0 then
          			 		  dBV_dispA <= std_logic_vector(dBVscaled) ; -- Positive dBV value
          			   	  Minus <= '0' ; -- "-" sign is off
          			else
          					  dBV_dispA <= std_logic_vector (1 + not(dBVscaled)) ; -- Negative dBV value
          					  Minus <= '1' ; -- "-" sign is on
          			end if;
          	else                       -- In Auto mode : Display dBV Setting
                if 	  ManuScaled >= 0 then
          			 		  dBV_dispA <= std_logic_vector(ManuScaled) ; -- Positive dBV value
          			   	  Minus <= '0' ; -- "-" sign is off
          			else
          					  dBV_dispA <= std_logic_vector (1 + not(ManuScaled)) ; -- Negative dBV value
          					  Minus <= '1' ; -- "-" sign is on
          			end if;
          	end if;
        end if;
    end if;
end process;


--------------------------------------------------------------------
--  dBV amplitude regulation loop     !!!! not tested yet !!!!
--
-- Vmes work only for a dBVscaled range of -180 to +20 signed binary
-- Vmeas=0 => minimum output voltage ~ -90dBV and Vmeas=200 => ~+10dBV
-- Note:
-- Vmeas and Vsett are with 0...200 range for -90 to +10dBV range.
-- XREL is the attenuator control from 0 to 255.
-- 0 for no attenuation and 255 for maximal attenuation(-127.5dB).
---------------------------------------------------------------------
--
-- Notes about more complex control loop to avoid relay switchs.
-----------------------------------------------------------------
-- It is possible to add a condition on the error level to stop the control
-- process. Maybe with hysteresis :
-- when Vin> Vset then 
--           If error > 2 LSB (1dB) then continue 
--           else stop control process.
-- when Vin < Vset
--           if error > 6 LSB (3dB) then start process
--            else stop control process
--
-- Another approach is ;
------------------------- 
-- control loop stop after n iteration (sampling)
--  or if error = 0 (Vset=Vmeas)
--  control loop start again only if absolute error is > x LSB.
--
---------------------------------------------------------------------  







process(clkSAR,Mode,REL,XREL,error_sign,Manual,Vmeas,Vsett,clk8Hz)
begin

-- Attenuator relays are driven by counter in Manual mode (0) and
-- by servo control loop in auto Mode (1). 
case Mode is
	when '0' => RELAYS <=  REL ; -- Attenuator relays are driven by counter only.
	when '1' => RELAYS <=  std_logic_vector(XREL) ;-- Attenuator Relays are drived by servo control
  when others => RELAYS <= x"00" ;
end case;


if  rising_edge(clkSAR) then 
    -- Relays drived directly by counter, at clkSAR rate (2Hz) to avoid fast relay switching
    REL  <= MANUAL;
    -- last dBVscaled ADC difference sample stored
    -- we control that dBV i not below -90dBV (-180) to avoid overflow
    if   dBVscaled < -180 then
         Vmeas <= x"00" ; -- set Vmeas to 0 when lower than -90dBV.
    else
         Vmeas <= unsigned(dBVscaled(7 downto 0) + 180) ; -- add +180 offset for converting -90/+10dBV(-180/+20lsb) to 0/200 range        
    end if;       
end if;

-- New attenuator value is set at falling edge  of clkSAR,
-- new value done at each clkSAR for slow relay switchs.
if  falling_edge(clkSAR) then --Synchronize to clkSAR (falling edge)
    if    error_sign = 0 then
--         if    error > (x"FF" - XREL) then
--               XREL <= XREL + error; -- maximum attenuation reached, back to less attenuation to avoid overflow
--         else
              XREL <= XREL + error; -- new attenuator value is old + error => more attenuation
--         end if;
    elsif error_sign = 1 then
        if    error > XREL then
              XREL <= x"00" ; -- no attenuation, but avoid overflow
        else
              XREL <= XREL - error;-- new attenuator value is old - error => less attenuation
        end if;
    else
          XREL <= XREL ; -- no error !
    end if;
end if;

-- Calculate absolute error and sign between setup and measurement.
if    Vmeas > Vsett then -- error is positive (output level is too high)
      error_sign <= 0; -- sign of error
      error <= (Vmeas - Vsett); -- always positive result
elsif Vmeas < Vsett then -- error is negative (output level is too low)
      error_sign <= 1; -- sign of error
      error <= (Vsett - Vmeas);-- always positive result
else
      error_sign <= 2; --8 Hz blink when error is null.
      error <= x"00" ;
end if;
  
-- error sign value (0 to 2) allow diff�rent indication of regulation states
case error_sign is
	when 0 => LEDerror <= '0' ; -- LED off = negative error  ()
	when 1 => LEDerror <= '1' ;	-- LED on positive error
	when 2 => LEDerror <= clk8Hz ; -- lED blink if error is null
end case;

end process;

end architecture;
