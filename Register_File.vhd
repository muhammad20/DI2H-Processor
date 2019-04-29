Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Register_File is 

port(
Read_Sig, Write_Sig,clk,rst: in std_logic;
Address_read1,Address_read2,Address_write: in std_logic_vector( 2 downto 0);
datain: in std_logic_vector(15 downto 0);
dataout1,dataout2: out std_logic_vector(15 downto 0)
);
end entity;

architecture arch2 of Register_File is  

signal endec_read1,endec_read2,endec_write: std_logic;
signal output_read1,output_read2,output_write1,output4: std_logic_vector(7 downto 0);
signal out1,out2,out3,out4,out5,out6,out7,out8: std_logic_vector(15 downto 0);
signal outdata1,outdata2,outdata3,outdata4,outdata5,outdata6,outdata7,outdata8: std_logic_vector(15 downto 0); 

begin

--read data from read address 1
t0: entity work.tristate generic map(16) port map (out1,dataout1,output_read1(0));
t1: entity work.tristate generic map(16) port map (out2,dataout1,output_read1(1));
t2: entity work.tristate generic map(16) port map (out3,dataout1,output_read1(2));
t3: entity work.tristate generic map(16) port map (out4,dataout1,output_read1(3));
t4: entity work.tristate generic map(16) port map (out5,dataout1,output_read1(4));
t5: entity work.tristate generic map(16) port map (out6,dataout1,output_read1(5));
t6: entity work.tristate generic map(16) port map (out7,dataout1,output_read1(6));
t7: entity work.tristate generic map(16) port map (out8,dataout1,output_read1(7));

--read data from read address 2
t8: entity work.tristate generic map(16) port map (out1,dataout2,output_read2(0));
t9: entity work.tristate generic map(16) port map (out2,dataout2,output_read2(1));
tA: entity work.tristate generic map(16) port map (out3,dataout2,output_read2(2));
tB: entity work.tristate generic map(16) port map (out4,dataout2,output_read2(3));
tC: entity work.tristate generic map(16) port map (out5,dataout2,output_read2(4));
tD: entity work.tristate generic map(16) port map (out6,dataout2,output_read2(5));
tE: entity work.tristate generic map(16) port map (out7,dataout2,output_read2(6));
tF: entity work.tristate generic map(16) port map (out8,dataout2,output_read2(7));

--8 16-bit registers
r0: entity work.nbit_register generic map(16) port map (datain,clk,rst,output_write1(0),out1);
r1: entity work.nbit_register generic map(16) port map (datain,clk,rst,output_write1(1),out2);
r2: entity work.nbit_register generic map(16) port map (datain,clk,rst,output_write1(2),out3);
r3: entity work.nbit_register generic map(16) port map (datain,clk,rst,output_write1(3),out4);
r4: entity work.nbit_register generic map(16) port map (datain,clk,rst,output_write1(4),out5);
r5: entity work.nbit_register generic map(16) port map (datain,clk,rst,output_write1(5),out6);
r6: entity work.nbit_register generic map(16) port map (datain,clk,rst,output_write1(6),out7);
r7: entity work.nbit_register generic map(16) port map (datain,clk,rst,output_write1(7),out8);

--read decoders
d0: entity work.decoder3x8 port map(Address_read1,endec_read1,output_read1);
d1: entity work.decoder3x8 port map(Address_read2,endec_read2,output_read2);

--write decoder
d2: entity work.decoder3x8 port map(Address_write,endec_write,output_write1);

process(clk, Write_Sig, Read_Sig)
begin
if(rst='1') then
	endec_write <= '0';
	endec_read1 <= '0';
	endec_read2 <= '0';
	else
    if(rising_edge(clk) and Write_Sig='1') 
    then endec_write<='1';
	endec_read1 <= '0';
	endec_read2 <= '0';
    elsif (falling_edge(clk) and Read_Sig='1') 
        then endec_read2<='1';
		endec_read1 <='1';
		endec_write <= '0';
end if;
end if;
end process;

end architecture;
