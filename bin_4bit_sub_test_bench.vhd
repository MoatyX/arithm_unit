library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_sub_test_bench is
end bin_sub_test_bench;

architecture waveforms of bin_sub_test_bench is
	signal T_opA: unsigned(3 downto 0) := "0000";	--1st operand
        signal T_opB: unsigned(3 downto 0) := "0000";	--2nd operand
        signal T_result: std_ulogic_vector (3 downto 0);
        signal T_carry_in: std_ulogic := '0';
        signal T_carry_out: std_ulogic;
	signal T_overflow: std_ulogic;

	COMPONENT bin_4bit_subtractor

		PORT(
			opA: in std_ulogic_vector(3 downto 0);	--1st operand
			opB: in std_ulogic_vector(3 downto 0);	--2nd operand
			result: out std_ulogic_vector (3 downto 0);
			carry_in: in std_ulogic;
			carry_out: out std_ulogic;
			overflow: out std_ulogic
		);
	END component;	
begin
ba: bin_4bit_subtractor PORT MAP(std_ulogic_vector(T_opA), std_ulogic_vector(T_opB), T_result, T_carry_in, T_carry_out, T_overflow);
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
		wait for 15*40 ns;
		for I in 0 to 15 loop
			T_opB <= T_opB + 1;
			wait for 15*40 ns;
		end loop;
	end process;

	simTime: process
	begin
		wait for 15*40*15 ns;
    		assert false
      		report "simulation finished"
      		severity failure;
	end process;
end waveforms;

configuration one of bin_sub_test_bench is
	for waveforms
		for ba:bin_4bit_subtractor
	
			use entity work.bin_4bit_subtractor
		(logic);
		end for;
	end for;
end one;
