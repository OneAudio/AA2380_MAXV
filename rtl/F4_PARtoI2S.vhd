------------------------------------------------------------------
-- ON le 15/03/2025
-- Parallel to I2S audio converter.
-- Generate LRCK / BCK and SDATA I2S signals
-- Take 57 LE (old 52)
--
-- MCLK = 49.152 MHz or 45.1584 MHz
-- Available output sampling rates :
--
-- Update 03/2025 :Low SR modifications
-------------------------------------------------------------------
-- LRCK      MCLKSEL  DFS2  DFS1  DFS0   BCK             MCLK
-------------------------------------------------------------------
--_________________MCLK = 45.1584 MHz______________________________
-- 11.025k      0     0     0     0     705.6 kHz  (Low SR Mode)    
--  22.05k      0     0     0     1     1.4112 MHz (Low SR Mode)    
--   44.1k      0     0     1     0     2.8224 MHz    
--   88.2k      0     0     1     1     5.6448 MHz   
--  176.4k      0     1     0     0     11.2896 MHz  
--  352.8k*     0     1     0     1     22.5792 MHz  
--  705.6k*     0     1     1     0     45.1584 MHz  
-- 1411.2k*     0     1     1     1     NA  
--
--_________________MCLK = 49.152 MHz_______________________________
--     16k      1     0     0     0     1.024 MHz (Low SR Mode)    
--     32k      1     0     0     1     2.048 MHz (Low SR Mode)  
--     48k      1     0     1     0     3.072 MHz    
--     96k      1     0     1     1     6.144 MHz    
--    192k      1     1     0     0     12.288 MHz    
--    384k*     1     1     0     1     24.576 MHz   
--    768k*     1     1     1     0     49.152 MHz   
--   1536k*     1     1     1     1     NA   
--
--(* : No 128Fs available for SPDIF output for these sample rate.)
----------------------------------------------------------------------
-- Specs from Philips Semiconductor I2S specs documentation figure 5.
-- -------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F4_PARtoI2S is
--
port(
  RSTn          : in  std_logic; -- Reset input (active low)
  MCLK          : in  std_logic; -- Main clock input (49.152 or 45.1584 MHz)
  DFS		        : in  std_logic_vector (2 downto 0); -- FSmode selection bits (3bits)
  MCLKSEL       : in  std_logic; -- Master clock frequency mode (1=49.152M 0=45.1584M)
  DATAL        	: in  std_logic_vector(23 downto 0); -- Data in Left channel
  DATAR        	: in  std_logic_vector(23 downto 0); -- Data in Right channel
--   count 	: out integer range 0 to 127;
--   rwsp		:out std_logic ;
--   testdata :out std_logic_vector (23 downto 0);
-- I2S outputs
  x128FS        : out std_logic ;   -- 128*FS output (for SPDIF transmitter clock)
  LRCK          : buffer std_logic ;-- I2S Left/Right clock = Fs
  BCK           : out std_logic ;   -- I2S bit clock
  SDATA         : out std_logic    -- I2S serial data out (MSB first signed 2's complement)
  );

end F4_PARtoI2S;

architecture Behavioral of F4_PARtoI2S is

signal  clk_divider	: unsigned(5 downto 0); -- clock divider counter
signal  r_bck      	: std_logic ; --  bit clock register
signal	wsd		      : std_logic ; -- register
signal	wsdd	    	: std_logic :='0' ; -- register
signal	wsp		      : std_logic ; -- register
signal	data	   	  : std_logic_vector(23 downto 0) ;
signal	dataload	  : std_logic_vector(23 downto 0) ;

signal countbck	  	: integer range 0 to 32 ; -- bitclock(BCK) count for half FS period

signal clk_div2	  	: std_logic ; -- 24.576M & 22.579M
signal clk_div4	  	: std_logic ; -- 12.288M & 11.289M 
signal clk_div8	  	: std_logic ; --  6.144M &  5.644M
signal clk_div16  	: std_logic ; --  3.072M &  2.822M
signal clk_div32  	: std_logic ; --    NA   &  1.411M
signal clk_div64  	: std_logic ; --    NA   &  705.6M
-- For low SR with 49.15M MCLK
signal clk_divlowSR0  	: std_logic ; -- BCK for low SR 
signal clk_divlowSR1  	: std_logic ; -- BCK for low SR 
--
signal clk_2M048  	: std_logic ; -- 2.048M * for low SR
signal clk_1M024  	: std_logic ; -- 1.024M * for low SR
signal counter_2M048 : integer range 0 to 2 := 0;

begin


-- count <= countbck ;
-- rwsp <= wsp ;

------------------------------------------------------------------
-- clock divider for BCK (bit clock)
-- There is always 64 BCK period for each LRCK period.
-- BCK frequency = 64xLRCK . LRCK equal sampling rate frequency.
------------------------------------------------------------------
p_clk_divider:process(RSTn,MCLK,clk_2M048,clk_div4)
begin
  if RSTn ='1' then
    if	rising_edge(MCLK) then
        clk_divider   <= clk_divider + 1;
    end if;
    --
    if rising_edge(clk_div4) then -- 6.144M clock
            if counter_2M048 = 2 then
              clk_2M048 <= not clk_2M048;
              counter_2M048 <= 0;
            else
              counter_2M048 <= counter_2M048 + 1;
            end if;
    end if;
    -- Division par 2 pour générer 1.024 MHz
    if rising_edge(clk_2M048) then
      clk_1M024 <= not clk_1M024;
    end if;
  else
      clk_divider <= "000000" ; -- reset
      clk_2M048 <= '0';
      clk_1M024 <= '0';
      counter_2M048 <= 0;
  end if;
end process p_clk_divider;
clk_div2	<= clk_divider(0); -- 64 x 384k & 64 x 352.8k
clk_div4	<= clk_divider(1); -- 64 x 192k & 64 x 176.48k
clk_div8	<= clk_divider(2); -- 64 x 96k  & 64 x 88.2k
clk_div16	<= clk_divider(3); -- 64 x 48k  & 64 x 44.1k
clk_div32	<= clk_divider(4); --    NA     & 64 x 22.05k
clk_div64	<= clk_divider(5); --    NA     & 64 x 11.025k
-- clk_divlowSR1	<= clk_2M048 ;     -- 64 x 32k  &     NA
-- clk_divlowSR0	<= clk_1M024 ;     -- 64 x 16k  &     NA
--
-- Low SR clock selection
process (MCLKSEL,clk_1M024,clk_2M048,clk_div32,clk_div64)
begin
case MCLKSEL is
    when '1' => clk_divlowSR0   <= clk_1M024 ; -- 16 kHz
                clk_divlowSR1   <= clk_2M048 ; -- 32 kHz
    when '0' => clk_divlowSR0   <= clk_div64 ; -- 11.025kHz
                clk_divlowSR1   <= clk_div32 ; -- 22.05kHz 
end case;  
end process;


process (DFS,MCLK,clk_div16,clk_div8,clk_div4,clk_div2,clk_divlowSR0,clk_divlowSR1)
begin
  case DFS is
		 	when "000" =>   r_bck    <= clk_divlowSR0 ; -- 16kHz or 11.025k BCK (64fs)
                      x128FS   <= '0'           ; -- no supported
			when "001" =>   r_bck    <= clk_divlowSR1 ; -- 32kHz or 22.05k BCK (64fs)
                      x128FS   <= '0'           ; -- no supported 
			when "010" =>   r_bck    <= clk_div16 ; -- 48kHz = 3.072M BCK (64fs)
                      x128FS   <= clk_div8  ; -- 128FS=6.144MHz
			when "011" =>   r_bck    <= clk_div8  ; -- 96kHz = 6M144 BCK (64fs)
                      x128FS   <= clk_div4  ; -- 128FS=12.288MHz
			when "100" =>   r_bck    <= clk_div4  ; -- 192kHz = 12M288 BCK (64fs)
                      x128FS   <= clk_div2  ; -- 128FS=24.576MHz
			when "101" =>   r_bck    <= clk_div2  ; -- 384kHz = 24M576 BCK (64fs)
                      x128FS   <= '0'       ; -- no supported
			when "110" =>   r_bck    <= MCLK      ; -- 768kHz = 49M152 BCK (64fs)
                      x128FS   <= '0'       ; -- no supported
			when "111" =>   r_bck    <= MCLK      ; -- 1536kHz = 98M304 BCK (64fs)
                      x128FS   <= '0'       ; -- no supported
		end case;
end process;
BCK <= r_bck ;

---------------------------------------------------------------------
-- I2S generation
----------------------------------------------------------------------
process(r_bck,wsd,wsdd,DATAR,DATAL)
begin
	if	rising_edge(r_bck) then
		wsd	  <= LRCK ; -- first buffer
		wsdd  <= wsd	; -- second buffer
	end if;
	wsp <= wsd xor wsdd ; -- generate syncronous data parallel load
	if	wsd='1' then
		data <= DATAR; 	-- sending data right
	else
		data <= DATAL; 	-- sending data left
	end if;
end process;

process(RSTn,r_bck,wsp,countbck,dataload,data)
begin
  if RSTn='1' then
  	if	falling_edge (r_bck) then
      countbck <= countbck +1 ;
  		if   wsp='1' then
  			   dataload <= data ;
  		elsif	countbck = 30  then
  				LRCK <= not LRCK ; -- Toggle LRCK
  		else
          dataload <= dataload(22 downto 0) & '0' ; -- shift data
		  end if;
      if  wsp='1' then
  		    countbck <= 0 ; -- clear bck counter
  		end if;
    end if;
  else
      LRCK  <= '0';
      dataload <= x"000000";
  end if;

end process;
SDATA <= dataload(23);
--testdata <= dataload ;
end Behavioral;
