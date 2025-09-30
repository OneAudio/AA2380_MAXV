-----------------------------------------------------------------
-- O.N 05/2017
-- 8 bits SAR control loop
--
-- Take 41LE
-----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
 
 entity SAR is
    Port ( 
          Start       	 	: in  std_logic; -- start SAR register
          clkSAR      		: in  std_logic; -- SAR clock = 2Hz
          comp            : in  std_logic; -- Comparator output (DAC compare  with dB level)
          ATT             : out std_logic_vector(7 downto 0) -- Attenuator control (8 bits)
--          Deltax		: out integer range 1 to 256;
--          stepcnt		: out integer range 0 to 8
    );
 end SAR;
 
architecture AutoTrack of SAR is

signal iATT             : integer range 1 to 256 :=256 ; -- DAC value in integer form
signal stepscount       : integer range 0 to 8 :=0  ; -- SAR steps counter
signal Delta            : integer range 1 to 256 :=256 ; -- SAR increment steps

begin 

--Deltax <= Delta;
--stepcnt <= stepscount;
ATT <= std_logic_vector(to_unsigned(iATT, 8)) ; -- integer to logic_vector convertion.

process(clkSAR,start,comp,Stepscount,Delta)

begin
    if rising_edge(clkSAR) then --Synchronize all to clkSAR (500ms period)
		if start='1' then		-- initiate SAR (take 8 sarCLK cyles).
			if stepscount < 9 then    	
			stepscount <= stepscount+1;	
			Delta <= Delta /2 ; --  Divide Delta by 2 between each cyle of the SAR register 
				if comp='1' then		-- comp=1 when signal level is higher than specified threshold.
				iATT <= iATT + (Delta); -- set lower attenuation
				else
				iATT <= iATT - (Delta); -- set higher attenuation
				end if;
			else
			stepscount <= stepscount; -- no count
			iATT <= iATT; -- freezed attenuation value
			end if;
		else
        stepscount <=0; --reset counter
		Delta <= 128 ; -- reset delta
      end if;
    else
  end if;
end process;

end architecture;
