-- ===================================================================
-- Fichier : F14_DAT2BUS
-- Description :
--   
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity F14_DAT2BUS is
    Port (
        CONF      : in STD_LOGIC_VECTOR(3 downto 0);
        READY     : in STD_LOGIC ; 
        SPIDATAin : out STD_LOGIC_VECTOR(23 downto 0)
    );
end F14_DAT2BUS;

architecture Behavioral of F14_DAT2BUS is
begin
    
    SPIDATAin(0) <= READY ;
    SPIDATAin(4 downto 1)<= not CONF(3 downto 0) ;
    SPIDATAin(23 downto 5) <= x"0000" & "000" ;
    
end Behavioral;
