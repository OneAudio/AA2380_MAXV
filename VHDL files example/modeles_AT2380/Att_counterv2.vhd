-----------------------------------------------------------------
-- O.N - 28/08/2017
-- Rotary encoder and push button control
-- 8 bits outputs to drive attenuator relays
-- 2 bits for step value indicator
-- Auto/manu signal indicator.
-- Generate also 1s pulse for info display when nex command is set
-- take 124 LE
-- + Add counter limit to 200 in Auto mode.
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
 
 entity Att_counterv2 is
    Port ( 
          Clk       : in  std_logic; -- 20MHz clock
          ClkS      : in  std_logic; -- 2kHz clock
			    Clk2Hz	  : in  std_logic; -- 2Hz clock
          Ta		: in  std_logic; -- coder track A
          Tb    	: in  std_logic; -- coder track B
          Push      : in  std_logic; -- coder push button
          ATT  		: out std_logic_vector(7 downto 0); -- Attenuator Relay drive outputs
          dBstep	: buffer std_logic_vector (2 downto 0) ;-- dB step current value
          Mode		: buffer std_logic ;-- Auto/manual mode indicator        
          ModeP     : out std_logic ; -- pusle output when new Mode selected
          StepP   	: out std_logic ; -- pusle output when new dBstep selected
          OptionOK 	: in std_logic -- signal to validate auto mode option
    );
 end Att_counterv2;
 
architecture Attenuator of Att_counterv2 is

signal rotary_in        : STD_LOGIC_vector (1 downto 0)  ; -- Vector of the two encoder tracks
signal delay_rotary_q1  : STD_LOGIC  ; --
signal DIR				: STD_LOGIC  ; --
signal Rotate			: STD_LOGIC  ; --
signal count1s			: integer range 0 to 2047 :=0  ; --
signal cnstep           : integer range 0 to 5  ; -- steps values counter
signal stepVAL          : integer range 0 to 64 ; -- 
signal countmax         : integer range 0 to 256 ; -- counter8 maximum value 
signal counter8         : integer range 1 to 256 :=1 ; --
signal Pu               : std_logic;-- Filtered and inverter push button
signal Previous_Mode : std_logic;-- 
signal Previous_dBstep : std_logic_vector (2 downto 0);-- 
signal DispTime         : integer range 0 to 2047  :=0 ; -- info display time counter
signal Disp           : std_logic ;
signal Mmode          : std_logic ;
signal Mstep           : std_logic ;

begin 

ATT <= std_logic_vector(to_unsigned(counter8, 8)) ; -- integer to logic_vector convertion.
dBstep	<= std_logic_vector(to_unsigned(cnstep, 3)) ; -- integer to logic_vector convertion.

----------------------------------------------------------
-- Filtering of push button and 1s push detect for manu/auto
-- mode selection . Signal sampled with clkS
---------------------------------------------------------
process (clkS)
begin 
    if rising_edge(clkS) then
    Pu <= not Push;   
    end if;
end process;

process (clkS,Pu,OptionOK)
begin 
	if Pu = '1' and OptionOK ='1' then -- enable long push detection only if optionOK is valid.
		if rising_edge(clkS) then
			if  count1s = 100 then --2000 then
				Mode 	<= not Mode ; -- signal is inverted after 1s push
				count1s <= 0 ;-- clear counter
			else 
				count1s <= count1s +1 ;-- increment counter
			end if; 
		end if;
	else
		count1s <= 0; -- reset counter when push button is not pressed
end if;
	
end process;
----------------------------------------------------------
-- Generate a pulse to display shortly the new command
-- set to 7segments diplay (dB step and auto/manu mode )
---------------------------------------------------------
process (ClkS,Clk2Hz,Mode,dBstep,Previous_Mode,Previous_dBstep,Disptime,MMode,Mstep)
begin
    if  rising_edge (ClkS) then
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
-- dB step selection by push button
----------------------------------------------------------
Sel_dBstep : process (Pu,cnstep)
begin
  if rising_edge(Pu) then
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
-- Relay counter increment/decrement by xdB
-- Counter value is limited to 200 when auto mode is active,
-- otherwire 256 in Manual mode.
----------------------------------------------------------

Attenuator_counter : process(Rotate,counter8,stepVAL,Mode,countmax)
begin
case Mode is
  when '0' => countmax <= 256 ;
  when '1' => countmax <= 200 ;
end case;
  if rising_edge(Rotate) then
   	if  Mode='1' and counter8 > 200 then
   	    counter8 <= 200 ;
   	else
      if    DIR='1' and counter8 < (countmax - stepVAL) then
		        counter8 <= counter8 + stepVAL ;--
	    elsif DIR='0' and counter8 >= stepVAL then
	          counter8 <= counter8 - stepVAL ;--
	    end if;
	  end if;
	end if;
end process;

end architecture;
