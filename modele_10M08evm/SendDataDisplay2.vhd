------------------------------------------------
-- ON -- 28/03/2017
-- Main function that send sequentially each characters to be displayed on the
-- LCD in ASCII form.(for 2 lines of 16 characters HD44780 LCD display)
-- There is a part of fixed character and others variable characters depending
-- on some signal inputs and coming also from th ascii_in input.
-- Take xxx LC.
----------------------------------------------------------
library  IEEE;
use  IEEE.STD_LOGIC_1164.ALL;
use  ieee.numeric_std.all;

 entity SendDataDisplay2 is

       port(
    clk       : in std_logic ; -- Main clock (50M)
    Nextchar  : in std_logic ; -- next character to be sent input
    Ready     : in std_logic ; -- Signal indicate initialisation (1 when ok)
    FSample   : in std_logic_vector (1 downto 0); -- SPDIF effective sampling frequency
    AVG       : in std_logic_vector (2 downto 0); -- Average ratio from 1x to 32x
    SinCnFIR  : in std_logic ; -- SinC (1) or FIR (1) digital filter selection
    ACmode    : in std_logic ; -- Digital High-pass filter ON.
    Calib     : in std_logic ; -- DC calibration in progress (blink) or active (1)
    Ascii_out : buffer std_logic_vector (7 downto 0); -- ascii characters data output to LCD
    Ascii_in  : in std_logic_vector (7 downto 0); -- ascii characters data input (from dB and Freq meter)
    Addr      : out std_logic_vector (5 downto 0); -- Output character display address (0 to 63)
    CS_Freq	  : out std_logic ; -- chip select for frequency counter
    LCD_ena   : buffer std_logic ; -- LCD enable output
	LCD_bus	  :OUT STD_LOGIC_VECTOR(9 DOWNTO 0); -- LCD bus data output
	LCD_busy   : IN STD_LOGIC; -- Busy input from LCD display
    CS_dB	  : out std_logic ); -- chip select for dB meter
                
end  SendDataDisplay2;

ARCHITECTURE DESCRIPTION OF SendDataDisplay2 IS

