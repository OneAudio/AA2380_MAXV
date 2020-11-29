-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date:29/11/20	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 69 LE.
-- Function F14 :  F14_slaveio
-----------------------------------------------------------------
--
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
  ExtCLK      : out std_logic : -- external clock mode enable
  CNVmode     : out std_logic_vector(2 downto 0); -- ADC conversion mode selection
  PANleds     : out std_logic_vector(8 downto 0); -- AA2380PAN 9 leds drive
  -- INPUTS DATA Data received from SPI
  DATA_out    : out std_logic_vector(15 downto 0) ; -- Data received from 10M08 board
  -- INPUTS DATA & CLOCKS
  DATA_in     : in std_logic_vector (15 downto 0) ; -- Data to be send on 10M08 board


 );
end entity F14_slaveio;

architecture behavioral of F14_slaveio is

signal  : integer range 0 to 15  ; -- 32 bits data counter
signal  : std_logic_vector(15 downto 0) ; -- data latch
signal  : std_logic_vector(15 downto 0) ; -- data counter

begin
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
io_module : process ()
begin

end process io_module ; -- end of Process

end behavioral ; -- end of file.
