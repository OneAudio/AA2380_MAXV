-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 17/04/2025	Designer: O.N
-- Design notes, please read : "SPECIF_SPI_LTC2380-24.vhd" and
-- "F1_readADCmulti_ExtClk.xls"
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 122 LE
-- Function F1 :  F1_ReadADCFullSpeed.vhd
--
-- Function to read data from two LT2380-24 ADC using normal mode 
-- at sampling frequency equal to CLKFS.
-- 24 reading/conversion. Fsmax of ADC: 1536kHz
-----------------------------------------------------------------
-- Simulation OK.
-- Le 16/11/2025 fonctionne OK sur ma carte de test AA2380V1
-- avec MCLK=98.304MHz et Fs= 768kHz.
-- Reste à valider avec CLKFS=1.536MHz 
-----------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F1_ReadADCFullSpeed is
--
port(
    -- Inputs Clocks
    MCLK          : in  std_logic  ; -- Master input clock (98.304 MHz or 90.3168 MHz)
    CLKFS         : in  std_logic  ; -- Sampling frequency clock ( 12 to 1536 kHz, square wave)
    nRESET        : in  std_logic  ; -- nRESET input active low
    -- Output ports
    DOUTL	 	  : out std_logic_vector(23 downto 0); --ADC parrallel output data, 24 bits wide CA2, Left channel
    DOUTR	 	  : out std_logic_vector(23 downto 0); --ADC parrallel output data, 24 bits wide CA2, Right channel
    -- ADC i/o control signals
    -- Left Channel ADC control
    BUSYL         : in std_logic  ; -- ADC BUSY signal(active high), Left channel
    SDOL          : in std_logic  ; -- ADC data output, Left channel
    nCNVL         : out std_logic ; -- ADC start conv signal (inverted), Left channel
    SCKL          : buffer std_logic ; -- ADC data read clock, Left channel
    -- Right Channel ADC control
    BUSYR         : in std_logic  ; -- ADC BUSY signal (active high), Right channel
    SDOR          : in std_logic  ; -- ADC data output, Right channel
    nCNVR         : out std_logic ; -- ADC start conv signal (inverted), Right channel
    SCKR          : buffer std_logic -- ADC data read clock, Right channel
);

end F1_ReadADCFullSpeed;

architecture Behavioral of F1_ReadADCFullSpeed is
--
signal CNV      : std_logic ; -- 
signal CLKFSd1  : std_logic ; -- 
signal CLKFSd2  : std_logic ; -- 
signal CLKFSd3  : std_logic ; -- 

signal sBUSYL        : std_logic ; -- synch Left ADC busy flag
signal sBUSYR        : std_logic ; -- synch Right ADC busy flag

signal CNVclk_cnt    : integer range 0 to 32 ; --
signal CNVen_SCK     : std_logic ; --
signal ADC_CLK       : std_logic ; --
signal SDO_Read      : std_logic ; --
signal TCLK23        : integer range 0 to 23 ; --

signal r_DATAR	 	   : std_logic_vector(23 downto 0);
signal r_DATAL	 	   : std_logic_vector(23 downto 0);

----------------------------------------------------------------

begin

--signaux à tester


------------------------------------------------------------------
-- Generate CNV from CLKFS 
-- Both Left and Righ CNV pulse come from CLKFS square wave.
-- CNV pulse width must be 20ns min (low or high),
-- (See LTC2380-24 datasheet timing specs page 5).
-- Here it is 3x MCLK period (about 30ns with 98.304MHz MCLK).
------------------------------------------------------------------
process (MCLK) is
begin
	-- 
	if 	rising_edge(MCLK)	then
      CLKFSd1 <= CLKFS  ; -- first delay
      CLKFSd2 <= CLKFSd1; -- second delay
      CLKFSd3 <= CLKFSd2; -- third delay
	    CNV <= CLKFS and not(CLKFSd3); -- Generate CNV pulse from CLKFS rising edge
	end if;
end process;

