-----------------------------------------------------------------
--	ON le 08/05/2017
--	Rotary encoder with push button main function
--  Allow to choose and select values for each function :
----------------------------------------------------------------
--  1) SPDIF Sampling rate : 48, 96 or 192 kHz (2 bits)
--  2) SinC averaging filter or FIR filter mode (1 bit)
--  3) Averaging ratio from 1x to 32x selection (3bits)
--  4) AC or DC mode (1 bit)
--  5) Offset calibration process with output cal signal ( 2 bits)
------------------------------------------------------------------
-- 	Take 108 LE.
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
 
 entity EncoderMain is
    Port ( 
           clk  		: in  std_logic; -- 50M input clock
           Ta	 		: in  std_logic; -- encoder track a input
           Tb			: in  std_logic; -- encoder track b input
           push   		: in  std_logic; -- encoder push switch input
           Ready   		: in  std_logic; -- Ready input
           SR       	: buffer std_logic_vector (1 downto 0); -- select SPDIF sampling rate
           AVG      	: out std_logic_vector (2 downto 0); -- select averaging ration of SinC filter
           ACnDC   	 	: buffer std_logic ; -- AC/DC mode selection
           FIRnSinC	 	: buffer std_logic ; -- FIR or SinC filter selection
           CAL      	: buffer std_logic ;  -- DC Calibration mode
           CAL_pulse	: buffer std_logic; -- Pulse for DC calibration process sent to HPF.
           ModeSR		: out std_logic; -- SR mode select indicator
           ModeAVG		: out std_logic; -- AVG mode select indicator
           ModeACDC		: out std_logic; -- AcDC mode select indicator
           ModeFilter	: out std_logic; -- Filter mode select indicator
		   ModeCal		: out std_logic;  -- Cal mode select indicator
		   TestP		: out std_logic;
		   TestD		: out std_logic;  
			Clockslow: out std_logic   -- test clock 100Hz   
    );
 end EncoderMain;
 
architecture select_mode of EncoderMain is
   signal clkslow : STD_LOGIC  ; -- low frequency clock for filtering
   signal countA  : integer range 0 to 1000000 ; -- counter of frequency divider (50M/100Hz= 500000)
   signal count1s : integer range 0 to 100 ; -- counter for 1s push detection
   signal rotary_in        : STD_LOGIC_vector (1 downto 0)  ; -- Vector of the two encoder tracks
	signal delay_rotary_q1  : STD_LOGIC  ; --
   signal pushf   : STD_LOGIC  ; -- Filtered push button
   signal push1s  : STD_LOGIC  ; -- push button press for more than 1s.
   signal Rotate  : STD_LOGIC  ; -- pulse output of encoder
   signal A		  : STD_LOGIC  ; -- divide by 2 variable.
   signal D		  : STD_LOGIC  ; -- variable 
   signal Qtm	  : STD_LOGIC  ; -- variable 
   signal pushB	  : STD_LOGIC  ; -- variable   
   signal Dir     : STD_LOGIC  ; -- Direction of encoder
   signal Funcnt  : integer range 0 to 4 :=0 ; -- functions to be set counter
   signal AVGcnt  : integer range 0 to 5 :=0 ; -- Averaging ratio counter (default value 3= 1x)
   signal SRcnt   : integer range 0 to 3 :=2 ; -- SPDIF frequency counter (default value 2 = 192kHz)
   signal CALtime : integer range 1 to 1024 ; -- Calibration time counter 
   signal CALmax  : integer range 1 to 1024 :=128 ; -- Calibration time max values
   signal StartCAL: STD_LOGIC ; -- latched Calibration start
   signal AVGmax  : integer range 0 to 5 :=0 ; --  maximum value of avreage (depend on Filter type and sampling rate)
   
   
begin

--calibtime <= CALtime;

