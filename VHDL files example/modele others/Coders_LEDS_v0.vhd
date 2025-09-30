-----------------------------------------------------
-- O.Narce the 15-05-2019 *** OSVA ** AA2380v1 TEST.
-- take 52 LE
-- Rotary encoder + push button and leds test
-----------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity  Coders_LEDS_v0  is
   port(CLOCK1M				:	in	std_logic	; 	-- 1MHz clock input
   		CLOCK10kHz			:	in	std_logic	; 	-- 10kHz clock input
		CLOCK10Hz			:	in	std_logic	; 	-- 10Hz clock input
		CLOCK1Hz			:	in	std_logic	; 	-- 1Hz clock input
   		CODER_TA			:	in std_logic	;	-- Rotary encoder track A
		CODER_TB			:	in std_logic	;   -- Rotary encoder track B
		CODER_PUSH			:	in std_logic	;   -- Rotary encoder push button
		CONF_0				:	in std_logic	;   -- Config jumper 0 (internal pull-up)
		CONF_1				:	in std_logic	;   -- Config jumper 1 (internal pull-up)
		CONF_2				:	in std_logic	;   -- Config jumper 2 (internal pull-up)
		CONF_3				:	in std_logic	;   -- Config jumper 3 (internal pull-up)
		CLK_EXT				:	in std_logic	;   -- isolated external clock (1MHz to 100MHz)
		LED_48K				: 	out std_logic	;	-- LED 48kHz			
		LED_96K				: 	out std_logic	;	-- LED 96kHz
		LED_192K			: 	out std_logic	;	-- LED 192kHz
		LED_AVG0			: 	out std_logic	;	-- LED AVG0
		LED_AVG1			: 	out std_logic	;	-- LED AVG1
		LED_AVG2			: 	out std_logic	;	-- LED AVG2
		LED_CAL				: 	buffer std_logic;	-- LED CALIBRATION
		LED_SE				: 	out std_logic	;	-- LED SingleEnded/Differential
		LED_FILTOFF			: 	out std_logic	;	-- LED Filter OFF
		LED1_Y				: 	out std_logic	;	-- Front SMD LED1 (yellow)
		LED1_G				: 	out std_logic	;	-- Front SMD LED1 (Green)
		LED1_R				: 	out std_logic	;	-- Front SMD LED1 (Red) 
		LED2_Y				: 	out std_logic	;	-- Front SMD LED2 (yellow)
		LED2_G				: 	out std_logic	;	-- Front SMD LED2 (Green)
		LED2_R				: 	out std_logic	;	-- Front SMD LED2 (Red) 
		FILTER_CH1			: 	out std_logic	;	-- Relay drive for filter bandwidth on Channel 1
		SE_CH1				: 	out std_logic	;	-- Relay drive for single-ended or Differential mode channel 1
		FILTER_CH2			: 	out std_logic	;	-- Relay drive for filter bandwidth on Channel 1
		SE_CH2				: 	out std_logic	;	-- Relay drive for single-ended or Differential mode channel 2
		ACTIVITY_LED		: 	out std_logic		-- CPLD activity led
		); 	  
end  Coders_LEDS_v0;
 
ARCHITECTURE Behavioral OF Coders_LEDS_v0 IS

signal	countLED	: integer range 0 to 15 :=0 ; -- counter
signal	TA			: std_logic ;
signal	TB			: std_logic ;
signal	Push		: std_logic ;
signal 	LED			: std_logic_vector (5 downto 0);
signal	DIR_CW		: std_logic ;
signal  Push_Toggle : std_logic ;

signal clkdivide	: unsigned(23 downto 0) :=(others=>'0'); -- external clock divider
signal EXCLK_LED	: std_logic ;
signal cntLED		: integer range 0 to 2 :=0 ;
signal AVG 			: std_logic_vector(2 downto 0) ;

begin 

