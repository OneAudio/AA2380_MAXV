-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 26/10/19	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 37 LE.
-- Function F0 :  FO_ctrl_encoder.vhd
-----------------------------------------------------------------
-- Allow to choose and select values for each function
-- using jumper on connectors J17 (config jumpers)
-- and connectors J12 (unisolated OPT I/O).
-- Only calibration require encoder nPush (1s).
----------------------------------------------------------------
-- 0) SPDIF Sampling rate : 48, 96 or 192 kHz (2 bits)
-- 1) SinC averaging filter or FIR filter mode (1 bit)
-- 2) Averaging ratio from 1x to 32x selection (3bits)
	  --> the ratio depend on SR value : (ratio*SR) = 1536 kHz
-- 3) SE/Diff input and HPF filter selection
-- 4) Low or high bandwidth analog filter type
-- 5) Digital HPF mode *optional future use*
-- 6) DC offset calibration process
-- 7) if digital averaging value bits (UIO) are ='111', then the
--    averaging mode is autoset for real SR=1536kHz
--    Then for nFS=1536kHz :
--    48kHz@ avg=32x / 96kHz@ avg=16x / 192kHz@ avg=8x
-----------------------------------------------------------------
-- Sampling can be selected by encoder nPush, or it is controlled
-- by SDR-widget directly if EN_ext is active (SDR board detected
-----------------------------------------------------------------
-- 26/10/19,avoid SR change when long nPush is initiate for calib
-- 27/10/19, add control of averaging with coder rotating
-----------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity F0_ctrl_encoder is
Port (
		-- INPUTS
    CLKSLOW  	: in  std_logic; -- low frequency clock clock (100Hz)
    Ta	 		  : in  std_logic; -- encoder track a input
    Tb		  	: in  std_logic; -- encoder track b input
    nPush   		: in  std_logic; -- encoder nPush switch input
    CONF			: in  std_logic_vector(3 downto 0); -- CONF jumpers inputs
    UIO		   	: in  std_logic_vector(3 downto 0); -- UIO  jumpers inputs
    EXT_SR		: in  std_logic_vector(1 downto 0); -- external sampling rate selection
    EN_ext		: in  std_logic; -- external sampling enable mode (active high)
    -- OUTPUTS
    SR       	: buffer std_logic_vector (1 downto 0); -- select SPDIF sampling rate
    AVG      	: out std_logic_vector (2 downto 0); -- select averaging ration of SinC filter
    SEnDIFFL 	: buffer std_logic ; -- Single-ended / Differential input mode : Left channel
    SEnDIFFR 	: buffer std_logic ; -- Single-ended / Differential input mode : Right channel
    HBWonL	  : buffer std_logic ; -- High bandwidth analog input filter type (0= Low bandwidth 1=High bandwidth) : Left channel
    HBWonR	  : buffer std_logic ; -- High bandwidth analog input filter type (0= Low bandwidth 1=High bandwidth) : Right channel
    FIRnSinC 	: buffer std_logic ; -- FIR or SinC filter selection (0=SInC 1=FIR)
    Push2s     	: buffer std_logic -- Pulse when push button of rotary encoderis press for more than 2s
		   --TEST SIGNALS
--       Blank : buffer std_logic --
    );
 end F0_ctrl_encoder;

architecture select_mode of F0_ctrl_encoder is

signal pushcnt			: integer range 0 to 3 ; -- counter for SR selection
signal count2s 			: integer range 0 to 255 ; -- counter for 2s nPush detection
signal delay        : integer range 0 to 31 ; --delay
signal rotary_in        : STD_LOGIC_vector (1 downto 0)  ; -- Vector of the two encoder tracks
signal delay_rotary_q1  : STD_LOGIC  ; --
signal pushf   			: STD_LOGIC  ; -- Filtered nPush button
signal Rotate  			: STD_LOGIC  ; -- pulse output of encoder
signal sel_AVG 			: integer range 0 to 7 ; -- Averaging ratio counter
signal Dir					: STD_LOGIC ;
signal CntEnd      	: STD_LOGIC ;
signal Start		: STD_LOGIC ;
signal blank		: STD_LOGIC ;


begin


----------------------------------------------------------
-- Filtering of nPush button
-- sampled at 100Hz with clkslow
---------------------------------------------------------
process (clkslow)
begin
    if rising_edge(clkslow) then
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
process (Dir,Rotate,sel_AVG)
begin
  if  rising_edge(Rotate) then
      if    Dir='0' and sel_AVG > 0 then
            sel_AVG <= sel_AVG - 1 ;
      elsif Dir='1' and sel_AVG < 5 then
            sel_AVG <= sel_AVG + 1 ;
      end if;
  end if;
end process;
---------------------------------------------------------
-- Each short pulse on encoder nPush button allow
-- to select sampling rate sequencially.
-- If EN_ext is active (SDR board is connected)
-- then SR follow EXT_SR selection bits.
---------------------------------------------------------
process (Pushf,pushcnt,EXT_SR,EN_ext,Push2s,blank)
begin
  if Blank='0' then                -- SR can be changed only is no calib is active.
	   if	falling_edge(Pushf)	then      -- SR change when push is released
		     if	pushcnt < 3	then
			      pushcnt <= pushcnt + 1 ;
		     else
			      pushcnt <= 0 ;
         end if;
	   end if;
  end if;
	if EN_ext='0'	then-- Sampling  rate is selected by ncoder nPush button
		case pushcnt is
			when       0 => SR <= "00" ; -- 48k
			when       1 => SR <= "01" ; -- 96k
			when       2 => SR <= "10" ; -- 192k
			when others  => SR <= "00" ;
		end case;
	else  				-- Sampling  rate is coming from SDR-widget
		SR	<= EXT_SR ;
	end if;
end process;

----------------------------------------------------------
-- SinC filter averaging value is limited depending on FS
-- 192 k = 8x max / 96k = 16x max and 48k=32x max
-- and no average in FIR.
----------------------------------------------------------
-- Config jumpers allow seletion of input coupling and bandwidth for each input channel :.
SEnDIFFL 	<= CONF(0) ;	--JPA config jumper "SEnDIFF" (single-ended-Differential) : Left
HBWonL	  <= CONF(1) ;	--JPB config jumper "HBWon" ( Analog input filter bandwidth): Left
SEnDIFFR 	<= CONF(0) ;	--JPC config jumper "SEnDIFF" (single-ended-Differential) : Right
HBWonR	  <= CONF(1) ;	--JPD config jumper "HBWon" ( Analog input filter bandwidth) : Right



-- Others jumpers on JP12 connector
-- sel_AVG		<= UIO (2 downto 0) ;	-- send UIO jumper 0-1-2 to averaging value
FIRnSinC	<= UIO (3) ;			-- send UIO jumper 3 to FIRnSinC (Digital filter type)

-- Set AVG value depending on sampling rate and selected averaging values
process (sel_AVG,SR)
begin
	if		SR="00" then		-- 48kHz / AVG max is 32x
				case sel_AVG is
					when 0 => AVG <= "000" ; -- avg= 1x
					when 1 => AVG <= "001" ; -- avg= 2x
					when 2 => AVG <= "010" ; -- avg= 4x
					when 3 => AVG <= "011" ; -- avg= 8x
					when 4 => AVG <= "100" ; -- avg= 16x
					when others => AVG <= "101";-- avg= 32x
				end case;
	elsif	SR="01" then		-- 96kHz / AVG max is 16x
				case sel_AVG is
					when 0 => AVG <= "000" ; -- avg= 1x
					when 1 => AVG <= "001" ; -- avg= 2x
					when 2 => AVG <= "010" ; -- avg= 4x
					when 3 => AVG <= "011" ; -- avg= 8x
					when others => AVG <= "100"; -- avg= 16x
				end case;
	elsif	SR="10" then		-- 192kHz / AVG max is 8x
				case sel_AVG is
					when 0 => AVG <= "000" ; -- avg= 1x
					when 1 => AVG <= "001" ; -- avg= 2x
					when 2 => AVG <= "010" ; -- avg= 4x
					when others => AVG <= "011";-- avg= 8x
				end case;
	else					    	-- 384kHz / AVG max is 4x
    		case sel_AVG is
    			when 0 => AVG <= "000" ; -- avg= 1x
    			when 1 => AVG <= "001" ; -- avg= 2x
    			when others => AVG <= "010";-- avg= 4x
    		end case;
	end if;
end process;

-------------------------------------------------------------------------
-- Generate a pulse signal when long push on rotatry encoder,
-- to start DC calibration process
 -- (and a longer pulse (blank) to disable the short pulse detection.)
-------------------------------------------------------------------------
process (pushf,clkslow,Push2s,delay,Blank,CntEnd,Start)
begin
	-- Generate a  pulse when pushf is active for >2s.
	if pushf = '1' then
		if rising_edge(clkslow) then -- 100Hz clock
			if  count2s = 200 then -- wait 2s
				  Push2s   <= '1';  -- Push2s active is push for more than 2s.
			else
				  count2s <= count2s +1 ;-- increment counter
			end if;
		end if;
	else
		count2s  <= 0  ; -- reset counter when nPush button is not pressed
    Push2s   <= '0'; -- reset Push2s
	end if;
  --
  -- DElay to avoid  changing SR when long push
  if    CntEnd= '1'  Then -- end of count
        Start <= '0'; -- reset
  elsif rising_edge(Push2s) then
        Start <= '1';
  end if;
  --
  if rising_edge(clkslow) then
      if    Start='0'  Then
            Delay <=  0 ; -- reset delay counter
            CntEnd <= '0' ;
      elsif Push2s='0' then -- 100Hz clock
            Delay <= Delay + 1 ; -- increment counter
            if  Delay = 15 Then
                CntEnd <= '1' ; -- delay end
            end if;
      end if;
  end if;
  Blank <= not CntEnd and Start ; -- Blank is longer than Push2s to disable SR short push detection.


end process;
end architecture ;
