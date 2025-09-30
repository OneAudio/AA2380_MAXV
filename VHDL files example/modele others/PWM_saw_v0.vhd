--------------------------------------------------------------------------------
-- O.N - 20/05/19	***OSVA*** AA2380v1 	TEST
-- take  xx LE
-- 
-- Generate 2 complemenntary PWM output (180° phase shift) at 200 kHz
-- with triangle wave at 1000 Hz (200kHz/200).
-- The triangle amplitude change at the rate of CLK1Hz
-- from two values : 100% and 12.5% of PWM duty-cyle amplitude.
-- Triangle values are centered to mid duty-cyle (50%).
--------------------------------------------------------------------------------
library  IEEE;
use  IEEE.STD_LOGIC_1164.ALL;
use  ieee.numeric_std.all;

entity  PWM_saw_v0  is

port(
        CLK100M           :	in	std_logic   ;	-- 100MHz main clock 
		CLK1Hz			:	in	std_logic   ;	-- 1 Hz input (PWM excursion select)
		PWM				:	out	std_logic	;	-- PWM output
		nPWM			:	out	std_logic	;	-- PWM output (complementary)
		FPWM			:	out std_logic	;	-- PWM base frequency.
		Duty_test		: 	out integer range 0 to 127 --test 
		-- CLK200KTST		:	out std_logic	;			--test 
		-- CLK20MTST		:	out std_logic				--test 
        );
end  PWM_saw_v0;

ARCHITECTURE DESCRIPTION OF PWM_saw_v0 IS

signal clk_divider	: integer range 0 to 4 	:=0	; -- counter for clock divider
signal clk_divider2	: integer range 0 to 49 :=0 ; -- counter for clock divider
signal CLK20M    	: std_logic ;
signal CLK200K    	: std_logic ;

signal counter   	: integer range 0 to 99  := 0 ; -- PWM frequency divider
signal Duty      	: integer range 0 to 99	 := 0 ; -- Duty cycle value
signal count_saw    : integer range 0 to 199 := 0 ; -- saw values counter



BEGIN

Duty_test <= Duty; --test output only
-- CLK200KTST<=CLK200K;--test output only
-- CLK20MTST<=CLK20M;--test output only
--------------------------------------------------------------------------------
-- clock divider, generate 100kHz from 10MHz input clock.
--------------------------------------------------------------------------------
p_clk_divider: process(CLK100M,CLK20M,clk_divider,clk_divider2,CLK200K)
begin
    if  (rising_edge(CLK100M)) then
		-- Generate 20MHz clock from 100MHz 
        clk_divider   <= clk_divider + 1; -- increment counter
		if 		clk_divider < 3	then
				CLK20M	<='1' ;
		else
				CLK20M	<='0' ;	
		end if;
		if		clk_divider	= 4 then 
				clk_divider	<= 0 ;-- reset counter
		end if;
	end if;
	-- Generate 200kHz from 20MHz
	if  (rising_edge(CLK20M)) then
        clk_divider2   <= clk_divider2 + 1; -- increment counter
		if 	clk_divider2 = 49	then
			CLK200K	<= not CLK200K ; -- toggle each half period of 200k
			clk_divider2	<= 0 ;-- reset counter
		end if;
	end if;
end process p_clk_divider;

--------------------------------------------------------------------------------
-- For ~1kHz output wave, with 200 levels (100 up+100 down) whe need a 200kHz PWM
-- to have one PWM cycle for each PWM values.
--
-- Ramp amplitude change each 500ms from 12.5% to 100% duty cycle
--------------------------------------------------------------------------------
process(CLK200K,count_saw,Duty,CLK1Hz)
begin
    if    rising_edge(CLK200K) then
        count_saw <= count_saw +1 ; -- increment counter.
		if 	count_saw = 199	then
			count_saw<= 0; -- reset counter to coun t from 0 to 99.
		end if;
		-- CLK1Hz is high => 100% triangle duty-cyle PWM
		if 	CLK1Hz='1'	then	
			if   count_saw < 100 then-- ramp up
					Duty <= count_saw ;
			else
					Duty <= 100 - (count_saw - 99)  ;-- ramp down
			end if;
		-- CLK1Hz is low => 12.5% triangle duty-cyle PWM
		else				
			if  	count_saw < 100 then -- ramp up
					Duty <= (50 - 100/8) + (count_saw/4) ;
			else
					Duty <= (50 - 100/8) + (100 - (count_saw - 99))/4 ; -- ramp down
			end if;
		end if;
	end if;
end process;

--------------------------------------------------------------------------------
-- Generate PWM from duty cycle values.
-- There is 100 possible PWM values(up and down are same), so PWM counter
-- must be clocked by 100x 200kHZ => 20MHz.
--------------------------------------------------------------------------------
process(CLK20M,counter,Duty)
begin
  if    rising_edge(CLK20M) then
        -- Base PWN frequency generator.
        counter <= counter + 1  ; -- increment counter
		if 	counter = 99	then
			counter	<= 0; -- reset counter to count from 0 to 99.
		end if;
		--
        if    counter>49  then
              FPWM <= '0' ;
        else
              FPWM <= '1' ;
        end if;
        --
        -- PWM output generator from duty cycle input.
        if    counter >= Duty then -- compare counter value to duty input.
              PWM <= '0' ;
              nPWM <= '1';
        else
              PWM <= '1' ;
              nPWM <= '0';
        end if;
  end if;
  

end process;
END DESCRIPTION;
