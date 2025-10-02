-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 21/08/19	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 24 LE.
-- Function F4 :  F4_LR_DATAMUX.vhd
-- 
-- Mux Left/Right channel according to LRCK state.
-- 
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F4_LR_DATAMUX is
--
port(
	-- INPUTS
	LRCK		: in  std_logic ; -- Left/RIght clock of output sampling rate of SPDIF
	DOUTL		: in  std_logic_vector(23 downto 0) ; -- Left channel ADC data
	DOUTR		: in  std_logic_vector(23 downto 0) ; -- Right channel ADC data
	-- OUTPUT
	SPDIFDATA	: out std_logic_vector(23 downto 0)   -- Muxed data output for SPDIF transmitter
);
 
end F4_LR_DATAMUX;

architecture Behavioral of F4_LR_DATAMUX is

begin

------------------------------------------------------------------
-- MUX of Left/Right channels
------------------------------------------------------------------
LRCK_dataMux : process (LRCK,DOUTL,DOUTR) is
begin
	case LRCK is
			when '0' => SPDIFDATA <= DOUTL ;
			when '1' => SPDIFDATA <= DOUTR ;
	end case;
end process LRCK_dataMux ;


end Behavioral ;