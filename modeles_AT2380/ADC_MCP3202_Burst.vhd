  -------------------------------------------------------------------------------
-- ON 06/09/2017
--Take 66 LE
--
-- MCP3202 12 bits 2 channels ADC read/write 
-- 
-- ADC convertion start at rising edge of clk8Hz and stop when
-- average_end=1. (indicated end of external sample averager).
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADC_MCP3202_Burst is
-- generic(
--   CLK_DIV               : integer := 20 );  -- input clock divider to generate output serial clock; o_sclk frequency = i_clk/(CLK_DIV)
  
port (
  
  clk8Hz                      : in  std_logic; -- 8 Hz clock to initate start of burst sampling
  average_end                 : in  std_logic; -- Pulse to indicate end of averaging process 
--  clk2Hz                      : in  std_logic; -- 2Hz clock , ADC conversion on each edge
  i_clk                       : in  std_logic; -- main clock (divided by CLK_DIV for SPI) = 2MHz
--  i_rstb                      : in  std_logic; -- /reset input
  o_adc_data_valid            : buffer std_logic;  -- conversion valid pulse
  o_adc_ch                    : out std_logic;  -- ADC converted channel
  o_adc_data                  : out std_logic_vector(11 downto 0); -- adc parallel data
-- ADC serial interface
  o_sclk                      : out std_logic; -- ADC clock
  o_ss                        : out std_logic; -- ADC /Chip Select (/CS)
  o_mosi                      : out std_logic :='0'; -- ADC Data in
  i_miso                      : in  std_logic-- ADC Data out
--  chanx                       : out std_logic
	); --
end ADC_MCP3202_Burst;

architecture rtl of ADC_MCP3202_Burst is
constant C_N                     : integer := 17;
constant ST                      : std_logic := '1'; -- start bit to send
constant SE_DIFF                 : std_logic:= '1'; -- single ended or pseudo diff mode
signal CHAN_AB                   : std_logic  :='0'; -- Channel selection (0=CH0 1=CH1)
constant MSBF                    : std_logic := '1' ; -- MSB format (1= MSB fisrt, 0 = MSB first + LSB first)

constant CLK_DIV                  : integer := 20 ; 
signal r_counter_clock            : integer range 0 to CLK_DIV :=0 ;-- counter for clock divider
signal r_sclk_rise                : std_logic :='0';
signal r_sclk_fall                : std_logic :='0';
signal r_counter_clock_ena        : std_logic :='0'; --enable clock divider signal

signal r_counter_data             : integer range 0 to C_N-1  :=0; -- counter of ADC clock cycle
signal r_tc_counter_data          : std_logic :='0'; -- terminate conversion signal

signal r_conversion_running       : std_logic :='0';  -- enable serial data protocol

signal r_miso                     : std_logic :='0';
signal r_conv_ena                 : std_logic :='0';  -- enable ADC convesion
signal r_adc_ch                   : std_logic :='0';  -- ADC converted channel
signal r_adc_data                 : std_logic_vector(11 downto 0)  :=x"000"; -- adc parallel data

signal conv_enable		          	: std_logic :='0';
signal conv_start	                : std_logic :='0';
signal QA		                     	: std_logic :='0';
signal ResetA			                : std_logic :='0';   
signal channel                    : std_logic :='0';  

begin

--chanx <= r_adc_ch ;

--------------------------------------------------------------------
-- FSM
p_conversion_control : process(i_clk,conv_start)
begin
--  if(i_rstb='0') then
--    r_conv_ena             <= '0';
--    r_conversion_running   <= '0';
--    r_counter_clock_ena    <= '0';
  if(rising_edge(i_clk)) then
    r_conv_ena    <= conv_start;
    r_counter_clock_ena    <= r_conversion_running;  -- enable clock divider
    if(r_conv_ena='1') then
      r_conversion_running   <= '1';
    elsif(r_conv_ena='0') and (r_tc_counter_data='1') then -- terminate current conversion
      r_conversion_running   <= '0';
    end if;
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
        if(r_counter_data < C_N-1) then
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
    if  (r_tc_counter_data='1') then
            r_adc_ch <= not r_adc_ch; -- strobe new
    end if; 
      CHAN_AB   <= r_adc_ch ;
      o_adc_ch  <= r_adc_ch ; -- update current conversion 
    
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
      o_adc_data           <= r_adc_data (11 downto 0) ;
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
-- Sampling is start at rising edge of 8Hz, and stop
-- as soon average_end is =1
---------------------------------------------------
process (i_clk,clk8Hz,average_end,conv_enable,ResetA,QA,o_adc_data_valid)
begin
    if    average_end = '1' then
          conv_enable <= '0' ;
    elsif rising_edge  (clk8Hz) then
          conv_enable <= '1' ; -- enable ADC sampling
    end if;      
    if    ResetA='1' then
          QA <= '0';
    elsif rising_edge(conv_enable) then
    	    QA <= '1';
    end if;
    if   rising_edge(i_clk) then
         ResetA<= QA;
    end if;
    conv_start <= QA or (o_adc_data_valid and conv_enable) ;  
end process;

end rtl;
