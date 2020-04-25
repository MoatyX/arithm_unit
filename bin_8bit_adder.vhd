library ieee;
use ieee.std_logic_1164.all;

entity bin_8bit_adder is
    port(
        opA: in std_ulogic_vector(7 downto 0);	--1st operand
        opB: in std_ulogic_vector(7 downto 0);	--2nd operand
        result: out std_ulogic_vector (7 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic;
	overflow: out std_ulogic
    );
end bin_8bit_adder;

architecture logic of bin_8bit_adder is    
    component full_adder is
        port(
		bitA: in std_ulogic;
	        bitB: in std_ulogic;
	        carry_in: in std_ulogic;
	        sum: out std_ulogic;
	        carry_out: out std_ulogic);
    end component;

    signal cascade_carry: std_ulogic_vector(7 downto 0);

    begin
	--final output
        fa0: full_adder port map (opA(0), opB(0), '0', result(0), cascade_carry(0));
        fa1: full_adder port map (opA(1), opB(1), cascade_carry(0), result(1), cascade_carry(1));
        fa2: full_adder port map (opA(2), opB(2), cascade_carry(1), result(2), cascade_carry(2));
        fa3: full_adder port map (opA(3), opB(3), cascade_carry(2), result(3), cascade_carry(3));
	fa4: full_adder port map (opA(4), opB(4), cascade_carry(3), result(4), cascade_carry(4));
        fa5: full_adder port map (opA(5), opB(5), cascade_carry(4), result(5), cascade_carry(5));
        fa6: full_adder port map (opA(6), opB(6), cascade_carry(5), result(6), cascade_carry(6));
        fa7: full_adder port map (opA(7), opB(7), cascade_carry(6), result(7), cascade_carry(7));

	overflow <= cascade_carry(7) XOR cascade_carry(6);
    end logic;
