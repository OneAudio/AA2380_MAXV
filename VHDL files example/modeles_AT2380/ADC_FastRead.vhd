------------------------------------------------------------------
-- ON le 26/05/2017
-- Function to read data from LT2380-24 ADC using fast reading
-- protocol, eg all 24 bits of data in a single clock cycle.
--
--Average is always scaled to : 
-- 8x for 192 kHz
-- 16x for 96 kHz
-- 32x for 48 kHz
-- Take 119 LE
-------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ADC_FastRead is
--
port(
  enable		: in  std_logic; --enable input for fast reading mode.
  clock         : in  std_logic; -- 98.304 MHz clock input
  FS            : in  std_logic_vector(1 downto 0); -- selected output sampling rate (48,96 or 192kHz) 
  DATAO 	    : out std_logic_vector(23 downto 0); --ADC parrallel output data
  Fso			: buffer std_logic ; -- output sampling rate
  Fsr			: out std_logic ; -- output sampling rate unaveraged
  FS128			: out std_logic ; -- 128 FS output for SPDIF.
  --- ADC control signals
  ncnv           : out std_logic ; -- ADC start conv signal (inverted)
  sck           : out std_logic ; -- ADC clk
  busy          : in std_logic  ; -- ADC busy signal
  sdo           : in std_logic ; -- ADC data output
  r_data		: buffer std_logic_vector(23 downto 0); -- test
  r_en_clk		: out std_logic ; --test
  r_tclk23	 	: out integer range 0 to 32   
  );
 
end ADC_FastRead;

architecture Behavioral of ADC_FastRead is

signal clk_divider  : unsigned(6 downto 0); -- clock divider counter
signal clk_div4		: std_logic ; --
signal clk_div5		: std_logic ; --
signal clk_div6		: std_logic ; --
  	
signal FSample  	: std_logic ; -- output sampling clock 	

signal  avg_max     : integer range 1 to 32  ; -- max average value
signal  avg_cnt     : integer range 1 to 32  ; -- average counter
signal  tclk23      : integer range 0 to 32   ; -- clk_div4 pulses counter for complete ADC reading
signal	AVG_en		: std_logic ; --  
signal	en_clk		: std_logic ; --
signal r_sck		: std_logic ; --

signal  QA          : std_logic ; --  
signal  ResetA      : std_logic ; --

--signal r_DATA       : std_logic_vector (23 downto 0) ; -- DATAO buffer

begin

------------------------------------------------------------------
-- clock divider
------------------------------------------------------------------
p_clk_divider: process(clock)
begin
  if(rising_edge(clock)) then
    clk_divider   <= clk_divider + 1;
  end if;
end process p_clk_divider;
clk_div4   <= clk_divider(1); -- 24.576 MHz (128*192)
clk_div5	 <= clk_divider(2); -- 12.288 MHz (128*96)
clk_div6	 <= clk_divider(3); -- 6.144 MHz (128*48)
FSample    <= clk_divider(5); -- 1536 kHz (=192x8, 96x16 ot 48x32)

Fsr <= Fsample;
------------------------------------------------------------------
-- Decoding averaging value from inputs
-- and output corresponding 128FS clock
------------------------------------------------------------------
process (FS,clk_div4,clk_div5,clk_div6)
begin
  case FS is
    when "00" => avg_max <= 32 ; -- FS= 48k,  averaging = 32x
			FS128	<= clk_div6;
    when "01" => avg_max <= 16 ; -- FS= 96k,  averaging = 16x
			FS128	<= clk_div5;
    when "10" => avg_max <= 8  ; -- FS=192k,  averaging = 8x
			FS128	<= clk_div4;
    when "11" => avg_max <= 4  ; -- FS=384k,  averaging = 4x
			FS128	<= clk_div4;
    when others => avg_max <= 4 ;-- 
  end case;
end process;

------------------------------------------------------------------
-- Enable AVG_en signal for averaging process of ADC.
-- This signal is active only the first of the avg_max count
-- to allow ADC reading in this FSample clock cycle
------------------------------------------------------------------
process (FSample,avg_cnt,avg_max,AVG_en)
begin
    if rising_edge(FSample) then
        if  avg_cnt < avg_max then
            avg_cnt <=avg_cnt +1 ; -- increment coounter
        else
            avg_cnt <= 1 ; -- reset counter
        end if;
        if  avg_cnt =1 then
            AVG_en <= '1' ; -- average enable signal active only for the first count
        else
            AVG_en <= '0' ; -- disable for all others counts
        end if;
    end if;
