-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 30/10/19	Designer: O.N (aka Frex on DYaudio)
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 151 LE.
-- Function F3 :  F3_AutoZero.vhd
--
-- Allow DC offset removal when Start_CAL is initiate (rising edge).
-- The DC offset is stored and substracted from actual ADC value.
-- There is 2^16 samples summed and then they are divided by 2^16
-- to take the average value (offset).
-- To finish, this average value i stored and substracted  from the
-- actual DATA value to remove the offset.
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F3_AutoZero is
--
port(
	-- INPUTS
	FS				: in  std_logic ; -- ADC effective sampling rate
	DATAL			: in  std_logic_vector(23 downto 0) ; -- Left channel ADC data
	DATAR			: in  std_logic_vector(23 downto 0) ; -- Right channel ADC data
	Start_CAL	: in  std_logic ; -- Input pulse to initiate calibration.
	CIP				: buffer std_logic ; -- Calibration In Progress indicator
	-- OUTPUTS
	DATAFL		: buffer  std_logic_vector(23 downto 0) ; -- Left channel filtered ADC data
	DATAFR		: buffer  std_logic_vector(23 downto 0)  -- Left channel filtered ADC data
	--TEST
  -- TST_CalCNT : out integer range 0 to 65535  ; --
	-- TST_AVG_end : out  std_logic  --
);

end F3_AutoZero;

architecture Behavioral of F3_AutoZero is

signal	ACCUML		:	std_logic_vector(39 downto 0) :=x"0000000000" ; -- Accumulator output sample Left
signal	ACCUMR		:	std_logic_vector(39 downto 0) :=x"0000000000" ; -- Accumulator output sample Right
signal	MSBL			:	std_logic_vector(15 downto 0) :=x"0000" ;	-- 16 MSB bits of adder equal MSB of 24bits data word.Left
signal	MSBR			:	std_logic_vector(15 downto 0) :=x"0000" ;	-- 16 MSB bits of adder equal MSB of 24bits data word.Right

signal  CalCNT		: Integer range 0 to 65535 ; -- averaged samples counter
signal	AVG_end		: std_logic ; -- indicator of averaging is end.


begin
------------------------------------------------------------------
-- Calibration pulse generator
-- This pulse have fixed lenght of 65536 x FS(Sample rate) period.
-- For 192kHz = 1.360 s
-- For 96 kHz = 0.683 s
-- For 48 kHz = 0.341 s
------------------------------------------------------------------
process (FS,Start_CAL,CIP,CalCNT,AVG_end) is
begin
		-- Edge detect
		if 			AVG_end='1'	then
						CIP		<= '0'	; -- Reset pulse at end of averaging.
		elsif 	rising_edge(Start_CAL)	then
						CIP		<= '1'	;	-- Start calibration at rising edge of Start_CAL
		end if;
		--
		-- Counter for 65536 period of FS.
		if 			CIP='0'	then
						CalCNT	<= 0 ;
						AVG_end <= '0' ;
		elsif		rising_edge(FS) then
						CalCNT	<= CalCNT + 1 ;
						if 			CalCNT =65535	then
										AVG_end	<= '1'	; -- end of averaging
						end if;
		end if;
end process;

-- TEst outputs
-- TST_CalCNT  <=  CalCNT;
-- TST_AVG_end <=  AVG_end;
------------------------------------------------------------------
-- Autozero.
------------------------------------------------------------------
process (FS,DATAFL(23),DATAFR(23),CIP) is
begin
	-- Set sign bit at accumulator output
	case	DATAFL(23) is
			when '0' => MSBL <= x"0000" ;
			when '1' => MSBL <= x"FFFF" ;
	end case;
	case	DATAFR(23) is
			when '0' => MSBR <= x"0000" ;
			when '1' => MSBR <= x"FFFF" ;
	end case;
	-- Accumulate at each new sample
	if	rising_edge(FS)	and CIP='1' then
		-- Left
		ACCUML <= std_logic_vector(signed(ACCUML) + signed((MSBL & DATAL))) ;
		-- Right
		ACCUMR <= std_logic_vector(signed(ACCUMR) + signed((MSBR & DATAR))) ;
	end if;
end process ;

-- substract the mean of 2^16 values to actual value
DATAFL <= std_logic_vector(signed(DATAL) - signed(ACCUML(39 downto 16))) ;-- Left
DATAFR <= std_logic_vector(signed(DATAR) - signed(ACCUMR(39 downto 16))) ;-- Right

end Behavioral ;
