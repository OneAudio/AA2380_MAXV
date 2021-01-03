-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 03/01/21	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 5 LE.
-- Function F2 "B" :  F2_leds_decoders_B.vhd
-- It decode signals and drive Leds & relays accordingly.
--_______________________________________________________________
--     NOTE : CH1 IS RIGHT PCB SIDE / CH2 IS LEFT PCB SIDE
--_______________________________________________________________
-- AA2380PAN PCB leds positions:
--       _____
--      |A B C| <-- Leds x3 D9-D8-D7 (Sample rate)
--      |D E F| <-- Leds x3 D6-D5-D4 (Average ratio)
--      |			|
--      |  *  | <-- Rotary encoder
--      |G H I| <-- Leds x3 D3-D2-D1 (modes)
--      |_____|
--
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F2_leds_decoders_B is
--
port(
	-- Input signals
	CLKSLOW		: in  std_logic ; -- slow clock input for synchronisation
	Ready			: in  std_logic ; -- Ready signal (1s startup delay)
	SR				: in  std_logic_vector(2 downto 0) ; -- sampling rate (12k to 1536k)
	AVG				: in  std_logic_vector(2 downto 0) ; -- averaging ratio (1x to 128x)
	SE_DIFF		: in  std_logic ; -- Single-ended / Différential mode
	HBWon			: in  std_logic ; -- High bandwidth filter mode
	AQMODE		: in  std_logic ; -- acquisition mode indicator (normal or distributed read)
	OutOfRange: in  std_logic ; -- Ready signal (1s startup delay)
	--LEDS (AA2380PAN)
	PAN_A			: out std_logic ;	-- D9 CPLD pin 83, AA2380PAN led A (top left)
	PAN_B			: out std_logic ;	-- D8 CPLD pin 81, AA2380PAN led B
	PAN_C			: out std_logic ;	-- D7 CPLD pin 77, AA2380PAN led C
	PAN_D			: out std_logic ;	-- D6 CPLD pin 89, AA2380PAN led D
	PAN_E			: out std_logic ;	-- D5 CPLD pin 86, AA2380PAN led E
	PAN_F			: out std_logic ;	-- D4 CPLD pin 84, AA2380PAN led F
	PAN_G			: out std_logic ;	-- D3 CPLD pin 76, AA2380PAN led G
	PAN_H			: out std_logic ;	-- D2 CPLD pin 78, AA2380PAN led H
	PAN_I			: out std_logic ;	-- D1 CPLD pin 82, AA2380PAN led I (bottom right)
	--
	-- 2 front tricolors SMD Leds (AA2380)
	-- All outputs are inverted, leds are active low ("n" prefix)
	nLeft_Gre		: out std_logic ;	-- D34 CPLD pin 52, Left  channel tricolors led indicator (Green)
	nLeft_Red		: out std_logic ;	-- D34 CPLD pin 58, Left  channel tricolors led indicator (Red)
	nLeft_Blu		: out std_logic ;	-- D34 CPLD pin 57, Left  channel tricolors led indicator (Blue)
	nRight_Gre	: out std_logic ;	-- D30 CPLD pin 49, Right channel tricolors led indicator (Green)
	nRight_Red	: out std_logic ;	-- D30 CPLD pin 51, Right channel tricolors led indicator (Red)
	nRight_Blu	: out std_logic ;	-- D30 CPLD pin 50, Right channel tricolors led indicator (Blue)
	--
	-- RELAYS for select input mode (single-ended;SE_DIFF='0'  or differential;SE_DIFF='1')
	-- and for analog input filter bandwidth (38.4kHz;HBWon='0' or 384kHz;HBWon='1')
	FLTBW_L			: out std_logic ;	-- Ch1 (Left) analog filter mode
	SE_DIFF_L		: out std_logic ;	-- Ch1 (Left) single-ended input mode
	FLTBW_R			: out std_logic ;	-- Ch2 (Right) analog filter mode
	SE_DIFF_R		: out std_logic 	-- Ch2 (Right) single-ended input mode
);

end F2_leds_decoders_B;

architecture Behavioral of F2_leds_decoders_B is


begin

