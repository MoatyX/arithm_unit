library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_4bit_divider is
port(
	clk: in std_ulogic;
	reset: in std_ulogic := '0';
	dividend: in std_ulogic_vector (3 downto 0);
	divisor: in std_ulogic_vector (3 downto 0);
	output: out std_ulogic_vector (3 downto 0)
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

signal tmp_dividend: std_ulogic_vector (3 downto 0) := "UUUU";
signal sub_result: std_ulogic_vector (3 downto 0) := "UUUU";
signal comp_zero_result, finish: std_ulogic;
signal comp_rest_result: std_ulogic;
signal div_step: std_ulogic_vector (3 downto 0) := "0000";
signal div_step_increment_result: std_ulogic_vector (3 downto 0);

begin

subber: bin_subtractor PORT MAP(tmp_dividend, divisor, sub_result, '0', OPEN, OPEN);
comp_zero: bin_4bit_comparator PORT MAP(sub_result, "0000", "001", comp_zero_result);
comp_rest: bin_4bit_comparator PORT MAP(sub_result, "0000", "100", comp_rest_result);
adder: bin_adder PORT MAP(div_step, "0001", div_step_increment_result, '0', OPEN, OPEN);

myProcess: process(clk, comp_zero_result, reset)
begin
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
end process;

outputProcess: process(finish)
begin
	if (finish = '1') then
		output <= div_step;
	end if;
end process;

end logic;
