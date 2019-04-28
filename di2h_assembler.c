#include <stdio.h>
#include <string.h>

#define M 0b00
#define J 0b01
#define H 0b10
#define X 0b11

#define PUSH 0b000
#define POP 0b001
#define LDM 0b011 
#define LDD 0b111
#define STD 0b100
#define IN 0b101
#define OUT 0b110

#define JZ 0b001
#define JN 0b010
#define JC 0b011
#define CALL 0b100
#define JMP 0b101
#define RET 0b110
#define RTI 0b111

#define MOV 0b001
#define ADD 0b001
#define SUB 0b010
#define MUL 0b111
#define AND 0b100
#define OR 0b101
#define SHL 0b110
#define SHR 0b111

#define NOT 0b000
#define SETC 0b001
#define CLRC 0b010
#define NOP 0b011
#define INC 0b100
#define DEC 0b101

char** program;

int main(int argc, char **argv)
{
    
    printf("%d \n", X);
}

