-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date:24/11/20	Designer: O.N
-- 24 bits fixed data for test purpose
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity TEST_Fixed_LR_values is
 port(
  DATAL		: out std_logic_vector(23 downto 0); -- Left  channel Data
  DATAR   : out std_logic_vector(23 downto 0)  -- Right channel Data
 );
end entity TEST_Fixed_LR_values;

architecture behavioral of TEST_Fixed_LR_values is
begin

DATAL <= x"201004"; -- binary= 001000000001000000000100
DATAR <= x"802801"; -- binary= 100000000010100000000001

end behavioral;
