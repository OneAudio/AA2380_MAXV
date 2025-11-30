
-- File        : F15_Par2I2S_2S4P.vhd
-- Project     : AA2380V1 OSVA
-- Author      : O.N
-- Date        : 31/10/2025
-- Size        : 98 LE (Intel MAXV 5M570 CPLD)
-- Status      : Verified on AA2380V1 board 
--
--   This module is intended to send audio data over a 2x4-lane I²S-like
--   serial interface. The 2x4 lanes allow much lower clock rates.
--   These data are send through isolated link between AA2380V1 board and
--   the AA10M08 FPGA board.   
--
-- Description :
--   Parallel-to-serial interface generating two 4-lane I²S-like outputs.
--   This module takes 24-bit parallel audio samples (Left and Right),
--   optionally replaces them with fixed test patterns, and serializes
--   them simultaneously over 4x data lanes (4 bits per CLK8FS period).
--
-- Functional overview :
--   • Input parallel audio data DATAL/DATAR (24 bits each)
--   • On each rising edge of LRCK (sample rate clock), a LOAD pulse
--     (PARI2S_LOAD) is generated, one MCLKI cycle wide
--   • On PARI2S_LOAD:
--        - If TSTMODE = '1',
--          Load generic fixed test patterns (DATAL_TST/DATAR_TST).
--        - Else load actual audio samples
--   • On each rising edge of CLK8FS:
--        - Shift the 24-bit word left by 4 bits
--        - Output the 4 MSBs (bits 23 downto 20) on the 4-lane I²S bus
--
-- Timing overview :
--   • MCLKI  = Master high-speed clock (≈ 98 MHz or ≈ 90 MHz)
--   • LRCK   = Frame clock (sample rate, e.g., 44.1 kHz / 48 kHz / etc.)
--   • CLK8FS = 8 × LRCK (8 FS), used as parallel data shift clock
--              -> Each rising edge outputs 4 new bits on each 4-bit lane
--
-- Test mode (generics DATAL_TST, DATAR_TST) :
--   • TSTMODE = '1' forces the output to send repeating test patterns:
--         Left  channel = DATAL_TST (default = x"B20EA7")
--         Right channel = DATAR_TST (default = x"9C9F4D")
--
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity F15_Par2I2S_2S4P is
--
GENERIC(
    DATAL_TST : std_logic_vector(23 downto 0) := x"B20EA7"; -- Fixed Left-channel test word
    DATAR_TST : std_logic_vector(23 downto 0) := x"9C9F4D"  -- Fixed Right-channel test word
    ); 
port(
    -- INPUTS
    MCLKI      : in  std_logic ;                     -- Main high-speed clock (≈98 MHz or ≈90 MHz)
    CLK8FS     : in  std_logic ;                     -- 8× sample rate clock (parallel shift clock)
    LRCK       : in  std_logic ;                     -- Frame clock (sample rate, up to 1.536 MHz)
    DATAL      : in  std_logic_vector(23 downto 0) ; -- Parallel Left-channel input sample
    DATAR      : in  std_logic_vector(23 downto 0) ; -- Parallel Right-channel input sample
    TSTMODE    : in  std_logic ;                     -- Test mode enable

    -- OUTPUTS
    I2S4L_SDATAL : out std_logic_vector(3 downto 0); -- 4-lane serialized Left-channel data
    I2S4L_SDATAR : out std_logic_vector(3 downto 0); -- 4-lane serialized Right-channel data
    PARI2S_LOAD  : buffer std_logic                  -- Data loading pulse (1 MCLK cycle)
);

end F15_Par2I2S_2S4P;

architecture Behavioral of F15_Par2I2S_2S4P is

------------------------------------------------------------------
-- Internal shift registers for serialization
------------------------------------------------------------------
signal Lshift  : std_logic_vector(23 downto 0); -- Left-channel shift register
signal Rshift  : std_logic_vector(23 downto 0); -- Right-channel shift register

begin

------------------------------------------------------------------
-- PARI2S_LOAD Generator
--   Generates a one-clock pulse (synchronous to MCLKI)
--   on each rising edge of LRCK.
--
--   PARI2S_LOAD is used to load new 24-bit samples into the
--   serialization shift registers.
------------------------------------------------------------------
process (MCLKI)
    variable LRCKd : std_logic := '0'; -- Previous LRCK state for edge detection
begin
    if rising_edge(MCLKI) then
        -- Detect rising edge of LRCK
        -- PARi2S_LOAD pulse is one MCLKI cycle wide
        if (LRCK = '1' and LRCKd = '0') then
            PARI2S_LOAD <= '1';  -- Assert load pulse
        else
            PARI2S_LOAD <= '0';  -- Otherwise keep low
        end if;

        -- Store LRCK state for edge detection
        LRCKd := LRCK; -- LRCKd is delayed to one MCLKI cycle
    end if;
end process;

--------------------------------------------------------------------------
-- Shift Registers + Data Load Logic
--
-- Behavior:
--   • On PARI2S_LOAD = '1'
--         If TSTMODE = '1' → load test vectors
--         Else             → load input parallel samples
--
--   • On each rising edge of CLK8FS (and when PARI2S_LOAD='0'):
--         Shift left by 4 bits (insert "0000" at LSB)
--
-- Output:
--   • I2S4L_SDATAL/I2S4L_SDATAR = upper 4 bits (23 downto 20)
--     of each shift register (MSB-first serialization)
--------------------------------------------------------------------------
process (CLK8FS, PARI2S_LOAD, TSTMODE, DATAL, DATAR)
begin
    -- Load phase: triggered by PARI2S_LOAD
    if PARI2S_LOAD = '1' then
        if TSTMODE = '1' then
            Lshift <= DATAL_TST; -- Load Left test word
            Rshift <= DATAR_TST; -- Load Right test word
        else
            Lshift <= DATAL; -- Load actual Left-channel data
            Rshift <= DATAR; -- Load actual Right-channel data
        end if;

    -- Shift phase: occurs only when PARI2S_LOAD='0'
    elsif rising_edge(CLK8FS) then
        Lshift <= Lshift(19 downto 0) & "0000"; -- Shift Left  4 bits
        Rshift <= Rshift(19 downto 0) & "0000"; -- Shift Right 4 bits
    end if;
end process;

------------------------------------------------------------------
-- Output the top 4 bits of each lane (MSB-first)
------------------------------------------------------------------
I2S4L_SDATAL <= Lshift(23 downto 20); -- Left  MS nibble
I2S4L_SDATAR <= Rshift(23 downto 20); -- Right MS nibble

end architecture ;
