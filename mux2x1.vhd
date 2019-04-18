Library ieee;
use ieee.std_logic_1164.all;

entity mux2x1 is 
generic( size: positive := 16);
port(
in0,in1: in std_logic_vector(size-1 downto 0);
s: in std_logic;
c : out std_logic_vector(size-1 downto 0));
end entity;

Architecture mux2arch of mux2x1 is

begin
c <= in0 when s='0'
else in1;
end Architecture;
