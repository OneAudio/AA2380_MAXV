-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 19/09/19	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 44 LE.
-- Function F0 :  FO_ctrl_encoder.vhd
-----------------------------------------------------------------
-- Allow to choose and select values for each function
-- using jumper on connectors J17 (config jumpers)
-- and connectors J12 (unisolated OPT I/O).
-- Only calibration require encoder push (1s).
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
-- Sampling can be selected by encoder push, or it is controlled
-- by SDR-widget directly if EN_ext is active (SDR board detected
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
    push   		: in  std_logic; -- encoder push switch input
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
    CAL_pulse	: buffer std_logic	 -- Pulse for DC calibration process ent to HPF.
		   --TEST SIGNALS

    );
 end F0_ctrl_encoder;

architecture select_mode of F0_ctrl_encoder is

signal pushcnt			: integer range 0 to 3 ; -- counter for SR selection
signal count1s 			: integer range 0 to 100 ; -- counter for 1s push detection
signal rotary_in        : STD_LOGIC_vector (1 downto 0)  ; -- Vector of the two encoder tracks
signal delay_rotary_q1  : STD_LOGIC  ; --
signal pushf   			: STD_LOGIC  ; -- Filtered push button
signal Rotate  			: STD_LOGIC  ; -- pulse output of encoder
signal D		 		: STD_LOGIC  ; -- variable
signal Qtm	  			: STD_LOGIC  ; -- variable
signal sel_AVG 			: STD_LOGIC_vector (2 downto 0); -- Averaging ratio counter (default value 3= 1x)
signal CALtime 			: integer range 0 to 255 ; -- Calibration time counter
signal CALmax  			: integer range 0 to 255 :=127 ; -- Calibration time max values
signal StartCAL			: STD_LOGIC ; -- latched Calibration start

begin


----------------------------------------------------------
-- Filtering of push button
-- sampled at 100Hz with clkslow
---------------------------------------------------------
process (clkslow)
begin
    if rising_edge(clkslow) then
    Pushf <= not Push; -- push is inverted and Filtered
    end if;
end process;

---------------------------------------------------------
-- Each short pulse on encoder Push button allow
-- to select sampling rate sequencially/
-- If EN_ext is active (SDR board is connected)
-- then SR follow EXT_SR selection bits.
---------------------------------------------------------
process (Pushf,pushcnt,EXT_SR,EN_ext)
begin
	if	rising_edge(Pushf)	then
		if	pushcnt < 3	then
			pushcnt <= pushcnt + 1 ;
		else
			pushcnt <= 0 ;
		end if;
	end if;
	if EN_ext='0'	then-- Sampling  rate is selected by ncoder push button
		case pushcnt is
			when 0 => SR <= "00" ; -- 48k
			when 1 => SR <= "01" ; -- 96k
			when 2 => SR <= "10" ; -- 192k
			when others => SR <= "00" ;
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
-- Config jumpers allow seletion of input coupling and bandwidth for each input channe :.
SEnDIFFL 	<= CONF(0) ;	--JPA config jumper "SEnDIFF" (single-ended-Differential) : Left
HBWonL	  <= CONF(1) ;	--JPB config jumper "HBWon" ( Analog input filter bandwidth): Left
SEnDIFFR 	<= CONF(2) ;	--JPC config jumper "SEnDIFF" (single-ended-Differential) : Right
HBWonR	  <= CONF(3) ;	--JPD config jumper "HBWon" ( Analog input filter bandwidth) : Right

-- Others jumpers on JP12 connector
sel_AVG		<= UIO (2 downto 0) ;	-- send UIO jumper 0-1-2 to averaging value
FIRnSinC	<= UIO (3) ;			-- send UIO jumper 3 to FIRnSinC (Digital filter type)

