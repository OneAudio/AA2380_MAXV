library ieee;
use ieee.std_logic_1164.all;
entity Asynch_shift16 is
  port(CLK,SIN,ALOAD : in std_logic;
        DATA   : in std_logic_vector(15 downto 0);
        SDO  : out std_logic);
end Asynch_shift16;
architecture archi of Asynch_shift16 is
  signal tmp: std_logic_vector(15 downto 0);
  begin 
    process (CLK, ALOAD, DATA)
      begin
        if (ALOAD='1') then
          tmp <= DATA;
        elsif (CLK'event and CLK='1') then
          tmp <= tmp(14 downto 0) & SIN;
        end if;
    end process;
    SDO <= tmp(15);
end archi;