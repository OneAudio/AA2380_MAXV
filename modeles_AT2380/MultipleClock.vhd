--------------------------------------------
-- ON 09/2017
-- Multiple clock generator from 2MHz input
--------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MultipleClock is

  Port (
        clk2MHz   :in   STD_LOGIC;  -- input clock
        CLK2kHz   :out  STD_LOGIC;  -- 2 kHz output clock 
        CLK500mHz :out  STD_LOGIC;  -- 0.5 Hz output clock
		  CLK8Hz    :out  STD_LOGIC;  -- 8 Hz output clock
		  CLK100mHz :out  STD_LOGIC   -- 0.1 Hz output clock 
    );
end MultipleClock;

architecture Behavioral of MultipleClock is

signal counter1   : integer range 0  to 499 :=0 ; -- counter 1
signal counter2   : integer range 0  to 124 :=0 ; -- counter 2
signal counter3   : integer range 0 to 7 := 0;-- counter 3
signal counter4   : integer range 0 to 39 := 0;-- counter 4
signal temporal1  : std_logic := '0' ;
signal temporal2  : std_logic := '0' ;
signal temporal3  : std_logic := '0' ;
signal temporal4  : std_logic := '0' ;
	 
    
begin

frequency_divider: process (clk2MHz,temporal1,temporal2,temporal3,temporal4)
begin
   if rising_edge(clk2MHz) then -- Generate 2kHz clock from 2MHz
        if  (counter1 = 499 ) then
            temporal1 <= NOT(temporal1);
            counter1 <=0;
        else
            counter1 <= counter1 +1;
        end if;
    end if;
     if rising_edge(temporal1) then -- Generate 8 Hz clock from 2kHz
        if  (counter2 = 124 ) then
            temporal2 <= NOT(temporal2);
            counter2 <=0;
        else
            counter2 <= counter2 +1;
        end if;
    end if;
    if rising_edge(temporal2) then -- Generate 0.5 Hz  clock from 8 Hz
        if  (counter3 = 7 ) then
            temporal3 <= NOT(temporal3);
            counter3 <=0;
        else
            counter3 <= counter3 +1;
        end if;
    end if;
    if rising_edge(temporal2) then -- Generate 0.1 Hz clock from  8 Hz
        if  (counter4 = 39 ) then
            temporal4 <= NOT(temporal4);
            counter4 <=0;
        else
            counter4 <= counter4 +1;
        end if;
    end if;
end process;
CLK2kHz	  <= temporal1; -- send to output
CLK8Hz  	<= temporal2; -- send to output
CLK500mHz  	<= temporal3; -- send to output
CLK100mHz <= temporal4; -- send to output

end Behavioral;

