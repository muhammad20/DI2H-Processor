Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder3x8 is 

port(
s: in std_logic_vector(2 downto 0);
en: in std_logic;
output: out std_logic_vector( 7 downto 0));

end entity;

architecture arh2 of decoder3x8 is   
begin

output<="00000001" when s="000" and en='1'
else "00000010" when s="001" and en='1' 
else "00000100" when s="010" and en='1'
else "00001000" when s="011" and en='1'
else "00010000" when s="100" and en='1'
else "00100000" when s="101" and en='1'
else "01000000" when s="110" and en='1'
else "10000000";




end architecture;
