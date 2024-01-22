------------------------------------------------------------------
-- ON le 12/12/2017
-- Parallel to SPI converter 
-- 
-- Block designed to test MCP 3202 ADC difference with average 
-- function in AT2380 PLD.
-- Take 22 LE
-------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Parallel_to_SPI is
--
port(
  clock         : in  std_logic; -- Main clock input ()
  clkR          : in  std_logic; -- SPI output data rate (8Hz)
  DATAI        	: in  signed (8 downto 0); -- signed Data input
  SDATA         : out std_logic ;  -- serial data out 
--  counter       : out integer range 0 to 8 ;-- test output 
  nCS           : out std_logic   -- chip select (active low)
  );
 
end Parallel_to_SPI;

architecture Behavioral of Parallel_to_SPI is

signal	wsd		      : std_logic ; -- register
signal	wsdd	    	: std_logic :='0' ; -- register
signal	wsp		      : std_logic ; -- register
signal	dataload	  : std_logic_vector(8 downto 0) ; -- data register
signal  countbck	  : integer range 0 to 8 ; -- 
signal  DATA_rect   : std_logic_vector (8 downto 0);-- 9 bit temporary value of dBV_Disp
signal  DATA_corr   : std_logic_vector (8 downto 0);
signal	Minus       :std_logic ; -- register

begin

--counter <= countbck;
---------------------------------------------------------------------
-- SPI generation
----------------------------------------------------------------------
process(clock,clkR,wsd,wsdd,countbck,DATAI,Minus,DATA_rect)
begin
--- convert signed value to unsigned 8 bits (lower bits), and MSB as sign.
--- value can take value from +20 to -180 (for +10dBV to -*90dBV)
    if  DATAI >= 0 then
      	DATA_rect <= std_logic_vector(DATAI) ; -- Positive dBV value
      	Minus <= '0' ; -- "-" sign is off
 		else
 			  DATA_rect <= std_logic_vector (1 + not(DATAI)) ; -- Negative dBV value
 			  Minus <= '1' ; -- "-" sign is on
 		end if;
DATA_corr <= Minus & DATA_rect(7 downto 0);	-- 

--- generate a single pulse (1xclock period) after each rising edge of clkR
  if	rising_edge(clock) then
		wsd	<= clkR ;
		wsdd	<=wsd	; 	
	end if;
wsp <= (wsd xor wsdd) and clkR ; -- and clkR allow only pulse for rising edge.
  
---generate shifted data out  
  	if	falling_edge (clock) then
  	  if   countbck < 9 then
  	       countbck <= countbck +1 ; -- increment counter until reach 9
  	  end if;
-- nCS generation between bit 7 to 0 (not MSB because it's sign
-- the 8 bits can be converted and divided by 2 to give direct absolute dBV value
-- the MSB outside the nCS give the sign.
-- (this allow direct binary convertion by logic analyser) 
  	  if   countbck > 7 then
  	       nCS <= '1'; -- stop nCS to 1 when last bit is read
      else
           nCS <= '0'; -- set nCS to 0 (active) as soon wsp is ready 
  	  end if;
  	  
-- Load data to buffer at each wsp pulse
-- and shift output at each clock falling edge.
      if   wsp='1' then
  			   dataload <= DATA_corr ; -- latach DATA_rect at each wsp pulse
  		else 
  				 dataload <= dataload(7 downto 0) & '0' ; -- shift data to output
		  end if;
-- reset counter
		if 		wsp='1' then
				countbck <= 0 ; -- clear bck counter
-- 				nCS <= '0'; -- set nCS to 0 (active) as soon wsp is ready
		end if;
  end if;
end process;

-- send MSB of shifted register
SDATA <= dataload(8); -- send last bit of shifted register to serial output.

end Behavioral;
		 
		
