-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 17/04/2025	Designer: O.N
-- Design notes, please read : "SPECIF_SPI_LTC2380-24.vhd" and
-- "F1_readADCmulti_ExtClk.xls"
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 143 LE
-- Function F1 :  F1_ReadADCFullSpeed.vhd
--
-- Function to read data from two LT2380-24 ADC using normal mode 
-- at sampling frequency equal to CLKFS.
-- 24 reading/conversion. Fsmax of ADC: 1536kHz
-----------------------------------------------------------------
-- Simulation OK.
-----------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F1_ReadADCFullSpeed is
--
port(
    -- Inputs Clocks
    MCLK          : in  std_logic  ; -- master input clock (98.304 MHz or 90.3168 MHz)
    CLKFS         : in  std_logic  ; -- Sampling frequency clock
    CLEAR          : in  std_logic ; -- clear input active high
    -- Output ports
    DOUTL	 	  : out std_logic_vector(23 downto 0); --ADC parrallel output data, 24 bits wide, Left channel
    DOUTR	 	  : out std_logic_vector(23 downto 0); --ADC parrallel output data, 24 bits wide, Right channel
    --- ADC i/o control signals
    -- Left Channel ADC control
    BUSYL         : in std_logic  ; -- ADC BUSY signal(active high), Left channel
    SDOL          : in std_logic  ; -- ADC data output, Left channel
    nCNVL         : out std_logic ; -- ADC start conv signal (inverted), Left channel
    SCKL          : buffer std_logic ; -- ADC data read clock, Left channel
    -- Right Channel ADC control
    BUSYR         : in std_logic  ; -- ADC BUSY signal (active high), Right channel
    SDOR          : in std_logic  ; -- ADC data output, Right channel
    nCNVR         : out std_logic ; -- ADC start conv signal (inverted), Right channel
    SCKR          : buffer std_logic  -- ADC data read clock, Right channel
    --
    -- Testing purpose IO--
  --
);

end F1_ReadADCFullSpeed;

architecture Behavioral of F1_ReadADCFullSpeed is
--
signal CLKFS_Pulse  : std_logic ; -- 
signal CLKFSd1  : std_logic ; -- 
signal CLKFSd2  : std_logic ; -- 

signal sBUSYL        : std_logic ; -- synch Left ADC busy flag
signal sBUSYR        : std_logic ; -- synch Right ADC busy flag

signal CNVclk_cnt    : integer range 0 to 32 ; --
signal CNVen_SCK     : std_logic ; --
signal ADC_CLK       : std_logic ; --
signal TCLK23        : integer range 0 to 23 ; --

signal r_DATAR	 	 : std_logic_vector(23 downto 0);
signal r_DATAL	 	 : std_logic_vector(23 downto 0);

signal T_CNVen_SCK  : std_logic ; --

--





begin

--- Copy of signals for tests purpose
-- Test_ <=  ; -- TEST 
-- Test_ <=  ; -- TEST
-- Test_ <=  ; -- TEST
-- Test_ <=  ; -- TEST
-- Test_ <=  ; -- TEST
-- Test_ <=  ; -- TEST
-- Test_ <=  ; -- TEST
-- Test_ <=  ; -- TEST
-- Test_ <=  ; -- TEST
-- Test_ <=  ; -- TEST
-- Test_ <=  ; -- TEST

------------------------------------------------------------------
-- Generate CLKFS_Pulse from CLKFS 
------------------------------------------------------------------
process (MCLK,CLKFS,CLKFSd2,CLKFSd1) is
begin
	-- 
	if 	rising_edge(MCLK)	then
		CLKFSd1 <= CLKFS ;
		CLKFSd2 <= CLKFSd1;
	end if;
	CLKFS_Pulse <= CLKFS and not(CLKFSd2);
end process;

------------------------------------------------------------------
-- Both Left and Righ CNV pulse come from nFS pulse
------------------------------------------------------------------
nCNVL  <= not CLKFS_Pulse ;
nCNVR  <= not CLKFS_Pulse ;
------------------------------------------------------------------
--  Data read CLock pulse generator
-- 24 is the number of reading clock cycle / conversion
-- "MCLK" is clock used to read data 
--
-- Detect when Busy flag of ADC become low (conversion is done),
-- and then start readind data and generate read clock for ADC (ADC_CLK)
--
------------------------------------------------------------------
ADC_clocks : process (MCLK,BUSYL,BUSYR,CNVclk_cnt,sBUSYL,sBUSYR)
begin
  ---- Generate synchronous to MCLK BUSY flag (delay 1 period max:10ns@100M)
--   if rising_edge(MCLK) then
--         sBUSYL <=BUSYL ; -- Synch BUSYL to MCLK
--         sBUSYR <=BUSYR ; -- Synch BUSYR to MCLK
--   end if;
  --
--   if  (sBUSYR='0' and sBUSYL='0')  then -- sBUSY flags must be low.
  if  (BUSYR='0' and BUSYL='0')  then -- sBUSY flags must be low.
      if    rising_edge(MCLK) then   -- All the process is synchronous to MCLK
                --
    			if  CNVclk_cnt <= 24 then    -- compare cycle counter value
                    CNVclk_cnt <= CNVclk_cnt + 1 ;      -- Increment clock cylce counter
    			end if;
                --
                -- ADC clock pulse window
                if    CNVclk_cnt>0 and  CNVclk_cnt <= 24  then
                        CNVen_SCK  <= '1' ; -- Enable window for clock
                else
                        CNVen_SCK  <= '0' ; -- Disable window for clock
                end if;
		    --
	    end if;
  else
      CNVclk_cnt <= 0;  -- Reset tclk_cnt when BUSY is high
      -- Added below 11/02/24: (more clean behaviour)
      CNVen_SCK  <= '0' ; -- sck window always disable when busy active
  end if;
