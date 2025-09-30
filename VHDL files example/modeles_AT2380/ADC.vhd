-------------------------------------------------------------------------------
--  ON le 12/10/2017     -- take xxx LE
-- MCP3202 ADC control block - UNTESTED !!!
-- Dual channel 12 bits  ADC with SPI
--
--
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ADC is
port (  clk : in std_logic; -- input clock
        cs : out std_logic; -- ADC chip select
        sck : out std_logic; -- ADC channel selection
        do : out std_logic; -- ADC data output
        din : in std_logic; -- ADC input data (config)
        led : out std_logic_vector(11 downto 0)); -- ADC value output data

end ADC;

architecture Behavioral of ADC is

type state is (spi,conversion); -- states of  machine 
signal presentstate : state := spi;

begin

process(clk)
variable i : integer range 0 to 8  := 0;
variable j : integer range 0 to 18 := 0;
variable tot : std_logic_vector(11 downto 0) := "000000000000";

begin   
if clk'event and clk = '1' then
    if presentstate = spi then
        if    i <= 3 then ---"0000000110010" then
              i := i + 1;
              sck <= '1';
        elsif i > 3 and i < 7  then ---"0000000110010" and i < "0000001100100" then
              i := i + 1;
              sck <= '0';
        elsif i = 7 then ---"0000001100100" then
              i := 0; ----"0000000000000";
            if  j < 18 then
                j := j + 1;
            elsif j = 18 then
              presentstate <= conversion;
                j := 0;
            end if;
        end if;
        if  j = 0 or j >= 18 then
            cs <= '1';
        else
            cs <= '0';
        end if;
        if i > 2 and i < 6 then --- "0000000101000" and i < "0000000111100" then
            case j is
                  when 0 =>  do <= '0';                    
                  when 1 =>  do <= '0';                 
                  when 2 =>  do <= '1';                
                  when 3 =>  do <= '0'; -----channel bit
                  when 4 =>  do <= '1';
                  when others =>  null;
            end case;
        end if;
        if i >= 2 and i < 6 then --"0000000000000" and i < "0000000001010" then
            case j is
                  when 6  => tot(11) := din;
                  when 7  => tot(10) := din;
                  when 8  => tot(9)  := din;
                  when 9  => tot(8)  := din;
                  when 10 => tot(7)  := din;
                  when 11 => tot(6)  := din;
                  when 12 => tot(5)  := din;
                  when 13 => tot(4)  := din;
                  when 14 => tot(3)  := din;
                  when 15 => tot(2)  := din;
                  when 16 => tot(1)  := din;
                  when 17 => tot(0)  := din;
                  when others => null;
            end case;
        end if;
    end if;
    if    presentstate = conversion then
          cs <= '1';
          led <= tot;
        if    i < 7 then --"1001110001000" then
              i := i + 1;
        elsif i = 7 then --"1001110001000" then
              i := 0; ---"0000000000000";
              presentstate <= spi;
        end if;
    end if;
end if;

end process;
end Behavioral;

