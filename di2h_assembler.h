#ifndef _DI2H_ASSEMBLER_H
#define _DI2H_ASSEMBLER_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAX_INSTR_LENGTH 32

#define M 0b00000
#define J 0b01000
#define H 0b10000
#define X 0b11000

// all instructions are 16-bit in size except STD, LDD, LDM
#define PUSH M + 0b000
#define POP M + 0b001
#define LDM M + 0b011   //32-bit instruction
#define LDD M + 0b111   //32-bit instruction
#define STD M + 0b100   //32-bit instruction
#define IN M + 0b101
#define OUT M + 0b110

#define JZ J + 0b001
#define JN J + 0b010
#define JC J + 0b011
#define CALL J + 0b100
#define JMP J + 0b101
#define RET J + 0b110
#define RTI J + 0b111

#define MOV H + 0b000
#define ADD H + 0b001
#define SUB H + 0b010
#define MUL H + 0b111
#define AND H + 0b100
#define OR H + 0b101
#define SHL H + 0b110
#define SHR H + 0b111

#define NOT X + 0b000
#define SETC X + 0b001
#define CLRC X + 0b010
#define NOP X + 0b011
#define INC X + 0b100
#define DEC X + 0b101

#define R0 0b000
#define R1 0b001
#define R2 0b010
#define R3 0b011
#define R4 0b100
#define R5 0b101
#define R6 0b110
#define R7 0b111

extern char *valid_regs[8] = {
    __STRING(R0),
    __STRING(R1),
    __STRING(R2),
    __STRING(R3),
    __STRING(R4),
    __STRING(R5),
    __STRING(R6),
    __STRING(R7)};

extern int valid_regs_code[8] = {
    R0, R1, R2, R3, R4, R5, R6, R7};

extern int two_regs_instr_code[6] = {
    MOV, ADD, MUL, SUB, AND, OR};

extern int one_reg_val_instr_code[5] = {
    SHL, SHR, LDM, LDD, STD};

extern int one_reg_instr_code[12] = {
    NOT, INC, DEC, OUT, IN, PUSH, POP, JZ, JN, JC, JMP, CALL};

extern int uni_instr_code[5] = {
    NOP, SETC, CLRC, RET, RTI};

#define TWO_REG_INSTR 0
#define ONE_REG_VAL_INSTR 1
#define ONE_REG_INSTR 2
#define UNI_INSTR 3

#define TWO_REG_INSTR_LENGTH 6
extern char *two_regs_instr[6] = {
    __STRING(MOV),
    __STRING(ADD),
    __STRING(MUL),
    __STRING(SUB),
    __STRING(AND),
    __STRING(OR)};

#define ONE_REG_VAL_INSTR_LENGTH 5
extern char *one_reg_val_instr[5] = {
    __STRING(SHL),
    __STRING(SHR),
    __STRING(LDM),
    __STRING(LDD),
    __STRING(STD)};

#define ONE_REG_INSTR_LENGTH 12
extern char *one_reg_instr[12] = {
    __STRING(NOT),
    __STRING(INC),
    __STRING(DEC),
    __STRING(OUT),
    __STRING(IN),
    __STRING(PUSH),
    __STRING(POP),
    __STRING(JZ),
    __STRING(JN),
    __STRING(JC),
    __STRING(JMP),
    __STRING(CALL)};

#define UNI_INSTR_LENGTH 5
extern char *uni_instr[5] = {
    __STRING(NOP),
    __STRING(SETC),
    __STRING(CLRC),
    __STRING(RET),
    __STRING(RTI),
};

char **
read_program(char *file_path, int *instr_count);

char ***parse_program(char **program, int instr_count);

int *gen_code(char ***program, int instr_count);

int get_reg_address(char *reg);

int get_instr_type(char *instr_str, int *instr);

#endif