--------------------------------------------------------------------------------
-- O.N the 27/03/2017
-- This function calculate from signed 24 bit input data "DATAIN"
-- the peak amplitude in dB with 0.25dB  precision in 0 to - 138.5 dB range.
-- Input is signed binary (from an ADC) and the output (ascii_out) is the muxed
-- ASCII values of the 5 digits (4+ decimal point).
-- 
-- Output is recalculated from peak that is cleared after each rising edge of 
-- "Refresh". It take maximum 32 clk cycles to be completed.
-- The "Sat" output allow to indicate digital saturation.
-- (Need 257 LE)
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY dB_meter_Mux IS
  PORT(
		CLK			: IN  STD_LOGIC; -- Main 50M clock
		FS			: IN  STD_LOGIC; --system clock (192,96 or 48kHz)
		Refresh		: IN  STD_LOGIC; -- Refresh clock rate of dB output (4Hz)
		DATAIN 		: IN signed(23 DOWNTO 0); -- 24 bits signed input data
--		dB	   		: OUT std_logic_vector(11 downto 0); --Output value in dB in binary form.
--		udata		: OUT unsigned(22 downto 0); --test signal
-- 		Ovar1		: out integer range 0 to 2047; -- Test output for 2(Gc-Gm)
-- 		Ovar2		: out integer range 0 to 63 ; -- Test output for 2Gr
-- 		peak		: OUT unsigned(22 downto 0); -- Instantaneous peak value
-- 		clr			: OUT std_logic ; -- clear out for test only
-- 		Eq1			: OUT STD_LOGIC; -- end of shift test signal
		Aff_pos		: in std_logic_vector (5 downto 0); -- binary value of current display position
--		CS			: in std_logic ; -- Chip select input (for tri-state Ascii_out output).
		Ascii_out	: OUT std_logic_vector(7 downto 0); -- Muxed ascii digits output
--		Digits		: OUT std_logic_vector(39 downto 0); -- 5 digits ASCII output(4 + decimal point).
		SAT			: in std_logic ); -- Saturation indicator input
END dB_meter_Mux;

ARCHITECTURE behavior OF dB_meter_Mux IS
----------------------------------
signal	pk 		: unsigned(22 downto 0); -- 24 bits peak value
----------------------------------
signal	countdec : integer range 0 to 31 :=0 ; -- shift counter to find first MSB to 1.
signal	MSB		: std_logic :='0'  ; --signal indicating when dB value is ready to be read
signal 	datao	: bit_vector (22 downto 0); --shifted word until MSB equal 1.
signal  data	: std_logic_vector (22 downto 0) ; -- logic vector of datao
signal 	R		: std_logic_vector (4 downto 0) ;-- First five MSB of data
signal 	m		: integer range 0 to 22 :=0 ; -- Number of shift performed to find MSB=1.
signal 	var1	: integer range 0 to 2047  ; -- Finded value of 10(Gc-Gm))
signal 	var2	: integer range 0 to 63  ; -- Finded value of 10(Gr)
signal 	dBout	: integer range 0 to 2047; -- equal var2-var1
signal udatain 	: unsigned(22 downto 0); -- unsigned form of "udatain". (absolute rectified value)
signal vdatain	: bit_vector (22 downto 0);--bit vector form of "stdatain".
signal stdatain : std_logic_vector (22 downto 0);--logic vector of "peak".
signal Qa		: std_logic :='0'  ; -- First FF output of pulse generator triggered by Refresh clock.
signal clear	: std_logic :='0'  ; -- Clear of fisrt FF.
signal dB12		: std_logic_vector (11 downto 0); --12 bits logic vector form of dB output.
constant dot	: std_logic_vector(7 downto 0) := x"2E" ; -- Decimal point
signal Tent		: std_logic_vector (3 downto 0); -- First digit
signal Unit		: std_logic_vector (7 downto 4); -- Second digit
signal Tens		: std_logic_vector (11 downto 8); -- Third digit
signal Hund		: std_logic_vector (15 downto 12); -- Fourth digit
signal position : integer range 0 to 64; -- Display character position

-----------------------------------------
-- 23 bits absolute value of datain
-----------------------------------------
begin
process (FS,datain)
begin
	if rising_edge(FS) then
		if 	datain >=0 then
			udatain <= unsigned(datain(22 downto 0));
		else
			udatain <= 16777216 - unsigned(datain(22 downto 0));
		end if;
     end if;
