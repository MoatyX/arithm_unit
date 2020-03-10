library ieee;
use ieee.std_logic_1164.all;

entity half_uni is
port (	op: in std_ulogic;
	bitA: in std_ulogic;
	bitB: in std_ulogic;
	result: out std_logic;
	carry_out: out std_ulogic
);
end half_uni;

architecture logic of half_uni is
signal q: std_ulogic;
begin
	result <= ((NOT bitA) AND bitB) OR (bitA AND (NOT bitB));
	q <= ((NOT op) AND bitA) OR ((NOT bitA) AND op);
	carry_out <= q AND bitB;
end logic;
