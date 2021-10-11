library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_divider is
    generic (IN_FREQ : INTEGER := 50_000_000;
             OUT_FREQ : INTEGER := 1);
    port (clk     : in STD_ULOGIC;
          rst     : in STD_LOGIC;
          out_clk : out STD_ULOGIC);
end clk_divider;

architecture structural of clk_divider is
    constant COUNT : INTEGER := IN_FREQ / OUT_FREQ - 1; -- since we count from 0
begin
    proc : process(clk, rst)
        variable v_counter : INTEGER := 0;
    begin
        if rst = '1' then
            v_counter := 0;
            out_clk <= '0';
        elsif rising_edge(clk) then
            if v_counter = COUNT then
                v_counter := 0;
                out_clk <= '1';
            else
                v_counter := v_counter + 1;
                out_clk <= '0';
            end if;
        end if;
    end process;

end structural;