constant	startup      : string := 	 "A2380v1 ANALYSER OnE-AudioProject " ; -- startup message (ready=0)
constant  	ready01      : string := "      Hz    :  x -     dB    #    " ; -- message mask n�1 when ready=1
signal   	loadtxt      : string (1 to startup'length) := startup; -- string buffer
signal	 	count		 : integer range 1 to 64; -- character increment counter (40 characters)
constant	countmax 	 : integer := 35 ; -- maximum value of counter = number of characters
signal	 	c			 : integer range 0 to 255 ; -- character at position "count".
signal    	Fix_txt      : std_logic_vector (7 downto 0); -- Fixed display zone with special commands.
signal    	Ftext      : std_logic_vector (7 downto 0); -- Text to display.
signal		FS_txt		 : std_logic_vector (7 downto 0)  ; -- FS display (3 digits)
signal		AVG_txt		 : std_logic_vector (7 downto 0)  ; -- Average display (2 digits)
signal		IND_txt		 : std_logic_vector (7 downto 0)  ; -- various indicator (AC/DC/CAL)
signal    	Filter		 : std_logic_vector (7 downto 0)  ; -- Filter type indicator
signal   	mode     	 : std_logic_vector (1 downto 0)  ; -- mode inputs aggregate
signal 		Ascii_tmp	 : std_logic_vector (7 downto 0)  ; -- 
signal		RSRW		 : std_logic_vector (1 downto 0)  ; -- LCD bit 8 and 9 (RS and RW). 


begin
--------------------------------------------------------------------------
--Send 8 bits ASCII data to LCD and add RW to 0 (bit8) and RS to 1 (bit9).
--------------------------------------------------------------------------
PROCESS(clk)
  BEGIN
    IF rising_edge(clk) THEN
      IF(LCD_busy = '0' AND LCD_ena = '0') THEN
			LCD_ena <= '1';
			LCD_bus <= RSRW & Ascii_out;-- concatenation of fixed bit 8/9 and input data .
            ELSE
			LCD_ena <= '0';
		END IF;
	END IF;
END PROCESS;

----------------------------------------------------------------
-- Set the two higher bits (RS and RW) to according to send data
-- or to write command (go to line 2 and return home)
-- and  write Fix_txt register to right value on 17th and 34th charecters
-- to send LCD commands.
--------------------------------------------------------------- 
PROCESS(clk)
  BEGIN
      IF rising_edge(clk) THEN
		    IF 		(count=17) then
				      RSRW <= "00"; -- Send command to LCD (RS=0 RW=0)
				      Fix_txt <= x"C0"; -- command to go at start of 2nd line
				ELSIF (count= 34) then
				      RSRW <= "00"; -- Send command to LCD (RS=0 RW=0)
				      Fix_txt <= x"80"; -- command to return at home position
        ELSE
				RSRW <= "10"; -- Write DATA to RAM.
				Fix_txt <= Ftext;
		END IF;
	end if;
END PROCESS;

----------------------------------------------------------------
--Activate CS signals for frequency counter and dB meter
--in the range of their display
--------------------------------------------------------------- 
process (clk,count)
begin
	if rising_edge(clk) then
		if (count>=1) and (count<=5) then
		CS_Freq <= '1'  ; -- CS=1 for 1 to 5 for Frequency display
		else
		CS_Freq <= '0' ;
		end if;
		if (count>=19) and (count<=23) then
		CS_dB <= '1' ; -- CS=1 for 19 to 23 for Amplitude in dB display
		else
		CS_dB <= '0' ;
		end if;
	end if;
end process;		

----------------------------------------------------------------
--MUX to choose only fixed data display before ready=1
---------------------------------------------------------------
with ready select
	Ascii_out <= Ascii_tmp  when '1', -- 
				 Fix_txt	when '0', -- 
				 x"00"	when others;
----------------------------------------------------------------
--Muxed vraiable and fixed data for each characters position after ready=1
---------------------------------------------------------------               
with count select
Ascii_tmp <= Ascii_in 	when 1, --
			 Ascii_in 	when 2, --
			 Ascii_in 	when 3, --
			 Ascii_in 	when 4, --
			 Ascii_in 	when 5, --
			 Ascii_in 	when 6, --
			 Fix_txt 	when 7, --
			 Ascii_in 	when 8, --
			 Fix_txt 	when 9, --
			 Filter 		when 10, --
			 Filter 		when 11, --
			 Filter 		when 12, --
			 Fix_txt 	when 13, --
			 AVG_txt 	when 14, --
			 AVG_txt		when 15, --
			 Fix_txt 	when 16, --
			 Fix_txt		when 17, -- Go to DDRAM address 64 (start of line 2).
			 Fix_txt 	when 18, --
			 Ascii_in 	when 19, --
			 Ascii_in 	when 20, --
			 Ascii_in	when 21, --
			 Ascii_in 	when 22, --
			 Ascii_in 	when 23, --
			 Fix_txt 	when 24, --
			 Fix_txt 	when 25, --
			 Fix_txt 	when 26, --
			 IND_txt 	when 27, --
			 IND_txt 	when 28, --
			 IND_txt 	when 29, --
			 Fix_txt 	when 30, --
			 FS_txt 		when 31, --
			 FS_txt 		when 32, --
			 FS_txt 		when 33, --
			 Fix_txt 	when 34, -- Return home position
			 x"00"		when others;

---------------------------------------------------------------
-- Convert the charecters of string in ascii form
---------------------------------------------------------------
  Addr <= std_logic_vector(to_unsigned(count,6)); -- count value output for dB and Freq functions
process (Nextchar,Ready,c,loadtxt,count)
  begin
  Ftext <= std_logic_vector(to_unsigned(c,8)); -- converting and writing current character
  c <= character'pos(loadtxt(count)); -- 
      if rising_edge (Nextchar) then
        if Ready='0' then -- Startup message when ready not active   
            if  count < (countmax-1) then
                count <= count +1 ;
                loadtxt <= startup ;
            else
            count <= 1 ;-- counter reset 
            end if;
         else  -- Mask message when ready signal is active
            if  count < (countmax-1)  then
                count <= count +1 ;
                 loadtxt <= ready01 ;
              else
            count <= 1 ;-- counter reset 
            end if;
          end if;
       end if;
end process;

---------------------------------------------------------------
--Buffer AVG_txt to display averaging ratio
---------------------------------------------------------------

process (avg,count,AVG_txt)
begin
  case AVG is
      when "000" =>
			 if count= 14 then AVG_txt <= x"30"; --0
          elsif count= 15 then AVG_txt <= x"31"; --1
          else AVG_txt <= x"00"; --0
          end if;
      when "001" =>
			 if count= 14 then AVG_txt <= x"30"; --0
          elsif count= 15 then AVG_txt <= x"32"; --2
          else AVG_txt <= x"00"; --0
          end if;
      when "010" =>
			 if count= 14 then AVG_txt <= x"30"; --0
          elsif count= 15 then AVG_txt <= x"34"; --4
          else AVG_txt <= x"00"; --0
          end if;
      when "011" =>
			 if count= 14 then AVG_txt <= x"30"; --0
          elsif count= 15 then AVG_txt <= x"38"; --8
          else AVG_txt <= x"00"; --0
          end if;       
      when "100" =>
			 if count= 14 then AVG_txt <= x"31"; --1
          elsif count= 15 then AVG_txt <= x"36"; --6
          else AVG_txt <= x"00"; --0
          end if;
      when "101" =>
			 if count= 14 then AVG_txt <= x"33"; --3
          elsif count= 15 then AVG_txt <= x"32"; --2
          else AVG_txt <= x"00"; --0
          end if;
      when "110" =>
			 if count= 14 then AVG_txt <= x"36"; --6
          elsif count= 15 then AVG_txt <= x"34"; --4
          else AVG_txt <= x"00"; --0
          end if;
      when others =>
			 if count= 14 then AVG_txt <= x"00"; --0
          elsif count= 15 then AVG_txt <= x"00"; --0
          else AVG_txt <= x"00"; --0
          end if;
      end case;
end process;
               
---------------------------------------------------------------
----Buffer FS_txt display SPDIF sample rate
---------------------------------------------------------------          
process (count,Fsample)
  begin
    case Fsample is
     when "01" =>  -- FS= 48kHz
             if count= 31 then FS_txt <= x"30"; --0
          elsif count= 32 then FS_txt <= x"34"; --4
          elsif count= 33 then FS_txt <= x"38"; --8
          else FS_txt <= x"00"; --0
          end if;
     when "00" =>  -- FS= 96kHz
             if count= 31 then FS_txt <= x"30"; --0
          elsif count= 32 then FS_txt <= x"39"; --9
          elsif count= 33 then FS_txt <= x"36"; --6
          else FS_txt <= x"00"; --0
          end if;
     when "10" =>  -- FS= 192kHz
             if count= 31 then FS_txt <= x"31"; --1
          elsif count= 32 then FS_txt <= x"39"; --9
          elsif count= 33 then FS_txt <= x"32"; --2
          else FS_txt <= x"00"; --0
          end if;
     when others =>      
          FS_txt <= x"00"; --0
    end case;
end process;
---------------------------------------------------------------
----Buffer IND_txt to display AC,DC and CAlibration mode.
---------------------------------------------------------------      
process (count,ACmode,Calib,mode)
begin
  mode <= (ACmode,Calib);
  case mode is
      when "10" =>
             if count= 27 then IND_txt <= x"41"; --A
          elsif count= 28 then IND_txt <= x"43"; --C
          elsif count= 29 then IND_txt <= x"20"; --
          else IND_txt <= x"20"; -- 
          end if;
       when "00" =>
             if count= 27 then IND_txt <= x"44"; --D
          elsif count= 28 then IND_txt <= x"43"; --C
          elsif count= 29 then IND_txt <= x"20"; --
          else IND_txt <= x"20"; -- 
          end if;
       when "01" =>
             if count= 27 then IND_txt <= x"43"; --C
          elsif count= 28 then IND_txt <= x"41"; --A
          elsif count= 29 then IND_txt <= x"4C"; --L
          else IND_txt <= x"20"; -- 
          end if;
       when others =>
             if count= 27 then IND_txt <= x"43"; --C
          elsif count= 28 then IND_txt <= x"41"; --A
          elsif count= 29 then IND_txt <= x"4C"; --L
          else IND_txt <= x"20"; -- 
          end if;
    end case;
end process;     
   
---------------------------------------------------------------
---- Buffer "Filter" to display SinC or RIF filtering mode.
---- Filter = 0 => SinC (AVG) mode, Filter=1 => FIR mode.
---------------------------------------------------------------
process (count,Filter,SinCnFIR)
  begin
    case SinCnFIR is
     when '0' =>  -- AVG (Mode SinC filter)
             if count= 10 then Filter <= x"41"; --A
          elsif count= 11 then Filter <= x"56"; --V
          elsif count= 12 then Filter <= x"47"; --G
          else Filter <= x"00"; --0
          end if;
     when '1' =>  -- FIR (mode FIR filter)
             if count= 10 then Filter <= x"46"; --F
          elsif count= 11 then Filter <= x"49"; --I
          elsif count= 12 then Filter <= x"52"; --R
          else Filter <= x"00"; --0
          end if;
      when others =>      
          FS_txt <= x"00"; --0
    end case;
end process;
END DESCRIPTION;
