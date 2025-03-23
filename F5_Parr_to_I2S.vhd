-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 23/03/25	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 27 LE.
-- Function F5 :  F5_Parr_to_I2S.vhd
-- 
-- Parrallel to I2S generator
-- From Philips semiconductor "I2S bus specification" document.
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F5_Parr_to_I2S is
--
port(
	-- INPUTS
	CK64FS		: in  std_logic ; -- ADC 64xFs clock
	LRCK		: in  std_logic ; -- Output sampling rate clock
	PDATAL		: in  std_logic_vector(23 downto 0) ; -- Left channel parallel data in
	PDATAR		: in  std_logic_vector(23 downto 0) ; -- Right channel parallel data in
	-- OUTPUTS
	I2S_LRCK		: out  std_logic ; -- I2S Left/Right clock
	I2S_BCLK		: out  std_logic ; -- I2S bit clock 
	I2S_SDATA		: out  std_logic   -- I2S stereo data
);
 
end F5_Parr_to_I2S;

architecture Behavioral of F5_Parr_to_I2S is

signal	LR_SELECT	: std_logic  ; -- Left/Right data selection bit
signal	OREX		: std_logic  ; -- xor bit
signal	LOADSR		: std_logic  ; -- shift register load signal
signal  SR_DATA		: std_logic_vector(23 downto 0)  ; -- Data to be shifted
signal  Lshift		: std_logic_vector(23 downto 0)  ; -- shift register output

begin

------------------------------------------------------------------
-- Generate I2s control signal for shift register 
------------------------------------------------------------------

I2S_LRCK <= LRCK 	; -- send LRCK to I2S_LRCK
I2S_BCLK <= CK64FS	; -- I2S Bit clock is equal to 64xFS

process (CK64FS,LR_SELECT,OREX,PDATAL,PDATAR)	is
begin
	-- synchronize to 64FS
	if 	rising_edge(CK64FS)	then
		LR_SELECT	<= LRCK		;
		OREX		<= LR_SELECT;
	end if;
	-- Generate load pulse
	LOADSR <= OREX xor LR_SELECT ; -- generate load signal of shift register
	-- MUX of Left/Right data
	case LR_SELECT is
			when '0' => SR_DATA <= PDATAL ;
			when '1' => SR_DATA <= PDATAR ;
	end case;
end process;
	
--------------------------------------------------------------------------------
-- shift of data 
--------------------------------------------------------------------------------
process (CK64FS)
begin
	-- Shift are made on each falling_edge of 64FS clock
    if falling_edge(CK64FS) then
          if  LOADSR='1' then
              Lshift  <= SR_DATA ; -- load channa data to be transmitted
          else
              Lshift  <= Lshift(22 downto 0) & '0' ;-- shift data
          end if;
    end if;
end process;
I2S_SDATA <= Lshift(23); -- MSB of shift register is serial data out
	


end architecture ;