-- Set AVG value depending on sampling rate and filter type
-- Averaging ratio (AVG) x Sampling rate (SR) equal always 1536 kHz.
process (sel_AVG,SR)
begin
	if		SR="00" then		-- 48kHz / AVG max is 32x
				case sel_AVG is
					when "000" => AVG <= "000" ; -- avg= 1x
					when "001" => AVG <= "001" ; -- avg= 2x
					when "010" => AVG <= "010" ; -- avg= 4x
					when "011" => AVG <= "011" ; -- avg= 8x
					when "100" => AVG <= "100" ; -- avg= 16x
					when ("101" or "111") => AVG <= "101" ; -- avg= 32x ("111"=auto avg mode)
					when others => AVG <= "000";
				end case;
	elsif	SR="01" then		-- 96kHz / AVG max is 16x
				case sel_AVG is
					when "000" => AVG <= "000" ; -- avg= 1x
					when "001" => AVG <= "001" ; -- avg= 2x
					when "010" => AVG <= "010" ; -- avg= 4x
					when "011" => AVG <= "011" ; -- avg= 8x
					when ("100" or "111") => AVG <= "100" ; -- avg= 16x ("111"=auto avg mode)
					when "101" => AVG <= "100" ; -- avg= 16x
					when others => AVG <= "000";
				end case;
	elsif	SR="10" then		-- 192kHz / AVG max is 8x
				case sel_AVG is
					when "000" => AVG <= "000" ; -- avg= 1x
					when "001" => AVG <= "001" ; -- avg= 2x
					when "010" => AVG <= "010" ; -- avg= 4x
					when ("011" or "111") => AVG <= "011" ; -- avg= 8x ("111"=auto avg mode)
					when "100" => AVG <= "011" ; -- avg= 8x
					when "101" => AVG <= "011" ; -- avg= 8x
					when others => AVG <= "000";
				end case;
	else					    	-- 384kHz / AVG max is 4x
    		case sel_AVG is
    			when "000" => AVG <= "000" ; -- avg= 1x
    			when "001" => AVG <= "001" ; -- avg= 2x
    			when ("010" or "111") => AVG <= "010" ; -- avg= 4x ("111"=auto avg mode)
    			when "011" => AVG <= "010" ; -- avg= 4x
    			when "100" => AVG <= "010" ; -- avg= 4x
    			when "101" => AVG <= "010" ; -- avg= 4x
    			when others => AVG <= "000";
    		end case;
	end if;
end process;


-------------------------------------------------------------------------
-- Generate CAL_pulse signal when DC calibration is activated
-- Duration depend on sampling rate.
-- clkslow = 100Hz (T= 10ms)
-- RC@48k = 1.36 s
-- RC@96k = 0.683 s
-- RC@192k= 0.341 s
-------------------------------------------------------------------------
process (pushf,SR,clkslow,CALtime,CALmax,Qtm,D,StartCAL)
begin
	--Sampling rate select the CALtime value for corresponding pulse width
	case SR is
		when "00" => CALmax <= 136 ;	--48kHz sampling rate  = 1.360 s autozero pulse (with clkslow=100Hz)
		when "01" => CALmax <=  68  ;	--96kHz sampling rate  = 0.683 s autozero pulse (with clkslow=100Hz)
		when "10" => CALmax <=  34  ;	--192kHz sampling rate = 0.341 s autozero pulse (with clkslow=100Hz)
		when "11" => CALmax <=  17  ;	--384kHz sampling rate = 0.170 s autozero pulse (with clkslow=100Hz)
	end case;

	-- Generate a StartCAL pulse when pushf is active for 1s.
	if D= '0'	then
		if pushf = '1' then
			if rising_edge(clkslow) then
				if  count1s = 100 then
					StartCAL <= '1';  --
					count1s  <= 0 ;-- clear counter
				else
					count1s <= count1s +1 ;-- increment counter
				end if;
			end if;
		else
			count1s <= 0; -- reset counter when push button is not pressed
		end if;
	else
		StartCAL <= '0';  --clear counter
	end if;

	if rising_edge(clkslow) then
		CAL_pulse <= StartCAL and not Qtm; -- Output pulse=1 until counter maxval reached.
		if 	StartCAL='1' then
			if CALtime = Calmax then -- Counter maxval reached
				Qtm <= '1'; --Stop output pulse
				D <= '1'; -- Clear memorized edge
				CALtime <= 0; -- Clear counter
			else
				Qtm <= '0'; -- Output pulse active
				CALtime <= CALtime +1 ; -- increment counter
			end if;
		else
			CALtime <= 0; -- clear counter when calib not active
			D <= '0'; -- clear reset signal
		end if;
	end if;
end process;

end architecture ;
