-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 21/12/20	Designer: O.N
-- Design notes, please read : "SPECIF_SPI_LTC2380-24.vhd" and
-- "F1_readADC_multimodes.xls"
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take (65) LE.
-- Function F1 :  F1_readADC_multimodes.vhd
-- Function to read data from two LT2380-24 ADC using any of the two modes :
-- #############################################################################
-- 1) NormalRead        **  24 reading/conversion Fs: 12kHz...1536kHz
--                      **  nFS=(Fso x AVG) , 24 reading in one conversion
-- 3) DistributedRead   **  nFS=(FsoxAVG) , 24 reading distributed in (N-1)
--                          conversion cycles. Fs: 12kHz...1536kHz
-- #############################################################################
-- NOTES : TBD
--
------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F1_readADC_multimodes is
--
port(
  -- Inputs ports
  MCLK          : in  std_logic; -- master input clock (98.304 MHz or 90.3168 MHz)
  SR            : in  integer range 0 to 7 ; -- selected output effetive sampling rate 4 bits (...,12,24,48,96,192,384,768,1536 kHz)
  AVG           : in  integer range 0 to 7; -- Averaging ratio 4 bits, (1,2,4,8,16,32,64,128, ...)
  AQMODE        : in  std_logic; -- ADC acquisision mode 2 bits (00=NormalRead,01=DistributedRead,others TBD)
  ITLV          : in  std_logic; -- Allow simultaneous acquisision or interleaved (0=simultaneous 1= interleaved)
  -- Output ports
  Fso		        : buffer  std_logic ; -- effective output sampling rate (12,24,48,96,192,384,768,1536 kHz)
  nFS			      : buffer std_logic ; -- ADC sampling rate unaveraged (equal Fso * averaging ratio)
  DOUTL	 	      : out std_logic_vector(23 downto 0); --ADC parrallel output data, 24 bits wide, Left channel
  r_DATAL       : buffer std_logic_vector(23 downto 0);
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
  -- S/PDIF clock (derived from MCLK)
  Fsox128	    	: out std_logic ; -- 128 x Fso output clock for SPDIF (6.144M to 24.576M)
  --
  -- Testing purpose IO--
  TEst_OutOfRange   : out integer range 0 to 1;
  Test_SpdifOK      : out integer range 0 to 1;
  Test_ReadCLK	    : out std_logic ;
  Test_CK_cycle	    : out integer range 0 to 24;
  Test_SEL_RDCLK    : out integer range 0 to 15;
  Test_SEL_nFS      : out integer range 0 to 7 ;
  Test_CNVA         : out std_logic;
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

end F1_readADC_multimodes;

architecture Behavioral of F1_readADC_multimodes is
--
signal  OutOfRange  : integer range 0 to 1 :=0  ; --
signal  SpdifOK     : integer range 0 to 1 :=0  ; --
--
signal MCLK_divider : unsigned (12 downto 0)    ; -- counter for clock divivier. Allow down to 12kHz clock (from 98.304M)
signal SEL_nFS      : integer range 0 to 7 :=0  ;
--
signal CK_cycle     : integer range 0 to 24 :=24;
signal SEL_RDCLK    : integer range 0 to 15 :=0 ;
signal ReadCLK      : std_logic ;
--
signal CNVA         : std_logic ; --
signal CNVstop      : std_logic ; --
signal countCNV     : integer range 0 to 7 ; --

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

--signal r_DATAL	 	   : std_logic_vector(23 downto 0);
signal r_DATAR	 	   : std_logic_vector(23 downto 0);

signal AVG_count    : integer range 1 to 128 ; -- sample average counter
signal dAVG         : integer range 1 to 128 ; --

signal T_CNVen_SCK  : std_logic ; --
signal T_CNVen_SHFT : std_logic ; --
signal ResetAVGread : std_logic ; --

--

begin

--- Copy of signals for tests purpose
Test_SpdifOK      <= SpdifOK     ; -- TEST
TEst_OutOfRange   <= OutOfRange  ; -- TEST
Test_SEL_nFS      <= SEL_nFS ; -- TEST
Test_ReadCLK      <= ReadCLK ; -- TEST
Test_CK_cycle     <= CK_cycle;  -- TEST
Test_SEL_RDCLK    <= SEL_RDCLK ; -- TEST
Test_CNVA         <= CNVA ; -- TEST
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
-- Generate the flag "OutOfRange" .
-- This flag indicate that combination of sampling Rate and averaging
-- ratio is not allowed.
-- -- (Fso x AVG must be equal or lower than 1536 kHz).
-- @ Fso=1536kHz no averaging
-- @ Fso= 12 kHz x128 maximum averaging.
-- RANGE :
-- SR : 000 to 111 for sampling rate from 12kHz to 1536kHz
-- AVG: 000 to 111 for averaging ratio from x1 to x128
------------------------------------------------------------------
RangeCheck : process(SR,AVG)
begin
  --
  if    (SR+AVG) > 7 then -- condition to detect OutOfRange mode
        OutOfRange <= 1 ; -- detect bad SR/AVG combination => value is OutOfRange
  else
        OutOfRange <= 0 ; -- SR/AVG in the range.
  end if;
  -- COnvert binary AVG value to real Decimal average value.
  case  AVG   is
        when 0 => dAVG  <= 1   ; --
        when 1 => dAVG  <= 2   ; --
        when 2 => dAVG  <= 4   ; --
        when 3 => dAVG  <= 8   ; --
        when 4 => dAVG  <= 16  ; --
        when 5 => dAVG  <= 32  ; --
        when 6 => dAVG  <= 64  ; --
        when 7 => dAVG  <= 128 ; --
  end case ;
  --
end process RangeCheck;

------------------------------------------------------------------
-- Detect S/PDIF out of range if Fso become > 192k.
-- (No S/PDIF link allow more than 192K stream)
------------------------------------------------------------------
SpdifCheck : process(SR)
begin
  if  SR<5 then         -- Sampling Rate selected equal or below 192kHz
      SpdifOK <= 1 ; -- detect bad SR/AVG combinattion
  else
      SpdifOK <= 0 ; -- SR/AVG in the range.
  end if;
end process SpdifCheck;
------------------------------------------------------------------
-- Generate nFs Fso and Fsox128 clocks.
--
-- RANGE ouf clocks:
-- Fso (kHz)     : 12,24,48,96,192,384,768,1536k
-- Fsox128 (MHz) : 1.536,3.072,6.144,12.288,24.576
-- NOTE: No clock if OutOfRange is active.
------------------------------------------------------------------
MCLK_div : process(MCLK,AVG,MCLK_divider,SEL_nFS,SR,OutOfRange)
begin
    -- DivideMCLK
    if  rising_edge(MCLK)  then
        MCLK_divider <= MCLK_divider + 1 ; -- increment MCLK_divider counter
    end if;
    --
    -- Compute AVG + Fso value to select nFS frequency value.
    -- SEL_nFS= 0 to 7 for nFS= 12k to 1536kHz
    SEL_nFS <= AVG + SR ; -- sum of AVG and Fso values
    --
    -- Select nFS Clock value from calculated SEL_nFS
    if    OutOfRange= 1  then
          nFS     <= '0' ; -- No nFS clock
          FSo     <= '0' ; -- No FSo clock
          Fsox128 <= '0' ; -- No Fsox128 clock
    else
        case  SEL_nFS is
              when 0 => nFS <= MCLK_divider(12) ; -- 12kHz ()
              when 1 => nFS <= MCLK_divider(11) ; --
              when 2 => nFS <= MCLK_divider(10) ; --
              when 3 => nFS <= MCLK_divider(9) ; --
              when 4 => nFS <= MCLK_divider(8) ; --
              when 5 => nFS <= MCLK_divider(7) ; --
              when 6 => nFS <= MCLK_divider(6) ; --
              when 7 => nFS <= MCLK_divider(5) ; -- 1536k
        end case ;
        -- Select FSo Clock value from SR input
        case  SR   is
              when 0 => FSo     <= MCLK_divider(12); -- 12kHz
                        Fsox128 <= MCLK_divider(5) ; --
              when 1 => FSo     <= MCLK_divider(11); --
                        Fsox128 <= MCLK_divider(4) ; --
              when 2 => FSo     <= MCLK_divider(10); --
                        Fsox128 <= MCLK_divider(3) ; --
              when 3 => FSo     <= MCLK_divider(9) ; --
                        Fsox128 <= MCLK_divider(2) ; --
              when 4 => FSo     <= MCLK_divider(8) ; --
                        Fsox128 <= MCLK_divider(1) ; --
              when 5 => FSo     <= MCLK_divider(7) ; --
                        Fsox128 <= '0'             ; --
              when 6 => FSo     <= MCLK_divider(6) ; --
                        Fsox128 <= '0'             ; --
              when 7 => FSo     <= MCLK_divider(5) ; -- 1536 kHz
                        Fsox128 <= '0'             ; --
        end case ;
    end if;
    --
end process MCLK_div ;

------------------------------------------------------------------
-- En fonction de AQMODE(Normal ou distributed Read), selectionne
-- la valeur de la clock de lecture des données de l'ADC.
-- NOTES :
-- a) Dans le cas du mode Normal, ReadCLK est toujours égale à 64 x nFS.
-- b) Dans le cas du mode DIstributed, le nombre de coups clock par
--    conversion  dépend de la valeur de la moyenne AVG.
--    ReadCLK dépend de Fso et le nombre de coups de clock par conversion est toujours de 24.
-- Si le signal OutOfRange est actif pas de signal de clock en sortie
-- (combinaison SR/AVG non compatible)
------------------------------------------------------------------
ReadCLK_SEL : process(MCLK,MCLK_divider,AVG,SEL_nFS,SEL_RDCLK,AQMODE,OutOfRange)
begin
    -- Set number of clock cycles for Normal and DIstributed Read modes.
    if  AQMODE = '1' then -- Distributed read Mode
        case AVG is
            when 0       => CK_cycle <= 24; -- 24 cycles if no averaging
            when 1       => CK_cycle <= 24; -- 24 clock cycles
            when 2       => CK_cycle <= 12; -- 12 clock cycles
            when 3       => CK_cycle <= 6 ; -- 6  clock cycles
            when others  => CK_cycle <= 3 ; -- otherwise 3 clock cycles
        end case;
    else
         CK_cycle <= 24; -- always 24 clocks cycles in NormalRead mode.
    end if;
    --
    --
    -- Select ReadCLK values for boths Modes at any SR/AVG combination.
    -- ReadCLK is disable if OutOfRange is active (bad SR/AVG combination)
    if  OutOfRange= 1  then
        ReadCLK   <= '0'  ; -- No ReadCLK is OutOfRange active
        SEL_RDCLK <=  0   ; -- reset SEL_RDCLK
    else
        if AVG= 0 then
            SEL_RDCLK <= SEL_nFS + (7-AVG) - 1 ; -- substract 1 to get same result as  with AVG=1.. 
            -- AVG + SR = SEL_nFS donc SEL_RDCLK=  AVG + SR + 7 - AVG - 1 = SR + 6 !!!! ?
        else
            SEL_RDCLK <= SEL_nFS + (7-AVG)    ; -- result value = 0 to 14
            -- AVG + SR = SEL_nFS donc SEL_RDCLK=  AVG + SR + 7 - AVG = SR + 7 !!!! ?
        end if;
        --
        if  AQMODE = '1' then    -- Distributed read Mode
            case  SEL_RDCLK is
                when 13 => ReadCLK <= MCLK             ; -- 98.304M
                when 12 => ReadCLK <= MCLK_divider(0)  ; -- 49.152M
                when 11 => ReadCLK <= MCLK_divider(1)  ; -- 24.576M
                when 10 => ReadCLK <= MCLK_divider(2)  ; -- 12.288M
                when 9  => ReadCLK <= MCLK_divider(3)  ; -- 6.144M
                when 8  => ReadCLK <= MCLK_divider(4)  ; -- 3.072M
                when 7  => ReadCLK <= MCLK_divider(5)  ; -- 1.536M
                when 6  => ReadCLK <= MCLK_divider(4)  ; -- 0.768M ** added the 30/01/24 for proper work at avg=0 and aqmode=1
                when others => ReadCLK <= '0'           ;
            end case;
       else                      -- Mode Normal.  (Note SEL_nFS= AVG + SR)
            case  SEL_nFS is
              when 0 => ReadCLK <= MCLK_divider(6)  ; -- 0.768K
              when 1 => ReadCLK <= MCLK_divider(5)  ; -- 1.536M
              when 2 => ReadCLK <= MCLK_divider(4)  ; -- 3.072M
              when 3 => ReadCLK <= MCLK_divider(3)  ; -- 6.144M
              when 4 => ReadCLK <= MCLK_divider(2)  ; -- 12.288M
              when 5 => ReadCLK <= MCLK_divider(1)  ; -- 24.576M
              when 6 => ReadCLK <= MCLK_divider(0)  ; -- 49.152M
              when 7 => ReadCLK <= MCLK             ; -- 98.304M
            end case;
        end if;
      end if;
