-------------------------------------------------------------------------------
-- ON 2017
-- ADC distributed read
-- Take xxx LE
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADC_DistRead is
generic(
  CLK_DIV               : integer := 10 );  -- input clock divider to generate output serial clock; o_sclk frequency = i_clk/(CLK_DIV)
port (
  FSample                     : in  std_logic; -- FS clock , ADC conversion on each edge
  i_clk                       : in  std_logic; -- main clock (divided by CLK_DIV for SPI)
--  i_rstb                      : in  std_logic; -- /reset input
  o_adc_data_valid            : out std_logic;  -- conversion valid pulse
--   o_adc_ch                    : out std_logic;  -- ADC converted channel
  o_adc_data                  : out std_logic_vector(23 downto 0); -- adc parallel data
-- ADC serial interface
  o_sclk                      : out std_logic; -- ADC clock
  o_ss                        : out std_logic; -- ADC /Chip Select (/CS)
  o_convstart                 : out std_logic; -- 
--   o_mosi                      : out std_logic; -- ADC Data in
  i_miso                      : in  std_logic;-- ADC Data out
  i_busy                      : in  std_logic; -- ADC busy flag
  enable_cnv                  : out std_logic; -- test 
  conv_run                    : out std_logic; -- test 
  count_run                   : out integer range 0 to 23 -- test 
  );
  
end ADC_DistRead;

architecture rtl of ADC_DistRead is
constant C_N                     : integer := 24;

signal r_counter_clock            : integer range 0 to CLK_DIV;-- counter for clock divider
signal r_sclk_rise                : std_logic;
signal r_sclk_fall                : std_logic;
signal r_counter_clock_ena        : std_logic; --enable clock divider signal

signal r_counter_data             : integer range 0 to C_N-1; -- counter of ADC clock cycle
signal r_tc_counter_data          : std_logic; -- terminate conversion signal

signal r_conversion_running       : std_logic;  -- enable serial data protocol

signal r_miso                     : std_logic;
signal r_conv_ena                 : std_logic;  -- enable ADC convesion
signal r_adc_data                 : std_logic_vector(23 downto 0); -- adc parallel data

signal QA			: std_logic;
signal QB			: std_logic;  
signal ResetA		: std_logic; 
signal ResetB		: std_logic;
signal conv_start	: std_logic; 

begin

--- Test signals
o_convstart <= conv_start ;
conv_run    <=r_conversion_running ;
count_run   <= r_counter_data;
enable_cnv <= r_counter_clock_ena ;

--------------------------------------------------------------------
-- FSM
p_conversion_control : process(i_clk,conv_start)
begin
  if(rising_edge(i_clk)) then
    r_conv_ena             <= conv_start;
    if(r_conv_ena='1') then
      r_conversion_running   <= '1';
    elsif(r_conv_ena='0') and (r_tc_counter_data='1') then -- terminate current conversion
      r_conversion_running   <= '0';
    end if;
    r_counter_clock_ena    <= r_conversion_running;  -- enable clock divider
  end if;
end process p_conversion_control;



--------------------------------------------------------------------
p_counter_data : process(i_clk)
begin
  if(rising_edge(i_clk)) then
    if(r_counter_clock_ena='1') and i_busy='0' then
      if(r_sclk_rise='1') then  -- count data @ o_sclk rising edge
        if(r_counter_data<C_N-1) then
          r_counter_data     <= r_counter_data + 1;
          r_tc_counter_data  <= '0';
        else
          r_counter_data     <= 0;
          r_tc_counter_data  <= '1';
        end if;
      else
        r_tc_counter_data  <= '0';
      end if;
    else
      r_counter_data     <= 0;
      r_tc_counter_data  <= '0';
    end if;
  end if;
end process p_counter_data;


