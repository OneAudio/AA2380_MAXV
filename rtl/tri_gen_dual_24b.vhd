library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tri_gen_dual_24b is
    generic (
        -- Incrément entre deux fronts montants de LRCK, en LSB (24 bits signés)
        g_step    : integer := 1111;
        -- Amplitude crête max, en LSB (valeur positive, crête + et - sont symétriques)
        g_amp_max : integer := 2**22      -- par défaut ≈ 1/2 pleine échelle
    );
    port (
        MCLK   : in  std_logic;                      -- 98.304 MHz
        LRCK   : in  std_logic;                      -- 12 kHz à 1.536 MHz, synchrone de MCLK
        DATAOL : out std_logic_vector(23 downto 0);  -- triangle gauche (90° décalé)
        DATAOR : out std_logic_vector(23 downto 0)   -- triangle droite (référence)
    );
end entity;

architecture rtl of tri_gen_dual_24b is

    ------------------------------------------------------------------------
    -- Constantes calculées à l'élaboration (pas de HW pour ça)
    ------------------------------------------------------------------------
    constant C_SIGNED_WIDTH : integer := 24;

    -- Nombre de pas pour aller de -Amax à +Amax (demi-période)
    constant C_N_HALF  : integer := (2 * g_amp_max) / g_step;

    -- 90° de phase = quart de période = demi de C_N_HALF
    constant C_K_90    : integer := C_N_HALF / 2;

    -- Valeurs initiales (en entier) des triangles
    constant C_TRI_R_INIT_INT : integer := -g_amp_max;
    constant C_TRI_L_INIT_INT : integer := -g_amp_max + (g_step * C_K_90);

    -- Conversion en signed(23 downto 0)
    constant C_TRI_R_INIT : signed(C_SIGNED_WIDTH-1 downto 0) :=
        to_signed(C_TRI_R_INIT_INT, C_SIGNED_WIDTH);

    constant C_TRI_L_INIT : signed(C_SIGNED_WIDTH-1 downto 0) :=
        to_signed(C_TRI_L_INIT_INT, C_SIGNED_WIDTH);

    -- Limites en signed
    constant C_AMP_MAX : signed(C_SIGNED_WIDTH-1 downto 0) :=
        to_signed(g_amp_max, C_SIGNED_WIDTH);
    constant C_AMP_MIN : signed(C_SIGNED_WIDTH-1 downto 0) :=
        to_signed(-g_amp_max, C_SIGNED_WIDTH);

    -- Optionnel : quelques assertions de cohérence (non synthétisées)
    -- Vérifier que 2*g_amp_max est multiple de g_step
    -- et que C_N_HALF est pair (pour le /2) si tu veux du 90° exact.
    -- (Quartus les ignorera en synthèse, mais utiles en simu.)
    --
    -- assert ((2 * g_amp_max) mod g_step = 0)
    --   report "tri_gen_dual_24b: 2*g_amp_max must be a multiple of g_step"
    --   severity warning;
    --
    -- assert (C_N_HALF mod 2 = 0)
    --   report "tri_gen_dual_24b: (2*g_amp_max/g_step) must be even for exact 90°"
    --   severity warning;

    ------------------------------------------------------------------------
    -- Signaux internes
    ------------------------------------------------------------------------
    -- Synchronisation de LRCK sur MCLK
    signal lrck_ff1, lrck_ff2 : std_logic := '0';
    signal lrck_prev          : std_logic := '0';
    signal lrck_rise          : std_logic;

    -- Triangles internes, 24 bits signés
    signal tri_r : signed(C_SIGNED_WIDTH-1 downto 0) := C_TRI_R_INIT; -- droite (référence)
    signal tri_l : signed(C_SIGNED_WIDTH-1 downto 0) := C_TRI_L_INIT; -- gauche (90° décalé)

    -- Direction: '1' = montée, '0' = descente
    signal dir_r : std_logic := '1';
    signal dir_l : std_logic := '1';

    -- Incrément en signed
    constant C_STEP : signed(C_SIGNED_WIDTH-1 downto 0) :=
        to_signed(g_step, C_SIGNED_WIDTH);

begin

    ------------------------------------------------------------------------
    -- Synchronisation de LRCK dans le domaine MCLK + détection de front montant
    ------------------------------------------------------------------------
    sync_lrck : process(MCLK)
    begin
        if rising_edge(MCLK) then
            lrck_ff1  <= LRCK;
            lrck_ff2  <= lrck_ff1;
            lrck_prev <= lrck_ff2;
        end if;
    end process;

    lrck_rise <= '1' when (lrck_ff2 = '1' and lrck_prev = '0') else '0';

    ------------------------------------------------------------------------
    -- Génération des triangles, mise à jour à chaque front montant de LRCK
    ------------------------------------------------------------------------
    tri_proc : process(MCLK)
    begin
        if rising_edge(MCLK) then

            if lrck_rise = '1' then

                -- ==========================
                -- Canal droit : triangle de référence
                -- ==========================
                if dir_r = '1' then  -- montée
                    if (tri_r + C_STEP) >= C_AMP_MAX then
                        tri_r <= C_AMP_MAX;
                        dir_r <= '0';  -- on bascule en descente
                    else
                        tri_r <= tri_r + C_STEP;
                    end if;
                else                 -- descente
                    if (tri_r - C_STEP) <= C_AMP_MIN then
                        tri_r <= C_AMP_MIN;
                        dir_r <= '1';  -- on bascule en montée
                    else
                        tri_r <= tri_r - C_STEP;
                    end if;
                end if;

                -- ==========================
                -- Canal gauche : même logique, mais état initial différent => 90°
                -- ==========================
                if dir_l = '1' then  -- montée
                    if (tri_l + C_STEP) >= C_AMP_MAX then
                        tri_l <= C_AMP_MAX;
                        dir_l <= '0';
                    else
                        tri_l <= tri_l + C_STEP;
                    end if;
                else                 -- descente
                    if (tri_l - C_STEP) <= C_AMP_MIN then
                        tri_l <= C_AMP_MIN;
                        dir_l <= '1';
                    else
                        tri_l <= tri_l - C_STEP;
                    end if;
                end if;

            end if;  -- lrck_rise

        end if;  -- rising_edge(MCLK)
    end process;

    ------------------------------------------------------------------------
    -- Sorties
    ------------------------------------------------------------------------
    DATAOR <= std_logic_vector(tri_r);
    DATAOL <= std_logic_vector(tri_l);

end architecture;
