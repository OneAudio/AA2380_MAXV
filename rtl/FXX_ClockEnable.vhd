-----------------------------------------------------------------
-- ON le 17/12/2020
-- Clock circuit with enable.
-- The output is synchronous to falling_edge of input
-- clock to avoid glitch.
-- FXX_ClockEnable.vhd
-- Take 1 LE only
------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FXX_ClockEnable is
--
port(

  enable      : in  std_logic; -- enable input
  CLKI        : in  std_logic; -- clock input
  CLKO        : out std_logic
);

end FXX_ClockEnable ;

architecture Behavioral of FXX_ClockEnable is

signal  QA           : std_logic ; --

begin
---
CKenab: process(CLKI,enable,QA)
begin
    --
		if  falling_edge(CLKI) then
        QA <= enable ;
    end if;
		CLKO <= QA and CLKI ;
end process CKenab;
---
end Behavioral ;
