library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_dvider_tb is

end clk_dvider_tb;

architecture tb of clk_dvider_tb is
    component clk_divider is
        generic (IN_FREQ : INTEGER := 50_000_000;
                 OUT_FREQ : INTEGER := 1);
        port (clk     : in STD_ULOGIC;
              rst     : in STD_LOGIC;
              out_clk : out STD_ULOGIC);
    end component;

    signal clk      : STD_ULOGIC := '0';
    signal rst      : STD_LOGIC;
    signal out_clk  : STD_ULOGIC;
    shared variable sv_expected_out_clk : STD_ULOGIC;
begin
    DUT_clk_divider : clk_divider generic map(IN_FREQ => 10,
                                              OUT_FREQ => 1)
                                  port map(clk => clk,
                                           rst => rst,
                                           out_clk => out_clk);
    clk <= not clk after 20 ns; -- 50 MHz clock

    monitor : process(out_clk)
    begin
        if out_clk /=  sv_expected_out_clk then
            assert false
            report "wrong clock value = " & std_logic'image(out_clk) & " expected = " & std_logic'image(sv_expected_out_clk)
            severity error;
        end if;
    end process;

    generator : process
    begin
        rst <= '1';
        sv_expected_out_clk := '0';
        wait for 20 ns;
        rst <= '0';

        wait for 400 ns;
        sv_expected_out_clk := '1';
        wait for 20 ns;

        sv_expected_out_clk := '0';
        wait for 20 ns;
    end process;
end tb;
