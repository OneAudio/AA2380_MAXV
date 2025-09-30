-----------------------------------------------------------------
--  O.N - 21/01/18
-- take 143 LE
-- Rotary encoder and push button control
-- 8 bits outputs to drive attenuator relays
-- 2 bits for step value indicator
-- Auto/manu signal indicator.
-- Generate also 1s pulse for info display when new command is set
-- Counter limit to 200 in Auto mode.
-- Add 2s push output for dBV display option (any modes)
-- 1s and long push is disable if nOPTION_TRK is high (no tracking available)
--
-- Change counter limit for -85dBV min in auto mode.
--
-- Version F : Adding uart data input support to load counter
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

 entity Att_counterv4F is
    Port (
          Clk       : in  std_logic; -- 20MHz clock
          Clk2kHz      : in  std_logic; -- 2kHz clock
	        Ta		 : in  std_logic; -- coder track A
          Tb    	: in  std_logic; -- coder track B
          Push      : in  std_logic; -- coder push button
          ATT  		: out std_logic_vector(7 downto 0); -- Attenuator Relay drive outputs
          dBstep	: buffer std_logic_vector (2 downto 0) ;-- dB step current value
          Mode		: buffer std_logic ;-- Auto/manual mode indicator
          ModeP     : buffer std_logic ; -- pusle output when new Mode selected
          StepP   	: out std_logic ; -- pusle output when new dBstep selected
          nOPTION_TRK 	: in std_logic ;-- signal to validate auto mode option (active low with internal pull-up)
          Mode2    : buffer std_logic ; -- long push function
          DATA_uart: in integer range 0 to 255; -- data bus from uart
          uart_valid: in std_logic -- new data coming from uart
    );
 end Att_counterv4F;

architecture Attenuator of Att_counterv4F is

signal rotary_in        : STD_LOGIC_vector (1 downto 0)  ; -- Vector of the two encoder tracks
signal delay_rotary_q1  : STD_LOGIC  ; --
signal DIR				: STD_LOGIC  ; --
signal Rotate			: STD_LOGIC  ; --
signal count1s			: integer range 0 to 8191 :=0  ; -- counter for long push detection
signal cnstep           : integer range 0 to 5  ; -- steps values counter
signal stepVAL          : integer range 0 to 64 ; --
signal countmax         : integer range 0 to 255; -- counter8 maximum value
signal countmin         : integer range 0 to 15 ; -- counter8 minimum value
signal counter8         : integer range 1 to 256 :=1 ; --
signal Pu               : std_logic;-- Filtered and inverter push button
signal Previous_Mode : std_logic;--
signal Previous_dBstep : std_logic_vector (2 downto 0);--
signal DispTime         : integer range 0 to 2047  :=0 ; -- info display time counter
signal Disp           : std_logic ;
signal Mmode    	: std_logic ;
signal Mstep 	        : std_logic ;
signal xMode		: std_logic :='0'; 
signal xMode2		: std_logic :='0';


begin


ATT <= std_logic_vector(to_unsigned(counter8, 8)) ; -- integer to logic_vector convertion.
dBstep	<= std_logic_vector(to_unsigned(cnstep, 3)) ; -- integer to logic_vector convertion.

----------------------------------------------------------
-- Filtering of push button and 1s and 5s push detect for
-- manu/auto mode selection and dBV mode display
-- The signal is sampled with Clk2kHz
---------------------------------------------------------
process (Clk2kHz)
begin
    -- sampling and inverting push button signal for glitch filtering
    if rising_edge(Clk2kHz) then
    Pu <= not Push;-- invert push button for positive pulse logic
    end if;
end process;

process (Clk2kHz,Pu,nOPTION_TRK,xmode,xmode2)
begin
-- Detection of 1s and 4s push for Mode and Mode2 function control
	if rising_edge(Clk2kHz) then
	   if Pu = '1' then
	   	   if 	 count1s < 8191 then -- 4.2 s counter with 2kHz clock
	   	         count1s <= count1s +1 ;-- increment counter when push is active
	   	   else
	   	         count1s <= count1s ;-- counter stop
	   	   end if;
   	 else
          count1s <= 0 ;-- reset counter when push button is released
	   end if;
	   if   count1s = 6000 then -- normal value is 4000 ( time > 2s ) -- Mode2 available only if 
   	      xMode2	<= not xMode2 ; -- signal is inverted after 4s push
	   end if;
	end if;

	if  falling_edge(Pu)  then -- check counter value when releasing push button
	    if  count1s > 2000 and count1s < 4000 then -- Mode is disable when option not installed (normal values are 2000/8000)
        	xMode 	<= not xMode ; -- signal is inverted after push between 1 to 2s
      end if;
  end if;

