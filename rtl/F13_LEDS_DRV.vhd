-- ===================================================================
-- Fichier : F13_LEDS_DRV
-- Description :
-- 
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity F13_LEDS_DRV is
    Port (
        nRESET          : in STD_LOGIC;
        LED_ACT         : in STD_LOGIC;
        MCLK_RDY        : in STD_LOGIC;
        nACTIVITY_LED   : out STD_LOGIC
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
    
end Behavioral;
