-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date:23/11/20	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 6 LE.
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
signal cnt	 : integer range 0 to 15  ; -- counter


begin

PulseGenerator: process (CLK,LRCK,Pulse,cnt,QA)
begin
  if    Pulse='1'  then
        QA <= '0';
  elsif rising_edge(LRCK) then
        QA <= '1';
  end if;
  --
  if    QA='0' then
        cnt <= 0 ;
        Pulse <='0' ;
  else
      if  rising_edge(CLK) THEN
          cnt <=cnt+1;
          if  cnt<1  THEN
              Pulse <= '0';
          else
              Pulse <= '1';
          end if;
      end if;
  end if;
LRsync <= QA ;
end process PulseGenerator ;

end behavioral;
