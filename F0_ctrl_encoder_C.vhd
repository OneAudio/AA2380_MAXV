-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 24/12/2020	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 18 LE.
-- Function F0 :  FO_ctrl_encoder_B.vhd
--
-----------------------------------------------------------------
-- New control fonction for us with new ADC reading block
-- "F1_readADC_multimodes".
-- This new module allow to select independently :
-- 1) Output Sample Rate from 12kHz to 1536 kHz
--    (12,24,48,96,192,384,768,1536).
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
-- Update 'C' 24/03/2025.
--***********************
-- Add external SRcoder input from USBI2S board.
-- Add SRcoder+AVR overrange to limite average value.
----------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity F0_ctrl_encoder_C is
Port (
		-- INPUTS
    CLKSLOW  	: in  std_logic; -- low frequency clock clock (100Hz)
    Ta          : in  std_logic; -- encoder track a input
    Tb		  	: in  std_logic; -- encoder track b input
    nPush   	: in  std_logic; -- encoder nPush switch input
    CONF		: in  std_logic_vector(3 downto 0); -- CONF jumpers inputs
    DFS		   	: in  std_logic_vector(2 downto 0); -- external sampling rate selections inputs
    -- OUTPUTS
    SRcoder       	: buffer std_logic_vector (2 downto 0); -- select SPDIF sampling rate
    AVG      	: out std_logic_vector (2 downto 0); -- select averaging ration of SinC filter
    SEnDIFF 	: buffer std_logic ; -- Single-ended / Differential input mode : Left channel
    HBWon       : buffer std_logic ; -- High bandwidth analog input filter type (0= Low bandwidth 1=High bandwidth) 
    AQMODE      : buffer std_logic ; -- ADC reading mode selection (0=Normal 1=Distributed Read)
    SRnAVG   	: buffer std_logic   -- Output to indicate is SRcoder or AVG is selected (0=SRcoder 1=AVG).
   --TEST SIGNALS

    );
 end F0_ctrl_encoder_C;

architecture select_mode of F0_ctrl_encoder_C is

signal rotary_in        : STD_LOGIC_vector (1 downto 0)  ; -- Vector of the two encoder tracks
signal delay_rotary_q1  : STD_LOGIC  ; --
signal pushf   	    	: STD_LOGIC  ; -- Filtered nPush button
signal Rotate  		    : STD_LOGIC  ; -- pulse output of encoder
signal SEL_SR      	    : integer range 0 to 7 ; -- SRcoder select counter
signal SEL_AVG      	: integer range 0 to 7 ; -- AVG select counter
signal Dir				: STD_LOGIC ;
signal OutOfRange       : STD_LOGIC ;

begin

----------------------------------------------------------
-- Sampling frequency external/internal selection MUX
---------------------------------------------------------
process (CONF(0))
begin
    case(CONF(0)) is
        when '0' => SRcoder <= SRcoder ; -- coder sampling rates setting
        when '1' => SRcoder <= DFS     ; -- external input sampling rates selection
    end case;
end process;
---------------------------------------------------------
--  Detection of maximal value of average for each SRcoder value 
---------------------------------------------------------
process(AVG,SRcoder)
begin
-- Generate OutOfRange signal to detect wrong settings (SRcoder+AVG must be always <8 to have nFS =< 1536kHz)
if (SRcoder+AVG) > 7 then -- condition to detect OutOfRange mode
    OutOfRange <= '1' ; -- detect bad SRcoder/AVG combination => value is OutOfRange
else
    OutOfRange <= '0' ; -- SRcoder/AVG in the range.
end if;
--
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


-- Coder rotating select averaging ratio.
-- To avoid bad combination of AVG/SRcoder.
--
process (Dir,Rotate,SEL_SR,SEL_AVG,SRnAVG)
begin
    if SRnAVG='0' then
        if  rising_edge(Rotate) then
            if    Dir='1' and SEL_SR > 0 then
                  SEL_SR <= SEL_SR - 1 ;
            elsif Dir='0' and SEL_SR < 7 then
                  SEL_SR <= SEL_SR + 1 ;
            end if;
        end if;
		else
  			if  rising_edge(Rotate) then
    				if      Dir='1' and SEL_AVG > 0 then
    						    SEL_AVG <= SEL_AVG - 1 ;
    				elsif   Dir='0' and SEL_AVG < 7 then
    						    SEL_AVG <= SEL_AVG + 1 ;
    				end if;
  			end if;
		end if;
    SRcoder  <= std_logic_vector(to_unsigned(SEL_SR,3))  ; --
    AVG <= std_logic_vector(to_unsigned(SEL_AVG,3)) ; --
end process;
---------------------------------------------------------
-- Each short pulse on encoder nPush button allow
-- to select sampling rate sequencially.
---------------------------------------------------------
process (Pushf,SRnAVG)
begin
    if	 falling_edge(Pushf)	then     -- SRcoder change when push is released
  		   SRnAVG <= not SRnAVG ;        -- Toggle SRcoder/AVG setting
    end if;
end process;
----------------------------------------------------------
-- Config jumpers allow seletion of input coupling and bandwidth for each input channel :.
SEnDIFF	<= CONF(0) ;	--JPA config jumper "SEnDIFF" (single-ended-Differential) : 
HBWon	  <= CONF(1) ;	--JPB config jumper "HBWon" ( Analog input filter bandwidth): Left

-- Jumper unmouted => Distributed Read
-- Jumper mounted  => Normal Read
AQMODE    <= CONF(3) ;  --JPD config jumper to select conversion mode :

end architecture ;
