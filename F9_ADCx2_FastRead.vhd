-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date:23/05/19	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 148 LE.  *** IN PROGRESS ***
-- Function F9 :  F9_ADCx2_FastRead.vhd
-----------------------------------------------------------------
-- Function to read data from LT2380-24 ADC using ONLY fast reading
-- protocol, eg: all 24 bits of data in a single CLOCK cycle.
-- (no clock in average samples cycle).
--
-- Averaging ratio can be set as follow (SinC mode) : 
-- SR=384 kHz Avg = 1 to 4 x (xFS= 384 to 1536 kHz)
-- SR=192 kHz Avg = 1 to 8 x (xFS= 192 to 1536 kHz)
-- SR= 96 kHz Avg = 1 to 16x (xFS=  96 to 1536 kHz)
-- SR= 48 kHz Avg = 1 to 32x (xFS=  48 to 1536 kHz)
-- 
-- When FIR mode is active then ;
-- SR= 384k => xFS= 3072kHz 8x decimation
-- SR= 192k => xFS= 1536kHz 8x decimation
-- SR=  96k => xFS=  768kHz 8x decimation 
-- SR=  48k => xFS=  384kHz 8x decimation
-- 
-------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F9_ADCx2_FastRead is
--
port(
	-- INPUTS
	FIRmode		: in  std_logic		; 				-- 1=FIR mode active, 0= SInC mode (ADC auto average)
	enable      : in  std_logic		; 				-- Enable input for fast reading mode.
	CLOCK       : in  std_logic		; 				-- 98.304 MHz clock input
	SR          : in  std_logic_vector(1 downto 0); -- selected output sampling rate (48,96 or 192kHz) 
	AVG         : in  std_logic_vector(2 downto 0); -- Averaging ratio in SinC mode 
	DOUTL       : out std_logic_vector(23 downto 0);-- ADC parrallel output data
	Fso         : out std_logic 	; 				-- effective output sampling rate
	nFS			: out std_logic 	; 				-- ADC sampling rate 
	
	--- ADC control signals
	nCNVL       : out std_logic 	;				-- ADC start conv signal (inverted)
	SCK         : out std_logic	 	;				-- ADC clk
	BUSYL       : in std_logic  	;				-- ADC BUSYL signal
	SDOL        : in std_logic		; 				-- ADC data output
	CK128FS     : out std_logic  					-- 128 FS output for SPDIF.
);
 
end F9_ADCx2_FastRead;

architecture Behavioral of F9_ADCx2_FastRead is

signal	clk_divider	: unsigned(3 downto 0); -- clock divider counter
signal 	clk_div2	: std_logic ; --  49.152 MHz clock
signal 	clk_div4	: std_logic ; --  24.576 MHz clock
signal 	clk_div8	: std_logic ; --  12.288 MHz clock
signal 	clk_div16	: std_logic ; --   6.144 MHz clock

signal	cntFS		: integer range 1 to 64  ; -- counter for generate FS clock
signal 	cntxFS		: integer range 1 to 64  ; -- counter for generate nFS clock
signal 	maxval		: integer range 1 to 128 ; -- counter maxval for nFS clock 
signal 	FS128		: std_logic; -- 128FS clock temp signal
signal	 xFS		: std_logic; -- nFS clock temp signal
  	
signal 	average    	: integer range 1 to 32  ; -- average value
signal 	avg_cnt     : integer range 1 to 32  ; -- average counter
signal 	tclk23      : integer range 0 to 32   ; -- counter for complete ADC reading
signal 	AVG_en		: std_logic ; --    Averaging cycle counter
signal	en_clk		: std_logic ; --  enable clock pulses
signal 	r_sck		: std_logic ; --
signal 	n       	: integer range 1 to 10  ;-- SR clock divide ratio
signal 	div      	: integer range 1 to 5  ;-- 

signal 	QA          : std_logic ; --   Pulse generator temporary signal
signal 	ResetA      : std_logic ; --   output pulse generator
signal 	ReadPeriod  : std_logic ; --   window where ADC reading is done

signal 	r_DATA      : std_logic_vector (23 downto 0) ; -- DOUTL temp buffer
signal 	r_Fso       : std_logic ; --  
signal 	r_enable    : std_logic ; --  
begin

