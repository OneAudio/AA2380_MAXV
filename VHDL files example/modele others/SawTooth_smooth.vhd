--------------------------------------------------------------------------------
-- O.N - 14/05/19	***OSVA*** AA2380v1 	TEST
-- take xx LE
-- 
--
--
--
--------------------------------------------------------------------------------
library  IEEE;
use  IEEE.STD_LOGIC_1164.ALL;
use  ieee.numeric_std.all;

entity  PWM_saw_v0  is
-- generic(zero: integer  := 64 ) ; -- counting offset (minimum PWM value)

port(
        CLK1M           :	in	std_logic   ;	-- 1MHz clock 
		CLK1Hz			:	in	std_logic   ;	-- 1 Hz input
		PWM				:	out	std_logic	;	-- PWM output
		nPWM			:	out	std_logic		-- PWM output (complementary)		
        );
end  PWM_saw_v0;

ARCHITECTURE DESCRIPTION OF PWM_saw_v0 IS

signal counter   : integer range 0 to 127  := 0 ; -- PWM frequency divider
signal Duty      : integer range 0 to 127  := 0 ; --

signal clk_divider	: unsigned(10 downto 0)  :=(others=>'0'); -- counter for clock divider
signal count_saw    : integer range 0 to 255 :=0 ; -- saw values counter
signal countout     : integer range 0 to 127 :=0 ;
signal offset	    : integer range 0 to 64	 :=0 ;
signal CLK_250K    	: std_logic ;


signal counter   	: integer range 0 to 127  := 0 ; -- PWM frequency divider
	


BEGIN


--------------------------------------------------------------------------------
-- clock divider to get 128x LED blinking rate clock
--------------------------------------------------------------------------------
p_clk_divider: process(CLK1M)
begin
    if  (rising_edge(CLK1M)) then
        clk_divider   <= clk_divider + 1; -- increment counter
        CLK_250K	  <= not clk_divider(1) ; -- div 4 = 250 kHz
    end if;
end process p_clk_divider;

--------------------------------------------------------------------------------
-- Generate PWM ramp with 128 level (64 up + 64 down) from CLK_128Hz
--------------------------------------------------------------------------------
process(CLK_128Hz,count_saw,Duty,ENAB)
begin
    if    rising_edge(CLK_128Hz) then
          count_saw <= count_saw +1 ; -- increment counter.
		if ENAB='1'	then	--	 0-100% duty-cyle triangle amplitude 
			if   count_saw < 128 then-- ramp up
					Duty <= count_saw ;
			else
					Duty <= 128 - (count_saw - 127)  ;-- ramp down
			end if;
		else				-- 0-12.5 % duty-cyle triangle amplitude
			if  	count_saw < 128 then -- ramp up
					Duty <= (count_saw/8) ;
			else
					Duty <= (128 - (count_saw - 127))/8 ; -- ramp down
			end if;
		end if;
	end if;
end process;



BEGIN
--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
process(CLOCK_PWM,counter,Duty,DTY_CYCLE,PWM)
begin
  if    rising_edge(CLOCK_PWM) then
        -- base PWN frequency generator.
        counter <= counter + 1  ; -- increment counter
        if    counter>63  then
              FPWM <= '0' ;
        else
              FPWM <= '1' ;
        end if;
        --
        -- PWM output generator from duty cycle input.
        if    counter >= Duty then -- compare counter value to duty input.
              PWM <= '0' ;
        else
              PWM <= '1' ;
        end if;
  end if;
  
nPWM <= not PWM; -- inverted output.

end process;





































END DESCRIPTION;
