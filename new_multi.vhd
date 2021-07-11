library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
library std;

-- summary: multiplies 2 4bit numbers
entity aaa is 
	 port(	clk : in std_ulogic;
		reset : in std_ulogic := '0';
		op1 :in std_ulogic_vector(3 downto 0) := "0000";
		op2 :in std_ulogic_vector(3 downto 0) := "0000";
		result	 :out std_logic_vector(7 downto 0);
		operation_finished: out std_ulogic := '0'	
		);
end aaa;

architecture Logic of aaa is
	
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


SIGNAL counter: std_ulogic_vector(7 downto 0) := "00000001";
SIGNAL out_counter: std_ulogic_vector(7 downto 0) := "00000000";
SIGNAL tmp_sum: std_ulogic_vector(7 downto 0) := "00000000"; 
SIGNAL tmp_out_sum, negated_tmp_out_sum: std_ulogic_vector(7 downto 0) := "00000000";
SIGNAL abs_op1: std_ulogic_vector(7 downto 0) := "00000000";
SIGNAL abs_op2: std_ulogic_vector(3 downto 0) := "0000";
SIGNAL output_is_negative: std_ulogic := '0';
SIGNAL counter_stop: std_ulogic := '0';
SIGNAL counter_4bit: std_ulogic_vector(3 downto 0) := "0000";

begin

abs_op1 <= std_ulogic_vector(resize(unsigned(op1), abs_op1'length));
abs_op2 <= std_ulogic_vector(resize(unsigned(op2), abs_op2'length));
counter_4bit <= std_ulogic_vector(resize(unsigned(counter), counter_4bit'length));
output_is_negative <= op1(3) XOR op2(3);

out_sum: bin_8bit_adder PORT MAP(abs_op1, tmp_sum, tmp_out_sum, '0', OPEN, OPEN);
op_counter: bin_8bit_adder PORT MAP(counter, "00000001", out_counter, '0', OPEN, OPEN);
counter_op_stop: bin_4bit_comparator PORT MAP(counter_4bit, abs_op2, "001", counter_stop);
negate_output: bin_8bit_negator PORT MAP(tmp_out_sum, negated_tmp_out_sum, OPEN);

multi: process(clk, reset)
begin
if(rising_edge(clk)) then
	if(reset='0') then
		if(counter_stop = '1') then
			operation_finished <= '1';
		else 
			tmp_sum <= tmp_out_sum;
			counter <= out_counter;
		end if;
	else
		tmp_sum <= "00000000";
		operation_finished <= '0';
		counter <= "00000001";
	end if;
end if;
end process;

result <= std_logic_vector(tmp_out_sum) when output_is_negative='0' else std_logic_vector(negated_tmp_out_sum);

end Logic;
