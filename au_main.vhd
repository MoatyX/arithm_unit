library ieee;
use ieee.std_logic_1164.all;

entity au_main is
port(
	clk: in std_ulogic;
	reset: in std_ulogic := '0';
	operandA: in std_ulogic_vector (3 downto 0);
	operandB: in std_ulogic_vector (3 downto 0);
	operation: in std_ulogic_vector (1 downto 0);	-- "00" add, "01" sub, "10" multi, "11" div
	output: out std_ulogic_vector (7 downto 0)
);
end au_main;

architecture logic of au_main is

component bin_4bit_signed_divider is
port(
	clk: in std_ulogic;
	reset: in std_ulogic := '0';
	dividend: in std_ulogic_vector (3 downto 0);
	divisor: in std_ulogic_vector (3 downto 0);
	output: out std_ulogic_vector (3 downto 0);
	division_by_zero: out std_ulogic;
	operation_finished: out std_ulogic
);
end component;

component bin_4bit_signed_multi is 
	 port(	clk,reset : in std_ulogic;
		op1 :in std_ulogic_vector(3 downto 0);
		op2 :in std_ulogic_vector(3 downto 0);
		Result	 :out std_logic_vector(7 downto 0)
		);
end component;

component bin_4bit_adder is
    port(
        opA: in std_ulogic_vector(3 downto 0);	--1st operand
        opB: in std_ulogic_vector(3 downto 0);	--2nd operand
        result: out std_ulogic_vector (3 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic;
	overflow: out std_ulogic
    );
end component;

component bin_4bit_subtractor is
    port(
        opA: in std_ulogic_vector(3 downto 0);	--1st operand
        opB: in std_ulogic_vector(3 downto 0);	--2nd operand
        result: out std_ulogic_vector (3 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic;
	overflow: out std_ulogic
    );
end component;

-- Signals and variables
signal sub_output, add_output, div_output: std_ulogic_vector (3 downto 0);
signal multi_output: std_logic_vector (7 downto 0);

signal div_operation_finished: std_ulogic;
signal div_by_zero: std_ulogic;

signal adder_overflowed, subber_overflowed: std_ulogic;
--

begin

divider: bin_4bit_signed_divider PORT MAP(clk, reset, operandA, operandB, div_output, div_by_zero, div_operation_finished);
multiplier: bin_4bit_signed_multi PORT MAP(clk, reset, operandA, operandB, multi_output);
adder: bin_4bit_adder PORT MAP(operandA, operandB, add_output, '0', OPEN, adder_overflowed);
subtractor: bin_4bit_subtractor PORT MAP(operandA, operandB, sub_output, '0', OPEN, subber_overflowed);

--map the final output based on the operation
output <= "0000"&add_output when operation = "00" else 
	 "0000"&sub_output when operation = "01" else 
	 std_ulogic_vector(multi_output) when operation = "10" else 
	 "0000"&div_output when operation = "11";

end logic; 
