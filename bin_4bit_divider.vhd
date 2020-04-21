library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_4bit_divider is
port(
	clk: in std_ulogic;
	reset: in std_ulogic := '0';
	dividend: in std_ulogic_vector (3 downto 0);
	divisor: in std_ulogic_vector (3 downto 0);
	output: out std_ulogic_vector (3 downto 0);
	division_by_zero: out std_ulogic
);
end bin_4bit_divider;

architecture logic of bin_4bit_divider is

COMPONENT bin_4bit_comparator is
port(	opA: in std_ulogic_vector(3 downto 0);
	opB: in std_ulogic_vector(3 downto 0);
	opType: in std_ulogic_vector(2 downto 0);	--"001" equal, "010" bigger than, "100" smaller than, "011" bigger equal, "101" smaller equal
	result: out std_ulogic	-- 0(fail) or 1(success)
);
end COMPONENT;

--4 bit subtractor
component bin_subtractor is
    port(
        opA: in std_ulogic_vector(3 downto 0);	--1st operand
        opB: in std_ulogic_vector(3 downto 0);	--2nd operand
        result: out std_ulogic_vector (3 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic;
	overflow: out std_ulogic
    );
end component;

component bin_adder is
    port(
        opA: in std_ulogic_vector(3 downto 0);	--1st operand
        opB: in std_ulogic_vector(3 downto 0);	--2nd operand
        result: out std_ulogic_vector (3 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic;
	overflow: out std_ulogic
    );
end component;

component bin_4bit_abs is
PORT(	input: in std_ulogic_vector(3 downto 0);
	abs_output: out std_ulogic_vector(3 downto 0);
	overflow: out std_ulogic	--happens only at abs(-8) = -8
);
END component;

component bin_4bit_negator is
port(	number: in std_ulogic_vector(3 downto 0);		--the input
	negatedNumber: out std_ulogic_vector (3 downto 0);	--the output
	overflow: out std_ulogic				--the overflow flag. happens at abs(-8) = -8
);
end component;

signal tmp_dividend: std_ulogic_vector (3 downto 0) := "UUUU";
signal sub_result: std_ulogic_vector (3 downto 0) := "UUUU";
signal comp_zero_result, finish: std_ulogic;
signal comp_rest_result: std_ulogic;
signal div_step: std_ulogic_vector (3 downto 0) := "0000";
signal div_step_increment_result: std_ulogic_vector (3 downto 0);
signal divisor_eq_zero: std_ulogic := '0';
signal abs_dividend, abs_divisor: std_ulogic_vector (3 downto 0);
signal abs_dividend_overflow, abs_divisor_overflow: std_ulogic;
signal dividend_is_pos, divisor_is_pos: std_ulogic;
signal output_is_negative: std_ulogic;
signal negative_output: std_ulogic_vector (3 downto 0);
begin

-- universal components: components that work no matter the input (no special cases)
dividend_abs: bin_4bit_abs PORT MAP(dividend, abs_dividend, abs_dividend_overflow);		--abs(dividend)
divisor_abs: bin_4bit_abs PORT MAP(divisor, abs_divisor, abs_divisor_overflow);			--abs(divisor)
comp_zero: bin_4bit_comparator PORT MAP(sub_result, "0000", "001", comp_zero_result);		--rest = 0 comparator
comp_divisor_eq_zero: bin_4bit_comparator PORT MAP(divisor, "0000", "001", divisor_eq_zero);	--division by 0
adder: bin_adder PORT MAP(div_step, "0001", div_step_increment_result, '0', OPEN, OPEN);	--division_step incrementer
comp_dividend_negative: bin_4bit_comparator PORT MAP(dividend, abs_dividend, "001", dividend_is_pos);		--dividend > 0
comp_divisor_negative: bin_4bit_comparator PORT MAP(divisor, abs_divisor, "001", divisor_is_pos);		--divisor > 0
output_negator: bin_4bit_negator PORT MAP(div_Step, negative_output, OPEN);


--specific components: components that have special cases
subber: bin_subtractor PORT MAP(tmp_dividend, abs_divisor, sub_result, '0', OPEN, OPEN);
comp_rest: bin_4bit_comparator PORT MAP(sub_result, "0000", "100", comp_rest_result);

division_by_zero <= divisor_eq_zero;
output_is_negative <= NOT dividend_is_pos OR NOT divisor_is_pos;

myProcess: process(clk, comp_zero_result, reset, divisor_eq_zero)
begin
if (divisor_eq_zero='0') then	--dont do anything if we try to divide by 0
	if (reset ='1') then
		finish <= '0';
		tmp_dividend <= "UUUU";
		div_step <= "0000";
		--reset <= '0';
	end if;
	if tmp_dividend = "UUUU" then
		tmp_dividend <= dividend;
	end if;
	if (rising_edge(clk) AND reset='0') then
		--special case. if the abs(divisor) overflows: we know definietly divisor = -8 and output = 0
		
		-- if we dont reach zero or below, keep subtracting
		if (comp_zero_result='0' AND comp_rest_result='0') then
			--keep subtracting and increment the division_step
			tmp_dividend <= sub_result;
			div_step <= div_step_increment_result; 
		else
			--we reached 0 or below, if we go under 0, ignore the last subtraction as a division step
			if(comp_rest_result='0') then
				div_step <= div_step_increment_result;
			end if;
			finish <= '1';
		end if;
	end if;
elsif(divisor_eq_zero='1') then
	finish <= '1';	--finish directly if we try to divide by 0
end if;
end process;

outputProcess: process(finish, divisor_eq_zero, negative_output, output_is_negative)
begin
	if (finish = '1') then
		if (divisor_eq_zero='1') then
			output <= "XXXX";
		else
			if(output_is_negative='1') then
				output <= negative_output;
			else
				output <= div_step;
			end if;
		end if;
	end if;
end process;

end logic;
