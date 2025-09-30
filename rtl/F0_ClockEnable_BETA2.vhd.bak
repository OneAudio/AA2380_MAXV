--------------------------------------------------------------------------------
-- Ressource : -- https://www.fpga4student.com/2017/08/how-to-generate-clock-enable-signal.html
-- fpga4student.com: FPGA projects, Verilog projects, VHDL projects,
-- Generate clock enable signal instead of creating another clock domain
-- Assume that the input clock : CK98M304
--------------------------------------------------------------------------------
-- O.N - 02/03/2024 -- take 174 LE
--------------------------------------------------------------------------------
-- NOTES sur les différents signaux d'horloges nécessaires :
-- RANGE of clocks:
-- Fso (kHz)     : 12,24,48,96,192,384,768,1536k
-- Fsox128 (MHz) : 1.536,3.072,6.144,12.288,24.576
-- NOTE: No clock if OutOfRange is active.
------------------------------------------
-- Les signaux de clock utiles en fonction de SR/AVG et du mode sont :
-- ReadCLK  --> Signal de clock utiliser pour lire les data renvoyées par L'ADC
-- nFS      --> Signal d'échantillonnage de l'ADC (CNV). Egal à la fréquence audio de sortie (Fso) x La valeur de moyennage (AVG)
-- Fso      --> Signal d'échantillonnage effectif en sortie, soit nFS/AVG.
--
-- Seul ReadCLK a un rapport cyclique de 50%, les autres horloges sont des implusions
-- d'une période de la clock principale (98.304MHz)
-- ==> TOUTES LES HORLOGES GENEREES SONT PARFAITEMENT SYNCHRONE ENTRE ELLES
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 02/03/24 Problèmes à résoudre  :
-- *******************************
-- Tester le module seul en situation réelle et vérifier la synchronicité des horloges.
--
--
--
--
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library  IEEE;
use  IEEE.STD_LOGIC_1164.ALL;
use  ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity  F0_ClockEnable_BETA2  is
port(
    CK98M304      :	in  std_logic   ;          -- Main input clock (98.304MHz)
    SR            :	in integer range 0 to 7 ;  -- Sampling rate 4 bits (12kHz to 1536kHz)
    AVG           :	in integer range 0 to 7 ;  -- Averaging ratio 4 bits (1 to 128)
    AQMODE        :	in std_logic    ;          -- Aquisition mode ; 0= Normal Read - 1= Distributed Reading
    -- Outputs used CLOCKs
    ReadCLK       :	out std_logic   ;  -- clock used to read data (50% duty cycle output)
    nFS           :	out std_logic   ;  -- Fso x AVG ratio (12kHz to 1536kHz) (100ns pulse output)
    Fso           :	out std_logic   ;  -- Effective output sampling rate (12kHz to 1536kHz) (100ns pulse output)
    Fso128        :	out std_logic   ;  -- 128.Fso bit clock for S/PDIF output (100ns pulse output)    
    OutOfRange    :	out std_logic   ; --
    -- test outputs
    -- TSTcounter_ReadCLK :out integer range 1 to 8192 ;
    -- TSTSetCnt_ReadCLK  :out integer range 1 to 8192
    clearAll    :	buffer std_logic   
    );
end  F0_ClockEnable_BETA2;

ARCHITECTURE DESCRIPTION OF F0_ClockEnable_BETA2 IS

signal   counter_nFS     : integer range 1 to 8192 ; -- nFS clock counter
signal   SetCnt_nFS      : integer range 1 to 8192 ; -- nFS counter set value for frequency selection
signal   counter_Fso     : integer range 1 to 8192 ; -- FSo clock counter
signal   SetCnt_Fso      : integer range 1 to 8192 ; -- FSo counter set value for frequency selection
signal   counter_Fso128  : integer range 1 to 64   ; -- FSo128 clock counter
signal   SetCnt_Fso128   : integer range 1 to 64   ; -- FSo128 counter set value for frequency selection

signal   clken_nFS       : std_logic;
signal   clken_FSo       : std_logic;
signal   clken_Fso128    : std_logic;

signal   counter_ReadCLK : integer range 1 to 8192 ; -- ReadCLK clock counter
signal   SetCnt_ReadCLK  : integer range 1 to 8192 ; -- ReadCLK counter set value for frequency selection
signal   clken_ReadCLK   : std_logic;
signal   zReadCLK        : std_logic; 
signal   Bypass          : std_logic;

