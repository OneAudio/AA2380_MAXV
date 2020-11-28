-----------------------------------------------------------------
-- AA2380V1 OSVA PROJECT.
-- Date:27/11/20	Designer: O.N
-----------------------------------------------------------------
-- Intel MAXV 5M570 CPLD	Take ??? LE.
-- Function F11 :  F11_ISOinterface
-----------------------------------------------------------------
-- Interface function for isolated link between AA2380 board and
-- AA10M08 CPU dauther board.
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity F11_ISOinterface is
 port(
  -- INPUTS DATA & CLOCKS
  ADC_FS      : in std_logic ; -- ADC effective sampling rate (1536kHz max)
  ADC_8FS     : in std_logic ; -- 8x Fs clock (12.288M max)
  CLK_128Fo   : in std_logic ; -- 128 Fo clock (Fo is effective output rate) : max is 384k x128= 49.152 MHz
  DATAL		  : in std_logic_vector(23 downto 0); -- Left Data input (24 bits length)
  DATAR       : in std_logic_vector(23 downto 0); --  Left Data input (24 bits length)
  -- OUTPUTS SLICED DATA
  MxDATA_L    : out std_logic_vector(3 downto 0) ; -- multiplexed output data, Left channel
  MxDATA_R    : out std_logic_vector(3 downto 0)  -- multiplexed output data, Right channel

 );
end entity F11_ISOinterface;

architecture behavioral of F11_ISOinterface is

signal DATAL_latch : std_logic_vector(23 downto 0) ; --
signal DATAR_latch : std_logic_vector(23 downto 0) ; --
signal enab_cnt    : std_logic :='0' ; --
signal MUXcnt	     : integer range 0 to 7  ; -- counter

begin

-------------------------------------------------------------------------------
--  The MUX_32to4 module slice one ADC_FS period in 8 to send 4 bits data packet
-- with muxed data. 2x 32 bits are sent in one FS period (2*8*4= 64 bits)
-- received data muste be read at falling edge of  ADC_8FS clock.
--------------------------------------------------------------------------------
MUX_32to4 : process (ADC_8FS,ADC_FS,MUXcnt,enab_cnt,DATAL,DATAR)
begin
    -- Generate count value for MUX states
    if    enab_cnt='0'  then
          MUXcnt <= 0 ; -- reset mux counter
    elsif rising_edge(ADC_8FS) then
          MUXcnt <= MUXcnt + 1 ;
          if  MUXcnt= 7  then
              enab_cnt <= '0' ;
          end if;
    end if;
    --
    if    rising_edge(ADC_FS)  then
          DATAL_latch <= DATAL ;
          DATAR_latch <= DATAR ;
          enab_cnt    <= '1'    ;
    end if;
    --
    case (MUXcnt) is
        when (0)  => MxDATA_L <= DATAL_latch(3 downto 0);
                     MxDATA_R <= DATAR_latch(3 downto 0) ;
        when (1)  => MxDATA_L <= DATAL_latch(7 downto 4) ;
                     MxDATA_R <= DATAR_latch(7 downto 4) ;
        when (2)  => MxDATA_L <= DATAL_latch(11 downto 8) ;
                     MxDATA_R <= DATAR_latch(11 downto 8) ;
        when (3)  => MxDATA_L <= DATAL_latch(15 downto 12) ;
                     MxDATA_R <= DATAR_latch(15 downto 12) ;
        when (4)  => MxDATA_L <= DATAL_latch(19 downto 16) ;
                     MxDATA_R <= DATAR_latch(19 downto 16) ;
        when (5)  => MxDATA_L <= DATAL_latch(23 downto 20) ;
                     MxDATA_R <= DATAR_latch(23 downto 20) ;
        when (6)  => MxDATA_L <= DATAL_latch(27 downto 24) ;
                     MxDATA_R <= DATAR_latch(27 downto 24) ;
        when (7)  => MxDATA_L <= DATAL_latch(32 downto 28) ;
                     MxDATA_R <= DATAR_latch(32 downto 28) ;
    end case;
end process MUX_32to4 ;


end behavioral ; -- end of file.
