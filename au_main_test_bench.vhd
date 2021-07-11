library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity au_main_test_bench is
end au_main_test_bench;


architecture waveforms of au_main_test_bench is
	SIGNAL T_clk: std_ulogic := '0';
	SIGNAL T_reset: std_ulogic := '0';
	SIGNAL T_operandA: std_ulogic_vector (3 downto 0) := "1000";
	SIGNAL T_operandB: std_ulogic_vector (3 downto 0) := "1000";
	SIGNAL T_operation: std_ulogic_vector (1 downto 0) := "00";	-- "00" add, "01" sub, "10" multi, "11" div
	SIGNAL T_output: std_ulogic_vector (7 downto 0) := "00000000";
	SIGNAL T_operation_finished: std_ulogic := '0';
	SIGNAL T_division_by_zero: std_ulogic := '0';

	--sim
	constant PERIOD: time := 40 ns;

	COMPONENT au_main PORT (
		clk: in std_ulogic;
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

main: au_main PORT MAP(T_clk, T_reset, T_operandA, T_operandB, T_operation, T_output, T_operation_finished, T_division_by_zero);

--clock
T_clk <= NOT T_clk after PERIOD;

tester: process(T_operation_finished, T_clk)
variable tested_entries: integer := 0;
begin

--division requires special handeling with the reset signal
if(T_operation ="11") then
	if(falling_edge(T_clk) AND T_reset='1') then
		T_reset <= '0';
		T_operandA <= STD_ULOGIC_VECTOR(UNSIGNED(T_operandA) + 1);
		tested_entries := tested_entries + 1;
		if(tested_entries > 15) then
			T_operandB <= STD_ULOGIC_VECTOR(UNSIGNED(T_operandB) + 1);
			tested_entries := 0;
		end if;
	end if;

	if (T_operation_finished ='1' AND T_reset='0') then
		T_reset <= '1';
	end if;

elsif(T_operation="10") then
	if (rising_edge(T_clk)) then
		if  (T_reset = '1' ) then
			T_reset <= '0';
		end if;
		
	end if;
	if (rising_edge(T_clk) and T_reset = '0' AND T_operation_finished = '1') then 	
		T_reset <= '1';
		T_operandA <= STD_ULOGIC_VECTOR(UNSIGNED(T_operandA) + 1);
		if(T_operandA = "0111") then
			T_operandB <= STD_ULOGIC_VECTOR(UNSIGNED(T_operandB) + 1);
			if(T_operandB = "0111") then
				T_operation <= std_ulogic_vector(signed(T_operation) + 1);
			end if;
		end if; 
	end if;
else
	if(rising_edge(T_clk)) then
		T_operandA <= std_ulogic_vector(signed(T_operandA) + 1);
		if(T_operandA = "0111") then 
			T_operandB <= std_ulogic_vector(signed(T_operandB) + 1);
			T_operandA <= "1000";
		end if;
		if(T_operandB = "0111") then
			T_operation <= std_ulogic_vector(signed(T_operation) + 1);
			T_operandB <= "1000";
		end if;
	end if;

end if;

end process;

simfinish: process
begin
	wait until T_operandB="0111" AND T_operation="11";
    	assert false
      	report "simulation finished"
      	severity failure;
end process;

end waveforms;

configuration one of au_main_test_bench is
	for waveforms
		for main:au_main
			use entity work.au_main(logic);
		end for;
	end for;
end one;
