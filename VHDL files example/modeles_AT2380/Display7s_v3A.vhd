--------------------------------------------------------------------------------
-- O.N the 09/10/2017
-- Need 86 LE
-- Muxed 4 digits 7 segments LEDs diplay control
---(added OSCen for display off when disable)
--
-- add Mode2 input to set display in dBV mode.
-- add 50% dimming input (DIM)
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY Display7s_v3A IS
  PORT(
		CLK		: IN  STD_LOGIC; -- Main 20M clock
		clkS  	: IN  STD_LOGIC; -- 2kHz low frequency clock
		ATT		: IN  STD_LOGIC_vector (7 downto 0); -- 8 bits attenuation input
		dBstep	: IN  STD_LOGIC_vector (2 downto 0); -- 3 bits step value
		Mode		: IN  STD_LOGIC; -- Manual or Auto Mode input
		Mode2   	: IN  STD_LOGIC; -- dBV measurement display mode
		ModeP		: IN  STD_LOGIC; -- pulse when mode is changed (short display)
		StepP  	: IN  STD_LOGIC; -- pulse when new dB step is selected (short display)
		OSCen		: IN  STD_LOGIC; -- external oscillator enable
		dBV_sign	: IN  STD_LOGIC; -- dBV sign extension : 0 =+  1= -
		Segments	: OUT STD_LOGIC_VECTOR (7 downto 0);-- 7 segments + dp output for muxed display
		Digits  	: OUT STD_LOGIC_VECTOR (3 downto 0)-- 7 segments common digit output for muxed display
		);
END Display7s_v3A;

ARCHITECTURE behavior OF Display7s_v3A IS

signal muxcount 	: integer range 0 to 4 :=0 ; --  digits mux counter
signal dpoint		: std_logic ;
signal dpchar		: std_logic ;
signal dp			: std_logic_vector (3 downto 0);
signal Tent			: std_logic_vector (3 downto 0);
signal segBCD		: std_logic_vector (3 downto 0);
signal BCD3			: std_logic_vector (11 downto 0);
signal Seg   		: std_logic_vector (6 downto 0); -- 7 segments output witout decimal point
signal Attvalue		: std_logic_vector (7 downto 0); --
signal Char8		: std_logic_vector (7 downto 0); --
signal Char7		: std_logic_vector (6 downto 0); --
signal charDisp		: std_logic_vector (3 downto 0); --
signal MuxDisp  	: std_logic_vector (15 downto 0); --
signal dBDisp  		: std_logic_vector (15 downto 0); --
signal ModeDisp  	: std_logic_vector (15 downto 0); --
signal BCD3L     	: std_logic_vector (3 downto 0); -- Left digit is Hundred or sign in Auto Mode.
signal sign       : std_logic_vector (3 downto 0); --

begin
--------------------------------------------------------
-- Convert 8 bits counter binary value to 4 digits BCD format.
-- 0 to 255 ==> 000.0 to 127.5 dB
-- The 7 MSB are decoded in BCD, the MSB is read only for
-- .0 or .5 dB value after decimal point.
--------------------------------------------------------
BCDdecode: process(ATT)
  variable temp : STD_LOGIC_VECTOR (7 downto 0);
  variable bcd : UNSIGNED (11 downto 0) := (others => '0');
  begin
    bcd := (others => '0');
    temp(7 downto 0) := '0' & ATT(7 downto 1) ;-- we take only the 7 MSB (=divide by 2).
    for i in 0 to 7 loop
      if bcd(3 downto 0) > 4 then
        bcd(3 downto 0) := bcd(3 downto 0) + 3;
      end if;
      if bcd(7 downto 4) > 4 then
        bcd(7 downto 4) := bcd(7 downto 4) + 3;
      end if;
	bcd := bcd(10 downto 0) & temp(7);
    temp := temp(6 downto 0) & '0';
    end loop;

