-----------------------------------------------------------------
-- O.N 31/08/2017
-- The Attenuator is set directly according to dB level read
-- 8 bits ADC data come in muxed mode.
-- TAKE xx LE
-- New :
-- Adding output for dBV sign display
-- Display refresh rate is 8Hz and Relays refresh rate is 2Hz.
-- + Improve dBV resolution to 0.5dBV (9bits ADC data width)
-- + New  input to enable servo amplitude control or not in auto mode.
--                  !!Test Module !!
-- ++ Big modifications to reduce time between ADC dBV reading and
-- calculated attenuator setting.
-- !! V10 is tested and amplitude control work OK !!
-- New in v11 (to be tested):
-- Allow to display dBV measurement or dBV setting in auto mode,
-- because measurement is slow (refreshed at relays control speed).
--
--
--
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

 entity SAR_ADC_v11 is
    Port (
          clk8Hz			   : in  std_logic; -- 8Hz clock (displayed value refresh)
          clkSAR         : in  std_logic; -- Read ADC clock = 2Hz
          Mode				   : in  std_logic; -- Manual(0) or auto mode control (1)
          servo          : in  std_logic; -- Servo control enable in (0= no servo, 1=servo dBV amplitude control)
          MANUAL			   : in std_logic_vector (7 downto 0); -- manual mode relays control or dBV setting
          dBVscaled       : in  signed (8 downto 0); -- ADC dBV value (-180 +20 for -90 to +10dBV)
          RELAYS         : buffer std_logic_vector(7 downto 0); -- Attenuator control (8 bits)
          dBV_Disp			 : out std_logic_vector(7 downto 0); -- Display dB Level
          Minus          : out std_logic;  -- Sign output, 1= negative dBV 0 = positive dBV.
          Vmesure        : out unsigned (7 downto 0);-- Test output
          Verror         : out unsigned (7 downto 0);-- Test output
          LEDerror       : out std_logic;
          dBVnBin        : in std_logic ; -- input selection
          Set_nMeas      : in std_logic ; -- input selection
--          XdBVsetting  : out unsigned (7 downto 0) -- Test output
--          XDelta  : out unsigned (7 downto 0); -- Test output
          xrelay         : out unsigned (7 downto 0);  --Test output
          XdBVscaled     : out signed (8 downto 0)  -- Test output
 --         XNEG : out unsigned (7 downto 0);  -- Test output
 --         XPOSIT  : out unsigned (7 downto 0);  -- Test output
		);
 end SAR_ADC_v11;

architecture AutoTrack of SAR_ADC_v11 is

signal REL			       : std_logic_vector (7 downto 0) :=x"FF" ; -- default value of attenuator is maxi  (-127.5dB)
signal XREL				     : unsigned (7 downto 0) :=x"FF" ; -- attenuator value calculated for amplitude control.
signal dBVdisplay		   : std_logic_vector (8 downto 0); -- absolute 9 bits dBV values with 0.5dB resolution
signal Vmeas           : unsigned (7 downto 0);-- dBV scaled measurement 0..200 for -90 to +10dBV
signal Vsett           : unsigned (7 downto 0);-- unsigned value of MANUAL
signal error           : unsigned (7 downto 0);--
signal dBV_DispA       : std_logic_vector (7 downto 0); --
signal control_on      : std_logic ;--
signal error_sign		   : integer range 0 to 2; --
signal ManuScaled      : signed (8 downto 0);--



begin

----Test signals
Vmesure <= Vmeas ;
Verror  <= error;
--XdBVsetting <= dBVsetting ;
-- XDelta <= Delta;
XdBVscaled <= dBVscaled;
xrelay <= XREL;
-----------------



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
-- This function the display of counter value in manual control mode
-- from 0 to -127.5.
-- In Auto-track mode, we can display the dBV setting (that have a fast
-- updated value) or the dBV measurement  with lower updated value
-- because relays are only driven at slow rate (2Hz).
-- The signal "Set_nMeas" allow to select what is displayed in auto mode.
--------------------------------------------------------------------
process(clk8Hz,Vsett,ManuScaled)
begin
    if rising_edge(clk8Hz) then
    -- add -180 LSB offset to counter value to get -180/+20 value to be displayed
    ManuScaled <= signed (Vsett -180) ;
    -- Relays drived directly by counter
    REL  <= MANUAL;
       	if	mode = '0' then -- Manual mode enable
       	    dBV_Disp	<=	 MANUAL; -- Manual attenuation control in 0.5dB step (0 to 255 for 0dB to -127.5 dB)
      	else               -- Auto tracking mode enable
          	if    Set_nMeas = '0' then -- In Auto mode : Display dBV measurement
                if 	  dBVscaled >= 0 then
          			 		  dBVdisplay <= std_logic_vector(dBVscaled) ; -- Positive dBV value
          			   	  Minus <= '0' ; -- "-" sign is off
          			else
          					  dBVdisplay <= std_logic_vector (1 + not(dBVscaled)) ; -- Negative dBV value
          					  Minus <= '1' ; -- "-" sign is on
          			end if;
          	else                       -- In Auto mode : Display dBV Setting
                if 	  ManuScaled >= 0 then
          			 		  dBVdisplay <= std_logic_vector(ManuScaled) ; -- Positive dBV value
          			   	  Minus <= '0' ; -- "-" sign is off
          			else
          					  dBVdisplay <= std_logic_vector (1 + not(ManuScaled)) ; -- Negative dBV value
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
process(clkSAR,control_on,servo,Mode,REL,XREL,error_sign,Manual,Vmeas,Vsett,clk8Hz)
begin
 -- tracking mode enable when mode is =1 and servo is =1
control_on <= servo and mode;
-- unsigned convertion 8 bits counter (must be limited to 200)
Vsett <= unsigned (MANUAL);
case control_on is
     when '0' => RELAYS <=  REL ; -- Attenuator relays are driven by counter only.
     when '1' => RELAYS <=  std_logic_vector(XREL) ;-- Attenuator Relays are drived by servo control
end case;

  if  rising_edge(clkSAR) then --Synchronize to clkSAR (rising edge)
      -- last dBVscaled ADC difference sample stored
      Vmeas <= unsigned(dBVscaled(7 downto 0) + 180) ; -- add +180 offset for converting -90/+10dBV(-180/+20lsb) to 0/200 range.
  end if;
  -- New attenuator value is set at falling edge  of clkSAR,
  if  falling_edge(clkSAR) then --Synchronize to clkSAR (falling edge)
      if    error_sign = 0 then
            XREL <= XREL + error; -- new attenuator value is old + error => more attenuation
      elsif error_sign = 1 then
            XREL <= XREL - error;-- new attenuator value is old - error => less attenuation
      else
            XREL <= XREL ; -- no error !
      end if;
  end if;
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
case error_sign is
	when 0 => LEDerror <= '0' ; -- LED off = negative error  ()
	when 1 => LEDerror <= '1' ;	-- LED on positive error
	when 2 => LEDerror <= clk8Hz ; -- lED blink with no error
end case;

end process;

end architecture;
