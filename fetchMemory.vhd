Library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity FetchMemoryUnit is 
port(
	clock, reset, INT: in std_logic;
	new_pc: in std_logic_vector(31 downto 0);
	inport : in std_logic_vector(15 downto 0);
	outport : out std_logic_vector(15 downto 0);
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
signal pc_change_enable, stall_mul,stall_rti,stall_ret,stall_INT,stall_ld,out_type: std_logic;


signal push_sig, pop_sig, ret_rti, jmp_enable, fetch_enable: std_logic;
signal jmp_type: std_logic_vector(1 downto 0);
signal dec_ex_effective_address, dec_ex_pc: std_logic_vector(19 downto 0);

signal dec_ex_sp: std_logic_vector(31 downto 0);
signal regFileOutData1, regFileOutData2, fwd_data1, fwd_data2: std_logic_vector(15 downto 0); 
signal sp_add1, sp_add2, sp_sub1, sp_sub2: std_logic;
signal sp_value: std_logic_vector(31 downto 0);

--------------------- intermediate buffers signals -------------------------------------------------------------------
signal  bufferedInstruction: std_logic_vector(31 downto 0);
Signal inFetchDecodeBuffer : std_logic_vector(15 downto 0);
signal fetchDecBuffDataIn, fetchDecBuffDataOut: std_logic_vector(47 downto 0);
signal decExBuffDataIn, decExBuffDataOut: std_logic_vector(152 downto 0);
signal exMemBuffDataIn, exMemBuffDataOut: std_logic_vector(182 downto 0);
signal MemWBBuffDataIn, MemWBBuffDataOut: std_logic_vector(128 downto 0);

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
signal mem_read, mem_write: std_logic;

begin
mem_write <= exMemBuffDataOut(129);
mem_read <= fetch_enable or exMemBuffDataOut(130);
fetch_dec_buffRst <= reset;
fetch_dec_buffEn <= '1';
dec_ex_buffRst <= reset;
dec_ex_buffEn <= '1';
jmp_enable <= '0';
buffsClk <= not clock;

dec_ex_effective_address(19 downto 13)<= bufferedInstruction(7 downto 1);
dec_ex_effective_address(12 downto 0) <= bufferedInstruction(31 downto 19); 
readAddress1 <= bufferedInstruction(10 downto 8); --destination address
readAddress2 <= bufferedInstruction(7 downto 5); --- source address
writeAddress <= bufferedInstruction(10 downto 8); ---destination is the first oeprand

--- Fetch to Decode buffer

 
---- Decode to Execute data buffer
decExBuffDataIn(128 downto 125) <= bufferedInstruction(4 downto 1);
decExBuffDataIn(112 downto 110)  <= jmp_type & ret_rti;
decExBuffDataIn(109 downto 90) <= dec_ex_effective_address;
decExBuffDataIn(89 downto 70) <= dec_ex_pc;
decExbuffDataIn(69 downto 38) <= dec_ex_sp;
decExBuffDataIn(37 downto 19) <= readAddress1 & regFileOutData1; --- DST address and value
decExBuffDataIn(18 downto 0) <= readAddress2 & regFileOutData2; --- SRC address and value

---- Execute to Memory Data Buffer
exMemBuffDataIn(166)<= decExBuffDataOut(129);			----- decode to execute mul signal
exMemBuffDataIn(165 downto 134)<= alu_result;
exMemBuffDataIn(133 downto 131) <= flags_result;
exMemBuffDataIn(130 downto 125) <= decExBuffDataOut(119 downto 116) & decExBuffDataOut(110) & jmp_enable; --Memrd, memwr, memtoreg, wb_en, ret_rti, jmp_enable
exMemBuffDataIn(124 downto 106) <= decExBuffDataOut(18 downto 0) ; -- SRC address and value
exMemBuffDataIn(105 downto 87) <= decExBuffDataOut(37 downto 19); -- DST address and value
exMemBuffDataIn(86 downto 67) <= decExBuffDataOut(89 downto 70); --PC
exMemBuffDataIn(66 downto 35) <= decExbuffDataOut(69 downto 38); --SP
exMemBuffDataIn(34 downto 15) <= decExBuffDataOut(109 downto 90); -- Effective Address
exMemBuffDataIn(14) <= decExBuffDataOut(129);
exMemBuffDataIn(13 downto 9)<= decExBuffDataOut(124 downto 120); --opcode
exMemBuffDataIn(8 downto 0) <= (others => '0');

--exMemBuffDataOut(116) = write back enable

---- Memory to write back buffer
MemWBBuffDataIn(128 downto 113) <= fromMemory(31 downto 16);
MemWBBuffDataIn(112 downto 108) <= exMemBuffDataOut(13 downto 9); -----opcode
MemWBBuffDataIn(107 downto 92) <= exMemBuffDataOut(182 downto 167);
MemWBBuffDataIn(87 downto 72) <= exMemBuffDataOut(34 downto 19); --Effective address/Immvalue
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
pc_change_enable,									-----------pc change enable		
INT, 											-----------INT
jmp_enable,
mem_zero,
mem_one,
fromMemory(31 downto 16),
fromMemory(15 downto 0),
new_pc, 
fromFetch, 
fetchedInstruction); 
--JMP_RESULT should come from the buffer 

