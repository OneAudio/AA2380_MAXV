--------------------------------------------------------------------------------
--  ON le 12/10/2017     -- take 48 LE
-- MCP3202 ADC control block - UNTESTED !!!
-- Dual channel 12 bits  ADC with SPI
--
-- for compatibility :
-- 8Hz clock must iniate start of n convertions until
-- average_end pulse active (coming from 32 samples averager)
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity ADC_MCP3202L is
port (  clk8Hz      : in std_logic  ; -- start measurement cycle clock input
        clk         : in std_logic  ; -- input clock for ADC
        average_end : in std_logic  ; -- end of averaging pulse to stop converstion process.
        nCS         : out std_logic ; -- ADC chip select
        sck         : out std_logic ; -- ADC channel selection
        sdo         : out std_logic ; -- ADC data output
        din         : in std_logic  ;  -- ADC input data (config)
        adc_chan    : out std_logic ; -- adc channel converted
        dataout     : out std_logic_vector(11 downto 0)); -- ADC value output
--         ocycle : out integer range 0 to 18 );

end ADC_MCP3202L;

architecture Behavioral of ADC_MCP3202L is

type state is (spi,conversion); -- states of  machine
signal presentstate : state := spi;
signal channel      : std_logic :='0'; -- ADC channel selection bit
signal start        : std_logic :='0'; -- Start signal that enable convertion process

begin

process(clk,channel,start,clk8Hz,average_end)
variable cycle : integer range 0 to 18 := 0; -- SPI clock cylce counter
variable data : std_logic_vector(11 downto 0) := "000000000000"; -- data buffer

begin
sck <= clk ;
adc_chan <= not channel;

if    average_end='1' then
      start <= '0';-- convertion is stoped when average_end active
elsif rising_edge(clk8Hz) then
	    start <= '1';-- convertion is started each rising of clk8Hz
end if;

-- data are retreived on rising edge of clk
if clk'event and clk = '1' then
    case cycle is -- store ADC din values to tot (12 bits)
          when 6  => data(11) := din;
          when 7  => data(10) := din;
          when 8  => data(9)  := din;
          when 9  => data(8)  := din;
          when 10 => data(7)  := din;
          when 11 => data(6)  := din;
          when 12 => data(5)  := din;
          when 13 => data(4)  := din;
          when 14 => data(3)  := din;
          when 15 => data(2)  := din;
          when 16 => data(1)  := din;
          when 17 => data(0)  := din;
          when others => null;
    end case;
end if;

-- all synchronous to falling edge of clk
if clk'event and clk = '0' then
    -------------------------------------- first state
    if presentstate = spi then
        cycle := cycle + 1 ; -- count number of clk cycle
        if cycle < 18 then
            nCS <= '0' ; --set chip select signal active (=0)
            case cycle is --  data config bits send to ADC sdo pin
                  when 1 =>  sdo <= '1'; --start bit always = 1
                          channel <= not channel ; -- invert ADC channel selection
                  when 2 =>  sdo <= '1'; -- SE mode=1 , Diff mode=0
                  when 3 =>  sdo <= channel ; --channel0 = 0, channel1 =1
                  when 4 =>  sdo <= '1'; -- MSB fisrt =1
                  when others =>  null;
            end case;
          else
              presentstate <= conversion; -- go to convertion state
              cycle := 0 ;
          end if;
    end if;
    -------------------------------------- 2nd state
    if    presentstate = conversion then
      nCS <= '1'; -- chip select disable
      dataout <= data ; --data send to output
        if    start='1' then --
              presentstate <= spi;
        end if;
    end if;
end if;
end process;

end Behavioral;
