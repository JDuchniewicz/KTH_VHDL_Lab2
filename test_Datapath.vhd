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

    signal clk          : STD_ULOGIC;
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
begin
    DUT_Datapath : Datapath generic map(M => c_M,
                                        N => c_N);
                            port map(Input => tt_Input,
                                     IE => tt_IE,
                                     WAddr => tt_WAddr,
                                     Write => tt_Write,
                                     RA => tt_RA,


end tb;

