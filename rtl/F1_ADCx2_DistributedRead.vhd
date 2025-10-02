-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 22/09/19	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 187 LE.
-- Function F1 :  F1_ADCx2_DistributedRead.vhd
-- Function to read data from two LT2380-24 ADC using the distributed
-- reading protocol.
-- ==> Data reading of both ADCs are made synchronously using same
-- control signals.
------------------------------------------------------------------
-- Averaging ratio is fixed as follow (SinC mode only) :
-- Fso=384 kHz Avg = 4 x (nFS= 1536 kHz)
-- Fso=192 kHz Avg = 8 x (nFS= 1536 kHz)
-- Fso= 96 kHz Avg = 16x (nFS= 1536 kHz)
-- Fso= 48 kHz Avg = 32x (nFS= 1536 kHz)
-- NO FIR mode available here !
-- (Note : nFS = AVG x Fso )
-- 22/09/19 : Modif for Fso 50% duty-cycle
------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F1_ADCx2_DistributedRead is
--
port(

  enable	      : in  std_logic; -- enable input
  CLOCK         : in  std_logic; -- 98.304 MHz clock input (not 100M !)
  SR            : in  std_logic_vector(1 downto 0); -- selected output effetive sampling rate (48,96 or 192kHz)
  DOUTL	 	      : out std_logic_vector(23 downto 0); --ADC parrallel output data, 24 bits wide, Left channel
  DOUTR	 	      : out std_logic_vector(23 downto 0); --ADC parrallel output data, 24 bits wide, Right channel
  Fso		        : buffer std_logic ; -- effective output sampling rate
  nFS			      : out std_logic ; -- ADC sampling rate unaveraged (equal Fso * averaging ratio)

  --- ADC i/o control signals
  -- Left Channel ADC
  nCNVL         : out std_logic ; -- ADC start conv signal (inverted), Left channel
  BUSYL         : in std_logic  ; -- ADC BUSY signal, Left channel
  SDOL          : in std_logic  ; -- ADC data output, Left channel
  -- Right Channel ADC
  nCNVR         : out std_logic ; -- ADC start conv signal (inverted), Right channel
  BUSYR         : in std_logic  ; -- ADC BUSY signal, Right channel
  SDOR          : in std_logic  ; -- ADC data output, Right channel
  -- ADCs Clocks
  SCK           : out std_logic ; -- ADC clk_div4
  -- S/PDIF clock
  CK128FS	    	: out std_logic   -- 128 Fso output for SPDIF (6.144M to 24.576M)
);

end F1_ADCx2_DistributedRead;

architecture Behavioral of F1_ADCx2_DistributedRead is

signal  clk_divider : unsigned (5 downto 0); -- clock divider counter
signal  clk_div2	: std_logic ; --  49.152 MHz clock
signal  clk_div4	: std_logic ; --  24.576 MHz clock
signal  clk_div8	: std_logic ; --  12.288 MHz clock
signal  clk_div16	: std_logic ; --   6.144 MHz clock

signal  xFS  	    : std_logic ; -- output sampling clock

signal  avg_max     : integer range 1 to 32  ; -- max average value
signal  avg_cnt     : integer range 1 to 32  ; -- average counter
signal  tclk_cnt    : integer range 0 to 6   ; -- clk_div4 pulse counter for each xFS period
signal  tclk23      : integer range 0 to 23   ; -- clk_div4 pulses counter for complete ADC reading

signal  enable_sck  : std_logic; -- ADC clk_div4 enable
signal  QA          : std_logic ; --
signal  ResetA      : std_logic ; --
signal  ena_sck     : std_logic ; --
signal  ena_shft    : std_logic ; --
signal  enable_read : std_logic ; --
signal  sckshift	  : std_logic ; --
signal  r_sck	      : std_logic ; --

signal	r_DATAL     : std_logic_vector (23 downto 0) ; -- DATAL Left channel temp buffer
signal	r_DATAR     : std_logic_vector (23 downto 0) ; -- DATAL Right channel temp buffer

begin

------------------------------------------------------------------
-- CLOCK divider
-- This is the same nCNV pulse for both Left/Right ADC (from ResetA signal).
------------------------------------------------------------------
p_clk_divider: process(CLOCK,enable,enable_sck,ResetA)
begin
	if enable = '1' then
		if  (rising_edge(CLOCK)) then
		    clk_divider   <= clk_divider + 1;
		end if;
    --
    nCNVL 	<= not ResetA 	; -- ADC start convertion pulse (inverted),Left channel
	  nCNVR	  <= not ResetA 	; -- ADC start convertion pulse (inverted), Right channel
	else
    nCNVL 	<= '1' 	; -- nCNV set to high,Left channel
	  nCNVR 	<= '1' 	; -- nCNV set to high,Right channel
    clk_divider <= "000000" ; -- clear counter if enable is low.
	end if;
