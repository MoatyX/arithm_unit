library ieee;
use ieee.std_logic_1164.all;

entity half_adder is
port(	bitA: in std_ulogic;
	bitB: in std_ulogic;
	sum: out std_ulogic;
	carry: out std_ulogic
);
end half_adder;

architecture logic of half_adder is
begin
sum <= bitA XOR bitB;
carry <= bitA AND bitB;
end logic;