library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_tri_gen_dual_24b is
end entity;

architecture tb of tb_tri_gen_dual_24b is

    --------------------------------------------------------------------
    -- Constantes de simulation
    --------------------------------------------------------------------
    -- Période de MCLK pour 98.304 MHz
    constant C_MCLK_PERIOD : time := 10.16 ns;

    -- Division pour générer LRCK à partir de MCLK :
    -- f_lrck = f_mclk / (2 * C_DIV_LRCK)
    -- avec f_mclk = 98.304 MHz et C_DIV_LRCK = 1024 => f_lrck = 48 kHz
    constant C_DIV_LRCK : natural := 1024;

    -- Génériques de l'UUT (à adapter à tes besoins)
    -- Ici on prend des valeurs cohérentes pour le 90°:
    -- g_step = 2^16, g_amp_max = 2^21 => (2*g_amp_max)/g_step = 64 (pair)
    constant C_STEP    : integer := 2**16;
    constant C_AMP_MAX : integer := 2**21;

    --------------------------------------------------------------------
    -- Signaux reliés à l'UUT
    --------------------------------------------------------------------
    signal MCLK   : std_logic := '0';
    signal LRCK   : std_logic := '0';
    signal DATAOL : std_logic_vector(23 downto 0);
    signal DATAOR : std_logic_vector(23 downto 0);

    -- Pour la génération de LRCK
    signal lrck_cnt : natural range 0 to C_DIV_LRCK-1 := 0;

begin

    --------------------------------------------------------------------
    -- Instanciation de l'UUT (Unit Under Test)
    --------------------------------------------------------------------
    uut : entity work.tri_gen_dual_24b
        generic map (
            g_step    => C_STEP,
            g_amp_max => C_AMP_MAX
        )
        port map (
            MCLK   => MCLK,
            LRCK   => LRCK,
            DATAOL => DATAOL,
            DATAOR => DATAOR
        );

    --------------------------------------------------------------------
    -- Génération de MCLK (98.304 MHz)
    --------------------------------------------------------------------
    clk_gen : process
    begin
        MCLK <= '0';
        wait for C_MCLK_PERIOD / 2;
        MCLK <= '1';
        wait for C_MCLK_PERIOD / 2;
    end process;

    --------------------------------------------------------------------
    -- Génération de LRCK à partir de MCLK (48 kHz ici)
    --------------------------------------------------------------------
    lrck_gen : process(MCLK)
    begin
        if rising_edge(MCLK) then
            if lrck_cnt = C_DIV_LRCK-1 then
                lrck_cnt <= 0;
                LRCK     <= not LRCK;
            else
                lrck_cnt <= lrck_cnt + 1;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Process de stimulation / fin de simulation
    --------------------------------------------------------------------
    stim_proc : process
    begin
        -- Laisser tourner la simulation un certain temps
        -- 10 ms -> ~480 périodes de LRCK à 48 kHz
        wait for 10 ms;

        -- Fin de simu
        assert false report "Fin de simulation" severity failure;
    end process;

end architecture;