end process p_clk_divider;

-- Generate all 128 Fso clocks
clk_div2    <= clk_divider(0); -- 50 MHz (128*384)
clk_div4    <= clk_divider(1); -- 25 MHz (128*192)
clk_div8  	<= clk_divider(2); -- 12.5 MHz (128*96)
clk_div16	  <= clk_divider(3); -- 6.125 MHz (128*48)

xFS         <= clk_divider(5); -- 15 kHz (384x4/192x8/96x16/48x32)

nFS <= xFS ; -- nFS always equal 1536 kHz

------------------------------------------------------------------
-- Decoding 128FS frequencies and averaging value from  SR inputs
------------------------------------------------------------------
process (CLOCK,SR,clk_div4,clk_div8,clk_div16)
begin
  if rising_edge(clock) then
    case SR is
      when "00" => avg_max  <= 32 		; -- Fso= 48k,  averaging = 32x
                   CK128FS	<= clk_div16; -- CK128FS = 6.144M
      when "01" => avg_max  <= 16 		; -- Fso= 96k,  averaging = 16x
  			           CK128FS	<= clk_div8	; -- CK128FS = 12.288M
      when "10" => avg_max  <= 8  		; -- Fso=192k,  averaging = 8x
  		             CK128FS	<= clk_div4	; -- CK128FS = 24.576M
      when "11" => avg_max  <= 4  		; -- Fso=384k,  averaging = 4x
  			           CK128FS	<= clk_div2	; -- CK128FS = 49.152M
    end case;
  end if;
end process;

------------------------------------------------------------------
-- Enable SCK window for auto averaging process of ADC
-- xFS is ADC real sampling clock ) 1536kHz
------------------------------------------------------------------
process (xFS,avg_cnt,avg_max)
begin
    if rising_edge(xFS) then
        --
        if  avg_cnt < avg_max then
            avg_cnt <=avg_cnt +1; -- increment coounter
        else
            avg_cnt <= 1 		; -- reset counter
        end if;
        -- Generate 50% duty cycle Fso (LRCK) (output effective sampling clock)
        if  avg_cnt <= (avg_max/2)  then
            Fso <= '1'  ; -- set to high for half averaging cycle
        else
            Fso <= '0'  ; -- set to low for half averaging cycle
        end if;
        -- Generate ADC clock window
        if  avg_cnt = avg_max-1 then
            enable_sck <= '0' 	; -- disable ADC clk_div4 for last avg count (end of averaging)
        else
            enable_sck <= '1' 	; -- enable clk_div4
        end if;
        -- Generate enable data read window.
        if  avg_cnt = avg_max or avg_cnt <6 then
            enable_read <= '1' 	; -- enable reading for only 4x6 clocks count
        else
            enable_read <= '0' 	; -- disable reading
        end if;
    end if;
end process;
--

------------------------------------------------------------------
---- window to limit the reading of the only 23 first clock cycle
--------------------------------------------------------------------
process (enable_sck,r_sck,tclk23)
begin
	if	enable_sck = '0' then
		tclk23 <= 0			;
	elsif  rising_edge(r_sck) and tclk23 < 23 then
        tclk23 <= tclk23 +1 ;
	end if;
end process;

------------------------------------------------------------------
-- ADC nCNV pulse generator
------------------------------------------------------------------
process (xFS,ResetA,clk_div4)
begin
	if	ResetA='1' then
		QA 		<= '0'	;
	elsif rising_edge(xFS) then
		QA		<= '1'	;
	end if;
end process;
--

process (clk_div4)
begin
	if	rising_edge(clk_div4) then
		ResetA	<= QA	;
	end if;
end process;

------------------------------------------------------------------
-- ADC SCK pulse generator
-- and SDO read shift register clock
-----------------------------------------------------------------
process (enable_sck,clk_div4,tclk_cnt,BUSYL,BUSYR)
begin
	if rising_edge(clk_div4) then
		if  BUSYL='0' and BUSYR='0' then -- Both ADC Busy flags must be low.
			--
			if  tclk_cnt < 5 then
				tclk_cnt <= tclk_cnt+1;
			end if;
			--
			if  tclk_cnt > 0  and tclk_cnt < 5 then
				ena_sck  <= '1' 	;
			else
				ena_sck  <= '0' 	;
			end if;
			--
			if  tclk_cnt < 4 then
				ena_shft <= '1' ;
			else
				ena_shft <= '0' ;
			end if;
			--
		else
			tclk_cnt <= 0;
		end if;
	end if;
