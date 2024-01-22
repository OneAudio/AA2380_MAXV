--------------------------------------------------------------------------------
-- Top module : ADC_ACQ_4x_V1
-- ON le 13/01/18
-- Take 115 LE
--
--  top module("ADC_MCP3202M" and "avg4x_filter_V1") entity declaration
--  Version 1.00
--
-- This module allow reading of MCP3202 two channel ADC, compute the difference
-- between ch1-ch0 and compute the avrage of 4 samples with 9 bits output.
-- The 4 acquistions are made at each rising edge of clk8Hw and take less
-- than Xms (4 samples) with a xMHz clk  (kHz/us ADC clock)
--
-- Modified the 13/12/17 to add diff output and ADC_channel signals.
-- Adding direct output of the ADC values (for debug purpose)
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ADC_ACQ_4x_V1 is
port (
      clk             : in  std_logic; -- main SPI clock
      clk8Hz          : in  std_logic; -- 8 Hz clock to initate start of burst sampling
      sck             : out std_logic; -- ADC clock
      nCS             : buffer std_logic; -- ADC /Chip Select (/CS)
      sdo             : out std_logic; -- ADC Data out
      din             : in  std_logic;-- ADC Data in
      adc_channel     : buffer  std_logic;-- ADC selected channel
      difference      : out signed(11 downto 0); -- ADC (ch1-ch0) value
      datafilt		    : out signed(8 downto 0); -- n samples averaged signed 12 bits data output (ch1-ch0)
      ADCmuxdata      : out std_logic_vector(8 downto 0) -- direct 9 bits output of muxed values of ADC.   
      ----Test outputs only ---------
--      average_stop     : out std_logic;  -- pulse signal to indicate end of averaging process
--      difference      : out signed(11 downto 0); -- test output
--      average         : out integer range 0 to 33; -- test output
--      somme           : out signed(16 downto 0) -- test output
  );
end ADC_ACQ_4x_V1 ;
--top module architecture declaration.
architecture behavior of ADC_ACQ_4x_V1 is

 -- ADC read and write of two muxed channels
    component ADC_MCP3202M
    port(
      clk8Hz      : in std_logic  ; -- start measurement cycle clock input
      clk         : in std_logic  ; -- input clock for ADC
      average_end : in std_logic  ; -- end of averaging pulse to stop conver
      nCS         : out std_logic ; -- ADC chip select
      sck         : out std_logic ; -- ADC channel selection
      sdo         : out std_logic ; -- ADC data output
      din         : in std_logic  ;  -- ADC input data (config)
      adc_chan    : out std_logic ; -- adc channel converted
      dataout     : out std_logic_vector(11 downto 0) -- ADC value output
    );
    end component;

    -- demux and averaging filter module
    component avg4x_filter_V1
    port(
      i_clk           : in  std_logic; -- master clock
      nCS 	: in  std_logic; -- data valid signal (to latch channel data)
      ADC_channel    	: in  std_logic; -- ADC Channel 0(offset)/1(dBV) input
      ADC_data       	: in  std_logic_vector (11 downto 0); -- ADC DATA for both channels
      output		      : out signed(8 downto 0); -- n samples averaged signed 12 bits data output (ch1-ch0)
      average_end     : out std_logic ;  -- pulse signal to indicate end of averaging process
-- Test I/O
----------------------------------------------------------
      difference      : out signed(11 downto 0) -- test output
--      average         : out integer range 0 to 33;-- test output
--      somme           : out signed(16 downto 0) -- test output)
    );
    end component;

--All the signals are declared here,which are not a part of the top module(internal signals between components)..
signal    ADC_data          :std_logic_vector(11 downto 0)  :=x"000";
--signal    nCS    :std_logic :='0' ;
--signal    ADC_channel       :std_logic :='0' ;
signal    average_end       :std_logic :='0' ;
--signal 	 ADCmuxdata			:std_logic_vector(8 downto 0) ;



----------------------------------------------------------
----------------------------------------------------------
begin

--instantiate and do port map for ADC_MCP3202L.
-------------------------------------------------
MOD1 : ADC_MCP3202M port map (
      clk8Hz       =>  clk8Hz         ,
      clk          =>  clk            ,
      average_end  =>  average_end    ,
      nCS          =>  nCS            ,
      sck          =>  sck            ,
      sdo          =>  sdo            ,
      din          =>  din            ,
      adc_chan     =>  ADC_channel    ,
      dataout      =>  ADC_data       );
      

--instantiate and do port map for avg32x_filter
-------------------------------------------------
MOD2 : avg4x_filter_V1 port map (
      i_clk           =>  clk            ,
      nCS  =>  nCS        ,
      ADC_channel     =>  ADC_channel    ,
      ADC_data        =>  ADC_data       ,
      output		    =>  datafilt      ,
      average_end     =>  average_end    ,                                            
      difference      =>  difference     
--      average         =>  average      ,
--      somme           =>  somme
    );

--average_stop  <=  average_end ;
ADCmuxdata <= ADC_data (11 downto 3) ; --

end;
