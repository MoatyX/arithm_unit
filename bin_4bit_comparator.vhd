library ieee;
use ieee.std_logic_1164.all;

-- summary: compares 2 4bit nummbers according to a 3bit number representing the Operation Type
-- Operation Types: "001" equal, "010" bigger than, "100" smaller than, "011" bigger equal, "101" smaller equal

entity bin_4bit_comparator is
port(	opA: in std_ulogic_vector(3 downto 0);
	opB: in std_ulogic_vector(3 downto 0);
	opType: in std_ulogic_vector(2 downto 0);	--"001" equal, "010" bigger than, "100" smaller than, "011" bigger equal, "101" smaller equal
	result: out std_ulogic	-- 0(fail) or 1(success)
);
end bin_4bit_comparator;



architecture logic of bin_4bit_comparator is

--4 bit subtractor
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

signal subber_overflow: std_ulogic;

--the equal function (X == Y)
function EQUAL_OLD(X,Y: std_ulogic_vector(3 downto 0)) 
	return std_ulogic is
variable output: std_ulogic := 'U';
begin
output := (X(3) XNOR Y(3)) AND (X(2) XNOR Y(2)) AND (X(1) XNOR Y(1)) AND (X(0) XNOR Y(0));
return output;
end EQUAL_OLD;

function EQUAL_ZERO(X: std_ulogic_vector(3 downto 0))
	return std_ulogic is
begin
if X = "0000" then
	return '1';
else
	return '0';
end if;
end EQUAL_ZERO;

function NEGATIVE(X: std_ulogic_vector(3 downto 0))
	return std_ulogic is
begin
if X(3) = '1' then
	return '1';
else
	return '0';
end if;
end NEGATIVE;

signal sub: std_ulogic_vector(3 downto 0);
begin

subber: bin_4bit_subtractor PORT MAP(opA, opB, sub, '0', OPEN, subber_overflow);

operation: process(opType, sub, subber_overflow) is
begin
case opType is
	when "001" =>	--Equal operation
		--result <= EQUAL_OLD(opA, opB);
		result <= EQUAL_ZERO(sub);
	when "010" =>	--greater than operation
		-- opA - opB = 0ddd (postive number that is NOT 0)
		-- consider overflows as well as a potential error. use XOR to solve overflow problems
		result <= ((sub(3) XNOR '0') XOR subber_overflow) AND (NOT EQUAL_ZERO(sub));
	when "100" =>	--smaller than operation
		-- opA - opB = 1ddd (negative number that is NOT 0)
		-- consider overflows as well as a potential error. use XOR to solve overflow problems
		result <= ((sub(3) XNOR '1') XOR subber_overflow) AND (NOT EQUAL_ZERO(sub));
	when "011" =>	--greater equal operation
		-- opA - opB = 0ddd | 0000 (postive number that CAN be 0)
		result <= ((sub(3) XNOR '0') XOR subber_overflow) OR EQUAL_ZERO(sub);
	when "101" =>	--smaller than operation
		-- opA - opB = 1ddd | 0000 (negative number that CAN be 0)
		result <= ((sub(3) XNOR '1') XOR subber_overflow) OR EQUAL_ZERO(sub);
	when others => result <= 'U';
end case;
end process;

end logic;