end process;

process (clock)
begin
	if  rising_edge(clock) then
		r_sck <= clk_div4 and enable_sck and ena_sck;      -- ADC clock pulse
		sckshift <= clk_div4 and enable_read and ena_shft; -- shift register clock
	end if;
end process;

SCK <= r_sck;

--------------------------------------------------------------------
-- ADCs Serial data Input Process
-- Both LefT/Right channels SDO data are read at same time
-- but when both Busy flag are falling
--------------------------------------------------------------------
p_serial_input : process(clock,sckshift)
begin
	if falling_edge(sckshift) then --stored data of SDO is send to bit 0 to 23 of DATAO
		case tclk23 is
			when  0  => r_DATAL(23)  <= SDOL; -- MSB Left channel
						      r_DATAR(23)  <= SDOR; -- MSB Right channel
			when  1  => r_DATAL(22)  <= SDOL;
						      r_DATAR(22)  <= SDOR;
			when  2  => r_DATAL(21)  <= SDOL;
						      r_DATAR(21)  <= SDOR;
			when  3  => r_DATAL(20)  <= SDOL;
						      r_DATAR(20)  <= SDOR;
			when  4  => r_DATAL(19)  <= SDOL;
						      r_DATAR(19)  <= SDOR;
			when  5  => r_DATAL(18)  <= SDOL;
						      r_DATAR(18)  <= SDOR;
			when  6  => r_DATAL(17)  <= SDOL;
						      r_DATAR(17)  <= SDOR;
			when  7  => r_DATAL(16)  <= SDOL;
						      r_DATAR(16)  <= SDOR;
			when  8  => r_DATAL(15)  <= SDOL;
						      r_DATAR(15)  <= SDOR;
			when  9  => r_DATAL(14)  <= SDOL;
						      r_DATAR(14)  <= SDOR;
			when 10  => r_DATAL(13)  <= SDOL;
						      r_DATAR(13)  <= SDOR;
			when 11  => r_DATAL(12)  <= SDOL;
						      r_DATAR(12)  <= SDOR;
			when 12  => r_DATAL(11)  <= SDOL;
						      r_DATAR(11)  <= SDOR;
			when 13  => r_DATAL(10)  <= SDOL;
						      r_DATAR(10)  <= SDOR;
			when 14  => r_DATAL( 9)  <= SDOL;
						      r_DATAR( 9)  <= SDOR;
			when 15  => r_DATAL( 8)  <= SDOL;
						      r_DATAR( 8)  <= SDOR;
			when 16  => r_DATAL( 7)  <= SDOL;
						      r_DATAR( 7)  <= SDOR;
			when 17  => r_DATAL( 6)  <= SDOL;
						      r_DATAR( 6)  <= SDOR;
			when 18  => r_DATAL( 5)  <= SDOL;
						      r_DATAR( 5)  <= SDOR;
			when 19  => r_DATAL( 4)  <= SDOL;
						      r_DATAR( 4)  <= SDOR;
			when 20  => r_DATAL( 3)  <= SDOL;
						      r_DATAR( 3)  <= SDOR;
			when 21  => r_DATAL( 2)  <= SDOL;
						      r_DATAR( 2)  <= SDOR;
			when 22  => r_DATAL( 1)  <= SDOL;
						      r_DATAR( 1)  <= SDOR;
			when 23  => r_DATAL( 0)  <= SDOL; -- LSB Left channel
						      r_DATAR( 0)  <= SDOR; -- LSB Right channel
			when others => NULL;
		end case;
  end if;
end process p_serial_input;

------------------------------------------------------------------------------
-- Transfer data register to DOUTL and DOUTR output at each rising edge
-- of Fso (LRCK) signal output is 0 if enable input is low
------------------------------------------------------------------------------
process (enable, Fso)
begin
	if 	enable='1' then
		if	falling_edge(Fso) then
			DOUTL <= r_DATAL; -- Left channel data latch
			DOUTR <= r_DATAR; -- Right channel data latch
		end if;
	else
		DOUTL <= x"000000" ; -- output set to 0 when enable is not active
		DOUTR <= x"000000" ; -- output set to 0 when enable is not active
	end if;
end process;

end Behavioral ;
