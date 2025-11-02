-- ===================================================================
-- Fichier : F16_UIOTESTB
-- Description :
--   
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity F16_UIOTESTB is
    Port (
        J18_1   : in STD_LOGIC ;
        J18_3   : in STD_LOGIC ;
        J18_5   : in STD_LOGIC ;
        J18_7   : in STD_LOGIC ;
        J18_9   : in STD_LOGIC ;
        J18_11  : in STD_LOGIC ;
        J18_2   : in STD_LOGIC ;
        J18_4   : in STD_LOGIC ;
        J18_6   : in STD_LOGIC ;
        J18_8   : in STD_LOGIC ;
        J18_10  : in STD_LOGIC ;
        J18_12  : in STD_LOGIC ;
        TESTO_1 : out STD_LOGIC ;
        TESTO_3 : out STD_LOGIC ;
        TESTO_5 : out STD_LOGIC ;
        TESTO_7 : out STD_LOGIC ;
        TESTO_9 : out STD_LOGIC ;
        TESTO_11 : out STD_LOGIC ;
        TESTO_2 : out STD_LOGIC ;
        TESTO_4 : out STD_LOGIC ;
        TESTO_6 : out STD_LOGIC ;
        TESTO_8 : out STD_LOGIC ;
        TESTO_10 : out STD_LOGIC ;
        TESTO_12 : out STD_LOGIC 
    );
end F16_UIOTESTB;

architecture Behavioral of F16_UIOTESTB is
begin

TESTO_1 <= J18_1 ;
TESTO_3 <= J18_3 ;
TESTO_5 <= J18_5 ;
TESTO_7 <= J18_7 ;
TESTO_9 <= J18_9 ;
TESTO_11 <= J18_11 ;
TESTO_2 <= J18_2 ;
TESTO_4 <= J18_4 ;
TESTO_6 <= J18_6 ;
TESTO_8 <= J18_8 ;
TESTO_10 <= J18_10 ;
TESTO_12 <= J18_12   ;
    
end Behavioral;
