------------------------------------
--  ON 05/2017
-- Divide by N Frequency divider 
------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Divideby_byN is
generic(N : integer :=8 ); -- scale factor from input frequency
                           -- N must be an odd integer of clk_in !!
  Port (
        clk_in :in   STD_LOGIC; -- input clock
        CLK2M :out  STD_LOGIC   -- output clock = clk_in / N
    );
end Divideby_byN;

architecture Behavioral of Divideby_byN is

    signal temporal: STD_LOGIC;
    signal count_range : integer :=N/2 ; -- counter max value
    signal counter : integer range 0  to count_range-1 :=0 ; --  
    
begin
    frequency_divider: process (clk_in) begin
       if rising_edge(clk_in) then
            if  (counter = count_range-1) then
                temporal <= NOT(temporal);
                counter <=0;
            else
                counter <= counter +1;
            end if;
        end if;
    end process;
        CLK2M <= temporal;
end Behavioral;

