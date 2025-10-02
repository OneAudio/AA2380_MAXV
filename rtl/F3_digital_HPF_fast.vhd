-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 22/08/19	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take (only)138 LE.
-- Function F3 :  F3_digital_HPF_fast.vhd
-- 
-- DC Offset calibration.
-- The "fast" version is made to require lower LE.
-- 
-- NOTE:
-- When CAL_PULSE is initiate, we accumulate 1024 ADCs DATA values.
-- Then this sum is divided by 1024 (shift) to take the average and
-- subsctacted from actual ADCs value to allow offset removal.
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F3_digital_HPF_fast is
--
port(
	-- INPUTS
	nFS			: in  std_logic ; -- ADC effective sampling rate
	DOUTL		: in  std_logic_vector(23 downto 0) ; -- Left channel ADC data
	DOUTR		: in  std_logic_vector(23 downto 0) ; -- Right channel ADC data
	CAL_PULSE	: in  std_logic ; -- Offset removal calibration pulse.
	-- OUTPUTS
	DOUTFL		: out  std_logic_vector(23 downto 0) ; -- Left channel filtered ADC data
	DOUTFR		: out  std_logic_vector(23 downto 0)  -- Left channel filtered ADC data
	
);
 
end F3_digital_HPF_fast;

architecture Behavioral of F3_digital_HPF_fast is

signal	OFFSETL	:	std_logic_vector(33 downto 0) ; -- Stored offset Left channel
signal	OFFSETR	:	std_logic_vector(33 downto 0) ; -- Stored offset Right channel
signal 	avgcount:	integer range 0 to 1024 :=0 ; -- average counter

begin

---------------------------------------------------------------------- 
-- Acummulated 1024 ADC value and then divide it by 1024 (10 bits)
-- to take the offset average value.
-- Then it is substracted to current ADC value to remove this offset.
----------------------------------------------------------------------
average : process (nFS,avgcount,CAL_PULSE,DOUTL,DOUTR,OFFSETL,OFFSETR) is
begin
	--
	if	CAL_PULSE='1'	then
		if	rising_edge(nFS)	then
			if	avgcount < 1024	then
				OFFSETL <= std_logic_vector(signed(OFFSETL) + signed(DOUTL) ); -- accumulate
				OFFSETR <= std_logic_vector(signed(OFFSETR) + signed(DOUTR) ); -- accumulate
				avgcount <= avgcount + 1	; -- increment counter	
			end if;
		end if;
	else
		avgcount	<= 0 ; --reset counter
	end if;
	DOUTFL		<=  std_logic_vector(signed(DOUTL) - signed(OFFSETL(33 downto 10)))	;
	DOUTFR		<=  std_logic_vector(signed(DOUTR) - signed(OFFSETR(33 downto 10)))	;
			
end process average;

end Behavioral ;