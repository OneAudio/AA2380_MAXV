  -------------------------------------------------------------------------------
-- ON 23/08/2017
-- MCP3202 12 bits 2 channels ADC read/write 
-- Take 61 LE
-- + add 9 bits output
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADC_MCP3202 is
generic(
  CLK_DIV               : integer := 100 );  -- input clock divider to generate output serial clock; o_sclk frequency = i_clk/(CLK_DIV)
port (
  clk2Hz                     : in  std_logic; -- 2Hz clock , ADC conversion on each edge
  i_clk                       : in  std_logic; -- main clock (divided by CLK_DIV for SPI)
--  i_rstb                      : in  std_logic; -- /reset input
  o_adc_data_valid            : out std_logic;  -- conversion valid pulse
  o_adc_ch                    : out std_logic;  -- ADC converted channel
  o_adc_data                  : out std_logic_vector(8 downto 0); -- adc parallel data
-- ADC serial interface
  o_sclk                      : out std_logic; -- ADC clock
  o_ss                        : out std_logic; -- ADC /Chip Select (/CS)
  o_mosi                      : out std_logic; -- ADC Data in
  i_miso                      : in  std_logic);-- ADC Data out
end ADC_MCP3202;

architecture rtl of ADC_MCP3202 is
constant C_N                     : integer := 17;
constant ST                      : std_logic := '1'; -- start bit to send
constant SE_DIFF                 : std_logic:= '1'; -- single ended or pseudo diff mode
signal CHAN_AB                   : std_logic; -- Channel selection (0=CH0 1=CH1)
constant MSBF                    : std_logic := '1' ; -- MSB format (1= MSB fisrt, 0 = MSB first + LSB first)

signal r_counter_clock            : integer range 0 to CLK_DIV;-- counter for clock divider
signal r_sclk_rise                : std_logic;
signal r_sclk_fall                : std_logic;
signal r_counter_clock_ena        : std_logic; --enable clock divider signal

signal r_counter_data             : integer range 0 to C_N-1; -- counter of ADC clock cycle
signal r_tc_counter_data          : std_logic; -- terminate conversion signal

signal r_conversion_running       : std_logic;  -- enable serial data protocol

signal r_miso                     : std_logic;
signal r_conv_ena                 : std_logic;  -- enable ADC convesion
signal r_adc_ch                   : std_logic;  -- ADC converted channel
signal r_adc_data                 : std_logic_vector(11 downto 0); -- adc parallel data

signal QA			: std_logic;
signal QB			: std_logic;  
signal ResetA		: std_logic; 
signal ResetB		: std_logic;
signal conv_start	: std_logic; 

begin


--------------------------------------------------------------------
-- FSM
p_conversion_control : process(i_clk,conv_start)
begin
--  if(i_rstb='0') then
--    r_conv_ena             <= '0';
--    r_conversion_running   <= '0';
--    r_counter_clock_ena    <= '0';
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

p_counter_data : process(i_clk)
begin
--  if(i_rstb='0') then
--    r_counter_data       <= 0;
--    r_tc_counter_data    <= '0';
  if(rising_edge(i_clk)) then
    if(r_counter_clock_ena='1') then
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

-- Serial Input Process
p_serial_input : process(i_clk)
begin
--  if(i_rstb='0') then
--    r_miso               <= '0';
--    r_adc_ch             <= '0';
--    r_adc_data           <= (others=>'0');
  if(rising_edge(i_clk)) then
    r_miso               <= i_miso;
        if(r_tc_counter_data='1') then
       r_adc_ch             <= clk2Hz; -- strobe new
      CHAN_AB <= clk2Hz ;
    end if;

    case r_counter_data is
      when  5  => r_adc_data(11)  <= r_miso; -- ADC Data start at sixt clock edge (bit n�5).
      when  6  => r_adc_data(10)  <= r_miso;
      when  7  => r_adc_data( 9)  <= r_miso;
      when  8  => r_adc_data( 8)  <= r_miso;
      when  9  => r_adc_data( 7)  <= r_miso;
      when 10  => r_adc_data( 6)  <= r_miso;
      when 11  => r_adc_data( 5)  <= r_miso;
      when 12  => r_adc_data( 4)  <= r_miso;
      when 13  => r_adc_data( 3)  <= r_miso;
      when 14  => r_adc_data( 2)  <= r_miso;
      when 15  => r_adc_data( 1)  <= r_miso;
      when 16  => r_adc_data( 0)  <= r_miso;
      when others => NULL;
    end case;
  end if;
end process p_serial_input;

-- SERIAL Output process
p_serial_output : process(i_clk)
begin
--  if(i_rstb='0') then
--    o_ss                 <= '1';
--    o_mosi               <= '1';
--    o_sclk               <= '1';
--    o_adc_data_valid     <= '0';
--    o_adc_ch             <= '0';
--    o_adc_data           <= (others=>'0');
  if(rising_edge(i_clk)) then
    o_ss                 <= not r_conversion_running;

    if(r_tc_counter_data='1') then
      o_adc_ch             <= r_adc_ch; -- update current conversion
      o_adc_data           <= r_adc_data (11 downto 3) ;
    end if;
    o_adc_data_valid     <= r_tc_counter_data;


    if(r_counter_clock_ena='1') then  -- sclk = '1' by default
      if(r_sclk_rise='1') then
        o_sclk   <= '1';
      elsif(r_sclk_fall='1') then
        o_sclk   <= '0';
      end if;
    else
      o_sclk   <= '1';
    end if;
      if(r_sclk_fall='1') then
      case r_counter_data is
        when  0  => o_mosi <= ST ; -- Din start bit of MCP3202 SPI 
        when  1  => o_mosi <= SE_DIFF; -- Din Single-ended or Pseudo diff input mode of MCP3202
        when  2  => o_mosi <= CHAN_AB ;-- Din Channel 1/2 selection of MCP3202
        when  3  => o_mosi <= MSBF; --Din MSB fisrt mode of MCP 3202
        when others => NULL;
      end case;
    end if;
  end if;
end process p_serial_output;

-- CLOCK divider
p_counter_clock : process(i_clk)
begin
--  if(i_rstb='0') then
--    r_counter_clock            <= 0;
--    r_sclk_rise                <= '0';
--    r_sclk_fall                <= '0';
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

---------------------------------------------------
-- From the 2Hz clock, generate conv pulse at each
-- edge to initate ch0+ch1 convertion on one 2Hz cycle
------------------------------------------------------
process (clk2Hz,ResetA,ResetB)
begin
conv_start <= ResetA or ResetB ;

if ResetA='1' then
	QA <= '0';
elsif rising_edge(clk2Hz) then
	QA <= '1';
end if;
if ResetB='1' then
	QB <= '0';
elsif falling_edge(clk2Hz) then
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

