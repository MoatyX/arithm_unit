library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity bin_adder_test_bench is
end bin_adder_test_bench;

architecture waveforms of fa_test_bench is
		signal T_opA: std_ulogic_vector(3 downto 0) := "0000";	--1st operand
        signal T_opB: std_ulogic_vector(3 downto 0) := "0000";	--2nd operand
        signal T_result: std_ulogic_vector (3 downto 0);
        signal T_carry_in: std_ulogic := '0';
        signal T_carry_out: std_ulogic;

	COMPONENT bin_adder
		PORT(
			opA: in std_ulogic_vector(3 downto 0);	--1st operand
			opB: in std_ulogic_vector(3 downto 0);	--2nd operand
			result: out std_ulogic_vector (3 downto 0);
			carry_in: in std_ulogic;
			carry_out: out std_ulogic
		);
	END COMPONENT;
begin
	Ba: bin_adder PORT MAP(T_opA, T_opB, T_result, T_carry_in, T_carry_out);
	opA_value: PROCESS
	begin
		T_opA<="0000";
		wait for 40 ns;
		for I in 0 to 15 loop
			T_opA <= T_opA + 1;
			wait for 40 ns;
		end loop;
	end process;

	opB_value: PROCESS
	begin
		T_opB<="0000";
		wait for 40 ns;
		for I in 0 to 15 loop
			T_opB <= T_opB + '1';
			wait for 40 ns;
		end loop;
	end process;
end waveforms;

configuration one of ba_test_bench is
	for waveforms
		for ba:bin_adder
			use entity work.bin_adder(logic);
		end for;
	end for;
end one;
