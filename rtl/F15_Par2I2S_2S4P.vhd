-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 19/04/2025	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 51 LE.
-- Function F15: F15_Par2I2S_2S4P.vhd
-- 
-- Parrallel to 2x4 Lanes serial interface
-- Simplified version for F1_ReadADCFullSpeed.vhd reading block
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F15_Par2I2S_2S4P is
--
port(
	-- INPUTS
	MCLKI		: in  std_logic ;
	CLK8FS		: in  std_logic ; -- main clock 8FS
	LRCK		: in  std_logic ; -- Output sampling rate clock
	DATAL		: in  std_logic_vector(23 downto 0) ; -- Left channel parallel data in
	DATAR		: in  std_logic_vector(23 downto 0) ; -- Right channel parallel data in
	-- OUTPUTS
	I2S_BCLK		: out  std_logic ; -- I2S bit clock 
	I2S4L_SDATAL	: out  std_logic_vector(3 downto 0);   -- I2S data 4 lanes
	I2S4L_SDATAR	: out  std_logic_vector(3 downto 0);   -- I2S data 4 lanes
	Synchpulse		: buffer  std_logic;
	LRCKd1_test 	: out  std_logic ;
	LRCKd2_test 	: out  std_logic 
);
 
end F15_Par2I2S_2S4P;

architecture Behavioral of F15_Par2I2S_2S4P is

signal  SR_DATA		: std_logic_vector(23 downto 0)  ; -- Data to be shifted
signal  Lshift		: std_logic_vector(23 downto 0)  ; -- shift register output
signal  Rshift		: std_logic_vector(23 downto 0)  ; -- shift register output

-- signal Synchpulse	: std_logic  ;
signal LRCKd1		: std_logic  := '0'  ;
signal LRCKd2		: std_logic  := '0'  ;

begin

I2S_BCLK <= CLK8FS	; -- I2S Bit clock is equal to 64xFS
LRCKd1_test <=  LRCKd1;
LRCKd2_test <=  LRCKd2;
------------------------------------------------------------------
-- Generate I2s control signal for shift register 
------------------------------------------------------------------
process (MCLKI,LRCKd1,LRCKd2,LRCK)	is
begin
	-- 
	if 	rising_edge(MCLKI)	then
		LRCKd1 <= LRCK ;
		LRCKd2 <= LRCKd1;
	end if;
	Synchpulse <= LRCK and not(LRCKd2);
end process;
	
--------------------------------------------------------------------------------
-- shift of data 
--------------------------------------------------------------------------------
process (CLK8FS,Synchpulse,DATAL,DATAR)
begin
	-- Shift are made on each falling_edge of 64FS cloc
    if  Synchpulse='1' then
            Lshift  <= DATAL ; -- load Left channel data to be transmitted
			Rshift  <= DATAR ; -- load Right channel data to be transmitted
    elsif falling_edge(CLK8FS) then
		Lshift  <= Lshift(19 downto 0) & "0000" ;-- shift data
		Rshift  <= Rshift(19 downto 0) & "0000" ;-- shift data
	end if;
end process;
I2S4L_SDATAL <= Lshift(23 downto 20); -- MSB of shift register is serial data out
I2S4L_SDATAR <= Rshift(23 downto 20); -- MSB of shift register is serial data out	

end architecture ;














