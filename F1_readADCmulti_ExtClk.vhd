-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 06/03/24	Designer: O.N
-- Design notes, please read : "SPECIF_SPI_LTC2380-24.vhd" and
-- "F1_readADCmulti_ExtClk.xls"
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 248 LE
-- Function F1 :  F1_readADCmulti_ExtClk.vhd
-- Function to read data from two LT2380-24 ADC using any of the two modes :
-- #############################################################################
-- 1) NormalRead        **  24 reading/conversion Fs: 12kHz...1536kHz
--                      **  nFS=(Fso x AVG) , 24 reading in one conversion
-- 3) DistributedRead   **  nFS=(FsoxAVG) , 24 reading distributed in (N-1)
--                          conversion cycles. Fs: 12kHz...1536kHz
-- #############################################################################
-- New version forked from "F1_readADC_multimodes.vhd" and modified to work with
-- the new external module "F0_ClockEnable_BETA2.vhd".
-- All clock come now from this external module that are really synch between them.
-- 
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F1_readADCmulti_ExtClk is
--
port(
    -- Inputs Clocks
    MCLK          : in  std_logic; -- master input clock (98.304 MHz or 90.3168 MHz)
    ReadCLK       :	in std_logic   ;  -- clock used to read data (50% duty cycle output)
    nFS           :	in std_logic   ;  -- Fso x AVG ratio (12kHz to 1536kHz) (100ns pulse output)
    Fso           :	in std_logic   ;  -- Effective output sampling rate (12kHz to 1536kHz) (100ns pulse output)
    OutOfRange    :	in std_logic   ; --    
    Clear         :	in std_logic   ; -- Clear input (set all counters to 0 for synch)
    -- Inputs ports
    AVG           : in  integer range 0 to 7; -- Averaging ratio 4 bits, (1,2,4,8,16,32,64,128, ...)
    AQMODE        : in  std_logic; -- ADC acquisision mode 2 bits (00=NormalRead,01=DistributedRead,others TBD)
    --ITLV          : in  std_logic; -- Allow simultaneous acquisision or interleaved (0=simultaneous 1= interleaved)
    -- Output ports
    DOUTL	 	    : out std_logic_vector(23 downto 0); --ADC parrallel output data, 24 bits wide, Left channel
    DOUTR	 	      : out std_logic_vector(23 downto 0); --ADC parrallel output data, 24 bits wide, Right channel
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
    SCKR          : buffer std_logic ; -- ADC data read clock, Right channel
    --
    -- Testing purpose IO--
    --r_DATAL       : buffer std_logic_vector(23 downto 0);
    Test_CK_cycle	  : out integer range 0 to 24;
    Test_ADC_CLK      : out std_logic;
    Test_ADC_SHIFT    : out std_logic;
    Test_AVGen_READ   : out std_logic;
    Test_CNVen_SHFT   : out std_logic;
    Test_AVGen_SCK    : out std_logic;
    Test_CNVen_SCK    : out std_logic ;
    Test_CNVclk_cnt   : out integer range 0 to 32 ;
    Test_AVG_count    : out integer range 0 to 127;
    Test_TCLK23       : out integer range 0 to 23;
    Test_TCNVen_SCK   : out std_logic ;
    Test_TCNVen_SHFT  : out std_logic
  --
);

end F1_readADCmulti_ExtClk;

architecture Behavioral of F1_readADCmulti_ExtClk is
--
--
--
signal CK_cycle     : integer range 0 to 24 :=24;

signal sBUSYL        : std_logic ; -- synch Left ADC busy flag
signal sBUSYR        : std_logic ; -- synch Right ADC busy flag

signal CNVclk_cnt    : integer range 0 to 32 ; --
signal CNVen_SHFT    : std_logic ; --
signal CNVen_SCK     : std_logic ; --
signal ADC_CLK       : std_logic ; --
signal ADC_SHIFT     : std_logic ; --
signal AVGen_SCK     : std_logic ; --
signal AVGen_READ    : std_logic ; --
signal TCLK23        : integer range 0 to 23 ; --

signal r_DATAR	 	 : std_logic_vector(23 downto 0);
signal r_DATAL	 	 : std_logic_vector(23 downto 0);

