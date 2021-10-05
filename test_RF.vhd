library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF_tb is

end RF_tb;

architecture tb of RF_tb is
    component RF is
        generic (M : INTEGER;
                 N : INTEGER);
        port (WD        : in STD_LOGIC_VECTOR(N - 1 downto 0);
              WAddr     : in STD_LOGIC_VECTOR(M - 1 downto 0);
              Write     : in STD_LOGIC;
              RA        : in STD_LOGIC_VECTOR(M - 1 downto 0);
              ReadA     : in STD_LOGIC;
              RB        : in STD_LOGIC_VECTOR(M - 1 downto 0);
              ReadB     : in STD_LOGIC;
              QA        : out STD_LOGIC_VECTOR(N - 1 downto 0);
              QB        : out STD_LOGIC_VECTOR(N - 1 downto 0);
              rst       : in STD_LOGIC;
              clk       : in STD_ULOGIC);
    end component;

    constant c_M        : INTEGER := 3;
    constant c_N        : INTEGER := 3;
    signal clk          : STD_ULOGIC := '0';
    signal rst          : STD_LOGIC;
    signal tt_WD        : STD_LOGIC_VECTOR(c_N - 1 downto 0);
    signal tt_WAddr     : STD_LOGIC_VECTOR(c_M - 1 downto 0);
    signal tt_Write     : STD_LOGIC;
    signal tt_RA        : STD_LOGIC_VECTOR(c_M - 1 downto 0);
    signal tt_ReadA     : STD_LOGIC;
    signal tt_RB        : STD_LOGIC_VECTOR(c_N - 1 downto 0);
    signal tt_ReadB     : STD_LOGIC;
    signal tt_QA        : STD_LOGIC_VECTOR(c_N - 1 downto 0);
    signal tt_QB        : STD_LOGIC_VECTOR(c_N - 1 downto 0);
    --shared variable sv_expected : STD_LOGIC_VECTOR(2 downto 0) := (others => '0'); -- they should be protected to be encapsulated
    shared variable sv_expected_A : STD_LOGIC_VECTOR(c_N downto 0);
    shared variable sv_expected_B : STD_LOGIC_VECTOR(c_N downto 0);
begin
    DUT_RF : RF map generic(M => c_M,
                            N => c_N);
                map port(WD => tt_WD,
                         WAddr => tt_WAddr,
                         Write => tt_Write,
                         RA => tt_RA,
                         ReadA => tt_ReadA,
                         RB => tt_RB,
                         ReadB => tt_ReadB,
                         QA => tt_QA,
                         QB => tt_QB,
                         rst => rst,
                         clk => clk);

    clk <= not clk after 5 ns;

    monitor : process (tt_QA, tt_QB)
    begin
        if tt_QA /= sv_expected_A then
            assert false
            report "Wrong data on QA = " & integer'image(to_integer(unsigned(tt_QA))) & " expected = " & integer'image(to_integer(unsigned(sv_expected_A))) -- signed?
            severity error;
        end if;
        if tt_QB /= sv_expected_B then
            assert false
            report "Wrong data on QB = " & integer'image(to_integer(unsigned(tt_QB))) & " expected = " & integer'image(to_integer(unsigned(sv_expected_B))) -- signed?
            severity error;
        end if;
    end process monitor;

    generator : process
    begin
    -- reset
    rst <= '1';
    wait for 10 ns;

    -- load the RF with data
    for i in 2**(c_M - 1) loop
        tt_WD <= std_logic_vector(unsigned(i));
        tt_WAddr <= std_logic_vector(unsigned(i - 1));
        tt_Write <= '1';
        wait for 10 ns;
    end loop;

    -- check if the data is loaded
    for i in 2**(c_M - 1) / 2 loop
        tt_RA <= std_logic_vector(unsigned(i * 2));
        tt_ReadA <= '1';
        sv_expected_A <= std_logic_vector(unsigned(i * 2 - 1));

        tt_RB <= std_logic_vector(unsigned(i * 2 + 1));
        tt_ReadB <= '1';
        sv_expected_B <= std_logic_vector(unsigned(i * 2));

        wait for 10 ns;
    end loop;

    -- check if reading a 0 outputs 0s
    tt_ReadA <= '0'
    sv_expected_A <= std_logic_vector(0);
    tt_ReadB <= '0'
    sv_expected_B <= std_logic_vector(0);
    wait for 10 ns;

    end process generator;
end tb;
