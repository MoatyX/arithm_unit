library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity au_main_algorithm_testbench is
end au_main_algorithm_testbench;

architecture waveforms of au_main_algorithm_testbench is
	SIGNAL T_reset: std_ulogic := '0';
	SIGNAL T_operandA: std_ulogic_vector (3 downto 0) := "1000";
	SIGNAL T_operandB: std_ulogic_vector (3 downto 0) := "1000";
	SIGNAL T_operation: std_ulogic_vector (1 downto 0) := "00";	-- "00" add, "01" sub, "10" multi, "11" div
	SIGNAL T_output: std_ulogic_vector (7 downto 0) := "00000000";
	SIGNAL T_operation_finished: std_ulogic := '0';
	SIGNAL T_division_by_zero: std_ulogic := '0';

	--sim
	constant PERIOD: time := 40 ns;

	COMPONENT au_main_algorithm PORT (
		reset: in std_ulogic := '0';
		operandA: in std_ulogic_vector (3 downto 0);
		operandB: in std_ulogic_vector (3 downto 0);
		operation: in std_ulogic_vector (1 downto 0);	-- "00" add, "01" sub, "10" multi, "11" div
		output: out std_ulogic_vector (7 downto 0);
		operation_finished: out std_ulogic;
		division_by_zero: out std_ulogic
	);
	END COMPONENT;
begin

main: au_main_algorithm PORT MAP(T_reset, T_operandA, T_operandB, T_operation, T_output, T_operation_finished, T_division_by_zero);

tester: process
begin
	for I in 0 to 15 loop
		T_operandA <= STD_ULOGIC_VECTOR(UNSIGNED(T_operandA) + 1);
		wait for PERIOD;
		for U in 0 to 15 loop
			T_operandB <= STD_ULOGIC_VECTOR(UNSIGNED(T_operandB) + 1);
			wait for PERIOD;
		end loop;
	end loop;

	T_operation <= STD_ULOGIC_VECTOR(UNSIGNED(T_operation) + 1);
	wait for PERIOD;
end process;

simfinish: process
begin
	wait until T_operandA="0111" AND T_operation="11";
    	assert false
      	report "simulation finished"
      	severity failure;
end process;

end waveforms;

configuration one of au_main_algorithm_testbench is
	for waveforms
		for main:au_main_algorithm
			use entity work.au_main_algorithm(logic);
		end for;
	end for;
end one;