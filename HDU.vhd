Library ieee;
use ieee.std_logic_1164.all;

entity HazardDetectionUnit is 
port(
    ex_mem_wb, ex_mem_read, dec_ex_mem_read, dec_ex_wb, mul : in std_logic;
    ex_mem_ret_rti, int : in std_logic;
    ex_mem_rdst, ex_mem_rsrc, dec_ex_rdst: in std_logic_vector(2 downto 0);
    stall,fetch_enable, pc_enable: out std_logic
);

end entity;

architecture structural of HazardDetectionUnit is
signal fetchEnable,memWB: std_logic;
signal comparator1, comparator2: std_logic_vector(2 downto 0);



begin 
end architecture;