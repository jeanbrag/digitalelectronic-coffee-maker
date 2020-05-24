library verilog;
use verilog.vl_types.all;
entity medio is
    generic(
        S1contagem_money: vl_logic_vector(3 downto 0) := (Hi0, Hi0, Hi0, Hi1);
        S2verifica_agua : vl_logic_vector(3 downto 0) := (Hi0, Hi0, Hi1, Hi1);
        S3verifica_borra: vl_logic_vector(3 downto 0) := (Hi0, Hi0, Hi1, Hi0);
        S4sel_ciclos    : vl_logic_vector(3 downto 0) := (Hi0, Hi1, Hi1, Hi0);
        S5verifica_temp : vl_logic_vector(3 downto 0) := (Hi0, Hi1, Hi1, Hi1);
        S6ciclo_moagem  : vl_logic_vector(3 downto 0) := (Hi0, Hi1, Hi0, Hi1);
        S7verifica_graos: vl_logic_vector(3 downto 0) := (Hi0, Hi1, Hi0, Hi0);
        S8espera        : vl_logic_vector(3 downto 0) := (Hi1, Hi1, Hi0, Hi0);
        S9cafe          : vl_logic_vector(3 downto 0) := (Hi1, Hi1, Hi0, Hi1)
    );
    port(
        clk             : in     vl_logic;
        money           : in     vl_logic;
        sen_borra       : in     vl_logic;
        sen_grao        : in     vl_logic;
        sen_temp        : in     vl_logic;
        nvl_agua        : in     vl_logic;
        sel_ciclos      : in     vl_logic_vector(2 downto 0);
        rst             : in     vl_logic;
        coffee          : out    vl_logic;
        balance         : out    vl_logic;
        clock1hz        : in     vl_logic;
        busy            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of S1contagem_money : constant is 2;
    attribute mti_svvh_generic_type of S2verifica_agua : constant is 2;
    attribute mti_svvh_generic_type of S3verifica_borra : constant is 2;
    attribute mti_svvh_generic_type of S4sel_ciclos : constant is 2;
    attribute mti_svvh_generic_type of S5verifica_temp : constant is 2;
    attribute mti_svvh_generic_type of S6ciclo_moagem : constant is 2;
    attribute mti_svvh_generic_type of S7verifica_graos : constant is 2;
    attribute mti_svvh_generic_type of S8espera : constant is 2;
    attribute mti_svvh_generic_type of S9cafe : constant is 2;
end medio;
