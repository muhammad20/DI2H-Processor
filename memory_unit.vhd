Library ieee;

use ieee.std_logic_1164.all;

entity memory_unit is
    generic(n: integer := 16; m: integer := 20);
    port(
	membus: inout std_logic_vector(n-1 downto 0);
	src_sel: in std_logic_vector(1 downto 0);
	dst_sel: in std_logic_vector(1 downto 0);
        src_en, dst_en, clk, rst, wen: in std_logic
    );
end entity;

architecture memarch of memory_unit is
    
signal not_clk: std_logic;

signal ram_addr: std_logic_vector(m-1 downto 0);

signal not_src_en: std_logic;

signal ram_data_out: std_logic_vector(n-1 downto 0);

begin
	not_clk <= not clk;
    not_src_en <= not src_en;
    t0: entity work.tristate generic map(n) port map(ram_data_out, membus, not_src_en);
    m0: entity work.register_unit generic map(n) port map(membus, src_sel, dst_sel, clk, dst_en, src_en);
    c0: entity work.my_counter generic map(m) port map(ram_addr, not_clk, rst);
    r0: entity work.mem_ram generic map(n,m) port map(ram_addr,membus, not_clk, rst, wen, ram_data_out);
end architecture;
    