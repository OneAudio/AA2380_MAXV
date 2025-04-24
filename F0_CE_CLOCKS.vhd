--------------------------------------------------------------------------------
-- Ressource : -- https://www.fpga4student.com/2017/08/how-to-generate-clock-enable-signal.html
-- fpga4student.com: FPGA projects, Verilog projects, VHDL projects,
-- Generate clock enable signal instead of creating another clock domain
-- Assume that the input clock : MCLK
--------------------------------------------------------------------------------
-- O.N - 19/04/2025 -- take 11 LE 
--------------------------------------------------------------------------------
--  from main audio clock, generate 50% duty cycle divided by 8 and 64 outputs,
-- and divided b 64 pusle output.
--------------------------------------------------------------------------------
library  IEEE;
use  IEEE.STD_LOGIC_1164.ALL;
use  ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity  F0_CE_CLOCKS  is
port(
    MCLK          :	in  std_logic   ; -- Main input clock (98.304MHz or 90.3168MHz)
    Clear         :	in  std_logic   ; -- Clear input 
    -- Outputs used CLOCKs
    MCLKDV8       :	out std_logic   ; -- Divided by 8  clock 50 % duty cycle
    MCLKDV64      :	out std_logic   ; -- Divided by 64 clock 50 % duty cycle
    MCLKDV64p     :	out std_logic    -- Divided by 64 clock pulse output
    );
end  F0_CE_CLOCKS;

ARCHITECTURE DESCRIPTION OF F0_CE_CLOCKS IS

signal   clken_MCLKDV8     : std_logic;
signal   clken_MCLKDV64    : std_logic;
signal   clken_MCLKDV64p   : std_logic;
signal   Delay1            : std_logic;
signal   Delay2            : std_logic;

signal MCLKCNT : unsigned (5 downto 0) :="000000"  ; -- divide by 64 counter

begin

--Test signals
--************
 
------------------------------------------------------------------
--
------------------------------------------------------------------
process (MCLK,MCLKCNT,Delay1,Delay2)	is
begin
	-- Generate a short pulse of 1 MCLK perdio mini, that start when MCLKCNT4) become high.
	if 	rising_edge(MCLK)	then
		Delay1 <= MCLKCNT(5);
		Delay2 <= Delay1    ;
	end if;
	clken_MCLKDV64p <= MCLKCNT(5) and not(Delay2);
end process;

process(MCLK,Clear,MCLKCNT)
begin
    -- 6 bits counter for divide by 2^6 max=64
    if     Clear='1'    then
        MCLKCNT <= "000000" ;
    elsif  rising_edge(MCLK) then
        MCLKCNT <= MCLKCNT + 1 ;
    end if;
  
    clken_MCLKDV8     <= MCLKCNT(2); -- divide by 8 output
    clken_MCLKDV64    <= MCLKCNT(5); -- divide by 64 output

    if(rising_edge(MCLK)) then
  -- Clock enable to allow all clock to be perfectly syncronized
        if(clken_MCLKDV8 = '1') then
            MCLKDV8  <= '1'; --
        else
            MCLKDV8  <= '0'; --
        end if;
    --
        if(clken_MCLKDV64 = '1') then
            MCLKDV64 <= '1'; --
        else
            MCLKDV64 <= '0'; --
        end if;
  
        if(clken_MCLKDV64p = '1') then
            MCLKDV64p <= '1'; --
        else
            MCLKDV64p <= '0'; --
        end if;
    end if;
    
end process;

END DESCRIPTION;
