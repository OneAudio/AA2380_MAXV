-----------------------------------------------------------------
-- File        : F1_ReadADCFullSpeed.vhd
-- Project     : AA2380V1 OSVA
-- Author      : O.N
-- Date        : 18/11/2025
-- Size        : 126 LE (Intel MAXV 5M570 CPLD)
-- Status      : Verified on AA2380V1 board (+ ModelSim simulation)
--
-- Design notes, please read : "SPECIF_SPI_LTC2380-24.vhd" and
-- "F1_readADCmulti_ExtClk.xls"
----------------------------------------------------------------
-- Description :
--   Full-speed readout of two LTC2380-24 ADCs (Left and Right channels)
--   using their normal serial mode. Each conversion produces 24 bits per ADC.
--   This module:
--     * Generates CNV pulses for both ADCs from the sampling clock CLKFS.
--     * Waits for both ADC BUSY signals to return low (conversion complete).
--     * Generates a read clock (SCKL/SCKR) derived from MCLK.
--     * Reads 24 serial bits (SDOL/SDOR) into 24-bit shift registers.
--     * Latches the parallel data into DOUTL/DOUTR at each rising edge of CLKFS.
--
-- Clocking and timing overview :
--   - MCLK
--       * Master system clock (e.g. 98.304 MHz or 90.3168 MHz).
--       * Used for all internal synchronous logic (data readout, counters, etc.).
--
--   - CLKFS
--       * Sampling frequency clock (12 kHz to 1.536 MHz, 50% duty).
--       * Each rising edge of CLKFS corresponds to one ADC conversion period.
--       * CNV pulse is derived from CLKFS and synchronized to MCLK.
--
--   - CNV (nCNVL/nCNVR)
--       * Internal CNV pulse generated from the rising edge of CLKFS.
--       * Pulse width is ~3 * MCLK period (~30 ns @ 98.304 MHz),
--         which satisfies the ADC minimum CNV pulse width (≥ 20 ns).
--       * External CNV pins (nCNVL, nCNVR) are active low.
--
--   - BUSY (BUSYL/BUSYR)
--       * Active high during ADC conversion.
--       * When both BUSYL and BUSYR go low, conversion is complete and
--         the serial data can be read out.
--
--   - SCKL/SCKR / ADC_CLK
--       * ADC_CLK is internally derived from MCLK and gated by CNVen_SCK.
--       * SCKL and SCKR are simply ADC_CLK forwarded to the two ADCs.
--       * 24 SCK pulses are generated per conversion to read 24 data bits.
--       * SCK pulses are delayed by 1 MCLK cycle relative to the data-read
--         window SDO_Read to ensure correct sampling of SDOL/SDOR.
--
-- Data path overview :
--   - While SDO_Read = '1' and for 24 MCLK cycles, the serial outputs
--     SDOL (Left) and SDOR (Right) are shifted into r_DATAL and r_DATAR.
--   - TCLK23 counts from 0 to 23 and indexes the bit positions (MSB->LSB).
--   - After the 24 bits are captured, at the next rising edge of CLKFS,
--     r_DATAL and r_DATAR are latched into DOUTL and DOUTR.
--
-- Assumptions / constraints :
--   - MCLK frequency is high enough to:
--       * Generate a valid CNV pulse.
--       * Provide 24 read clock cycles between conversions.
--   - CLKFS frequency is compatible with the LTC2380-24 datasheet for
--     normal mode operation (up to ~1.536 MHz).
--   - BUSYL and BUSYR behave according to LTC2380-24 timing diagrams.
--
-- Notes :
--   - This design has been simulated (ModelSim) and validated on the
--     AA2380V1 board with MCLK = 98.304 MHz and CLKFS up to 1.536 MHz.
-- Intel MAXV 5M570 CPLD	Take 126 LE
-- Function F1 :  F1_ReadADCFullSpeed.vhd
--
-- Function to read data from two LT2380-24 ADC using normal mode 
-- at sampling frequency equal to CLKFS.
-- Normal mode is always 24 reading clock cycles in one conversion.
-- This module allows ADC speed up to 1.536 MHz
-- (with 98.304MHz MCLK and 5M570ZT100C5N CPLD).
-----------------------------------------------------------------
-- Tested with ModelSim and validated on AA2380V1 board up to
-- 1.536 MHz sampling frequency with 98.304 MHz MCLK.
-----------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F1_ReadADCFullSpeed is
--
port(
    -- Input clocks
    MCLK          : in  std_logic  ; -- Master input clock (98.304 MHz or 90.3168 MHz)
    CLKFS         : in  std_logic  ; -- Sampling frequency clock (12 to 1536 kHz, 50% duty square wave)
    nRESET        : in  std_logic  ; -- Global reset, active low

    -- Data output ports (parallel data from ADCs)
    DOUTL	 	  : out std_logic_vector(23 downto 0); -- ADC parallel output data, 24 bits wide, Left channel
    DOUTR	 	  : out std_logic_vector(23 downto 0); -- ADC parallel output data, 24 bits wide, Right channel

    -- LTC2380-24 ADC SPI-like INTERFACE SIGNALS
    -- Left Channel  (First ADC)
    BUSYL         : in std_logic      ; -- ADC BUSY signal (active high), Left channel
    SDOL          : in std_logic      ; -- ADC serial data output, Left channel
    nCNVL         : out std_logic     ; -- ADC start conversion signal (active low), Left channel
    SCKL          : buffer std_logic  ; -- ADC serial data read clock, Left channel

    -- Right Channel (Second ADC)
    BUSYR         : in std_logic      ; -- ADC BUSY signal (active high), Right channel
    SDOR          : in std_logic      ; -- ADC serial data output, Right channel
    nCNVR         : out std_logic     ; -- ADC start conversion signal (active low), Right channel
    SCKR          : buffer std_logic    -- ADC serial data read clock, Right channel
);

