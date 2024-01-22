--ON le 30/01/2017
-- Frequency divider 
-- 1 to pulse each 8 pulses
--Tested OK/
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Divideby_8to1 is
    Port (
        clk_in :in   STD_LOGIC;
        reset  :in   STD_LOGIC;
        clk_out:out  STD_LOGIC
    );
end Divideby_8to1;

architecture Behavioral of Divideby_8to1 is
    signal temporal: STD_LOGIC;
    signal counter : integer range 0  to 7  :=0 ;
begin
    frequency_divider: process (reset, clk_in) begin
        if  (reset ='1') then
            temporal <='0';
            counter <=0;
            counter <=0;
        elsif rising_edge(clk_in) then
            if  (counter =7) then
                temporal <= '1';
                counter <= 0;
			else           
               temporal <= '0';
               counter <= counter +1;
            end if;
        end if;
    end process;
        clk_out <= temporal;
end Behavioral;

