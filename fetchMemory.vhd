Library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity FetchMemoryUnit is 
port(	clock, reset, fetch_enable, mem_write, mem_read: in std_logic;
	new_pc: in std_logic_vector(31 downto 0);
	instruction_selectors: in std_logic_vector(1 downto 0);
	memory1_location : in std_logic_vector(31 downto 0); -- instruction in memory[1] location
	program_counter: out std_logic_vector(31 downto 0)

);
end entity;

Architecture fetching of FetchMemoryUnit is

signal dataBus : std_logic_vector(31 downto 0);
signal fromMemory: std_logic_vector(31 downto 0);
signal fromFetch: std_logic_vector(31 downto 0);
signal fetch_dec_buffRst, fetch_dec_buffEn, dec_ex_buffRst, dec_ex_buffEn: std_logic;
signal fetchedInstruction, bufferedInstruction: std_logic_vector(31 downto 0);
signal regFileRead, regFileWrite: std_logic;
signal readAddress1, readAddress2, writeAddress: std_logic_vector(2 downto 0);
signal regInData: std_logic_vector(15 downto 0);
signal opcode: std_logic_vector(4 downto 0);


signal alu_src, wb_en, alu_en, jmp_en, memToReg, 
memWrite, MemRead, push_sig, pop_sig, ret_rti, jmp_result, 
multiply, setc, clrc, inc, dec, not_op, h_type: std_logic;

signal jmp_type: std_logic_vector(1 downto 0);
signal dec_ex_effective_address,
	dec_ex_pc: std_logic_vector(19 downto 0);

signal dec_ex_sp: std_logic_vector(31 downto 0);

signal regFileOutData1, regFileOutData2: std_logic_vector(15 downto 0); 

signal decExBuffDataIn, decExBuffDataOut: std_logic_vector(135 downto 0);

signal exMemBuffDataIn, exMemBuffDataOut: std_logic_vector(166 downto 0);
signal MemWBBuffDataIn, MemWBBuffDataOut: std_logic_vector(74 downto 0);

signal dec_ex_src_addr, dec_ex_dst_addr: std_logic_vector(2 downto 0);
signal dec_ex_src_val, dec_ex_dst_val: std_logic_vector(15 downto 0);
signal sh_amount: std_logic_vector(3 downto 0);
signal alu_result: std_logic_vector(31 downto 0);
signal flags_result: std_logic_vector(2 downto 0); -- Z N C
signal mem_zero,mem_one: std_logic_vector(15 downto 0); -- Memory(0) instruction and Memory(1) instruction

signal buffsClk: std_logic;

begin

fetch_dec_buffRst <= reset;
fetch_dec_buffEn <= '1';
dec_ex_buffRst <= reset;
dec_ex_buffEn <= '1';
jmp_result <= '0';
buffsClk <= not clock;

---- 
sh_amount <= bufferedInstruction(4 downto 1);
readAddress1 <= bufferedInstruction(10 downto 8); --destination address
readAddress2 <= bufferedInstruction(7 downto 5); --- source address
writeAddress <= bufferedInstruction(10 downto 8); ---destination is the first oeprand
 
---- Decode to Execute data buffer
decExBuffDataIn(135) <= h_type;
decExBuffDataIn(134) <= not_op;
decExBuffDataIn(133) <= clrc;
decExBuffDataIn(132) <= setc;
decExBuffDataIn(131) <= dec;
decExBuffDataIn(130) <= inc;
decExBuffDataIn(129) <= multiply; -- Should be output from the decode circuit
decExBuffDataIn(128 downto 125) <= sh_amount;
decExBuffDataIn(124 downto 120) <= opcode;
decExBuffDataIn(119 downto 116) <= MemRead & MemWrite & memToReg & wb_en; 
decExBuffDataIn(115 downto 114)  <= alu_en & alu_src;
decExBuffDataIn(113 downto 110)  <= jmp_en & jmp_type & ret_rti;
decExBuffDataIn(109 downto 90) <= dec_ex_effective_address;
decExBuffDataIn(89 downto 70) <= dec_ex_pc;
decExbuffDataIn(69 downto 38) <= dec_ex_sp;
decExBuffDataIn(37 downto 19) <= readAddress1 & regFileOutData1; --- DST address and value
decExBuffDataIn(18 downto 0) <= readAddress2 & regFileOutData2; --- SRC address and value