-----------------------------------------------------------------
-- When ready signal = 1, Generate low frequency clock "clkslow"
-- invert clockslow each 250000 count to get 100Hz output with 50MHz clk
-----------------------------------------------------------------
process (clk, ready)
begin 
Clockslow <= clkslow ; -- output the 100Hz clock
    if rising_edge(clk) and ready ='1' then
        if countA < 250000 then  -- normal value is 250000 !
          countA <= countA +1 ; 
        else 
          countA <= 0 ;-- clear counter
          clkslow <= not clkslow ; -- invert clkslow each half period
        end if;
    end if;
end process;

----------------------------------------------------------
-- Filtering of push button
--  sampled at 100Hz with clkslow
---------------------------------------------------------
process (clkslow)
begin 
    if rising_edge(clkslow) then
    Pushf <= Push;   
    end if;
end process;

----------------------------------------------------------
-- New rotary encoder function from Xilinx app note
-- (Works fine !)
----------------------------------------------------------

rotary_filter: process(clk)
begin
  if clk'event and clk='1' then
      rotary_in <= Ta & Tb;
  case rotary_in is
    when "00" =>  Rotate <= '0';         
                  Dir <= Dir;
    when "01" =>  Rotate <= Rotate;
                  Dir <= '0';
    when "10" =>  Rotate <= Rotate;
                  Dir <= '1';
    when "11" =>  Rotate <= '1';
                  Dir <= Dir; 
    when others => Rotate <= Rotate; 
                  Dir <= Dir; 
  end case;
end if;
end process rotary_filter;

TestP <= Rotate ;
TestD <= Dir ;

----------------------------------------------------------
-- Rotary encoder function
-- Generate pulses for each count and direction indicator
----------------------------------------------------------
--process (clkslow,Taf,Tbf)
--begin
--	if rising_edge(clkslow) then
--		Ar <= (Ar(0)&Taf);
--		Br <= (Br(0)&Tbf);
--		if (Ar = "01") then -- rising edge of A
--			Rotate <= '1';
--			if (Tbf = '0') then Dir <= '1'; -- A leads B
--			else Dir <= '0';					-- B leads A
--			end if;
--		elsif (Ar = "10") then -- falling edge of A
--			Rotate <= '0';
--			if (Tbf = '1') then Dir <= '1'; -- A leads B
--			else Dir <= '0';					-- B leads A
--			end if;
--		elsif (Br = "01") then -- positive edge of B
--			Rotate <= '0';
--			if (Taf = '1') then Dir <= '1'; -- A leads B
--			else Dir <= '0';					-- B leads A
--			end if;
--		elsif (Br = "10") then -- positive edge of B
--			Rotate <= '0';
--			if (Taf = '0') then Dir <= '1'; -- A leads B
--			else Dir <= '0';					-- B leads A
--			end if;
--		else Rotate <= '0';
--		end if;
--	end if;
--end process;

----------------------------------------------------------
-- Detect 1s push and then toggle value of push1s signal
----------------------------------------------------------
process (clkslow,pushf)
begin 
	if pushf = '1' then
		if rising_edge(clkslow) then
			if  count1s = 100 then
				push1s <= not push1s ;  -- signal is inverted after 1s push
				count1s <= 0 ;-- clear counter
			else 
				count1s <= count1s +1 ;-- increment counter
			end if; 
		end if;
	else
		count1s <= 0; -- reset counter when push button is not pressed
end if;
	
end process;
----------------------------------------------------------
--  Function Counter increment/decrement after 1s push.
--  1 ) Increment function with rotary encoder
----------------------------------------------------------
--process (Rotate,Dir,push1s,funcnt)
--begin 
--    if push1s = '1' then
--         if     rising_edge(Rotate) and Dir ='0' and funcnt < 4 then
--                Funcnt <= Funcnt +1 ; -- increment counter
--         elsif  rising_edge(Rotate) and Dir ='1' and funcnt > 0 then            
--                Funcnt <= Funcnt -1 ; -- decrement counter
--         end if;
--    end if;
--end process;
----------------------------------------------------------
--  Function Counter increment/decrement after 1s push.
--  2 ) Increment function with push-button
----------------------------------------------------------
 process (pushf,push1s,funcnt)
 begin 
     if rising_edge(Pushf) and push1s = '1' then
		if   funcnt < 4 then
             Funcnt <= Funcnt +1 ; -- increment counter
		else
             Funcnt <= 0; -- clear to zero
		end if;
     end if;
 end process;

