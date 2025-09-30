-----------------------------------------------------------------
-- O.N 31/12/17 - SAR_ADC_v13A
-- TAKE 178  LE
--
-- The Attenuator is set directly according to dB level read
-- 8 bits ADC data come in muxed mode.
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
-- In Auto mode, it is the dBV setting (!) not measurement
-- that it is displayed , because measurement is slow.
-- (Anyway, with Mode2 input, the dBV measuurement can also be displayed if needed.)
--
-- Now, ADC data (dBVscaled) come from a new function "ADC_MCP3202_Burst".
-- It compute the difference between both channels (measure-offset) and
-- made N samples averaging for lowering noise.
-- It provide then clean signed data with -180/+20 scale for -90/+10 dBV
-- with 0.5dBV resolution.
-- v12B) Add Mode2 input to activate dBV measurement display
-- v12B) Add +/- 2LSB error tolerance in tracking (Auto) mode
-- Add 2 leds outputs for error display without blink mode
--
--Addind limits ?
-- update 10/12/17 clean unused variable
--
-- Adding fast relays update rate option
-- Including calibration input
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


 entity SAR_ADC_v13A is
    Port (
          clk50mHz      : in  std_logic; -- 0.05 Hz clock (20s period)
          clk8Hz	      : in  std_logic; -- 8Hz clock (displayed value refresh)
          clkSAR        : in  std_logic; -- Read ADC clock = 2Hz
          ndBVCalib     : in  std_logic; -- Calibration input with internal pull-up (active low)
	       nFastMode     : in  std_logic; -- Fast relays update rate  option
          Mode		      : in  std_logic; -- Manual(0) or auto mode control (1)
          Mode2         : in  std_logic; -- When active (1) , the dBV output level is displayed (any mode).
          MANUAL		   : in std_logic_vector (7 downto 0); -- manual mode relays control or dBV setting
          dBVscaled     : in  signed (8 downto 0); -- ADC dBV value (-180 +20 for -90 to +10dBV)
          RELAYS        : buffer std_logic_vector(7 downto 0); -- Attenuator control (8 bits)
          dBV_Disp	   : out std_logic_vector(7 downto 0); -- Output to display dB Level
          Minus         : out std_logic;  -- Sign output, 1= negative dBV 0 = positive dBV.
--          Vmesure       : out unsigned (7 downto 0);-- Test output
--          Verror        : out unsigned (7 downto 0);-- Test output
          LEDerrorP     : out std_logic;-- positive error output
			 
          LEDerrorN     : out std_logic-- negative error output
--          XdBVsetting  : out unsigned (7 downto 0) -- Test output
--          XDelta  : out unsigned (7 downto 0); -- Test output
--          xrelay         : out unsigned (7 downto 0);  --Test output
--          XdBVscaled     : out signed (8 downto 0)  -- Test output
--         XNEG : out unsigned (7 downto 0);  -- Test output
--         XPOSIT  : out unsigned (7 downto 0);  -- Test output
		);
 end SAR_ADC_v13A;

architecture AutoTrack of SAR_ADC_v13A is

signal REL			     : std_logic_vector (7 downto 0) :=x"FF" ; -- default value of attenuator is maxi  (-127.5dB)
signal XREL				  : unsigned (7 downto 0) :=x"FF" ; -- attenuator value calculated for amplitude control.
signal dBVdisplay		  : std_logic_vector (8 downto 0); -- absolute 9 bits dBV values with 0.5dB resolution
signal Vmeas           : unsigned (7 downto 0);-- dBV scaled measurement 0..200 for -90 to +10dBV
signal Vsett           : unsigned (7 downto 0);-- unsigned value of MANUAL
signal error           : unsigned (7 downto 0);--
signal error_sign      : integer range 0 to 2; --
signal ManuScaled      : signed (8 downto 0);--
signal dBV_dispA       : std_logic_vector (8 downto 0);-- 9 bit temporary value of dBV_Disp

signal iteration  	  : integer range 0 to 3; -- iteration counter
signal Stoptrack	     : std_logic ;-- tracking enable signal after N iteration.

signal clk_div         : unsigned(1 downto 0) :=(others=>'0'); -- counter for clk divider
signal CLKF            : std_logic ;-- fast update relay clock
signal CLK_REL         : std_logic ;-- relay clock

begin

----Test signals
--Vmesure <= Vmeas ;
--Verror  <= error;
--XdBVsetting <= dBVsetting ;
-- XDelta <= Delta;
--XdBVscaled <= dBVscaled;
--xrelay <= XREL;
-----------------

-- unsigned convertion of 8 bits setting counter
-- (must be limited to 200 in auto mode ?)
Vsett <= unsigned (MANUAL);

-- Fast 4Hz clock generation for fast relay update option
process (clk8Hz,clk_div)
begin
	if	rising_edge(clk8Hz) then
		clk_div<= clk_div +1 ;-- increment counter
		CLKF   <= not clk_div(0);-- 4Hz clock for fast update relay mode option
	end if;