fetchDecBuffDataIn <= inport&fetchedInstruction;
fetchDecodeBuff: entity work.nbit_register generic map(48) port map(fetchDecBuffDataIn, buffsClk, reset, '1', fetchDecBuffDataOut);
bufferedInstruction <= fetchDecBuffDataOut(31 downto 0);
------------------------------------------------------------------- decode stage ---------------------------------------------------------
--------------------------------------------- control unit
controlUnit: entity work.Control_Unit port map(
bufferedInstruction(15 downto 11),     		                                ----------in opcode
decExBuffDataIn(124 downto 120), 			                        ----------out opcode
decExBuffDataIn(114), 								----------alu src
decExBuffDataIn(116),								----------write back enable
decExBuffDataIn(115),								----------alu enable
decExBuffDataIn(113), 								----------jmp enable
decExBuffDataIn(117),								----------memtoReg
decExBuffDataIn(118),								----------memWrite
decExBuffDataIn(119),								----------memRead
push_sig,									----------push signal
pop_sig, 									----------pop signal
decExBuffDataIn(132),								----------setc
decExBuffDataIn(133),								----------clrc
decExBuffDataIn(134),								----------not
decExBuffDataIn(130),								----------inc
decExBuffDataIn(131),								----------dec
decExBuffDataIn(129),								----------multiply signal
decExBuffDataIn(135),								----------h_type
out_type);
---------------------------------------------------------------- register file
MemWB_wb <= MemWBBuffDataOut(39);
MemWB_write_addr <= MemWBBuffDataOut(38 downto 36);
registerFile: entity work.Register_File port map(
'1',															----------read enable
MemWB_wb, 												----------write enable
clock, reset, MemWBBuffDataOut(0),													----------clock and reset
readAddress1, readAddress2,						----------read address of src and dst
MemWB_write_addr, 									----------write address
MemWBBuffDataOut(19 downto 17),												--------multiply second write address.
regInData,									----------register input data
MemWBBuffDataOut(16 downto 1),
regFileOutData1, regFileOutData2);			----------register output data

decExBuffDataIn(151 downto 136) <= fetchDecBuffDataOut(47 downto 32);
decExBuffDatain(152) <= out_type;
decodeExecuteBuff: entity work.nbit_register generic map(153) port map(decExBuffDataIn, buffsClk, reset,'1', decExBuffDataOut);

-- Set the output port.
outport <= fwd_data2 when decExBuffDataOut(152) = '1'
		else (others => 'Z');

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
fwd_data1,  											--------source value
fwd_data2,											--------destination value
DecEx_sh_amount, 										--------shift amount
alu_result, flags_result);