end process ReadCLK_SEL;


------------------------------------------------------------------
-- Generate CNV pulse to initiate conversion start of ADC.
-- The conversion of both ADC can be simultaneous or interleav
-- depending on ITLV input (not yet done !!)
-- Tcnv_high must be > 20ns. (here pulse is 8 periods of MCLK=80ns)
-- CNV pulses are Disable if OutOfRange is active.
------------------------------------------------------------------
CNV_pulse : process(MCLK,nFs,ITLV,CNVA,CNVstop,MCLK_divider,OutOfRange)
begin
    --
    if    CNVstop= '1' or OutOfRange= 1 then -- No CNV pulse if OutOfRange  is active.
          CNVA      <= '0'  ; -- Reset CNVA
    elsif rising_edge(nFs) then -- nFS is the real conversion clock of ADCs
          CNVA      <= '1'  ; -- Set CNVA synch to nFS
    end if;
    --
    if    rising_edge(MCLK) then
          if   CNVA='1' then
            countCNV <= countCNV + 1 ; --
              if    countCNV=7  then    -- CNV pulse duration in number of MCLK periods
                    CNVstop <= '1'  ; -- Set CNV high
              else
                    CNVstop <= '0'  ; -- Set CNV low
              end if;
          else
              countCNV <= 0  ;-- Reset CNV counter
              CNVstop <= '0' ; --Set CNV low
          end if;
    end if;
    nCNVL <= not CNVA ;--
    nCNVR <= not CNVA ;--
