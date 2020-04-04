library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity fa_test_bench is
end fa_test_bench;

architecture waveforms of fa_test_bench is
	signal T_bitA: std_ulogic := '0';
	signal T_bitB: std_ulogic := '0';
	signal T_sum: std_ulogic;
	signal T_carry_in: std_ulogic := '0';
	signal T_carry_out: std_ulogic;

	COMPONENT full_adder
		PORT(
			bitA: in std_ulogic;
			bitB: in std_ulogic;
			carry_in: in std_ulogic;
			sum: out std_ulogic;
			carry_out: out std_ulogic
		);
	END COMPONENT;
begin
	fa: full_adder PORT MAP(T_bitA, T_bitB, T_carry_in, T_sum, T_carry_out);
	opA_value: PROCESS
	begin
		T_bitA <= '0';
		wait for 40 ns;
		T_bitA <= '1';
		wait for 40 ns;
	end process;

	opB_value: PROCESS
	begin
		T_bitB <= '0';
		wait for 80 ns;
		T_bitB <= '1';
		wait for 80 ns;
	end process;

	carry_in_value: PROCESS
	begin
		T_carry_in <= '0';
		wait for 160 ns;
		T_carry_in <= '1';
		wait for 160 ns;
	end process;
end waveforms;

configuration one of fa_test_bench is
	for waveforms
		for fa:full_adder
			use entity work.full_adder(logic);
		end for;
	end for;
end one;