library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity abs_test is
port(input: in std_ulogic_vector(3 downto 0));
end abs_test;

architecture logic of abs_test is

component bin_4bit_abs is
PORT(	input: in std_ulogic_vector(3 downto 0);
	abs_output: out std_ulogic_vector(3 downto 0);
	overflow: out std_ulogic	--happens only at abs(-8) = -8
);
END component;

signal res: std_ulogic_vector(3 downto 0);
signal tmp_abs: std_ulogic_vector(3 downto 0);
signal init: std_ulogic := '0';
begin

abser: bin_4bit_abs PORT MAP(input, res, OPEN);


tp: process(res, init)
begin
	if (NOT (res = "UUUU")) then
		init <= '1';
	end if;

	if (init = '1') then
		tmp_abs <= res;
	end if;
end process;

end logic;
