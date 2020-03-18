library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- Needed for shifts

entity bin_divider is
PORT (	clk: in std_ulogic;
	opA: in std_ulogic_vector (3 downto 0);
	opB: in std_ulogic_vector (3 downto 0);
	result: out std_ulogic_vector (3 downto 0)
);
end bin_divider;

architecture logic of bin_divider is

COMPONENT bin_4bit_abs is
PORT(	input: in std_ulogic_vector(3 downto 0);
	abs_output: out std_ulogic_vector(3 downto 0)
);
end COMPONENT;

COMPONENT bin_4bit_comparator is
port(	opA: in std_ulogic_vector(3 downto 0);
	opB: in std_ulogic_vector(3 downto 0);
	opType: in std_ulogic_vector(2 downto 0);	--"001" equal, "010" bigger than, "100" smaller than, "011" bigger equal, "101" smaller equal
	result: out std_ulogic	-- 0(fail) or 1(success)
);
end COMPONENT;

COMPONENT bin_4bit_negator is
port(	number: in std_ulogic_vector(3 downto 0);
	negatedNumber: out std_ulogic_vector (3 downto 0)
);
end COMPONENT;

SIGNAL divByZero: std_ulogic := 'U';
SIGNAL finalSignIsNegative: std_ulogic := 'U';

SIGNAL abs_opA, abs_opB: std_ulogic_vector(3 downto 0);
SIGNAL tmpResult: std_ulogic_vector(3 downto 0);
SIGNAL negativeTmpResult: std_ulogic_vector(3 downto 0);
SIGNAL opB_sub3, opB_sub2, opB_sub1, opB_sub0: unsigned(3 downto 0) := "0000";
begin

absA: bin_4bit_abs PORT MAP(opA, abs_opA);
absB: bin_4bit_abs PORT MAP(opB, abs_opB);

opB_sub3 <= SHIFT_RIGHT(unsigned(abs_opB), 3);
opB_sub2 <= SHIFT_RIGHT(unsigned(abs_opB), 2);
opB_sub1 <= SHIFT_RIGHT(unsigned(abs_opB), 1);
opB_sub0 <= SHIFT_RIGHT(unsigned(abs_opB), 0);

fr3: bin_4bit_comparator PORT MAP(abs_opA, std_ulogic_vector(opB_sub3), "101", tmpResult(3));
fr2: bin_4bit_comparator PORT MAP(abs_opA, std_ulogic_vector(opB_sub2), "101", tmpResult(2));
fr1: bin_4bit_comparator PORT MAP(abs_opA, std_ulogic_vector(opB_sub1), "101", tmpResult(1));
fr0: bin_4bit_comparator PORT MAP(abs_opA, std_ulogic_vector(opB_sub0), "101", tmpResult(0));

inveter: bin_4bit_negator PORT MAP(tmpResult, negativeTmpResult);
 
operation: process(clk) is
begin
if rising_edge(clk) then
	--how it works: 
	--check if opB is 0. if it is, return X (std_ulogic that means unknown)
	--calculate the end sign, in that we check if: both numbers negative -> result >= 0; one is negative result <= 0; both positive result >= 0
	--calculate the division: subtract opB from opA until res <= 0. the number of subtractions is the end result of the division

	--avoid division by zero
	if opB="0000" then
		divByZero <= '1';
	else
		divByZero <= '0';
	end if;

	--logic
	if NOT divByZero='1' then
		--determaine the final sign
		finalSignIsNegative <= opA(3) XOR opB(3);
		
	end if;
end if;
end process;

correction: process(tmpResult, divByZero) is
begin
	if (divByZero='1') then
		result <= "UUUU";
	else
		--fix the result if it should be negative
		if (finalSignIsNegative='1') then
			result <= negativeTmpResult;
		else 
			result <= tmpResult;
		end if;
	end if;
	
end process;

end logic;