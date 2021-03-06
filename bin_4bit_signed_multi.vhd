library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.std_logic_unsigned.all;
--USE ieee.numeric_std.ALL;
--library std;

-- summary: multiplies 2 4bit numbers

entity bin_4bit_signed_multi is 
	 port(	clk : in std_ulogic;
		reset : in std_ulogic := '0';
		op1 :in std_ulogic_vector(3 downto 0) := "0000";
		op2 :in std_ulogic_vector(3 downto 0) := "0000";
		Result	 :out std_logic_vector(7 downto 0);
		operation_finished: out std_ulogic := '0'	
		);
end bin_4bit_signed_multi;

architecture Logic of bin_4bit_signed_multi is
	
	
	
COMPONENT bin_4bit_abs is
PORT(	input: in std_ulogic_vector(3 downto 0);
	abs_output: out std_ulogic_vector(3 downto 0);
	overflow: out std_ulogic	--happens only when asked for the abs of the min number in 2' complement (in our case, at -8)
);
END COMPONENT;

COMPONENT bin_4bit_comparator is
port(	opA: in std_ulogic_vector(3 downto 0);
	opB: in std_ulogic_vector(3 downto 0);
	opType: in std_ulogic_vector(2 downto 0);	--"001" equal, "010" bigger than, "100" smaller than, "011" bigger equal, "101" smaller equal
	result: out std_ulogic	-- 0(fail) or 1(success)
);
end COMPONENT;

COMPONENT bin_8bit_negator is
port(	number: in std_ulogic_vector(7 downto 0);		--the input
	negatedNumber: out std_ulogic_vector (7 downto 0);	--the output
	overflow: out std_ulogic				--the overflow flag. happens at abs(-8) = -8
);
end COMPONENT;
	signal pv_temp:		std_ulogic_vector(7 downto 0);
	signal pb_temp:		std_ulogic_vector(7 downto 0) :="00000000";
	signal out_temp:	std_ulogic_vector(7 downto 0) :="00000000";
COMPONENT bin_8bit_adder is
    port(
        opA: in std_ulogic_vector(7 downto 0);	--1st operand
        opB: in std_ulogic_vector(7 downto 0);	--2nd operand
        result: out std_ulogic_vector (7 downto 0);
        carry_in: in std_ulogic;
        carry_out: out std_ulogic;
	overflow: out std_ulogic
    );
end COMPONENT;
SIGNAL abs_op1, abs_op2: std_ulogic_vector(3 downto 0);
SIGNAL abs_op1_overflow, abs_op2_overflow: std_ulogic;
SIGNAL op1_is_pos, op2_is_pos: std_ulogic;
SIGNAL finish :std_ulogic :='0' ;
Signal tmp_output :std_logic_vector(7 downto 0);
SIGNAL negated_tmp_output :std_ulogic_vector(7 downto 0);
SIGNAL output_is_negative: std_ulogic;

SIGNAL delay : integer :=0 ;	-- variable will be counted up by every iteration to know if the addition loop has been finished
SIGNAL started : std_ulogic :='0'; -- will be set after setting the counter otherwise (pv and pb ) will be resetd every iteration 
begin

-- abs
op1_abs: bin_4bit_abs PORT MAP(op1, abs_op1, abs_op1_overflow);
op2_abs: bin_4bit_abs PORT MAP(op2, abs_op2, abs_op2_overflow);

-- comparators
op1_is_pos_comp: bin_4bit_comparator PORT MAP(op1, "0000", "011", op1_is_pos);
op2_is_pos_comp: bin_4bit_comparator PORT MAP(op2, "0000", "011", op2_is_pos);

output_negator: bin_8bit_negator PORT MAP(std_ulogic_vector(tmp_output), negated_tmp_output, OPEN);
output_is_negative <= (NOT op1_is_pos OR abs_op1_overflow) XOR (NOT op2_is_pos OR abs_op2_overflow);
	
multi : bin_8bit_adder PORT MAP (pv_temp , pb_temp, out_temp, '0',open,open);

operation_finished <= finish;

Multiplizierer : process(clk,delay,started)
variable pv: std_ulogic_vector(7 downto 0);
variable bp: std_logic_vector(7 downto 0);
variable counter: integer :=-1; -- otherwise on strat will counter and delay have the same value that will cause to set finish to 1
begin
if(rising_edge(clk))then
counter := To_integer(unsigned(abs_op1));
end if;
if reset='1' then
	finish <= '0';
	started <= '0';
	pv := "00000000";
	bp := "00000000" ;
	pv_temp <= "00000000";
	pb_temp <= "00000000";
	tmp_output<= "00000000";
	counter := To_integer(unsigned(abs_op1));
	if (rising_edge(clk)) then 
	end if;
else  
	if( started = '0') then -- to not reset the the variable evry time the process called 
		pv := "00000000";
		bp :="0000"&std_logic_vector(abs_op2);
	end if;
	if(rising_edge(clk) )then --suspends the process until the change occurs on the signal
		started <= '1';
	end if;
	if((abs_op1 = "0000" or abs_op2 = "0000") and rising_edge(clk) ) then
		finish <= '1';
	pv_temp <= "00000000";
	pb_temp <= "00000000";
		tmp_output<="00000000";
		started <= '0';
	end if;
		pv_temp <= std_ulogic_vector(pv);
		pb_temp <= std_ulogic_vector(bp);

		if(rising_edge(clk) )then 
		end if;
		if((delay = counter) and (started = '1'))then
			finish <= '1';
			tmp_output<=std_logic_vector(out_temp);
			started <= '0';
		else 
			pv := std_ulogic_vector(out_temp);
		end if;
end if;

end process;

resetProcess: process(reset)
begin
	if reset='1' then
		--finish <= '0';
	else
	end if;
end process;
delayProcess: process(clk,delay,reset)
begin
if (rising_edge(clk)) then 
if reset = '1' then 
	delay <= 0;
else 
case delay is
	when (-1) => delay <=0 ;
	when 0 => delay <= 1;
	when 1 => delay <= 2;
	when 2 => delay <= 3;
	when 3 => delay <= 4;
	when 4 => delay <= 5;
	when 5 => delay <= 6;
	when 6 => delay <= 7;
	when 7 => delay <= 8;
	when 8 => delay <= 0;
	when others => delay <=0;
	end case;
end if;
end if ;
--wait until rising_edge(clk);
end process;
EndCal:process(finish, negated_tmp_output, tmp_output, reset)
begin
if finish='1' then
	if(output_is_negative='1') then
		Result <= std_logic_vector(negated_tmp_output);
	else
		Result <= std_logic_vector(tmp_output);
	end if;
end if;
end process;
end Logic;