-- Inverted CNV for both ADCs because CNS is inverted and resynchronized tp MCLK
-- inside AA2380V1 board.
nCNVL  <= not CNV ;
nCNVR  <= not CNV ;

------------------------------------------------------------------
--  Data read CLock pulse generator
--  24 is the number of reading clock cycle / conversion
-- "MCLK" is clock used to read data 
--
-- Detect when Busy flag of ADC become low (conversion is done),
-- and then start readind data and generate read clock for ADC (ADC_CLK)
------------------------------------------------------------------
ADC_clocks : process (MCLK)
begin
  if    rising_edge(MCLK) then   -- All the process is synchronous to MCLK (Falling edge)
      if  (BUSYR='0' and BUSYL='0')  then -- sBUSY flags must be low.
          -- Increment TCLK23 counter
          if    TCLK23 < 23 then
                TCLK23 <= TCLK23 + 1 ;
          end if;
          -- MCLK cycle counter for ADC clock generation and data reading window
    			if    CNVclk_cnt <= 24 then          -- compare cycle counter value
                CNVclk_cnt <= CNVclk_cnt + 1 ; -- Increment clock cylce counter
    			end if;
          --
          -- ADC SCK pulses clock window
          -- SCK pulse are delayed of 1 MCLK period compare to data reading window
          if      CNVclk_cnt> 0 and  CNVclk_cnt < 24  then
                  CNVen_SCK  <= '1' ; -- Enable window for clock
          else
                  CNVen_SCK  <= '0' ; -- Disable window for clock
          end if;

          -- Data reading window
          -- Data reading window start 1 MCLK period before SCK clock window 
          if      CNVclk_cnt < 24  then
                  SDO_Read  <= '1' ; -- Enable window for clock
          else
                  SDO_Read  <= '0' ; -- Disable window for clock
          end if;
      else
          CNVclk_cnt <= 0   ; -- Reset tclk_cnt when BUSY is high
          CNVen_SCK  <='0'  ; -- sck window always disable when busy active
          TCLK23     <= 0   ; -- Reset TCLK23 counter when BUSY is high
      end if;
  end if;
end process;
ADC_CLK   <= MCLK when CNVen_SCK='1' else '0' ; -- Generate ADC read clock when CNVen_SCK is active

-- Generate SCK for both ADCs
SCKR <= ADC_CLK ; -- 
SCKL <= ADC_CLK ; --
-- ----

------------------------------------------------------------------
-- ADC Data reading Channel L+R
-- Modifié le 11/03/2024    
-- Le signal ADC_CLK vient du MUX.
-- La clock est différente à haute vitesse pour tenir compte du delai
-- d'arrivée des donnée de l'ADC.
------------------------------------------------------------------
ADCserial_read : process(MCLK)
variable idx : integer range 0 to 23; 
begin
 if rising_edge(MCLK) then
    if SDO_Read = '1' then
      -- Data reading only when SDO_Read window is active
      if  (TCLK23 >= 0) and (TCLK23 <= 23) then
      -- Shift data into data registers
      -- at each MCLK rising edge during data reading window
          idx := 23 - TCLK23;
          r_DATAL <= r_DATAL(22 downto 0) & SDOL; -- shift Left channel data
          r_DATAR <= r_DATAR(22 downto 0) & SDOR; -- shift Right channel data
      end if;
    end if;
 end if;
end process ADCserial_read;

------------------------------------------------------------------------------
-- Transfer data register to DOUTL and DOUTR output at each rising edge
-- of CLKFS (Effective output sample frequency)
------------------------------------------------------------------------------
process (CLKFS,nRESET)
begin
  if    nRESET='0' then
        DOUTL <= x"000000"  ; -- Reset DATA if nRESET is active
        DOUTR <= x"000000"  ; -- Reset DATA if nRESET is active
  elsif	rising_edge(CLKFS) then
    		DOUTL <= r_DATAL; -- Left channel data latch
    		DOUTR <= r_DATAR; -- Right channel data latch
	end if;
end process;

end Behavioral ;