----------------------------------------------------------
--  Function selection using function counter
-- 1 ) Increment function with push-button
----------------------------------------------------------
--SR <= std_logic_vector(to_unsigned(SRcnt,2)) ; -- Convert SRcnt counter value in std_logic
--AVG <= std_logic_vector(to_unsigned(AVGcnt,3)) ; -- Convert AVGcnt counter value in std_logic
--
--process (push1s,Funcnt,pushf)
--begin
--  if push1s ='1' then
--        if 		Funcnt=0 then
--			if rising_edge(pushf) then
--			 	ACnDC <= not ACnDC ; -- toggle AC / DC mode
--			end if;
--        elsif	Funcnt=1 then
--			if rising_edge(pushf) then
--				if 	AVGcnt < 5  then
--				   	AVGcnt <= AVGcnt +1 ; -- increment value of averaging ratio
--				else
--					AVGcnt <= 0;
--				end if;
--			end if;
--        elsif	Funcnt=2 then
--			if rising_edge(pushf) then
--		       	FIRnSinC <= not FIRnSinC ; -- toggle SinC / FIR mode
--			end if;
--        elsif 	Funcnt=3 then
--			if rising_edge(pushf) then
--				CAL <= not CAL ; -- toggle DC Calibrtion mode
--			end if;
--        elsif 	Funcnt=4 then
--			if rising_edge(pushf) then
--				if 	SRcnt < 2 then
--					SRcnt <= SRcnt +1 ;-- increment value of SPDIF sampling frequency
--				else
--					SRcnt <= 0;
--				end if;
--			end if; 		
--        end if;
--  end if; 
--end process;
----------------------------------------------------------
--  Function selection using function counter
-- 2 ) Increment function with rotary encoder
-- Averaging value is limited depending on FS
-- 192 k = 8x max / 96k = 16x max and 48k=32x max
-- and no average in FIR
----------------------------------------------------------
 SR <= std_logic_vector(to_unsigned(SRcnt,2)) ; -- Convert SRcnt counter value in std_logic
 AVG <= std_logic_vector(to_unsigned(AVGcnt,3)) ; -- Convert AVGcnt counter value in std_logic
 
 process (FIRnSinc,AVGcnt,SRcnt,AVGmax)
 begin
 	if	FIRnSinc= '1'then
 		AVGmax <= 1 ; -- no avearging in FIR mode
 	else
 		if SRcnt = 0 then -- 48 kHz sampling rate
 		AVGmax <= 5 ; -- AVG max is 32x  	
 		elsif SRcnt = 1 then -- 96 kHz sampling rate
 		AVGmax <= 4 ; -- AVG max is 16x 
 		elsif SRcnt = 2 then -- 192 kHz sampling rate
 		AVGmax <= 3 ; -- AVG max is 8x 
 		elsif SRcnt = 2 then -- 192 kHz sampling rate
 		AVGmax <= 2 ; -- AVG max is 4x
 		end if;
 	end if;
