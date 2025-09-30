--------------------------------------------------------------------------------
-- PROJECT: SIMPLE UART Transmitter FOR FPGA
-- TAKE 16 LE 
-- Designed the 21/01/2018 by ON
-- 
--------------------------------------------------------------------------------
-- MODULE:  UART TARANSMITTER
-- Read uart data with :
-- 1 start bit(0) + 8 data bits + 1 stop bit(1).
-- CLK input is equal to baud rate (9600 bauds=9600Hz CLK)
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Mini_uartTX is

    Port (
        CLK         : in  std_logic; -- system clock
        UART_TXD    : out std_logic :='0'; -- UART TX serial output data
        DATA_IN     : in  std_logic_vector(7 downto 0); -- parrallel data input
        Send	    : in  std_logic -- data is send on TX at each rising edge of "send" 
    );
end Mini_uartTX;

architecture behavorial of Mini_uartTX is

signal Start          : std_logic :='0' ; -- start RX data reading bit
signal StopBit        : std_logic :='0' ; -- stop RX data reading bit
signal count          : integer range 0 to 15 :=0 ; -- counter for RX sampling at 2X baud rate 

begin


process(stopbit,send)
begin
  if    stopbit='1' then
        Start <= '0' ; -- stop reading
  elsif rising_edge(send) then
        Start <= '1' ; -- start reading
  
  end if;
end process;

--- The 10 bits from RX are read at sampled time
process(CLK,Start,StopBit,count,DATA_IN)
begin
  if  falling_edge(CLK) then
      if  Start='1' then
          count <= count+1 ; -- increment counter
           if     count= 0 then
                  UART_TXD <= '0';	  -- Start bit =0
           elsif  count= 1 then
                  UART_TXD <= DATA_IN(0); -- bit 0 (LSB)
           elsif  count= 2 then                                       
                  UART_TXD <= DATA_IN(1); -- bit 1
           elsif  count= 3 then                                       
                  UART_TXD <= DATA_IN(2); -- bit 2
           elsif  count= 4 then                                       
                  UART_TXD <= DATA_IN(3); -- bit 3
           elsif  count= 5 then                                       
                  UART_TXD <= DATA_IN(4); -- bit 4
           elsif  count= 6 then                                       
                  UART_TXD <= DATA_IN(5); -- bit 5
           elsif  count= 7 then                                       
                  UART_TXD <= DATA_IN(6); -- bit 6
           elsif  count= 8 then                                       
                  UART_TXD <= DATA_IN(7); -- bit 7 (MSB)              
           elsif  count= 9 then
                  UART_TXD <= '1' ; -- stop bit =1
                  stopbit <= '1' ; -- stop reading
           end if;
      else
        count    <=  0  ; -- reset counter
        stopbit  <= '0' ; -- reset stopbit
        UART_TXD <= '1' ;
      end if;
  end if;
end process;

end behavorial;
