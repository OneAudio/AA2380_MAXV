-- ===================================================================
-- Fichier : F13_LEDSTRI
-- Description :
--   Ce module mappe les 6 bits  pour les deux leds tricolores
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity F13_LEDSTRI is
    Port (
        LED1    : in STD_LOGIC_VECTOR(2 downto 0);
        LED2    : in STD_LOGIC_VECTOR(2 downto 0);
        nLED1_Y : out STD_LOGIC;
        nLED1_G : out STD_LOGIC;
        nLED1_R : out STD_LOGIC;
        nLED2_Y : out STD_LOGIC;
        nLED2_G : out STD_LOGIC;
        nLED2_R : out STD_LOGIC
    );
end F13_LEDSTRI;

architecture Behavioral of F13_LEDSTRI is
begin
    
     nLED1_Y <= not LED1(0);
     nLED1_G <= not LED1(1);
     nLED1_R <= not LED1(2);
     nLED2_Y <= not LED2(0);
     nLED2_G <= not LED2(1);
     nLED2_R <= not LED2(2);
    
end Behavioral;