end F1_ReadADCFullSpeed;

architecture Behavioral of F1_ReadADCFullSpeed is
--
-- CNV: internal conversion start pulse, derived from CLKFS and synchronized to MCLK
signal CNV      : std_logic ;

-- 3-stage pipeline of CLKFS into the MCLK domain, used to detect a rising edge
signal CLKFSd1  : std_logic ;
signal CLKFSd2  : std_logic ;
signal CLKFSd3  : std_logic ;

-- Counters for read-clock and data-read windows
signal CNVclk_cnt    : integer range 0 to 25 ; -- MCLK cycle counter for SCK (ADC clock) window
signal SDO_Read_cnt  : integer range 0 to 25 ; -- MCLK cycle counter for data-read window

-- CNVen_SCK: enables/disables generation of ADC_CLK from MCLK
signal CNVen_SCK     : std_logic ;

-- ADC_CLK: internal gated clock derived from MCLK, used as SCKL/SCKR
signal ADC_CLK       : std_logic ;

-- SDO_Read: window signal indicating that serial data should be captured (24 cycles)
signal SDO_Read      : std_logic ;

-- TCLK23: bit index counter, from 0 to 23 for the 24 serial bits
signal TCLK23        : integer range 0 to 23 ;

-- Internal 24-bit shift registers for each channel
signal r_DATAR	 	   : std_logic_vector(23 downto 0); -- Right channel internal data register
signal r_DATAL	 	   : std_logic_vector(23 downto 0); -- Left channel internal data register


begin

------------------------------------------------------------------
-- Generate CNV from CLKFS 
-- Both Left and Right CNV pulses come from the CLKFS square wave.
-- CNV pulse width must be ≥ 20 ns (low or high),
-- (see LTC2380-24 datasheet timing specs).
-- Here, CNV pulse width is 3 x MCLK period (~30 ns with 98.304 MHz MCLK).
------------------------------------------------------------------
process (MCLK) is
begin
	if rising_edge(MCLK) then
      -- 3-stage delay line to bring CLKFS into MCLK domain
      CLKFSd1 <= CLKFS  ; -- first delay stage
      CLKFSd2 <= CLKFSd1; -- second delay stage
      CLKFSd3 <= CLKFSd2; -- third delay stage

      -- Generate CNV pulse from rising edge of CLKFS:
      -- CNV is '1' when CLKFS = '1' and the delayed version is still '0'.
	    CNV <= CLKFS and not(CLKFSd3);
	end if;
end process;

-- Inverted CNV for both ADCs because CNV pins are active low.
-- CNV is further resynchronized to MCLK inside the AA2380V1 board.
nCNVL  <= not CNV ;
nCNVR  <= not CNV ;

------------------------------------------------------------------
-- Data read clock pulse generator (control of SDO_Read window)
--  - 24 is the number of read clock cycles per conversion.
--  - MCLK is the clock used to read data.
--
--  Operation:
--    * Detect when both ADC BUSY flags become low (conversion completed).
--    * Start the data-read window (SDO_Read) and prepare the SCK generation.
--    * SDO_Read is asserted for up to 24 MCLK cycles.
------------------------------------------------------------------
ADC_SDO_read : process (MCLK)
begin
  if rising_edge(MCLK) then   -- Entire process is synchronous to MCLK (rising edge)
      if (BUSYR='0' and BUSYL='0') then -- Both ADC BUSY flags must be low.
          -- -- Increment TCLK23 counter (bit index 0..23)
          -- if    TCLK23 < 23 then
          --       TCLK23 <= TCLK23 + 1 ;
          -- end if;

          -- MCLK cycle counter for ADC clock generation and data reading window
    			if    SDO_Read_cnt <= 24 then                  -- compare cycle counter value
                SDO_Read_cnt <= SDO_Read_cnt + 1 ;       -- increment clock cycle counter
    			end if;

          -- Data reading window:
          --   The data reading window starts 1 MCLK period before the
          --   SCK clock window so that data is stable when clock edges occur.
          if    SDO_Read_cnt < 24 then
                SDO_Read  <= '1' ; -- Enable data-reading window
          else
                SDO_Read  <= '0' ; -- Disable data-reading window
          end if;
      else
          -- If any ADC is busy again, reset counters and close the data window
          SDO_Read_cnt  <= 0   ; -- Reset data-read counter when BUSY is high
          SDO_Read      <= '0' ; -- Data-read window disabled when BUSY active
          -- TCLK23        <= 0   ; -- Reset TCLK23 bit counter when BUSY is high
      end if; 
  end if;
