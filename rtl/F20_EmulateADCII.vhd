-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 23/12/20	Designer: O.N
-- Design notes, please read : "SPECIF_SPI_LTC2380-24.vhd" and
-- "F1_readADC_multimodes.xls"
-- Take 24 LE.
-----------------------------------------------------------------
-- This module is to emulate LTC2380-24 ADC signals
-- behaviour for testing purpose only.
-- F20_EmulateADCII is without busy signal)
--
-- Update from 14/02/2024 :
-- The input DATA_Latch must be used to latch input data before 
-- to be sent on SDO serial output (accordingly to number of sample 
-- averaged).
--
------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F20_EmulateADCII is
--
port(
  -- Inputs ports

  DATADC        : in std_logic_vector(23 downto 0)  ; -- Signal to be send at SDO serial out (Emulated ADC data)
  DATA_Latch    : in std_logic  ; --effective output sampling frequency (needed to update data shift register )
  -- ADC signals
  CNV           : in std_logic ; -- ADC start conv signal (rising_edge)
  SCK           : in std_logic ; -- ADC data read clock
  SDO           : out std_logic   -- ADC data output
  -- Test output only
);

end F20_EmulateADCII;

architecture Behavioral of F20_EmulateADCII is
--


signal  SRDATA      : std_logic_vector(23 downto 0);

begin

--- Copy of signals for tests purpose

------------------------------------------------------------------
-- A partir de donnée d'un bus parrallele 24 bits,génére des valeurs
-- en série à la place de SDO.
------------------------------------------------------------------
Emulate_SDO : process(DATADC,SCK,SRDATA,DATA_Latch)
begin
      -- Shift register update  
      if    DATA_Latch='1' then
            SRDATA <= DATADC; --Latch parallel input data when DATA_Latch is high
      elsif rising_edge(SCK)   then             
            SRDATA <= SRDATA(22 downto 0) & '0'  ; -- décalage d'un bit à chaque front montant de SCK
      end if;
SDO <= SRDATA(23)  ; -- The MSB of SRDATA is the output of serial shift register 

end process Emulate_SDO ;

end Behavioral ;
