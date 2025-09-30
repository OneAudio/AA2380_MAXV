------------------------------------------------------------------
-- ON le 08/05/2017
-- Function to read data from LT2380-24 ADC using the distributed
-- readind protocol
--
-- Averaging ratio is fixed as follow (SinC mode only) : 
-- FS=384 kHz Avg = 4 x (nFS= 1536 kHz)
-- FS=192 kHz Avg = 8 x (nFS= 1536 kHz)
-- FS= 96 kHz Avg = 16x (nFS= 1536 kHz)
-- FS= 48 kHz Avg = 32x (nFS= 1536 kHz)
-- NO FIR mode !
--
-- Take 127 LE
-------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ADC_DistReadX is
--
port(
  enable		    : in  std_logic; -- enable input
  clock         : in  std_logic; -- 98.304 MHz clock input
  FS            : in  std_logic_vector(1 downto 0); -- selected output sampling rate (48,96 or 192kHz) 
  DATAO 	      : out std_logic_vector(23 downto 0); --ADC parrallel output data
  Fso		       	: out std_logic ; -- effective output sampling rate
  nFS			      : out std_logic ; -- ADC sampling rate unaveraged
  --- ADC control signals
  nCNV          : out std_logic ; -- ADC start conv signal (inverted)
  SCK           : out std_logic ; -- ADC clk_div4
  BUSY          : in std_logic  ; -- ADC BUSY signal
  SDO           : in std_logic ; -- ADC data output
  CK128FS		: out std_logic  -- 128 FS output for SPDIF.

 
  );
 
end ADC_DistReadX;

architecture Behavioral of ADC_DistReadX is

signal clk_divider  : unsigned(5 downto 0); -- clock divider counter
signal clk_div2		: std_logic ; --  49.152 MHz clock
signal clk_div4		: std_logic ; --  24.576 MHz clock
signal clk_div8		: std_logic ; --  12.288 MHz clock
signal clk_div16	: std_logic ; --   6.144 MHz clock
  	
signal  xFS  	      : std_logic ; -- output sampling clock 	

signal  avg_max     : integer range 1 to 32  ; -- max average value
signal  avg_cnt     : integer range 1 to 32  ; -- average counter
signal  tclk_cnt    : integer range 0 to 6   ; -- clk_div4 pulse counter for each xFS period
signal  tclk23      : integer range 0 to 23   ; -- clk_div4 pulses counter for complete ADC reading

signal  enable_sck  : std_logic; -- ADC clk_div4 enable
signal  QA          : std_logic ; --  
signal  ResetA      : std_logic ; --
signal  ena_sck     : std_logic ; --
signal  ena_shft    : std_logic ; --
signal  enable_read : std_logic ; --
signal  sckshift		: std_logic ; --
signal  r_sck	    	: std_logic ; --

signal r_DATA       : std_logic_vector (23 downto 0) ; -- DATAO temp buffer

begin

------------------------------------------------------------------
-- clock divider
------------------------------------------------------------------
p_clk_divider: process(clock,enable,enable_sck,ResetA)
begin
  if enable = '1' then
     if (rising_edge(clock)) then
         clk_divider   <= clk_divider + 1;
     end if;
    Fso <= enable_sck; -- no Fso output if enable is low
    nCNV <= not ResetA ; ---- ADC start convertion pulse (inverted)
  else
    Fso <= '0'; -- clear Fso
    nCNV <= '1' ; -- nCNV set to high
    clk_divider <= "000000" ; -- clear counter if enable is low.
  end if;
end process p_clk_divider;
clk_div2    <= clk_divider(0); -- 49.152 MHz (128*384)
clk_div4    <= clk_divider(1); -- 24.576 MHz (128*192)
clk_div8  	<= clk_divider(2); -- 12.288 MHz (128*96)
clk_div16	  <= clk_divider(3); -- 6.144 MHz (128*48)
xFS         <= clk_divider(5); -- 1536 kHz (=192x8, 96x16 ot 48x32)

nFS <= xFS ;
------------------------------------------------------------------
-- Decoding 128FS frequencys and averaging value from  FS inputs
------------------------------------------------------------------
process (clock,FS,clk_div4,clk_div8,clk_div16)
begin
  if rising_edge(clock) then
    case FS is
      when "00" => avg_max  <= 32 ; -- FS= 48k,  averaging = 32x
                    CK128FS	<= clk_div16;
      when "01" => avg_max  <= 16 ; -- FS= 96k,  averaging = 16x
  			            CK128FS	<= clk_div8;
      when "10" => avg_max  <= 8  ; -- FS=192k,  averaging = 8x
  		            	CK128FS	<= clk_div4;
      when "11" => avg_max  <= 4  ; -- FS=384k,  averaging = 4x
  			            CK128FS	<= clk_div2;
    end case;
  end if;
