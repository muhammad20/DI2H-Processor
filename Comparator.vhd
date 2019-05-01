Library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Comparator is
    
port(
in1,in2: in std_logic_vector(2 downto 0);
out1: out std_logic);
end entity;

architecture arch of Comparator is 


begin
process(in1,in2)
begin

if( to_integer(unsigned(in1))=to_integer(unsigned(in2)))
then out1<= '1';
elsif ( to_integer(unsigned(in1))<to_integer(unsigned(in2)))
then out1<='0';
elsif ( to_integer(unsigned(in1))>to_integer(unsigned(in2)))
then out1<='0';
end if;

end process;
end architecture;
