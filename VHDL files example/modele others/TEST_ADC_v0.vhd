-----------------------------------------------------
-- ON the 24-05-2019 ***OSVA*** AA2380v1 	TEST
-- Take 174 LE - V1.01
-- 
-- LTC2380-24 ADC's TEST
--
-- Fonction de lecture des ADC LTC2380-24 pour test
-- Mode de lecture simple SANS moyennage par l'ADC !
--
-- La conversion est initié au front montant de CNV (durée mini=20ns)
-- L'ADC lève le signal BUSY pendant environ 115ns.
-- Lorsque BUSY revient à 0, les données peuvent être lu
-- Il faut alors 23 cycles de clock sur SCK pour lire en série
-- les 24 bits de donnée sur SDO (le MSB peut être lu dés que busy 
-- est redescendu.
-- V1.01 : correction timing clock ADC.
-----------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity  TEST_ADC_V0  is
   port(CLOCK				:	in	std_logic; 	-- 100MHz clock input
		--ADC Channel 1
		ADC1_CNV			:	buffer	std_logic;  -- ADC 1 Start conversion
   		ADC1_BUSY			:	in	std_logic;  -- ADC 1 Busy indicator
		ADC1_SCK			:	out	std_logic;  -- ADC 1 reading clock
		ADC1_SDO			:	in	std_logic;  -- ADC 1 serial data result 
		--ADC Channel 2
		ADC2_CNV			:	buffer	std_logic;  -- ADC 2 Start conversion
   		ADC2_BUSY			:	in	std_logic;  -- ADC 2 Busy indicator
		ADC2_SCK			:	out	std_logic;  -- ADC 2 reading clock
		ADC2_SDO			:	in	std_logic;   -- ADC 2 serial data result
		-- Data output test for SPDIF link
		LRCK				:	out std_logic;  -- Left/Right clock
		LRDATA				:	out std_logic_vector(23 downto 0) ; -- parallel output data (muxed L/R)
		FS_X128				:	out std_logic ; -- Left/Right clock
		EnableCLOCK1		:	out std_logic ; -- test
		CLK12M5_tst			:	out std_logic ; -- test
		CNTread1_tst		: out integer range 0 to 23  --test
		);   
end  TEST_ADC_V0;
 
ARCHITECTURE Behavioral OF TEST_ADC_V0 IS

signal	Divcnt		: unsigned(8 downto 0 ) ; -- clock divider counter
signal	counter		: integer range 0 to 23 ; -- counter 
signal	CLK195K		: std_logic ; -- 195K clock
signal	CLK12M5		: std_logic ; -- 12.5MHz SCK clock

signal Start1		: std_logic ; --
signal Start2		: std_logic ; --


signal	CNTread1	: integer range 0 to 23 :=0 ; -- bit reading counter
signal	DATAL		: std_logic_vector(23 downto 0) ;
signal	Stop1		: std_logic ; --
signal 	BusyEND1	: std_logic ; --
signal	sREAD1		: std_logic ; --
signal	EN_SCK1		: std_logic ; --


signal	CNTread2	: integer range 0 to 23 :=0 ; -- bit reading counter
signal	DATAR		: std_logic_vector(23 downto 0) ;
signal	Stop2		: std_logic ; --
signal 	BusyEND2	: std_logic ; --
signal	sREAD2		: std_logic ; --
signal	EN_SCK2		: std_logic ; --



begin 

EnableCLOCK1 <= EN_SCK1 ; -- test
CLK12M5_tst	 <= CLK12M5 ; -- test
CNTread1_tst <= CNTread1 ; -- test
---------------------------------------------------------------
-- For 192kHz output sampling rate, the main clock of 100MHz
-- must be divided by 2^9 (100M/512 = 195 kHz)
---------------------------------------------------------------
process(CLOCK)
begin
	if	rising_edge(CLOCK)	then
		Divcnt	<= Divcnt + 1 ;
		FS_X128 <= Divcnt(1);-- 25MHz clock, 128xFS for 192kHZ SR (SPDIF transmitter).
		CLK12M5	<= Divcnt(2);-- 12.5MHz sck data clock
		CLK195K	<= Divcnt(8);-- 195kHz sampling clock
	end if;
end process;	

LRCK	<= CLK195K; --
---------------------------------------------------------------
-- Generate start conversion pulse for both ADC, at CLK195K
-- frequency.
-- ADC1 on rising_edge of CLK195K and
-- ADC2 on falling_edge .
-- each CNV pulse are 1x CLK12M5 period 
---------------------------------------------------------------
process(CLK12M5,CLK195K,ADC1_CNV,ADC2_CNV)
begin
	-- CNV ADC 1
	if 		ADC1_CNV='1'	then
			Start1	<= '0';	-- reset pulse
	elsif 	rising_edge(CLK195K)	then
			Start1	<= '1';
	end if;
	if 		rising_edge(CLK12M5)	then
			ADC1_CNV	<= Start1 ;
	end if;
	-- CNV ADC 2
	if 		ADC2_CNV='1'	then
			Start2	<= '0';-- reset pulse
	elsif 	falling_edge(CLK195K)	then
			Start2	<= '1';
	end if;
	if 		rising_edge(CLK12M5)	then
			ADC2_CNV	<= Start2 ;
	end if;
end process;



---------------------------------------------------------------
--	ADC's data reading is started when busy goed low
--  Generate also 23 SCK clock cyle for reading.
---------------------------------------------------------------

-- ADC CHANNEL 1
process(CLOCK,ADC1_BUSY,CLK12M5,CLK195K,DATAL,ADC2_SDO,Stop1,BusyEND1,CNTread1,sREAD1,EN_SCK1)
begin
	if 		Stop1='1'	then
			BusyEND1	<= '0';
	elsif	falling_edge(ADC1_BUSY)	then
			BusyEND1	<= '1';
	end if;
	--
	if 	rising_edge(CLK12M5)	then
		sREAD1	<= BusyEND1;
	end if;
	--
	--	
	if	sREAD1='1'	then
		if	rising_edge(CLOCK)	then
			--
			if 	CNTread1>0 and CNTread1 <=23	then
				EN_SCK1	 <= '1';
			else
				EN_SCK1	 <= '0';
			end if;
		end if;
		--
		if 	falling_edge(CLK12M5)	then
			if 	CNTread1 <= 23	then
				CNTread1	<= CNTread1 + 1 ;
				case 	CNTread1 is
						when 0   => DATAL(23) <= ADC1_SDO ; -- MSB read
						when 1   => DATAL(22) <= ADC1_SDO ; --
						when 2   => DATAL(21) <= ADC1_SDO ; --
						when 3   => DATAL(20) <= ADC1_SDO ; --
						when 4   => DATAL(19) <= ADC1_SDO ; --
						when 5   => DATAL(18) <= ADC1_SDO ; --
						when 6   => DATAL(17) <= ADC1_SDO ; --
						when 7   => DATAL(16) <= ADC1_SDO ; --
						when 8   => DATAL(15) <= ADC1_SDO ; --
						when 9   => DATAL(14) <= ADC1_SDO ; --
						when 10  => DATAL(13) <= ADC1_SDO ; --
						when 11  => DATAL(12) <= ADC1_SDO ; --
						when 12  => DATAL(11) <= ADC1_SDO ; --
						when 13  => DATAL(10) <= ADC1_SDO ; --
						when 14  => DATAL(9)  <= ADC1_SDO ; --
						when 15  => DATAL(8)  <= ADC1_SDO ; --
						when 16  => DATAL(7)  <= ADC1_SDO ; --
						when 17  => DATAL(6)  <= ADC1_SDO ; --
						when 18  => DATAL(5)  <= ADC1_SDO ; --
						when 19  => DATAL(4)  <= ADC1_SDO ; --
						when 20  => DATAL(3)  <= ADC1_SDO ; --
						when 21  => DATAL(2)  <= ADC1_SDO ; --
						when 22  => DATAL(1)  <= ADC1_SDO ; --
						when 23  => DATAL(0)  <= ADC1_SDO ; -- LSB read
				end case;    
			else
				Stop1 <= '1';
			end if;
		end if;
	else
		CNTread1	<=  0 ; -- reset counter
		ADC1_SCK	<= '0';
		Stop1 		<= '0';
		EN_SCK1		<= '0';
	end if;
	ADC1_SCK  <= CLK12M5 and EN_SCK1 ; -- Generate 23 clock cycle for ADC_SCK
end process;


-- ADC CHANNEL 2
process(ADC2_BUSY,CLK12M5,CLK195K,DATAR,ADC2_SDO,Stop2,BusyEND2,CNTread2,sREAD2,EN_SCK2)
begin
	if 		Stop2='1'	then
			BusyEND2	<= '0';
	elsif	falling_edge(ADC2_BUSY)	then
			BusyEND2	<= '1';
	end if;
	--
	if 	rising_edge(CLK12M5)	then
		sREAD2	<= BusyEND2;
	end if;
	--
	--	
	if	sREAD2='1'	then
		if	rising_edge(CLK12M5)	then
			--
			if 	CNTread2>0 and CNTread2 <=23	then
				EN_SCK2	 <= '1';
			else
				EN_SCK2	 <= '0';
			end if;
		end if;
		--
		if 	falling_edge(CLK12M5)	then
			if 	CNTread2 <= 23	then
				CNTread2	<= CNTread2 + 1 ;
				case 	CNTread2 is
						when 0   => DATAR(23) <= ADC2_SDO ; -- MSB read
						when 1   => DATAR(22) <= ADC2_SDO ; --
						when 2   => DATAR(21) <= ADC2_SDO ; --
						when 3   => DATAR(20) <= ADC2_SDO ; --
						when 4   => DATAR(19) <= ADC2_SDO ; --
						when 5   => DATAR(18) <= ADC2_SDO ; --
						when 6   => DATAR(17) <= ADC2_SDO ; --
						when 7   => DATAR(16) <= ADC2_SDO ; --
						when 8   => DATAR(15) <= ADC2_SDO ; --
						when 9   => DATAR(14) <= ADC2_SDO ; --
						when 10  => DATAR(13) <= ADC2_SDO ; --
						when 11  => DATAR(12) <= ADC2_SDO ; --
						when 12  => DATAR(11) <= ADC2_SDO ; --
						when 13  => DATAR(10) <= ADC2_SDO ; --
						when 14  => DATAR(9)  <= ADC2_SDO ; --
						when 15  => DATAR(8)  <= ADC2_SDO ; --
						when 16  => DATAR(7)  <= ADC2_SDO ; --
						when 17  => DATAR(6)  <= ADC2_SDO ; --
						when 18  => DATAR(5)  <= ADC2_SDO ; --
						when 19  => DATAR(4)  <= ADC2_SDO ; --
						when 20  => DATAR(3)  <= ADC2_SDO ; --
						when 21  => DATAR(2)  <= ADC2_SDO ; --
						when 22  => DATAR(1)  <= ADC2_SDO ; --
						when 23  => DATAR(0)  <= ADC2_SDO ; -- LSB read
				end case;    
			else
				Stop2 <= '1';
			end if;
		end if;
	else
		CNTread2	<=  0 ; -- reset counter
		ADC2_SCK	<= '0';
		Stop2 		<= '0';
		EN_SCK2		<= '0';
	end if;
	ADC2_SCK  <= CLK12M5 and EN_SCK2 ; -- Generate 23 clock cycle for ADC_SCK
end process;


process(CLK195K,DATAL,DATAR)
begin
		if	CLK195K='0'	then
			LRDATA <= DATAL ;
		else
			LRDATA <= DATAR	;
		end if;
end process;


end Behavioral;