---------------------------------------------------------------------
-- Full clock generator
-- Generate 4 master clock signals from 98.304MHz clock.
-- Generate 128FS clock from selected SR and then
-- generate from this clock the FS rate (Fso) and xFS(nFS) rate
-- using selected averaging value (AVG), SR value and FIRmode signal
----------------------------------------------------------------------
p_clk_divider: process(CLOCK,xFS,r_Fso,ResetA,r_sck,r_enable)
begin
  if rising_edge(CLOCK) then
    r_enable <= enable;-- enable signal is synhronized with CLOCK
  end if;
  if  r_enable='1' then  
      if  (rising_edge(CLOCK)) then
          clk_divider   <= clk_divider + 1; -- increment counter
      end if;
      nFS   <= xFS;	-- send xFS to nFS
      Fso   <= r_Fso ;--send r_Fso to Fso
      nCNVL  <= not ResetA ; -- ADC start convertion pulse (inverted)
      SCK   <= r_sck ;  
  else
      nFS <= '0' ;-- clear nFS
      Fso <= '0' ;-- clear Fso
      clk_divider <= "0000" ; -- clear counter if enable is low.
      nCNVL <= '1' ; -- nCNVL set to high
      SCK   <= '0' ; -- clear SCK
   end if;
end process p_clk_divider;
clk_div2   <= clk_divider(0); -- 49.152 MHz (128*384)
clk_div4   <= clk_divider(1); -- 24.576 MHz (128*192)
clk_div8   <= clk_divider(2); -- 12.288 MHz (128*96)
clk_div16  <= clk_divider(3); -- 6.144 MHz (128*48) 


process (CLOCK,SR,clk_div2,clk_div4,clk_div8,clk_div16)
begin
  if rising_edge(CLOCK) then
    case SR is
      when "00" => FS128 <= clk_div16 ;--128FS= 6.144M             
      when "01" => FS128 <= clk_div8  ;--128FS= 12.288M             
      when "10" => FS128 <= clk_div4  ;--128FS= 24.576M 
      when "11" => FS128 <= clk_div2  ;--128FS= 49.152M
    end case;
  end if;
end process;
CK128FS <= FS128;

process (CLOCK,FS128,AVG,cntFS,cntxFS,maxval,FIRmode)
begin
  if rising_edge(CLOCK) then
    if FIRmode='0' then
    	case AVG is
      	when "000" =>  maxval	<=128;
      					       average<=1	;
      	when "001" =>  maxval <=64;
      					       average<=2	;
      	when "010" =>  maxval <=32;
      					       average<=4	;
      	when "011" =>  maxval <=16;
      					       average<=8	;
      	when "100" =>  maxval <=8	;
      					       average<=16;
      	when "101" =>  maxval <=4 ;
      					       average<=32;
      	when "110" =>  maxval <=2	;
      					       average<=1	;
      	when "111" =>  maxval <=1	; 	
      					       average<=1	;  	
  	    end case;
  	  else             -- FIR mode active then :
         maxval  <=16 ;-- nFS alway equal 128FS/16 for 8x post decimation
      end if; 
  end if;
  if rising_edge(FS128) then -- generate Fso and nFS synchonously to 128FS clock.
	cntFS  <= cntFS  +1	;
	cntxFS <= cntxFS +1 ;
	if 	cntFS = 64 then -- divide by 128 the 128FS clock to get FSclock
		  cntFS <= 1 ;
	   	r_FSo 	<= not r_FSo; -- invert signal at each half period
	end if;
	if 	cntxFS = (maxval/2) then
		  cntxFS 	<= 1;
		  xFS		<= not xFS ;-- invert signal at each half period
	end if;
end if;
end process;


------------------------------------------------------------------
-- Enable AVG_en signal for averaging process of ADC.
-- This signal is active only the first of the average count
-- to allow ADC reading in this xFS clock cycle
------------------------------------------------------------------
process (xFS,avg_cnt,average,AVG_en)
begin
    if rising_edge(xFS) then
        if  avg_cnt < average then
            avg_cnt <=avg_cnt +1 ; -- increment coounter
        else
            avg_cnt <= 1 ; -- reset counter
        end if;
        if  avg_cnt =1 then
            AVG_en <= '1' ; -- average enable signal active only for the first count
        else
            AVG_en <= '0' ; -- disable for all others counts
        end if;
    end if;