end process;
-----------------------------------------------------------------
-- ADC nCNV pulse generator
------------------------------------------------------------------
process (FSample,ResetA,clk_div4)
begin
  if ResetA='1' then
	   QA <= '0';
  elsif rising_edge(FSample) then
	   QA <= '1';
  end if;
end process;
--
process (clk_div4)
begin
  if rising_edge(clk_div4) then
  ResetA<= QA;
  end if;
end process;

ncnv <= not ResetA ; -- ADC start convertion pulse (inverted) 

process (ResetA)
begin
	if rising_edge (ResetA) then
		Fso <= AVG_en; -- to output
	end if;
end process;
------------------------------------------------------------------
-- ADC sck pulses generator and sdo read shift register clock
-----------------------------------------------------------------
process (clock,tclk23,AVG_en,busy,en_clk)
begin
  if rising_edge(clock) then
    if Fso='1' then
      if  busy='0'  then
        if  tclk23 > 24 then
            en_clk <= '0' ;
        else                 
            tclk23 <= tclk23+1;
            en_clk <= '1';                     
        end if;
      else
        tclk23 <= 0;
        en_clk <= '0';
    end if;
    else
      en_clk <= '0';
   end if;
  end if;
r_sck <= clock and en_clk; 
end process;
          
r_en_clk <= en_clk ; --test (sck clock window)
r_tclk23 <= tclk23 ;

process(enable,r_sck)
begin
	if enable='1' then
		sck <= r_sck ;
	else
		sck <= 'Z' ;
	end if;
end process;

--------------------------------------------------------------------
-- Serial Input Process
-- Note that the SDO value reading is delayed to one clock cycle
-- to take in account the delay specs of the ADC.
-- So, first read is done when tclkcnt=1, not 0 !
--------------------------------------------------------------------
p_serial_input : process(clock,tclk23)
begin
  if rising_edge(clock) then  --stored data of sdo is send to bit 0 to 23 of DATAO
  case tclk23 is
      when  1  => r_DATA(23)  <= sdo; 
      when  2  => r_DATA(22)  <= sdo;
      when  3  => r_DATA(21)  <= sdo;
      when  4  => r_DATA(20)  <= sdo;
      when  5  => r_DATA(19)  <= sdo;
      when  6  => r_DATA(18)  <= sdo;
      when  7  => r_DATA(17)  <= sdo;
      when  8  => r_DATA(16)  <= sdo;
      when  9  => r_DATA(15)  <= sdo;
      when 10  => r_DATA(14)  <= sdo;
      when 11  => r_DATA(13)  <= sdo;
      when 12  => r_DATA(12)  <= sdo;
      when 13  => r_DATA(11)  <= sdo; 
      when 14  => r_DATA(10)  <= sdo;
      when 15  => r_DATA( 9)  <= sdo;
      when 16  => r_DATA( 8)  <= sdo;
      when 17  => r_DATA( 7)  <= sdo;
      when 18  => r_DATA( 6)  <= sdo;
      when 19  => r_DATA( 5)  <= sdo;
      when 20  => r_DATA( 4)  <= sdo;
      when 21  => r_DATA( 3)  <= sdo;
      when 22  => r_DATA( 2)  <= sdo;
      when 23  => r_DATA( 1)  <= sdo;
      when 24  => r_DATA( 0)  <= sdo;
      when others => NULL;
    end case;
  end if;
end process p_serial_input;

------------------------------------------------------------------------------
-- Transfer data register to DATAO output at each rising edge
-- of AVG_en signal
-- Output is high impedance if enable input is low.
------------------------------------------------------------------------------
process (enable,AVG_en)
begin
	IF enable='1' then
		if rising_edge(AVG_en) THEN
			DATAO <= r_DATA; --
		end if;
	else
		DATAO <= "ZZZZZZZZZZZZZZZZZZZZZZZZ" ; -- output set in high impedance
	end if;
end process;
--------------------------------------------------------------------
end Behavioral ;
          

