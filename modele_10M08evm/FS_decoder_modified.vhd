-----------------------------------------------------
-- AA2380 CPLD DESIGN  ON 01/2017 
-- Cette fonction permet de gérer automatiquement
--les fréquences d'échantillonage en fonction de
--la moyenne choisi de 1 à 32 pour des fréquences
--de sortie FS effective de 48/96 et 192kHz réel
--En mode avec le filtre RIF du MAX10, la fréquence
-- d'échantillonage de l'ADC est égale a 8FS et 
-- le moyennage est inactif.
--On génére également le signal de reset du compteur
-- externe de la moyenne pour limiter la moyenne possible
-- en fonction de FS (Maxi: x8/192k x16/96x et x32/48k)
--On génère aussi la commande de 3 leds pour afficher
-- le SR en cours.
--
-- FIR mode at 192k mofied for 4x decimation only, 
-- for test if lower THD
-----------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
entity  FS_decoder_modified  is
   port(CLOCK				:	in	std_logic; 						-- Input clock for synchonous operation
   		FS					:	in	std_logic_vector(1 downto 0);	-- 3 positions FS switch (2 bits)
		FIR_nSINC			:	in	std_logic; 						-- Switch for FIR or SinC mode.
        AVG					:	in 	std_logic_vector (2 downto 0);	-- 3 bits of average counter (extrenal)
   		nSTOP				:   out std_logic;						-- nSTOP output to disable averaging counter counter
   		CLEAR				:   out std_logic;						-- Clear output of averaging counter
   		SRATE				:	out std_logic_vector (2 downto 0);	-- Output sampling rate word for FS mux control
   		LED_48				:	out std_logic;						-- output for LED indicator of 48kHz SR
   		LED_96				:	out std_logic;						-- output for LED indicator of 96kHz SR
   		LED_192				:	out std_logic);						-- output for LED indicator of 192kHz SR
end  FS_decoder_modified;
 
ARCHITECTURE Behavioral OF FS_decoder_modified IS
signal 	CLR		:	std_logic;
signal 	STP		:	std_logic;
signal	AVER	:	std_logic_vector (2 downto 0); 

begin 
	process (CLOCK,FS,FIR_nSINC,AVG,AVER)
	begin 
	LED_48  <= FS(0) and not FS(1);		-- 48k position, --> LED_48  ON
	LED_96  <= not FS(0) and not FS(1);	-- 96k position, --> LED_96  ON
	LED_192 <= FS(1) and not FS(0);		-- 192k position,--> LED_192 ON 
	
	if (CLOCK'event and CLOCK='1') then
		AVER <= AVG;	-- synchronize AVER input to clock
		nSTOP<= STP;	-- synchronize nSTOP output to clock
		CLEAR<= CLR;	-- synchronize CLEAR output to clock
	end if;	
	
	if	(FS="00" and (AVER >="100")) or
		(FS="10" and (AVER >="011")) or
		(FS="01" and (AVER >="101")) then -- stop the external average counter to limit values (x16 for 96k and x8 for 192k)
				STP <='0' ;
		else 	STP <='1' ;
	end if;
	
	if	(FS="00" and (AVER >="101")) or
		(FS="10" and (AVER >="100")) or
		(FS="01" and (AVER >="110")) or
		(FIR_nSINC = '1')			then -- stop the external average counter to limit values (x16 for 96k and x8 for 192k)
				CLR <='1' ;
		else	CLR <='0' ;
	end if;
	
		SRATE <= "000";       	 -- default sampling rate
		if (FIR_nSINC = '1') then -- FIR filter with 8x decimation active, no averaging allowed
			case FS is
				when "01" => SRATE <="101";		-- 48k position => 384kHz SRATE
				when "00" => SRATE <="110";		-- 96k position => 768kHz SRATE 
				when "10" => SRATE <="111";		-- 192k position => 1536 kHz SRATE for only 4x decimation rate  --For test only
				when others => SRATE <="000";
			end case;
		else if (AVER="000" and FIR_nSINC = '0' ) then -- SinC filter active with no averaging ratio
			case FS is
				when "01" => SRATE <="010";		-- 48k position => 48kHz SRATE
				when "00" => SRATE <="011";		-- 96k position => 96kHz SRATE 
				when "10" => SRATE <="100";		-- 192k position => 192kHz SRATE
				when others => SRATE <="000" ;
			end case;
		else if (AVER="001" and FIR_nSINC = '0' ) then -- SinC filter active with x2 averaging ratio
			case FS is
				when "01" => SRATE <="011";		-- 48k position => 96kHz SRATE
				when "00" => SRATE <="100";		-- 96k position => 192kHz SRATE 
				when "10" => SRATE <="101";		-- 192k position => 384kHz SRATE
				when others => SRATE <="000";
			end case;
		else if (AVER="010" and FIR_nSINC = '0' ) then -- SinC filter active with x4 averaging ratio
			case FS is
				when "01" => SRATE <="100";		-- 48k position => 192kHz SRATE
				when "00" => SRATE <="101";		-- 96k position => 384kHz SRATE 
				when "10" => SRATE <="110";		-- 192k position => 768kHz SRATE
				when others => SRATE <="000";
			end case;
		else if (AVER="011" and FIR_nSINC = '0' ) then -- SinC filter active with no x8 averaging ratio
			case FS is
				when "01" => SRATE <="101";		-- 48k position => 384kHz SRATE
				when "00" => SRATE <="110";		-- 96k position => 768kHz SRATE 
				when "10" => SRATE <="111";		-- 192k position => 1536kHz SRATE
				when others => SRATE <="000";
			end case;
		else if (AVG="100" and FIR_nSINC = '0' ) then -- SinC filter active with x16 averaging ratio
			case FS is
				when "01" => SRATE <="110";		-- 48k position => 768kHz SRATE
				when "00" => SRATE <="111";		-- 96k position => 1536kHz SRATE 
				when "10" => SRATE <="111";		-- 192k position =>  --- kHz SRATE
				when others => SRATE <="000";
			end case;
		else if (AVER="101" and FIR_nSINC = '0' ) then -- SinC filter active with x32 averaging ratio
			case FS is
				when "01" => SRATE <="111";		-- 48k position => 1536kHz SRATE
				when "00" => SRATE <="111";		-- 96k position => ---kHz SRATE 
				when "10" => SRATE <="111";		-- 192k position => ---kHz SRATE
				when others => SRATE <="000";
			end case;
			end if;
		end if;
		end if;
		end if;
		end if;
		end if;
		end if;
	end process; 
end Behavioral;
