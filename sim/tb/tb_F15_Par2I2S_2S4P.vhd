LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity tb_F15_Par2I2S_2S4P is
end tb_F15_Par2I2S_2S4P;

architecture sim of tb_F15_Par2I2S_2S4P is

    component F15_Par2I2S_2S4P
        generic(
            DATAL_TST : std_logic_vector(23 downto 0) := x"B20EA7";
            DATAR_TST : std_logic_vector(23 downto 0) := x"9C9F4D"
        );
        port(
            MCLKI        : in  std_logic;
            CLK8FS       : in  std_logic;
            LRCK         : in  std_logic;
            DATAL        : in  std_logic_vector(23 downto 0);
            DATAR        : in  std_logic_vector(23 downto 0);
            TSTMODE      : in  std_logic;
            I2S4L_SDATAL : out std_logic_vector(3 downto 0);
            I2S4L_SDATAR : out std_logic_vector(3 downto 0);
            PARI2S_LOAD  : buffer std_logic
        );
    end component;

    -- Signals
    signal MCLKI_tb        : std_logic := '0';
    signal CLK8FS_tb       : std_logic := '0';
    signal LRCK_tb         : std_logic := '0';
    signal DATAL_tb        : std_logic_vector(23 downto 0) := (others => '0');
    signal DATAR_tb        : std_logic_vector(23 downto 0) := (others => '0');
    signal TSTMODE_tb      : std_logic := '0';
    signal I2S4L_SDATAL_tb : std_logic_vector(3 downto 0);
    signal I2S4L_SDATAR_tb : std_logic_vector(3 downto 0);
    signal PARI2S_LOAD_tb  : std_logic;





begin

    ----------------------------------------------------------------
    -- DUT instance
    ----------------------------------------------------------------
    DUT: F15_Par2I2S_2S4P
        port map(
            MCLKI        => MCLKI_tb,
            CLK8FS       => CLK8FS_tb,
            LRCK         => LRCK_tb,
            DATAL        => DATAL_tb,
            DATAR        => DATAR_tb,
            TSTMODE      => TSTMODE_tb,
            I2S4L_SDATAL => I2S4L_SDATAL_tb,
            I2S4L_SDATAR => I2S4L_SDATAR_tb,
            PARI2S_LOAD  => PARI2S_LOAD_tb
        );

    ----------------------------------------------------------------
    -- MCLKI generation
    ----------------------------------------------------------------
process
begin
    while true loop
        MCLKI_tb <= '1';
        wait for 5.086 ns;
        MCLKI_tb <= '0';
        wait for 5.086 ns;
    end loop;
end process;

process
    variable counter_clk8fs : integer := 0;
begin
    while true loop
        wait until rising_edge(MCLKI_tb);

        -- Compteurs pour les horloges dérivées
        counter_clk8fs := counter_clk8fs + 1;
        if counter_clk8fs = 4 then
            CLK8FS_tb <= not CLK8FS_tb;
            counter_clk8fs := 0;
        end if;
    end loop;
end process;

process
    variable counter_lrck   : integer := 0;
    begin
  while true  loop
        wait until rising_edge(CLK8FS_tb);

        -- Compteu1
        counter_lrck := counter_lrck + 1;
        if counter_lrck = 4 then
            LRCK_tb <= not LRCK_tb;
            counter_lrck := 0;
        end if;
    end loop;
end process;

    ----------------------------------------------------------------
    -- Stimulus process
    ----------------------------------------------------------------
    stim_proc: process  
    begin
        wait for 1 us;

        -- Normal mode
        TSTMODE_tb <= '0';
        for i in 0 to 5 loop
            DATAL_tb <= std_logic_vector(to_signed(1000*i,24));
            DATAR_tb <= std_logic_vector(to_signed(2000*i,24));
            wait for 10 us;
        end loop;

        -- Test mode
        TSTMODE_tb <= '1';
        wait for 20 us;

        -- Back to normal
        TSTMODE_tb <= '0';
        DATAL_tb <= x"123456";
        DATAR_tb <= x"ABCDEF";
        wait for 20 us;

        wait;
    end process;

end architecture sim;
