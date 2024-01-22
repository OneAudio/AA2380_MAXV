-----------------------------------------------------------------
--	ON le 29/03/2017
--	4 digits autoscale frequency meter.
--	(999.9 Hz to 999.9 kHz in 4 auto ranges).
--	10ms, 100ms, 1s and 10s Gate time. 
--	from 50MHz input clock.
--	Output is ASCII form for 4 digits + decimal point = 5 octets
-- 	Take 268 LE.
-----------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
 
 entity Freq_counter is
    Port ( 
           Fin		: in  std_logic; -- input frequency signal
           Refresh	: in  std_logic; -- Clock for autoscale refresh
           clk 		: in  std_logic; -- 50M input clock
--            clear	: in  std_logic; -- Clear input to synchronisation (?)
		   gateout  : out std_logic; -- Gate output (test only)
		   Aff_pos	: in std_logic_vector (5 downto 0); -- binary value of current display position
--		   CS		: in std_logic ; -- Chip select input (for tri-state Ascii_out output).
		   Ascii_out: OUT std_logic_vector(7 downto 0) -- Muxed ascii digits output
--		   max_cnt 	: out integer range 0 to 500000 
    );
 end Freq_counter;
 
 architecture frequencymeter of Freq_counter is
   signal max_count : natural := 500000 ; -- 10s max gate time from 50MHz clock
   signal gates		: std_logic;	 -- Gate time to count Fin
   signal Fout		: integer range 0 to 10000 ; -- output count i gate time
   signal count 	: natural range 0 to 500000000;-- mximum value of counter
   signal Fo		: integer range 0 to 10000 ;-- Number of count in gate time.
   signal Unit		: std_logic_vector (3 downto 0); -- First digit
   signal Tens		: std_logic_vector (7 downto 4); -- Second digit
   signal Hund		: std_logic_vector (11 downto 8); -- Third digit
   signal Thou		: std_logic_vector (15 downto 12); -- Fourth digit
   signal Da		: std_logic_vector(7 downto 0); -- First left digit
   signal Db		: std_logic_vector(7 downto 0); -- Second digit
   signal Dc		: std_logic_vector(7 downto 0); -- Third digit
   signal Dd		: std_logic_vector(7 downto 0); -- Fourth 
   signal De		: std_logic_vector(7 downto 0); -- Fifth digit
   signal Df		: std_logic_vector(7 downto 0); -- Sixt digit
	signal zgate	: std_logic_vector(7 downto 0); -- z gate indicator
   signal position : integer range 0 to 64; -- Display character position

   
 begin
----------------------------------------------------------------------
-- Measurement counter : count number of Fin rising edge in gate time interval
----------------------------------------------------------------------

 MeasureFin : process (gates,Fout,Fin)
	begin
		if gates='1' then
			if rising_edge(Fin) then
				if Fout < 9999 then
				Fout <= Fout +1 ; -- increment counter at each cycle of input frequency
				else 
				Fout <= 9999;-- Stop counter when it reach 9999.
				end if;
			end if;
		else 
		Fout <= 0 ; --reset counter after each gate time
		end if;
	end process MeasureFin ;
	
-------------------------------------------------------------------------------------
-- Autoscale gate time from input frequency and set decimal point in right position
-------------------------------------------------------------------------------------
 Autoscale : process (gates)
    begin
		if rising_edge(gates) then
			if (max_count =500000) then 		-- Gate of 10ms (999.9 kHz range)
				if  Fo < 1000 then 			-- Frequency is below 100.0 kHz
				max_count <= 5000000;   		-- New gate time is 100 ms
				else
				max_count <= 500000;  -- stay to previous value
				end if;
			 Da <= x"3" & Thou;
			 Db <= x"3" & Hund;
			 Dc <= x"3" & Tens;
			 Dd <= x"2E" ; -- decimal point
			 De <= x"3" & Unit ;
			 Df <= x"6B";  -- kHz indicator
			elsif (max_count = 5000000) then	-- Gate of 100ms (99.99 kHz range)
				if Fo < 1000 then			-- Frequency is below 10.00 kHz
				max_count <= 50000000;			-- New gate time is 1s
				elsif Fo  = 9999 then		-- Frequency is upper than 100.0 kHz
				max_count <= 500000;			-- New gate time is 10 ms
				else
				max_count <= 5000000;  -- stay to previous value
				end if;
			 Da <= x"3" & Thou;
			 Db <= x"3" & Hund;
			 Dc <= x"2E" ; -- decimal point
			 Dd <= x"3" & Tens;
			 De <= x"3" & Unit ;
			 Df <= x"6B"; -- kHz indicator
			elsif (max_count = 50000000) then	-- Gate of 1s (9.999 kHz range)	
				if Fo  < 1000 then			-- Frequency is below 1.000 kHz
				max_count <= 500000000;			-- New gate time is 10s
				elsif Fo  = 9999 then		-- Frequency is upper than 10.00 kHz
				max_count <= 5000000;			-- New gate time is 100 ms
				else
				max_count <= 50000000;  -- stay to previous value
				end if;
			 Da <= x"3" & Thou;
			 Db <= x"2E"; -- decimal point
			 Dc <= x"3" & Hund;
			 Dd <= x"3" & Tens ;
			 De <= x"3" & Unit ;
			 Df <= x"6B"; -- kHz indicator
			elsif (max_count = 500000000) then	-- Gate of 10s (999.9 Hz range)	
				if Fo  = 9999 then			-- Frequency is upper than 1.000 kHz
				max_count <= 50000000;			-- New gate time is 1s
				else
				max_count <= 500000000;  -- stay to previous value
				end if;
			 Da <= x"3" & Thou;
			 Db <= x"3" & Hund;
			 Dc <= x"3" & Tens;
			 Dd <= x"2E" ; -- decimal point
			 De <= x"3" & Unit ;
			 Df <= x"20"; -- no indicator
		   end if;
	   end if;	