-- decimal from LSB value.
case ATT(0) is
  	when '0' => Tent <= "0000" ;	-- .0 dB
  	when '1' => Tent <= "0101" ;	-- .5 dB
  	when others => Tent <= "0000" ;
end case;

BCD3 <= STD_LOGIC_VECTOR(bcd(11 downto 0)); -- unsigned to logic_vector convertion

end process BCDdecode;

------------------------------------------------------------------
-- mux display of attenuation value with decimal point
-- from 000.0 to 127.5 dB.
------------------------------------------------------------------
process (clkS,muxcount)
begin
	if rising_edge(clkS) then
		if	muxcount=3 then
			muxcount <= 0;
	    else
			muxcount <= muxcount+1 ;
		end if;
	end if;
end process;

--Digits common drive
process (ClkS,muxcount,BCD3,BCD3L,dpoint,Tent,SegBCD,seg,OSCen,dBV_sign)
begin

  if  OSCen='0' then Digits <= "0000" ; -- All digits are off when oscillator is stoped
  else
      case muxcount is
     	   when 0 => Digits <= "0001" ;	-- Digit 1 (Tenth)
     	   when 1 => Digits <= "0010" ;	-- Digit 2 (unit)
     	   when 2 => Digits <= "0100" ;	-- Digit 3 (tent)
     	   when 3 => Digits <= "1000" ;	-- Digit 4 (Hund)
     	   when others => Digits <= "0000" ;	--
      end case;
  end if;



-- Left digit become sign extension when Auto Mode is active for
-- +10.0 dBV to -90.0 dBV display.
-- Sign indicator is bit 'dBV_sign'
case dBV_sign is
    when '0' => sign <= "1111" ; -- Right character no display
    when '1' => sign <= "1010" ; -- Right character "-" sign display
end case;


--4 digits BCD value mux
case muxcount is
  	when 0 => SegBCD <= Tent ;				-- Digit 1 (Tent)
  	when 1 => SegBCD <= BCD3(3 downto 0) ;	-- Digit 2 (unit)
  	when 2 => SegBCD <= BCD3(7 downto 4) ;	-- Digit 3 (tens)
  	when 3 => SegBCD <= BCD3L ;	-- Digit 4 (Hund or sign)
  	when others => SegBCD <= "0000" ;	--
end case;

-- BCD to 7 segments table
case SegBCD is
		WHEN "0000"=>Seg<="1111110"; --0
		WHEN "0001"=>Seg<="0110000"; --1
		WHEN "0010"=>Seg<="1101101"; --2
		WHEN "0011"=>Seg<="1111001"; --3
		WHEN "0100"=>Seg<="0110011"; --4
		WHEN "0101"=>Seg<="1011011"; --5
		WHEN "0110"=>Seg<="1011111"; --6
		WHEN "0111"=>Seg<="1110000"; --7
		WHEN "1000"=>Seg<="1111111"; --8
		WHEN "1001"=>Seg<="1111011"; --9
		WHEN "1010"=>Seg<="0000001"; -- (-) sign
		WHEN OTHERS=>Seg<="0000000"; -- nothing
end case;

-- decimal point mux
case muxcount is
  	when 0 => dpoint <= '0' ;	-- Decimal point digit 1 , =0 (LSB)
  	when 1 => dpoint <= '1' ;	-- Decimal point digit 2 , =1
  	when 2 => dpoint <= '0' ;	-- Decimal point digit 3 , =0
  	when 3 => dpoint <= '0' ;	-- Decimal point digit 4 , =0 (MSB)
  	when others => dpoint <= '0' ;	--
end case;

Attvalue <= Seg & dpoint ; -- adding the decimal point to 7 segments

