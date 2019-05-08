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

begin
--    process(reset,clock, alu_enable, h_type, operation)
--        begin
--	
--	if (reset = '1') then
--		result <= "00000000000000000000000000000000";
--		carry<='0';
--		zero<='0';
--		negative<='0';
--		destination<="0000000000000000"&dest;
--		source <="0000000000000000"&src;
--	else 
--		if (alu_enable='1' and rising_edge(clock)) then
--				destination<= X"0000"&dest;
--				carry<='0';
--				zero<='0';
--				negative<='0';
--				source <= X"0000"&src;
--			if(h_type ='1') then
--				if  (operation =   "001"  ) then
--					--ADDITION
--					result <=  std_logic_vector(to_signed(to_integer(unsigned(source)+unsigned(destination)),32));
--					carry <= result(16);
--				elsif operation =  "111" then
--					--SHR
--					result(15-to_integer(unsigned(shift_amount)) downto 0)<=destination(15 downto to_integer(unsigned(shift_amount)));
--					carry <= destination(to_integer(unsigned(shift_amount))-1);
--				elsif operation = "110" then
--					--SHL
--					result(15 downto  to_integer(unsigned(shift_amount)))<=destination(15 - to_integer(unsigned(shift_amount))downto 0);
--				   	 carry <= destination(16 - to_integer(unsigned(shift_amount)));
--				elsif operation =   "101" then
--					--OR
--					result <= std_logic_vector(to_signed(to_integer(unsigned(source) or unsigned(destination)),32));
--				elsif operation =   "100"  then
--					--AND
--					result <= std_logic_vector(to_signed(to_integer(unsigned(source) and unsigned(destination)),32));
--				elsif operation =   "011" then
--					--MULTIPLICATION
--					result <= std_logic_vector(to_signed(to_integer(unsigned(source)*unsigned(destination)),32));
--				elsif operation =   "010" then
--					--SUBTRACTION
--					result <= std_logic_vector(to_signed(to_integer(unsigned(destination)-unsigned(source)),32));
--					
--				else
--					--MOVE					
--					result<= source;
--				end if;
--				elsif (h_type='0') then
--				if (setc = '1') then carry <= '1'; end if;
--				if (clrc = '1') then carry <= '0'; end if;
--				if(not_op = '1') then result <= not source; end if;
--				if (inc = '1') then result <= std_logic_vector(to_signed(to_integer(unsigned(destination) + unsigned(one)),32)); end if;
--				if (dec = '1') then result <= std_logic_vector(to_signed(to_integer(unsigned(destination) - unsigned(one)),32)); end if;
--		end if;
--		end if;
--	end if;
--end process;

process(clock) begin
	if(rising_edge(clock)) then
		output <= oup;
 	end if;
 end process;

zero_val <= X"00000000";
one <= X"00000001";

destination<="0000000000000000"&dest;
source <="0000000000000000"&src;

inc_val <= std_logic_vector(to_signed(to_integer(unsigned(destination) + unsigned(one)),32));
dec_val <= std_logic_vector(to_signed(to_integer(unsigned(destination) - unsigned(one)),32));
not_val <= not destination;

mov <= destination;
add <= std_logic_vector(to_signed(to_integer(unsigned(source)+unsigned(destination)),32));
sub <= std_logic_vector(to_signed(to_integer(unsigned(destination)-unsigned(source)),32));
mul <= std_logic_vector(to_signed(to_integer(unsigned(source)*unsigned(destination)),32));
andd <= std_logic_vector(to_signed(to_integer(unsigned(source) and unsigned(destination)),32));
orr <= std_logic_vector(to_signed(to_integer(unsigned(source) or unsigned(destination)),32));
shr(15-to_integer(unsigned(shift_amount)) downto 0) <= destination(15 downto to_integer(unsigned(shift_amount)));
shl(15 downto  to_integer(unsigned(shift_amount))) <= destination(15 - to_integer(unsigned(shift_amount))downto 0);

x_decision <= inc & dec & not_op;
mOp_h: entity work.mux8x1 generic map(32) port map(mov, add, sub, mul, andd, orr, shl, shr, operation, h_result);
mOp_x: entity work.mux8x1 generic map(32) port map(inc_val, not_val, dec_val, zero_val, inc_val, zero_val, zero_val, zero_val, x_decision, x_result);
selOp: entity work.mux2x1 generic map(32) port map(x_result, h_result, h_type, result);
sense_output: entity work.mux2x1 generic map(32) port map(zero_val, result, alu_enable, oup);

zero <= '1' when oup(15 downto 0) = x"0000" else '0';
carry <= '1' when oup(16) = '1' else '0';
negative <= '1' when to_integer(signed(oup)) < to_integer(signed(zero_val)) else '0';

flags <= zero & negative & carry;

--flags(0)<='1' when (result(15 downto 0) = X"0000" and result(16) = '1') or 
--		(to_integer(unsigned(source))>to_integer(unsigned(destination)) and result(16) = '1') or
--		((operation = "111" and  destination(to_integer(unsigned(shift_amount))-1) = '1') or (setc='1') or 
--	(operation = "110" and destination(16 - to_integer(unsigned(shift_amount)))='1') or result(16) = '1')
--	else '0' when clrc = '1';
--
--flags(1) <= '1' when (to_integer(unsigned(source))>to_integer(unsigned(destination)) and result(16) = '1') or
--	(to_integer(unsigned(result(15 downto 0)))<0 ) else '0';
--
--flags(2) <= '1' when (result(15 downto 0) = "0000000000000000" and result(16) = '1') or (result = "00000000000000000000000000000000" )else '0';
--	

 --flags<= "101" when result(15 downto 0) = "0000000000000000" and result(16) = '1' else
 	--"011" when to_integer(unsigned(source))>to_integer(unsigned(destination)) and result(16) = '1' else
 	--"100" when result = "00000000000000000000000000000000" else
 	--"010" when to_integer(unsigned(result(15 downto 0)))<0 else
 	--"001" when (operation = "111" and  destination(to_integer(unsigned(shift_amount))-1) = '1') or (setc='1') or 
	--(operation = "110" and destination(16 - to_integer(unsigned(shift_amount)))='1') or result(16) = '1' else "000";
end Architecture;
     
-- Z N C 