end process;

-------------------------------------------------------
-- Combination of enable and clocks with clock enable
-------------------------------------------------------
RDenable : process (MCLK,CNVen_SCK,T_CNVen_SCK,ADC_CLK)
begin
    if   falling_edge(MCLK) then
            T_CNVen_SCK  <= CNVen_SCK  ; -- signal "CNVen_SCK" synch to falling edge of MCLK
    end if;
    -- Now combinations below will not produce glitches !
    ADC_CLK   <= T_CNVen_SCK  and MCLK ;

end process RDenable;

SCKR <= ADC_CLK ; --
SCKL <= ADC_CLK ; --
----

------------------------------------------------------------------

----------------------------------------------------------------------------


------------------------------------------------------------------
---- window to limit the reading of the only 23 first clock cycle AVGen_READ
--------------------------------------------------------------------
-- ** MODIF DU 30/01/24 pour régler le problème lorsque  AVG=0 pas de moyennage 
process (ADC_CLK,TCLK23,CLKFS_Pulse)
begin
  -- the TCLK23 counter is reset outside "AVGen_READ" window.
    if	    CLKFS_Pulse = '1' then --
 		    TCLK23 <= 0	 ;
    elsif   rising_edge(ADC_CLK) and TCLK23 < 23 then --t
            TCLK23 <= TCLK23 + 1 ;
    end if;
end process;

------------------------------------------------------------------
-- ADC Data reading Channel L+R
-- Modifié le 11/03/2024    
-- Le signal ADC_CLK vient du MUX.
-- La clock est différente à haute vitesse pour tenir compte du delai
-- d'arrivée des donnée de l'ADC.
------------------------------------------------------------------
ADCserial_read : process(TCLK23,ADC_CLK)
begin
	if    rising_edge(ADC_CLK) then --stored data of SDO is send to bit 0 to 23 of DATAO
                case TCLK23 is
                when  0  => r_DATAL(23)  <= SDOL ; -- MSB Left channel
                            r_DATAR(23)  <= SDOR ; -- MSB Right channel
                when  1  => r_DATAL(22)  <= SDOL ;
                            r_DATAR(22)  <= SDOR ;
                when  2  => r_DATAL(21)  <= SDOL ;
                            r_DATAR(21)  <= SDOR ;
                when  3  => r_DATAL(20)  <= SDOL ;
                            r_DATAR(20)  <= SDOR ;
                when  4  => r_DATAL(19)  <= SDOL ;
                            r_DATAR(19)  <= SDOR ;
                when  5  => r_DATAL(18)  <= SDOL ;
                            r_DATAR(18)  <= SDOR ;
                when  6  => r_DATAL(17)  <= SDOL ;
                            r_DATAR(17)  <= SDOR ;
                when  7  => r_DATAL(16)  <= SDOL ;
                            r_DATAR(16)  <= SDOR ;
                when  8  => r_DATAL(15)  <= SDOL ;
                            r_DATAR(15)  <= SDOR ;
                when  9  => r_DATAL(14)  <= SDOL ;
                            r_DATAR(14)  <= SDOR ;
                when 10  => r_DATAL(13)  <= SDOL ;
                            r_DATAR(13)  <= SDOR ;
                when 11  => r_DATAL(12)  <= SDOL ;
                            r_DATAR(12)  <= SDOR ;
                when 12  => r_DATAL(11)  <= SDOL ;
                            r_DATAR(11)  <= SDOR ;
                when 13  => r_DATAL(10)  <= SDOL ;
                            r_DATAR(10)  <= SDOR ;
                when 14  => r_DATAL( 9)  <= SDOL ;
                            r_DATAR( 9)  <= SDOR ;
                when 15  => r_DATAL( 8)  <= SDOL ;
                            r_DATAR( 8)  <= SDOR ;
                when 16  => r_DATAL( 7)  <= SDOL ;
                            r_DATAR( 7)  <= SDOR ;
                when 17  => r_DATAL( 6)  <= SDOL ;
                            r_DATAR( 6)  <= SDOR ;
                when 18  => r_DATAL( 5)  <= SDOL ;
                            r_DATAR( 5)  <= SDOR ;
                when 19  => r_DATAL( 4)  <= SDOL ;
                            r_DATAR( 4)  <= SDOR ;
                when 20  => r_DATAL( 3)  <= SDOL ;
                            r_DATAR( 3)  <= SDOR ;
                when 21  => r_DATAL( 2)  <= SDOL ;
                            r_DATAR( 2)  <= SDOR ;
                when 22  => r_DATAL( 1)  <= SDOL ;
                            r_DATAR( 1)  <= SDOR ;
                when 23  => r_DATAL( 0)  <= SDOL ; -- LSB Left channel
                            r_DATAR( 0)  <= SDOR ; -- LSB Right channel
                when others => NULL;
    		end case;
  end if;
end process ADCserial_read;

------------------------------------------------------------------------------
-- Transfer data register to DOUTL and DOUTR output at each rising edge
-- of "FSo" (Effective output sample frequency).
--
------------------------------------------------------------------------------
process (CLKFS,r_DATAL,r_DATAR,CLEAR)
begin
  if    CLEAR='1' then
        DOUTL <= x"000000"  ; -- Reset DATA if OutOfRange detected
        DOUTR <= x"000000"  ; -- Reset DATA if OutOfRange detected
  elsif	rising_edge(CLKFS) then
    		DOUTL <= r_DATAL; -- Left channel data latch
    		DOUTR <= r_DATAR; -- Right channel data latch
	end if;
end process;

end Behavioral ;
