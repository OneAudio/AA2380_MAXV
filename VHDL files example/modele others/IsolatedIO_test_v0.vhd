--------------------------------------------
-- ON 13/05/19 *** OSVA ***AA2380v1*** TEST
-- Take 24 LE
-- Isolated I/O test
-- 
--------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity IsolatedIO_test_v0 is

  Port (
        IN_PIN0     : in std_logic	; -- test input 
        IN_PIN1     : in std_logic	; -- test input 
		IN_PIN2     : in std_logic	; -- test input 
		IN_PIN3     : in std_logic	; -- test input 
		IN_PIN4     : in std_logic	; -- test input 
		IN_PIN5     : in std_logic	; -- test input 
        OUT_PIN0	: out std_logic	; -- test output 
        OUT_PIN1	: out std_logic	; -- test output 
		OUT_PIN2	: out std_logic	; -- test output 
		OUT_PIN3	: out std_logic	; -- test output 
		OUT_PIN4	: out std_logic	; -- test output 
		OUT_PIN5	: out std_logic	; -- test output 
		OUT_PIN6	: out std_logic	; -- test output 
		OUT_PIN7	: out std_logic	; -- test output 
		OUT_PIN8	: out std_logic	; -- test output 
		OUT_PIN9	: out std_logic	; -- test output 
		OUT_PIN10	: out std_logic	; -- test output 
		OUT_PIN11	: out std_logic	 -- test output 
		);
end IsolatedIO_test_v0;

architecture Behavioral of IsolatedIO_test_v0 is

signal clk_divider	: unsigned(10 downto 0) :=(others=>'0'); -- counter for clock divider
signal counter		: integer range 0 to 3 :=0 ; --
signal CA			: unsigned(3 downto 0) ;
signal CB			: unsigned(3 downto 0) ;
signal CC			: unsigned(3 downto 0) ;
signal CA0			: std_logic ;
signal CA1			: std_logic ;
signal CA2			: std_logic ;
signal CA3			: std_logic ;
signal CB0			: std_logic ;
signal CB1			: std_logic ;
signal CB2			: std_logic ;
signal CB3			: std_logic ;
signal CC0			: std_logic ;
signal CC1			: std_logic ;
signal CC2			: std_logic ;
signal CC3			: std_logic ;



begin

----------------------------------------------------------------------------------------
--  Use an isolated input (clock) from IN_PIN 0/2/4 to be send on isolated output
-- after to be divided by 2/4/8 and 16 for the 4 isolated output of each digital isolator IC.
-- The 2nd input IN_PIN 1/3/5 allow to swap the 4 divided outputs.
----------------------------------------------------------------------------------------
process(counter,CA,CB,CC,IN_PIN0,IN_PIN2,IN_PIN4)
begin
	-- Generate 
	if 	rising_edge(IN_PIN0)	then
		Ca <= Ca+1 	; -- increment CA
		CA0 <= Ca(0) ; --div2
		CA1 <= Ca(1) ; --div4
		CA2 <= Ca(2) ; --div8
		CA3 <= Ca(3) ; --div16
	end if;
	if 	rising_edge(IN_PIN2)	then
		Cb <= Cb+1 	; -- increment CB
		CB0 <= Cb(0) ; --div2
		CB1 <= Cb(1) ; --div4
		CB2 <= Cb(2) ; --div8
		CB3 <= Cb(3) ; --div16
	end if;
	if 	rising_edge(IN_PIN4)	then
		Cc <= Cc+1 	; -- increment Cc
		CC0 <= Cc(0) ; --div2
		CC1 <= Cc(1) ; --div4
		CC2 <= Cc(2) ; --div8
		CC3 <= Cc(3) ; --div16
	end if;
end process;

process (IN_PIN1,IN_PIN3,IN_PIN5,CA0,CA1,CA2,CA3,CB0,CB1,CB2,CB3,CC0,CC1,CC2,CC3)
begin
	case IN_PIN1	is
		when '0' => OUT_PIN0 <= CA0 ;
					OUT_PIN1 <= CA1 ;
					OUT_PIN2 <= CA2 ;
					OUT_PIN3 <= CA3 ;
		when '1' =>	OUT_PIN0 <= CA3 ;
					OUT_PIN1 <= CA2 ;
                    OUT_PIN2 <= CA1 ;
	                OUT_PIN3 <= CA0 ;
	end case;
	
	case IN_PIN3	is
		when '0' =>	OUT_PIN4 <= CB0 ;
					OUT_PIN5 <= CB1 ;
					OUT_PIN6 <= CB2 ;
					OUT_PIN7 <= CB3 ;
		when '1' => OUT_PIN4 <= CB3 ;
					OUT_PIN5 <= CB2 ;
                    OUT_PIN6 <= CB1 ;
	                OUT_PIN7 <= CB0 ;
	end case;
	
	case IN_PIN5	is
		when '0' => OUT_PIN8  <= CC0 ;
					OUT_PIN9  <= CC1 ;
					OUT_PIN10 <= CC2 ;
					OUT_PIN11 <= CC3 ;
		when '1' => OUT_PIN8  <= CC3 ;
					OUT_PIN9  <= CC2 ;
                    OUT_PIN10 <= CC1 ;
	                OUT_PIN11 <= CC0 ;
	end case;	
end process;
 
 
 
 
end Behavioral;
