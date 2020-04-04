
library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
entity ha_test_bench is
end ha_test_bench;

architecture waveforms of ha_test_bench is
	signal T_bitA: std_ulogic := '0';
	signal T_bitB: std_ulogic := '0';
	signal T_sum: std_ulogic;
	signal T_carry: std_ulogic;

	COMPONENT half_adder
		PORT(
			bitA: in std_ulogic;
			bitB: in std_ulogic;
			sum: out std_ulogic;
			carry: out std_ulogic
		);
	END COMPONENT;
begin
	ha: half_adder PORT MAP(T_bitA, T_bitB, T_sum, T_carry);
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
end waveforms;

configuration one of ha_test_bench is
	for waveforms
		for ha:half_adder
			use entity work.half_adder(logic);
		end for;
	end for;
end one;