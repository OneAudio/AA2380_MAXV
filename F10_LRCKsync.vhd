-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date:23/11/20	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 2  LE.
-- Function F10 :  F10_LRCKsync.vhd
-----------------------------------------------------------------
-- Generate short pulse at each rising edge of LRCK to synchronise
-- SPDIF data
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity F10_LRCKsync is
 port(
  CLK		    : in std_logic; -- fast clock (>128*LRCK)
  LRCK       : in std_logic; -- LRCK (48 to 192 kHz)
  LRsync     : out std_logic -- output sync pulse
 );
end entity F10_LRCKsync;

architecture behavioral of F10_LRCKsync is

signal QA    : std_logic :='0' ; --
signal Pulse : std_logic :='0' ; --

begin

PulseGenerator: process (CLK,LRCK,Pulse)
begin
  if    Pulse='1'  then
        QA <= '0';
  elsif rising_edge(LRCK) then
        QA <= '1';
  end if;
  if    rising_edge(CLK) then
        Pulse <= QA ;
  end if;
LRsync <= Pulse ;
end process PulseGenerator ;


end behavioral;