ACTIVITY_LED	<= CLOCK1Hz ; --
------------------------------------------------------------------------
process (CLOCK10Hz,CODER_PUSH,CODER_TA,CODER_TB,TA,TB,Push,DIR_CW,Push_Toggle)
begin
	-- coder pulses filtering
	if 		rising_edge(CLOCK10kHz)	then
			TA		<=	CODER_TA	; --
			TB		<=	CODER_TB	; --
			Push	<=	CODER_PUSH	; --
	end if;
	
	-- Coder Direction detection
	if 		rising_edge(TA)	then
			DIR_CW	<= TB; 
	end if;
	-- Coder push button test on LED 48k (toggle each push).
	if 		rising_edge(Push)	then
			Push_Toggle	<= not Push_Toggle ; --
	end if;
		
	LED_192K	<= DIR_CW		; -- Direction indicator test LED
	LED_96K		<= TA			; -- Encoder pulse indicator LED
	LED_48K		<= Push_Toggle	; -- Encoder push button test LED
end process;

------------------------------------------------------------------------	
process (CLOCK1Hz, countLED,LED_CAL,LED)
begin
	--- Dual tricolors front LEDS test
	if 		rising_edge(CLOCK1Hz)	then
			countLED <= countLED + 1 ;
			case	countLED	is
				when	0  => LED <= "000000" ;
				when	1  => LED <= "000001" ;
				when	2  => LED <= "000010" ;
				when	3  => LED <= "000011" ;
				when	4  => LED <= "000100" ;
				when	5  => LED <= "000101" ;
				when	6  => LED <= "000110" ;
				when	7  => LED <= "000111" ;
				when	8  => LED <= "000000" ;
				when	9  => LED <= "001000" ;
				when	10 => LED <= "010000" ;
				when	11 => LED <= "011000" ;
				when	12 => LED <= "100000" ;	
				when	13 => LED <= "101000" ;
				when	14 => LED <= "110000" ;
				when	15 => LED <= "111000" ;
						LED_CAL <= not LED_CAL; -- toggle LED_CAL
			end case;
	end if;
	LED1_Y	<= not  LED(0); -- yellow led 1 drive
    LED1_G  <= not 	LED(1); -- Green led 1 drive
    LED1_R  <= not 	LED(2); -- Red led 1 drive
    LED2_Y  <= not 	LED(3); -- yellow led 2 drive
    LED2_G  <= not 	LED(4); -- Green led 2 drive
    LED2_R  <= not 	LED(5); -- Red led 2 drive
end process;


------------------------------------------------------------------------
process (CLOCK10Hz, CONF_0,CONF_1,CONF_2,CONF_3)
begin	
	-- Relay drive with jumpers
	if 		rising_edge(CLOCK10Hz)	then
			FILTER_CH1	<= CONF_0 ; -- Jumper 0 set Filter on CH1
			SE_CH1		<= CONF_1 ; -- Jumper 1 set  on CH1
			FILTER_CH2	<= CONF_2 ; -- Jumper 2 set Filter on CH2
			SE_CH2		<= CONF_3 ; -- Jumper 3 set  on CH1
			LED_SE		<= CONF_1 and CONF_3 ; -- LED_SE is ON if both channels are in SE mode
			LED_FILTOFF	<= CONF_0 and CONF_2 ; -- LED_FILTOFF is ON if both channels are ON.		
	end if;
end process;
	
	
------------------------------------------------------------------------
process (CLK_EXT,cntLED,EXCLK_LED,clkdivide,AVG)
begin
	-- AVG LEDS are driven by divided external clock input.
	if 		rising_edge(CLK_EXT)	then
			clkdivide	<= clkdivide + 1 ;
			EXCLK_LED   <= not clkdivide(23); -- divide by  = 2.2 Hz
			-- EXCLK_LED   <= not clkdivide(8); -- test

	end if;
	
	if 		rising_edge(EXCLK_LED)	then
			cntLED 		<= cntLED + 1 ;
			case	cntLED is
				when 0 => AVG <= "001" ; -- AVG led 0
				when 1 => AVG <= "010" ; -- AVG led 1
				when 2 => AVG <= "100" ; -- AVG led 2
			end case;
	end if;
	LED_AVG0	<= AVG(0) ;
	LED_AVG1	<= AVG(1) ;
	LED_AVG2	<= AVG(2) ;
end process;

end Behavioral;