Mode	<= xMode  and not (nOPTION_TRK); -- send xMode to mode if track option is installed
Mode2	<= xMode2 and not (nOPTION_TRK); -- send xMode2 to mode2 if track option is installed

end process;

----------------------------------------------------------
-- dB step selection by push button
-- dB step is not incremented when push for more than 1s
----------------------------------------------------------
Sel_dBstep : process (Pu,cnstep,count1s)
begin
  if falling_edge(Pu)  and count1s <= 2000 then
      if 	cnstep < 4 then
    		cnstep <= cnstep +1 ;
    	else
    		cnstep <= 0 ; -- reset (back to 0)
    	end if;
  end if;

case cnstep is				      --
		when 0 => stepVAL <= 1 	; -- 0.5 DB step
		when 1 => stepVAL <= 2  ; -- 1 dB step
		when 2 => stepVAL <= 6  ; -- 3 dB step
		when 3 => stepVAL <= 12 ; -- 6 dB step
		when 4 => stepVAL <= 20 ; -- 10 dB step
		when others => stepVAL <= 1 ;
end case;
end process Sel_dBstep ;

----------------------------------------------------------
-- Generate a pulse to display shortly the new command
-- set to 7segments diplay (dB step and auto/manu mode )
---------------------------------------------------------
process (Clk2kHz,Mode,dBstep,Previous_Mode,Previous_dBstep,Disptime,MMode,Mstep)
begin
    if  rising_edge (Clk2kHz) then
        Previous_Mode <= Mode ; -- store Mode value
        Previous_dBstep <= dBstep; -- store dBstep value
          if      Mode /= Previous_Mode  then  -- hold value different from new value
                  MMode <= '1' ; -- new mode value detected
          elsif   dBstep /= Previous_dBstep  then -- hold value different from new value
                  Mstep <= '1' ; --new step value detected
          end if;
          if (MMode='1' or Mstep='1') then
              if  Disptime < 1000 then --start counter
                  DispTime <= DispTime +1 ; -- increment counter
                  Disp <= '1' ; -- run display info signal
              else
                  DispTime <= 0 ; -- reset counter
                  Disp <= '0' ; -- reset disp signal
                  MMode <= '0' ; -- reset MMode signal after pulse
                  Mstep <= '0' ; -- reset Mstep signal after pulse
              end if;
          end if;
        ModeP <= Disp and MMode; -- pulse when new mode selected
        StepP <= Disp and Mstep; -- pulse when new step selected
    end if;
end process;

----------------------------------------------------------
-- New rotary encoder function from Xilinx app note
-- (Works fine !)
----------------------------------------------------------
rotary_filter: process(clk)
begin
  if clk'event and clk='1' then
      rotary_in <= Ta & Tb;
  case rotary_in is
    when "00" =>  Rotate <= '0';
                  Dir <= Dir;
    when "01" =>  Rotate <= Rotate;
                  Dir <= '0';
    when "10" =>  Rotate <= Rotate;
                  Dir <= '1';
    when "11" =>  Rotate <= '1';
                  Dir <= Dir;
    when others => Rotate <= Rotate;
                  Dir <= Dir;
  end case;
end if;
end process rotary_filter;


----------------------------------------------------------
-- Relay counter increment/decrement by xdB
-- Counter value is limited to 191 (-85dBV min) when auto mode is active,
-- otherwire 256 in Manual mode.
--
-- In Manual mode (Mode=0), the attenuator counter can be loaded
-- by uart data (uart_valid=1)
----------------------------------------------------------

Attenuator_counter : process(Rotate,counter8,stepVAL,Mode,countmax,ModeP,uart_valid,DATA_uart)
begin
case Mode is
  when '0' 	=> countmax <= 255 ;-- Manu mode max count
				   countmin <= 0   ;-- Manu mode min count
  when '1' 	=> countmax <= 201 ;-- Auto mode max count for +10dBV
				   countmin <= 10  ;-- Auto mode min count for -85dBV
end case;
if    ModeP='1' and Mode='1' and counter8 > 201 then --avoid value greater than +10dBV
      counter8 <= 201 ; -- set to +10dBV
elsif ModeP='1' and Mode='1' and counter8 < 10 then -- avoid value lower than -85dBV
      counter8 <= 10 ; -- set to -85dBV
elsif rising_edge(Rotate) then
   if       DIR='1' and counter8 < (countmax - stepVAL) then
            counter8 <= counter8 + stepVAL ;--
   elsif    DIR='0' and counter8 >= (countmin + stepVAL) then
            counter8 <= counter8 - stepVAL ;--
   end if;     
end if;

--- counter8 is loaded with uart value if uart_valid=1 and mode is manual.
if    uart_valid='1' and Mode='0' then -- uart control only in Manual mode.
      counter8 <= DATA_uart ; -- loading counter with uart new value
end if;

end process;



end architecture;
