-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date:10/12/20	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 133 LE.
-- Function F13 :  F13_SPI_master_32io
-----------------------------------------------------------------
-- Interface function for isolated link between AA10M08 CPU dauther
-- board and AA2380 ADC board.
--  (It's not a real SPI link! But that look like.. )
--
-- The master send 32 clocks cycles when nCS is active (low)
-- First 16 data are send from master to slave to MOSI
-- then 16 others data are send from slave to MISO
-- Data at settled at rising edge of spi_clock, and read at
-- falling egde.
-- Resulting data buffer is latched at  rising edge of nCS
--
--
--                                  *** SPI LINK SIGNAL DESCRIPTION ***
--           ___                                                                   _________________
-- /CS          \__________________________active low_____________________________/
--                 ___     ___     __      ___     ___     ___     ___     ___
-- clock     _____/31 \___/   \___/  ...__/   \___/   \___/   \___/   \___/ 0 \____________________
--           _____________________________________________________________________ _________________                                                                       ________________
-- data_out  ______________________data(n-1)[15..0]_______________________________X__data(n)[15..0]__
--                 _______ _______ __...__ _______ _______ _______ _______ ______
-- spi_mosi  _____/__D31__X__D30__X__...__X__D04__X__D03__X__D02__X__D01__X__D00_\___________________
--
--
--
-- Data in/out change on rising_edge of clock, and must be read on falling edge.
-- The data length is 32 bits. in and out send at same time.
-- Data read/write is onlys initiated by master.
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity F13_SPI_master_32io is
 port(
  -- CLOCK
  CLOCK_spi   : in std_logic ; -- clock for SPI : equal twice the frequency of effective SPI_CLK
  strobe      : in std_logic ; -- strobe input to initiate spi read/write sequence when new data available
  -- INPUTS DATA Data received from SPI
  DATA_out    : out std_logic_vector(31 downto 0) ; -- Data received from AA2380 board
  DATA_in     : in std_logic_vector (31 downto 0) ; -- Data to be send on AA2380 board
  -- INPUTS DATA & CLOCKS
  SPI_CLK     : buffer std_logic ; -- Serial SPI link clock (slave)
  SPI_MOSI    : out std_logic ; -- Serial SPI data link clock (slave)
  SPI_MISO    : in  std_logic ; -- Serial SPI link clock (slave)
  SPI_ADCnCS  : buffer std_logic ;   -- Chipselect for ADC board (AA2380)
  --test
  ckpspi_cnt_tst : out integer range 0 to 127 ;
  spi_run_tst : out std_logic
 );
end entity F13_SPI_master_32io;

architecture behavioral of F13_SPI_master_32io is

  signal serial_cnt   : integer range 0 to 31  ; -- 32 bits data counter
  signal tx_data      : std_logic_vector(31 downto 0) ; -- data latch
  signal rx_data      : std_logic_vector(31 downto 0) ; -- data counter

  signal ckpspi_cnt   : integer range 0 to 127  ; -- counter ??
  signal spi_run      : std_logic ;

  begin

spi_run_tst <= spi_run ;
ckpspi_cnt_tst <= ckpspi_cnt ;
--------------------------------------------------------------------------------
-- SPI /CS generator
--------------------------------------------------------------------------------
csgen_module : process (CLOCK_spi,strobe,ckpspi_cnt,spi_run)
begin
    -- strobe edge initiate spi read/write.
    if      ckpspi_cnt= 65  then -- condition for spi sequence completed.
            spi_run <= '0'  ; -- bit  to stop spi
    elsif   rising_edge(strobe)  then
            spi_run <= '1'  ; -- bit set to run spi
    end if;
    --
    if      spi_run='1'  then
            if    rising_edge(CLOCK_spi) then
                  ckpspi_cnt <= ckpspi_cnt+1 ; -- increment counter
                  SPI_CLK <= not SPI_CLK ; -- generate SPI_CLK = CLOCK_spi/2
                  if  ckpspi_cnt <= 64 then
                      SPI_ADCnCS <= '0' ; -- set chip select SPI_ADCnCS
                  else
                      SPI_ADCnCS <= '1' ;
                  end if;
            end if;
    else
          SPI_CLK    <= '0' ; -- reset SPI_CLK
          ckpspi_cnt <=  0  ; -- reset counter
          SPI_ADCnCS <= '1' ;
    end if;

end process csgen_module ; -- end of Process

  -----------------------------------------------------------------------------------
  -- SPI link between AA2380 board and AA10M08 dotherboard
  -----------------------------------------------------------------------------------
  SPI_slave_module : process (SPI_ADCnCS,SPI_CLK,serial_cnt,tx_data,DATA_in,rx_data)
  begin
      --
      if  SPI_ADCnCS='0'  then -- Wait chip selec active (low)
          if  falling_edge(SPI_CLK)  then -- start reading received data at falling edge of spi clock
              serial_cnt <= serial_cnt + 1 ; -- increment bit counter
              -- data to receive
              case  serial_cnt is -- send received seril data o rx_data buffer
                    when  0 => rx_data(31) <= SPI_MISO; -- read MSB data
                    when  1 => rx_data(30) <= SPI_MISO;
                    when  2 => rx_data(29) <= SPI_MISO;
                    when  3 => rx_data(28) <= SPI_MISO;
                    when  4 => rx_data(27) <= SPI_MISO;
                    when  5 => rx_data(26) <= SPI_MISO;
                    when  6 => rx_data(25) <= SPI_MISO;
                    when  7 => rx_data(24) <= SPI_MISO;
                    when  8 => rx_data(23) <= SPI_MISO;
                    when  9 => rx_data(22) <= SPI_MISO;
                    when 10 => rx_data(21) <= SPI_MISO;
                    when 11 => rx_data(20) <= SPI_MISO;
                    when 12 => rx_data(19) <= SPI_MISO;
                    when 13 => rx_data(18) <= SPI_MISO;
                    when 14 => rx_data(17) <= SPI_MISO;
                    when 15 => rx_data(16) <= SPI_MISO;
                    when 16 => rx_data(15) <= SPI_MISO;
                    when 17 => rx_data(14) <= SPI_MISO;
                    when 18 => rx_data(13) <= SPI_MISO;
                    when 19 => rx_data(12) <= SPI_MISO;
                    when 20 => rx_data(11) <= SPI_MISO;
                    when 21 => rx_data(10) <= SPI_MISO;
                    when 22 => rx_data(9)  <= SPI_MISO;
                    when 23 => rx_data(8)  <= SPI_MISO;
                    when 24 => rx_data(7)  <= SPI_MISO;
                    when 25 => rx_data(6)  <= SPI_MISO;
                    when 26 => rx_data(5)  <= SPI_MISO;
                    when 27 => rx_data(4)  <= SPI_MISO;
                    when 28 => rx_data(3)  <= SPI_MISO;
                    when 29 => rx_data(2)  <= SPI_MISO;
                    when 30 => rx_data(1)  <= SPI_MISO;
                    when 31 => rx_data(0)  <= SPI_MISO; -- read LSB data
                    when others => null ;
              end case;
              -- data to be send
          end if;
          if  rising_edge(SPI_CLK) and serial_cnt >0  then -- send data to Master side at rising edge of SPI clock with 1 clk delay
            tx_data <= tx_data(30 downto 0) & '0' ; -- shift transmitted daa buffer at each SPI clock cycle
          end if;
      else -- When CS become high :
        serial_cnt <= 0 ;-- reset serial counter
        tx_data  <= DATA_in ; -- latch input data
        DATA_out <= rx_data ; -- latch received data
      end if;
      --
      SPI_MOSI <=tx_data(31); -- send MSB of tx_data to MISO to get serial output

  end process SPI_slave_module ; -- end of Process

  end behavioral ; -- end of file.
