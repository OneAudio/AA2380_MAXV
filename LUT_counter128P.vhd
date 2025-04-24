----------------------------------------------------------------------------------
-- The 16/04/2025 O.Narce
-- Avec le signal LRCK (Fs) et le mot de 3 bits qui indique la valeur
-- de FS, on incremente un compteur qui fait un cylce complet (128 valeurs)
-- soit 1500Hz qq soit Fs.
-- 
-- Take 16 LE
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity LUT_counter128P is

    Port (LRCK	    : in  STD_LOGIC; -- lockup table input data address
          DFS		: in  STD_LOGIC_vector(2 downto 0) ;
          LUT_Addr  : buffer  unsigned(6 downto 0) --          
          );
        
end LUT_counter128P;

architecture Behavioral of LUT_counter128P is

signal Div2  : STD_LOGIC ;
signal Div4  : STD_LOGIC ;
signal Div8  : STD_LOGIC ;
signal Div16  : STD_LOGIC ;
signal LUTclk  : STD_LOGIC ;
signal CNTdiv  : unsigned(6 downto 0) ;


begin

-----------------------------------------------------------------------
-- LRCK divider
-----------------------------------------------------------------------
process(LRCK,DFS,CNTdiv,LUTclk,Div2,div4,div8,div16)
begin
    if  rising_edge(LRCK)    then
        CNTdiv <= CNTdiv + 1;
    end if;

    Div2 <=CNTdiv(0);
    Div4 <=CNTdiv(1);
    Div8 <=CNTdiv(2);
    Div16 <=CNTdiv(3);

    case (DFS) is
        when "010" => LUTclk <= LRCK  ; 
        when "011" => LUTclk <= Div2  ;
        when "100" => LUTclk <= Div4  ;
        when "101" => LUTclk <= Div8  ;
        when "110" => LUTclk <= Div16 ;
        when others => null;
    end case;

     if  rising_edge(LUTclk)    then
        LUT_Addr <= LUT_Addr + 1;
    end if;
    
end process;
             
                                   
end Behavioral;                    

















