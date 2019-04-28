
Library ieee;
use ieee.std_logic_1164.all;

entity mux4 is

port(in1,in2,in3,in4: in std_logic;
	s1,s0:in std_logic;
	c: out std_logic);

end entity;

ARCHITECTURE arch6 of mux4 is
begin 
	c <=in1 when (s1='0' and s0='0')
	else in2 when (s1='0' and s0='1')
	else in3 when (s1='1' and s0='0')
	else in4;
	

end arch6;
