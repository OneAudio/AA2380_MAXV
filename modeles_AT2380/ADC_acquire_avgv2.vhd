--------------------------------------------------------------------------------
-- Top module : ADC_acquire_avg
-- ON le 21/09/2017
--  top module("ADC reac-write" and "averaging 32 values") entity declaration
--  Version 2.00     with variable averaging generic parameter
--
--This module allow reading of MCP3202 two channel ADC, compute the difference
-- between ch1-ch0 and compute the avrage of 32 samples with 9 bits output.
-- The 32 acquistions are made at each rising edge of clk8Hs and take less
-- than 6ms (32 samples) with a 4MHz i_clk and clk_div=20 (200kHz/5us ADC clock)
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ADC_acquire_avgv2 is
generic(
            nAVG           : integer := 5 );
port (
      i_clk           : in  std_logic; -- main clock (divided by CLK_DIV for SPI) = 2MHz
      clk8Hz          : in  std_logic; -- 8 Hz clock to initate start of burst sampling
      o_sclk          : out std_logic; -- ADC clock
      o_ss            : out std_logic; -- ADC /Chip Select (/CS)
      o_mosi          : out std_logic; -- ADC Data in
      i_miso          : in  std_logic;-- ADC Data out
      output		      : out signed(8 downto 0) -- n samples averaged signed 12 bits data output (ch1-ch0)
      ----Test outputs only ---------
--      average_stop     : out std_logic;  -- pulse signal to indicate end of averaging process
--      difference      : out signed(11 downto 0); -- test output
--      average         : out integer range 0 to 33; -- test output
--      somme           : out signed(16 downto 0) -- test output
  );
end ADC_acquire_avgv2 ;
--top module architecture declaration.
architecture behavior of ADC_acquire_avgv2 is

 -- ADC read and write of two muxed channels
    component ADC_MCP3202_Burst
    port(
      clk8Hz                      : in  std_logic; -- 8 Hz clock to initate start of burst sampling
      average_end                 : in  std_logic; -- Pulse to indicate end of averaging process 
      i_clk                       : in  std_logic; -- main clock (divided by CLK_DIV for SPI) = 2MHz
      o_adc_data_valid            : buffer std_logic;  -- conversion valid pulse
      o_adc_ch                    : out std_logic;  -- ADC converted channel
      o_adc_data                  : out std_logic_vector(11 downto 0); -- adc parallel data
      o_sclk                      : out std_logic; -- ADC clock
      o_ss                        : out std_logic; -- ADC /Chip Select (/CS)
      o_mosi                      : out std_logic; -- ADC Data in
      i_miso                      : in  std_logic-- ADC Data out
    );
    end component;
    
    -- demux and averaging filter module
    component avg32x_filterv2
    generic(
            avg_2n           : integer := nAVG );
    port(
      i_clk           : in  std_logic; -- master clock
      ADC_data_valid 	: in  std_logic; -- data valid signal (to latch channel data)
      ADC_channel    	: in  std_logic; -- ADC Channel 0(offset)/1(dBV) input
      ADC_data       	: in  std_logic_vector (11 downto 0); -- ADC DATA for both channels
      output		      : out signed(8 downto 0); -- n samples averaged signed 12 bits data output (ch1-ch0)
      average_end     : out std_logic  -- pulse signal to indicate end of averaging process
      -- Test I/O
      ----------------------------------------------------------
--      difference      : out signed(11 downto 0); -- test output
--      average         : out integer range 0 to 33;-- test output
--      somme           : out signed(16 downto 0) -- test output)
    );
    end component;
    
--All the signals are declared here,which are not a part of the top module(internal signals between components)..
signal    ADC_data          :std_logic_vector(11 downto 0)  :=x"000";
signal    ADC_data_valid    :std_logic :='0' ;
signal    ADC_channel       :std_logic :='0' ;
signal    average_end       :std_logic :='0' ;


----------------------------------------------------------
----------------------------------------------------------
begin
    
--instantiate and do port map for ADC_MCP3202_Burst.
-------------------------------------------------
MOD1 : ADC_MCP3202_Burst port map (
      clk8Hz          =>  clk8Hz         ,
      average_end     =>  average_end    ,
      i_clk           =>  i_clk          ,
      o_adc_data_valid=>  ADC_data_valid ,
      o_adc_ch        =>  ADC_channel    ,
      o_adc_data      =>  ADC_data       ,
      o_sclk          =>  o_sclk         ,
      o_ss            =>  o_ss           ,
      o_mosi          =>  o_mosi         ,
      i_miso          =>  i_miso 
    );
       
--instantiate and do port map for avg32x_filter
-------------------------------------------------
MOD2 : avg32x_filterv2 port map (
      i_clk           =>  i_clk           ,                                      
      ADC_data_valid  =>  ADC_data_valid  ,                                                     
      ADC_channel     =>  ADC_channel     ,                                                  
      ADC_data        =>  ADC_data        ,                                             
      output		      =>  output        ,                                           
      average_end     =>  average_end                                                
--      difference      =>  difference      ,                                        
--      average         =>  average         ,                                       
--      somme           =>  somme                                                  
    );

--average_stop  <=  average_end ;
                                                                              
end;            