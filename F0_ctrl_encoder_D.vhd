-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 24/12/2020	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 34 LE (old 18).
-- Function F0 :  FO_ctrl_encoder_D.vhd
--
-----------------------------------------------------------------
-- New control fonction for us with new ADC reading block
-- "F1_readADC_multimodes".
-- This new module allow to select independently :
-- 1) Output Sample Rate from 48kHz to 768 kHz
--    (48,96,192,384,768).
-- 2) ADC conversion averaging ratio between x1 to x128.
--    (1,2,4,8,16,32,64,128).
-- A short push on encoder button allow to switch between
-- Sampling rate setting or Averaging setting.
--
-- SMD front Leds of AA2380 PCB indicate what is selected :
-- Green => SRcoder , Red=> Average
-- The 2x3 leds on the encoder PCB (AA2380PAN) is used to display
-- values of current SRcoder and AVG value.
--
--
-- NOTE : The conversion mode bewteen Normal/Distributed read is
-- not set with encoder, but using jumper IO.
-- Same for input analog buffer operation (SE/Diff and Filter BW).
----------------------------------------------------------------
-- Update 'C' 26/03/2025.
--***********************
-- Add external SRcoder input from USBI2S board.
-- Add SRcoder+AVR overrange to limite average value.
-- Update 'D' 26/03/2025.
--***********************
-- Whe keep only SR between 48k to 768k according to USBI2S board capability
----------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity F0_ctrl_encoder_D is
Port (
		-- INPUTS
    CLKSLOW  	: in  std_logic; -- low frequency clock clock (100Hz)
    Ta          : in  std_logic; -- encoder track a input
    Tb		  	: in  std_logic; -- encoder track b input
    nPush   	: in  std_logic; -- encoder nPush switch input
    CONF		: in  std_logic_vector(3 downto 0); -- CONF jumpers inputs
    DFS		   	: in integer range 0 to 7 ; -- external sampling rate selections inputs
    -- OUTPUTS
    SRate       : buffer integer range 0 to 7 ; -- select sampling rate
    AVGcoder 	: buffer integer range 0 to 7 ; -- select averaging ration of SinC filter
    SEnDIFF 	: buffer std_logic ; -- Single-ended / Differential input mode : Left channel
    HBWon       : buffer std_logic ; -- High bandwidth analog input filter type (0= Low bandwidth 1=High bandwidth) 
    AQMODE      : buffer std_logic ; -- ADC reading mode selection (0=Normal 1=Distributed Read)
    SRnAVG   	: buffer std_logic   -- Output to indicate is SRcoder or AVG is selected (0=SRcoder 1=AVG).
   --TEST SIGNALS

    );
 end F0_ctrl_encoder_D;

architecture select_mode of F0_ctrl_encoder_D is

signal rotary_in        : STD_LOGIC_vector (1 downto 0)  ; -- Vector of the two encoder tracks
signal delay_rotary_q1  : STD_LOGIC  ; --
signal pushf   	    	: STD_LOGIC  ; -- Filtered nPush button
signal Rotate  		    : STD_LOGIC  ; -- pulse output of encoder
signal SRcoder      	: integer range 0 to 7 :=2 ; -- SRcoder select counter 
signal Dir				: STD_LOGIC ;
signal limit			: integer range 0 to 15 ;

begin

----------------------------------------------------------
-- Filtering of nPush button
-- sampled at 100Hz with clkslow
---------------------------------------------------------
process (clkslow)
begin
    if  rising_edge(clkslow) then
        Pushf <= not nPush; -- nPush is inverted and Filtered
    end if;
end process;
----------------------------------------------------------
-- New rotary encoder function from Xilinx app note
-- (Works fine !)
----------------------------------------------------------
rotary_filter: process(CLKSLOW)
begin
if rising_edge(CLKSLOW) then
    rotary_in <= Ta & Tb; --
case rotary_in is
  when "00"   => Rotate <= '0';
                 Dir <= Dir;
  when "01"   => Rotate <= Rotate;
                 Dir <= '0';
  when "10"   => Rotate <= Rotate;
                 Dir <= '1';
  when "11"   => Rotate <= '1';
                 Dir <= Dir;
  when others => Rotate <= Rotate;
                 Dir <= Dir;
  end case;
end if;
end process rotary_filter;

-----------------------------------------------------------
-- Coder rotating select averaging ratio.
-- To avoid bad combination of AVG/SRcoder.
-----------------------------------------------------------
process (CLKSLOW,Dir,Rotate,SRcoder,AVGcoder,SRnAVG,CONF(0),DFS,SRate,limit)
begin
    if  rising_edge(CLKSLOW) then
        Limit <= (SRate+AVGcoder);
    end if;
    case CONF(0) is
        when '0' => SRate <= SRcoder;
        when '1' => SRate <= DFS ;
    end case;
    --
    if SRnAVG='0' and CONF(0)='0' then -- Choose Sampling rate value with coder (only internal mode; conf0=0)
        if  Limit>7 then
            AVGcoder <= 7-SRate ; -- reset average if behond the limit when external FS is selected.
        elsif  rising_edge(Rotate) then
            -- SR coder values are bounded between 2 and 7 (48k to 768k) 
            if  Dir='1' and SRcoder > 2 then
                SRcoder <= SRcoder - 1 ;
            elsif Dir='0' and SRcoder<6 and Limit<7 then
                SRcoder <= SRcoder + 1 ;
            end if;
        end if;
    else                -- Choose averaging value with coder.
        if  Limit>7 then
            AVGcoder <= 7-SRate ; -- reset average if behond the limit when external FS is selected.
        elsif  rising_edge(Rotate) then 
            if  Dir='1' and AVGcoder > 0 then
                AVGcoder <= AVGcoder - 1 ;
            elsif   Dir='0' and Limit<7 then
                AVGcoder <= AVGcoder + 1 ;
            end if;
        end if;
    end if;
end process;
---------------------------------------------------------
-- Each short pulse on encoder nPush button allow
-- to select sampling rate sequencially.
---------------------------------------------------------
process (Pushf,SRnAVG,CONF(0))
begin
    if      CONF(0)='1'  then
            SRnAVG <= '0';--reset 
    elsif   falling_edge(Pushf)	then     -- SRcoder change when push is released
  		    SRnAVG <= not SRnAVG ;        -- Toggle SRcoder/AVG setting
    end if;
end process;
----------------------------------------------------------
-- Config jumpers allow seletion of input coupling and bandwidth for each input channel :.
SEnDIFF	<= CONF(1) ;	--JPA config jumper "SEnDIFF" (single-ended-Differential) : 
HBWon	  <= CONF(2) ;	--JPB config jumper "HBWon" ( Analog input filter bandwidth): Left

-- Jumper unmouted => Distributed Read
-- Jumper mounted  => Normal Read
AQMODE    <= CONF(3) ;  --JPD config jumper to select conversion mode :

end architecture ;
