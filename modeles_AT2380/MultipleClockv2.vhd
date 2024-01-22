--------------------------------------------
-- ON 14/12/2017
-- Multiple clock generator from 2MHz input
-- take 32 LE
--------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity MultipleClockv2 is

  Port (
        Reset     :in   STD_LOGIC;  -- reset input
        clk2MHz   :in   STD_LOGIC;  -- input clock
        CLK8kHz   :out  STD_LOGIC;  -- 8 kHz output clock
        CLK4kHz   :out  STD_LOGIC;  -- 4 kHz output clock
        CLK2kHz   :out  STD_LOGIC;  -- 2 kHz output clock
        CLK8Hz    :out  STD_LOGIC;  -- 8 Hz output clock
        CLK500mHz :out  STD_LOGIC;  -- 0.5 Hz output clock
	     CLK100mHz :out  STD_LOGIC;  -- 0.1 Hz output clock
		  CLK50mHZ	:out  STD_LOGIC   -- 0.05Hz output clock
    );
end MultipleClockv2;

architecture Behavioral of MultipleClockv2 is

signal clk_divider : unsigned(24 downto 0) :=(others=>'0');

begin

p_clk_divider: process(reset,clk2MHz)
begin
  if(reset='1') then
    clk_divider   <= (others=>'0');
  elsif(rising_edge(clk2MHz)) then
    clk_divider   <= clk_divider + 1;
    CLK8kHz   <= not clk_divider(7);
    CLK4kHz   <= not clk_divider(8);
    CLK2kHz   <= not clk_divider(9);
    CLK8Hz    <= not clk_divider(17);
    CLK500mHz <= not clk_divider(21);
    CLK100mHz <= not clk_divider(23);
	 CLK50mHz  <= not clk_divider(24);
  end if;
end process p_clk_divider;




end Behavioral;