------------------------------------------------------------------
-- Sampling frequency decoding 12k(000) to 1536k(111)
-- 3 upper leds of AA2380PAN (Leds are active high)
-- (Note : Signals of leds D9/D7 are crossed !)
------------------------------------------------------------------
PAN_A <= SR(2) ; -- MSB
PAN_B <= SR(1) ; --
PAN_C <= SR(0) ; -- LSB
-----------------------------------------------------------------
-- Averaging ratio decoding x1(000) to x128 (111)
-- 3 middle leds of AA2380PAN (Leds are active high)
------------------------------------------------------------------
PAN_D <= AVG(2) ; -- MSB
PAN_E <= AVG(1) ; --
PAN_F <= AVG(0) ; -- LSB
----------------------------------------------------------------
-- Indicate Ready, SEnDIFF and HBWon
-- 3 bottom leds of AA2380PAN PCB (Leds are active high)
------------------------------------------------------------------
PAN_G <= AQMODE		; -- Led for Ready signal
PAN_H <= SE_DIFF	; -- Led for Single-Ended / Différential mode
PAN_I <= HBWon		; -- Led for high bandwidth mode
------------------------------------------------------------------
-- TRicolors LED (Red+Green+Blue)
-- COLORS LEDS STATUS :
-----------------------
-- RED  : Blink if OutOfRange active, others colors off.
-- BLUE : if high-bandwidth input filter mode active (384k)
-- GREEN: if Single-ended mode active
-- CYAN : if both high-bandwidth and Single-ended modes active (blue+green)
------------------------------------------------------------------
-- Both red leds are on when calib is in progress
-- All these leds are active LOW !

process(Ready,HBWon,SE_DIFF,OutOfRange,CLKSLOW) is
begin
	if 	Ready= '0'	then
		nLeft_Gre 	<= '1'  ; -- leds all off
		nLeft_Red 	<= '1'  ; -- leds all off
		nLeft_Blu 	<= '1'  ; -- leds all off
		nRight_Gre 	<= '1'  ; -- leds all off
		nRight_Red 	<= '1'  ; -- leds all off
		nRight_Blu 	<= '1'  ; -- leds all off
	else
		-- Left Channel LED
		nLeft_Gre		<= 	not (SE_DIFF and not OutOfRange)	; --(Green)
		nLeft_Red		<= 	not (OutOfRange and CLKSLOW )			; --(red)
		nLeft_Blu		<= 	not (HBWon 	 and not OutOfRange)	; --(Blue)
		-- Right channel LED
		nRight_Gre	<=  not (SE_DIFF and  not OutOfRange)	; --(Green)
		nRight_Red	<=  not (OutOfRange and CLKSLOW )			; --(red)
		nRight_Blu	<=  not (HBWon 	 and  not OutOfRange)	; --(Blue)
	end if;
end process;

------------------------------------------------------------------
-- Relays drive (active high)
-- Note :
-- "Ch1" is Right channel (ADC U9) Relays K1-K2-K3
-- (SE_CH1 : pin66, FILTER_CH1: pin61)
-- "Ch2" is Left channel (ADC U11) Relays K4-K5-K6
-- (SE_CH2 : pin48, FILTER_CH2: pin47)
--
-- NOTES about default values :
--"SE_DIFF" : 0 (default)= single-ended mode 	1= differential
--"HBWon"		: 0 (default)= Low bandwidth mode	1= High bandwidth
------------------------------------------------------------------
process (Ready,HBWon,SE_DIFF)
begin
	if 	Ready='0'	then -- all relay off.
		FLTBW_L			<= '0'		; -- High bandwidth mode
		FLTBW_R			<= '0'		; -- High bandwidth mode
		SE_DIFF_L		<= '0'		; -- Single-Ended mode
		SE_DIFF_R		<= '0'		; -- Single-Ended mode
	else
		FLTBW_L			<= HBWon	; -- High bandwidth mode
		FLTBW_R			<= HBWon	; -- High bandwidth mode
		SE_DIFF_L		<= SE_DIFF; -- Single-Ended mode
		SE_DIFF_R		<= SE_DIFF; -- Single-Ended mode
	end if;
end process;


end Behavioral ;
