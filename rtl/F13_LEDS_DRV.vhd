-- ===================================================================
-- Fichier : F13_LEDS_DRV
-- Description :
--   Ce module mappe les 6 bits  pour les deux leds tricolores
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity F13_LEDS_DRV is
    Port (
        nRESET          : in STD_LOGIC;
        LED_ACT         : in STD_LOGIC;
        MCLK_RDY        : in STD_LOGIC;
        LED1            : in STD_LOGIC_VECTOR(2 downto 0);
        LED2            : in STD_LOGIC_VECTOR(2 downto 0);
        nACTIVITY_LED   : out STD_LOGIC;
        nLED1_Y         : out STD_LOGIC;
        nLED1_G         : out STD_LOGIC;
        nLED1_R         : out STD_LOGIC;
        nLED2_Y         : out STD_LOGIC;
        nLED2_G         : out STD_LOGIC;
        nLED2_R         : out STD_LOGIC
    );
end F13_LEDS_DRV;

architecture Behavioral of F13_LEDS_DRV is
begin

-- Gestion de la LED d'activité (active low)
process(nRESET, LED_ACT, MCLK_RDY)
begin
    if nRESET = '0' then
        nACTIVITY_LED <= '1'; -- LED éteinte
    else
        -- Led d'activité est allumée fixe si LED_ACT qui vient
        -- de la carte 10M08 est actif, et clignote si en plus MCLK_RDY
        -- qui détecte la présence de MCLK est actif.
        nACTIVITY_LED <= not (LED_ACT or not MCLK_RDY);
    end if;
end process;

    -- Mapping des LEDs tricolores (active low)
     nLED1_Y <= not LED1(0);
     nLED1_G <= not LED1(1);
     nLED1_R <= not LED1(2);
     nLED2_Y <= not LED2(0);
     nLED2_G <= not LED2(1);
     nLED2_R <= not LED2(2);
    
end Behavioral;
