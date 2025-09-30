-----------------------------------------------------------------
-- Clock divider test module
------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TESTclkdivider is
--
port(

  enable	      : in  std_logic; -- enable input
  CLKIN         : in  std_logic; -- clock input
  CLOCKO        : out std_logic_vector(23 downto 0) ; --
  CLOCKOx       : out std_logic_vector(23 downto 0)  --
);

end TESTclkdivider ;

architecture Behavioral of TESTclkdivider is

signal  clk_divider1 : unsigned (23 downto 0); -- clock divider counter
signal  clk_divider2 : unsigned (23 downto 0); -- clock divider counter

begin

------------------------------------------------------------------
-- CLOCK divider Normal (with skew)
------------------------------------------------------------------
p_clk_divider: process(CLOCK,enable,clk_divider1)
begin
	if enable = '1' then
		if  rising_edge(CLOCK) then
		    clk_divider1   <= clk_divider1 + 1 ;
		end if;
	else
    clk_divider1 <= x"000000" ; -- clear counter if enable is low.
	end if;
  CLOCKO    <= clk_divider1 ; -
end process p_clk_divider;

------------------------------------------------------------------
-- CLOCK divider Modified  (no skew)
------------------------------------------------------------------
p_clk_divider: process(CLOCK,enable,clk_divider2)
begin
	if enable = '1' then
		if  rising_edge(CLOCK) then
		    clk_divider2   <= clk_divider2 + 1 ;
		end if;
	else
    clk_divider <= x"000000" ; -- clear counter if enable is low.
    if  falling_edge(Clock)  then
        CLOCKx <= clk_divider2 ;
    end if;
  end if;

end process p_clk_divider;
-------------------------------------------


end Behavioral ;
