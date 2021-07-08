
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
library std;

-- summary: multiplies 2 4bit numbers

entity bin_4bit_signed_multi is 
	 port(	clk : in std_ulogic;
		reset : in std_ulogic := '0';
		op1 :in std_ulogic_vector(3 downto 0) := "0000";
		op2 :in std_ulogic_vector(3 downto 0) := "0000";
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
	signal pv_temp:		std_ulogic_vector(7 downto 0);
	signal pb_temp:		std_ulogic_vector(7 downto 0) :="00000000";
	signal out_temp:	std_ulogic_vector(7 downto 0) :="00000000";
COMPONENT bin_8bit_adder is
    port(
        opA: in std_ulogic_vector(7 downto 0);	--1st operand
        opB: in std_ulogic_vector(7 downto 0);	--2nd operand
        result: out std_ulogic_vector (7 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic;
	overflow: out std_ulogic
    );
end COMPONENT;
SIGNAL abs_op1, abs_op2: std_ulogic_vector(3 downto 0);
SIGNAL abs_op1_overflow, abs_op2_overflow: std_ulogic;
SIGNAL op1_is_pos, op2_is_pos: std_ulogic;
SIGNAL finish :std_ulogic :='0' ;
Signal tmp_output :std_logic_vector(7 downto 0);
SIGNAL negated_tmp_output :std_ulogic_vector(7 downto 0);
SIGNAL output_is_negative: std_ulogic;
signal abs_op1_temp : std_ulogic_vector(7 downto 0);
signal counter: integer :=0;
begin
abs_op1_temp <= std_ulogic_vector(resize(unsigned(abs_op1),abs_op1_temp'length));
-- abs
op1_abs: bin_4bit_abs PORT MAP(op1, abs_op1, abs_op1_overflow);
op2_abs: bin_4bit_abs PORT MAP(op2, abs_op2, abs_op2_overflow);

-- comparators
op1_is_pos_comp: bin_4bit_comparator PORT MAP(op1, "0000", "011", op1_is_pos);
op2_is_pos_comp: bin_4bit_comparator PORT MAP(op2, "0000", "011", op2_is_pos);

output_negator: bin_8bit_negator PORT MAP(std_ulogic_vector(tmp_outPut), negated_tmp_output, OPEN);
output_is_negative <= (NOT op1_is_pos OR abs_op1_overflow) XOR (NOT op2_is_pos OR abs_op2_overflow);
	
multi : bin_8bit_adder PORT MAP (pv_temp , pb_temp, out_temp, '0',open,open);

Multiplizierer : process(clk)
 variable pv: std_ulogic_vector(7 downto 0);
	variable bp: std_logic_vector(7 downto 0);

begin

if(rising_edge(clk)) then

pv := "00000000";
bp :="0000"&std_logic_vector(abs_op2);
counter <= To_integer(unsigned(abs_op1));
--pv_temp <= "00000000";
for I in 0 to counter loop
	--if abs_op1(i)='1' then 
		--pv:=pv+bp;
		pv_temp <= std_ulogic_vector(pv);
		pb_temp <= std_ulogic_vector(bp);
		pv := std_ulogic_vector(out_temp);
--wait for 10 ns;
	--end if--
--bp:=bp(6 downto 0)&'0';
end loop;

tmp_output<=std_logic_vector(out_temp);
finish<='1';
end if;
end process;


EndCal:process(finish,tmp_output)
begin
if finish='1' then
	if(output_is_negative='1') then
		Result <= std_logic_vector(negated_tmp_output);
	else
		Result <= tmp_output;
	end if;
end if;
end process;
end Logic;