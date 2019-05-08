Library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity FetchMemoryUnit is 
port(	clock, reset, fetch_enable, mem_write, mem_read: in std_logic;
	new_pc: in std_logic_vector(31 downto 0);
	memory1_location : in std_logic_vector(31 downto 0); -- instruction in memory[1] location
	program_counter: out std_logic_vector(31 downto 0)

);
end entity;

Architecture fetching of FetchMemoryUnit is

signal dataBus : std_logic_vector(31 downto 0);
signal fromMemory: std_logic_vector(31 downto 0);
signal fromFetch: std_logic_vector(31 downto 0);
signal fetchedInstruction: std_logic_vector(31 downto 0);
signal readAddress1, readAddress2, writeAddress: std_logic_vector(2 downto 0);
signal regInData: std_logic_vector(15 downto 0);


signal push_sig, pop_sig, ret_rti, jmp_result: std_logic;
signal jmp_type: std_logic_vector(1 downto 0);
signal dec_ex_effective_address, dec_ex_pc: std_logic_vector(19 downto 0);

signal dec_ex_sp: std_logic_vector(31 downto 0);
signal regFileOutData1, regFileOutData2: std_logic_vector(15 downto 0); 

--------------------- intermediate buffers signals -------------------------------------------------------------------
signal  bufferedInstruction: std_logic_vector(31 downto 0);
signal decExBuffDataIn, decExBuffDataOut: std_logic_vector(135 downto 0);
signal exMemBuffDataIn, exMemBuffDataOut: std_logic_vector(166 downto 0);
signal MemWBBuffDataIn, MemWBBuffDataOut: std_logic_vector(91 downto 0);

--------------- buffers reset signals and enables
signal fetch_dec_buffRst, fetch_dec_buffEn, dec_ex_buffRst, dec_ex_buffEn, buffsClk: std_logic;
-------------------------------------------------------------------------------------------------------------------------------

signal alu_result: std_logic_vector(31 downto 0);
signal flags_result: std_logic_vector(2 downto 0); -- Z N C
signal mem_zero,mem_one: std_logic_vector(15 downto 0); -- Memory(0) instruction and Memory(1) instruction

signal MemWB_wb, DecEx_setc, DecEx_clrc, DecEx_inc, DecEx_dec, DecEx_not, DecEx_htype, DecEx_alu_en: std_logic;
signal MemWB_write_addr, htype_op: std_logic_vector(2 downto 0);
signal DecEx_src_val, DecEx_dst_val: std_logic_vector(15 downto 0);
signal DecEx_sh_amount: std_logic_vector(3 downto 0);
signal bufferedInstructionOrg: std_logic_vector(31 downto 0);

begin

fetch_dec_buffRst <= reset;
fetch_dec_buffEn <= '1';
dec_ex_buffRst <= reset;
dec_ex_buffEn <= '1';
jmp_result <= '0';
buffsClk <= not clock;

dec_ex_effective_address(19 downto 13)<= bufferedInstruction(7 downto 1);
dec_ex_effective_address(12 downto 0) <= bufferedInstruction(31 downto 19); 
readAddress1 <= bufferedInstruction(10 downto 8); --destination address
readAddress2 <= bufferedInstruction(7 downto 5); --- source address
writeAddress <= bufferedInstruction(10 downto 8); ---destination is the first oeprand
 
---- Decode to Execute data buffer
decExBuffDataIn(128 downto 125) <= bufferedInstruction(4 downto 1);
decExBuffDataIn(112 downto 110)  <= jmp_type & ret_rti;
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
MemWBBuffDataIn(91 downto 72) <= exMemBuffDataOut(34 downto 15); --Effective address/Immvalue
MemWBBuffDataIn(71 downto 40) <= exMembuffDataOut(165 downto 134); -- ALU result
MemWBBuffDataIn(39) <= exMemBuffDataout(127);--WB
MemWBBuffDataIn(38 downto 20) <=exMemBuffDataout(105 downto 87); --Dest address and value
MemWBBuffDataIn(19 downto 1) <= exMemBuffDataout(124 downto 106);--Src address and value
MemWBBuffDataIn(0)<= exMemBuffDataOut(166);--MUL




------------------------------------------------------------------- fetch stage -------------------------------------------------------------- 

