-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 15/12/20	Designer: O.N
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
  DOUTR	 	      : out std_logic_vector(23 downto 0); --ADC parrallel output data, 24 bits wide, Right channel
  --- ADC i/o control signals
  -- Left Channel ADC control
  BUSYL         : in std_logic  ; -- ADC BUSY signal(active high), Left channel
  SDOL          : in std_logic  ; -- ADC data output, Left channel
  nCNVL         : out std_logic ; -- ADC start conv signal (inverted), Left channel
  SCKL          : out std_logic ; -- ADC data read clock, Left channel
  -- Right Channel ADC control
  BUSYR         : in std_logic  ; -- ADC BUSY signal (active high), Right channel
  SDOR          : in std_logic  ; -- ADC data output, Right channel
  nCNVR         : out std_logic ; -- ADC start conv signal (inverted), Right channel
  SCKR          : out std_logic ; -- ADC data read clock, Right channel
  -- S/PDIF clock (derived from MCLK)
  Fsox128	    	: out std_logic ; -- 128 x Fso output clock for SPDIF (6.144M to 24.576M)
  --
  -- Testing purpose IO--
  TEst_OutOfRange : out integer range 0 to 1;
  Test_SpdifOK  : out integer range 0 to 1;
  Test_ReadCLK	 : out std_logic ;
  Test_CK_cycle	 : out integer range 0 to 24;
  Test_SEL_RDCLK : out integer range 0 to 15;
  Test_SEL_nFS  : out integer range 0 to 7 ;
  Test_CNVA : out std_logic

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

signal CNVclk_cnt    : integer range 0 to 23 ; --
signal CNVen_SHFT    : std_logic ; --
signal CNVen_SCK     : std_logic ; --
signal ADC_CLK       : std_logic ; --
signal ADC_SHIFT     : std_logic ; --
signal AVGen_SCK     : std_logic ; --
signal AVGen_READ    : std_logic ; --
signal TCLK23        : integer range 0 to 23 ; --

signal r_DATAL	 	   : std_logic_vector(23 downto 0);
signal r_DATAR	 	   : std_logic_vector(23 downto 0);

signal AVG_count    : integer range 0 to 127 ; -- sample average counter
signal dAVG         : integer range 1 to 128 ; --


begin

Test_SpdifOK  <= SpdifOK     ; -- TEST
TEst_OutOfRange <= OutOfRange  ; -- TEST
Test_SEL_nFS <= SEL_nFS ; -- TEST
Test_ReadCLK <= ReadCLK ; -- TEST
Test_CK_cycle <= CK_cycle;  -- TEST
Test_SEL_RDCLK <= SEL_RDCLK ; -- TEST
Test_CNVA <= CNVA ;
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
  if    SR+(7-AVG) > 7 then -- condition to detect OutOfRange mode
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
------------------------------------------------------------------
MCLK_div : process(MCLK,AVG,MCLK_divider,SEL_nFS,SR)
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
    --
end process MCLK_div ;

------------------------------------------------------------------
-- En fonction de AQMODE(Normal ou distributed Read), selectionne
-- la valeur de la clock de lecture des données de l'ADC.
-- NOTES :
-- a) Dans le cas du mode Normal, ReadCLK est toujours égale à 64 x nFS.
-- b) Dans le cas du mode DIstributed, le nombre de coups clock par
--    et le nombre de coups de clock par conversion est toujours de 24.
--    conversion  dépend de la valeur de la moyenne AVG.
--    ReadCLK dépend de Fso et
------------------------------------------------------------------
ReadCLK_SEL : process(MCLK,MCLK_divider,AVG,SEL_nFS,SEL_RDCLK,AQMODE)
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
    if  AVG= 0 then
        SEL_RDCLK <= SEL_nFS + (7-AVG) -1 ; -- substract 1 to get same result as  with AVG=1..
    else
        SEL_RDCLK <= SEL_nFS + (7-AVG)    ; -- result value = 0 to 14
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
            when others => ReadCLK <= '0'           ;
        end case;
   else                      -- Mode Normal
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
end process ReadCLK_SEL;


