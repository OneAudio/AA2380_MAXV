-------------------------------------------------------------------------
-- ON le 24/05/2017
-- Computation of rectified mean value each N input samples
-- of 24 bits unsigned word from ADC.
-- This method give very good value near to RMS for various signal type
-- and avoid square and square-root computation nedded for real RMS value.
-- Require much less LE .
-- Errors from rms value is :
-- (Sine wave= 0.9dB , Gaussian noise= ? dB , triangle =1.25dB and square =0dB)
-- take 103LE for 32768 (2^15) averaged samples
-------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all; 
use IEEE.STD_LOGIC_unsigned.ALL;
use ieee.numeric_std.all;

entity RectifiedMean is port( 

FSclk     : in std_logic; -- input sampling clock (48,96,192 or 384kHz)
data_in   : in signed(23 downto 0);  -- 24 signed input data 
data_out  : out std_logic_vector(23 downto 0) -- 24 bits rectified average output
-- acc		  	:out unsigned (38 downto 0); --test output
-- countN		: out integer range 0 to 32768  --test output
);
 end RectifiedMean;

architecture behaviour of RectifiedMean is

--mean of squared samples signals
constant	N		: integer := 32768 ; -- 
signal sample_sq	: unsigned (22 downto 0); -- 
signal acc_cnt    	: integer range 0 to N ; -- acuumulate counter for N samples
signal accumulate	: unsigned (37 downto 0); -- accumulator output
signal us_data_in : unsigned (22 downto 0); -- unsigned input form (rectified)

begin

-- acc <= accumulate;    -- test output
-- countN <= acc_cnt ;   -- test output
------------------------------------------------------------------------
-- Convert 24 bit signed input in unsigned form
-- (rectification)
-------------------------------------------------------------------------
process (data_in)
begin
	if data_in >= 0 then
		us_data_in <= unsigned(data_in(22 downto 0));
	else
		us_data_in <= 16777216 - unsigned(data_in(22 downto 0));
	end if;
end process;

------------------------------------------------------------------------
-- Averaging N rectified samples and then divide by N to take the mean.
-- (The output value is also doubled to have an output value for 24 bits width,
-- not 23 => So, the real divison is not N but N/2).
-------------------------------------------------------------------------
process (FSclk)
begin   
	if rising_edge(FSclk) then
		if	acc_cnt <= (N-1) then -- accumulate N samples
			sample_sq  <= us_data_in ;-- sample square
			accumulate <= accumulate + sample_sq ; -- accumlate N time
			acc_cnt    <= acc_cnt+1 ; -- increment acc counter
		else
			acc_cnt <= 0 ; -- reset acc counter
			accumulate <= "00" & x"000000000"; -- reset accumulator
			data_out   <= std_logic_vector(accumulate (37 downto 14)); -- divide by N/2 before to sent to output (Shift)
		end if;
	end if;
end process;

end behaviour;