exMemBuffDataIn (182 downto 167) <= decExBuffDataOut(151 downto 136);
executeMemoryBuff: entity work.nbit_register generic map(183) port map(exMemBuffDataIn, buffsClk, reset,'1', exMemBuffDataOut);

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
MemoryWritebackBuff: entity work.nbit_register generic map(129) port map(MemWBBuffDataIn, buffsClk, reset,'1', MemWBBuffDataOut);


regInData <= MemWBBuffDataOut(55 downto 40) when MemWBBuffDataOut(112) = '1'
						else MemWBBuffDataOut(87 downto 72) when MemWBBuffDataOut(112 downto 108) = "00011"
						else MemWBBuffDataOut(128 downto 113) when (MemWBBuffDataOut(112 downto 108) = "00001" or MemWBBuffDataOut(112 downto 108) = "00111")
						else MemWBBuffDataOut(107 downto 92) when MemWBBUffDataOut(112 downto 108) = "00101";


---------------------------------------------------------------------------Hazard Detection Unit ----------------------------------------------------------
hdu: entity work.Hazard_detection_unit port map(
	exMemBuffDataOut(129),						----Ex_M_memwrite
	exMemBuffDataOut(130),						----Ex_M_memread
	decExBuffDataOut(119),							----dec_ex_memread
	decExBuffDataOut(116),							----dec_ex_writeback
	decExBuffDataOut(37 downto 35),			----dec_ex_DST
	exMemBuffDataOut(124 downto 122),	----ex_mem_SRC
	exMemBuffDataOut(105 downto 103),	----ex_mem_DST
	decExBuffDataOut(129),							----multiply signal
	INT,															----interrupt signal
	exMemBuffDataOut(110),						----ex_mem_ret								
	exMemBuffDataOut(110),						----ex_mem_rti
    bufferedinstruction(15 downto 11),	     -----Opcode
	decExBuffDataOut(18 downto 16),              ------DtoEx_rsrc
	fetch_enable,				     ----fetch_enable
	pc_change_enable,			     ----pc_change_enable
	stall_mul,				     ----stall mul signal
	stall_ret,			             ----stall ret signal
	stall_rti,				     ----stall rti signal								
	stall_int,	
	stall_ld						----stall int signal
);

----------------------------------------------------- Forwarding Unit -----------------------------------------------------------------------------
fu: entity work.Fwd_unit port map (
exMemBuffDataOut(165 downto 150),					----EtoM_src_val
exMemBuffDataOut(149 downto 134),					----EtoM_dst_val
exMemBuffDataOut(124 downto 122),					----EtoM_src_addr
exMemBuffDataOut(105 downto 103),					----EtoM_dst_addr
MemWBBuffDataOut(35 downto 20),				----MtoWB_src_val
MemWBBuffDataOut(16 downto 1),				----MtoWb_dst_val
MemWBBuffDataOut(38 downto 36),				----MtoWb_src_addr
MemWBBuffDataOut(19 downto 17),				----MtoWb_src_addr
decExBuffDataOut(15 downto 0),					----DtoEx_src_val
decExBuffDataOut(34 downto 19),					----DtoEx_dst_val
decExBuffDataOut(18 downto 16),					----DtoEx_src_addr
decExBuffDataOut(37 downto 35),					----DtoEx_dst_addr
exMemBuffDataOut(127),					----EtoM_wb
MemWBBuffDataOut(39),				----MtoWB_wb
MemWBBuffDataOut(0),				----MtoWB_mul
exMemBuffDataOut(129),					----EtoM_mul
fwd_data1,									----fwd_data1
fwd_data2									----fwd_data2
);

------------------------------------------------------------ Stack pointer --------------------------------------------------------------------
stack_pointer: entity work.StackPointer port map(
clock,
sp_add1,
sp_add2,
sp_sub1,
sp_sub2,
reset,
sp_value
);

end Architecture;




