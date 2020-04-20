library ieee;
use ieee.std_logic_1164.all;

entity bin_adder is
    port(
        opA: in std_ulogic_vector(3 downto 0);	--1st operand
        opB: in std_ulogic_vector(3 downto 0);	--2nd operand
        result: out std_ulogic_vector (3 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic;
	overflow: out std_ulogic
    );
end bin_adder;

architecture logic of bin_adder is    
    component full_adder is
        port(
		bitA: in std_ulogic;
	        bitB: in std_ulogic;
	        carry_in: in std_ulogic;
	        sum: out std_ulogic;
	        carry_out: out std_ulogic);
    end component;

    signal cascade_carry: std_ulogic_vector(3 downto 0);

    begin
	--final output
        fa0: full_adder port map (opA(0), opB(0), '0', result(0), cascade_carry(0));
        fa1: full_adder port map (opA(1), opB(1), cascade_carry(0), result(1), cascade_carry(1));
        fa2: full_adder port map (opA(2), opB(2), cascade_carry(1), result(2), cascade_carry(2));
        fa3: full_adder port map (opA(3), opB(3), cascade_carry(2), result(3), cascade_carry(3));

	overflow <= cascade_carry(3) XOR cascade_carry(2);
    end logic;