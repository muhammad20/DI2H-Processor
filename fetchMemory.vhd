Library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity FetchMemoryUnit is 
port(	clock, reset, fetch_enable, mem_write, mem_read: in std_logic;
	new_pc: in std_logic_vector(31 downto 0);
	instruction_selectors: in std_logic_vector(1 downto 0);
	memory1_location : in std_logic_vector(31 downto 0); -- instruction in memory[1] location
	instruction: out std_logic_vector(31 downto 0);
	program_counter: out std_logic_vector(31 downto 0)

);
end entity;

Architecture fetching of FetchMemoryUnit is
component memory_unit is
    generic(n: integer := 32; m: integer := 20);
    port(
    data_bus: inout std_logic_vector(n-1 downto 0);
    ram_addr: in std_logic_vector(m-1 downto 0);
        clk, rst, mem_write, mem_read: in std_logic
    );
end component;
component tristate is
    generic(n: integer := 32);
    port(
        inData: in std_logic_vector(n-1 downto 0);
        outData: out std_logic_vector(n-1 downto 0);
        ctl: in std_logic
    );
end component;
component mem_ram is

    generic(n: integer; m: integer);

    port(

	address: in std_logic_vector(m-1 downto 0);

	data_in: in std_logic_vector(n-1 downto 0);

	clk, rst, wen: in std_logic;

	data_out: out std_logic_vector(n-1 downto 0));

end component;

component FetchUnit is
port( 	clock, fetch_enable, reset, pc_change_enable, int:in std_logic;
	instruction_selectors : in std_logic_vector(1 downto 0);
	memory1_location : in std_logic_vector(31 downto 0); -- instruction in memory[1] location
	instruction_in : in std_logic_vector(31 downto 0);
	new_pc : in std_logic_vector(31 downto 0);
	program_counter: out std_logic_vector(31 downto 0);
	instruction_out: out std_logic_vector(31 downto 0)
);
end component;
signal dataBus : std_logic_vector(31 downto 0);
signal fromMemory: std_logic_vector(31 downto 0);
signal fromFetch: std_logic_vector(31 downto 0);

begin
tristateBuffer: tristate port map(fromMemory,dataBus,fetch_enable);
memory: memory_unit generic map(32,20) port map(fromMemory, fromFetch(19 downto 0),clock,reset,mem_write, mem_read);
fetch: FetchUnit port map(clock, fetch_enable, reset,'1','0', instruction_selectors, memory1_location, dataBus, new_pc, fromFetch, instruction);
program_counter<=fromFetch;



end Architecture;

