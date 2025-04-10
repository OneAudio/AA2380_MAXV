-- ===================================================================
-- Fichier : F16_UIOTEST
-- Description :
--   
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity F16_UIOTEST is
    Port (
        J17_2  : in STD_LOGIC ;
        J17_1  : in STD_LOGIC ;
        J17_3  : in STD_LOGIC ;
        J17_5  : in STD_LOGIC ;
        J17_7  : in STD_LOGIC ;
        J17_9  : in STD_LOGIC ;
        J17_11 : in STD_LOGIC ;
        J17_13 : in STD_LOGIC ;
        J17_15 : in STD_LOGIC ;
        J17_17 : in STD_LOGIC ;
        J17_19 : in STD_LOGIC ;
        UIO_00 : out STD_LOGIC ;
        UIO_01 : out STD_LOGIC ;
        UIO_02 : out STD_LOGIC ;
        UIO_03 : out STD_LOGIC ;
        UIO_04 : out STD_LOGIC ;
        UIO_05 : out STD_LOGIC ;
        UIO_06 : out STD_LOGIC ;
        UIO_07 : out STD_LOGIC ;
        UIO_08 : out STD_LOGIC ;
        UIO_09 : out STD_LOGIC ;
        UIO_10 : out STD_LOGIC 
    );
end F16_UIOTEST;

architecture Behavioral of F16_UIOTEST is
begin

UIO_10 <= J17_2 ;     
UIO_00 <= J17_1 ; 
UIO_01 <= J17_3 ; 
UIO_02 <= J17_5 ; 
UIO_03 <= J17_7 ; 
UIO_04 <= J17_9 ; 
UIO_05 <= J17_11;
UIO_06 <= J17_13;
UIO_07 <= J17_15;
UIO_08 <= J17_17;
UIO_09 <= J17_19; 
    
end Behavioral;
