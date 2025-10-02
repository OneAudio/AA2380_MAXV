-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 23/12/20	Designer: O.N
-- Design notes, please read : "SPECIF_SPI_LTC2380-24.vhd" and
-- "F1_readADC_multimodes.xls"
-- Take 33 LE.
-----------------------------------------------------------------
-- This module is to emulate LTC2380-24 ADC signals
-- behaviour for testing purpose only.
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

entity F20_EmulateADC is
--
port(
  -- Inputs ports

  MCLK	    : in std_logic  ; -- Master clock
  DATADC        : in std_logic_vector(23 downto 0)  ; -- Signal to be send at SDO serial out (Emulated ADC data)
  DATA_Latch    : in std_logic  ; --effective output sampling frequency (needed to update data shift register )
  -- ADC signals
  CNV           : in std_logic ; -- ADC start conv signal (rising_edge)
  SCK           : in std_logic ; -- ADC data read clock
  BUSY          : out std_logic  ; -- BUSY output (conversion in progress, fixed duration of 400ns)
  SDO           : out std_logic   -- ADC data output
  -- Test output only
);

end F20_EmulateADC;

architecture Behavioral of F20_EmulateADC is
--

signal  Busy_count  : integer range 0 to 63 ;
signal  BUSY_on     : std_logic ;
signal  Busy_end    : std_logic ;
signal  SRDATA      : std_logic_vector(23 downto 0);

begin

--- Copy of signals for tests purpose


------------------------------------------------------------------
-- Function to emulate busy of DAC for simulation purpose
-- Generate 400 ns pulse when rising_edge of CNV (start conversion)
------------------------------------------------------------------
Emulate_Busy : process(CNV,MCLK,Busy_end,Busy_on)
begin
      if      Busy_end='1'  then
              BUSY_on <= '0'  ; --
      elsif   rising_edge(CNV) then
              BUSY_on <= '1'  ; -- Busy set to high as soon rising edge of CNV pulse
      end if;
      --
      if    rising_edge(MCLK) then
            if   BUSY_on='1' then
              Busy_count <= Busy_count + 1 ; -- increment counter
                if    Busy_count= 35  then -- 35x10ns =350ns pulse width (real measured Busy time=350ns, Datasheet max=391ns)
                      Busy_end <= '1'  ; -- engage reset of busy signal when Busy_count value is reached.
                else
                      Busy_end <= '0'  ; -- no reset
                end if;
            else
                Busy_count  <=  0  ; -- reset counter
                Busy_end    <= '0' ; -- no busy reset
            end if;
      end if;
BUSY <= BUSY_on ;-- send to busy output


end process Emulate_Busy ;
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
