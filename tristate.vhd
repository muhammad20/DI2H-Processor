Library ieee;

use ieee.std_logic_1164.all;

entity tristate is
    generic(n: integer := 32);
    port(
        inData: in std_logic_vector(n-1 downto 0);
        outData: out std_logic_vector(n-1 downto 0);
        ctl: in std_logic
    );
end entity;

architecture tristatearch of tristate is
    begin
        outData <= inData when ctl = '1'
        else (others => 'Z');
end architecture;