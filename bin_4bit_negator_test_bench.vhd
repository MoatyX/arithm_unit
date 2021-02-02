
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_4bit_negator_test_bench is
end bin_4bit_negator_test_bench;

architecture waveforms of bin_4bit_negator_test_bench is
	SIGNAL T_input: std_ulogic_vector(3 downto 0) := "1000";	-- (-8)
	SIGNAL T_negator_output: std_ulogic_vector(3 downto 0);
	SIGNAL T_overflow: out std_ulogic;
	
	COMPONENT bin_4bit_negator
		port(	number: in std_ulogic_vector(3 downto 0);		--the input
		negatedNumber: out std_ulogic_vector (3 downto 0);	--the output
		overflow: out std_ulogic				--the overflow flag. happens at abs(-8) = -8
		);
	end COMPONENT;
begin
	bin_negator: bin_4bit_negator PORT MAP(T_input, T_negator_output, T_overflow);
	bin_negator_process: PROCESS
	begin
		T_input <= "1000";
		for i in 0 to 15 loop
			T_input <= std_ulogic_vector(signed(T_input) + 1);
			wait for 40 ns;
		end loop;
	end PROCESS;
end waveforms;

configuration one of bin_4bit_negator_test_bench is
	for waveforms
		for bin_negator:bin_4bit_negator
			use entity work.bin_4bit_negator(logic);
		end for;
	end for;
end one;