signal AVG_count    : integer range 1 to 128 ; -- sample average counter
signal dAVG         : integer range 1 to 128 ; --

signal T_CNVen_SCK  : std_logic ; --
signal T_CNVen_SHFT : std_logic ; --
signal ResetAVGread : std_logic ; --


signal AVGlatch     : integer range 0 to 7; --
signal SRLatch      : integer range 0 to 7; --
--

begin

--- Copy of signals for tests purpose
Test_CK_cycle     <= CK_cycle;  -- TEST
Test_ADC_CLK      <= ADC_CLK  ; -- TEST
Test_ADC_SHIFT    <= ADC_SHIFT ; -- TEST
Test_AVGen_READ   <= AVGen_READ ; -- TEST
Test_CNVen_SHFT   <= CNVen_SHFT ; -- TEST
Test_AVGen_SCK    <= AVGen_SCK ; -- TEST
Test_CNVen_SCK    <= CNVen_SCK ; -- TEST
Test_CNVclk_cnt   <= CNVclk_cnt ; -- TEST
Test_AVG_count    <= AVG_count  ; -- TEST
Test_TCLK23       <= TCLK23     ; -- TEST

Test_TCNVen_SCK   <= T_CNVen_SCK  ; -- TEST
Test_TCNVen_SHFT  <= T_CNVen_SHFT ; -- TEST

------------------------------------------------------------------

-- -- (Fso x AVG must be equal or lower than 1536 kHz).
-- @ Fso=1536kHz no averaging
-- @ Fso= 12 kHz x128 maximum averaging.
-- RANGE :
-- SR : 000 to 111 for sampling rate from 12kHz to 1536kHz
-- AVG: 000 to 111 for averaging ratio from x1 to x128
------------------------------------------------------------------
RangeCheck : process(AVG)
begin
  -- COnvert binary AVG value to real Decimal average value.
  case  AVG   is
        when 0 => dAVG  <= 1   ; -- 1 sample average
        when 1 => dAVG  <= 2   ; --
        when 2 => dAVG  <= 4   ; --
        when 3 => dAVG  <= 8   ; --
        when 4 => dAVG  <= 16  ; --
        when 5 => dAVG  <= 32  ; --
        when 6 => dAVG  <= 64  ; --
        when 7 => dAVG  <= 128 ; -- 128 sample average
  end case ;
  --
end process RangeCheck;


------------------------------------------------------------------
-- Both Left and Righ CNV pulse come from nFS pulse
------------------------------------------------------------------
nCNVL  <= not nFS ;
nCNVR  <= not nFS ;
------------------------------------------------------------------
-- En fonction de AQMODE(Normal ou distributed Read), selectionne
-- le nombre de la clock de lecture des données de l'ADC.
-- 
-- NOTES :
-- a) Dans le cas du mode Normal, ReadCLK est toujours égale à 64 x nFS.
-- b) Dans le cas du mode DIstributed, le nombre de coups clock par
-- conversion  dépend de la valeur de la moyenne AVG.
------------------------------------------------------------------
ReadCLK_Cycle : process(AVG,AQMODE)
begin
    -- Set number of clock cycles for Normal and DIstributed Read modes.
    if  AQMODE = '1' then -- Distributed read Mode
        case AVG is
            -- New corrected table values to allow correct reading when nFS become high
            -- The number of clock cycle has been reduced.(02/2024)
            when 0       => CK_cycle <= 24; -- 24 cycles if no averaging
            when 1       => CK_cycle <= 24; -- 24 clock cycles
            when 2       => CK_cycle <= 8 ; -- 8 clock cycles
            when 3       => CK_cycle <= 4 ; -- 4  clock cycles 
            when 4       => CK_cycle <= 2 ; -- 2  clock cycles
            when others  => CK_cycle <= 1 ; -- otherwise 1 clock cycles
        end case;
    else
         CK_cycle <= 24; -- always 24 clocks cycles in NormalRead mode.
    end if;
    --
    --
end process ReadCLK_Cycle;