end process; 
 
 process (push1s,Funcnt,Rotate,Dir,AVGcnt,SRcnt,AVGmax)
 begin
   if push1s ='1' then
     if 	Funcnt=0 then -- Filter type
 		if 	rising_edge(Rotate) and Dir ='0' then
 		 	FIRnSinC <= '0' ; -- SinC Filter mode
 		elsif	rising_edge(Rotate) and Dir ='1' then
 			FIRnSinC <= '1' ; -- FIR Filter mode
 		end if; 			
     elsif	Funcnt=1 then -- Averaging ratio
		if	rising_edge(Rotate) and Dir ='0' and AVGcnt >0 then
			AVGcnt <= AVGcnt -1 ; -- increment value of averaging ratio
      		elsif	rising_edge(Rotate) and Dir ='1' and AVGcnt < AVGmax  then  -- average limited specific max value AVGmax
 			AVGcnt <= AVGcnt +1; -- decrement value of averaging ratio
 		end if;			
     elsif	Funcnt=2 then -- AC or DC mode
  		if 	rising_edge(Rotate) and Dir ='0' then
 			ACnDC <= '0' ; -- DC mode
 		elsif	rising_edge(Rotate) and Dir ='1' then
 			ACnDC <= '1' ; -- AC mode
		end if; 		 
     elsif 	Funcnt=3 then -- DC Calibration
 		if 	rising_edge(Rotate) and Dir ='0' then
 			CAL <= '0' ; -- Calibration mode disable
 		elsif	rising_edge(Rotate) and Dir ='1' then
 			CAL <= '1' ; -- Calibration mode enable
       		end if;
     elsif	Funcnt=4 then -- Output sampling rate
    		if 	rising_edge(Rotate) and Dir ='0' and SRcnt >0 then
 		  	SRcnt <= SRcnt -1 ; 
       		elsif 	rising_edge(Rotate) and Dir ='1' and SRcnt <2 then
 			SRcnt <= SRcnt +1;
 		end if;
     end if; 		
   end if;
 end process;
--------------------------------------------------------------------------
-- Decode counter positions to indicated on display value to be changed
--------------------------------------------------------------------------
process (funcnt,push1s)
begin
	if push1s='1' then -- Enable display blinking only when set mode active
		if 	funcnt=0 then
			ModeACDC 	<= '1';
		else	ModeACDC	<= '0';
		end if;
		if 	funcnt=1 then
			ModeAVG		<= '1';
		else 	ModeAVG		<= '0';
		end if;
		if 	funcnt=2 then
			ModeFilter 	<= '1';
		else 	ModeFilter	<= '0';
		end if;
		if 	funcnt=3 then
			ModeCAL		<= '1';
		else 	ModeCAL		<= '0';
		end if;
		if 	funcnt=4 then
			ModeSR	 	<= '1';
		else 	ModeSR 		<= '0';
		end if;
	else
		ModeACDC	<= '0'; -- no blinking
		ModeAVG		<= '0'; -- no blinking
		ModeFilter	<= '0'; -- no blinking
		ModeCAL		<= '0'; -- no blinking
		ModeSR 		<= '0'; -- no blinking
	end if;
end process;

-------------------------------------------------------------------------
-- Generate CAL_pulse signal when DC calibration is activated
-- Duration depend on sampling rate.
-------------------------------------------------------------------------
calibration_pulse : process (SRcnt,CAL,clkslow,CALtime,CALmax,Qtm,D,StartCAL)
begin 
	case SRcnt is				--Sampling rate select the CALtime value for corresponding pulse width
		when 0 => CALmax <= 1024 ;	--48kHz sampling rate  =10.24s autozero pulse (with clkslow=100Hz)
		when 1 => CALmax <= 512  ;	--96kHz sampling rate  = 5.12s autozero pulse
		when 2 => CALmax <= 256  ;	--192kHz sampling rate = 2.56s autozero pulse
		when 3 => CALmax <= 128  ;	--384kHz sampling rate = 1.28s autozero pulse
	end case;
	if rising_edge(CAL) then -- Wait Calib mode
		StartCAL <= '1'; -- memorize rising edge of cal
	end if;
	if D='1' then -- counter maxval reached
		StartCAL <= '0'; -- clear memorized edge
	end if;
	if rising_edge(clkslow) then
		CAL_pulse <= StartCAL and not Qtm; -- Output pulse=1 until counter maxval reached.
		if 	StartCAL='1' then
			if CALtime > Calmax then -- Counter maxval reached
				Qtm <= '1'; --Stop output pulse
				D <= '1'; -- Clear memorized edge
				CALtime <= 1; -- Clear counter
			else
				Qtm <= '0'; -- Output pulse active
				CALtime <= CALtime +1 ; -- increment counter
			end if;
		else
			CALtime <= 1; -- clear counter when calib not active
			D <= '0'; -- clear reset signal
		end if;
	end if;
end process;

-----------------------------------------------------------------------------
end select_mode;
