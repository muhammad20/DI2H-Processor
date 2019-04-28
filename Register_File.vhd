Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Register_File is 

port(
Read_Sig, Write_Sig,clk,rst: in std_logic;
Address1,Address2,Address3: in std_logic_vector( 2 downto 0);
datain: in std_logic_vector(15 downto 0);
dataout1,dataout2: out std_logic_vector(15 downto 0)
);
end entity;

architecture arh2 of Register_File is  

component mux8x1 is 

generic( size: positive := 16);

port(

in0,in1,in2,in3, in4, in5, in6, in7: in std_logic_vector(size-1 downto 0);

s: in std_logic_vector(2 downto 0);

c : out std_logic_vector(size-1 downto 0));

end component;

component decoder3x8 is 

port(
s: in std_logic_vector(2 downto 0);
en: in std_logic;
output: out std_logic_vector( 7 downto 0));

end component; 

component nbit_register is
generic(n: integer := 16);
port(
    indata: in std_logic_vector(n-1 downto 0);
    clk, rst, en: in std_logic;
    outData: out std_logic_vector(n-1 downto 0));
end component;

component tristate is
    generic(n: integer := 32);
    port(
        inData: in std_logic_vector(n-1 downto 0);
        outData: out std_logic_vector(n-1 downto 0);
        ctl: in std_logic
    );
end component;
signal endec1,endec2,endec3: std_logic;
signal output1,output2,output3,output4: std_logic_vector(7 downto 0);
signal out1,out2,out3,out4,out5,out6,out7,out8: std_logic_vector(15 downto 0);
signal outdata1,outdata2,outdata3,outdata4,outdata5,outdata6,outdata7,outdata8: std_logic_vector(15 downto 0); 

begin

t0: tristate generic map(16) port map (datain,outdata1,output3(0));
t1: tristate generic map(16) port map (datain,outdata2,output3(1));
t2: tristate generic map(16) port map (datain,outdata3,output3(2));
t3: tristate generic map(16) port map (datain,outdata4,output3(3));
t4: tristate generic map(16) port map (datain,outdata5,output3(4));
t5: tristate generic map(16) port map (datain,outdata6,output3(5));
t6: tristate generic map(16) port map (datain,outdata7,output3(6));
t7: tristate generic map(16) port map (datain,outdata8,output3(7));
r0: nbit_register generic map(16) port map (outdata1,clk,rst,output4(0),out1);
r1: nbit_register generic map(16) port map (outdata2,clk,rst,output4(1),out2);
r2: nbit_register generic map(16) port map (outdata3,clk,rst,output4(2),out3);
r3: nbit_register generic map(16) port map (outdata4,clk,rst,output4(3),out4);
r4: nbit_register generic map(16) port map (outdata5,clk,rst,output4(4),out5);
r5: nbit_register generic map(16) port map (outdata6,clk,rst,output4(5),out6);
r6: nbit_register generic map(16) port map (outdata7,clk,rst,output4(6),out7);
r7: nbit_register generic map(16) port map (outdata8,clk,rst,output4(7),out8);

output4 <= output1 or output2;

d0: decoder3x8 port map(Address1,endec1,output1);
d1: decoder3x8 port map(Address2,endec2,output2);
d2: decoder3x8 port map(Address3,endec3,output3);

m0: mux8x1 generic map(16) port map(out1,out2,out3,out4,out5,out6,out7,out8,Address1,dataout1);
m1: mux8x1 generic map(16) port map(out1,out2,out3,out4,out5,out6,out7,out8,Address2,dataout2);

process(clk, Write_Sig, Read_Sig)
begin
if (rst = '1') then
    dataout1 <= (others => '0');
    dataout2 <= (others => '0');
    else 
    if(rising_edge(clk) and Write_Sig='1') 
    then endec3<='1';
        endec2 <='0';
        endec1 <= '0';
    elsif (falling_edge(clk) and Read_Sig='1') 
        then endec2<='1';
        endec1<='1';
        endec3 <='0';
    else 
end if;
end if;
end process;




end architecture;