end process Autoscale ; 

----------------------------------------------------------------------
-- Counting Gate generation (10ms,100ms,1s and 10s from 50MHz clock).
----------------------------------------------------------------------
compteur : process(clk)
  begin
     if rising_edge(clk) then
        if    count < max_count then
              gates    <='1';
              count <= count + 1;
        elsif count = max_count then
              gates <='0';
              count <= count + 1;
              Fo <= Fout; --  send Fout counter value in Fo register
        else
              count <= 0;
              gates   <='1';
        end if;
      end if;
end process compteur;
----------------------------------------------------------------------
-- Generate 50% duty cycle gate output (for display purpose)
-- Z of Hz indictor is used to show gate time on LCD.
----------------------------------------------------------------------
process (clk)
begin
     if rising_edge(clk) then
        if    count < (max_count/2) then
              gateout <= '1';
				  zgate 	 <= x"7A"; -- The 'z' is lower case
        else
              gateout <= '0';
				  zgate   <= x"5A" ; -- The  'Z' is upper case.
        end if;
      end if;
end process;
    
----------------------------------------------------
-- Convert Fo binary value to 4 digits BCD format.
----------------------------------------------------
bcd1: process(Fo)
  variable temp : STD_LOGIC_VECTOR (13 downto 0);
  variable bcd : UNSIGNED (15 downto 0) := (others => '0');
  begin
    bcd := (others => '0');
    temp(13 downto 0) := std_logic_vector(to_unsigned(Fo, 14));
    for i in 0 to 13 loop
      if bcd(3 downto 0) > 4 then 
        bcd(3 downto 0) := bcd(3 downto 0) + 3;
      end if;
      if bcd(7 downto 4) > 4 then 
        bcd(7 downto 4) := bcd(7 downto 4) + 3;
      end if;
      if bcd(11 downto 8) > 4 then  
        bcd(11 downto 8) := bcd(11 downto 8) + 3;
      end if;
      bcd := bcd(14 downto 0) & temp(13);
      temp := temp(12 downto 0) & '0';
    end loop;
    Unit <= STD_LOGIC_VECTOR(bcd(3 downto 0));
    Tens <= STD_LOGIC_VECTOR(bcd(7 downto 4));
    Hund <= STD_LOGIC_VECTOR(bcd(11 downto 8));
    Thou <= STD_LOGIC_VECTOR(bcd(15 downto 12));
end process bcd1;

------------------------------------------------------------------
-- Ascii_out muxed output 1 to 6 
-- 4 digits + decimal point (moving) + "k" indicator when kHz range
------------------------------------------------------------------
process (Aff_pos,clk)
begin 	
	position <= to_integer(unsigned(Aff_pos));
	if rising_edge(clk) then
			if 	  position= 1 then
			ascii_out <=  Da ;
			elsif position= 2  then
			ascii_out <=  Db ;
			elsif position= 3 then
			ascii_out <=  Dc ;
			elsif position= 4 then
			ascii_out <=  Dd ;
			elsif position= 5 then
			ascii_out <=  De;
			elsif position= 6 then
			ascii_out <=  Df;
			elsif position= 8 then
			ascii_out <= zGate;
			else
			ascii_out <= "ZZZZZZZZ";--output is high Z state for others count value.
			end if;
	end if;
end process;
	
end frequencymeter;
