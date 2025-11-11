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
        D0 : out STD_LOGIC;
        D1 : out STD_LOGIC;
        D2 : out STD_LOGIC;
        D3 : out STD_LOGIC;
        D4 : out STD_LOGIC;
        D5 : out STD_LOGIC;
        D6 : out STD_LOGIC;
        D7 : out STD_LOGIC;
        D8 : out STD_LOGIC;
        D9 : out STD_LOGIC;
        D10 : out STD_LOGIC
    );
end F12_SPI_Mapping;

architecture Behavioral of F12_SPI_Mapping is
begin
    D0 <= SPIDATA(0);
    D1 <= SPIDATA(1);
    D2 <= SPIDATA(2);
    D3 <= SPIDATA(3);
    D4 <= SPIDATA(4);
    D5 <= SPIDATA(5);
    D6 <= SPIDATA(6);
    D7 <= SPIDATA(7);
    D8 <= SPIDATA(8);
    D9 <= SPIDATA(9);
    D10 <= SPIDATA(10);
end Behavioral;
