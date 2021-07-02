library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_4bit_signed_divider_test_bench is
end bin_4bit_signed_divider_test_bench;

architecture waveforms of bin_4bit_signed_divider_test_bench is

--divider component signals
SIGNAL 	T_clk: std_ulogic := '0';
SIGNAL	T_reset: std_ulogic := '0';
SIGNAL	T_dividend: std_ulogic_vector (3 downto 0) := "1000";	--start with -8
SIGNAL	T_divisor: std_ulogic_vector (3 downto 0) := "1000";	--start with -8
SIGNAL	T_output: std_ulogic_vector (3 downto 0);
SIGNAL	T_division_by_zero: std_ulogic;
SIGNAL	T_operation_finished: std_ulogic;

--sim
constant PERIOD: time := 50 ns;

COMPONENT bin_4bit_signed_divider is
port(
	clk: in std_ulogic;
	reset: in std_ulogic := '0';
	dividend: in std_ulogic_vector (3 downto 0);
	divisor: in std_ulogic_vector (3 downto 0);
	output: out std_ulogic_vector (3 downto 0);
	division_by_zero: out std_ulogic;
	operation_finished: out std_ulogic
);
END COMPONENT;

begin

divider: bin_4bit_signed_divider PORT MAP(T_clk, T_reset, T_dividend, T_divisor, T_output, T_division_by_zero, T_operation_finished);

--clock
T_clk <= NOT T_clk after PERIOD;

tester: process(T_operation_finished, T_clk)
variable tested_entries: integer := 0;
variable wait_1_clk: boolean := false;
begin

--increment the input of the divider, and wait 1clk before setting T_reset to 0
--the divider does not see input change, when reset and input change on the flank
if(falling_edge(T_clk) AND T_reset='1' AND NOT wait_1_clk) then
	wait_1_clk := true;
	T_dividend <= STD_ULOGIC_VECTOR(UNSIGNED(T_dividend) + 1);
	tested_entries := tested_entries + 1;
	if(tested_entries > 15) then
		T_divisor <= STD_ULOGIC_VECTOR(UNSIGNED(T_divisor) + 1);
		tested_entries := 0;
	end if;
elsif(falling_edge(T_clk) AND T_reset='1' AND wait_1_clk) then
	T_reset <= '0';
	wait_1_clk := false;
end if;

if (T_operation_finished ='1' AND T_reset='0') then
	T_reset <= '1';
end if;
end process;

simfinish: process
begin
	wait until T_divisor="0111" AND T_dividend="0111" AND T_operation_finished='1';
    	assert false
      	report "simulation finished"
      	severity failure;
end process;

end waveforms;

configuration one of bin_4bit_signed_divider_test_bench is
	for waveforms
		for divider:bin_4bit_signed_divider
			use entity work.bin_4bit_signed_divider(logic);
		end for;
	end for;
end one;
