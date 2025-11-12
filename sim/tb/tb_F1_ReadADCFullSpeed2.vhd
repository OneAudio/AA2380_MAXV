-- tb_F1_ReadADCFullSpeed.vhd (version à motifs alternés HEX)
-- ModelSim 2020.1 — Pour MAX V + LTC2380-24

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_F1_ReadADCFullSpeed2 is
  generic (
    G_MCLK_HZ   : integer := 98_304_000;
    G_CLKFS_HZ  : integer := 1_536_000;
    G_BITS      : integer := 24;
    G_TBUSY_NS  : time    := 13 ns;
    G_TCONV_NS  : time    := 392 ns;

    -- >>> motifs alternés sur chaque voie (définissables dans vsim -g)
    G_L_VAL_A   : std_logic_vector(23 downto 0) := x"7A_BCDE";
    G_L_VAL_B   : std_logic_vector(23 downto 0) := x"85_4321";
    G_R_VAL_A   : std_logic_vector(23 downto 0) := x"12_3456";
    G_R_VAL_B   : std_logic_vector(23 downto 0) := x"ED_CBA9"
  );
end entity;

architecture tb of tb_F1_ReadADCFullSpeed2   is
  constant C_T_MCLK  : time := 1 sec / real(G_MCLK_HZ);
  constant C_T_CLKFS : time := 1 sec / real(G_CLKFS_HZ);

  -- DUT I/O
  signal MCLK   : std_logic := '0';
  signal CLKFS  : std_logic := '0';
  signal RESETn : std_logic := '0';

  signal SCKL, SCKR : std_logic;
  signal nCNVL, nCNVR : std_logic;
  signal BUSYL, BUSYR : std_logic := '0';
  signal SDOL,  SDOR  : std_logic := '0';

  signal DOUTL, DOUTR : std_logic_vector(G_BITS-1 downto 0);

  -- internes TB
  signal l_sample_hold, r_sample_hold : signed(G_BITS-1 downto 0) := (others => '0');
  signal l_shift, r_shift : std_logic_vector(G_BITS-1 downto 0) := (others => '0');

begin
  ------------------------------------------------------------------------------
  -- Instance du DUT
  ------------------------------------------------------------------------------
  dut: entity work.F1_ReadADCFullSpeed
    port map (
      MCLK   => MCLK,
      CLKFS  => CLKFS,
      nRESET => RESETn,

      SDOL   => SDOL,
      BUSYL  => BUSYL,
      SCKL   => SCKL,
      nCNVL  => nCNVL,

      SDOR   => SDOR,
      BUSYR  => BUSYR,
      SCKR   => SCKR,
      nCNVR  => nCNVR,

      DOUTL  => DOUTL,
      DOUTR  => DOUTR
    );

  ------------------------------------------------------------------------------
  -- Clocks & reset
  ------------------------------------------------------------------------------
  MCLK_gen : process
  begin
    MCLK <= '0'; wait for C_T_MCLK/2;
    MCLK <= '1'; wait for C_T_MCLK/2;
  end process;

  CLKFS_gen : process
  begin
    CLKFS <= '0'; wait for C_T_CLKFS/2;
    CLKFS <= '1'; wait for C_T_CLKFS/2;
  end process;

  rst_proc : process
  begin
    RESETn <= '0';
    wait for 1 us;
    RESETn <= '1';
    wait;
  end process;

  ------------------------------------------------------------------------------
  -- Alternance A/B sur chaque voie à chaque CNV↓
  ------------------------------------------------------------------------------
  adc_pattern_select : process
    variable toggle : boolean := false;
  begin
    wait until falling_edge(nCNVL) or falling_edge(nCNVR);
    toggle := not toggle;

    if toggle then
      l_sample_hold <= signed(G_L_VAL_A);
      r_sample_hold <= signed(G_R_VAL_A);
    else
      l_sample_hold <= signed(G_L_VAL_B);
      r_sample_hold <= signed(G_R_VAL_B);
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Modèle BUSY (CNV actif bas)
  ------------------------------------------------------------------------------
  adc_busy_L : process
  begin
    wait until falling_edge(nCNVL);
    BUSYL <= '0';
    wait for G_TBUSY_NS;
    BUSYL <= '1';
    wait for G_TCONV_NS;
    BUSYL <= '0';
  end process;

  adc_busy_R : process
  begin
    wait until falling_edge(nCNVR);
    BUSYR <= '0';
    wait for G_TBUSY_NS;
    BUSYR <= '1';
    wait for G_TCONV_NS;
    BUSYR <= '0';
  end process;

  ------------------------------------------------------------------------------
  -- SDO série : MSB-first, actualisé sur SCK↓
  ------------------------------------------------------------------------------
  adc_serial_L : process
    variable v_shift : std_logic_vector(G_BITS-1 downto 0);
  begin
    wait until falling_edge(BUSYL);
    v_shift := std_logic_vector(l_sample_hold);
    SDOL    <= v_shift(G_BITS-1);
    report "[L] load " & integer'image(to_integer(l_sample_hold)) severity note;

    for i in 1 to G_BITS-1 loop
      wait until rising_edge(SCKL);
      v_shift := v_shift(G_BITS-2 downto 0) & '0';
      SDOL    <= v_shift(G_BITS-1);
    end loop;
  end process;

  adc_serial_R : process
    variable v_shift : std_logic_vector(G_BITS-1 downto 0);
  begin
    wait until falling_edge(BUSYR);
    v_shift := std_logic_vector(r_sample_hold);
    SDOR    <= v_shift(G_BITS-1);
    report "[R] load " & integer'image(to_integer(r_sample_hold)) severity note;

    for i in 1 to G_BITS-1 loop
      wait until rising_edge(SCKR);
      v_shift := v_shift(G_BITS-2 downto 0) & '0';
      SDOR    <= v_shift(G_BITS-1);
    end loop;
  end process;

  ------------------------------------------------------------------------------
  -- Moniteur de sortie (optionnel)
  ------------------------------------------------------------------------------
--   monitor : process(CLKFS)
--   begin
--     if rising_edge(CLKFS) then
--       report "DOUTL=" & integer'image(to_integer(signed(DOUTL))) &
--              "  DOUTR=" & integer'image(to_integer(signed(DOUTR))) severity note;
--     end if;
--   end process;

--   -- Fin de simulation
--   sim_end : process
--   begin
--     wait for 5 ms;
--     report "Simulation finished." severity failure;
--   end process;

end architecture;