end process CNV_pulse;

------------------------------------------------------------------
-- AU desssus OK !
--
--
-- Au dessous NON TESTE !
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

           -- *** PARTIE A RETRAVAILLER ***
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
  end if;
end process;

-------------------------------------------------------
-- Combination of enable and clocks with clock enable
-------------------------------------------------------
RDenable : process (ReadCLK,AVGen_SCK,CNVen_SHFT,CNVen_SCK,AVGen_READ,T_CNVen_SHFT,T_CNVen_SCK)
begin
    -- To avoid glitchs when combinate clock & pulse synch to same clock,
    -- when must use "clock-enable" module below.
    if  falling_edge(ReadCLK) then
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
AVG_cycles : process(nFS,AQMODE,dAVG,AVG_count,OutOfRange)
begin
    if  OutOfRange= 1  then
        AVGen_SCK   <= '0'  ; --
        AVGen_READ  <= '0'  ; --
        AVG_count   <=  1   ; --
    else
        if rising_edge(nFS) then
            --
            if  AVG_count < dAVG then  --  compare average counter and AVG input value
                AVG_count <=AVG_count +1; -- increment coounter
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
-- process (AVGen_READ,ADC_CLK,TCLK23)
-- begin
--   -- the TCLK23 counter is reset outside "AVGen_READ" window.
-- 	if	    AVGen_READ = '0' then -- Replace "CNVen_SCK"
-- 		      TCLK23 <= 0			;
-- 	elsif   rising_edge(ADC_CLK) and TCLK23 < 23 then
--           TCLK23 <= TCLK23 + 1 ;
-- 	end if;
-- end process;

-- ** MODIF DU 30/01/24 pour régler le problème lorsque  AVG=0 pas de moyennage 
process (AVGen_READ,ADC_CLK,TCLK23,CNVA,AVG,ResetAVGread)
begin
  -- the TCLK23 counter is reset outside "AVGen_READ" window.
    if      AVG=0 then
            ResetAVGread <= not CNVA ;
    else
            ResetAVGread <= AVGen_READ	;
    end if;

    if	ResetAVGread = '0'  then --
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
  if    OutOfRange= 1 then
        DOUTL <= x"000000"  ; -- Reset DATA if OutOfRange detected
        DOUTR <= x"000000"  ; -- Reset DATA if OutOfRange detected
  elsif	rising_edge(FSo) then
    		DOUTL <= r_DATAL; -- Left channel data latch
    		DOUTR <= r_DATAR; -- Right channel data latch
	end if;
end process;

end Behavioral ;
