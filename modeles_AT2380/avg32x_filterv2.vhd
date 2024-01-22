------------------------------------------------------------------
-- ON le 02/10/2017  v2
-- Moving average filter for MCP3202 Dual channels 12bits ADC.
--
-- There is 2 ADC channels multiplexed.
-- The output is the difference bewteen ch1-ch0
-- [Note that 12 bits input value must'nt excess midscale
-- to avoid difference underflow ! ]
--
-- unsigned 12 bits data in and signed data out
-- The output is the average of the n previous input samples.
-- There is only 1 output sample each n samples.
--  ==>  n (average ratio) is here = 32x
-- Take xx LE
--
-- New: add generic parameter (avg_2n) to set averaging ratio
-- to see real effect and minimize logic cells requirement 
-- To be tested !
------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity avg32x_filterv2 is

generic(
  avg_2n           : integer := 5 );  -- averaged samples in power of two (2^5 = 32samples)
  
port(
  i_clk           : in  std_logic; -- master clock
  ADC_data_valid 	: in  std_logic; -- data valid signal (to latch channel data)
  ADC_channel    	: in  std_logic; -- ADC Channel 0(offset)/1(dBV) input
  ADC_data       	: in  std_logic_vector (11 downto 0); -- ADC DATA for both channels
  output		      : out signed(8 downto 0); -- n samples averaged signed 12 bits data output (ch1-ch0)
  average_end     : out std_logic;  -- pulse signal to indicate end of averaging process
-- Test I/O
----------------------------------------------------------
--   u_ch0_data      : in unsigned (11 downto 0);
--   u_ch1_data      : in unsigned (11 downto 0);
   difference      : out signed(11 downto 0); -- test output
   average         : out integer range 0 to ((2**avg_2n)+1) ;
   somme           : out signed((12+(avg_2n-1)) downto 0) -- test output
----------------------------------------------------------
  );
end avg32x_filterv2;

architecture Behavioral of avg32x_filterv2 is

signal avg_count    : integer range 0 to ((2**avg_2n)+1) := 0 ;-- averaging counter
signal sum          : signed((12+(avg_2n-1)) downto 0) := (others => '0');-- result is +5 bits wider for 32x averaging (2^5)
signal u_ch0_data   : unsigned(11 downto 0) ; -- unsigned value of ADC channel 0 // Offset setting
signal u_ch1_data   : unsigned(11 downto 0) ; -- unsigned value of ADC channel 1 // dBV value
signal ADC_diff     : signed(11 downto 0) := (others => '0'); --  signed value of ADC ch1-ch0 = Gain/offset corrected outpu dBV amplitude
signal avg_terminate: std_logic := '0' ; -- signal active at end of averaging
signal QA		     : std_logic := '0' ; -- temporary signal for pulse generating
signal ResetA		  : std_logic := '0' ;  -- temporary signal for pulse generating
 
begin

--Test signals
difference <= ADC_diff; -- test
somme <= sum;-- test
average <= avg_count ;
-------------------

-------------------------------------------------------
-- ADC (MCP3202) channels demux and ch1-ch0 difference caclulation
-- and latch on ADC_data_valid falling edge.
-------------------------------------------------------
process(ADC_channel,u_ch0_data,u_ch1_data,ADC_data_valid)
begin
--  if    rising_edge (ADC_channel) then -- difference to remove ch0 offset is calculated eah Fs period
        ADC_diff 	<= signed (u_ch1_data - u_ch0_data) ; -- ch1(dBV) - ch0(Offset) (result is signed for -180/+20 for -90 to +10dBV)
--  end if;
 if falling_edge(ADC_data_valid) then -- Data valid at 2 x Fsample
   if  ADC_channel='0'  then
     u_ch1_data 	<= unsigned (ADC_data(11 downto 0)); -- Channel 1 is dBV value from AD8310
   else
     u_ch0_data 	<= unsigned (ADC_data(11 downto 0)); -- Channel 0 is offset value
   end if;
end if;
end process;

-------------------------------------------------------
-- n samples averaging
-- n samples are added, and then the result is divided
-- by n ( n is a power of 2 for a simple division that
-- is only a right shift).
-------------------------------------------------------
process (ADC_data_valid,ADC_channel,avg_count,sum,ADC_diff)
begin
    if    rising_edge(ADC_channel) then 
        if  avg_count < 1  then
            avg_count <= avg_count + 1 ;
            avg_terminate <= '0' ;
            sum <= (others => '0');
        elsif  avg_count < (2**avg_2n)+1 then
            avg_count <= avg_count + 1 ; -- increment avg_count
            avg_terminate <= '0' ; -- averaging in  process
            sum <= ADC_diff + sum ; -- accumulate
        else            
            avg_count <= 0 ; -- reset average counter
            output <= sum ((12+(avg_2n-1)) downto (4+(avg_2n-1))) ; -- 9 MSB of adder is kept to output.
--             sum <=  ADC_diff + "00000000000000000" ; -- reset accumulator
            sum <= (others => '0') ; -- reset accumulator
            avg_terminate <= '1' ; -- averaging is end
        end if;
     end if;
end process;

------------------------------------------------------------------
-- Generate a single short pulse (1 period i_clk) 
-- at rising edge of avg_terminate
------------------------------------------------------------------
process (ResetA,avg_terminate,i_clk,QA)
begin
    if    ResetA='1' then
          QA <= '0';
    elsif rising_edge(avg_terminate) then
    	    QA <= '1';
    end if;
    
    if    rising_edge(i_clk) then
          ResetA<= QA;
    end if; 
    average_end <= QA ;   
end process;



end behavioral;
