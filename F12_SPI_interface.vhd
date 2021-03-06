-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date:27/11/20	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 86 LE.
-- Function F12 :  F12_SPI_interface
-----------------------------------------------------------------
-- Interface function for isolated link between AA2380 board and
-- AA10M08 CPU dauther board.
--  (It's not a real SPI link! But that look like.. )
--
-- The master send 32 clocks cycles when nCS is active (low)
-- First 16 data are send from master to slave to MOSI
-- then 16 others data are send from slave to MISO
-- Data at settled at rising edge of spi_clock, and read at
-- falling egde.
-- Resulting data buffer is latched at  rising edge of nCS
---
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity F12_SPI_interface is
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
end entity F12_SPI_interface;

architecture behavioral of F12_SPI_interface is

signal serial_cnt  : integer range 0 to 31  ; -- 32 bits data counter
signal tx_data  : std_logic_vector(31 downto 0) ; -- data latch
signal rx_data  : std_logic_vector(15 downto 0) ; -- data counter

begin
-----------------------------------------------------------------------------------
-- SPI link between AA2380 board and AA10M08 dotherboard
-----------------------------------------------------------------------------------
SPI_slave_module : process (SPI_ADCnCS,SPI_CLK,serial_cnt,SPI_MOSI,tx_data,DATA_in,rx_data)
begin
    -- Latch data to buffer when reading is end (cs become high)



    --
    if  SPI_ADCnCS='0'  then
        if  falling_edge(SPI_CLK)  then
            serial_cnt <= serial_cnt + 1 ; -- increment counter
            -- data to receive
            case  serial_cnt is
                  when  0  => rx_data(15) <= SPI_MOSI;
                  when  1 => rx_data(14) <= SPI_MOSI;
                  when  2 => rx_data(13) <= SPI_MOSI;
                  when  3 => rx_data(12) <= SPI_MOSI;
                  when  4 => rx_data(11) <= SPI_MOSI;
                  when  5 => rx_data(10) <= SPI_MOSI;
                  when  6 => rx_data(9)  <= SPI_MOSI;
                  when  7 => rx_data(9)  <= SPI_MOSI;
                  when  8 => rx_data(7)  <= SPI_MOSI;
                  when  9 => rx_data(6)  <= SPI_MOSI;
                  when 10 => rx_data(5)  <= SPI_MOSI;
                  when 11 => rx_data(4)  <= SPI_MOSI;
                  when 12 => rx_data(3)  <= SPI_MOSI;
                  when 13 => rx_data(2)  <= SPI_MOSI;
                  when 14 => rx_data(1)  <= SPI_MOSI;
                  when 15 => rx_data(0)  <= SPI_MOSI;
                  when others => rx_data <= x"0000" ;
            end case;
            -- data to be send
            tx_data <= tx_data(30 downto 0) & '0' ; -- shift
        end if;
    else
      serial_cnt <= 0 ;-- reset counter
      tx_data  <= DATA_in & x"0000" ; -- latch input data
      DATA_out <= rx_data ; -- latch received data
    end if;
    --
    SPI_MISO <=tx_data(31); -- send MSB of tx_data to MISO

end process SPI_slave_module ; -- end of Process

end behavioral ; -- end of file.
