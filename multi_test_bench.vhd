
library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
entity multi_test_bench is
end multi_test_bench;

architecture waveforms of multi_test_bench is
	signal T_rst : std_ulogic :='1';
	signal T_clk : std_ulogic :='0';
	signal T_Multi: std_ulogic :='0';
	signal T_once : std_ulogic :='0';
	signal	T_Operant1 : std_logic_vector(3 downto 0);
	signal	T_Operant2 : std_logic_vector(3 downto 0);
	signal	T_Result :std_logic_vector(7 downto 0);
	component multi
		port(rst,clk,Multi : in std_ulogic;
			Operant1 :in std_logic_vector(3 downto 0);
			Operant2 :in std_logic_vector(3 downto 0);
			Result :out std_logic_vector(7 downto 0)
			);
		end component;
	begin
	multi_inst: multi port map(T_rst,T_clk,T_Multi,T_Operant1,T_Operant2,T_Result);
	clock_gen: process
	begin
		T_clk<='1';
		wait for 20 ns;
		T_clk<='0';
		wait for 20 ns;
	end process clock_gen;
	Operant1_value: process
	begin 
		T_Operant1<="0000";
		wait for 40 ns;
		
		for I in 0 to 15 loop
			T_Operant1<=T_Operant1+'1';
			wait for 40 ns;
		end loop;
		end process Operant1_value;
	Operant2_value: process
	begin 
		T_Operant2<="1111";
		wait for 40 ns ;
		for I in 0 to 15 loop
			T_Operant2<=T_Operant2-'1';
			wait for 40 ns;
		end loop;
		end process Operant2_value;
	T_rst <='0',
		'1' after 10 ns;
	T_Multi<='1' ,
		'0' after 10 ns;
	T_once<='0';
end waveforms;
configuration one of multi_test_bench is
	for waveforms
		for multi_inst:multi
			use entity work.multi(Logic);
		end for;
	end for;
end one;