Library ieee;


use ieee.std_logic_1164.all;

use ieee.numeric_std.all;



entity mem_ram is

    generic(n: integer; m: integer);

    port(

	address: in std_logic_vector(m-1 downto 0);

	data_in: in std_logic_vector(n-1 downto 0);

	clk, rst, wen: in std_logic;

	data_out, mem0, mem1: out std_logic_vector(n-1 downto 0));

end entity;



architecture ramArch of mem_ram is

    type ram is array(0 to 2**m-1) of std_logic_vector(n-1 downto 0);

    signal s_ram: ram;

    begin

	process(clk)

		begin

		if (rising_edge(clk) and wen = '1') then s_ram(to_integer(unsigned(address))) <= data_in;

		end if;

	end process;

	data_out <= s_ram(to_integer(unsigned(address)));

	mem0 <= s_ram(0);

	mem1 <= s_ram(1);

end architecture;
