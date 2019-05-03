
Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Forwarding_unit is

port(
EtoM_rsrc_val,EtoM_rdst_val: in std_logic_vector(15 downto 0);
EtoM_rsrc_addr,EtoM_rdst_addr: in std_logic_vector(2 downto 0);
MtoWB_rsrc_val,MtoWB_rdst_val: in std_logic_vector(15 downto 0);
MtoWB_rsrc_addr,MtoWB_rdst_addr: in std_logic_vector(2 downto 0);
DtoEx_rsrc_val,DtoEx_rdst_val: in std_logic_vector(15 downto 0);
DtoEx_rsrc_addr,DtoEx_rdst_addr: in std_logic_vector(2 downto 0);
EtoM_wb,MtoWB_wb,MtoWB_mul,EtoM_mul: in std_logic;
fwd_data1,fwd_data2: out std_logic_vector(15 downto 0)
);

end entity;

ARCHITECTURE arch6 of Forwarding_unit is
signal temp1,temp2,temp3: std_logic;
begin 
process(EtoM_wb,MtoWB_wb,EtoM_mul,MtoWB_mul,DtoEx_rsrc_addr,EtoM_rdst_addr,EtoM_rdst_val,DtoEx_rdst_val,MtoWB_rdst_addr,MtoWB_rdst_val,EtoM_rsrc_addr,
EtoM_rsrc_val,DtoEx_rsrc_val,MtoWB_rsrc_addr,MtoWB_rsrc_val)
begin	



if(EtoM_wb = '1')
then if (DtoEx_rsrc_addr = EtoM_rdst_addr)
	then fwd_data1 <= EtoM_rdst_val;
        
        else if (EtoM_mul ='1')
                then if(DtoEx_rsrc_addr = EtoM_rsrc_addr)
	        then fwd_data1 <= EtoM_rsrc_val; 
                else fwd_data1 <= DtoEx_rsrc_val;
                end if;
	 
        elsif (EtoM_mul /='1' and DtoEx_rsrc_addr /= EtoM_rdst_addr) 
        then fwd_data1 <= DtoEx_rsrc_val;  
        end if;
        if (temp1 /='1')
        then fwd_data1 <= DtoEx_rsrc_val;
          
        end if;
end if;

if (DtoEx_rdst_addr = EtoM_rdst_addr)
	then fwd_data1 <= EtoM_rdst_val;
        temp2 <='0';
        if (EtoM_mul ='1')
        then if(DtoEx_rdst_addr = EtoM_rsrc_addr)
	        then fwd_data1 <= EtoM_rsrc_val; 
                else fwd_data1 <= DtoEx_rdst_val;
                end if;
	 
        elsif (EtoM_mul /='1' and DtoEx_rdst_addr /= EtoM_rdst_addr ) 
        then  fwd_data1 <= DtoEx_rdst_val;
	end if;
	if (temp2 /='0' and temp1 /='1')
           then fwd_data1 <= DtoEx_rdst_val;
       end if;
end if;

end if;



if (MtoWB_wb = '1')
then if (DtoEx_rsrc_addr = MtoWB_rdst_addr)
	then fwd_data2 <= MtoWB_rdst_val;
        if (MtoWB_mul ='1')
              then if(DtoEx_rsrc_addr = MtoWB_rsrc_addr)
	           then fwd_data2 <=MtoWB_rsrc_val; 
                   else fwd_data2 <= DtoEx_rsrc_val;
                   end if;
	  
        elsif (MtoWB_mul /='1' and DtoEx_rsrc_addr /= MtoWB_rdst_addr ) 
	then fwd_data2 <= DtoEx_rsrc_val;
        end if;
	 else
           fwd_data2 <= DtoEx_rsrc_val;
        end if;

 if (DtoEx_rdst_addr = MtoWB_rdst_addr)
	then fwd_data2 <= MtoWB_rdst_val;
             if (MtoWB_mul ='1')
             then if(DtoEx_rdst_addr = MtoWB_rsrc_addr)
	        then fwd_data2 <= MtoWB_rsrc_val; 
                else fwd_data2 <= DtoEx_rdst_val;
                end if;
	
           elsif (MtoWB_mul /='1' and DtoEx_rdst_addr /= MtoWB_rdst_addr ) 
	   then  fwd_data2 <= DtoEx_rdst_val;
           end if;
       else
           fwd_data2 <= DtoEx_rdst_val;
   
 end if;

end if;

end process;
end architecture;






