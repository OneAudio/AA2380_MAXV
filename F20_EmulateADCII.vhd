-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 29/01/24	Designer: O.N
-- F20_EmulateADCII
-----------------------------------------------------------------
-- This module is to emulate SDO output of LTC2380-24 ADC
-- for testing purpose.
--
-- Update from 23/12/2020 :
-- Auto reset shift register if no clock betweeen two CNV pulse,
-- or if 24 SCK clock shift are done (in any number of conversion).
-- Take 38 LE.
------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F20_EmulateADCII is
--
port(
  -- Inputs ports

  --MCLK	 	    : in std_logic  ; -- Master clock
  DATAi         : in std_logic_vector(23 downto 0)  ; -- Signal to be send at SDO serial out (Emulated ADC data)
  -- ADC signals
  CNV           : in std_logic ; -- ADC start conv signal (rising_edge)
  SCK           : in std_logic ; -- ADC data read clock
  --BUSY          : in std_logic  ; -- BUSY signal from ADC (conversion in progress ~400ns)
  SDO           : out std_logic ;  -- ADC data output
  -- Test output only
  tst_CLEAR_REG     : out std_logic ;
  tst_CLEAR_MOY     : out std_logic ;
  tst_SCK_count    : out integer range 0 to 32
);

end F20_EmulateADCII;

architecture Behavioral of F20_EmulateADCII is
--

signal  Busy_count  : integer range 0 to 63 ;
signal  BUSY_on     : std_logic ;
signal  Busy_end    : std_logic ;
signal  SRDATA      : std_logic_vector(23 downto 0);
signal  SSCK        : std_logic ;

signal  QA          : std_logic ;
signal  QB         : std_logic ;
signal  CLEAR_REG   : std_logic ;
signal  CLEAR_MOY   : std_logic ;

signal  CLS_count   : std_logic ;
signal  CLS        : std_logic ;

signal SCK_count    : integer range 0 to 32 ;

begin

--- Copy of signals for tests purpose
tst_CLEAR_REG <= CLEAR_REG  ; -- TEst output
tst_CLEAR_MOY <= CLEAR_MOY  ; -- TEst output
tst_SCK_count  <= SCK_count ; -- TEst output


------------------------------------------------------------------
-- Function to emulate busy of DAC for simulation purpose
-- Generate 400 ns pulse when rising_edge of CNV (start conversion)
------------------------------------------------------------------
-- Emulate_Busy : process(CNV,MCLK,Busy_end,Busy_on)
-- begin
--       if      Busy_end='1'  then
--               BUSY_on <= '0'  ; --
--       elsif   rising_edge(CNV) then
--               BUSY_on <= '1'  ; --
--       end if;
--       --
--       if    rising_edge(MCLK) then
--             if   BUSY_on='1' then
--               Busy_count <= Busy_count + 1 ; --
--                 if    Busy_count= 35  then -- 35x10ns = 350ns pulse width
--                       Busy_end <= '1'  ; --
--                 else
--                       Busy_end <= '0'  ; --
--                 end if;
--             else
--                 Busy_count  <=  0  ;
--                 Busy_end    <= '0' ;
--             end if;
--       end if;
-- BUSY <= BUSY_on ;


-- end process Emulate_Busy ;
------------------------------------------------------------------
--- MODULE 2 SEULEMENT POUR TEST------------------------------------
------------------------------------------------------------------
-- A partir de donnée d'un bus parrallele 24 bits,
-- génére des valeurs
-- en série à la place de SDO (valeurs série des ADC).
------------------------------------------------------------------
Emulate_SDO : process(CNV,DATAi,SCK,SRDATA,SSCK,CLEAR_REG,QA,QB,CLEAR_MOY,SCK_count)
begin
      -- Reset if no SCK betweeb 2 CNV conversion pulse.
      if    SCK='1'            then
            QA  <= '0';
            QB  <= '0';
      elsif rising_edge(CNV)   then
            QA  <= '1'  ;
            QB  <= QA   ;
      end if;
      CLEAR_MOY <=  QB and CNV  ;
      --
      -- Check number of SCK shift
      if      CNV='1' and SCK_count=23 then
               SCK_count <= 0   ;
               CLEAR_REG <= '0'  ;
      elsif    rising_edge(SCK) then
            if    SCK_count=23  then
                  CLEAR_REG <= '1'  ;
            else
                  SCK_count <= SCK_count +1 ;
            end if;
      end if;

      -- Shift register update  
      if    CLEAR_MOY='1' or  CLEAR_REG='1' then
            SRDATA <= DATAi;
      elsif rising_edge(SCK)   then
            SRDATA <= SRDATA(22 downto 0) & '0'  ; -- décalage d'un bit à chaque front montant de SCK
      end if;
SDO <= SRDATA(23)  ; -- Le MSB de xDOSL est la sortie série

end process Emulate_SDO ;


end Behavioral ;