--------------------------------------------------------------------
-- Serial Input Process
p_serial_input : process(i_clk)
begin
  if(rising_edge(i_clk)) then
    r_miso               <= i_miso; 
  case r_counter_data is
      when  0  => r_adc_data(23)  <= r_miso; -- ADC Data start .
      when  1  => r_adc_data(22)  <= r_miso;
      when  2  => r_adc_data(21)  <= r_miso;
      when  3  => r_adc_data(20)  <= r_miso;
      when  4  => r_adc_data(19)  <= r_miso;
      when  5  => r_adc_data(18)  <= r_miso;
      when  6  => r_adc_data(17)  <= r_miso;
      when  7  => r_adc_data(16)  <= r_miso;
      when  8  => r_adc_data(15)  <= r_miso;
      when  9  => r_adc_data(14)  <= r_miso;
      when 10  => r_adc_data(13)  <= r_miso;
      when 11  => r_adc_data(12)  <= r_miso;
      when 12  => r_adc_data(11)  <= r_miso; 
      when 13  => r_adc_data(10)  <= r_miso;
      when 14  => r_adc_data( 9)  <= r_miso;
      when 15  => r_adc_data( 8)  <= r_miso;
      when 16  => r_adc_data( 7)  <= r_miso;
      when 17  => r_adc_data( 6)  <= r_miso;
      when 18  => r_adc_data( 5)  <= r_miso;
      when 19  => r_adc_data( 4)  <= r_miso;
      when 20  => r_adc_data( 3)  <= r_miso;
      when 21  => r_adc_data( 2)  <= r_miso;
      when 22  => r_adc_data( 1)  <= r_miso;
      when 23  => r_adc_data( 0)  <= r_miso;
      when others => NULL;
    end case;
  end if;
end process p_serial_input;


--------------------------------------------------------------------
-- SERIAL Output process
p_serial_output : process(i_clk)
begin
  if(rising_edge(i_clk)) then
    o_ss                 <= not r_conversion_running;
    if  (r_tc_counter_data='1') then
       o_adc_data        <= r_adc_data (23 downto 0) ;
    end if;
    o_adc_data_valid     <= r_tc_counter_data;
    
    if(r_counter_clock_ena='1') and i_busy='0' then  -- sclk = '1' by default
      if(r_sclk_rise='1') then
        o_sclk   <= '1';
      elsif(r_sclk_fall='1') then
        o_sclk   <= '0';
      end if;
    else
      o_sclk   <= '1';
    end if;
  end if;
end process p_serial_output;


--------------------------------------------------------------------
-- CLOCK divider
p_counter_clock : process(i_clk)
begin
  if(rising_edge(i_clk)) then
    if(r_counter_clock_ena='1') then
      if(r_counter_clock=(CLK_DIV/2)-1) then  -- firse edge = fall
        r_counter_clock            <= r_counter_clock + 1;
        r_sclk_rise                <= '0';
        r_sclk_fall                <= '1';
      elsif(r_counter_clock=(CLK_DIV-1)) then
        r_counter_clock            <= 0;
        r_sclk_rise                <= '1';
        r_sclk_fall                <= '0';
      else
        r_counter_clock            <= r_counter_clock + 1;
        r_sclk_rise                <= '0';
        r_sclk_fall                <= '0';
      end if;
    else
      r_counter_clock            <= 0;
      r_sclk_rise                <= '0';
      r_sclk_fall                <= '0';
    end if;
  end if;
end process p_counter_clock;

--------------------------------------------------------------------
---------------------------------------------------
-- From the 2Hz clock, generate conv pulse at each
-- edge to initate ch0+ch1 convertion on one 2Hz cycle
------------------------------------------------------
process (FSample,ResetA,ResetB)
begin
-- conv_start <= ResetA or ResetB ;
conv_start <= ResetA ;


if ResetA='1' then
	QA <= '0';
elsif rising_edge(FSample) then
	QA <= '1';
end if;
if ResetB='1' then
	QB <= '0';
elsif falling_edge(FSample) then
	QB <= '1';
end if;
end process;

process (i_clk)
begin
if rising_edge(i_clk) then
ResetA<= QA;
end if;
if rising_edge(i_clk) then
ResetB<= QB;
end if;


end process;
--
end rtl;

