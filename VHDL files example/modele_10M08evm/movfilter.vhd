------------------------------------------------------------------
-- ON le 20/02/2017
-- Moving average filter
-- Tested ok.
-- signed 24 bits in and out data
-- input data_in & output assumed std_logic_vector(15 downto 0)
-- The output is the average of the 8 previous input samples.
------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity movfilter is
port(
  clock         : in  std_logic; -- clock input to Fs
  data_in       : in std_logic_vector(23 downto 0);
  output		: out std_logic_vector(23 downto 0));
end movfilter;

architecture Behavioral of movfilter is

type type1 is array (1 to 8) of std_logic_vector(23 downto 0);
signal stage: type1 := (others => (others => '0'));
signal sub_result: signed(23 downto 0) := (others => '0');
signal sum: signed(26 downto 0) := (others => '0');
begin
-- delay input 8 stages
process
	begin
		wait until 	clock = '1';
					stage(1) <= data_in;
		for i in 2 to 8 loop -- 
					stage(i) <= stage(i-1); 
		end loop;

-- subtract last stage from input
				sub_result <= signed(data_in) - signed(stage(8)); -- 

-- accumulate
				sum <= sum + sub_result;
				output <= std_logic_vector(sum(26 downto 3)); -- We remove the 3 LSB to divide by 8 the result after accumate
		end process;
end behavioral;
