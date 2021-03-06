library ieee;
use ieee.std_logic_1164.all;

-- summary: subtracts 2 4bit numbers. and adds overflow an overflow signal 

entity bin_8bit_subtractor is
    port(
        opA: in std_ulogic_vector(7 downto 0);	--1st operand
        opB: in std_ulogic_vector(7 downto 0);	--2nd operand
        result: out std_ulogic_vector (7 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic;
	overflow: out std_ulogic
    );
end bin_8bit_subtractor;

architecture logic of bin_8bit_subtractor is

--8 bit adder
component bin_8bit_adder is
    port(
        opA: in std_ulogic_vector(7 downto 0);	--1st operand
        opB: in std_ulogic_vector(7 downto 0);	--2nd operand
        result: out std_ulogic_vector (7 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic;
	overflow: out std_logic
    );
end component;

--8 bit negator
component bin_8bit_negator is
port(	number: in std_ulogic_vector(7 downto 0);
	negatedNumber: out std_ulogic_vector (7 downto 0);
	overflow: out std_ulogic
);
end component;

signal negatedOpB: std_ulogic_vector(7 downto 0);
signal negator_overflow: std_ulogic;
signal adder_overflow: std_ulogic;
begin

	negator: bin_8bit_negator PORT MAP (opB, negatedOpB, negator_overflow);
	addr: bin_8bit_adder PORT MAP (opA, negatedOpB, result, carry_in, carry_out, adder_overflow);
	overflow <= negator_overflow OR adder_overflow;

end logic;
