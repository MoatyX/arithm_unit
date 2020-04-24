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

-- simulation signals
SIGNAL tested_entries: integer := 0;

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
tester: process(T_operation_finished)
begin

if(T_operation_finished='0' AND T_reset='1') then
	T_reset <= '0';
	T_dividend <= STD_ULOGIC_VECTOR(UNSIGNED(T_dividend) + 1);
end if; 

if (T_operation_finished ='1' AND T_reset='0') then
	T_reset <= '1';
end if;
end process;

end waveforms;

configuration one of bin_4bit_signed_divider_test_bench is
	for waveforms
		for divider:bin_4bit_signed_divider
			use entity work.bin_4bit_signed_divider(logic);
		end for;
	end for;
end one;
