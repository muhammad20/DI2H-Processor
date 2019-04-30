Library ieee;

use ieee.std_logic_1164.all;

entity memory_unit is
    generic(n: integer := 32; m: integer := 20);
    port(
    data_bus: inout std_logic_vector(n-1 downto 0);
    memory0, memory1: out std_logic_vector(n-1 downto 0);
    
    ram_addr: in std_logic_vector(m-1 downto 0);
        clk, rst, mem_write, mem_read: in std_logic
    );
end entity;

architecture memarch of memory_unit is

    signal ram_data_out, ram_data_in, mem0,mem1: std_logic_vector(n-1 downto 0);

begin

    t0: entity work.tristate generic map(n) port map(ram_data_out,data_bus,mem_read);
    t1: entity work.tristate generic map(n) port map(mem0,memory0,mem_read);
    t2: entity work.tristate generic map(n) port map(mem1,memory1,mem_read);
    r0: entity work.mem_ram generic map(n,m) port map(ram_addr,data_bus, clk, rst, mem_write, ram_data_out, mem0,mem1);

end architecture;
    