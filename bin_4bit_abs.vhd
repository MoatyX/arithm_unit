library ieee;
use ieee.std_logic_1164.all;

--summary: return the abs on a 4bit nummber

ENTITY bin_4bit_abs is
PORT(	input: in std_ulogic_vector(3 downto 0);
	abs_output: out std_ulogic_vector(3 downto 0);
	overflow: out std_ulogic	--happens only when asked for the abs of the min number in 2' complement (in our case, at -8)
);
END bin_4bit_abs;

ARCHITECTURE logic of bin_4bit_abs is

COMPONENT bin_4bit_negator is
port(	number: in std_ulogic_vector(3 downto 0);
	negatedNumber: out std_ulogic_vector (3 downto 0);
	overflow: out std_ulogic
);
end COMPONENT;

SIGNAL tmpNegatedNum: std_ulogic_vector(3 downto 0);
begin

negator: bin_4bit_negator PORT MAP(input, tmpNegatedNum, overflow);

operation: process(tmpNegatedNum)
begin
	if input(3)='1' then
		abs_output <= tmpNegatedNum;
	else
		abs_output <= input;
	end if;
end process;

end logic;
