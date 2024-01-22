--------------------------------------------------------------------------------
-- PROJECT: SIMPLE UART FOR FPGA
-- TAKE ONLY 19 LE !
-- Designed the 16/01/2018 by ON
-- 
--------------------------------------------------------------------------------
-- MODULE:  UART RECEIVER
-- Read uart data with :
-- 1 start bit + 8 data bits + 1 stop bit.
-- for 9600 bauds, clk must be 3 x baud rate = 28800 Hz
-- output data value must be sampled when data_vld=1 (end of frame)
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Mini_uartRX is

    Port (
        CLK         : in  std_logic; -- system clock = 3 x Baud rate
        UART_RXD    : in  std_logic; -- UART RX serial input data
        DATA_OUT    : buffer std_logic_vector(7 downto 0);
        DATA_VLD    : out std_logic -- when DATA_VLD = 1, data on DATA_OUT are valid
    );
end Mini_uartRX;

architecture behavorial of Mini_uartRX is

signal Start          : std_logic :='0' ; -- start RX data reading bit
signal StopBit        : std_logic :='0' ; -- stop RX data reading bit
signal count          : integer range 0 to 31 :=0 ; -- counter for RX sampling at 2X baud rate 

begin

DATA_VLD <= stopbit; -- use stopbit as data valid signal indicator

process(UART_RXD,stopbit)
begin
  if    stopbit='1' then
        Start <= '0' ; -- stop reading
  elsif falling_edge(UART_RXD) then
        Start <= '1' ; -- start reading
  
  end if;
end process;

--- The 10 bits from RX are read at sampled time
process(CLK,Start,StopBit,count,UART_RXD,DATA_OUT)
begin
  if  falling_edge(CLK) then
      if  Start='1' then
          count <= count+1 ; -- increment counter
           if     count=4 then
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 0 (LSB)
           elsif  count=7 then                                       
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 1
           elsif  count=10 then                                       
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 2
           elsif  count=13 then                                       
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 3
           elsif  count=16 then                                       
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 4
           elsif  count=19 then                                       
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 5
           elsif  count=22 then                                       
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 6
           elsif  count=25 then                                       
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 7 (MSB)              
           elsif  count=28 then
                  stopbit <= '1' ; -- stop reading
           end if;
      else
        count    <=  0  ; -- reset counter
        stopbit  <= '0' ; -- reset stopbit
      end if;
  end if;
end process;

end behavorial;
