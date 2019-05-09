Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Control_Unit is 

port(
clock : in std_logic;
opcode: in std_logic_vector (4 downto 0);
INT: std_logic;
opcodeout: out std_logic_vector (4 downto 0);
ALU_Src,WB_En,ALU_En,Jmp,MemtoReg,MemWr,MemRd,Push_Sig,Pop_Sig, 
setc, clrc, not_op, inc, dec, multiply, h_type,type_out: out std_logic);

end entity;

Architecture arch1 of Control_Unit is
component mux4 is

port(in1,in2,in3,in4: in std_logic;
	s1,s0:in std_logic;
	c: out std_logic);

end component;
signal in1,in2,in3,in4,x,y,wb1: std_logic;
Signal jmp_en : std_logic;
begin


process(clock) 
begin
	if(rising_edge(clock)) then
		Jmp <= jmp_en;
	end if;
end process;
setc <= '1' when opcode = "11001" else '0';
clrc <= '1' when opcode = "11010" else '0';
not_op <= '1' when opcode = "11000" else '0';
inc <= '1' when opcode = "11100" else '0';
dec <= '1' when opcode = "11101" else '0'; 
multiply <= '1' when opcode = "10011" else '0';
h_type <= opcode(4) and not opcode(3);

opcodeout<=opcode;

x<= (not(opcode(3)) and opcode(0) and not(opcode(4)) and (opcode(2) xnor opcode(1)));
MemRd <= x or (not(opcode(4)) and opcode(3) and opcode(2) and opcode(1));
y<= (opcode(3) xnor opcode(2)) or (opcode(2) and (not opcode(3)));
MemWr <= '1' when opcode = "00000" or opcode = "00100" or opcode = "01100" else '0';

MemtoReg <= x;
ALU_En <= opcode(4) and not(opcode(4)and opcode(3) and opcode(1) and opcode(0) and not(opcode(2)));
--ALU_Src<=in1;
Jmp <= (opcode(3)and(not(opcode(4))));
Push_Sig <= '1' when opcode = "00000" or opcode = "01100" or INT = '1' else '0';
Pop_Sig <=(not(opcode(4)or opcode(3) or opcode(2) or opcode(1) or not(opcode(0))));

in1<= (not(opcode(1)))and( (opcode(2)and(not(opcode(0))))or((opcode(2) xnor opcode(0))));
in2<= (opcode(0)and((opcode(2)xor opcode(1))or(opcode(2)and opcode(1))));
in3<= (opcode(2)and((opcode(1)xnor opcode(0))or(opcode(1)and(not(opcode(0))))));
in4<= (not(opcode(2)or opcode(1)));

type_out <= not opcode(4) and not opcode(3) and opcode(2) and opcode(1) and not opcode(0);
m1: mux4 generic map(1) port map(in2,'0','1',in1,opcode(4),opcode(3),wb1);
WB_en <= wb1 or (not opcode(4) and not opcode(3) and not opcode(2) and not opcode(1) and opcode(0));


end Architecture;