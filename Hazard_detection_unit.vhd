Library ieee;

use ieee.std_logic_1164.all;

entity Hazard_detection_unit is
    
port(
EtoM_memwrite,EtoM_memread,DtoE_memread,DtoE_wb: in std_logic;
DtoE_rdst,EtoM_rsrc,EtoM_rdst: in std_logic_vector(2 downto 0);	
MUL,INT,EtoM_ret,EtoM_rti: in std_logic;
opcode: in std_logic_vector(4 downto 0);
DtoE_rsrc: in std_logic_vector(2 downto 0);
fetch_en,pc_en,stall_Mul,stall_ret,stall_rti,stall_INT,stall_ld: out std_logic);
end entity;

architecture arch of Hazard_detection_unit is 

component Comparator is  
port(
in1,in2: in std_logic_vector(2 downto 0);
out1: out std_logic);
end component;

signal temp1,out1,out2,x,y: std_logic;

begin

fetch_en <= EtoM_memwrite nor EtoM_memread;
x<=DtoE_memread and DtoE_wb;
c0: comparator port map(DtoE_rdst,EtoM_rsrc,out1);
c1: comparator port map(DtoE_rdst,EtoM_rdst,out2);

pc_en <= x nand (out1 or out2);
stall_Mul <= MUL; 
stall_ret <= EtoM_ret;  
stall_rti <= EtoM_rti;  
stall_INT <= INT;  


process(DtoE_rsrc,DtoE_rdst,EtoM_rdst,opcode)begin   
y<= not opcode(4) and not opcode(3) and opcode(1) and opcode(0); 
if( y = '1')
then if(DtoE_rsrc=EtoM_rdst or DtoE_rdst=EtoM_rdst)
      then stall_ld <='1';
      else stall_ld <='0';
      end if;
else stall_ld <='0';
end if;

end process;



end architecture;
