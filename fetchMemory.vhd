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
memWrite, MemRead, push_sig, pop_sig, ret_rti, jmp_result, multiply: std_logic;

signal jmp_type: std_logic_vector(1 downto 0);
signal dec_ex_effective_address,
	dec_ex_pc: std_logic_vector(19 downto 0);

signal dec_ex_sp: std_logic_vector(31 downto 0);

signal regFileOutData1, regFileOutData2: std_logic_vector(15 downto 0); 

signal decExBuffDataIn, decExBuffDataOut: std_logic_vector(129 downto 0);

signal exMemBuffDataIn, exMemBuffDataOut: std_logic_vector(165 downto 0);

signal dec_ex_src_addr, dec_ex_dst_addr: std_logic_vector(2 downto 0);
signal dec_ex_src_val, dec_ex_dst_val: std_logic_vector(15 downto 0);
signal sh_amount: std_logic_vector(3 downto 0);
signal alu_result: std_logic_vector(31 downto 0);
signal flags_result: std_logic_vector(2 downto 0); -- Z N C
signal mem_zero,mem_one: std_logic_vector(31 downto 0); -- Memory(0) instruction and Memory(1) instruction

begin

fetch_dec_buffRst <= reset;
fetch_dec_buffEn <= '1';
dec_ex_buffRst <= reset;
dec_ex_buffEn <= '1';

readAddress1 <= bufferedInstruction(10 downto 8);
readAddress2 <= bufferedInstruction(7 downto 5);
writeAddress <= bufferedInstruction(7 downto 5);
 
decExBuffDataIn(129) <= multiply; -- Should be output from the decode circuit
decExBuffDataIn(128 downto 125) <= sh_amount;
decExBuffDataIn(124 downto 120) <= opcode;
decExBuffDataIn(119 downto 116) <= MemRead & MemWrite & memToReg & wb_en; 
decExBuffDataIn(115 downto 114)  <= alu_en & alu_src;
decExBuffDataIn(113 downto 110)  <= jmp_en & jmp_type & ret_rti;
decExBuffDataIn(109 downto 90) <= dec_ex_effective_address;
decExBuffDataIn(89 downto 70) <= dec_ex_pc;
decExbuffDataIn(69 downto 38) <= dec_ex_sp;
decExBuffDataIn(37 downto 19) <= dec_ex_src_addr & dec_ex_src_val;
decExBuffDataIn(18 downto 0) <= dec_ex_dst_addr & dec_ex_dst_val;


exMemBuffDataIn(165 downto 134)<= alu_result;
exMemBuffDataIn(133 downto 131) <= flags_result;
exMemBuffDataIn(130 downto 125) <= decExBuffDataOut(119 downto 116) & decExBuffDataOut(110) & jmp_result; --Memrd, memwr, memtoreg, wb_en, ret_rti, jmp_enable
exMemBuffDataIn(124 downto 106) <= decExBuffDataOut(18 downto 0) ; -- DEST address and DEST value
exMemBuffDataIn(105 downto 87) <= decExBuffDataOut(37 downto 19); -- SRC address SRC value
exMemBuffDataIn(86 downto 67) <= decExBuffDataOut(89 downto 70); --PC
exMemBuffDataIn(66 downto 35) <= decExbuffDataOut(69 downto 38); --SP
exMemBuffDataIn(34 downto 15) <= decExBuffDataOut(109 downto 90); -- Effective Address
exMemBuffDataIn(14) <= decExBuffDataOut(129);
exMemBuffDataIn(13 downto 0)<= (others=>'0');

tristateBuffer: entity work.tristate port map(fromMemory,dataBus,fetch_enable);

memory: entity work.memory_unit generic map(32,20) port map(fromMemory,mem_zero, mem_one,
fromFetch(19 downto 0),clock,reset,mem_write, mem_read);

fetch: entity work.FetchUnit port map(clock, fetch_enable, reset,'1','0', 
jmp_result,mem_zero,mem_one,
fromMemory(15 downto 0),fromMemory(31 downto 16), new_pc, 
fromFetch, fetchedInstruction); --JMP_RESULT should come from the buffer 

fetchDecodeBuff: entity work.nbit_register generic map(32) port map(
fetchedInstruction, 
clock, fetch_dec_buffRst, fetch_dec_buffEn, bufferedInstruction);

controlUnit: entity work.Control_Unit port map(bufferedInstruction(15 downto 11),
opcode, alu_src, wb_en, alu_en, jmp_en, 
memToReg, memWrite, MemRead, push_sig, pop_sig);

registerFile: entity work.Register_File port map(regFileRead, regFileWrite, 
clock, reset, readAddress1, readAddress2, writeAddress, 
regInData, regFileOutData1, regFileOutData2);


decodeExecuteBuff: entity work.nbit_register generic map(130) port map(decExBuffDataIn, clock, reset,'1', decExBuffDataOut);
executeMemoryBuff: entity work.nbit_register generic map(166) port map(exMemBuffDataIn, clock, reset,'1', exMemBuffDataOut);

ALU: entity work.ArithmeticLogicUnit port map(decExBuffDataOut(15), clock, reset,
 decExBuffDataOut(121 downto 119), decExBuffDataOut(33 downto 18), decExBuffDataOut(15 downto 0),
 decExBuffDataOut(127 downto 124), alu_result, flags_result);

program_counter<=fromFetch;

end Architecture;

