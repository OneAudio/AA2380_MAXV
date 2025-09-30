----------------------------------------------------------------------------------
-- The 19/01/24 O.Narce
-- Generate a 24 bits 2's complement coded sine/cosine wave 
-- level is -6 dBFS (no offset).
-- Lockup table with only data point between 0 to pi/2.
-- because others are same but with sign change only.
-- with 8 bits address bus, the full sine data is 16x4 = 64 values => 6 bits
-- address input width.
-- One auxiliary output for square wave sync of sine/cosine wave.
--
-- Tested ok !
-- Take 93 LE
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity LUT_Quarter is

    Port (CLOCK     : in  STD_LOGIC ;
          LUT_Addr  : in  STD_LOGIC_vector(4 downto 0); -- lockup table input data address
          SIN_OUT   : out signed(23 downto 0); -- output LUT table values (sine)
          COS_OUT   : out signed(23 downto 0); -- output LUT table values (cosine)
          SYNC_OUT  : out STD_LOGIC  -- square wave sync output of sine wave (sync to sine)
          -- TEST OUTPUTS :
          --MSB_addr : buffer STD_LOGIC ;
          --XOUT1     : buffer  signed(23 downto 0);
          --XOUT2     : buffer  signed(23 downto 0);
          --LUTtronc : buffer integer range 0 to 32
          );
        
end LUT_Quarter;

architecture Behavioral of LUT_Quarter is
 
signal DecAddr   :integer range 0 to 8 ; -- modified address 
signal LUTtronc  :integer range 0 to 8 ;--
signal MSB_addr  :STD_LOGIC ; --
signal XOUT1      : signed(23 downto 0);
signal XOUT2      : signed(23 downto 0);

 
begin

LUTtronc <=to_integer(unsigned(LUT_Addr(3 downto 0))); -- 
MSB_addr <= LUT_Addr(4);-- MSB (5);-- MSB bit of address word
-----------------------------------------------------------------------
-- Address decoding to use only 1/4 of sine wave lockup table
-----------------------------------------------------------------------
process(MSB_addr,LUTtronc,XOUT1,XOUT2,LUT_Addr)
begin
    if  MSB_addr='0' then
    -- first half wave of sine (0..pi), positive values of wave (unchanged LUT value)
        if  LUTtronc>8 then
            DecAddr <= 16-LUTtronc ;--
        else
            DecAddr <= LUTtronc ;--
        end if;
    SIN_OUT <= XOUT1;--
    SYNC_OUT <= '1'; -- Synch high
    else 
    -- second half of wave, all LUT value are inverted to get negative value,
    -- to do this, all bit are inverted and 1 is added to get negative value.
        if  LUTtronc>8 then
            DecAddr <= 16-LUTtronc  ;--
        else
            DecAddr <= LUTtronc ;--
        end if;
    SIN_OUT <= -(XOUT1);-- inverted value
    SYNC_OUT <= '0'; -- Synch high
    end if;
    --
    -- For cosine output, the negative value are when both most MSB are high, but at same time (xor)
    if  (LUT_Addr(4)='1' xor LUT_Addr(3)='1') then -- the 2 MSB of address are high, not both 
        COS_OUT <= -(XOUT2);--inverted value
    else
        COS_OUT <= XOUT2;-- inverted value
    end if;
end process;

-----------------------------------------------------------------------
-- LUT table with 1/4 sine period data (0 to pi/2)
-- Here is for 16 points for 1/4 period or 64 points for each sine cycle
-----------------------------------------------------------------------
process(CLOCK,DecAddr)
begin
    if  CLOCK'event and CLOCK='1' then
        case DecAddr is  -- 
            when 0  => XOUT1 <= x"000000"; --24 bits signed value
            when 1  => XOUT1 <= x"164184";
            when 2  => XOUT1 <= x"2BA815";
            when 3  => XOUT1 <= x"3F6128";
            when 4  => XOUT1 <= x"50AAB5";
            when 5  => XOUT1 <= x"5EDAAA";
            when 6  => XOUT1 <= x"696573";
            when 7  => XOUT1 <= x"6FE35B";
            when 8  => XOUT1 <= x"721483";
            when others => XOUT1 <= x"000000";
        end case;
        --- Cosine output (same data as Sine, but mirrored)
        case DecAddr is  --
            when 0  => XOUT2 <= x"721483"; --24 bits signed value
            when 1  => XOUT2 <= x"6FE35B";
            when 2  => XOUT2 <= x"696573";
            when 3  => XOUT2 <= x"5EDAAA";
            when 4  => XOUT2 <= x"50AAB5";
            when 5  => XOUT2 <= x"3F6128";
            when 6  => XOUT2 <= x"2BA815";
            when 7  => XOUT2 <= x"164184";
            when 8  => XOUT2 <= x"000000";
            when others => XOUT2 <= x"000000";
        end case;
    end if;                           
end process;                       
                                   
end Behavioral;                    

















