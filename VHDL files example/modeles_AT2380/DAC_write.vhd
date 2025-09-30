-----------------------------------------------------------------
-- ON
-- MCP4802 dual channel DAC SPI control
-- Send 8 bits input data to both DAC channel
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
 
entity DAC_write is
    port(
        CLK: in std_logic; -- input clock for SPI
        DATA: in std_logic_vector (7 downto 0); -- 8 bits data to send on DACs
        SCK: out std_logic; -- SPI SCK output clock
        CS: out std_logic; --SPI /CS output signal
        MOSI: out std_logic -- SPI SDATA output signal
    );
end DAC_write;
 
architecture behavioral of DAC_write is

signal SEND: std_logic:='1';
signal VALUE: std_logic_vector (11 downto 0);
signal SENDING : std_logic := '0';
signal reg : std_logic_vector (15 downto 0);
SIGNAL  DACAB:std_logic := '1'; -- 0:DAC A, 1:DAC B
constant BUFFERED:std_logic := '0'; -- don't care
constant GAIN:std_logic := '0'; -- 0:Gain 2X, 1: Gain 1X
constant ACTIVE:std_logic := '1'; -- 0:shutdown, 1:active
     
begin
              
    process(CLK, SEND)
     
    variable counter : integer range 0 to 15 := 0; 
     
    begin
     
    if falling_edge(CLK) then
    VALUE <= DATA & x"0" ; -- 8 to 12 bits conversion
        if SEND = '1' then 
        reg <= DACAB & BUFFERED & GAIN & ACTIVE & VALUE(11 downto 0); -- add control bit
        counter := 0;
        CS <= '0';
        SENDING <= '1';
        SEND <= '0';
        DACAB <= not DACAB; -- change DAC channel alternativly
                 
        elsif SENDING = '1' then               
        reg <= reg(14 downto 0) & '0';
                     
            if counter = 15 then       
            counter := 0;  
            CS <= '1';
            SENDING <= '0';
            SEND <= '1';
            else
            counter := counter + 1;
            end if;
        end if;        
    end if;
         
    end process;
     
SCK <= CLK AND SENDING;
MOSI <= reg(15);
     
end behavioral;
