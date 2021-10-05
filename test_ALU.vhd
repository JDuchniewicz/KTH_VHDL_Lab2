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
    signal tt_OP         : STD_LOGIC_VECTOR(2 downto 0);
    signal tt_A          : STD_LOGIC_VECTOR(2 downto 0);
    signal tt_B          : STD_LOGIC_VECTOR(2 downto 0);
    signal tt_Sum        : STD_LOGIC_VECTOR(2 downto 0);
    signal tt_Z_Flag     : STD_LOGIC;
    signal tt_N_Flag     : STD_LOGIC;
    signal tt_O_Flag     : STD_LOGIC;
    signal tt_en         : STD_LOGIC;
    signal tt_rst        : STD_LOGIC;
    shared variable sv_expected : STD_LOGIC_VECTOR(2 downto 0) := (others => '0'); -- they should be protected to be encapsulated
    shared variable sv_z_expected : STD_LOGIC := '0';
    shared variable sv_n_expected : STD_LOGIC := '0';
    shared variable sv_o_expected : STD_LOGIC := '0';
    --signal ttt_rtl_result: STD_LOGIC_VECTOR(1 downto 0); should this be tested as well?

begin
    DUT_ALU : ALU   generic map (N => 3)
                    port map (OP => tt_OP,
                              A => tt_A,
                              B => tt_B,
                              Sum => tt_Sum,
                              Z_Flag => tt_Z_Flag,
                              N_Flag => tt_N_Flag,
                              O_Flag => tt_O_Flag,
                              clk => clk,
                              en => tt_en,
                              rst => tt_rst);

    clk <= not clk after 5 ns;
    monitor : process (tt_Sum)
    begin
        if tt_Sum /= sv_expected then
            assert false
            report "Sum is NOT correct = " & integer'image(to_integer(signed(tt_Sum))) & " should be " & integer'image(to_integer(signed(sv_expected)))
            severity error;
        end if;
        if tt_Z_Flag /= sv_z_expected then
            assert false
            report "Z_Flag is NOT correct = " & std_logic'image(tt_Z_Flag) & " should be " & std_logic'image(sv_z_expected)
            severity error;
        end if;
        if tt_N_Flag /= sv_n_expected then
            assert false
            report "N_Flag is NOT correct = " & std_logic'image(tt_N_Flag) & " should be " & std_logic'image(sv_n_expected)
            severity error;
        end if;
        if tt_O_Flag /= sv_o_expected then
            assert false
            report "O_Flag is NOT correct = " & std_logic'image(tt_O_Flag) & " should be " & std_logic'image(sv_o_expected)
            severity error;
        end if;
    end process monitor;

    generator : process
    begin
        -- zero out expected signals
        sv_expected := (others => '0');
        sv_z_expected := '0';
        sv_n_expected := '0';
        sv_o_expected := '0';

        -- reset the system
        tt_rst <= '1';
        wait for 10 ns;
        tt_rst <= '0';
        tt_en <= '1';

		--	when OP_ADD => v_Sum :=
		--	when OP_SUB => v_Sum := std_logic_vector(unsigned(A) - unsigned(B));
		--	when OP_AND => v_Sum := A and B;
		--	when OP_OR 	=> v_Sum := A or B;
		--	when OP_XOR => v_Sum := A xor B;
		--	when OP_NOT => v_Sum := not A;
		--	when OP_MOV => v_Sum := A;
		--	when OP_Zero=> v_Sum := (others => '0');
        wait for 10 ns;
        --for i in
        -- OP_ADD
        tt_OP <= "000";
        tt_A <= (others => '0');
        tt_B <= (others => '0'); -- test for Z_Flag
        sv_z_expected := '1';
        sv_o_expected := '0';
        sv_n_expected := '0';
        wait for 5 ns;
        sv_expected := std_logic_vector(signed(tt_A) + signed(tt_B)); -- have to wait for result of clocked assignment for A and B
        -- need additional wait so that signals are compared (sv_expected has just changed)
        wait for 5 ns;

        tt_A <= "011"; -- test overflow of 2's complement
        tt_B <= "001";
        sv_z_expected := '0';
        sv_o_expected := '1';
        sv_n_expected := '1';
        wait for 5 ns;
        sv_expected := std_logic_vector(signed(tt_A) + signed(tt_B));
        wait for 5 ns;

        -- OP_SUB
        tt_OP <= "001";
        tt_A <= "001"; -- test negative
        tt_B <= "010";
        sv_z_expected := '0';
        sv_o_expected := '1';
        sv_n_expected := '1';
        wait for 5 ns;
        sv_expected := std_logic_vector(signed(tt_A) - signed(tt_B));
        wait for 5 ns;

        -- OP_AND
        tt_OP <= "010";
        tt_A <= "111";
        tt_B <= "000";
        sv_z_expected := '1';
        sv_o_expected := '0';
        sv_n_expected := '0';
        wait for 5 ns;
        sv_expected := tt_A and tt_B;
        wait for 5 ns;

        -- OP_OR
        tt_OP <= "011";
        tt_A <= "111";
        tt_B <= "000";
        sv_z_expected := '0';
        sv_o_expected := '0';
        sv_n_expected := '1';
        wait for 5 ns;
        sv_expected := tt_A or tt_B;
        wait for 5 ns;

        -- OP_XOR
        tt_OP <= "100";
        tt_A <= "101";
        tt_B <= "000";
        sv_z_expected := '0';
        sv_o_expected := '0';
        sv_n_expected := '1';
        wait for 5 ns;
        sv_expected := tt_A xor tt_B;
        wait for 5 ns;

        -- OP_NOT
        tt_OP <= "101";
        tt_A <= "101";
        sv_z_expected := '0';
        sv_o_expected := '0';
        sv_n_expected := '0';
        wait for 5 ns;
        sv_expected := not tt_A;
        wait for 5 ns;

        -- OP_MOV
        tt_OP <= "110";
        tt_A <= "100";
        sv_z_expected := '0';
        sv_o_expected := '0';
        sv_n_expected := '1';
        wait for 5 ns;
        sv_expected := tt_A;
        wait for 5 ns;

        -- OP_Zero
        tt_OP <= "111";
        sv_z_expected := '1';
        sv_o_expected := '0';
        sv_n_expected := '0';
        wait for 5 ns;
        sv_expected := (others => '0');
        wait for 5 ns;

        -- test disabling en
        -- load the data
        tt_OP <= "110";
        tt_A <= "100";
        sv_z_expected := '0';
        sv_o_expected := '0';
        sv_n_expected := '1';
        wait for 5 ns;
        sv_expected := tt_A;
        tt_en <= '0';
        wait for 5 ns;

        tt_OP <= "110";
        tt_A <= "000";
        sv_z_expected := '0'; -- expect the same flags
        sv_o_expected := '0';
        sv_n_expected := '1';
        wait for 5 ns;
        sv_expected := "100"; -- expect no change
        wait for 5 ns;

    end process;
end tb;
