-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 21/08/19	Designer: O.N (aka Frex on DYaudio)
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 224 LE.
-- Function F3 :  F3_digital_HPF.vhd
-- 
-- Allow DC offset removal when CAL_PULSE is active.
-- --------------------------------------------------------------
-- Dynamic DC removal filter
-- From application note Xylinx Ref :
-- 24 bits data input and output.
-- The k factor is 1 / 65536 (16 bit are added to the accumulator).
-- That give a time constant for 192kHz sampling rate (input clock)
-- of  2.35s for reach 1/1000 error.
-- RC= Tsx n = 5.21e-6 x 65536 = 0.341s
-- For 0.1% error (1/1000), t= -RC ln 0.001 = 2.35 s
-- For 0.06 ppm error (24 bits) , t= -RC ln 0.06e-6 =  5.7 s
--
-- The autozero minimum time for each sampling rate (48k,96k and 192kHz),
-- to reach the 24bits accuracy is :
-- RC@48k = 1.36s
-- RC@96k = 0.683 s
-- RC@192k= 0.341 s
-- For 0.06 ppm error (24 bits) , t= -0.341 ln 0.06e-6 =  5.7 s @ 192 kHz
-- For 0.06 ppm error (24 bits) , t= -0.683 ln 0.06e-6 =  11.35 s @ 96 kHz
-- For 0.06 ppm error (24 bits) , t= -1.36 ln 0.06e-6 =   22.6 s @ 48kHz

------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F3_digital_HPF is
--
port(
	-- INPUTS
	nFS			: in  std_logic ; -- ADC effective sampling rate
	DOUTL		: in  std_logic_vector(23 downto 0) ; -- Left channel ADC data
	DOUTR		: in  std_logic_vector(23 downto 0) ; -- Right channel ADC data 
	CAL_PULSE	: in  std_logic ; -- Offset removal calibration pulse.
	-- OUTPUTS
	DOUTFL		: buffer  std_logic_vector(23 downto 0) ; -- Left channel filtered ADC data
	DOUTFR		: buffer  std_logic_vector(23 downto 0)  -- Left channel filtered ADC data
	
);
 
end F3_digital_HPF;

architecture Behavioral of F3_digital_HPF is

signal	DATASUBL	:	std_logic_vector(23 downto 0) ; -- Filtered output Left
signal	DATASUBR	:	std_logic_vector(23 downto 0) ; -- Filtered output Right
signal	ACCUML		:	std_logic_vector(39 downto 0) ; -- Accumulator output sample Left
signal	ACCUMR		:	std_logic_vector(39 downto 0) ; -- Accumulator output sample Right
signal	MSBL		:	std_logic_vector(15 downto 0) ;	-- 16 MSB bits of adder equal MSB of 24bits data word.Left
signal	MSBR		:	std_logic_vector(15 downto 0) ;	-- 16 MSB bits of adder equal MSB of 24bits data word.Right

signal  OFFL		:	std_logic_vector(23 downto 0) ; -- DC offset substractor Left
signal  OFFR		:	std_logic_vector(23 downto 0) ; -- DC offset substractor Right


begin

------------------------------------------------------------------
-- Digital high-pass filter
--
--
------------------------------------------------------------------
IIR_HPFilter : process (nFS,DOUTFL(23),DOUTFR(23)) is
begin
	--
	case	DOUTFL(23) is
			when '0' => MSBL <= x"0000" ;
			when '1' => MSBL <= x"FFFF" ;
	end case;
	case	DOUTFR(23) is
			when '0' => MSBR <= x"0000" ;
			when '1' => MSBR <= x"FFFF" ;
	end case;
	--
	if	rising_edge(nFS)	then
		-- Left
		ACCUML <= std_logic_vector(signed(ACCUML) + signed((MSBL & DATASUBL))) ; 
		-- Right
		ACCUMR <= std_logic_vector(signed(ACCUMR) + signed((MSBR & DATASUBR))) ;
	end if;
end process IIR_HPFilter;

DATASUBL <= std_logic_vector(signed(DOUTL) - signed(ACCUML(39 downto 16))) ;
DATASUBR <= std_logic_vector(signed(DOUTR) - signed(ACCUMR(39 downto 16))) ;

------------------------------------------------------------------
-- Offset calibration process
-- (This activate HPF for CAL_PULSE time, 
-- and then store DC value before to disable HPF).
------------------------------------------------------------------

OffsetCalib : process (nFS,CAL_PULSE,DOUTL,DOUTR,OFFL,OFFR) is
begin
	--
	if	rising_edge(nFS) and CAL_PULSE='1'	then
		OFFL	<= ACCUML(39 downto 16) ; -- remove averaged value until CAL_PULSE become low (Left)
		OFFR	<= ACCUMR(39 downto 16) ; -- remove averaged value until CAL_PULSE become low (Right)
	end if;

DOUTFL <= std_logic_vector(signed(DOUTL) - signed(OFFL)) ; -- Remove offset Left channel
DOUTFR <= std_logic_vector(signed(DOUTR) - signed(OFFR)) ; -- Remove offset Right channel	

end process OffsetCalib ;
	
end Behavioral ;