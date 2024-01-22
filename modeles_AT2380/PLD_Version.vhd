-----------------------------------------------------------------
-- O.N - 30/12/2017
-- take  xx LE
-- Version box
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

 entity PLD_Version is
 generic(VER : integer := 22 ); -- version set value
    Port (
         VERSION	    : out	std_logic_vector (7 downto 0)  -- PLD version (.000 to .255)
    );
 end PLD_Version;

architecture Attenuator of PLD_Version is
---------------------------------------------------------
---------------------------------------------------------

begin

VERSION <= std_logic_vector(to_unsigned(ver,8));


end architecture;
