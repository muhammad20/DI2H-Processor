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


signal result, destination, source :std_logic_vector(31 downto 0);
signal carry,zero,negative: std_logic;
signal one: std_logic_vector(31 downto 0);

begin
    process(reset,clock)
        begin
	
	if (reset = '1') then
		result <= "00000000000000000000000000000000";
		carry<='0';
		zero<='0';
		negative<='0';
		destination<="0000000000000000"&dest;
		source <="0000000000000000"&src;
	else 
		if (alu_enable='1' and falling_edge(clock) and h_type='1') then
				destination<="0000000000000000"&dest;
				carry<='0';
				zero<='0';
				negative<='0';
				source <="0000000000000000"&src;
				if  (operation =   "001"  ) then
					--ADDITION
					result <=  std_logic_vector(to_signed(to_integer(unsigned(source)+unsigned(destination)),32));
					carry <= result(16);
				elsif operation =  "111" then
					--SHR
					result(15-to_integer(unsigned(shift_amount)) downto 0)<=destination(15 downto to_integer(unsigned(shift_amount)));
					carry <= destination(to_integer(unsigned(shift_amount))-1);
				elsif operation = "110" then
					--SHL
					result(15 downto  to_integer(unsigned(shift_amount)))<=destination(15 - to_integer(unsigned(shift_amount))downto 0);
				   	 carry <= destination(16 - to_integer(unsigned(shift_amount)));
				elsif operation =   "101" then
					--OR
					result <= std_logic_vector(to_signed(to_integer(unsigned(source) or unsigned(destination)),32));
				elsif operation =   "100"  then
					--AND
					result <= std_logic_vector(to_signed(to_integer(unsigned(source) and unsigned(destination)),32));
				elsif operation =   "011" then
					--MULTIPLICATION
					result <= std_logic_vector(to_signed(to_integer(unsigned(source)*unsigned(destination)),32));
				elsif operation =   "010" then
					--SUBTRACTION
					result <= std_logic_vector(to_signed(to_integer(unsigned(destination)-unsigned(source)),32));
					--MOVE
				else
					result<= source;
				end if;
				elsif (alu_enable='1' and falling_edge(clock) and h_type='0') then
				if (setc = '1') then carry <= '1'; end if;
				if (clrc = '1') then carry <= '0'; end if;
				if(not_op = '1') then result <= not source; end if;
				if (inc = '1') then result <= std_logic_vector(to_signed(to_integer(unsigned(destination) + unsigned(one)),32)); end if;
				if (dec = '1') then result <= std_logic_vector(to_signed(to_integer(unsigned(destination) - unsigned(one)),32)); end if;
		end if;
	end if;
end process;
output<=result;
flags <= zero & negative & carry;
zero <= '1' when result(15 downto 0) = X"0000" 
		else '0';
negative <= '1' when to_integer(unsigned(source))>to_integer(unsigned(destination))
		else '0';
-- flags<= "101" when result(15 downto 0) = "0000000000000000" and result(16) = '1' else
-- 	"011" when to_integer(unsigned(source))>to_integer(unsigned(destination)) and result(16) = '1' else
-- 	"100" when result = "00000000000000000000000000000000" else
-- 	"010" when to_integer(unsigned(result(15 downto 0)))<0 else
-- 	"001" when (operation = "111" and  destination(to_integer(unsigned(shift_amount))-1) = '1') or 
-- 	(operation = "110" and destination(16 - to_integer(unsigned(shift_amount)))='1') or result(16) = '1' else "000";
end Architecture;
     
-- Z N C 