---- Execute to Memory Data Buffer
exMemBuffDataIn(166)<= decExBuffDataOut(129);
exMemBuffDataIn(165 downto 134)<= alu_result;
exMemBuffDataIn(133 downto 131) <= flags_result;
exMemBuffDataIn(130 downto 125) <= decExBuffDataOut(119 downto 116) & decExBuffDataOut(110) & jmp_result; --Memrd, memwr, memtoreg, wb_en, ret_rti, jmp_enable
exMemBuffDataIn(124 downto 106) <= decExBuffDataOut(18 downto 0) ; -- SRC address and value
exMemBuffDataIn(105 downto 87) <= decExBuffDataOut(37 downto 19); -- DST address and value
exMemBuffDataIn(86 downto 67) <= decExBuffDataOut(89 downto 70); --PC
exMemBuffDataIn(66 downto 35) <= decExbuffDataOut(69 downto 38); --SP
exMemBuffDataIn(34 downto 15) <= decExBuffDataOut(109 downto 90); -- Effective Address
exMemBuffDataIn(14) <= decExBuffDataOut(129);
exMemBuffDataIn(13 downto 0)<= (others=>'0');

--exMemBuffDataOut(118) = write back enable

---- Memory to write back buffer
MemWBBuffDataIn(74 downto 72) <= exMemBuffDataOut(105 downto 103); -- DST address
MemWBBuffDataIn(71 downto 40) <= exMembuffDataOut(165 downto 134); -- ALU result
MemWBBuffDataIn(39) <= exMemBuffDataout(127);--WB
MemWBBuffDataIn(38 downto 20) <=exMemBuffDataout(124 downto 106); --Dest address and value
MemWBBuffDataIn(19 downto 1) <= exMemBuffDataout(105 downto 87);--Src address and value
MemWBBuffDataIn(0)<= exMemBuffDataOut(166);--MUL

regInData <= MemWBBuffDataOut(55 downto 40);

tristateBuffer: entity work.tristate port map(fromMemory,dataBus,fetch_enable);

memory: entity work.memory_unit generic map(16,20) port map(fromMemory(31 downto 16),mem_zero, mem_one, 
fromMemory(15 downto 0), fromFetch(19 downto 0),clock,reset,mem_write, mem_read);

fetch: entity work.FetchUnit port map(clock, fetch_enable, reset,'1','0', 
jmp_result,mem_zero,mem_one,
fromMemory(31 downto 16),fromMemory(15 downto 0), new_pc, 
fromFetch, fetchedInstruction); --JMP_RESULT should come from the buffer 



controlUnit: entity work.Control_Unit port map(bufferedInstruction(15 downto 11),
opcode, alu_src, wb_en, alu_en, jmp_en, 
memToReg, memWrite, MemRead, push_sig, pop_sig, 
setc, clrc, not_op, inc, dec, multiply, h_type);

registerFile: entity work.Register_File port map('1', MemWBBuffDataOut(39), 
clock, reset, readAddress1, readAddress2, MemWBBuffDataOut(74 downto 72), 
regInData, regFileOutData1, regFileOutData2);

fetchDecodeBuff: entity work.nbit_register generic map(32) port map(fetchedInstruction, buffsClk, reset, '1', bufferedInstruction);
decodeExecuteBuff: entity work.nbit_register generic map(136) port map(decExBuffDataIn, buffsClk, reset,'1', decExBuffDataOut);
executeMemoryBuff: entity work.nbit_register generic map(167) port map(exMemBuffDataIn, buffsClk, reset,'1', exMemBuffDataOut);
MemoryWritebackBuff: entity work.nbit_register generic map(75) port map(MemWBBuffDataIn, buffsClk, reset,'1', MemWBBuffDataOut);

ALU: entity work.ArithmeticLogicUnit port map(decExBuffDataOut(115), clock, reset,
decExBuffDataOut(132),decExBuffDataOut(133),decExBuffDataOut(130),
decExBuffDataOut(131),decExBuffDataOut(134),decExBuffDataOut(135), 
 decExBuffDataOut(122 downto 120), decExBuffDataOut(15 downto 0), decExBuffDataOut(34 downto 19),
 decExBuffDataOut(128 downto 125), alu_result, flags_result);

program_counter<=fromFetch;

end Architecture;