end process;
------------------------------------------------------------------
-- function display : Auto or Manu mode
-- and dB step display (0.5dB 1.0dB 3.0dB 6.0dB and 10dB)
-- specific characters table to be displayed
------------------------------------------------------------------
DiplayFunc : process(clk,ModeP,StepP)
begin
if rising_edge(clk) then
	if  	modeP='1' and stepP='0' then  	-- 1s pulse from Mode selection
			MuxDisp <= ModeDisp ; 			-- Send ModeDisp to display
	elsif 	modeP='0' and stepP='1' then 	-- 1s pulse from dBstep selection
			MuxDisp <= dBDisp ;	   			-- Send dBdisp to display
	end if;
	if modeP='1' or stepP='1' then			-- if function active
	Segments <= Char8 ;					--display new setting
	else
	Segments <= Attvalue;					-- display attenuation
	end if;
	if 	stepP='1' and ModeP='0' and dBstep="000" then
		dp <= "1000"; -- left digit deciaml point when 0.5dB step.
	else
		dp <= "0000";-- no decimal point either...
	end if;
end if;
end process;

process (dBstep,Mode,muxcount,MuxDisp,dp,CharDisp,dpchar,char7,BCD3,sign,Mode2)
begin
-- Diplay value decode from dBstep input
case dBstep is
    WHEN "000"=>dBdisp<= x"0376"; -- 0.5dB
    WHEN "001"=>dBdisp<= x"D176"; --   1dB
    WHEN "010"=>dBdisp<= x"D276"; --   3dB
    WHEN "011"=>dBdisp<= x"D476"; --   6dB
    WHEN "100"=>dBdisp<= x"1076"; --  10dB
    WHEN OTHERS=>dBdisp<= x"DDDD"; --nothing
end case;
-- and decimal point for first 0.5dB step only

-- Display mode decode
--
case Mode or Mode2 is -- dBV display with sign when Mode or Mode is active
    WHEN '0' => 	Modedisp <= x"859C"; -- Manual mode (Manu)
						BCD3L     <=  BCD3(11 downto 8); -- in Manual Mode Left digit is Hundred
    WHEN '1' => 	Modedisp <= x"5CBA"; -- Auto track mode (Auto)
						BCD3L     <=  sign ; -- in Auto Mode Left digit is sign extension
    WHEN OTHERS=>	Modedisp <= x"DDDD"; --nothing
end case;

--Characters muxed
case muxcount is
  	when 0 => CharDisp <= MuxDisp(3 downto 0) ;	-- Right character
  	when 1 => CharDisp <= MuxDisp(7 downto 4) ;	--
  	when 2 => CharDisp <= MuxDisp(11 downto 8) ;	--
  	when 3 => CharDisp <= MuxDisp(15 downto 12) ;	-- Left character
  	when others => CharDisp <= "0000" ;	--
end case;

case muxcount is
  	when 0 => dpchar <= dp(0) ;	-- Right decimal point
  	when 1 => dpchar <= dp(1) ;	--
  	when 2 => dpchar <= dp(2);	--
  	when 3 => dpchar <= dp(3) ;	-- Left decimal point
  	when others => dpchar <= '0' ;	--
end case;

-- Displayed Characters 7 segments table
case CharDisp is
		WHEN x"0"=>Char7<="1111110"; --0
		WHEN x"1"=>Char7<="0110000"; --1
		WHEN x"2"=>Char7<="1111001"; --3
		WHEN x"3"=>Char7<="1011011"; --5
		WHEN x"4"=>Char7<="1011111"; --6
		WHEN x"5"=>Char7<="1110111"; --A
		WHEN x"6"=>Char7<="0011111"; --b
		WHEN x"7"=>Char7<="0111101"; --d
		WHEN x"8"=>Char7<="1110110"; --M
		WHEN x"9"=>Char7<="0010101"; --n
		WHEN x"A"=>Char7<="0011101"; --o
		WHEN x"B"=>Char7<="0000111"; --t
		WHEN x"C"=>Char7<="0011100"; --u
		WHEN OTHERS=>Char7<="0000000"; --nothing
end case;

Char8 <= Char7 & dpchar; -- adding the decimal point to 7 segments
end process;

END behavior;