end process;

------------------------------------------
--Calcultate peak value in real time
-----------------------------------------
process begin
    wait until rising_edge(FS);
     if Clear='1' then      -- Peak is cleared at each rising edge of Refresh.
        pk <= "000" & x"00000" ;
     elsif udatain > pk then
        pk <= udatain;
     end if;    
end process;

--------------------------------------------------------
--Peak value is stored at each rising edge of refresh
--------------------------------------------------------
process (Refresh)
begin
	if Refresh'event and Refresh ='1' then
	stdatain <= std_logic_vector(pk);
	end if;
end process;

vdatain <= to_bitvector(stdatain);

-----------------------------------------------------------
-- Shift data input until MSB=1, return the MSB position
-- and the vector value of 5 bits after MSB.
------------------------------------------------------------ 
   PROCESS(FS)
    BEGIN
		 IF(FS'EVENT AND FS = '1') THEN	
			IF Clear = '1' THEN
				countdec <= 0 ;
				datao <= vdatain;
				MSB <= '0';
			else	IF	datao(22) = '1' or vdatain(22)='1' or countdec=22 THEN 
					MSB <= '1' ;
					else
					countdec <= countdec +1 ;
					datao <= vdatain sll (countdec+1) ;
					MSB <= '0' ;
				end if;
		end if;
	end if;
  END PROCESS;
  dBout <= (var1 - var2);
  m <= 22-countdec; --  give on cnt the value of the number of first MSB equal to 1
  data <= to_stdlogicvector(datao);
  R <= data(21 downto 17); -- Take only the 5 MSB after from the first MSB equal to 1
  
-----------------------------------------
-- Tables to find 10Gc(Gc-Gm) and 10(Gr) values.
--from MSB position (m) and value of 5bits after MSB (R). 
-- dB value equal : dB = 10(Gc-Gm)-10(Gr)
-----------------------------------------
    process (m) is  -- 10(Gc-Gm) table
    begin
        case m is      
        --m value -- 10(Gc-Gm) values
        when 0  => var1 <= 1385 ;
        when 1  => var1 <= 1325 ;
        when 2  => var1 <= 1264 ;
        when 3  => var1 <= 1204 ;
        when 4  => var1 <= 1144 ;
        when 5  => var1 <= 1084 ;
        when 6  => var1 <= 1024 ;
        when 7  => var1 <= 963  ;
        when 8  => var1 <= 903 ;
        when 9  => var1 <= 843 ;
        when 10 => var1 <= 783 ;
        when 11 => var1 <= 722 ;
        when 12 => var1 <= 662 ;
        when 13 => var1 <= 602 ;
        when 14 => var1 <= 542 ;
        when 15 => var1 <= 482 ;
        when 16 => var1 <= 421 ;
        when 17 => var1 <= 361 ;
        when 18 => var1 <= 301 ;
        when 19 => var1 <= 241 ;
        when 20 => var1 <= 181 ;
        when 21 => var1 <= 120 ;
        when 22 => var1 <= 60  ;
        end case;
    end process;
    
    process (R) is  -- 10(Gr) table
    begin
        case R is      
        --R value -- 10 Gr values
        when "00000" => var2 <= 0 ;
        when "00001" => var2 <= 3 ;
        when "00010" => var2 <= 5 ;
        when "00011" => var2 <= 8 ;
        when "00100" => var2 <= 10 ;
        when "00101" => var2 <= 13 ;
        when "00110" => var2 <= 15 ;
        when "00111" => var2 <= 17 ;
        when "01000" => var2 <= 19 ;
        when "01001" => var2 <= 22 ;
        when "01010" => var2 <= 24 ;
        when "01011" => var2 <= 26 ;
        when "01100" => var2 <= 28 ;
        when "01101" => var2 <= 30 ;
        when "01110" => var2 <= 32 ;
        when "01111" => var2 <= 33 ;
        when "10000" => var2 <= 35 ;
        when "10001" => var2 <= 37 ;
        when "10010" => var2 <= 39 ;
        when "10011" => var2 <= 40 ;
        when "10100" => var2 <= 42 ;
        when "10101" => var2 <= 44 ;
        when "10110" => var2 <= 45 ;
        when "10111" => var2 <= 47 ;
        when "11000" => var2 <= 49 ;
        when "11001" => var2 <= 50 ;
        when "11010" => var2 <= 52 ;
        when "11011" => var2 <= 53 ;
        when "11100" => var2 <= 55 ;
        when "11101" => var2 <= 56 ;
        when "11110" => var2 <= 57 ;
        when "11111" => var2 <= 59 ;
        end case;
    end process;

-----------------------------------------
-- Generate a one clk cycle pulse for each 
-- rising edge of Refresh clock. 
-----------------------------------------
process (Refresh, clear)
begin
if clear='1' then
	Qa <= '0';
elsif (Refresh'event and Refresh='1') then
	Qa <= '1';
end if;
end process;

process (FS)
begin
if FS'event and FS ='1' then
clear<= Qa;
end if;
end process;

-----------------------------------------
--Write dB and dB12(BCD) signal as soon 
--dB value is found ==> MSB=1.
-----------------------------------------
process (MSB)
begin
	if MSB'event and MSB ='1' then
-- 	dB <= std_logic_vector(to_unsigned(dBout, 11));
	dB12 <= '0' & std_logic_vector(to_unsigned(dBout, 11)) ;
end if;
end process;

--------------------------------------------------------
-- Convert dB12 binary dB value to 4 digits BCD format.
--------------------------------------------------------
bcd1: process(dB12)
  variable temp : STD_LOGIC_VECTOR (11 downto 0);
  variable bcd : UNSIGNED (15 downto 0) := (others => '0');
  begin
    bcd := (others => '0');
    temp(11 downto 0) := dB12;
    for i in 0 to 11 loop
      if bcd(3 downto 0) > 4 then 
        bcd(3 downto 0) := bcd(3 downto 0) + 3;
      end if;
      if bcd(7 downto 4) > 4 then 
        bcd(7 downto 4) := bcd(7 downto 4) + 3;
      end if;
      if bcd(11 downto 8) > 4 then  
        bcd(11 downto 8) := bcd(11 downto 8) + 3;
      end if;
      bcd := bcd(14 downto 0) & temp(11);
      temp := temp(10 downto 0) & '0';
    end loop;
    Tent <= STD_LOGIC_VECTOR(bcd(3 downto 0));
    Unit <= STD_LOGIC_VECTOR(bcd(7 downto 4));
    Tens <= STD_LOGIC_VECTOR(bcd(11 downto 8));
    Hund <= STD_LOGIC_VECTOR(bcd(15 downto 12));
    
end process bcd1;
-- Concatenation for ASCII characters and decimal point added
--	Digits <= x"3" & Hund & x"3" & Tens & x"3" & Unit & dot & x"3" & Tent   ; 
  	
------------------------------------------------------------------
--Ascii_out mux output of digits fro Aff_pos values from 19 to 23
------------------------------------------------------------------
process (Aff_pos,clk)
begin 	
	if rising_edge(clk) then
	position <= to_integer(unsigned(Aff_pos));
			if SAT='0' then
				if position= 19 then
				ascii_out <=  x"3" & Hund ;
				elsif position= 20 then
				ascii_out <=  x"3" & Tens ;
				elsif position= 21 then
				ascii_out <=  x"3" & Unit ;
				elsif position= 22 then
				ascii_out <=  dot ;
				elsif position= 23 then
				ascii_out <=  x"3" & Tent ;
				else
				ascii_out <= "ZZZZZZZZ"; -- Output is high impedance for others count.
			end if;
			else
				if position= 19 then
				ascii_out <=  x"2A" ; --*
				elsif position= 20 then
				ascii_out <=  x"53" ; --S
				elsif position= 21 then
				ascii_out <=  x"41" ; --A
				elsif position= 22 then
				ascii_out <=  x"54" ; --T
				elsif position= 23 then
				ascii_out <=  x"2A" ; --*
				else
				ascii_out <= "ZZZZZZZZ";-- Output is high impedance for others count.
			end if;
		end if;	
	end if;
end process;
-----------------------------------------
-- Set some signal.
-------------------------------------------	
-- 	Ovar1 <= var1 ;
-- 	Ovar2 <= var2 ;
-- 	peak <= pk;
-- 	clr <= clear;
--	dB <= dB12;
--	udata <= udatain;
-- 	dataoo <= vdatain ;
		
END behavior;  
               