------------------------------------------------------------------
--  Data read CLock pulse generator
-- "CK_cycle" is the number of reading clock cycle / conversion
-- "ReadCLK" is clock used to read data (depend on Mode,SR and AVG)
--
-- Detect when Busy flag of ADC become low (conversion is done),
-- and then start readind data and generate read clock for ADC (ADC_CLK)
-- and shift register (ADC_SHIFT).
-- In AQU mode "0" (Normal read),
--
------------------------------------------------------------------
ADC_clocks : process (MCLK,BUSYL,BUSYR,CK_cycle,ReadCLK,CNVclk_cnt,sBUSYL,sBUSYR)
begin
  ---- Generate synchronous to MCLK BUSY flag (delay 1 period max:10ns@100M)
  if rising_edge(MCLK) then
        sBUSYL <=BUSYL ; -- Synch BUSYL to MCLK
        sBUSYR <=BUSYR ; -- Synch BUSYR to MCLK
  end if;
  --
  if  (sBUSYR='0' and sBUSYL='0')  then -- sBUSY flags must be low.
      if    rising_edge(ReadCLK) then   -- All the process is synchroous to ReadCLK
                --
    			if    CNVclk_cnt <= CK_cycle then    -- compare cycle counter with CK_cycle value
    				    CNVclk_cnt <= CNVclk_cnt + 1 ;      -- Increment clock cylce counter
    			end if;
                --
                -- ADC clock pulse window
    			if    CNVclk_cnt>0 and  CNVclk_cnt <= CK_cycle  then
    				    CNVen_SCK  <= '1' ; -- Enable window for clock
    			else
    				    CNVen_SCK  <= '0' ; -- Disable window for clock
    			end if;
                --
    			-- ADC read data clock window (for shift register data read)
    			if    CNVclk_cnt < (CK_cycle) then
    				    CNVen_SHFT <= '1' ; -- Enable serial data read window
    			else
    				    CNVen_SHFT <= '0' ; -- Disable serial data read window
    			end if;
		    --
	    end if;
  else
      CNVclk_cnt <= 0;  -- Reset tclk_cnt when BUSY is high
      -- Added below 11/02/24: (more clean behaviour)
      CNVen_SHFT <= '0' ; -- shift window always disable when busy active
      CNVen_SCK  <= '0' ; -- sck window always disable when busy active
  end if;
end process;

-------------------------------------------------------
-- Combination of enable and clocks with clock enable
-------------------------------------------------------
RDenable : process (ReadCLK,AVGen_SCK,CNVen_SHFT,CNVen_SCK,AVGen_READ,T_CNVen_SHFT,T_CNVen_SCK)
begin
    -- To avoid glitchs when combinate clock & pulse synch to same clock,
    -- when must use "clock-enable" module below.
    if      AVGen_SCK='0'   then -- Condition to reset ADC_CLK and ADC_SHIFT outside AVGen_SCK window
            T_CNVen_SCK <= '0';
            T_CNVen_SHFT<= '0';
    elsif   falling_edge(ReadCLK) then
            T_CNVen_SCK  <= CNVen_SCK  ; -- signal "CNVen_SCK" synch to falling edge of ReadCLK
            T_CNVen_SHFT <= CNVen_SHFT ; -- signal "CNVen_SHFT" synch to falling edge of ReadCLK
    end if;
    -- Now combinations below will not produce glitches !
    ADC_CLK   <= T_CNVen_SCK  and ReadCLK and AVGen_SCK ;
    ADC_SHIFT <= T_CNVen_SHFT and ReadCLK and AVGen_READ ;
end process RDenable;

SCKR <= ADC_CLK ; --
SCKL <= ADC_CLK ; --
----

