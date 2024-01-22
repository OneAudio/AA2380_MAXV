----------------------------
--ON le 25/04/2017
-- Ready signal after 3s
--
-----------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Ready_3s is
    Port (
        clk_in :in   STD_LOGIC;	-- input clock
        READY  :out   STD_LOGIC -- Ready output signal
        );
end Ready_3s;

architecture Behavioral of Ready_3s is
    signal counter : integer range 0  to 150000000  :=0 ; -- max count for 3s delay at 50MHz clock
begin
    process (clk_in) begin
        if rising_edge(clk_in) then
            if  (counter =150000000) then
                Ready   <= '1' ;-- Ready signal active
                counter <= counter ; -- stop counter
            else
				counter <= counter +1; -- increment counter
				Ready <= '0'; -- Ready not active
            end if;
        end if;
    end process;
end Behavioral;
