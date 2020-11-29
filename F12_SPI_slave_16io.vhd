-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date:27/11/20	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 69 LE.
-- Function F12 :  F12_SPI_slave_16io
-----------------------------------------------------------------
-- Interface function for isolated link between AA2380 board and
-- AA10M08 CPU dauther board.
--  (It's not a real SPI link! But that look like.. )
--  **************************
-- It's the slave side module.
--  **************************
-- The master send 16 clocks cycles when nCS is active (low)
-- 16 datas are send from master to slave to MOSI
-- and 16 others data are send from slave to MISO a same time.
-- Data at settled at rising edge of spi_clock, and read at
-- falling egde.
-- Resulting data buffer is latched at  rising edge of nCS
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity F12_SPI_slave_16io is
 port(
  -- INPUTS DATA Data received from SPI
  DATA_in     : in std_logic_vector (15 downto 0) ; -- Data to be send on 10M08 board
  DATA_out    : out std_logic_vector(15 downto 0) ; -- Data received from 10M08 board
  -- INPUTS DATA & CLOCKS
  SPI_CLK     : in std_logic  ; -- Serial SPI link clock (slave)
  SPI_MOSI    : in std_logic  ; -- Serial SPI data link clock (slave)
  SPI_MISO    : out std_logic ; -- Serial SPI link clock (slave)
  SPI_ADCnCS  : in std_logic   -- Chipselect for ADC board (AA2380)

 );
end entity F12_SPI_slave_16io;

architecture behavioral of F12_SPI_slave_16io is

signal serial_cnt  : integer range 0 to 15  ; -- 32 bits data counter
signal tx_data  : std_logic_vector(15 downto 0) ; -- data latch
signal rx_data  : std_logic_vector(15 downto 0) ; -- data counter

begin
-----------------------------------------------------------------------------------
-- SPI link between AA2380 board and AA10M08 dotherboard
-----------------------------------------------------------------------------------
SPI_slave_module : process (SPI_ADCnCS,SPI_CLK,serial_cnt,SPI_MOSI,tx_data,DATA_in,rx_data)
begin
    --
    if  SPI_ADCnCS='0'  then -- Wait chip selec active (low)
        if  falling_edge(SPI_CLK)  then -- start reading received data at falling edge of spi clock
            serial_cnt <= serial_cnt + 1 ; -- increment bit counter
            -- data to receive
            case  serial_cnt is -- send received seril data o rx_data buffer
                  when  0  => rx_data(15) <= SPI_MOSI; -- read MSB data
                  when  1 => rx_data(14) <= SPI_MOSI;
                  when  2 => rx_data(13) <= SPI_MOSI;
                  when  3 => rx_data(12) <= SPI_MOSI;
                  when  4 => rx_data(11) <= SPI_MOSI;
                  when  5 => rx_data(10) <= SPI_MOSI;
                  when  6 => rx_data(9)  <= SPI_MOSI;
                  when  7 => rx_data(8)  <= SPI_MOSI;
                  when  8 => rx_data(7)  <= SPI_MOSI;
                  when  9 => rx_data(6)  <= SPI_MOSI;
                  when 10 => rx_data(5)  <= SPI_MOSI;
                  when 11 => rx_data(4)  <= SPI_MOSI;
                  when 12 => rx_data(3)  <= SPI_MOSI;
                  when 13 => rx_data(2)  <= SPI_MOSI;
                  when 14 => rx_data(1)  <= SPI_MOSI;
                  when 15 => rx_data(0)  <= SPI_MOSI; -- read LSB data
                  when others => null ;
            end case;
            -- data to be send
        end if;
        if  rising_edge(SPI_CLK) and serial_cnt >0  then -- send data to Master side at rising edge of SPI clock with 1 clk delay
          tx_data <= tx_data(14 downto 0) & '0' ; -- shift transmitted daa buffer at each SPI clock cycle
        end if;
    else -- When CS become high :
      serial_cnt <= 0 ;-- reset serial counter
      tx_data  <= DATA_in ; -- latch input data
      DATA_out <= rx_data ; -- latch received data
    end if;
    --
    SPI_MISO <=tx_data(15); -- send MSB of tx_data to MISO to get serial output

end process SPI_slave_module ; -- end of Process

end behavioral ; -- end of file.
