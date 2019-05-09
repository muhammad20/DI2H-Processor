Library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity FetchUnit is
port( 	clock, fetch_enable, reset, pc_change_enable, int:in std_logic;
	branch_result : in std_logic;
	memory0_instr: in std_logic_vector(15 downto 0);
	memory1_instr : in std_logic_vector(15 downto 0); -- instruction in memory[1] location
	instruction_in_32_16 : in std_logic_vector(15 downto 0);
	instruction_in_15_0 : in std_logic_vector(15 downto 0);
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


signal instructionRegisterSignal: std_logic_vector(31 downto 0);
signal pc1, pc2: std_logic_vector(31 downto 0);
signal countChoice : std_logic_vector(31 downto 0); --an output from the 4x1 mux that chooses either to add 1 or 2 or a new pc if branch according to selection lines sent
signal programCount : std_logic_vector(31 downto 0); --an output from the register that stores the program counter
signal pcChosen : std_logic_vector(31 downto 0); --The input to the register coming from a 2X1 mux between int instruction or the chosen instruction
signal nopInstruction : std_logic_vector(31 downto 0);
signal instructionIn32 : std_logic_vector(15 downto 0);
signal instructionIn16 : std_logic_vector(15 downto 0);
signal pcEnable: std_logic;
Signal bit15 : std_logic;

Signal instruction_outSignal : std_logic_vector(31 downto 0);
begin

--process(clock, reset)
--begin
--	if (reset = '1') then
--		instructionIn32 <= memory0_instr;
--		instructionIn16 <= X"0000";
--		bit15 <= '0'; 		
--		--programCount<=(Others=>'0');
--	elsif(rising_edge(clock) and fetch_enable = '1') then
--		instructionIn32 <= instruction_in_32_16;
--		instructionIn16 <= instruction_in_15_0;
--		bit15 <= instruction_in_32_16(0);
----	elsif(falling_edge(clock) and fetch_enable = '1') then
--		--programCount<= pcChosen;	
--	end if;
--end process;


process (clock, reset)
begin
	if(reset = '1') then
		instruction_out <= "00000000000000001101100000000000";
	elsif(rising_edge(clock)) then
		--instructionIn32 <= instruction_in_32_16;
		--instructionIn16 <= instruction_in_15_0;
		instruction_out <= instruction_outSignal;
	end if;
end process;

nopInstruction <= "00000000000000001101100000000000";
program_counter <= programCount when fetch_enable='1' and pc_change_enable = '1';


--instruction_outSignal <= instructionIn16 & instructionIn32 when fetch_enable = '1' and instructionIn32(0) = '1' and reset = '0'  else
	--	 "0000000000000000"&instructionIn32 when fetch_enable = '1' and instructionIn32(0) = '0' and reset = '0'
	--	else nopInstruction;

instruction_outSignal <= instruction_in_15_0 & instruction_in_32_16 when fetch_enable = '1' and instruction_in_32_16(0) = '1' and reset = '0'  else
		 "0000000000000000"&instruction_in_32_16 when fetch_enable = '1' and instruction_in_32_16(0) = '0' and reset = '0'
		else nopInstruction;


pcEnable<=(fetch_enable and pc_change_enable);
bit15 <= instruction_in_32_16(0);

-- instructionTristate: nbit_register generic map(16) port map(instruction_in_32_16, clock, reset, fetch_enable, instructionIn32);
-- instructionTristate1: nbit_register generic map(16) port map(instruction_in_15_0, clock, reset, fetch_enable, instructionIn16);

pcRegister : nbit_register generic map(32) port map(pcChosen,clock, reset, pcEnable, programCount);
program_counter <= programCount;

countChoice	<= 	pc1 when fetch_enable = '1' and branch_result='0' and bit15 = '0' else
				pc2 when fetch_enable = '1' and branch_result='0' and bit15 = '1' else
				new_pc when fetch_enable = '1' and branch_result ='1'
			else (others=>'0');

pcChosen <=	countChoice when fetch_enable='1' and int ='0' else 
		x"0000"&memory1_instr when fetch_enable='1' and int = '1';

pc1 <= std_logic_vector(to_signed(to_integer(unsigned(programCount)+1),32));
pc2 <= std_logic_vector(to_signed(to_integer(unsigned(programCount)+2),32));

end Architecture;