signal AVGlatch     : integer range 0 to 7; --
signal SRLatch      : integer range 0 to 7; --

begin

--Test signals
--************
--TSTcounter_ReadCLK <= counter_ReadCLK;
--TSTSetCnt_ReadCLK  <= SetCnt_ReadCLK;

------------------------------------------------------------------
-- Generate a clearAll pulse when the AVG or SR value is changed.
-- This pulse is used to clear all counters and allow outputs to be synch.
------------------------------------------------------------------
ChangeDetect : process(CK98M304,AVG,SR)
begin
    if rising_edge(CK98M304)    then
        AVGlatch <= AVG ; -- record previous  state
        SRLatch  <=  SR ;
        if  (AVGlatch /= AVG) or (SRLatch /= SR)  then -- compare previous with new state. 
            clearAll <= '1'; -- set clearAll to high
        else
            clearAll <= '0'; -- set clearAll to low
        end if;
    end if;
end process  ChangeDetect;
------------------------------------------------------------------

------------------------------------------------------------------
-- Set SetCnt_Fso, SetCnt_nFS and SetCnt_Fso128 counters limit
-- values depending on SR and AVG values.
-- This allow to select effective desired output frequencies
------------------------------------------------------------------
process(AVG,SR,SetCnt_nFS,SetCnt_Fso)
begin
    -- Loaded counter limit for Fso ouput frequency from sampling rate "SR"
    case (SR) is
        when 0 => SetCnt_Fso <= 8192 ; -- 12kHz ()
        when 1 => SetCnt_Fso <= 4096 ; --
        when 2 => SetCnt_Fso <= 2048 ; --
        when 3 => SetCnt_Fso <= 1024 ; --
        when 4 => SetCnt_Fso <= 512  ; --
        when 5 => SetCnt_Fso <= 256  ; --
        when 6 => SetCnt_Fso <= 128  ; --
        when 7 => SetCnt_Fso <= 64   ; -- 1536k
    end case ;
    --
    -- Loaded counter limit for nFS ouput frequency from "AVG+SR" value
    case (AVG+SR) is
        when 0 => SetCnt_nFS <= 8192 ; -- 12kHz ()
        when 1 => SetCnt_nFS <= 4096 ; --
        when 2 => SetCnt_nFS <= 2048 ; --
        when 3 => SetCnt_nFS <= 1024 ; --
        when 4 => SetCnt_nFS <= 512  ; --
        when 5 => SetCnt_nFS <= 256  ; --
        when 6 => SetCnt_nFS <= 128  ; --
        when 7 => SetCnt_nFS <= 64   ; -- 1536k
        when others => SetCnt_nFS <= 1;
    end case ;
    --
    -- Loaded counter limit for Fso128 ouput frequency (S/DIF out). No signal if SR>192kHz
    if (SR) < 5 then
        SetCnt_Fso128 <= SetCnt_Fso/128 ; 
    else
        SetCnt_Fso128 <= 1 ;
    end if;
    --
    -- Generate OutOfRange signal to detect wrong settings (SR+AVG must be always <8 to have nFS =< 1536kHz)
    if (SR+AVG) > 7 then -- condition to detect OutOfRange mode
        OutOfRange <= '1' ; -- detect bad SR/AVG combination => value is OutOfRange
    else
        OutOfRange <= '0' ; -- SR/AVG in the range.
    end if;
    --
