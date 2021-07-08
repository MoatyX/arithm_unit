library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity au_main_algorithm is
port( 	reset: in std_ulogic := '0';
	operandA: in std_ulogic_vector (3 downto 0);
	operandB: in std_ulogic_vector (3 downto 0);
	operation: in std_ulogic_vector (1 downto 0);	-- "00" add, "01" sub, "10" multi, "11" div
	output: out std_ulogic_vector (7 downto 0);
	operation_finished: out std_ulogic := '1';
	division_by_zero: out std_ulogic
);
end au_main_algorithm;

architecture algorithm of au_main_algorithm is
begin
process
variable div_zero: boolean := false;
begin
	-- if the reset flag is on, then set all outputs to 0, otherwise do caculations according to the operation type
	if (reset = '0') then
		case operation is
			when "00" => output <= std_ulogic_vector(resize(signed(operandA), output'length) + resize(signed(operandB), output'length));
			when "01" => output <= std_ulogic_vector(resize(signed(operandA), output'length) - resize(signed(operandB), output'length));
			when "10" => output <= std_ulogic_vector(signed(operandA) * signed(operandB));
			when "11" =>
				if operandB = "0000" then
					division_by_zero <= '1';
					div_zero := true;
					output <= "XXXXXXXX";
				else
					output <= std_ulogic_vector(resize(signed(operandA), output'length) / resize(signed(operandB), output'length));
				end if;
			when others => output <= "XXXXXXXX";
		end case;

		if div_zero then 
			division_by_zero <= '1';
		else
			division_by_zero <= '0';
		end if;

		operation_finished <= '1';		--flag the end of operation
		div_zero := false;
	else
		output <= "00000000";
		operation_finished <= '0';
		division_by_zero <= '0';
	end if;
	wait for 10 ns;
end process;
end algorithm;