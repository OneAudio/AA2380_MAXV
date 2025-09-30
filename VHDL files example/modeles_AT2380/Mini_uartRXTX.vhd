--------------------------------------------------------------------------------
-- PROJECT: SIMPLE UART FOR FPGA
-- TAKE 38 LE
-- Designed the 28/01/2018 by ON
--------------------------------------------------------------------------------
-- MODULE:  UART RECEIVER & TRANSMITER
-- 
-- 1 start bit + 8 data bits + 1 stop bit.(no parity nor stop bit)
-- CLK must be 3 x baud rate.
-- output data value must be sampled when data_vld=1 (end of frame).
--
-- TX frame is sent when at end of received frame and if enable input is low
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Mini_uartRXTX is

    Port (
        CLK         : in  std_logic; -- system clock = 3 x Baud rate
		  nUART_EN	  : in  std_logic; -- Uart enable inpu (active low)
        UART_RXD    : in  std_logic; -- UART RX serial input data
        UART_TXD    : out std_logic :='0'; -- UART TX serial output data
        DATA_IN     : in  std_logic_vector(7 downto 0); -- parrallel data input
        DATA_OUT    : buffer std_logic_vector(7 downto 0); -- parrallel data output
        DATA_VLD    : out std_logic  -- when DATA_VLD = 1, data on DATA_OUT are valid
--        XStopTX     : out std_logic ;
--        XStopRX     : out std_logic 
    );
end Mini_uartRXTX;

architecture behavorial of Mini_uartRXTX is
----- RX signals
signal StartRX       : std_logic :='0' ; -- start RX data reading bit
signal StopRX        : std_logic :='0' ; -- stop RX data reading bit
signal countA        : integer range 0 to 31 :=0 ; -- counter for RX sampling at 2X baud rate
-------TX signals
signal StartTX       : std_logic :='0' ;
signal StopTX        : std_logic :='0' ; -- stop TX data reading bit
signal countB        : integer range 0 to 15 :=0 ; -- counter for RX sampling at 2X baud rate
signal cntdiv3       : integer range 0 to 3 :=0 ; -- divide by counter
signal CLKdiv3       : std_logic :='0' ; -- divided by 3 CLK.
--------

begin
--------------------------------------------------------------------------------
-- RX module
--------------------------------------------------------------------------------
DATA_VLD <= StopRX; -- use stopbit as data valid signal indicator

process(UART_RXD,StopRX,nUART_EN)
begin
  if    StopRX='1' then
        StartRX <= '0' ; -- stop reading
  elsif falling_edge(UART_RXD) and nUART_EN='0' then
        StartRX <= '1' ; -- start reading
  
  end if;
end process;

--- The 10 bits from RX are read at sampled time
process(CLK,StartRX,StopRX,countA,UART_RXD,DATA_OUT)
begin
  if  falling_edge(CLK) then
      if  StartRX='1' then
          countA <= countA+1 ; -- increment counter
           if     countA=4 then
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 0 (LSB)
           elsif  countA=7 then                                       
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 1
           elsif  countA=10 then                                       
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 2
           elsif  countA=13 then                                       
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 3
           elsif  countA=16 then                                       
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 4
           elsif  countA=19 then                                       
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 5
           elsif  countA=22 then                                       
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 6
           elsif  countA=25 then                                       
                  DATA_OUT <=UART_RXD & DATA_OUT(7 downto 1); -- bit 7 (MSB)              
           elsif  countA=28 then
                  StopRX <= '1' ; -- stop reading
           end if;
      else
        countA    <=  0  ; -- reset counter
        StopRX  <= '0' ; -- reset stopbit
      end if;
  end if;
end process;


--------------------------------------------------------------------------------
-- TX module
-- A tx frame is started at each end of reading incoming Rx frame.
--------------------------------------------------------------------------------

-- Divide by 3 CLK to get clock at baud rate for TX.
process (CLK)
begin
  if  rising_edge(CLK) then
      if cntdiv3 = 2 then
         cntdiv3 <= 0 ;
         CLKdiv3 <= '1' ;
      else
         cntdiv3 <= cntdiv3 +1 ;
         CLKdiv3 <= '0' ;
      end if;
  end if;
end process;

-- start/stop TX process
-- TX frame is started when Rx frame is received and read
process(StopTX,StopRX,nUART_EN)
begin
-- Wait end of receiving frame
	if    StopTX='1' then
			StartTX <= '0' ; -- stop reading
	elsif rising_edge(StopRX) and nUART_EN='0' then
        StartTX <= '1' ; -- start transmitting data on tX line
	end if;
  
  
end process;

--- sending 8 data bits to TX
process(CLKdiv3,StartTX,StopTX,countB,DATA_IN)
begin
  if  falling_edge(CLKdiv3) then
      if  StartTX='1' then
          countB <= countB + 1 ; -- increment counter
           if     countB= 0 then
                  UART_TXD <= '0';	  -- Start bit =0
           elsif  countB= 1 then
                  UART_TXD <= DATA_IN(0); -- bit 0 (LSB)
           elsif  countB= 2 then                                       
                  UART_TXD <= DATA_IN(1); -- bit 1
           elsif  countB= 3 then                                       
                  UART_TXD <= DATA_IN(2); -- bit 2
           elsif  countB= 4 then                                       
                  UART_TXD <= DATA_IN(3); -- bit 3
           elsif  countB= 5 then                                       
                  UART_TXD <= DATA_IN(4); -- bit 4
           elsif  countB= 6 then                                       
                  UART_TXD <= DATA_IN(5); -- bit 5
           elsif  countB= 7 then                                       
                  UART_TXD <= DATA_IN(6); -- bit 6
           elsif  countB= 8 then                                       
                  UART_TXD <= DATA_IN(7); -- bit 7 (MSB)              
           elsif  countB= 9 then
                  UART_TXD <= '1' ; -- stop bit =1
                  StopTX <= '1' ; -- stop reading
           end if;
      else
        countB    <=  0  ; -- reset counter
        StopTX  <= '0' ; -- reset stopbit
        UART_TXD <= '1' ; -- TXD signal default value
      end if;
  end if;
end process;
--
--XStopTX <= StopTX ;
--XStopRX <= StopRX ;       
end behavorial;
