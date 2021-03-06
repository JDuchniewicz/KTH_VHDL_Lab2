library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
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
end ALU;

architecture data_flow of ALU is -- should it be called behavioral?
	type t_operation is (OP_ADD, OP_SUB, OP_AND, OP_OR, OP_XOR, OP_NOT, OP_MOV, OP_Zero);

    constant c_all_zeros : STD_LOGIC_VECTOR(A'range) := (others => '0');
begin
	proc : process(OP, A, B, rst, en, clk)
		variable v_Sum :    STD_LOGIC_VECTOR(N - 1 downto 0);
        variable v_Z_Flag : STD_LOGIC;
        variable v_N_Flag : STD_LOGIC;
        variable v_O_Flag : STD_LOGIC;
	begin
    if rst = '1' then
        Sum <= (others => '0');
        Z_Flag <= '0';
        N_Flag <= '0';
        O_Flag <= '0';
    elsif en = '1' then
		case (t_operation'val(to_integer(unsigned(OP)))) is
			when OP_ADD => v_Sum := std_logic_vector(signed(A) + signed(B));
			when OP_SUB => v_Sum := std_logic_vector(signed(A) - signed(B));
			when OP_AND => v_Sum := A and B;
			when OP_OR 	=> v_Sum := A or B;
			when OP_XOR => v_Sum := A xor B;
			when OP_NOT => v_Sum := not A;
			when OP_MOV => v_Sum := A;
			when OP_Zero=> v_Sum := (others => '0');
		end case;
        -- flags
        if v_Sum = c_all_zeros then
            v_Z_Flag := '1';
        else
            v_Z_Flag := '0';
        end if;
        v_N_Flag := v_Sum(N - 1) and '1';
        -- this could be implemented easier if we know the carry value but it is implemented by the compiler
        if (A(N - 1) = '1' and B(N - 1) = '1') then -- if bits before are the same but the result is different we have overflow
            if v_Sum(N - 1) = '0' then
                v_O_Flag := '1';
            else
                v_O_Flag := '0';
            end if;
        elsif (A(N - 1) = '0' and B(N - 1) = '0') then
            if v_Sum(N - 1) = '1' then
                v_O_Flag := '1';
            else
                v_O_Flag := '0';
            end if;
        else
            v_O_Flag := '0';
        end if;
        if rising_edge(clk) then
            -- clk posedge (update the outputs)
            Sum <= v_Sum;
            Z_Flag <= v_Z_Flag;
            N_Flag <= v_N_Flag;
            O_Flag <= v_O_Flag;
        end if;
    else
        Sum <= v_Sum;
        Z_Flag <= v_Z_Flag;
        N_Flag <= v_N_Flag;
        O_Flag <= v_O_Flag;
    end if;
	end process proc;
end data_flow;
