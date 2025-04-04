-- ===================================================================
-- Fichier : SPI_LED_Mapping.vhd
-- Description :
--   Ce module mappe les bits du signal d'entrée 24 bits SPIDATA
--   vers des sorties individuelles correspondant à des indicateurs LED.
--   Chaque bit de SPIDATA contrôle une LED spécifique.
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_LED_Mapping is
    Port (
        SPIDATA : in STD_LOGIC_VECTOR(23 downto 0);
        LED_192K       : out STD_LOGIC;
        LED_96K        : out STD_LOGIC;
        LED_48K        : out STD_LOGIC;
        LEDavg0        : out STD_LOGIC;
        LEDavg1        : out STD_LOGIC;
        LEDavg2        : out STD_LOGIC;
        LED_SE         : out STD_LOGIC;
        LED_CAL        : out STD_LOGIC;
        LED_FILTOFF    : out STD_LOGIC;
        nLED2_G        : out STD_LOGIC;
        nLED2_R        : out STD_LOGIC;
        nLED2_Y        : out STD_LOGIC;
        nLED1_R        : out STD_LOGIC;
        nLED1_G        : out STD_LOGIC;
        nLED1_Y        : out STD_LOGIC;
        FILTER_CH1     : out STD_LOGIC;
        SE_CH1         : out STD_LOGIC;
        FILTER_CH2     : out STD_LOGIC;
        SE_CH2         : out STD_LOGIC;
        nACTIVITY_LED  : out STD_LOGIC
    );
end SPI_LED_Mapping;

architecture Behavioral of SPI_LED_Mapping is
begin
    LED_192K      <= SPIDATA(23);
    LED_96K       <= SPIDATA(22);
    LED_48K       <= SPIDATA(21);
    LEDavg0       <= SPIDATA(20);
    LEDavg1       <= SPIDATA(19);
    LEDavg2       <= SPIDATA(18);
    LED_SE        <= SPIDATA(17);
    LED_CAL       <= SPIDATA(16);
    LED_FILTOFF   <= SPIDATA(15);
    nLED2_G       <= SPIDATA(14);
    nLED2_R       <= SPIDATA(13);
    nLED2_Y       <= SPIDATA(12);
    nLED1_R       <= SPIDATA(11);
    nLED1_G       <= SPIDATA(10);
    nLED1_Y       <= SPIDATA(9);
    FILTER_CH1    <= SPIDATA(8);
    SE_CH1        <= SPIDATA(7);
    FILTER_CH2    <= SPIDATA(6);
    SE_CH2        <= SPIDATA(5);
    nACTIVITY_LED <= SPIDATA(4);
end Behavioral;
