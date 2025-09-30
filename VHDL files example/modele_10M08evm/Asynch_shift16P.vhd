library ieee;
use ieee.std_logic_1164.all;
entity Asynch_shift16P is 
  port(CLK, SDI,CLEAR : in  std_logic;
        POUT : out std_logic_vector(15 downto 0));
end Asynch_shift16P;
architecture archi of Asynch_shift16P is
  signal tmp: std_logic_vector(15 downto 0);
  begin
    process (CLK,CLEAR)
      begin 
		if CLEAR='1' then
			tmp <= x"0000" ;
		else
		if (CLK'event and CLK='1') then 
          tmp <= tmp(14 downto 0)& SDI;
        end if;
        end if;
    end process;
    POUT <= tmp;
end archi;