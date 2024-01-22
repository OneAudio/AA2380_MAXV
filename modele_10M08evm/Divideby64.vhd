--ON le 17/01/2017
-- Frequency divider /64
--
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Divideby64 is
    Port (
        clk_in :in   STD_LOGIC;
        reset  :in   STD_LOGIC;
        clk_out:out  STD_LOGIC
    );
end Divideby64;

architecture Behavioral of Divideby64 is
    signal temporal: STD_LOGIC;
    signal counter : integer range 0  to 31  :=0 ;
begin
    frequency_divider: process (reset, clk_in) begin
        if  (reset ='1') then
            temporal <='0';
            counter <=0;
        elsif rising_edge(clk_in) then
            if  (counter =31) then
                temporal <= NOT(temporal);
                counter <=0;
            else
                counter <= counter +1;
            end if;
        end if;
    end process;
        clk_out <= temporal;
end Behavioral;

