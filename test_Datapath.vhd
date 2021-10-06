library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Datapath is

end tb_Datapath;

architecture tb of tb_Datapath is
    component Datapath is
        generic (M: INTEGER;
                 N : INTEGER);
        port (Input     : in STD_LOGIC_VECTOR(N - 1 downto 0);
              IE        : in STD_LOGIC;
              WAddr     : in STD_LOGIC_VECTOR(M - 1 downto 0);
              Write     : in STD_LOGIC;
              RA        : in STD_LOGIC_VECTOR(M - 1 downto 0);
              ReadA     : in STD_LOGIC;
              RB        : in STD_LOGIC_VECTOR(M - 1 downto 0);
              ReadB     : in STD_LOGIC;
              OE        : in STD_LOGIC;
              EN        : in STD_LOGIC;
              OP        : in STD_LOGIC_VECTOR(2 downto 0);
              Output    : out STD_LOGIC_VECTOR(N - 1 downto 0);
              Z_Flag    : out STD_LOGIC;
              N_Flag    : out STD_LOGIC;
              O_Flag    : out STD_LOGIC;
              clk       : in STD_ULOGIC;
              rst       : in STD_LOGIC);
    end component;

    constant c_M : INTEGER := 3;
    constant c_N : INTEGER := 3;

    signal clk          : STD_ULOGIC := '0';
    signal rst          : STD_LOGIC;
    signal tt_Input     : STD_LOGIC_VECTOR(c_N - 1 downto 0);
    signal tt_IE        : STD_LOGIC;
    signal tt_WAddr     : STD_LOGIC_VECTOR(c_M - 1 downto 0);
    signal tt_Write     : STD_LOGIC;
    signal tt_RA        : STD_LOGIC_VECTOR(c_M - 1 downto 0);
    signal tt_ReadA     : STD_LOGIC;
    signal tt_RB        : STD_LOGIC_VECTOR(c_M - 1 downto 0);
    signal tt_ReadB     : STD_LOGIC;
    signal tt_OE        : STD_LOGIC;
    signal tt_EN        : STD_LOGIC;
    signal tt_OP        : STD_LOGIC_VECTOR(2 downto 0);
    signal tt_Output    : STD_LOGIC_VECTOR(c_N - 1 downto 0);
    signal tt_Z_Flag    : STD_LOGIC;
    signal tt_N_Flag    : STD_LOGIC;
    signal tt_O_Flag    : STD_LOGIC;

    shared variable sv_expected_output : STD_LOGIC_VECTOR(c_N - 1 downto 0);
begin
    DUT_Datapath : Datapath generic map(M => c_M,
                                        N => c_N)
                            port map(Input => tt_Input,
                                     IE => tt_IE,
                                     WAddr => tt_WAddr,
                                     Write => tt_Write,
                                     RA => tt_RA,
                                     ReadA => tt_ReadA,
                                     RB => tt_RB,
                                     ReadB => tt_ReadB,
                                     OE => tt_OE,
                                     EN => tt_EN,
                                     OP => tt_OP,
                                     Output => tt_Output,
                                     Z_Flag => tt_Z_Flag,
                                     N_Flag => tt_N_Flag,
                                     O_Flag => tt_O_Flag,
                                     clk => clk,
                                     rst => rst);

    clk <= not clk after 5 ns;

    monitor : process(tt_Output)
    begin
        if tt_Output /= sv_expected_output then
            assert false
            report "Wrong data on Output = " & integer'image(to_integer(signed(tt_Output))) & " expected = " & integer'image(to_integer(signed(sv_expected_output))) -- signed?
            severity error;
        end if;
    end process;

    generator : process
    begin

    rst <= '1';
    tt_IE <= '0';
    tt_OE <= '0';
    wait for 10 ns;
    sv_expected_output := "ZZZ";

    rst <= '0';

    -- store 1 at address 001
    tt_OP <= "110";
    tt_EN <= '1';
    tt_WAddr <= std_logic_vector(to_unsigned(1, tt_WAddr'length));
    tt_Input <= std_logic_vector(to_unsigned(1, tt_Input'length));
    tt_Write <= '1';
    tt_IE <= '1'; -- select data from Input
    wait for 10 ns;

    -- store 1 at address 002
    tt_WAddr <= std_logic_vector(to_unsigned(2, tt_WAddr'length));
    wait for 10 ns;

    -- add 1 several times and read the result from the Datapath (RF contains zeros)
    for i in 1 to 10 loop
        tt_OP <= "000";
        tt_EN <= '1';
        tt_WAddr <= std_logic_vector(to_unsigned(1, tt_WAddr'length));
        --if i = 1 then -- TODO: check what is going on - looks like the calculation takes two clock cycles so need to wait this time
        --    tt_Write <= '0';
        --else
            tt_Write <= '1';
        --end if;
        tt_IE <= '0'; -- select data from ALU and write back to RF

        tt_OE <= '1';
        tt_RA <= std_logic_vector(to_unsigned(1, tt_RA'length));
        tt_ReadA <= '1';
        tt_RB <= std_logic_vector(to_unsigned(2, tt_RB'length));
        tt_ReadB <= '1';
        sv_expected_output := std_logic_vector(to_unsigned(i - 1, sv_expected_output'length)); -- it should hold result from last cycle
        wait for 20 ns;
    end loop;

    -- read the data to check if the value is proper last time
    sv_expected_output := std_logic_vector(to_unsigned(10, sv_expected_output'length));

    end process;
end tb;

