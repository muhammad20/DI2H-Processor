Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Register_File is 

port(
Read_Sig, Write_Sig,clk,rst, mul_signal: in std_logic;
Address_read1,Address_read2,Address_write1, Address_write2: in std_logic_vector( 2 downto 0);
datain, datain_mul: in std_logic_vector(15 downto 0);
dataout1,dataout2: out std_logic_vector(15 downto 0)
);
end entity;

architecture arch2 of Register_File is  

signal endec_read1,endec_read2,endec_write1, endec_write2: std_logic;
signal output_read1,output_read2,output_write1, output_write2, output_write3: std_logic_vector(7 downto 0);
signal out1,out2,out3,out4,out5,out6,out7,out8: std_logic_vector(15 downto 0);
signal regInData: std_logic_vector(15 downto 0);

Signal regin1, regin2, regin3, regin4, regin5, regin6, regin7, regin8 : std_logic_vector(15 downto 0);

Signal registerOutput1, registerOutput2 : std_logic_vector(15 downto 0);

begin

--read data from read address 1
t0: entity work.tristate generic map(16) port map (out1,registerOutput1,output_read1(0));
t1: entity work.tristate generic map(16) port map (out2,registerOutput1,output_read1(1));
t2: entity work.tristate generic map(16) port map (out3,registerOutput1,output_read1(2));
t3: entity work.tristate generic map(16) port map (out4,registerOutput1,output_read1(3));
t4: entity work.tristate generic map(16) port map (out5,registerOutput1,output_read1(4));
t5: entity work.tristate generic map(16) port map (out6,registerOutput1,output_read1(5));
t6: entity work.tristate generic map(16) port map (out7,registerOutput1,output_read1(6));
t7: entity work.tristate generic map(16) port map (out8,registerOutput1,output_read1(7));

--read data from read address 2
t8: entity work.tristate generic map(16) port map (out1,registerOutput2,output_read2(0));
t9: entity work.tristate generic map(16) port map (out2,registerOutput2,output_read2(1));
tA: entity work.tristate generic map(16) port map (out3,registerOutput2,output_read2(2));
tB: entity work.tristate generic map(16) port map (out4,registerOutput2,output_read2(3));
tC: entity work.tristate generic map(16) port map (out5,registerOutput2,output_read2(4));
tD: entity work.tristate generic map(16) port map (out6,registerOutput2,output_read2(5));
tE: entity work.tristate generic map(16) port map (out7,registerOutput2,output_read2(6));
tF: entity work.tristate generic map(16) port map (out8,registerOutput2,output_read2(7));

--8 16-bit registers
r0: entity work.nbit_register generic map(16) port map (regin1,clk,rst,output_write3(0),out1);
r1: entity work.nbit_register generic map(16) port map (regin2,clk,rst,output_write3(1),out2);
r2: entity work.nbit_register generic map(16) port map (regin3,clk,rst,output_write3(2),out3);
r3: entity work.nbit_register generic map(16) port map (regin4,clk,rst,output_write3(3),out4);
r4: entity work.nbit_register generic map(16) port map (regin5,clk,rst,output_write3(4),out5);
r5: entity work.nbit_register generic map(16) port map (regin6,clk,rst,output_write3(5),out6);
r6: entity work.nbit_register generic map(16) port map (regin7,clk,rst,output_write3(6),out7);
r7: entity work.nbit_register generic map(16) port map (regin8,clk,rst,output_write3(7),out8);

--read decoders
d0: entity work.decoder3x8 port map(Address_read1,endec_read1,output_read1);
d1: entity work.decoder3x8 port map(Address_read2,endec_read2,output_read2);

--write decoder
output_write3 <= output_write1 xor output_write2;
d2: entity work.decoder3x8 port map(Address_write1,endec_write1,output_write1);
d3: entity work.decoder3x8 port map(Address_write2,endec_write2,output_write2);

-- dataout1 <= datain when Read_Sig = '1' and Write_Sig = '1' and Address_read1 = Address_write and endec_read1 = '1'
-- 			else registerOutput1;

--dataout2 <= datain when Read_Sig = '1' and Write_Sig = '1' and Address_read2 = Address_write and endec_read2 = '1'
--			else registerOutput2;

endec_read1 <= Read_Sig;
endec_read2 <= Read_Sig;
endec_write1 <= Write_Sig;
endec_write2 <= mul_signal;

regin1 <= datain_mul when output_write2(0) = '1' else datain;
regin2 <= datain_mul when output_write2(1) = '1' else datain;
regin3 <= datain_mul when output_write2(2) = '1' else datain;
regin4 <= datain_mul when output_write2(3) = '1' else datain;
regin5 <= datain_mul when output_write2(4) = '1' else datain;
regin6 <= datain_mul when output_write2(5) = '1' else datain;
regin7 <= datain_mul when output_write2(6) = '1' else datain;
regin8 <= datain_mul when output_write2(7) = '1' else datain;

process(clk, rst)
begin
-- if(rst='1') then
-- 	endec_write <= '0';
-- 	endec_read1 <= '0';
-- 	endec_read2 <= '0';
-- else
-- 	if(rising_edge(clk)) then 
-- 		if(Write_Sig = '1') then
-- 			endec_write<='1';
-- 		else
-- 			endec_write <= '0';
-- 		end if;
-- 		if(Read_Sig = '1') then
-- 			endec_read1 <= '0';
-- 			endec_read2 <= '0';
-- 		end if;
-- 	end if;
-- end if;
	if(rising_edge(clk)) then
		if (Write_Sig = '1' and mul_signal = '1' and Read_Sig = '1' and Address_read1 = Address_write2) then 
			dataout1 <= datain_mul;
		elsif (Write_Sig = '1' and Read_Sig = '1' and Address_read1 = Address_write1) then 
			dataout1 <= datain;
		else 
			dataout1 <= registerOutput1;
		end if;

		if (Write_Sig = '1' and mul_signal = '1' and Read_Sig = '1' and Address_read2 = Address_write2) then
			dataout2 <= datain_mul;
		elsif (Write_Sig = '1' and Read_Sig = '1' and Address_read2 = Address_write1) then
			dataout2 <= datain;
		else
			dataout2 <= registerOutput2;
		end if;
	end if;
end process;

end architecture;
