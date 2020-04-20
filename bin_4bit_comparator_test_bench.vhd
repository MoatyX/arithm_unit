
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY bin_4bit_comparator_test_bench is
end ENTITY;

ARCHITECTURE waveforms of bin_4bit_comparator_test_bench is
	SIGNAL T_opA: std_ulogic_vector(3 downto 0) := "1000";
	SIGNAL T_opB: std_ulogic_vector(3 downto 0) := "1000";
	SIGNAL T_opType: std_ulogic_vector(2 downto 0) := "000";
	SIGNAL T_result: std_ulogic;
	COMPONENT bin_4bit_comparator
		port(	opA: in std_ulogic_vector(3 downto 0);
			opB: in std_ulogic_vector(3 downto 0);
			opType: in std_ulogic_vector(2 downto 0);	--"001" equal, "010" bigger than, "100" smaller than, "011" bigger equal, "101" smaller equal
			result: out std_ulogic	-- 0(fail) or 1(success)
		);
	end COMPONENT;
begin
	comp: bin_4bit_comparator PORT MAP(T_opA, T_opB, T_opType, T_result);
	comp_process: PROCESS
	begin	
		--loop Operation Type
		T_opType <= "001";
		for i in 0 to 1 loop
			-- loop operand B
			T_opB <= "1000";
			for j in 0 to 15 loop
				-- loop operand A
				T_opA <= "1000";
				for k in 0 to 15 loop
					wait for 40 ns;
					T_opA <= std_ulogic_vector(signed(T_opA) + 1);
				end loop;

			T_opB <= std_ulogic_vector(signed(T_opB) + 1);
			wait for 40 ns;
			end loop;

			T_opType <= std_ulogic_vector(unsigned(T_opType) + 1);
			wait for 40 ns;
		end loop;
	end PROCESS;

	finish_sim_time: process
	begin
    		wait for (16*40)*16*5 ns;
    		assert false
      		report "simulation finished"
      		severity failure;
  	end process finish_sim_time;

end waveforms;

configuration one of bin_4bit_comparator_test_bench is
	for waveforms
		for comp:bin_4bit_comparator
			use entity work.bin_4bit_comparator(logic);
		end for;
	end for;
end one;