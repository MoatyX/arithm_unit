
library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


entity multi is 
	 port(Multi,rst,clk : in std_ulogic;
		Operant1 :in std_logic_vector(3 downto 0);
		Operant2 :in std_logic_vector(3 downto 0);
		Result	 :out std_logic_vector(7 downto 0); 
		seg0,seg1,seg2,seg3 :out std_ulogic_vector(6 downto 0));
end multi;
architecture Logic of multi is 
	signal once : std_ulogic;
begin 
Multiplizierer : process(clk)
variable pv,bp: std_logic_vector(7 downto 0);
begin
	pv:="00000000";
	bp:="0000"&Operant2;
	if(rising_edge(clk)) then 
		if rst='0' then 
				once<='0';
		elsif Multi='0' then
			if once='0' then 
				once<='1';
				for I in 0 to 3 loop
					if Operant1(i)='1' then 
						pv:=pv+bp;
					end if;
					bp:=bp(6 downto 0)&'0';
				end loop;
				
				once<='0';
				Result<=pv;
			end if;
		else 
			once<='0';
		end if;
			end if;
end process Multiplizierer;

end Logic;