program_counter<=fromFetch;
---------------------------------- fetch unit
fetch: entity work.FetchUnit port map(
clock, 
fetch_enable, 
reset,
'1',															-----------pc change enable		
'0', 															-----------jmp enable
jmp_result,
mem_zero,
mem_one,
fromMemory(31 downto 16),
fromMemory(15 downto 0),
new_pc, 
fromFetch, 
fetchedInstruction); 
--JMP_RESULT should come from the buffer 

bufferedInstructionOrg(31 downto 16) <= fetchedInstruction(15 downto 0);
fetchDecodeBuff: entity work.nbit_register generic map(32) port map(fetchedInstruction, buffsClk, reset, '1', bufferedInstruction);

------------------------------------------------------------------- decode stage ---------------------------------------------------------
--------------------------------------------- control unit
controlUnit: entity work.Control_Unit port map(
bufferedInstruction(15 downto 11),     		----------in opcode
decExBuffDataIn(124 downto 120), 			----------out opcode
decExBuffDataIn(114), 								----------alu src
decExBuffDataIn(116),								----------write back enable
decExBuffDataIn(115),								----------alu enable
decExBuffDataIn(113), 								----------jmp enable
decExBuffDataIn(117),								----------memtoReg
decExBuffDataIn(118),								----------memWrite
decExBuffDataIn(119),								----------memRead
push_sig,														----------push signal
pop_sig, 														----------pop signal
decExBuffDataIn(132),								----------setc
decExBuffDataIn(133),								----------clrc
decExBuffDataIn(134),								----------not
decExBuffDataIn(130),								----------inc
decExBuffDataIn(131),								----------dec
decExBuffDataIn(129),								----------multiply signal
decExBuffDataIn(135));								----------h_type

---------------------------------------------------------------- register file
MemWB_wb <= MemWBBuffDataOut(39);
MemWB_write_addr <= MemWBBuffDataOut(38 downto 36);
registerFile: entity work.Register_File port map(
'1',																----------read enable
MemWB_wb, 												----------write enable
clock, reset,													----------clock and reset
readAddress1, readAddress2,						----------read address of src and dst
MemWB_write_addr, 									----------write address
regInData,													----------register input data
regFileOutData1, regFileOutData2);			----------register output data

decodeExecuteBuff: entity work.nbit_register generic map(136) port map(decExBuffDataIn, buffsClk, reset,'1', decExBuffDataOut);

--------------------------------------------------------- Execute Stage ------------------------------------------------------------------

DecEx_setc <= decExBuffDataOut(132);
DecEx_clrc <= decExBuffDataOut(133);
DecEx_inc <= decExBuffDataOut(130);
DecEx_dec <= decExBuffDataOut(131);
DecEx_not <= decExBuffDataOut(134);
DecEx_htype <= decExBuffDataOut(135);
DecEx_alu_en <= decExBuffDataOut(115);
htype_op <= decExBuffDataOut(122 downto 120);
DecEx_src_val <= decExBuffDataOut(15 downto 0);
DecEx_dst_val <= decExBuffDataOut(34 downto 19);
DecEx_sh_amount <= decExBuffDataOut(128 downto 125);

------------------------------  ALU
ALU: entity work.ArithmeticLogicUnit port map(
DecEx_alu_en,  											--------alu enable
clock, reset,													--------clock and reset
DecEx_setc,													--------setc
DecEx_clrc, 													--------clrc
DecEx_inc, 													--------inc
DecEx_dec, 													--------dec
DecEx_not, 													--------not
DecEx_htype, 												--------operations is h type
htype_op, 													--------operation of h type
DecEx_src_val,  											--------source value
DecEx_dst_val,											--------destination value
DecEx_sh_amount, 										--------shift amount
alu_result, flags_result);

executeMemoryBuff: entity work.nbit_register generic map(167) port map(exMemBuffDataIn, buffsClk, reset,'1', exMemBuffDataOut);

-------------------------------------------------------- Memory Stage -------------------------------------------------------------
tristateBuffer: entity work.tristate port map(fromMemory,dataBus,fetch_enable);

------------------------memory unit
memory: entity work.memory_unit 
generic map(16,20) port map(
fromMemory(31 downto 16),
mem_zero, 
mem_one, 
fromMemory(15 downto 0),
fromFetch(19 downto 0),
clock,
reset,
mem_write, 
mem_read);

---------------------------------------------------- Write back stage --------------------------------------------------------------
MemoryWritebackBuff: entity work.nbit_register generic map(92) port map(MemWBBuffDataIn, buffsClk, reset,'1', MemWBBuffDataOut);
regInData <= MemWBBuffDataOut(55 downto 40); --------------------- write data to reg file

end Architecture;




