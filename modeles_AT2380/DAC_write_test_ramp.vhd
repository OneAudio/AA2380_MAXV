-----------------------------------------------------------------
-- O.Narce le 01/09/2017
-- Programme de test pour carte débitmètre Ultrasons // E2343v2
-- Take xxx LE
-- Permet le pilotage des deux DACs LTC1590 et génère une rampe 0-10V
-- par pas de 1V/s
--
--LTC1590 is dual output 12 bits DAC.
-- 24 clocks pulses for full DACS write
-- CS is active low
-- Data are read on rising edge of sck
--
-- 12 bits value for 0 to -Vref (5V) 4096 steps
-- So, for 32 steps that give 128 LSB for each step
--
-----------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
 
 entity DAC_write_test_ramp is
 

  Port ( 
          Clk          : in  std_logic; -- 16 MHz master clock 
          Speed        : in  std_logic; -- Select DAC speed output 1Hz or 100Hz
          DAC_SPI_SCK  : out  std_logic; -- DACs clock
          DAC_SPI_SDI  : out  std_logic; -- DACs DATAIN 
          DAC_SPI_nCS1 : out  std_logic; -- DAC1 chip select 
          DAC_SPI_nCS2 : out  std_logic; -- DAC2 chip select
          DATA         : out  std_logic_vector (11 downto 0) -- test output
    );
 end DAC_write_test_ramp;
 
architecture Test of DAC_write_test_ramp is

signal count1 : integer range 0 to 79 :=0 ; -- counter for 10kHz clock output from 16MHz " VALEUR = 799"
signal count2 : integer range 0 to 49 :=0 ; -- counter for 100Hz clock output from 10kHz   " VALEUR = 99"
signal count3 : integer range 0 to 49 :=0 ; -- counter for 1Hz clock output from 100Hz
signal clkSAR : std_logic ; -- 10kHz DAC clock
signal clk100Hz: std_logic ; -- 100Hz DAC clock
signal clk1Hz: std_logic ; -- 10Hz DAC clock
signal clkDAC : std_logic ; -- DAC value increment clock
signal reg    : std_logic_vector (23 downto 0);
signal DATA1  : unsigned (11 downto 0) := x"000" ; -- start to 0
signal DATA2  : unsigned (11 downto 0) := x"7FF" ; -- start to 2047 (180° shift)
signal SEND   : std_logic :='1' ;
signal SENDING   : std_logic := '0' ;
signal nCS    : std_logic :='1' ; 
signal DAC1n2 : std_logic :='0' ; 

begin


--- test outputs
DATA <= std_logic_vector(DATA1) ;

------------------------------------------------------
-- generate DAC SPI clock and 1Hz and 100Hz clock
------------------------------------------------------
process (Clk,clkSAR,clk100Hz,clk1Hz)
begin
  if  rising_edge (clk) then
      if  count1 = 799 then 
          clkSAR  <= not clkSAR ; -- 10kHz clock
          count1 <= 0 ;
      else
          count1 <= count1 +1 ;
      end if;      
  end if;
  if  rising_edge (clkSAR) then
      if  count2 = 49 then 
          clk100Hz  <= not clk100Hz ; -- 100Hz clock
          count2 <= 0 ;
      else
          count2 <= count2 +1 ;
      end if;      
  end if;
  if  rising_edge (clk100Hz) then
      if  count3 = 49 then 
          clk1Hz  <= not clk1Hz ; -- 1Hz clock
          count3 <= 0 ;
      else
          count3 <= count3 +1 ;
      end if;      
  end if;
end process;
           
------------------------------------------------------
-- generate 2 x 12 bits words with 128 lsb increment
-- and updated at clkDAC rate (1 or 100Hz depending on
-- Speed input)
------------------------------------------------------
process (clkDAC,DATA1,DATA2,speed,clk1Hz,clk100Hz)
begin
  if  Speed = '0' then
      clkDAC <= clk1Hz;
  else 
      clkDAC <= clk100Hz;
  end if;
  if  rising_edge (clkDAC) then
      DATA1 <= DATA1 + 128 ; 
      DATA2 <= DATA2 + 128 ;
  end if;
end process;


process(clkSAR, SEND)     
variable counter : integer range 0 to 23 := 0;      
begin     
    if falling_edge(clkSAR) then
--    VALUE <= std_logic_vector(DATA2 & DATA1) ; -- 
        if    SEND = '1' then 
              reg <= std_logic_vector(DATA2) & std_logic_vector(DATA1); -- add control bit
              counter := 0;
              nCS <= '0';
              SENDING <= '1';
              SEND <= '0';                 
        elsif SENDING = '1' then               
              reg <= reg(22 downto 0) & '0';          
        if    counter = 23 then       
              counter := 0;  
              nCS <= '1';
              DAC1n2 <= not DAC1n2; -- DAC 1 / 2 permutation at each convertion
              SENDING <= '0';
              SEND <= '1';
        else
              counter := counter + 1;
        end if;
     end if;        
  end if;       
end process;
     
DAC_SPI_SCK  <= clkSAR AND SENDING;
DAC_SPI_SDI  <= reg(23);
DAC_SPI_nCS1 <= nCS or DAC1n2 ;
DAC_SPI_nCS2 <= nCS or not DAC1n2 ;


end Test;