end process;

------------------------------------------------------------------
-- Enable SCK window for auto averaging process of ADC
--  
------------------------------------------------------------------
process (xFS,avg_cnt,avg_max)
begin
    if rising_edge(xFS) then
        if  avg_cnt < avg_max then
            avg_cnt <=avg_cnt +1 ; -- increment coounter
        else
            avg_cnt <= 1 ; -- reset counter
        end if;
        if  avg_cnt = avg_max-1 then
            enable_sck <= '0' ; -- disable ADC clk_div4 for last avg count (end of averaging)
        else
            enable_sck <= '1' ; -- enable clk_div4
        end if;
        if  avg_cnt = avg_max or avg_cnt <6 then
            enable_read <= '1' ; -- eaneble reading for only 4x6 clocks count
        else
            enable_read <= '0' ; -- disable reading
        end if;
    end if;
end process;
--

------------------------------------------------------------------
---- window to limit the reading of the only 23 first clock cycle
--------------------------------------------------------------------
process (enable_sck,r_sck,tclk23)
begin
   if enable_sck = '0' then
      tclk23 <= 0; 
   elsif  rising_edge(r_sck) and tclk23 < 23 then
          tclk23 <= tclk23 +1 ;
  end if;
end process;

------------------------------------------------------------------
-- ADC nCNV pulse generator
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

------------------------------------------------------------------
-- ADC SCK pulse generator
-- and SDO read shift register clock
-----------------------------------------------------------------
process (enable_sck,clk_div4,tclk_cnt,BUSY)
begin
  if rising_edge(clk_div4) then
      if  BUSY='0' then
          if      tclk_cnt < 5 then
                  tclk_cnt <= tclk_cnt+1;
          end if;
          if   tclk_cnt > 0  and tclk_cnt < 5 then
                  ena_sck <= '1' ;
          else
                  ena_sck <= '0' ;
          end if;
          if      tclk_cnt < 4 then
                  ena_shft <= '1' ;
          else
                  ena_shft <= '0' ;
          end if;
      else
           tclk_cnt <= 0;
      end if;
  end if;
end process;
          
process (clock)
begin
	if  rising_edge(clock) then
			r_sck <= clk_div4 and enable_sck and ena_sck;      -- ADC clock pulse
			sckshift <= clk_div4 and enable_read and ena_shft; -- shift register clock 
		end if;
end process;
SCK <= r_sck; 

--------------------------------------------------------------------
-- Serial Input Process
--------------------------------------------------------------------
p_serial_input : process(clock,sckshift)
begin
  if falling_edge(sckshift) then --stored data of SDO is send to bit 0 to 23 of DATAO
  case tclk23 is
      when  0  => r_DATA(23)  <= SDO; 
      when  1  => r_DATA(22)  <= SDO;
      when  2  => r_DATA(21)  <= SDO;
      when  3  => r_DATA(20)  <= SDO;
      when  4  => r_DATA(19)  <= SDO;
      when  5  => r_DATA(18)  <= SDO;
      when  6  => r_DATA(17)  <= SDO;
      when  7  => r_DATA(16)  <= SDO;
      when  8  => r_DATA(15)  <= SDO;
      when  9  => r_DATA(14)  <= SDO;
      when 10  => r_DATA(13)  <= SDO;
      when 11  => r_DATA(12)  <= SDO;
      when 12  => r_DATA(11)  <= SDO; 
      when 13  => r_DATA(10)  <= SDO;
      when 14  => r_DATA( 9)  <= SDO;
      when 15  => r_DATA( 8)  <= SDO;
      when 16  => r_DATA( 7)  <= SDO;
      when 17  => r_DATA( 6)  <= SDO;
      when 18  => r_DATA( 5)  <= SDO;
      when 19  => r_DATA( 4)  <= SDO;
      when 20  => r_DATA( 3)  <= SDO;
      when 21  => r_DATA( 2)  <= SDO;
      when 22  => r_DATA( 1)  <= SDO;
      when 23  => r_DATA( 0)  <= SDO;
      when others => NULL;
    end case;
  end if;
end process p_serial_input;
------------------------------------------------------------------------------
-- Transfer data register to DATAO output at each rising edge
-- of enable_sck signal output is 0 if enable input is low
------------------------------------------------------------------------------
process (enable, enable_sck)
begin
	if 	enable='1' then		
		if falling_edge(enable_sck) then
				DATAO <= r_DATA; --
		end if;
	else
		DATAO <= x"000000" ; -- output set to 0
	end if;
end process;

end Behavioral ;
          

