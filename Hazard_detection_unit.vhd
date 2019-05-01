Library ieee;

use ieee.std_logic_1164.all;

entity Hazard_detection_unit is
    
port(
EtoM_memwrite,EtoM_memread,DtoE_memread,DtoE_wb: in std_logic;
DtoE_rdst,EtoM_rsrc,EtoM_rdst: in std_logic_vector(2 downto 0);	
MUL,INT,EtoM_ret,EtoM_rti: in std_logic;
fetch_en,pc_en,stall: out std_logic);
end entity;

architecture arch of Hazard_detection_unit is 

component Comparator is  
port(
in1,in2: in std_logic_vector(2 downto 0);
out1: out std_logic);
end component;

signal temp1,out1,out2,x: std_logic;

begin

fetch_en <= EtoM_memwrite nor EtoM_memread;
x<=DtoE_memread and DtoE_wb;
c0: comparator port map(DtoE_rdst,EtoM_rsrc,out1);
c1: comparator port map(DtoE_rdst,EtoM_rdst,out2);

pc_en <= x nand (out1 or out2);
stall <= MUL or INT or EtoM_ret or EtoM_rti;       
end architecture;