end process;
------------------------------------------------------------------
-- ReadClock frequency selection.
-- This is the clock used to read ADC DATA.
------------------------------------------------------------------
process(AQMODE,SetCnt_nFS,SR,AVG,Bypass,zReadCLK,CK98M304)
begin
    if  AQMODE='0' then    
        -- Normal aquisition mode (24 data samples read in one nFS cycle)
        SetCnt_ReadCLK <= SetCnt_nFS / 64 ; -- Read clock is 64x time faster than nFS frequency
    else
        -- Distributed reading aquisition mode of ADC (LTC2380-24)
        -- (24 data samples read in the whole Fso cycle) 
        case SR is
            when 0 => SetCnt_ReadCLK <= 8 ; -- 12.288 MHz (= 98.304/8)
            when 1 => SetCnt_ReadCLK <= 8 ; -- 12.288 MHz (= 98.304/8)
            when 2 => SetCnt_ReadCLK <= 8 ; -- 12.288 MHz (= 98.304/8)
            when 3 => SetCnt_ReadCLK <= 8 ; -- 12.288 MHz (= 98.304/8)
            when 4 => SetCnt_ReadCLK <= 4 ; -- 24.576 MHz (= 98.304/4)
            when 5 => SetCnt_ReadCLK <= 4 ; -- 24.576 MHz (= 98.304/4)
            when 6 => SetCnt_ReadCLK <= 2 ; -- 49.152 MHz (= 98.304/2)
            when others => SetCnt_ReadCLK <= 2 ; -- 
        end case;
    end if;
    -- Generate Bypass conditions where ReadClock is the main fast clock (98.304MHz).
    -- This is the ReadCLK mux command signal to choose direct (bypass) or divided clock.
    if  (AQMODE='1' and SR>6) or (AQMODE='0' and (AVG+SR)>6 ) then
        Bypass <= '1';-- clock bypasse on
    else
        Bypass <= '0';-- clock bypasse off
    end if;
    -- Mux to choose where Readclock come from.
    case Bypass is
        when '0' => ReadCLK <= zReadCLK ; -- ReadClock is generated by divide counter
        when '1' => ReadCLK <= CK98M304 ; -- ReadClock is directly fast main clock
    end case;
    --
end process;

------------------------------------------------------------------
-- Counters incremented by main master clock (98.304MHz)
-- 
------------------------------------------------------------------
process(CK98M304)
begin
  if(rising_edge(CK98M304)) then
    ---- nFS clock counter (100ns pulse output)
        if  clearAll='1' then
            counter_nFS <= 1 ;
            clken_nFS <= '1';
        else
            if(counter_nFS =SetCnt_nFS ) then
                clken_nFS <= '1';
                counter_nFS <= 1 ;
            else
                clken_nFS <= '0';
                counter_nFS <= counter_nFS + 1 ;
            end if;
        end if;
    ---- FSo clock counter (100ns pulse output)
        if  clearAll='1' then
            counter_Fso <= 1 ;
            clken_FSo <= '1';
        else
            if(counter_Fso =SetCnt_Fso ) then
                clken_FSo <= '1';
                counter_Fso <= 1 ;
            else
                clken_FSo <= '0';
                counter_Fso <= counter_Fso + 1 ;    
            end if;
        end if;
    ---- FSo128 clock counter (100ns pulse output)
        if  clearAll='1' then
            counter_Fso128 <= 1 ;
            clken_FSo128 <= '1';
        else
            if(counter_Fso128 =SetCnt_Fso128 ) then
                clken_FSo128 <= '1';
                counter_Fso128 <= 1 ;
            else
                clken_FSo128 <= '0';
                counter_Fso128 <= counter_Fso128 + 1 ;    
            end if;
        end if;
        --
        -- Generate 50% du cycle ReadCLK signal.
        -- This is required because ADC data are shifted on rising edge
        -- and read on falling edge f this clock.
        counter_ReadCLK <= counter_ReadCLK + 1 ; -- counter ++
        if  (counter_ReadCLK < SetCnt_ReadCLK/2 ) then
            clken_ReadCLK <= '1';-- Clock set to 1
        else
            if counter_ReadCLK = SetCnt_ReadCLK   then
                clken_ReadCLK <= '1'; -- Clock set to 1
                counter_ReadCLK <= 1 ;-- counter reset
            else
                clken_ReadCLK <= '0';-- Clock set to 0
            end if;
        end if;
        --
    end if;
end process;
    
------------------------------------------------------------------
-- Use the same clock and the slow clock enable signal above 
-- to drive another part of the design to avoid domain crossing issues
------------------------------------------------------------------
process(CK98M304,clken_nFS,clken_FSo,clken_FSo128)
begin
    if(rising_edge(CK98M304)) then
  --
        if(clken_nFS = '1') then
            nFS <= '1'; --
        else
            nFS <= '0'; --
        end if;
    --
        if(clken_FSo = '1') then
            FSo <= '1'; --
        else
            FSo <= '0'; --
        end if;
    --
        if(clken_FSo128 = '1') then
            Fso128 <= '1'; --
        else
            Fso128 <= '0'; --
        end if;
    --
        if(clken_ReadCLK = '1') then
            zReadCLK <= '1'; --
        else
            zReadCLK <= '0'; --
        end if;
    end if;
    
end process;

END DESCRIPTION;