-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 20/08/19	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 9 LE.
-- Function F2 :  F2_leds_decoders.vhd
-- 
-- Decode signals and drive Leds & relays accordingly. 
--
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F2_leds_decoders is
--
port(
	-- Input signals
	CLKSLOW		: in  std_logic ; -- slow clock input for synchronisation
	SR			: in  std_logic_vector(1 downto 0) ; -- sampling rate
	AVG			: in  std_logic_vector(2 downto 0) ; -- averaging ratio
	SEnDIFF		: in  std_logic ; -- Single-ended / Différential mode
	HBWon		: in  std_logic ; -- High bandwidth filter mode
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
	nLED1_Y		: out std_logic ;	-- Left channel Multicolor led indicator (Yellow)
	nLED2_G		: out std_logic ;	-- Right channel Multicolor led indicator (Green)
	nLED2_R		: out std_logic ;	-- Right channel Multicolor led indicator (Red)
	nLED2_Y		: out std_logic ;	-- Right channel Multicolor led indicator (Yellow)
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
	when others =>	LED_48K <= '0' ;
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

LED_CAL		<= 	CAL_pulse	;
------------------------------------------------------------------
-- Others leds
------------------------------------------------------------------
-- Both red leds are on when calib is in progress
-- All these leds are active low !
-- Left channel
nLED1_R		<= not CAL_pulse ;
nLED1_G		<= '1';
nLED1_Y		<= '1';
-- Right channel
nLED2_R		<= not CAL_pulse ;
nLED2_G		<= '1';
nLED2_Y		<= '1';

------------------------------------------------------------------
-- Relays
------------------------------------------------------------------
process (CLKSLOW,HBWon,SEnDIFF)
begin
	if 	rising_edge(CLKSLOW)	then
		FILTER_CH1	<= HBWon	;
		FILTER_CH2	<= HBWon	;
		LED_FILTOFF <= HBWon	;
		SE_CH1		<= SEnDIFF	;
		SE_CH2		<= SEnDIFF	;
		LED_SE		<= SEnDIFF	;		
	end if;
end process;


 


end Behavioral ;