
library ieee;
use ieee.std_logic_1164.all;


entity multi is 
	 port(	rst,clk : in std_ulogic;
		op1 :in std_ulogic_vector(3 downto 0);
		op2 :in std_ulogic_vector(3 downto 0);
		Result	 :out std_logic_vector(7 downto 0)
		);
end multi;

architecture Logic of multi is

COMPONENT bin_4bit_abs is
PORT(	input: in std_ulogic_vector(3 downto 0);
	abs_output: out std_ulogic_vector(3 downto 0);
	overflow: out std_ulogic	--happens only when asked for the abs of the min number in 2' complement (in our case, at -8)
);
END COMPONENT;

COMPONENT bin_4bit_comparator is
port(	opA: in std_ulogic_vector(3 downto 0);
	opB: in std_ulogic_vector(3 downto 0);
	opType: in std_ulogic_vector(2 downto 0);	--"001" equal, "010" bigger than, "100" smaller than, "011" bigger equal, "101" smaller equal
	result: out std_ulogic	-- 0(fail) or 1(success)
);
end COMPONENT;

SIGNAL abs_op1, abs_op2: std_ulogic_vector(3 downto 0);
SIGNAL abs_op1_overflow, abs_op2_overflow: std_ulogic;
SIGNAL op1_is_pos, op2_is_pos: std_ulogic;

SIGNAL output_is_negative: std_ulogic;

begin

op1_abs: bin_4bit_abs PORT MAP(op1, abs_op1, abs_op1_overflow);
op2_abs: bin_4bit_abs PORT MAP(op2, abs_op2, abs_op2_overflow);

op1_is_pos_comp: bin_4bit_comparator PORT MAP(op1, "0000", "011", op1_is_pos);
op2_is_pos_comp: bin_4bit_comparator PORT MAP(op2, "0000", "011", op2_is_pos);

output_is_negative <= (NOT op1_is_pos OR abs_op1_overflow) XOR (NOT op2_is_pos OR abs_op2_overflow);

end Logic;