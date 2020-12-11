-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date:10/12/20	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 0 LE.
-- Function F14 :  F14_slaveio
-----------------------------------------------------------------
--   This function all only signals in/out from/to bus vector
--   from/to SPI serial modules (SPI_slave and SPI_master)
--
--                    *** SPI LINK SIGNAL DESCRIPTION ***  
--            ___                                                                  ___
--  /CS          \__________________________active________________________________/
--                  ___     ___     __      ___     ___     ___     ___     ___
--  clock     _____/   \___/   \___/  ...__/   \___/   \___/   \___/   \___/   \_______
--                  _______ _______ __...__ _______ _______ _______ _______ _______
--  data_out  _____/__D31__X__D30__X__...__X__D04__X__D03__X__D02__X__D01__X__D00__\___
--                  _______ _______ __...__ _______ _______ _______ _______ _______
--  data_in   _____/__D31__X__D30__X__...__X__D04__X__D03__X__D02__X__D01__X__D00__\___
--
--  Data in/out change on rising_edge of clock, and must be read on falling edge.
--  The data length is 32 bits. in and out send at same time.
--  Data read/write is onlys initiated by master.
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity F14_slaveio is
 port(
  -- Signal to be send to AA10M08
  Ready       : in std_logic  ; -- AA2380 board ready signal (active high)
  ROTccw      : in std_logic  ; -- AA2380PAN rotary encoder ccw direction indicator
  ROTpulse    : in std_logic  ; -- AA2380PAN rotary encoder pulses
  ROTpush     : in std_logic  ; -- AA2380PAN rotary encoder push
  -- Signal received from AA10M08
  SRate       : out std_logic_vector(2 downto 0); -- Sample rate(kHz) : 1536/768/384/192/96/48/24/12
  Average     : out std_logic_vector(3 downto 0); -- Sinc Average ratio (x) : 1/2/4/8/16/32/64/128
  DIFFnSE     : out std_logic_vector(1 downto 0); -- Differential/ single-ended mode input
  HighBW      : out std_logic_vector(1 downto 0); -- Low(0)/High(1) input filter bandwidth
  Lleds       : out std_logic_vector(2 downto 0); -- Left channel tricolor leds
  Rleds       : out std_logic_vector(2 downto 0); -- Right channel tricolor leds
  ExtCLK      : out std_logic ; -- external clock mode enable
  CNVmode     : out std_logic_vector(2 downto 0); -- ADC conversion mode selection
  PANleds     : out std_logic_vector(8 downto 0); -- AA2380PAN 9 leds drive
  SPARE0      : out std_logic ; -- Spare output
  SPARE1      : out std_logic ; -- Spare output
  SPARE2      : out std_logic ; -- Spare output
  -- INPUTS DATA Data received from SPI
  DATA_out    : out std_logic_vector(15 downto 0) ; -- Data received from 10M08 board
  -- INPUTS DATA & CLOCKS
  DATA_in     : in std_logic_vector (31 downto 0)  -- Data to be send on 10M08 board
 );
end entity F14_slaveio;

architecture behavioral of F14_slaveio is

begin
-----------------------------------------------------------------------------------
-- Concatane data to be transmitted
DATA_out <= "000000000000" & ROTpulse & ROTccw & ROTpush & Ready ; -- 16 bits to send

-- Un-concatane received data (32 bits data wide)
SRate   <= DATA_in(2 downto 0) ; -- bit 0.1.2 (LSB) to receive
Average <= DATA_in(6 downto 3) ; -- bit 3.4.5 to receive
DIFFnSE <= DATA_in(7 downto 6) ; -- bit 6.7 to receive
HighBW  <= DATA_in(9 downto 8) ; -- bit 8.9 to receive
CNVmode <= DATA_in(12 downto 10) ; -- bit 10.11.12 to receive
ExtCLK  <= DATA_in(13) ; -- bit 13 to receive
Lleds   <= DATA_in(16 downto 14) ; -- bit 14.15.16 to receive
Rleds   <= DATA_in(19 downto 17) ; -- bit 17.18.19 to receive
PANleds <= DATA_in(28 downto 20) ; -- bit 20.21.22.23.24.25.26.27.28 to receive
SPARE0  <= DATA_in(29) ; -- - bit 28 to receive
SPARE1  <= DATA_in(30) ; -- - bit 29 to receive
SPARE2  <= DATA_in(31) ; -- - bit 30 to receive


end behavioral ; -- end of file.
