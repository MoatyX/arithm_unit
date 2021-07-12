library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity au_main is
port(
	clk: in std_ulogic;
	reset: in std_ulogic := '0';
	operandA: in std_ulogic_vector (3 downto 0);
	operandB: in std_ulogic_vector (3 downto 0);
	operation: in std_ulogic_vector (1 downto 0);	-- "00" add, "01" sub, "10" multi, "11" div
	output: out std_ulogic_vector (7 downto 0);
	operation_finished: out std_ulogic;
	division_by_zero: out std_ulogic;
	opA_sig, opB_sig , opA_sing_sig , opB_sing_sig: out std_logic_vector(6 downto 0) := "1000000";
	output_sign_sig, output_10_sig, output_1_sig: out std_logic_vector(6 downto 0) := "1000000"
);
end au_main;

architecture logic of au_main is

--8 bit adder
component bin_8bit_adder is
    port(
        opA: in std_ulogic_vector(7 downto 0);	--1st operand
        opB: in std_ulogic_vector(7 downto 0);	--2nd operand
        result: out std_ulogic_vector (7 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic;
	overflow: out std_logic
    );
end component;

component bin_4bit_signed_multi is 
	 port(	clk,reset : in std_ulogic;
		op1 :in std_ulogic_vector(3 downto 0);
		op2 :in std_ulogic_vector(3 downto 0);
		Result	 :out std_logic_vector(7 downto 0);
		operation_finished: out std_ulogic
		);
end component;

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

component bin_8bit_subtractor is
    port(
        opA: in std_ulogic_vector(7 downto 0);	--1st operand
        opB: in std_ulogic_vector(7 downto 0);	--2nd operand
        result: out std_ulogic_vector (7 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic;
	overflow: out std_ulogic
    );
end component;

-- Signals and variables
signal opA, opB: std_ulogic_vector(7 downto 0);
signal sub_output: std_ulogic_vector (7 downto 0);
signal add_output: std_ulogic_vector (7 downto 0);
signal div_output: std_ulogic_vector (3 downto 0);
signal multi_output: std_logic_vector (7 downto 0);
signal multi_operation_finished: std_ulogic;
signal div_operation_finished: std_ulogic;

signal adder_overflowed, subber_overflowed: std_ulogic;

signal output_sigment : std_ulogic_vector (7 downto 0);
--

begin

opA <= std_ulogic_vector(resize(signed(operandA), opA'length));
opB <= std_ulogic_vector(resize(signed(operandB), opB'length));

divider: bin_4bit_signed_divider PORT MAP(clk, reset, operandA, operandB, div_output, division_by_zero, div_operation_finished);
multiplier: bin_4bit_signed_multi PORT MAP(clk, reset, operandA, operandB, multi_output, multi_operation_finished);
adder: bin_8bit_adder PORT MAP(opA, opB, add_output, '0', OPEN, adder_overflowed);
subtractor: bin_8bit_subtractor PORT MAP(opA, opB, sub_output, '0', OPEN, subber_overflowed);

--map the final output based on the operation
output_sigment <= std_ulogic_vector(add_output)when operation = "00" else 
	 std_ulogic_vector(sub_output) when operation = "01" else
	 std_ulogic_vector(multi_output) when operation = "10" else 
	 std_ulogic_vector(resize(signed(div_output), output'length)) when operation = "11";
 output <= output_sigment;

operation_finished <= div_operation_finished when operation = "11" else
		      multi_operation_finished when operation = "10" else '1';

operA_sig: process(operandA)
begin
case operandA is
when "1000" => opA_sig <= "0000000";	opA_sing_sig <= "0111111" ;--(-8)
when "1001" => opA_sig <= "0000111";	opA_sing_sig <= "0111111" ;--(-7)
when "1010" => opA_sig <= "0000010";	opA_sing_sig <= "0111111" ;--(-6)
when "1011" => opA_sig <= "0010010";	opA_sing_sig <= "0111111" ;--(-5)
when "1100" => opA_sig <= "0011001";	opA_sing_sig <= "0111111" ;--(-4)
when "1101" => opA_sig <= "1110000";	opA_sing_sig <= "0111111" ;--(-3)
when "1110" => opA_sig <= "0100100";	opA_sing_sig <= "0111111" ;--(-2)
when "1111" => opA_sig <= "1111001";	opA_sing_sig <= "0111111" ;--(-1)
when "0000" => opA_sig <= "1000000";	opA_sing_sig <= "1111111" ;--0 positive 
when "0001" => opA_sig <= "1111001";	opA_sing_sig <= "1111111" ;--1
when "0010" => opA_sig <= "0100100";	opA_sing_sig <= "1111111" ;--2
when "0011" => opA_sig <= "1110000";	opA_sing_sig <= "1111111" ;--3
when "0100" => opA_sig <= "0011001";	opA_sing_sig <= "1111111" ;--4
when "0101" => opA_sig <= "0010010";	opA_sing_sig <= "1111111" ;--5
when "0110" => opA_sig <= "0000010";	opA_sing_sig <= "1111111" ;--6
when "0111" => opA_sig <= "0000111";	opA_sing_sig <= "1111111" ;--7
when others => opA_sig <= "1111111";	opA_sing_sig <= "1111111" ;--none
end case;
end process operA_sig;




operB_sig: process(operandB)
begin
case operandB is
when "1000" => opB_sig <= "0000000";	opB_sing_sig <= "0111111" ; --(-8)
when "1001" => opB_sig <= "0000111";	opB_sing_sig <= "0111111" ;--(-7)
when "1010" => opB_sig <= "0000010";	opB_sing_sig <= "0111111" ;--(-6)
when "1011" => opB_sig <= "0010010";	opB_sing_sig <= "0111111" ;--(-5)
when "1100" => opB_sig <= "0011001";	opB_sing_sig <= "0111111" ;--(-4)
when "1101" => opB_sig <= "1110000";	opB_sing_sig <= "0111111" ;--(-3)
when "1110" => opB_sig <= "0100100";	opB_sing_sig <= "0111111" ;--(-2)
when "1111" => opB_sig <= "1111001";	opB_sing_sig <= "0111111" ;--(-1)
when "0000" => opB_sig <= "1000000";	opB_sing_sig <= "1111111" ;--0 positive 
when "0001" => opB_sig <= "1111001";	opB_sing_sig <= "1111111" ;--1
when "0010" => opB_sig <= "0100100";	opB_sing_sig <= "1111111" ;--2
when "0011" => opB_sig <= "1110000";	opB_sing_sig <= "1111111" ;--3
when "0100" => opB_sig <= "0011001";	opB_sing_sig <= "1111111" ;--4
when "0101" => opB_sig <= "0010010";	opB_sing_sig <= "1111111" ;--5
when "0110" => opB_sig <= "0000010";	opB_sing_sig <= "1111111" ;--6
when "0111" => opB_sig <= "0000111";	opB_sing_sig <= "1111111" ;--7
when others => opB_sig <= "1111111";	opB_sing_sig <= "1111111" ;--none
end case;
end process operB_sig;

output_sig: process(output_sigment)
begin
case output_sigment is
when "11000000" => output_10_sig <= "0000010";  output_1_sig <= "0011001";  output_sign_sig <= "0111111"; --(-64)
when "11000001" => output_10_sig <= "0000010";  output_1_sig <= "1110000";  output_sign_sig <= "0111111"; --(-63)
when "11000010" => output_10_sig <= "0000010";  output_1_sig <= "0100100";  output_sign_sig <= "0111111"; --(-62)
when "11000011" => output_10_sig <= "0000010";  output_1_sig <= "1111001";  output_sign_sig <= "0111111"; --(-61)
when "11000100" => output_10_sig <= "0000010";  output_1_sig <= "1000000";  output_sign_sig <= "0111111"; --(-60)
when "11000101" => output_10_sig <= "0010010";  output_1_sig <= "0010000";  output_sign_sig <= "0111111"; --(-59)
when "11000110" => output_10_sig <= "0010010";  output_1_sig <= "0000000";  output_sign_sig <= "0111111"; --(-58)
when "11000111" => output_10_sig <= "0010010";  output_1_sig <= "0000111";  output_sign_sig <= "0111111"; --(-57)
when "11001000" => output_10_sig <= "0010010";  output_1_sig <= "0000010";  output_sign_sig <= "0111111"; --(-56)
when "11001001" => output_10_sig <= "0010010";  output_1_sig <= "0010010";  output_sign_sig <= "0111111"; --(-55)
when "11001010" => output_10_sig <= "0010010";  output_1_sig <= "0011001";  output_sign_sig <= "0111111"; --(-54)
when "11001011" => output_10_sig <= "0010010";  output_1_sig <= "1110000";  output_sign_sig <= "0111111"; --(-53)
when "11001100" => output_10_sig <= "0010010";  output_1_sig <= "0100100";  output_sign_sig <= "0111111"; --(-52)
when "11001101" => output_10_sig <= "0010010";  output_1_sig <= "1111001";  output_sign_sig <= "0111111"; --(-51)
when "11001110" => output_10_sig <= "0010010";  output_1_sig <= "1000000";  output_sign_sig <= "0111111"; --(-50)
when "11001111" => output_10_sig <= "0011001";  output_1_sig <= "0010000";  output_sign_sig <= "0111111"; --(-49)
when "11010000" => output_10_sig <= "0011001";  output_1_sig <= "0000000";  output_sign_sig <= "0111111"; --(-48)
when "11010001" => output_10_sig <= "0011001";  output_1_sig <= "0000111";  output_sign_sig <= "0111111"; --(-47)
when "11010010" => output_10_sig <= "0011001";  output_1_sig <= "0000010";  output_sign_sig <= "0111111"; --(-46)
when "11010011" => output_10_sig <= "0011001";  output_1_sig <= "0010010";  output_sign_sig <= "0111111"; --(-45)
when "11010100" => output_10_sig <= "0011001";  output_1_sig <= "0011001";  output_sign_sig <= "0111111"; --(-44)
when "11010101" => output_10_sig <= "0011001";  output_1_sig <= "1110000";  output_sign_sig <= "0111111"; --(-43)
when "11010110" => output_10_sig <= "0011001";  output_1_sig <= "0100100";  output_sign_sig <= "0111111"; --(-42)
when "11010111" => output_10_sig <= "0011001";  output_1_sig <= "1111001";  output_sign_sig <= "0111111"; --(-41)
when "11011000" => output_10_sig <= "0011001";  output_1_sig <= "1000000";  output_sign_sig <= "0111111"; --(-40)
when "11011001" => output_10_sig <= "1110000";  output_1_sig <= "0010000";  output_sign_sig <= "0111111"; --(-39)
when "11011010" => output_10_sig <= "1110000";  output_1_sig <= "0000000";  output_sign_sig <= "0111111"; --(-38)
when "11011011" => output_10_sig <= "1110000";  output_1_sig <= "0000111";  output_sign_sig <= "0111111"; --(-37)
when "11011100" => output_10_sig <= "1110000";  output_1_sig <= "0000010";  output_sign_sig <= "0111111"; --(-36)
when "11011101" => output_10_sig <= "1110000";  output_1_sig <= "0010010";  output_sign_sig <= "0111111"; --(-35)
when "11011110" => output_10_sig <= "1110000";  output_1_sig <= "0011001";  output_sign_sig <= "0111111"; --(-34)
when "11011111" => output_10_sig <= "1110000";  output_1_sig <= "1110000";  output_sign_sig <= "0111111"; --(-33)
when "11100000" => output_10_sig <= "1110000";  output_1_sig <= "0100100";  output_sign_sig <= "0111111"; --(-32)
when "11100001" => output_10_sig <= "1110000";  output_1_sig <= "1111001";  output_sign_sig <= "0111111"; --(-31)
when "11100010" => output_10_sig <= "1110000";  output_1_sig <= "1000000";  output_sign_sig <= "0111111"; --(-30)
when "11100011" => output_10_sig <= "0100100";  output_1_sig <= "0010000";  output_sign_sig <= "0111111"; --(-29)
when "11100100" => output_10_sig <= "0100100";  output_1_sig <= "0000000";  output_sign_sig <= "0111111"; --(-28)
when "11100101" => output_10_sig <= "0100100";  output_1_sig <= "0000111";  output_sign_sig <= "0111111"; --(-27)
when "11100110" => output_10_sig <= "0100100";  output_1_sig <= "0000010";  output_sign_sig <= "0111111"; --(-26)
when "11100111" => output_10_sig <= "0100100";  output_1_sig <= "0010010";  output_sign_sig <= "0111111"; --(-25)
when "11101000" => output_10_sig <= "0100100";  output_1_sig <= "0011001";  output_sign_sig <= "0111111"; --(-24)
when "11101001" => output_10_sig <= "0100100";  output_1_sig <= "1110000";  output_sign_sig <= "0111111"; --(-23)
when "11101010" => output_10_sig <= "0100100";  output_1_sig <= "0100100";  output_sign_sig <= "0111111"; --(-22)
when "11101011" => output_10_sig <= "0100100";  output_1_sig <= "1111001";  output_sign_sig <= "0111111"; --(-21)
when "11101100" => output_10_sig <= "0100100";  output_1_sig <= "1000000";  output_sign_sig <= "0111111"; --(-20)
when "11101101" => output_10_sig <= "1111001";  output_1_sig <= "0010000";  output_sign_sig <= "0111111"; --(-19)
when "11101110" => output_10_sig <= "1111001";  output_1_sig <= "0000000";  output_sign_sig <= "0111111"; --(-18)
when "11101111" => output_10_sig <= "1111001";  output_1_sig <= "0000111";  output_sign_sig <= "0111111"; --(-17)
when "11110000" => output_10_sig <= "1111001";  output_1_sig <= "0000010";  output_sign_sig <= "0111111"; --(-16)
when "11110001" => output_10_sig <= "1111001";  output_1_sig <= "0010010";  output_sign_sig <= "0111111"; --(-15)
when "11110010" => output_10_sig <= "1111001";  output_1_sig <= "0011001";  output_sign_sig <= "0111111"; --(-14)
when "11110011" => output_10_sig <= "1111001";  output_1_sig <= "1110000";  output_sign_sig <= "0111111"; --(-13)
when "11110100" => output_10_sig <= "1111001";  output_1_sig <= "0100100";  output_sign_sig <= "0111111"; --(-12)
when "11110101" => output_10_sig <= "1111001";  output_1_sig <= "1111001";  output_sign_sig <= "0111111"; --(-11)
when "11110110" => output_10_sig <= "1111001";  output_1_sig <= "1000000";  output_sign_sig <= "0111111"; --(-10)
when "11110111" => output_10_sig <= "0111111";  output_1_sig <= "0010000";  output_sign_sig <= "0111111"; --(-9)
when "11111000" => output_10_sig <= "0111111";  output_1_sig <= "0000000";  output_sign_sig <= "0111111"; --(-8)
when "11111001" => output_10_sig <= "0111111";  output_1_sig <= "0000111";  output_sign_sig <= "0111111"; --(-7)
when "11111010" => output_10_sig <= "0111111";  output_1_sig <= "0000010";  output_sign_sig <= "0111111"; --(-6)
when "11111011" => output_10_sig <= "0111111";  output_1_sig <= "0010010";  output_sign_sig <= "0111111"; --(-5)
when "11111100" => output_10_sig <= "0111111";  output_1_sig <= "0011001";  output_sign_sig <= "0111111"; --(-4)
when "11111101" => output_10_sig <= "0111111";  output_1_sig <= "1110000";  output_sign_sig <= "0111111"; --(-3)
when "11111110" => output_10_sig <= "0111111";  output_1_sig <= "0100100";  output_sign_sig <= "0111111"; --(-2)
when "11111111" => output_10_sig <= "0111111";  output_1_sig <= "1111001";  output_sign_sig <= "0111111"; --(-1)
when "00000000" => output_10_sig <= "1000000";  output_1_sig <= "1000000";  output_sign_sig <= "0000000"; --(0)
when "00000001" => output_10_sig <= "1000000";  output_1_sig <= "1111001";  output_sign_sig <= "0000000"; --(1)
when "00000010" => output_10_sig <= "1000000";  output_1_sig <= "0100100";  output_sign_sig <= "0000000"; --(2)
when "00000011" => output_10_sig <= "1000000";  output_1_sig <= "1110000";  output_sign_sig <= "0000000"; --(3)
when "00000100" => output_10_sig <= "1000000";  output_1_sig <= "0011001";  output_sign_sig <= "0000000"; --(4)
when "00000101" => output_10_sig <= "1000000";  output_1_sig <= "0010010";  output_sign_sig <= "0000000"; --(5)
when "00000110" => output_10_sig <= "1000000";  output_1_sig <= "0000010";  output_sign_sig <= "0000000"; --(6)
when "00000111" => output_10_sig <= "1000000";  output_1_sig <= "0000111";  output_sign_sig <= "0000000"; --(7)
when "00001000" => output_10_sig <= "1000000";  output_1_sig <= "0000000";  output_sign_sig <= "0000000"; --(8)
when "00001001" => output_10_sig <= "1000000";  output_1_sig <= "0010000";  output_sign_sig <= "0000000"; --(9)
when "00001010" => output_10_sig <= "1111001";  output_1_sig <= "1000000";  output_sign_sig <= "0000000"; --(10)
when "00001011" => output_10_sig <= "1111001";  output_1_sig <= "1111001";  output_sign_sig <= "0000000"; --(11)
when "00001100" => output_10_sig <= "1111001";  output_1_sig <= "0100100";  output_sign_sig <= "0000000"; --(12)
when "00001101" => output_10_sig <= "1111001";  output_1_sig <= "1110000";  output_sign_sig <= "0000000"; --(13)
when "00001110" => output_10_sig <= "1111001";  output_1_sig <= "0011001";  output_sign_sig <= "0000000"; --(14)
when "00001111" => output_10_sig <= "1111001";  output_1_sig <= "0010010";  output_sign_sig <= "0000000"; --(15)
when "00010000" => output_10_sig <= "1111001";  output_1_sig <= "0000010";  output_sign_sig <= "0000000"; --(16)
when "00010001" => output_10_sig <= "1111001";  output_1_sig <= "0000111";  output_sign_sig <= "0000000"; --(17)
when "00010010" => output_10_sig <= "1111001";  output_1_sig <= "0000000";  output_sign_sig <= "0000000"; --(18)
when "00010011" => output_10_sig <= "1111001";  output_1_sig <= "0010000";  output_sign_sig <= "0000000"; --(19)
when "00010100" => output_10_sig <= "0100100";  output_1_sig <= "1000000";  output_sign_sig <= "0000000"; --(20)
when "00010101" => output_10_sig <= "0100100";  output_1_sig <= "1111001";  output_sign_sig <= "0000000"; --(21)
when "00010110" => output_10_sig <= "0100100";  output_1_sig <= "0100100";  output_sign_sig <= "0000000"; --(22)
when "00010111" => output_10_sig <= "0100100";  output_1_sig <= "1110000";  output_sign_sig <= "0000000"; --(23)
when "00011000" => output_10_sig <= "0100100";  output_1_sig <= "0011001";  output_sign_sig <= "0000000"; --(24)
when "00011001" => output_10_sig <= "0100100";  output_1_sig <= "0010010";  output_sign_sig <= "0000000"; --(25)
when "00011010" => output_10_sig <= "0100100";  output_1_sig <= "0000010";  output_sign_sig <= "0000000"; --(26)
when "00011011" => output_10_sig <= "0100100";  output_1_sig <= "0000111";  output_sign_sig <= "0000000"; --(27)
when "00011100" => output_10_sig <= "0100100";  output_1_sig <= "0000000";  output_sign_sig <= "0000000"; --(28)
when "00011101" => output_10_sig <= "0100100";  output_1_sig <= "0010000";  output_sign_sig <= "0000000"; --(29)
when "00011110" => output_10_sig <= "1110000";  output_1_sig <= "1000000";  output_sign_sig <= "0000000"; --(30)
when "00011111" => output_10_sig <= "1110000";  output_1_sig <= "1111001";  output_sign_sig <= "0000000"; --(31)
when "00100000" => output_10_sig <= "1110000";  output_1_sig <= "0100100";  output_sign_sig <= "0000000"; --(32)
when "00100001" => output_10_sig <= "1110000";  output_1_sig <= "1110000";  output_sign_sig <= "0000000"; --(33)
when "00100010" => output_10_sig <= "1110000";  output_1_sig <= "0011001";  output_sign_sig <= "0000000"; --(34)
when "00100011" => output_10_sig <= "1110000";  output_1_sig <= "0010010";  output_sign_sig <= "0000000"; --(35)
when "00100100" => output_10_sig <= "1110000";  output_1_sig <= "0000010";  output_sign_sig <= "0000000"; --(36)
when "00100101" => output_10_sig <= "1110000";  output_1_sig <= "0000111";  output_sign_sig <= "0000000"; --(37)
when "00100110" => output_10_sig <= "1110000";  output_1_sig <= "0000000";  output_sign_sig <= "0000000"; --(38)
when "00100111" => output_10_sig <= "1110000";  output_1_sig <= "0010000";  output_sign_sig <= "0000000"; --(39)
when "00101000" => output_10_sig <= "0011001";  output_1_sig <= "1000000";  output_sign_sig <= "0000000"; --(40)
when "00101001" => output_10_sig <= "0011001";  output_1_sig <= "1111001";  output_sign_sig <= "0000000"; --(41)
when "00101010" => output_10_sig <= "0011001";  output_1_sig <= "0100100";  output_sign_sig <= "0000000"; --(42)
when "00101011" => output_10_sig <= "0011001";  output_1_sig <= "1110000";  output_sign_sig <= "0000000"; --(43)
when "00101100" => output_10_sig <= "0011001";  output_1_sig <= "0011001";  output_sign_sig <= "0000000"; --(44)
when "00101101" => output_10_sig <= "0011001";  output_1_sig <= "0010010";  output_sign_sig <= "0000000"; --(45)
when "00101110" => output_10_sig <= "0011001";  output_1_sig <= "0000010";  output_sign_sig <= "0000000"; --(46)
when "00101111" => output_10_sig <= "0011001";  output_1_sig <= "0000111";  output_sign_sig <= "0000000"; --(47)
when "00110000" => output_10_sig <= "0011001";  output_1_sig <= "0000000";  output_sign_sig <= "0000000"; --(48)
when "00110001" => output_10_sig <= "0011001";  output_1_sig <= "0010000";  output_sign_sig <= "0000000"; --(49)
when "00110010" => output_10_sig <= "0010010";  output_1_sig <= "1000000";  output_sign_sig <= "0000000"; --(50)
when "00110011" => output_10_sig <= "0010010";  output_1_sig <= "1111001";  output_sign_sig <= "0000000"; --(51)
when "00110100" => output_10_sig <= "0010010";  output_1_sig <= "0100100";  output_sign_sig <= "0000000"; --(52)
when "00110101" => output_10_sig <= "0010010";  output_1_sig <= "1110000";  output_sign_sig <= "0000000"; --(53)
when "00110110" => output_10_sig <= "0010010";  output_1_sig <= "0011001";  output_sign_sig <= "0000000"; --(54)
when "00110111" => output_10_sig <= "0010010";  output_1_sig <= "0010010";  output_sign_sig <= "0000000"; --(55)
when "00111000" => output_10_sig <= "0010010";  output_1_sig <= "0000010";  output_sign_sig <= "0000000"; --(56)
when "00111001" => output_10_sig <= "0010010";  output_1_sig <= "0000111";  output_sign_sig <= "0000000"; --(57)
when "00111010" => output_10_sig <= "0010010";  output_1_sig <= "0000000";  output_sign_sig <= "0000000"; --(58)
when "00111011" => output_10_sig <= "0010010";  output_1_sig <= "0010000";  output_sign_sig <= "0000000"; --(59)
when "00111100" => output_10_sig <= "0000010";  output_1_sig <= "1000000";  output_sign_sig <= "0000000"; --(60)
when "00111101" => output_10_sig <= "0000010";  output_1_sig <= "1111001";  output_sign_sig <= "0000000"; --(61)
when "00111110" => output_10_sig <= "0000010";  output_1_sig <= "0100100";  output_sign_sig <= "0000000"; --(62)
when "00111111" => output_10_sig <= "0000010";  output_1_sig <= "1110000";  output_sign_sig <= "0000000"; --(63)
when "01000000" => output_10_sig <= "0000010";  output_1_sig <= "0011001";  output_sign_sig <= "0000000"; --(64)
when others => output_10_sig <= "0000000";	output_1_sig <= "0000000" ;  output_sign_sig <= "0000000";--none
end case;
end process output_sig;



end logic; 
