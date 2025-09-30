-----------------------------------------------------
-- ON the 04-2019 
-- This function is a simple sequential counter
-- to allow CPLD electrical test.
-- 
-- Rev 0.01  ***  Take xx LE
-----------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity  TEST_outputs  is
   port(CLOCK				:	in	std_logic; 	-- 100MHz clock input
   		LED_RATE			:	out std_logic;	-- CPLD LED to show the change rate (1Hz)
		OUTPUTS				:	out std_logic_vector(41 downto 0)
		); 	-- Tested Output  
end  TEST_outputs;
 
ARCHITECTURE Behavioral OF TEST_outputs IS

signal	counter		: integer range 0 to 5000 ; -- counter to divide 100M clock for 1Hz output
signal  OneHertz	: std_logic ; -- 1Hz output
signal  CNT_Jhonson	: unsigned (41 downto 0):="000000000000000000000000000000000000000001" ; -- vector of output

begin 

-- 1Hz clock generator from main 100MHz clock
	process (CLOCK,OneHertz,counter)
	begin 
		if	rising_edge(CLOCK) then
			counter <= counter+1	;	-- counter increment
			if	counter = 5000 then
				OneHertz <= not OneHertz	; -- toggle
			end if;
		end if;
	end process;
	LED_RATE <= OneHertz ; -- send 1Hz cock to activity LED
-- 
	process (OneHertz,CNT_Jhonson)
	begin 
		if	rising_edge(OneHertz) then
			CNT_Jhonson(1)  <= CNT_Jhonson(0) ;
			CNT_Jhonson(2)  <= CNT_Jhonson(1) ;
			CNT_Jhonson(3)  <= CNT_Jhonson(2) ;
			CNT_Jhonson(4)  <= CNT_Jhonson(3) ;
			CNT_Jhonson(5)  <= CNT_Jhonson(4) ;
			CNT_Jhonson(6)  <= CNT_Jhonson(5) ;
			CNT_Jhonson(7)  <= CNT_Jhonson(6) ;
			CNT_Jhonson(8)  <= CNT_Jhonson(7) ;
			CNT_Jhonson(9)  <= CNT_Jhonson(8) ;
			CNT_Jhonson(10) <= CNT_Jhonson(9) ;
			CNT_Jhonson(11) <= CNT_Jhonson(10) ;
			CNT_Jhonson(12) <= CNT_Jhonson(11) ;
			CNT_Jhonson(13) <= CNT_Jhonson(12) ;
			CNT_Jhonson(14) <= CNT_Jhonson(13) ;
			CNT_Jhonson(15) <= CNT_Jhonson(14) ;
			CNT_Jhonson(16) <= CNT_Jhonson(15) ;
			CNT_Jhonson(17) <= CNT_Jhonson(16) ;
			CNT_Jhonson(18) <= CNT_Jhonson(17) ;
			CNT_Jhonson(19) <= CNT_Jhonson(18) ;
			CNT_Jhonson(20) <= CNT_Jhonson(19) ;
			CNT_Jhonson(21) <= CNT_Jhonson(20) ;
			CNT_Jhonson(22) <= CNT_Jhonson(21) ;
			CNT_Jhonson(23) <= CNT_Jhonson(22) ;
			CNT_Jhonson(24) <= CNT_Jhonson(23) ;
			CNT_Jhonson(25) <= CNT_Jhonson(24) ;
			CNT_Jhonson(26) <= CNT_Jhonson(25) ;
			CNT_Jhonson(27) <= CNT_Jhonson(26) ;
			CNT_Jhonson(28) <= CNT_Jhonson(27) ;
			CNT_Jhonson(29) <= CNT_Jhonson(28) ;
			CNT_Jhonson(30) <= CNT_Jhonson(29) ;
			CNT_Jhonson(31) <= CNT_Jhonson(30) ;
			CNT_Jhonson(32) <= CNT_Jhonson(31) ;
			CNT_Jhonson(33) <= CNT_Jhonson(32) ;
			CNT_Jhonson(34) <= CNT_Jhonson(33) ;
			CNT_Jhonson(35) <= CNT_Jhonson(34) ;
			CNT_Jhonson(36) <= CNT_Jhonson(35) ;
			CNT_Jhonson(37) <= CNT_Jhonson(36) ;
			CNT_Jhonson(38) <= CNT_Jhonson(37) ;
			CNT_Jhonson(39) <= CNT_Jhonson(38) ;
			CNT_Jhonson(40) <= CNT_Jhonson(39) ;
			CNT_Jhonson(41) <= CNT_Jhonson(40) ;
			CNT_Jhonson(0) <=  CNT_Jhonson(41) ;
		end if;
		OUTPUTS <= STD_LOGIC_VECTOR(CNT_Jhonson);

	end process;
end Behavioral;



