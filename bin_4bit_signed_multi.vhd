
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity bin_4bit_signed_multi is 
	 port(	clk,reset : in std_ulogic;
		op1 :in std_ulogic_vector(3 downto 0);
		op2 :in std_ulogic_vector(3 downto 0);
		Result	 :out std_logic_vector(7 downto 0)
		);
end bin_4bit_signed_multi;

architecture Logic of bin_4bit_signed_multi is

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

COMPONENT bin_8bit_negator is
port(	number: in std_ulogic_vector(7 downto 0);		--the input
	negatedNumber: out std_ulogic_vector (7 downto 0);	--the output
	overflow: out std_ulogic				--the overflow flag. happens at abs(-8) = -8
);
end COMPONENT;

SIGNAL abs_op1, abs_op2: std_ulogic_vector(3 downto 0);
SIGNAL abs_op1_overflow, abs_op2_overflow: std_ulogic;
SIGNAL op1_is_pos, op2_is_pos: std_ulogic;
SIGNAL finish :std_ulogic;
Signal tmp_output :std_logic_vector(7 downto 0);
SIGNAL negated_tmp_output :std_ulogic_vector(7 downto 0);
SIGNAL output_is_negative: std_ulogic;

begin

-- abs
op1_abs: bin_4bit_abs PORT MAP(op1, abs_op1, abs_op1_overflow);
op2_abs: bin_4bit_abs PORT MAP(op2, abs_op2, abs_op2_overflow);

-- comparators
op1_is_pos_comp: bin_4bit_comparator PORT MAP(op1, "0000", "011", op1_is_pos);
op2_is_pos_comp: bin_4bit_comparator PORT MAP(op2, "0000", "011", op2_is_pos);

output_negator: bin_8bit_negator PORT MAP(std_ulogic_vector(tmp_outPut), negated_tmp_output, OPEN);

output_is_negative <= (NOT op1_is_pos OR abs_op1_overflow) XOR (NOT op2_is_pos OR abs_op2_overflow);
Multiplizierer : process(clk)
variable pv,bp: std_logic_vector(7 downto 0);
begin
pv:="00000000";
bp:="0000"&std_logic_vector(abs_op2);
for I in 0 to 3 loop
	if abs_op1(i)='1' then 
		pv:=pv+bp;
	end if;
	bp:=bp(6 downto 0)&'0';
end loop;
finish<='1';
tmp_output<=pv;
--Result<=pv;
end process;
EndCal:process(finish, tmp_output, negated_tmp_output)
begin
if finish='1' then
 --Result<=pv;
	if(output_is_negative='1') then
		Result <= std_logic_vector(negated_tmp_output);
	else
		Result <= tmp_output;
	end if;
end if;
end process;
end Logic;