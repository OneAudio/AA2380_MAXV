--------------------------------------------
-- ON 20/05/19
-- Take xx LE
-- Multiple clock generator for test purpose.
-- 
--------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Clock_Generator_v0 is

  Port (
        CLKIN		: in   std_logic;  -- Input clock (100MHz)
        CLK1M	 	: buffer std_logic;  -- 1MHz output
		CLK10kHz	: buffer std_logic;  -- 1MHz output
        CLK10Hz   	: buffer std_logic;  -- 10 Hz output clock 
        CLK1Hz   	: buffer std_logic;  -- 1 Hz output clock 
		UIO_00		: out std_logic	; -- test output J12-1
		UIO_01		: out std_logic	; -- test output J12-3
		UIO_02		: out std_logic	; -- test output J12-5
		UIO_03		: out std_logic	; -- test output J12-7
		UIO_04		: out std_logic	; -- test output J12-9
		UIO_05		: out std_logic	; -- test output J12-11
		UIO_06		: out std_logic	; -- test output J12-13
		UIO_07		: out std_logic	; -- test output J12-15
		UIO_08		: out std_logic	; -- test output J12-17
		UIO_09		: out std_logic	; -- test output J12-19
		UIO_10		: out std_logic	; -- test output J12-2
		SPDIFO		: out std_logic	; -- SPDIF output
		PLL_OE		: out std_logic	; -- PLL enable
		PLL_S0		: out std_logic	; -- PLL select bit 0
		PLL_S1		: out std_logic	  -- PLL select bit 1
		
		);
end Clock_Generator_v0;

architecture Behavioral of Clock_Generator_v0 is

signal clk_divider	: unsigned(10 downto 0) :=(others=>'0'); -- counter for clock divider
signal cnt100		: integer range 0 to 49 :=0 ; --
signal cnt10K		: integer range 0 to 49 :=0 ; --
signal cnt100K		: integer range 0 to 49999 :=0 ; --
-- signal cnt100K		: integer range 0 to 127 :=0 ; --
signal cnt10		: integer range 0 to 4 :=0 ; --
signal cnt10M		: integer range 0 to 4 :=0 ; --
signal CLK10M		: std_logic;
signal count		: integer range 0 to 2 :=0 ;

begin

p_clk_divider: process(CLKIN,CLK1M,CLK10Hz)
begin
	if	(rising_edge(CLKIN)) then
		cnt10M   <= cnt10M + 1; -- increment counter
		if 	cnt10M = 4	then
			CLK10M	<= not CLK10M	; -- 10MHz output
			cnt10M	<= 0;
		end if;
	end if;
	if	(rising_edge(CLKIN)) then
		cnt100   <= cnt100 + 1; -- increment counter
		if 	cnt100 = 49	then
			CLK1M	<= not CLK1M	;-- 1 MHz output
			cnt100	<= 0 ;
		end if;
	end if;
	if	(rising_edge(CLK1M)) then
		cnt100K   <= cnt100K + 1; -- increment counter
		if 	cnt100K = 49999	then
		-- if 	cnt100K = 127	then -- test line only for faster simulation
			CLK10Hz	<= not CLK10Hz	; -- 10 Hz output
		end if;
	end if;
	if	(rising_edge(CLK1M)) then
		cnt10K   <= cnt10K + 1; -- increment counter
		if 	cnt10K =  49	then
			CLK10kHz	<= not CLK10kHz	; -- 10 kHz output
		end if;
	end if;
	if	(rising_edge(CLK10Hz)) then
		cnt10   <= cnt10 + 1; -- increment counter
		if 	cnt10 = 4	then
			CLK1Hz	<= not CLK1Hz	; -- 1 Hz output
			cnt10	<= 0; -- reset
		end if;
	end if;
end process;

 
process(CLK1M)
begin
	if 	rising_edge(CLK1M)	then
		clk_divider <= clk_divider +1 ;		
		UIO_00      <= not clk_divider(0) ;  --
		UIO_01      <= not clk_divider(1) ;  --
		UIO_02      <= not clk_divider(2) ;  --
		UIO_03      <= not clk_divider(3) ;  --
		UIO_04      <= not clk_divider(4) ;  --
		UIO_05      <= not clk_divider(5);   -- 
		UIO_06      <= not clk_divider(6);   -- 
		UIO_07      <= not clk_divider(7);   -- 
		UIO_08      <= not clk_divider(8);   -- 
		UIO_09      <= not clk_divider(9);   --
		UIO_10      <= CLK1Hz ; -- 1Hz output for synch test
	end if;
end process;
 
process(CLK1Hz,CLK1M,CLK10M)
begin
	if 	CLK1Hz='0'	then	
		SPDIFO	<=  CLK1M ;
	else
		SPDIFO	<= CLK10M ;
	end if;
end process;


process(CLK10Hz,count)
begin
	if	rising_edge(CLK10Hz)	then
		count <= count + 1 ;
		if 	count = 2	then
			count <= 0;
		end if;
		case count is
			when 0 =>	PLL_OE <= '1';
						PLL_S0 <= '0';
						PLL_S1 <= '0';
			when 1 =>	PLL_OE <= '0';
						PLL_S0 <= '1';
						PLL_S1 <= '0';
			when 2 =>	PLL_OE <= '0';
						PLL_S0 <= '0';
						PLL_S1 <= '1';
		end case;
	end if;
end process;

end Behavioral;
