-- ===================================================================
-- Fichier : F16_UIOTEST
-- Description :
--   
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity F16_UIOTEST is
    Port (
        SR_1   : in STD_LOGIC ; -- test signal J12 right side
        SL_2   : in STD_LOGIC ; -- test signal J12 left side
        SL_3   : in STD_LOGIC ; -- ...
        SL_4   : in STD_LOGIC ; -- ...
        SL_5   : in STD_LOGIC ; -- ...
        SL_6   : in STD_LOGIC ; -- ...
        SL_7   : in STD_LOGIC ; -- ...
        SL_8   : in STD_LOGIC ; -- ...
        SL_9   : in STD_LOGIC ; -- ...
        SL_10  : in STD_LOGIC ; -- ...
        SL_11  : in STD_LOGIC ; -- ...
        J12_2  : out STD_LOGIC ; -- test output J12 pin 2 right side
        J12_1  : out STD_LOGIC ; -- test output J12 pin 1 left side
        J12_3  : out STD_LOGIC ; -- test output J12 pin 3 left side 
        J12_5  : out STD_LOGIC ; -- test output J12 pin 5 left side 
        J12_7  : out STD_LOGIC ; -- test output J12 pin 7 left side 
        J12_9  : out STD_LOGIC ; -- test output J12 pin 9 left side
        J12_11 : out STD_LOGIC ; -- test output J12 pin 11 left side
        J12_13 : out STD_LOGIC ; -- test output J12 pin 13 left side    
        J12_15 : out STD_LOGIC ; -- test output J12 pin 15 left side
        J12_17 : out STD_LOGIC ; -- test output J12 pin 17 left side
        J12_19 : out STD_LOGIC   -- test output J12 pin 19 left side
    );
end F16_UIOTEST;

architecture Behavioral of F16_UIOTEST is
begin

J12_2   <= SR_1  ;     
J12_1   <= SL_2  ; 
J12_3   <= SL_3  ; 
J12_5   <= SL_4  ; 
J12_7   <= SL_5  ; 
J12_9   <= SL_6  ; 
J12_11  <= SL_7  ;
J12_13  <= SL_8  ;
J12_15  <= SL_9  ;
J12_17  <= SL_10 ;
J12_19  <= SL_11 ; 
    
end Behavioral;
