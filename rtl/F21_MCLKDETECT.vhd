-- ============================================================================
--  Fichier      : F21_MCLKDETECT.vhd
--  Auteur       : ChatGPT (OpenAI)
--  Description  : Détecteur de présence d'une horloge MCLK à l'aide d'une
--                 horloge de référence lente (REFCLK ~4.7 MHz).
--
--  Synthétisable (VHDL-1998) - Compatible Quartus Prime
--
--  Principe :
--  -----------
--   • Dans le domaine MCLK (~100 MHz), un petit compteur (6 bits) s’incrémente
--     à chaque front montant.
--   • Ce compteur est échantillonné dans le domaine REFCLK (~4.7 MHz)
--     via une double synchronisation (anti-métastabilité).
--   • Si la valeur synchronisée change entre deux échantillons, cela signifie
--     que MCLK a tourné → MCK_RDY = '1'.
--   • Si aucune variation n’est détectée pendant un certain nombre de cycles
--     REFCLK (TIMEOUT_MAX), alors MCK_RDY repasse à '0'.
--
--  Avantages :
--   - Très fiable, même avec REFCLK << MCLK
--   - Peu de logique (quelques bascules)
--   - Aucun reset nécessaire
--
-- Take 72 LE - compiled ok 10/2025
--
-- ============================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity F21_MCLKDETECT is
  generic (
    W           : integer := 6;      -- largeur du compteur MCLK (2^6 = 64 > 100/4.7 ≈ 21)
    TIMEOUT_MAX : integer := 470     -- délai avant MCK_RDY='0' (470 cycles ≈ 100 µs à 4.7 MHz)
  );
  port (
    REFCLK  : in  std_logic;   -- horloge de référence stable (~4.7 MHz)
    MCLK    : in  std_logic;   -- horloge à tester (~100 MHz)
    MCK_RDY : out std_logic    -- '1' si MCLK détectée
  );
end entity;

architecture rtl of F21_MCLKDETECT is

  -- Petit compteur dans le domaine MCLK
  signal mcnt : unsigned(W-1 downto 0) := (others => '0');

  -- Synchronisation double dans le domaine REFCLK
  signal s0, s1, prev : std_logic_vector(W-1 downto 0) := (others => '0');

  -- Délai avant détection de perte
  signal timeout_cnt : integer := 0;

  -- Sortie interne
  signal mck_rdy_reg : std_logic := '0';

begin

  ----------------------------------------------------------------------------
  -- Domaine MCLK : incrémentation du compteur à chaque front montant.
  -- Ce compteur évolue continuellement tant que MCLK est présente.
  ----------------------------------------------------------------------------
  process(MCLK)
  begin
    if rising_edge(MCLK) then
      mcnt <= mcnt + 1;
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- Domaine REFCLK :
  --  - Synchronise les bits du compteur MCLK pour éviter la métastabilité.
  --  - Compare la valeur échantillonnée à la précédente.
  --  - Si elle change : MCLK actif → MCK_RDY = '1' et timeout remis à 0.
  --  - Si elle ne change pas : incrémente le compteur de timeout.
  --    Quand le délai atteint TIMEOUT_MAX → MCK_RDY = '0'.
  ----------------------------------------------------------------------------
  process(REFCLK)
  begin
    if rising_edge(REFCLK) then

      -- Double synchronisation bit à bit
      for i in 0 to W-1 loop
        s0(i) <= std_logic(mcnt(i));
        s1(i) <= s0(i);
      end loop;

      -- Détection de changement de valeur
      if s1 /= prev then
        prev         <= s1;          -- mémoriser la nouvelle valeur
        timeout_cnt  <= 0;           -- reset du compteur de délai
        mck_rdy_reg  <= '1';         -- MCLK présente
      else
        -- pas de changement observé → incrémenter le compteur
        if timeout_cnt < TIMEOUT_MAX then
          timeout_cnt <= timeout_cnt + 1;
        else
          mck_rdy_reg <= '0';        -- MCLK considérée absente
        end if;
      end if;
    end if;
  end process;

  -- Sortie
  MCK_RDY <= mck_rdy_reg;

end architecture rtl;
