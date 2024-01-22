----------------------------------------------------------
-- ON 19/01/2018
-- Multiple clock generator from 4.6 MHz input
-- from internat oscillator of MAXV device.
-- Take  39 LE
-- Adding ready output
-- Adding uart clock 
----------------------------------------------------------
-- Note: for MAXV device, the internal oscillator
-- can be between 3.9~5.3MHz ( 4.6 MHz typical +/- % maxi)
--
-- Fin= 4.6MHz typ (3.9M to 5.3M) --> +/- 15% accuracy
-- clk_divider(8) : => 8984 Hz
-- clk_divider(9) : => 4492 Hz
-- clk_divider(10) : => 2246 Hz
-- clk_divider(18): => 8.7 Hz
-- clk_divider(22): => 0.55 Hz
-- clk_divider(24): => 0.14 Hz
-- clk_divider(25): => 0.07 Hz
--
-- For a typical 28.8kHz output for the uart block,
-- with clk_divider(2)=287.5kHZ
-- we use a 3 bits counter to make 287.5/10 =28750 Hz
-- (toggle bit each 5 periods of clk_divider(2))
--
--
----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity MultipleClockv4 is

  Port (
        Reset     	:in   STD_LOGIC;  -- Reset input
        OSC4M6   	:in   STD_LOGIC;  -- 4.6M typ Input clock from internal oscillator UFM of MAXV.
        CLK_uart    :buffer STD_LOGIC;  -- 28800 Hz uart clock for 9600 bauds.
	    Ready		:out  STD_LOGIC;  -- Ready output=1 after 1s
        CLK8kHz   	:out  STD_LOGIC;  -- 8 kHz output clock
        CLK4kHz   	:out  STD_LOGIC;  -- 4 kHz output clock
        CLK2kHz   	:out  STD_LOGIC;  -- 2 kHz output clock
        CLK8Hz    	:out  STD_LOGIC;  -- 8 Hz output clock
        CLK500mHz 	:buffer  STD_LOGIC;  -- 0.5 Hz output clock
      	CLK100mHz   :out  STD_LOGIC;  -- 0.1 Hz output clock
        CLK50mHZ    :out  STD_LOGIC   -- 0.05 Hz output clock
    );
end MultipleClockv4;

architecture Behavioral of MultipleClockv4 is

signal clk_divider	: unsigned(25 downto 0) :=(others=>'0');
signal uart_divider : integer range 0 to 5 ; -- 3 bits counter for divide/5
signal tmp		: std_logic :='0' ;

begin

p_clk_divider: process(reset,OSC4M6,CLK500mHz,uart_divider,clk_divider(2))
begin
  if(reset='1') then
    clk_divider   <= (others=>'0');
  elsif(rising_edge(OSC4M6)) then
    clk_divider   <= clk_divider + 1;
    CLK8kHz   <= not clk_divider(8);
    CLK4kHz   <= not clk_divider(9);
    CLK2kHz   <= not clk_divider(10);
    CLK8Hz    <= not clk_divider(18);
    CLK500mHz <= not clk_divider(22);
    CLK100mHz <= not clk_divider(24);
    CLK50mHz  <= not clk_divider(25);
  end if;
  if (rising_edge(clk_divider(3))) then -- 287.5kHz clock
     uart_divider   <= uart_divider + 1;
     if uart_divider=4 then
        uart_divider <= 0 ; -- reset counter
        CLK_uart <= not CLK_uart; -- toggle CLK_uart (for 28750 Hz output)
    end if;
  end if;
      
-- generate ready signal
if rising_edge(CLK500mHz) then
	tmp <= '1';
	Ready <= tmp;
end if;

end process p_clk_divider;


end Behavioral;