------------------------------------------------------------------
-- Generate CNV pulse to initiate conversion start of ADC.
-- The conversion of both ADC can be simultaneous or interleav
-- depending on ITLV input (not yet done !!)
-- Tcnv_high must be > 20ns. (here pulse is 8 periods of MCLK=80ns)
------------------------------------------------------------------
CNV_pulse : process(MCLK,nFs,ITLV,CNVA,CNVstop,MCLK_divider)
begin
    --
    if    CNVstop= '1' then
          CNVA      <= '0'  ; --
    elsif rising_edge(nFs) then -- nFS is the real conversion clock of ADCs
          CNVA      <= '1'  ; --
    end if;
    --
    if    rising_edge(MCLK) then
          if   CNVA='1' then
            countCNV <= countCNV + 1 ; --
              if    countCNV=7  then
                    CNVstop <= '1'  ; --
              else
                    CNVstop <= '0'  ; --
              end if;
          else
              countCNV <= 0 ;
              CNVstop <= '0'  ; --
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
------------------------------------------------------------------
ADC_clocks : process (MCLK,BUSYL,BUSYR,CK_cycle,ReadCLK,CNVclk_cnt,sBUSYL,sBUSYR)
begin
  ---- Generate synchronous to MCLK BUSY flag
  if rising_edge(MCLK) then
        sBUSYL <=BUSYL ; -- Synch BUSYL to MCLK
        sBUSYR <=BUSYR ; -- Synch BUSYR to MCLK
  end if;
  --
  if  (sBUSYR='0' and sBUSYL='0')  then -- sBUSY flags must be low.
      if    rising_edge(ReadCLK) then -- All the process is synchroous to ReadCLK
          --
    			if    CNVclk_cnt < (CK_cycle + 1) then    -- compare cycle counter with CK_cycle value
    				    CNVclk_cnt <= CNVclk_cnt + 1 ;      -- Increment clock cylce counter
    			end if;
    			-- ADC clock pulse window
    			if    CNVclk_cnt > 0  and CNVclk_cnt < (CK_cycle + 1) then
    				    CNVen_SCK  <= '1' 	; -- Enable window for clock
    			else
    				    CNVen_SCK  <= '0' 	; -- Disable window for clock
    			end if;
    			-- ADC read data clock window
    			if    CNVclk_cnt < CK_cycle then
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

-- Combination of enable and clocks
ADC_CLK    <= ReadCLK and AVGen_SCK  and CNVen_SCK   ; -- ADC clock pulse
ADC_SHIFT  <= ReadCLK and AVGen_READ and CNVen_SHFT  ; -- ADC shift read clock

SCKR <= ADC_CLK ; --
SCKL <= ADC_CLK ; --
----

------------------------------------------------------------------
-- Distributed read average cycles count
-- AQMODE = 0 =NormalRead and , 1= DistributedRead mode
------------------------------------------------------------------
AVG_cycles : process(nFS,AQMODE,dAVG,AVG_count)
begin
    if rising_edge(nFS) then
        --
        if  AVG_count < dAVG then  --  compare average counter and AVG input value
            AVG_count <=AVG_count +1; -- increment coounter
        else
            AVG_count <= 1 		; -- reset counter
        end if;
        -- Generate ADC clock window
        if  AVG_count = (dAVG - 1) then
            AVGen_SCK <= '0' 	; -- disable ADC clk_div4 for last avg count (end of averaging)
        else
            AVGen_SCK <= '1' 	; -- enable clk_div4
        end if;
        -- Generate enable data read window depending n number o fclock pulse/cycle
        if  AVG_count < (24/CK_cycle)  then
            AVGen_READ <= '1' 	; -- enable reading for only 4x6 clocks count
        else
            AVGen_READ <= '0' 	; -- disable reading
        end if;
    end if;

end process AVG_cycles;

------------------------------------------------------------------
---- window to limit the reading of the only 23 first clock cycle
--------------------------------------------------------------------
process (CNVen_SCK,ADC_CLK,TCLK23)
begin
	if	    CNVen_SCK = '0' then
		      TCLK23 <= 0			;
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
-- of Fso (LRCK) signal output is 0 if enable input is low
------------------------------------------------------------------------------
process (FSo,r_DATAL,r_DATAR)
begin
	if	  rising_edge(FSo) then
    		DOUTL <= r_DATAL; -- Left channel data latch
    		DOUTR <= r_DATAR; -- Right channel data latch
	end if;
end process;


end Behavioral ;
