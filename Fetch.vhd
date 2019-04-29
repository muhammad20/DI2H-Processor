Library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity FetchUnit is
port( 	clock, fetch_enable, reset, pc_change_enable, int:in std_logic;
	instruction_selectors : in std_logic_vector(1 downto 0);
	memory1_location : in std_logic_vector(31 downto 0); -- instruction in memory[1] location
	instruction_in : in std_logic_vector(31 downto 0);
	new_pc : in std_logic_vector(31 downto 0);
	program_counter: out std_logic_vector(31 downto 0);
	instruction_out: out std_logic_vector(31 downto 0)
);
end entity;

Architecture behavioral of FetchUnit is

--Component for registers (PC and instruction register)
component nbit_register is
generic(n: integer := 16);
port(
    indata: in std_logic_vector(n-1 downto 0);
    clk, rst, en: in std_logic;
    outData: out std_logic_vector(n-1 downto 0));
end component;

--Component for 4X1 multiplexer
component mux4x1 is 
generic( size: positive := 16);
port(
in0,in1,in2,in3: in std_logic_vector(size-1 downto 0);
s: in std_logic_vector(1 downto 0);
c : out std_logic_vector(size-1 downto 0));
end component; 

--Component for 2X1 multiplexer
component mux2x1 is 

generic( size: positive := 16);

port(

in0,in1: in std_logic_vector(size-1 downto 0);

s: in std_logic;

c : out std_logic_vector(size-1 downto 0));

end component;

component tristate is
    generic(n: integer := 32);
    port(
        inData: in std_logic_vector(n-1 downto 0);
        outData: out std_logic_vector(n-1 downto 0);
        ctl: in std_logic
    );
end component;

signal instructionRegisterSignal: std_logic_vector(31 downto 0);
signal pc1, pc2: std_logic_vector(31 downto 0);
signal countChoice : std_logic_vector(31 downto 0); --an output from the 4x1 mux that chooses either to add 1 or 2 or a new pc if branch according to selection lines sent
signal programCount : std_logic_vector(31 downto 0); --an output from the register that stores the program counter
signal pcChosen : std_logic_vector(31 downto 0); --The input to the register coming from a 2X1 mux between int instruction or the chosen instruction
signal nopInstruction : std_logic_vector(31 downto 0);
signal instructionIn : std_logic_vector(31 downto 0);
signal instructionOut: std_logic_vector(31 downto 0);

begin
process(clock, reset)
begin
	if (reset = '1') then
		instructionIn <= (Others =>'0');
		programCount<=(Others=>'0');
	elsif(falling_edge(clock) and fetch_enable = '1') then
		instructionIn<=instruction_in;
		programCount <= pcChosen;
		
	end if;
end process;
program_counter <= programCount when fetch_enable='1' and pc_change_enable = '1' else (others=>'0') when reset = '1';
instruction_out<=instructionOut when fetch_enable='1' else (others=>'0');
nopInstruction <= "00000000000000001101100000000000";

instructionTristate: tristate generic map(32) port map(instructionIn,instructionRegisterSignal, fetch_enable);

--pcRegister : nbit_register generic map(32) port map(pcChosen,clock, reset, fetch_enable,programCount);

instructionOut<= nopInstruction when fetch_enable='0' else 
		 instructionregisterSignal;

countChoice<= 	pc1 when fetch_enable='1' and instruction_selectors="00" else
		pc2 when fetch_enable='1' and instruction_selectors="01" else
		new_pc when fetch_enable='1' and instruction_selectors ="10" else
		new_pc when fetch_enable='1' and instruction_selectors ="11";

pcChosen <=	countChoice when fetch_enable='1' and int ='0' else 
		memory1_location when fetch_enable='1' and int = '1';		

pc1<=std_logic_vector(to_signed(to_integer(unsigned(programCount)+1),32)) when pc_change_enable = '1';
pc2<=std_logic_vector(to_signed(to_integer(unsigned(programCount)+2),32)) when pc_change_enable = '1';

end Architecture;