------------------------------------------------------------------
-- Distributed read average cycles count
-- AQMODE = 0 =NormalRead and , 1= DistributedRead mode
-- This process generate 2 signals :
-- AVGen_SCK  --> Windows to enable clock pulses to ADC only the last conversion cycle
-- AVGen_READ --> Windows to enable ADC data read, depend on number of pulse/conv: "CK_cycle"
-- NOTE: This process is disable if OutOfRange is active (bad SR/AVG combination).
--
-- NOTE DE FONCTIONNEMENT :
--1) "AVGen_READ"
-- Ce signal est actif pendant le nombre de conversion necessaire pour
-- lire les 24 données présente pendant les 24 coups de clock de SCK.
-- Il sert au registre à décalage qui fait la conversion série/parrallème des DATA.
--
--2) "AVGen_SCK"
-- En mode "Normal" (AQMODE=0) ce signal est actif uniquement pendant
-- la première conversion d'un cycle de moyennage.(Fig-17 p20 datasheet)
-- En mode "DistributedRead" (AQMODE=1), pour que la moyenne soit conservé
-- entre les conversions, il faut des coups d'horloge sur toutes les conversions
-- sauf la dernière pour mettre à zéro la moyenne.
-- Donc, le signal est actif tout le temps SAUF la dernière conversion de la moyenne.
--
----------------------------------------------------------------------------
AVG_cycles : process(nFS,AQMODE,dAVG,AVG_count,OutOfRange,Clear)
begin
    -- Signals and counter are reset if outofrange, or if clear input is active.
    -- Clear input is active when SR or AVG are new value. It is required
    -- to ensure synchronous averaging cycle with FSo pulses.
    if      OutOfRange='1' or Clear='1' then
            AVGen_SCK   <= '0'  ; --
            AVGen_READ  <= '0'  ; --
            AVG_count   <=  1   ; --
    else
        if rising_edge(nFS) then
            --
            if  AVG_count < dAVG then  --  compare average counter and AVG input value
                AVG_count <=AVG_count +1; -- increment counter
            else
                AVG_count <= 1		; -- reset counter
            end if;
            --
            -- Generate ADC clock window : Disable clock only the last conversion for averaging
            if    AQMODE='1'  then  -- Mode "DistributedRead"
                  if  AVG_count = (dAVG - 1) then
                      AVGen_SCK <= '0' 	; -- disable ADC clk for last avg count (end of averaging)
                  else
                      AVGen_SCK <= '1' 	; -- enable clk
                  end if;
            else                    -- Mode "Normal"
                  if  AVG_count = dAVG then
                      AVGen_SCK <= '1' 	; -- enable ADC clk only for fisrt conversion cycle
                  else
                      AVGen_SCK <= '0' 	; -- enable clk
                  end if;
            end if;

            -- Generate enable data read window depending n number o fclock
            if  AVG_count=dAVG  or AVG_count<(24/CK_cycle) then
                AVGen_READ <= '1' 	; -- enable reading for only 4x6 clocks count
            else
                AVGen_READ <= '0' 	; -- disable reading
            end if; 
        end if;
    end if;

end process AVG_cycles;

------------------------------------------------------------------
---- window to limit the reading of the only 23 first clock cycle AVGen_READ
--------------------------------------------------------------------
-- ** MODIF DU 30/01/24 pour régler le problème lorsque  AVG=0 pas de moyennage 
process (AVGen_READ,ADC_CLK,TCLK23,nFS,AVG,ResetAVGread)
begin
  -- the TCLK23 counter is reset outside "AVGen_READ" window.
    if      AVG=0 then
            ResetAVGread <= not nFS ;
    else
            ResetAVGread <= AVGen_READ	;
    end if;

    if	ResetAVGread = '0' then --
 		      TCLK23 <= 0	 ;
    elsif   rising_edge(ADC_CLK) and TCLK23 < 23 then
        TCLK23 <= TCLK23 + 1 ;
    end if;

end process;

------------------------------------------------------------------
-- ADC Data reading Channel L+R
--
------------------------------------------------------------------
ADCserial_read : process(ADC_SHIFT,TCLK23)
begin
	if    falling_edge(ADC_SHIFT) then --stored data of SDO is send to bit 0 to 23 of DATAO
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
-- If "OutOfRange" signal output is 0 if enable input is low
------------------------------------------------------------------------------
process (FSo,r_DATAL,r_DATAR,OutOfRange)
begin
  if    OutOfRange='1' then
        DOUTL <= x"000000"  ; -- Reset DATA if OutOfRange detected
        DOUTR <= x"000000"  ; -- Reset DATA if OutOfRange detected
  elsif	rising_edge(Fso) then
    		DOUTL <= r_DATAL; -- Left channel data latch
    		DOUTR <= r_DATAR; -- Right channel data latch
	end if;
end process;

end Behavioral ;
