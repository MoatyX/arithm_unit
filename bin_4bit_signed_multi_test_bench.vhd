library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity bin_4bit_signed_multi_test_bench is
end bin_4bit_signed_multi_test_bench;

architecture waveforms of bin_4bit_signed_multi_test_bench is
	signal T_reset : std_ulogic :='1';
	signal T_clk : std_ulogic :='0';
	
	signal	T_Operant1 : std_logic_vector(3 downto 0) := "1000";
	signal	T_Operant2 : std_logic_vector(3 downto 0) := "1000";
	signal	T_Result :std_logic_vector(7 downto 0);
	signal	T_operation_finished: std_ulogic := '0';
	component bin_4bit_signed_multi
		port(	clk, reset : in std_ulogic;
		op1 :in std_ulogic_vector(3 downto 0);
		op2 :in std_ulogic_vector(3 downto 0);
		Result	 :out std_logic_vector(7 downto 0);
		operation_finished: out std_ulogic := '0'
		);
		end component;
	begin
	multi_inst: bin_4bit_signed_multi port map(T_clk, T_reset, std_ulogic_vector(T_Operant1), std_ulogic_vector(T_Operant2), T_Result, T_operation_finished);

	clock_gen: process
	begin
		T_clk<='1';
		wait for 50 ns;
		T_clk<='0';
		wait for 50 ns;
	end process clock_gen;

	testing: process(T_clk)
	begin
	if (rising_edge(T_clk)) then
		if  (T_reset = '1' ) then
			T_reset <= '0';
		end if;
		
	end if;
	if (rising_edge(T_clk) and T_reset = '0' AND T_operation_finished = '1') then 	
		T_reset <= '1';
		T_Operant2 <= T_Operant2 + '1';
		if(T_Operant2 = "0111") then
			T_Operant1 <= T_Operant1 + '1';
		end if; 
	end if;
	end process testing;


simfinish: process
begin
	wait until T_Operant1 = "0111";
	wait until T_Operant2 = "0111";
    	assert false
      	report "simulation finished"
      	severity failure;
end process;

	end waveforms;
configuration one of bin_4bit_signed_multi_test_bench is
	for waveforms
		for multi_inst:bin_4bit_signed_multi
			use entity work.bin_4bit_signed_multi(Logic);
		end for;
	end for;
end one;