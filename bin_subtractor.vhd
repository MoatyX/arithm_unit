library ieee;
use ieee.std_logic_1164.all;

entity bin_subtractor is
    port(
        opA: in std_ulogic_vector(3 downto 0);	--1st operand
        opB: in std_ulogic_vector(3 downto 0);	--2nd operand
        result: out std_ulogic_vector (3 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic
    );
end bin_subtractor;

architecture logic of bin_subtractor is

--4 bit adder
component bin_adder is
    port(
        opA: in std_ulogic_vector(3 downto 0);	--1st operand
        opB: in std_ulogic_vector(3 downto 0);	--2nd operand
        result: out std_ulogic_vector (3 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic
    );
end component;

--4 bit negator
component bin_4bit_negator is
port(	number: in std_ulogic_vector(3 downto 0);
	negatedNumber: out std_ulogic_vector (3 downto 0)
);
end component;

signal negatedOpB: std_ulogic_vector(3 downto 0);
begin
	negator: bin_4bit_negator PORT MAP (opB, negatedOpB);
	addr: bin_adder PORT MAP (opA, negatedOpB, result, carry_in, carry_out);
end logic;
