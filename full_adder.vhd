library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
port(	bitA: in std_ulogic;
	bitB: in std_ulogic;
	carry_in: in std_ulogic;
	sum: out std_ulogic;
	carry_out: out std_ulogic
);
end full_adder;

architecture logic of full_adder is
	component half_adder is
		port(
			bitA: in std_ulogic;
			bitB: in std_ulogic;
			sum: out std_ulogic;
			carry: out std_ulogic);
	end component;
	signal bits_sum, bits_carry, carry_final: std_ulogic;
begin
	ha1: half_adder port map (bitA, bitB, bits_sum, bits_carry);
	ha2: half_adder port map (carry_in, bits_sum, sum, carry_final);

	carry_out <= bits_carry or carry_final;
end logic;