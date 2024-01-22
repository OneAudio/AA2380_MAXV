--ON le 01/02/2017
-- This function allow to create one calibration pulse 
-- when Trig is asserted, and with a duration 
-- depending on FS[1..0] 
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity button_cal is
    Port (
        CLK50M	 	:in   	STD_LOGIC; -- 50MHz input clock
        Trig		:in   	STD_LOGIC; -- trigger input pulse (short) to initiate raz (short) or autozero calibration (long).
        pulse		:buffer STD_LOGIC; -- output calibration eneble pulse with duration depending on sampling rate FS
        led_calib	:out 	STD_LOGIC; -- output for blinking led to indicate calibration in progress
        RAZ_calib	:out 	STD_LOGIC; -- output for reset calibration
        FS			:in   	STD_LOGIC_vector(1 downto 0) -- Input word to indicate active sampling rate
        );
end button_cal;

architecture Behavioral of button_cal is
	signal countpush	: integer range 0  to 10  :=0 ; -- counter for 4s min push time
	signal reached		: STD_LOGIC ; -- indicate that counter reach 4s
	signal RAZCAL		: STD_LOGIC ; -- 
	signal CAL			: STD_LOGIC ; -- 
	signal fastcount	: STD_LOGIC;							-- 375ms period counter output
	signal FSL			: STD_LOGIC_vector(1 downto 0); 		-- latched sampling rate value
	signal counter1 	: integer range 0  to 9375000  :=0 ; 	-- 9 375 000 counts of 50MHz clock for 375ms period.
	signal countmax		: integer range 0  to 65  :=0 ; 		-- maximum value of countmax counter
	signal count 		: integer range 0  to 65  :=0 ; 		-- maximum value of count counter
begin
longpush_detect: process (fastcount,Trig) -- count 8x375ms period to set CAL output (3s)
	begin							-- and RAZCAL with 1p period delay (375ms) 
		if rising_edge(fastcount) then
		CAL <= reached ;
		RAZ_calib <= RAZCAL;
		if Trig = '1' then
				if countpush =0  then
				RAZCAL <= '0';
				countpush <= countpush + 1;
				else
				RAZCAL <= '1';
				end if;
				if countpush > 1  then
				RAZCAL <= '0';
				else
				countpush <= countpush + 1;
				end if;
				if countpush <7  then 
				reached <= '0';
				countpush <= countpush + 1;
				else
				reached <= '1'; -- set the reached value when count >7 periods
				end if;
				if countpush > 9  then
				reached <= '0'; -- reset the reached value when count >9 periods
				else
				countpush <= countpush + 1;
				end if;
			else  
			countpush <= 0 ;
			reached <= '0' ;
			RAZCAL<= '0';
	end if;
end if;
end process;
latch : PROCESS (pulse, FS)  -- Latch the FS value when pulse is active to avoid unexpected behaviour
     BEGIN
		 IF (pulse = '0') THEN
         FSL <= FS;
     END IF;
END PROCESS latch;
      
 fast_divider: process (CLK50M) begin  -- create fastcount clock with 375ms period
        if rising_edge(CLK50M) then
            if  (counter1 =9375000) then
                fastcount <= NOT(fastcount);
                counter1 <=0;
            else
                counter1 <= counter1 +1;
            end if;
        end if;
end process;

	monostable: process (Trig,FSL,fastcount,pulse) -- generate pulse with a multiple number of fastcount periods
		begin 
		case FSL is							--Sampling rate select the maxcount value for corresponding pulse width
			when "01" => countmax <= 64 ;	--48kHz sampling rate = 24s autozero pulse
			when "00" => countmax <= 32 ;	--96kHz sampling rate = 24s autozero pulse
			when "10" => countmax <= 16 ;	--192kHz sampling rate = 24s autozero pulse
			when "11" => countmax <= 00 ;	--not used
		end case;
		if rising_edge(fastcount) then
		if CAL = '1' or pulse='1' then
				if count < countmax then
				pulse <= '1';
				else
				pulse <= '0';
			end if;
		if count = countmax then
		count <= 0;
		else
		count <= count + 1;
		end if;
	end if;
end if;
end process;
		led_calib  <= (fastcount and pulse) or RAZCAL ; -- Blink the led output when pulse is active to inform cali in progress
end Behavioral;