end process;
-----------------------------------------------------------------
-- ADC nCNVL pulse generator
------------------------------------------------------------------
process (xFS,ResetA,clk_div4)
begin
  if ResetA='1' then
	   QA <= '0';
  elsif rising_edge(xFS) then
	   QA <= '1';
  end if;
end process;
--
process (clk_div4)
begin
  if rising_edge(clk_div4) then
  ResetA<= QA;
  end if;
end process;


--------------------------------------------------------------------
-- Generate the ReadPeriod signal that allow multiple conversion
-- averaging of the ADC.
--------------------------------------------------------------------
process (ResetA)
begin
	if rising_edge (ResetA) then
		ReadPeriod <= AVG_en; -- to output
	end if;
end process;

------------------------------------------------------------------
-- ADC SCK pulses generator and SDOL read shift register CLOCK
-----------------------------------------------------------------
process (CLOCK,tclk23,AVG_en,BUSYL,en_clk)
begin
  if rising_edge(CLOCK) then
    if ReadPeriod='1' or FIRmode='1' then
      if  BUSYL='0'  then
        if  tclk23 > 24 then
            en_clk <= '0' ;
        else                 
            tclk23 <= tclk23+1;
            en_clk <= '1';                     
        end if;
      else
        tclk23 <= 0;
        en_clk <= '0';
    end if;
    else
      en_clk <= '0';
   end if;
  end if;
r_sck <= CLOCK and en_clk; 
end process;
          
--------------------------------------------------------------------
-- Serial Input Process
-- Note that the SDOL value reading is delayed to one CLOCK cycle
-- to take in account the delay specs of the ADC.
-- (Here, the ADC CLOCK work at 100MHz !)
-- So, first read is done when tclkcnt=1, not 0 !
--------------------------------------------------------------------
p_serial_input : process(CLOCK,tclk23)
begin
  if rising_edge(CLOCK) then  --stored data of SDOL is send to bit 0 to 23 of DOUTL
  case tclk23 is
      when  1  => r_DATA(23)  <= SDOL; 
      when  2  => r_DATA(22)  <= SDOL;
      when  3  => r_DATA(21)  <= SDOL;
      when  4  => r_DATA(20)  <= SDOL;
      when  5  => r_DATA(19)  <= SDOL;
      when  6  => r_DATA(18)  <= SDOL;
      when  7  => r_DATA(17)  <= SDOL;
      when  8  => r_DATA(16)  <= SDOL;
      when  9  => r_DATA(15)  <= SDOL;
      when 10  => r_DATA(14)  <= SDOL;
      when 11  => r_DATA(13)  <= SDOL;
      when 12  => r_DATA(12)  <= SDOL;
      when 13  => r_DATA(11)  <= SDOL; 
      when 14  => r_DATA(10)  <= SDOL;
      when 15  => r_DATA( 9)  <= SDOL;
      when 16  => r_DATA( 8)  <= SDOL;
      when 17  => r_DATA( 7)  <= SDOL;
      when 18  => r_DATA( 6)  <= SDOL;
      when 19  => r_DATA( 5)  <= SDOL;
      when 20  => r_DATA( 4)  <= SDOL;
      when 21  => r_DATA( 3)  <= SDOL;
      when 22  => r_DATA( 2)  <= SDOL;
      when 23  => r_DATA( 1)  <= SDOL;
      when 24  => r_DATA( 0)  <= SDOL;
      when others => NULL;
    end case;
  end if;
end process p_serial_input;

------------------------------------------------------------------------------
-- Transfer data register to DOUTL output at each rising edge
-- of Fso signal. Output is high impedance if enable input is low.
------------------------------------------------------------------------------
process (enable,xFS)
begin
	IF enable='1' then
		if rising_edge(xFS) THEN
			DOUTL <= r_DATA; --
		end if;
	else
		DOUTL <= x"000000" ; -- output set to 0
	end if;
end process;
--------------------------------------------------------------------
end Behavioral ;
          

