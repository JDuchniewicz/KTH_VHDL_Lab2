library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_tb is

end ALU_tb;

architecture tb of ALU_tb is
    component ALU is
        generic (N : INTEGER := 4); -- default value??
        port (OP		: in STD_LOGIC_VECTOR(2 downto 0);
                A		: in STD_LOGIC_VECTOR(N - 1 downto 0);
                B		: in STD_LOGIC_VECTOR(N - 1 downto 0);
                Sum	: out STD_LOGIC_VECTOR(N - 1 downto 0);
                Z_Flag: out STD_LOGIC;
                N_Flag: out STD_LOGIC;
                O_Flag: out STD_LOGIC;
                clk     : in STD_ULOGIC;
                en      : IN STD_LOGIC;
                rst     : IN STD_LOGIC);
    end component;

    signal clk          : STD_ULOGIC := '0';
    signal t_OP         : STD_LOGIC_VECTOR(2 downto 0);
    signal t_A          : STD_LOGIC_VECTOR(2 downto 0);
    signal t_B          : STD_LOGIC_VECTOR(2 downto 0);
    signal t_Sum        : STD_LOGIC_VECTOR(2 downto 0);
    signal t_Z_Flag     : STD_LOGIC;
    signal t_N_Flag     : STD_LOGIC;
    signal t_O_Flag     : STD_LOGIC;
    signal t_en         : STD_LOGIC;
    signal t_rst        : STD_LOGIC;
    shared variable sv_expected : STD_LOGIC_VECTOR(2 downto 0);
    shared variable sv_z_expected : STD_LOGIC;
    shared variable sv_n_expected : STD_LOGIC;
    shared variable sv_o_expected : STD_LOGIC;
    --signal tt_rtl_result: STD_LOGIC_VECTOR(1 downto 0); should this be tested as well?

begin
    DUT_ALU : ALU   generic map (N => 3)
                    port map (OP => t_OP,
                              A => t_A,
                              B => t_B,
                              Sum => t_Sum,
                              Z_Flag => t_Z_Flag,
                              N_Flag => t_N_Flag,
                              O_Flag => t_O_Flag,
                              clk => clk,
                              en => t_en,
                              rst => t_rst);

    clk <= not clk after 5 ns;
    monitor : process (t_Sum)
    begin
        if t_Sum /= sv_expected then
            assert false
            report "Sum is NOT correct = " & integer'image(to_integer(unsigned(t_Sum))) & " should be " & integer'image(to_integer(unsigned(sv_expected)))
            severity error;
        end if;
        if t_Z_Flag /= sv_z_expected then
            assert false
            report "Z_Flag is NOT correct = " & std_logic'image(t_Z_Flag) & " should be " & std_logic'image(sv_z_expected)
            severity error;
        end if;
        if t_N_Flag /= sv_n_expected then
            assert false
            report "N_Flag is NOT correct = " & std_logic'image(t_N_Flag) & " should be " & std_logic'image(sv_n_expected)
            severity error;
        end if;
        if t_O_Flag /= sv_o_expected then
            assert false
            report "O_Flag is NOT correct = " & std_logic'image(t_O_Flag) & " should be " & std_logic'image(sv_o_expected)
            severity error;
        end if;
    end process monitor;

    generator : process
    begin
        wait for 10 ns;
        --for i in
        -- OP_ADD
        t_OP <= "000";
        t_A <= (others => '0');
        t_B <= (others => '0'); -- test for Z_Flag
        wait for 10 ns;
        assert t_Z_Flag = '1'
            report "Error OP_ADD Z_Flag test. Sum = " & integer'image(to_integer(unsigned(t_Sum)))
            severity error;

        t_A <= "011"; -- test overflow of 2's complement
        t_B <= "001";
        wait for 10 ns;
        assert t_O_Flag = '1'
            report "Error OP_ADD O_Flag test. Sum = " & integer'image(to_integer(unsigned(t_Sum)))
            severity error;

        -- OP_SUB
        t_OP <= "001";
        t_A <= "001"; -- test negative
        t_B <= "010";
        wait for 10 ns;
        assert t_N_Flag = '1'
            report "Error OP_SUB N_Flag test. Sum = " & integer'image(to_integer(unsigned(t_Sum)))
            severity error;

        -- OP_AND
        t_OP <= "010";
        t_A <= "111";
        t_B <= "000";
        wait for 10 ns;
        assert t_Z_Flag = '1'
            report "Error OP_AND Z_Flag test. Sum = " & integer'image(to_integer(unsigned(t_Sum)))
            severity error;

        -- OP_OR
        t_OP <= "011";
        t_A <= "111";
        t_B <= "000";
        wait for 10 ns;
        assert t_Z_Flag = '0'
            report "Error OP_OR Z_Flag test. Sum = " & integer'image(to_integer(unsigned(t_Sum)))
            severity error;

        -- OP_XOR
        t_OP <= "100";
        t_A <= "101";
        t_B <= "000";
        wait for 10 ns;
        assert t_Z_Flag = '0'
            report "Error OP_XOR Z_Flag test. Sum = " & integer'image(to_integer(unsigned(t_Sum)))
            severity error;

        -- OP_NOT
        t_OP <= "101";
        t_A <= "101";
        wait for 10 ns;
        assert t_Sum = "010"
            report "Error OP_NOT test. Sum = " & integer'image(to_integer(unsigned(t_Sum)))
            severity error;


        -- OP_MOV
        t_OP <= "110";
        t_A <= "100";
        wait for 10 ns;
        assert t_Sum = "100"
            report "Error OP_MOV test. Sum = " & integer'image(to_integer(unsigned(t_Sum)))
            severity error;


        -- OP_Zero
        t_OP <= "111";
        wait for 10 ns;
        assert t_Z_Flag = '1' and t_Sum = "000"
            report "Error OP_Zero Z_Flag test. Sum = " & integer'image(to_integer(unsigned(t_Sum)))
            severity error;


    end process;
end tb;
