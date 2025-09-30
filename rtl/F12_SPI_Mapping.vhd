-- ===================================================================
-- Fichier : F12_SPI_Mapping
-- Description :
--   Ce module mappe les bits du signal d'entrée 24 bits SPIDATA
--   vers des sorties individuelles 
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity F12_SPI_Mapping is
    Port (
        SPIDATA : in STD_LOGIC_VECTOR(23 downto 0);
        DFS     : out STD_LOGIC_VECTOR(2 downto 0);
        AVG     : out STD_LOGIC_VECTOR(2 downto 0);
        LED1    : out STD_LOGIC_VECTOR(2 downto 0);
        LED2    : out STD_LOGIC_VECTOR(2 downto 0);
        SE_CH1  : out STD_LOGIC;
        SE_CH2  : out STD_LOGIC;
        HBW_CH1 : out STD_LOGIC;
        HBW_CH2 : out STD_LOGIC;
        AQMODE  : out STD_LOGIC;
		  LED_ACT : out STD_LOGIC;
        SPARE   : out STD_LOGIC_VECTOR(5 downto 0)
    );
end F12_SPI_Mapping;

architecture Behavioral of F12_SPI_Mapping is
begin
    HBW_CH2 <= SPIDATA(23);
    HBW_CH1 <= SPIDATA(22);
    SE_CH2 <= SPIDATA(21);
    SE_CH1 <= SPIDATA(20);
    LED2(2 downto 0) <= SPIDATA(19 downto 17);
    LED1(2 downto 0) <= SPIDATA(16 downto 14);
	 LED_ACT <= SPIDATA(13) ;
    SPARE(5 downto 0) <= SPIDATA(12 downto 7);
    AQMODE <= SPIDATA(6);
    AVG(2 downto 0) <= SPIDATA(5 downto 3);
    DFS(2 downto 0) <= SPIDATA(2 downto 0);
end Behavioral;
