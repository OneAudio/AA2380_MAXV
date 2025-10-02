-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 23/08/19	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 12 LE.
-- Function F5 :  F6_SDRwidget.vhd
-- 
-- Generate all needed signals for SDRwidget board
-- I2S to USB adapter.
--
-- Note that the sampling rate selection come from  SDR-Widget.
-- Supported sampling are 48-96 and 192kHz (standard audio rates).
--
-- emulate all signal provided by AK5394A ADC to replace it 
-- in the SDR widget board design.
--
-- MCLK = 12.288MHz , Master mode.
-- FS(LRCK) DFS1  DFS0   BCK          FSYNCH
------------------------------------------------
--   48k     0    0    6M144(128fs)   96k(2fs)   
--   96k     0    1    6M144(64fs)   192k(2fs)
--  192k     1    0    12M288(64fs)  384k(2fs)
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F6_SDRwidget is
--
port(
	-- AA2380 signals
	CLKIN			: in  	std_logic ; -- 100 MHz input clock
	CK128FS			: in  	std_logic ; -- ADC 128xFs clock
	nFS				: in  	std_logic ; -- ADC sampling clock (1536 kHz).
	I2S_LRCK		: in  	std_logic ; -- I2S L/R clock (= FS rate)
	I2S_BCLK		: in  	std_logic ; -- I2S bit clock(= 64FS rate)
	I2S_SDATA		: in	std_logic ; -- I2S L/R data
	
	-- SRDwidget signals
	SDR_nRSTN		: in	std_logic ; -- Reset signal from SDR-Widget (active low).
	SDR_DFS			: in	std_logic_vector(1 downto 0); -- Sampling rate selection from SDR-Widget board
	SDR_LRCK		: out	std_logic ; -- SDR widget USB adapter I2S Left/Right clock
	SDR_SCLK		: out	std_logic ; -- SDR widget USB adapter I2S bit clock
	SDR_MCLK		: out  	std_logic ; -- SDR widget USB adapter I2S Master clock (12.288MHz)
	SDR_FSYNCH		: out  	std_logic ; -- SDR widget USB adapter I2S stereo data (= 2xFs clock)
	SDR_SDATA		: out  	std_logic   -- SDR widget USB adapter I2S stereo data 
);
 
end F6_SDRwidget;

architecture Behavioral of F6_SDRwidget is

signal nFSdiv	: unsigned (3 downto 0); -- nFS divider counter
signal ckdiv	: unsigned (2 downto 0); -- 100MHz clock divider for 12.5 MHz.

begin

------------------------------------------------------------------
--
------------------------------------------------------------------
process (CLKIN,nFS,SDR_DFS,CK128FS,nFSdiv,I2S_SDATA,I2S_LRCK,I2S_BCLK,ckdiv,SDR_nRSTN) is
begin
	if		rising_edge(CLKIN)	then
			ckdiv <= ckdiv +1 ;
	end if;
	
	 -- nFS clock divider to get 2xFS clock for FSYNCH of SDR-Widget.
	if		rising_edge(nFS)	then
			nFSdiv <= nFSdiv +1 ;
	end if;
	
	-- Select right FSYNCH and SCLK (BCK) from sampling rate selection
	case	SDR_DFS is
			-- FS= 48kHz 
			when "00" => SDR_SCLK 	<=	CK128FS		; -- SDR_SCLK (BCK) = 128FS = 6M144
						 SDR_FSYNCH <= 	nFSdiv(3)	; -- FSYNCH = nFS/16 = 96k (2xFS)
			-- FS= 96kHZ
			when "01" => SDR_SCLK 	<=  I2S_BCLK	; -- SDR_SCLK (BCK) = 64FS = 6M144
						 SDR_FSYNCH <=  nFSdiv(2)	; -- FSYNCH = nFS/8 = 192k (2xFS)
			-- FS= 192kHz
			when "10" => SDR_SCLK 	<=  I2S_BCLK	; -- SDR_SCLK (BCK) = 64FS = 12M288
						 SDR_FSYNCH <=  nFSdiv(1)	; -- FSYNCH = nFS/4 = 384k (2xFS)
			-- FS= 384 kHz (unsupported!)
			when "11" => SDR_SCLK 	<=  '0' ; --
						 SDR_FSYNCH <=  '0' ; --
	end case;
	
	-- send data and L/R clock
	if	SDR_nRSTN='1'	then
		SDR_SDATA	<= I2S_SDATA	; -- I2S_SDATA send to SDR_SDATA
		SDR_LRCK	<= I2S_LRCK		; -- I2S_LRCK send to SDR_LRCK
	else		
		SDR_SDATA	<= '0'			; -- reset signal until nRSTN is ok
		SDR_LRCK	<= '0'			; -- reset signal until nRSTN is ok
	end if;
	
	SDR_MCLK	<= ckdiv(2)		; -- 12.5MHz MCLK from 100MHz clock.
	
end process;

end architecture ;














