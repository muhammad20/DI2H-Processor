Library ieee;
use ieee.std_logic_1164.all;

entity mux4x1 is 
generic( size: positive := 16);
port(
in0,in1,in2,in3: in std_logic_vector(size-1 downto 0);
s: in std_logic_vector(1 downto 0);
c : out std_logic_vector(size-1 downto 0));
end entity;

Architecture mux4arch of mux4x1 is

begin
c <= in0 when s="00"
else in1 when s="01"
else in2 when s="10"
else in3;
end Architecture;