end process;

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
process(clk8Hz,Vsett,ManuScaled,dBVscaled,mode,Mode2)
begin
    if rising_edge(clk8Hz) then
    -- add -180 LSB offset to counter value to get -180/+20 value to be displayed
    ManuScaled <= signed (('0' & Vsett) - 180) ; -- add 1 MSB to Vsett and shift to -180 for 0..200 lsb = -180..+20 lsb
       	if	mode2 = '1' then -- Display always dBV output in any mode
       	 dBV_Disp	<=	 dBV_dispA (7 downto 0); -- dBV Measurement display (+20 to -180 for +10dB to -90 dBV) / MSB removed.
   	        if 	  dBVscaled >= 0 then
      			 		  dBV_dispA <= std_logic_vector(dBVscaled) ; -- Positive dBV value
      			   	  Minus <= '0' ; -- "-" sign is off
      			else
      					  dBV_dispA <= std_logic_vector (1 + not(dBVscaled)) ; -- Negative dBV value
      					  Minus <= '1' ; -- "-" sign is on
      			end if;
      	else        -- Display Attenuator setting or dBV setting depending if Manual or Auto mode is active
      	   	if    Mode = '0' then -- Manual Mode is active
                  dBV_Disp	<=	 MANUAL; -- Manual attenuation control in 0.5dB step (0 to 255 for 0dB to -127.5 dB)
          	else   -- Manual Mode is active : display dBV setting ( not measurement)
            dBV_Disp	<=	 dBV_dispA (7 downto 0); -- dBV setting  display (+20 to -180 for +10dB to -90 dBV) / MSB removed
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

process(clkSAR,Mode,REL,XREL,error_sign,Manual,Vmeas,Vsett,clk8Hz,Stoptrack,CLK_REL,nFastMode,CLKF,ndBVCalib,Clk50mHz)
begin

-- Relays drived directly by counter, at clkSAR rate (500mHz) to avoid fast relay switching
-- if nFastMode is low, relay update rate is 4Hz for attenuator audio use with faster response.
case	nFastMode is
	when '0' => CLK_REL <= CLKF   ; -- Fast mode jumper not mounted
	when '1' => CLK_REL <= clkSAR ;
end case;

if	rising_edge(CLK_REL) then
	REL  <= MANUAL ; -- relay update 
end if;



-- Attenuator relays are driven by counter in Manual mode (0) and
-- by servo control loop in auto Mode (1).
-- When ndBVCalib is active (=0), relay are driven alternatively for 0/-80dB
-- attenuation at 50mHz rate.
if ndBVCalib='1' then --
   if Mode='0' then
      RELAYS <=  REL ; -- Attenuator relays are driven by counter only.
   else
      RELAYS <=  std_logic_vector(XREL) ;-- Attenuator Relays are drived by servo control 
   end if;
else -- Calibration is active  (for dBV only)
   if Clk50mHz='0' then
      RELAYS <= x"00"; -- 0dB value toggle at 50mHz rate for calibrating process
   else
      RELAYS <= x"A0"; -- -80dB/0dB value toggle at clk100mHz rate for calibrating
	end if;              -- hex value are double og attenuation: A0= 160 =(2x80)
end if;					



if  rising_edge(clkSAR) then
    -- compare actual with previous to detect change
    if	MANUAL=REL then
    	if	iteration <3 then
    	 	iteration <= iteration + 1 ; -- increment iteration counter
    	else
    		Stoptrack <= '1' ; -- stop tracking after last iteration
    	end if;
    else
    	iteration <= 0 ; -- reset iteration counter
    	Stoptrack <= '0' ; -- enable tracking
    end if;
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
if  falling_edge(clkSAR) and Stoptrack ='0' then --Synchronize to clkSAR (falling edge)
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
-- no error if error is less than +/- 1 LSB
if  falling_edge(clk8Hz) then
	if    Vmeas > (Vsett+1) then -- error is positive (output level is too high)
		   error_sign <= 0; -- sign of error
	      error <= (Vmeas - Vsett); -- always positive result
		   LEDerrorP <= '1' ; -- REd led when error is positive
		   LEDerrorN <= '0' ; -- Green led when error is negative
	elsif Vmeas < (Vsett) then -- error is negative (output level is too low)
		   error_sign <= 1; -- sign of error
		   error <= (Vsett - Vmeas);-- always positive result
		   LEDerrorP <= '0' ; -- REd led when error is positive
		   LEDerrorN <= '1' ; -- Green led when error is negative
	else
		   error_sign <= 2; --8 Hz blink when error is null.
		   error <= x"00" ;
		   LEDerrorP <= '0' ; -- REd led when error is positive
		   LEDerrorN <= '0' ; -- Green led when error is negative
	end if;
end if;

end process;

end architecture;