end process ADC_SDO_read;

-- Generate ADC read clock when CNVen_SCK is active.
-- ADC_CLK follows MCLK only when CNVen_SCK = '1'.
ADC_CLK   <= MCLK when CNVen_SCK='1' else '0' ;

------------------------------------------------------------------
-- ADC_clocks :
--   Generation of SCK (ADC serial clocks).
--
--   - Uses SDO_Read (data-read window) as the condition to start clocking.
--   - CNVclk_cnt counts MCLK cycles while SDO_Read is active.
--   - CNVen_SCK is asserted while CNVclk_cnt is between 0 and 24.
--   - SCK pulses (ADC_CLK) are therefore generated for 24 MCLK cycles.
--   - SCK pulses are delayed by 1 MCLK period compared to the SDO_Read window.
------------------------------------------------------------------
ADC_clocks : process (MCLK)
begin
  if rising_edge(MCLK) then   -- Entire process is synchronous to MCLK (falling edge)
      -- if  (BUSYR='0' and BUSYL='0')  then -- could use synchronized BUSY flags
      if (SDO_Read='1') then -- Start clocking only while data-read window is active
          -- MCLK cycle counter for ADC clock generation and data-reading window
    			if    CNVclk_cnt <= 24 then                  -- compare cycle counter value
                CNVclk_cnt <= CNVclk_cnt + 1 ;         -- increment clock cycle counter
    			end if;
          -- Increment TCLK23 counter (bit index 0..23)
          if    TCLK23 < 23 then
                TCLK23 <= TCLK23 + 1 ;
          end if;


          -- ADC SCK pulses clock window
          -- SCK pulses are delayed by 1 MCLK period compared to data-reading window.
          if    (CNVclk_cnt >= 0) and (CNVclk_cnt <= 24) then
                CNVen_SCK  <= '1' ; -- Enable window for clock
          else
                CNVen_SCK  <= '0' ; -- Disable window for clock
          end if;

      else
          -- When SDO_Read is not active, reset counter and disable clock window
          CNVclk_cnt <= 0   ; -- Reset counter
          CNVen_SCK  <= '0' ; -- Clock window disabled
          TCLK23        <= 0   ; -- Reset TCLK23 bit counter when BUSY is high
      end if;
  end if;
end process ADC_clocks;

-- Generate SCK for both ADCs (same clock for Left and Right channels)
SCKR <= ADC_CLK ; -- Right channel SCK
SCKL <= ADC_CLK ; -- Left  channel SCK

------------------------------------------------------------------
-- ADC Data reading Channel L+R
--   Serial data capture of both ADC channels.
--
--   - Process is synchronous to MCLK (rising edge).
--   - While SDO_Read = '1', for TCLK23 in [0..23], each MCLK rising edge:
--       * Shifts SDOL into r_DATAL.
--       * Shifts SDOR into r_DATAR.
--   - Variable 'idx' holds the "logical" bit index (23 - TCLK23), i.e. MSB->LSB.
--     It can be used for debugging or further processing if needed.
------------------------------------------------------------------
ADCserial_read : process(MCLK)
variable idx : integer range 0 to 23; 
begin
 if rising_edge(MCLK) then
    -- if SDO_Read = '1' then
    if (CNVen_SCK = '1') then  -- Data read only when SCK clock window is active
      -- Data reading only when SDO_Read window is active
      if  (TCLK23 >= 0) and (TCLK23 <= 23) then
          -- Compute logical bit index (MSB down to LSB)
          idx := 23 - TCLK23;

          -- Shift data into data registers at each MCLK rising edge
          -- during the data reading window.
          r_DATAL <= r_DATAL(22 downto 0) & SDOL; -- shift Left channel data
          r_DATAR <= r_DATAR(22 downto 0) & SDOR; -- shift Right channel data
      end if;
    end if;
 end if;
end process ADCserial_read;

------------------------------------------------------------------------------
-- Transfer data registers to DOUTL and DOUTR outputs at each rising edge
-- of CLKFS (effective output sample frequency).
--
--   - Asynchronous reset nRESET clears both outputs to 0.
--   - On each rising edge of CLKFS, the 24-bit shift registers r_DATAL
--     and r_DATAR are latched to the external outputs DOUTL and DOUTR.
------------------------------------------------------------------------------
process (CLKFS,nRESET)
begin
  if nRESET='0' then
        DOUTL <= x"000000"  ; -- Reset Left channel output data
        DOUTR <= x"000000"  ; -- Reset Right channel output data
  elsif rising_edge(CLKFS) then
    		DOUTL <= r_DATAL; -- Left channel data latch
    		DOUTR <= r_DATAR; -- Right channel data latch
	end if;
end process;

end Behavioral ;
