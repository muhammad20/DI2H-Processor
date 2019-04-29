Library ieee;

use ieee.std_logic_1164.all;


entity nbit_register is
generic(n: integer := 16);
port(
    indata: in std_logic_vector(n-1 downto 0);
    clk, rst, en: in std_logic;
    outData: out std_logic_vector(n-1 downto 0));
end entity;

architecture registerarch of nbit_register is
    begin
        process(clk, rst, en, indata)
        begin
            if(rst = '1' and en = '1') 
                then outData <= (others => '0');
            elsif (rst='0' and en = '1')
                then outData <= inData;
            end if;
        end process;
end architecture;

