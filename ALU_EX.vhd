Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity ArithmeticLogicUnit is
port(
    alu_enable : in std_logic;
    clock : in std_logic;
    reset : in std_logic;
	setc, clrc, inc, dec, not_op, h_type: in std_logic;
    operation: in std_logic_vector(2 downto 0);
    src : in std_logic_vector(15 downto 0);
    dest : in std_logic_vector(15 downto 0);
    shift_amount : in std_logic_vector(3 downto 0);
    output : out std_logic_vector(31 downto 0);
    flags : out std_logic_vector(2 downto 0)

);
end entity;

Architecture behavioral of ArithmeticLogicUnit is


signal h_result, x_result, result, destination, source :std_logic_vector(31 downto 0);
signal carry,zero,negative: std_logic;
signal one, zero_val: std_logic_vector(31 downto 0);
signal mul, add, sub, shl, shr, orr, andd, mov: std_logic_vector(31 downto 0);
signal inc_val, dec_val, not_val: std_logic_vector(31 downto 0);
signal x_decision: std_logic_vector(2 downto 0);
signal oup: std_logic_vector(31 downto 0);
signal shiftRightCarry: std_logic;


begin


process(clock) begin
	if(rising_edge(clock)) then
		output <= oup;
		
 	end if;
	if (shift_amount = "0000") then
		shiftRightCarry<='0';
	else 
		shiftRightCarry<= destination(to_integer(unsigned(shift_amount))-1);
	end if;
 end process;

zero_val <= X"00000000";
one <= X"00000001";

destination<="0000000000000000"&dest;
source <="0000000000000000"&src;

inc_val <= std_logic_vector(to_unsigned(to_integer(unsigned(destination) + unsigned(one)),32));
dec_val <= std_logic_vector(to_unsigned(to_integer(unsigned(destination) - unsigned(one)),32));
not_val <= not destination;

mov <= destination;
add <= std_logic_vector(to_unsigned(to_integer(unsigned(source)+unsigned(destination)),32));
sub <= std_logic_vector(to_unsigned(to_integer(unsigned(destination)-unsigned(source)),32));
mul <= std_logic_vector(to_unsigned(to_integer(unsigned(source)*unsigned(destination)),32));
andd <= std_logic_vector(to_unsigned(to_integer(unsigned(source) and unsigned(destination)),32));
orr <= std_logic_vector(to_unsigned(to_integer(unsigned(source) or unsigned(destination)),32));


--shiftRightCarry <= '0' when shift_amount = "0000" else
--		destination(to_integer(unsigned(shift_amount))-1);


shr <= std_logic_vector(to_signed(to_integer(unsigned(destination)) / (2**to_integer(unsigned(shift_amount))),32));
shl <= std_logic_vector(to_signed(to_integer(unsigned(destination)) * (2**to_integer(unsigned(shift_amount))),32));


x_decision <= inc & dec & not_op;
mOp_h: entity work.mux8x1 generic map(32) port map(mov, add, sub, mul, andd, orr, shl, shr, operation, h_result);
mOp_x: entity work.mux8x1 generic map(32) port map(inc_val, not_val, dec_val, zero_val, inc_val, zero_val, zero_val, zero_val, x_decision, x_result);
selOp: entity work.mux2x1 generic map(32) port map(x_result, h_result, h_type, result);
sense_output: entity work.mux2x1 generic map(32) port map(zero_val, result, alu_enable, oup);



flags(2) <= '1' when (oup(15 downto 0) = x"0000") or (operation ="011" and oup = x"00000000") else '0';
flags(1) <= '1' when (to_integer(unsigned(source))>to_integer(unsigned(destination)) and result(16) = '1') or
	(to_integer(unsigned(result(15 downto 0)))<0 ) else '0';

--flags <= zero & negative & carry;

flags(0)<='1' when (result(15 downto 0) = X"0000" and result(16) = '1') or 
		(to_integer(unsigned(source))>to_integer(unsigned(destination)) and result(16) = '1') or
		((operation = "111" and  shiftRightCarry = '1') or (setc='1') or 
	(operation = "110" and result(16)='1') or result(16) = '1')
	else '0' when clrc = '1' else '0';
--
--
--
--

 --flags<= "101" when result(15 downto 0) = "0000000000000000" and result(16) = '1' else
 	--"011" when to_integer(unsigned(source))>to_integer(unsigned(destination)) and result(16) = '1' else
 	--"100" when result = "00000000000000000000000000000000" else
 	--"010" when to_integer(unsigned(result(15 downto 0)))<0 else
 	--"001" when (operation = "111" and  destination(to_integer(unsigned(shift_amount))-1) = '1') or (setc='1') or 
	--(operation = "110" and destination(16 - to_integer(unsigned(shift_amount)))='1') or result(16) = '1' else "000";
end Architecture;
     
-- Z N C 