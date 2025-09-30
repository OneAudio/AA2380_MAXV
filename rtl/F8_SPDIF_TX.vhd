-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date: 29/01/21	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take 113  LE.
-- Function F8 :  F8_SPDIF_TX.vhd
-----------------------------------------------------------------
-- parallel to serial SPDIF output.
--
-- The 25/11/2020 :
-- add 2 inputs channels
-- the 29/01/21 invert LR select for 1=Left, 0= Right
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity F8_SPDIF_TX is
 port(
  FSx128_CLK   : in std_logic; -- 128x Fsample (6.144MHz for 48K samplerate)
  DATAL        : in std_logic_vector(23 downto 0);--Left Channel Data input
  DATAR        : in std_logic_vector(23 downto 0);--Right Channel Data input
  SPDIF_OUT    : out std_logic -- S/PDIF serial output
 );
end entity F8_SPDIF_TX;

architecture behavioral of F8_SPDIF_TX is

 signal DATAIN : std_logic_vector(23 downto 0);
 signal DATAIN_buffer : std_logic_vector(23 downto 0);
 signal bit_counter : std_logic_vector(5 downto 0) := (others => '0');
 signal frame_counter : std_logic_vector(8 downto 0) := (others => '0');
 signal data_biphase : std_logic := '0';
 signal data_out_buffer : std_logic_vector(7 downto 0);
 signal parity : std_logic;
 signal channel_status_shift : std_logic_vector(23 downto 0);
 signal channel_status : std_logic_vector(23 downto 0) := "001000000000000001000000";
  signal LR_Select : std_logic;

begin

Channel_selection : process (DATAL,DATAR,LR_Select)
begin
  case (LR_Select) is
      when '0' => DATAIN <= DATAR ;
      when '1' => DATAIN <= DATAL ;
  end case;
end process Channel_selection;


FSx128_CLK_counter : process (FSx128_CLK)
begin
  if    FSx128_CLK'event and FSx128_CLK = '1' then
          bit_counter <= bit_counter + 1;
  end if;
end process FSx128_CLK_counter;

 data_latch : process (FSx128_CLK)
 begin
  if FSx128_CLK'event and FSx128_CLK = '1' then
   parity <= DATAIN_buffer(23) xor DATAIN_buffer(22) xor DATAIN_buffer(21) xor DATAIN_buffer(20) xor DATAIN_buffer(19) xor DATAIN_buffer(18) xor DATAIN_buffer(17)  xor DATAIN_buffer(16) xor DATAIN_buffer(15) xor DATAIN_buffer(14) xor DATAIN_buffer(13) xor DATAIN_buffer(12) xor DATAIN_buffer(11) xor DATAIN_buffer(10) xor DATAIN_buffer(9) xor DATAIN_buffer(8) xor DATAIN_buffer(7) xor DATAIN_buffer(6) xor DATAIN_buffer(5) xor DATAIN_buffer(4) xor DATAIN_buffer(3) xor DATAIN_buffer(2) xor DATAIN_buffer(1) xor DATAIN_buffer(0) xor channel_status_shift(23);
   if bit_counter = "000011" then
    DATAIN_buffer <= DATAIN;
   end if;
   if bit_counter = "111111" then
    if frame_counter = "101111111" then
     frame_counter <= (others => '0');
    else
     frame_counter <= frame_counter + 1;
    end if;
   end if;
  end if;
 end process data_latch;

 data_output : process (FSx128_CLK)
 begin
  if FSx128_CLK'event and FSx128_CLK = '1' then
   if bit_counter = "111111" then
    if frame_counter = "101111111" then -- next frame is 0, load preamble Z
     LR_Select <= '0';
     channel_status_shift <= channel_status;
     data_out_buffer <= "10011100";
    else
     if frame_counter(0) = '1' then -- next frame is even, load preamble X
      channel_status_shift <= channel_status_shift(22 downto 0) & '0';
      data_out_buffer <= "10010011";
      LR_Select <= '0';
     else -- next frame is odd, load preable Y
      data_out_buffer <= "10010110";
      LR_Select <= '1';
     end if;
    end if;
   else
    if bit_counter(2 downto 0) = "111" then -- load new part of data into buffer
     case bit_counter(5 downto 3) is
      when "000" =>
       data_out_buffer <= '1' & DATAIN_buffer(0) & '1' & DATAIN_buffer(1) & '1' & DATAIN_buffer(2) & '1' & DATAIN_buffer(3);
      when "001" =>
       data_out_buffer <= '1' & DATAIN_buffer(4) & '1' & DATAIN_buffer(5) & '1' & DATAIN_buffer(6) & '1' & DATAIN_buffer(7);
      when "010" =>
       data_out_buffer <= '1' & DATAIN_buffer(8) & '1' & DATAIN_buffer(9) & '1' & DATAIN_buffer(10) & '1' & DATAIN_buffer(11);
      when "011" =>
       data_out_buffer <= '1' & DATAIN_buffer(12) & '1' & DATAIN_buffer(13) & '1' & DATAIN_buffer(14) & '1' & DATAIN_buffer(15);
      when "100" =>
       data_out_buffer <= '1' & DATAIN_buffer(16) & '1' & DATAIN_buffer(17) & '1' & DATAIN_buffer(18) & '1' & DATAIN_buffer(19);
      when "101" =>
       data_out_buffer <= '1' & DATAIN_buffer(20) & '1' & DATAIN_buffer(21) & '1' & DATAIN_buffer(22) & '1' & DATAIN_buffer(23);
      when "110" =>
       data_out_buffer <= "10101" & channel_status_shift(23) & "1" & parity;
      when others =>
     end case;
    else
     data_out_buffer <= data_out_buffer(6 downto 0) & '0';
    end if;
   end if;
  end if;
 end process data_output;

 biphaser : process (FSx128_CLK)
 begin
  if FSx128_CLK'event and FSx128_CLK = '1' then
   if data_out_buffer(data_out_buffer'left) = '1' then
    data_biphase <= not data_biphase;
   end if;
  end if;
 end process biphaser;
 SPDIF_OUT <= data_biphase;

end behavioral;
