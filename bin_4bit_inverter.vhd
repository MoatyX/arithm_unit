library ieee;
use ieee.std_logic_1164.all;

--summary: this component inverts numbers (multiply with -1) using the 2 complement system
--test example "0101"(int 5) -> "1011"(int -5)

entity bin_4bit_negator is
port(	number: in std_ulogic_vector(3 downto 0);
	invertedNumber: out std_ulogic_vector (3 downto 0)
);
end bin_4bit_negator;

architecture logic of bin_4bit_negator is
component bin_adder is
    port(
        opA: in std_ulogic_vector(3 downto 0);
        opB: in std_ulogic_vector(3 downto 0);
        result: out std_ulogic_vector (3 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic
    );
end component;

signal out_inv_number: std_ulogic_vector(3 downto 0);
begin
	out_inv_number(0) <= NOT number(0);
	out_inv_number(1) <= NOT number(1);
	out_inv_number(2) <= NOT number(2);
	out_inv_number(3) <= NOT number(3);
	x: bin_adder PORT MAP (out_inv_number, "0001", invertedNumber, '0', OPEN);
end logic;