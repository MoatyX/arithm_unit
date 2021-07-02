library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aaatb is
end aaatb;

architecture waveforms of aaatb is

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

if(rising_edge(T_clk) AND T_reset = '1') then
	wait_1_clk := true;
end if;

if(falling_edge(T_clk) AND T_reset='1') then
	if(wait_1_clk) then
		wait_1_clk := false;
	else
	T_reset <= '0';
	T_dividend <= STD_ULOGIC_VECTOR(UNSIGNED(T_dividend) + 1);
	tested_entries := tested_entries + 1;
	if(tested_entries > 7) then
		T_divisor <= STD_ULOGIC_VECTOR(UNSIGNED(T_divisor) + 1);
		tested_entries := 0;
	end if;
	end if;
end if;

if (T_operation_finished ='1' AND T_reset='0') then
	T_reset <= '1';
end if;
end process;

simfinish: process
begin
	wait until T_divisor="0111";
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
