Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity ArithmeticLogicUnit is
port(
    alu_enable : in std_logic;
    clock : in std_logic;
    reset : in std_logic;
    operation: in std_logic_vector(2 downto 0);
    source : in std_logic_vector(15 downto 0);
    destination : in std_logic_vector(15 downto 0);
    shift_amount : in std_logic_vector(3 downto 0);
    output : out std_logic_vector(31 downto 0);
    flags : out std_logic_vector(2 downto 0)

);
end entity;

Architecture behavioral of ArithmeticLogicUnit is


signal result:std_logic_vector(31 downto 0);
signal carry,zero,negative: std_logic;

begin
    process(reset,clock)
        begin
	if (reset = '1') then
		result <= "00000000000000000000000000000000";
		carry<='0';
		zero<='0';
		negative<='0';
	else 
		if (alu_enable='1' and falling_edge(clock)) then
				if  (operation =   "001"  ) then
					--ADDITION
					result <=  std_logic_vector(to_signed(to_integer(unsigned(source)+unsigned(destination)),32));
					carry <= result(16);
				elsif operation =  "111" then
					--SHR
					--result <= "00000000000000000000000000000000";
					result(15-to_integer(unsigned(shift_amount)) downto 0)<=destination(15 downto to_integer(unsigned(shift_amount)));
					carry <= destination(to_integer(unsigned(shift_amount))-1);
				elsif operation = "110" then
					--SHL
					--result <= "00000000000000000000000000000000";
					result(15 downto  to_integer(unsigned(shift_amount)))<=destination(15 - to_integer(unsigned(shift_amount))downto 0);
				    carry <= destination(16 - to_integer(unsigned(shift_amount)));
				elsif operation =   "101" then
					--OR
					result <= std_logic_vector(to_signed(to_integer(unsigned(source) or unsigned(destination)),32));
					carry<='0';
				elsif operation =   "100"  then
					--AND
					result <= std_logic_vector(to_signed(to_integer(unsigned(source) and unsigned(destination)),32));
					carry<='0';
				elsif operation =   "011" then
					--MULTIPLICATION
					result <= std_logic_vector(to_signed(to_integer(unsigned(source)*unsigned(destination)),32));
					carry<='0';
				elsif operation =   "010" then
					--SUBTRACTION
					result <= std_logic_vector(to_signed(to_integer(unsigned(destination)-unsigned(source)),32));
					carry<=result(16);
				elsif operation =   "111" then
					result <= "0000000000000000"& not destination;
					carry<='0';
				else
					result<="00000000000000000000000000000000";
					carry<='0';
				end if;
		end if;
	end if;
end process;
output<=result;
flags(2)<= '1' when result = "00000000000000000000000000000000"
	    else '0';
flags(1)<= '1' when to_integer(unsigned(source))>to_integer(unsigned(destination))
	    else '0';
flags(0)<=carry;
end Architecture;


-- opCode       operation     
--  000         addition
--  001         SHR        
--  010         SHL 
--  011         OR
--  100         AND 
--  101         MUL
--  110         SUB
--  111        
-- Z N C 