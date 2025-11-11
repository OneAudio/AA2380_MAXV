-- tb_F1_ReadADCFullSpeed.vhd (corrigé)
-- ModelSim 2020.1

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_F1_ReadADCFullSpeed is
  generic (
    G_MCLK_HZ   : integer := 98_304_000;  -- 98.304 MHz
    G_CLKFS_HZ  : integer := 192_000;     -- 12k .. 1_536k
    G_AMPL_PCT  : real    := 90.0;        -- amplitude en % pleine échelle
    G_BITS      : integer := 24;          -- résolution ADC
    G_TBUSY_NS  : time    := 13 ns;       -- délai CNV↓ -> BUSY↑
    G_TCONV_NS  : time    := 392 ns;      -- durée conversion (BUSY haut)
    -- Pour la sinusoïde/cos : 1 période sur N échantillons
    G_SIG_PERIOD_SAMPLES : integer := 1024
  );
end entity;

architecture tb of tb_F1_ReadADCFullSpeed is
  constant C_T_MCLK  : time := 1 sec / real(G_MCLK_HZ);
  constant C_T_CLKFS : time := 1 sec / real(G_CLKFS_HZ);
  constant G_FS      : integer := 2**(G_BITS-1) - 1;

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
  signal SCKL_d, SCKR_d : std_logic := '0';

  signal sample_idx : integer := 0;  -- avance d’un cran à chaque conversion

  signal l_sample_hold, r_sample_hold : signed(G_BITS-1 downto 0) := (others => '0');
  signal l_shift, r_shift : std_logic_vector(G_BITS-1 downto 0) := (others => '0');

  -- helper
  function real_to_signed(val : real; width : positive) return signed is
  begin
    return to_signed(integer(val), width);
  end function;

begin
  ------------------------------------------------------------------------------
  -- Instance du DUT (adapte juste le mapping si tes noms diffèrent)
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

  -- détecteurs de fronts SCK (échantillonnage côté TB)
  sck_ed : process(MCLK)
  begin
    if rising_edge(MCLK) then
      SCKL_d <= SCKL;
      SCKR_d <= SCKR;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Génération des valeurs SIN/COS à chaque début de conversion (CNV actif bas)
  ------------------------------------------------------------------------------
  adc_math : process
    variable amp     : real := real(G_FS) * (G_AMPL_PCT / 100.0);
    variable theta   : real;
    variable idx_mod : integer;
  begin
    wait until falling_edge(nCNVL) or falling_edge(nCNVR);  -- **FIX** actif bas
    sample_idx <= sample_idx + 1;
    idx_mod := sample_idx mod G_SIG_PERIOD_SAMPLES;
    theta   := 2.0 * math_pi * real(idx_mod) / real(G_SIG_PERIOD_SAMPLES);

    l_sample_hold <= real_to_signed( amp * sin(theta), G_BITS); -- L = sin
    r_sample_hold <= real_to_signed( amp * cos(theta), G_BITS); -- R = cos
  end process;

  ------------------------------------------------------------------------------
  -- Modèle BUSY (CNV actif bas)
  ------------------------------------------------------------------------------
  adc_busy_L : process
  begin
    wait until falling_edge(nCNVL);  -- **FIX**
    BUSYL <= '0';
    wait for G_TBUSY_NS;
    BUSYL <= '1';
    wait for G_TCONV_NS;
    BUSYL <= '0';
  end process;

  adc_busy_R : process
  begin
    wait until falling_edge(nCNVR);  -- **FIX**
    BUSYR <= '0';
    wait for G_TBUSY_NS;
    BUSYR <= '1';
    wait for G_TCONV_NS;
    BUSYR <= '0';
  end process;

  ------------------------------------------------------------------------------
  -- Sortie série SDO (MSB-first), validée sur SCK↓ pour que le DUT lise sur SCK↑
  ------------------------------------------------------------------------------
--- ==== CANAL L ==========================================================
adc_serial_L : process
  variable v_shift : std_logic_vector(G_BITS-1 downto 0);
begin
  -- Attendre fin de conversion (données prêtes)
  wait until falling_edge(BUSYL);

  -- Charger le mot et PRÉ-POSER le MSB immédiatement
  v_shift := std_logic_vector(l_sample_hold);
  SDOL    <= v_shift(G_BITS-1);
  report "[L] load " & integer'image(to_integer(l_sample_hold)) severity note;

  -- Puis sortir les bits restants sur chaque SCK↓ (MSB-first)
  for i in 1 to G_BITS-1 loop
    wait until falling_edge(SCKL);
    -- Décaler d'un cran et émettre le nouveau MSB
    v_shift := v_shift(G_BITS-2 downto 0) & '0';
    SDOL    <= v_shift(G_BITS-1);
  end loop;
end process;

-- ==== CANAL R ==========================================================
adc_serial_R : process
  variable v_shift : std_logic_vector(G_BITS-1 downto 0);
begin
  wait until falling_edge(BUSYR);

  v_shift := std_logic_vector(r_sample_hold);
  SDOR    <= v_shift(G_BITS-1);
  report "[R] load " & integer'image(to_integer(r_sample_hold)) severity note;

  for i in 1 to G_BITS-1 loop
    wait until falling_edge(SCKR);
    v_shift := v_shift(G_BITS-2 downto 0) & '0';
    SDOR    <= v_shift(G_BITS-1);
  end loop;
end process;


  ------------------------------------------------------------------------------
  -- Moniteur (optionnel) des bus parallèles sortis par le DUT
  ------------------------------------------------------------------------------
  monitor : process(CLKFS)
  begin
    if rising_edge(CLKFS) then
      report "DOUTL=" & integer'image(to_integer(signed(DOUTL))) &
             "  DOUTR=" & integer'image(to_integer(signed(DOUTR))) severity note;
    end if;
  end process;

  -- Fin de simulation
  sim_end : process
  begin
    wait for 5 ms;
    report "Simulation finished." severity failure;
  end process;

end architecture;
