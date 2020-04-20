
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_4bit_abs_test_bench is
end bin_4bit_abs_test_bench;

architecture waveforms of bin_4bit_abs_test_bench is
	SIGNAL T_input: std_ulogic_vector(3 downto 0) := "1000";	-- (-8)
	SIGNAL T_abs_output: std_ulogic_vector(3 downto 0);
	
	COMPONENT bin_4bit_abs
		PORT(
			input: in std_ulogic_vector(3 downto 0);
			abs_output: out std_ulogic_vector(3 downto 0)
		);
	end COMPONENT;
begin
	bin_abs: bin_4bit_abs PORT MAP(T_input, T_abs_output);
	bin_abs_process: PROCESS
	begin
		T_input <= "1000";
		for i in 0 to 15 loop
			T_input <= std_ulogic_vector(signed(T_input) + 1);
			wait for 40 ns;
		end loop;
	end PROCESS;
end waveforms;

configuration one of bin_4bit_abs_test_bench is
	for waveforms
		for bin_abs:bin_4bit_abs
			use entity work.bin_4bit_abs(logic);
		end for;
	end for;
end one;
