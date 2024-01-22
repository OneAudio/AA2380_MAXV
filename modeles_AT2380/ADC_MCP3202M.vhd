--------------------------------------------------------------------------------
-- ON le 10/01/2018    -- take 48 LE
-- MCP3202 ADC control block
-- Dual channel 12 bits  ADC with SPI
--
-- for compatibility :
-- 8Hz clock iniate start of n convertions until average_end pulse is active
-- (coming from n samples averager)
--
-- Upated the 10/01 (Version M):
-- a) Remove 1 clock cycle on ADC SPI for 17 cylces.
-- b) signal "adc_chan" is inverted at cycle=2 to be shifted from
-- falling edge of nCS (otherwise there is bad reading of averager)
-- (Note: dataout is updated only 1 clock cycle after rising edge of nCS).
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity ADC_MCP3202M is
port (  clk8Hz      : in std_logic  ; -- start measurement cycle clock input
        clk         : in std_logic  ; -- input clock for ADC
        average_end : in std_logic  ; -- end of averaging pulse to stop converstion process.
        nCS         : out std_logic ; -- ADC chip select
        sck         : out std_logic ; -- ADC channel selection
        sdo         : out std_logic ; -- ADC data output
        din         : in std_logic  ;  -- ADC input data (config)
        adc_chan    : out std_logic ; -- adc channel converted
        dataout     : out std_logic_vector(11 downto 0) -- ADC value output
--        ocycle : out integer range 0 to 18 
        );
end ADC_MCP3202M;

architecture Behavioral of ADC_MCP3202M is

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
--ocycle <= cycle ; -- test

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
        if cycle < 17 then -- check number of cycle
            cycle := cycle + 1 ; -- count number of clk cycle
            nCS <= '0' ; --set chip select signal active (=0)
            case cycle is --  data config bits send to ADC sdo pin
                  when 1 =>  sdo <= '1'; --start bit always = 1
                  when 2 =>  sdo <= '1'; -- SE mode=1 , Diff mode=0
                          channel<= not channel ; -- invert ADC channel selection
                  when 3 =>  sdo <= channel ; --channel0 = 0, channel1 =1
                  when 4 =>  sdo <= '1'; -- MSB fisrt =1
                  when others =>  null;
            end case;
          else
              presentstate <= conversion; -- go to convertion state
              nCS <= '1'; -- chip select disable after 17 clock sycle
              cycle := 0 ; -- reset cycle counter
          end if;
    end if;
    -------------------------------------- 2nd state
    if    presentstate = conversion then       
          dataout <= data ; --data send to output
        if    start='1' then --
              presentstate <= spi;
        end if;
    end if;
end if;
end process;

end Behavioral;
