-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 23/11/20	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 11 LE.
-- Function F2 :  F2_leds_decoders.vhd
--
-- Decode signals and drive Leds & relays accordingly.
--
-- Update 23/11/20 :
-- New led color scheme, delay led and relays with Ready signal.
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F2_leds_decoders is
--
port(
	-- Input signals
	CLKSLOW		: in  std_logic ; -- slow clock input for synchronisation
	Ready		: in  std_logic ; -- Ready signal 
	SR		: in  std_logic_vector(1 downto 0) ; -- sampling rate
	AVG		: in  std_logic_vector(2 downto 0) ; -- averaging ratio
	SEnDIFFL	: in  std_logic ; -- Single-ended / Différential mode (Left CHannel)
	HBWonL		: in  std_logic ; -- High bandwidth filter mode (Left CHannel)
	SEnDIFFR	: in  std_logic ; -- Single-ended / Différential mode (Right CHannel)
	HBWonR		: in  std_logic ; -- High bandwidth filter mode(Right CHannel)
	FIRnSinC	: in  std_logic ; -- Digital FIR filter mode(1) or internal SinC filter mode
	CAL_pulse	: in  std_logic ; -- Calibration process pulse.
	--
	--LEDS (AA2380PAN)
	LED_48K		: out std_logic ;	--  48kHz indicator led
	LED_96K		: out std_logic ;	--  96kHz indicator led
	LED_192K	: out std_logic ;	-- 192kHz indicator led
	LED_AVG0	: out std_logic ;	-- Averaging Led 1/3
	LED_AVG1	: out std_logic ;	-- Averaging Led 2/3
	LED_AVG2	: out std_logic ;	-- Averaging Led 3/3
	LED_SE		: out std_logic ;	-- Single-ended indicator led
	LED_FILTOFF	: out std_logic ;	-- High bandwidth filter indicator led
	LED_CAL		: out std_logic ;	-- Calibration in progress led indicator
	--
	--LEDS (AA2380)
	nLED1_G		: out std_logic ;	-- Left channel Multicolor led indicator (Green)
	nLED1_R		: out std_logic ;	-- Left channel Multicolor led indicator (Red)
	nLED1_B		: out std_logic ;	-- Left channel Multicolor led indicator (Blue)
	nLED2_G		: out std_logic ;	-- Right channel Multicolor led indicator (Green)
	nLED2_R		: out std_logic ;	-- Right channel Multicolor led indicator (Red)
	nLED2_B		: out std_logic ;	-- Right channel Multicolor led indicator (Blue)
	--
	--RELAYS
	FILTER_CH1	: out std_logic ;	-- Ch1 (Left) analog filter mode
	SE_CH1		: out std_logic ;	-- Ch1 (Left) single-ended input mode
	FILTER_CH2	: out std_logic ;	-- Ch2 (Right) analog filter mode
	SE_CH2		: out std_logic 	-- Ch2 (Right) single-ended input mode
);

end F2_leds_decoders;

architecture Behavioral of F2_leds_decoders is


begin

------------------------------------------------------------------
-- Sampling frequency decoding.
------------------------------------------------------------------
process (SR) is
begin
case SR is
	when "00" 	=>	LED_48K <= '1' ;
				LED_96K <= '0' ;
				LED_192K<= '0' ;
	when "01" 	=>	LED_48K <= '0' ;
				LED_96K <= '1' ;
				LED_192K<= '0' ;
	when "10"	=>	LED_48K <= '0' ;
				LED_96K <= '0' ;
				LED_192K<= '1' ;
	when others	 =>	LED_48K <= '0' ;
	                	LED_96K <= '0' ;
	                	LED_192K<= '0' ;
end case ;
end process;

-----------------------------------------------------------------
-- Averaging ratio decoding and CAL led
------------------------------------------------------------------
LED_AVG0 <= AVG(0) ; --
LED_AVG1 <= AVG(1) ; --
LED_AVG2 <= AVG(2) ; --

LED_CAL	<= CAL_pulse	;
------------------------------------------------------------------
-- TRicolors LED (Red+Green+Blue)
-- COLORS LEDS STATUS :
-----------------------
-- RED  : if Calib in progress
-- BLUE : if high-bandwidth mode active
-- GREEN: if Single-ended mode active
-- CYAN : if both high-bandwidth and Single-ended modes active
------------------------------------------------------------------
-- Both red leds are on when calib is in progress
-- All these leds are active low !
process(Ready,CAL_pulse,SEnDIFFR,SEnDIFFL,CAL_pulse,HBWonR,HBWonL) is
begin
	if 	Ready= '0'	then
		nLED1_R <= '1'  ; -- leds all off
		nLED1_G <= '1'  ; -- leds all off
		nLED1_B <= '1'  ; -- leds all off
		nLED2_R <= '1'  ; -- leds all off
		nLED2_G <= '1'  ; -- leds all off
		nLED2_B <= '1'  ; -- leds all off
	else
		-- Left Channel LED
		nLED1_R	<= not (CAL_pulse)			; --Active when offset calibration is active (red)
		nLED1_G	<= not (SEnDIFFL and not CAL_pulse)	;-- off if calpulse is active, otherwise indicate Single-Ended mode (Green)
		nLED1_B	<= not (HBWonL and not 	CAL_pulse)	;-- off if calpulse is active, otherwise indicate High bandwidth mode (Blue)
		-- Right channel
		nLED2_R	<= not CAL_pulse			; --Active when offset calibration is active (red)
		nLED2_G	<= not (SEnDIFFR and not CAL_pulse)	;-- off if calpulse is active, otherwise indicate Single-Ended mode  (Green)
		nLED2_B	<= not (HBWonR and not CAL_pulse)	;-- off if calpulse is active, otherwise indicate High bandwidth mode(Blue)
	end if;
end process;

------------------------------------------------------------------
-- Relays drive (active high)
-- Note :
-- "Ch1" is Right channel (ADC U9) Relays K1-K2-K3
-- "Ch2" is Left channel (ADC U11) Relays K4-K5-K6
------------------------------------------------------------------
process (Ready,HBWonL,SEnDIFFL,HBWonR,SEnDIFFR)
begin
	if 	Ready='0'	then -- all relay off.
		FILTER_CH1	<= '0'		; -- High bandwidth mode channel 1 Right
		FILTER_CH2	<= '0'		; -- High bandwidth mode channel 2 Left
		SE_CH1		<= '0'		; -- Single-Ended mode channel 1 Right
		SE_CH2		<= '0'		; -- Single-Ended mode channel 1 Left
	else
		FILTER_CH1	<= HBWonR	; -- High bandwidth mode channel 1 Right
		FILTER_CH2	<= HBWonL	; -- High bandwidth mode channel 2 Left
		SE_CH1		<= SEnDIFFR	; -- Single-Ended mode channel 1 Right
		SE_CH2		<= SEnDIFFL	; -- Single-Ended mode channel 1 Left
	end if;
end process;


end Behavioral ;
