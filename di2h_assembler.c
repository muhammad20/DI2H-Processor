#include "di2h_assembler.h"

int main(int argc, char **argv)
{
    int instr_count;
    char **prog = read_program("test_prog.di2hasm", &instr_count);

    // char* x = "0xFFFF";
    // int y;
    // y = parse_imm_ea_val(x, y);
    // printf("num: %d \n", y);

    printf("\n");
    char ***di2hasm_code = parse_program(prog, instr_count);
    for (int i = 0; i < instr_count; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            if (di2hasm_code[i][j] != NULL)
            {
                printf("%s ", di2hasm_code[i][j]);
            }
        }
        printf("\n");
    }

    int *arr = gen_code(di2hasm_code, instr_count);
    for (int i = 0; i < instr_count; i++)
    {
        printf("%x\n", arr[i]);
    }
    return 0;
}

//read program from file and store it in a instruction array
char **read_program(char *file_path, int *instr_cnt)
{
    FILE *fp;
    fp = fopen(file_path, "r");

    if (!fp)
    {
        perror("Error while opening the file");
        exit(EXIT_FAILURE);
    }

    char **prog;
    int instr_count = 0;
    char line[MAX_INSTR_LENGTH];

    // get number of instructions in file
    while (fgets(line, sizeof line, fp) != NULL)
    {
        instr_count++;
    }
    *instr_cnt = instr_count;

    //allocate an array of strings to store the program
    prog = malloc(instr_count * sizeof(char *));
    fseek(fp, 0, 0);

    //store each instructions from the file to an entry in the prog array
    for (int i = 0; i < instr_count; i++)
    {
        prog[i] = malloc(sizeof(char *) * MAX_INSTR_LENGTH);
        fgets(prog[i], sizeof line, fp);
    }
    fclose(fp);
    return prog;
}

int *gen_code(char ***str_code, int instr_count)
{
    int *machine_code = malloc(instr_count * sizeof(int));
    int curr_instr_type;
    int curr_instr;
    int instruction;
    int instr_class; //either M or J or H or X
    int src;
    int dst;
    for (int i = 0; i < instr_count; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            if (j == 0)
            {
                curr_instr_type = get_instr_type(str_code[i][j], &curr_instr);
                instruction = curr_instr;
                instruction <<= 11;
                if (curr_instr == -1)
                    return NULL;
            }
            if (j == 1)
            {
                if (curr_instr_type == UNI_INSTR)
                    j = 3;
                else
                {
                    src = get_reg_address(str_code[i][j]);
                    if (src == -1)
                        return NULL;
                    src <<= 8;
                    instruction += src;
                }

                if (j != 3)
                {
                    //whether the instruction is 32-bit or not
                    if (curr_instr == LDD || curr_instr == LDM || curr_instr == STD)
                    {
                        //set next bit = 1
                        instruction++;
                        instruction <<= 16;
                    }
                }
            }
            if (j == 2)
            {
                switch (curr_instr_type)
                {
                case ONE_REG_VAL_INSTR:
                    //parse the value
                    break;
                case TWO_REG_INSTR:
                    dst = get_reg_address(str_code[i][j]);
                    if (dst == -1)
                        return NULL;
                    dst <<= 5;
                    break;
                }
                instruction += dst;
            }
        }
        machine_code[i] = instruction;
    }
    return machine_code;
}

int parse_imm_ea_val(char *imm_ea, int instr)
{
    int length = 0;
    while (imm_ea[length] != '\0')
    {
        length++;
    }
    char *clean_val = malloc(length * sizeof(char));
    if (length > 2)
    {
        short type = 1; // 0 --> binary, 1-->hex and nothing else
        if (imm_ea[1] != 'b' && imm_ea[1] != 'x')
        {
        }
    }
}

int get_reg_address(char *str_reg)
{
    int reg;
    for (int i = 0; i < 8; i++)
        if (strcmp(str_reg, valid_regs[i]) == 0)
        {
            reg = valid_regs_code[i];
            return reg;
        }

    return -1;
}

int get_instr_type(char *instr_str, int *instr)
{
    int curr_instr_type;
    for (int k = 0; k < 4; k++)
    {
        switch (k)
        {
        case TWO_REG_INSTR:
            for (int c = 0; c < TWO_REG_INSTR_LENGTH; c++)
            {
                if (strcmp(instr_str, two_regs_instr[c]) == 0)
                {
                    curr_instr_type = TWO_REG_INSTR;
                    *instr = two_regs_instr_code[c];
                    k = 4;
                    break;
                }
            }
            break;
        case ONE_REG_VAL_INSTR:
            for (int c = 0; c < ONE_REG_VAL_INSTR_LENGTH; c++)
            {
                if (strcmp(instr_str, one_reg_instr[c]) == 0)
                {
                    curr_instr_type = ONE_REG_INSTR;
                    *instr = one_reg_val_instr_code[c];
                    k = 4;
                    break;
                }
            }
            break;
        case ONE_REG_INSTR:
            for (int c = 0; c < ONE_REG_INSTR_LENGTH; c++)
            {
                if (strcmp(instr_str, one_reg_instr[c]) == 0)
                {
                    curr_instr_type = ONE_REG_INSTR;
                    *instr = one_reg_instr_code[c];
                    k = 4;
                    break;
                }
            }
            break;
        case UNI_INSTR:
            for (int c = 0; c < UNI_INSTR_LENGTH; c++)
            {
                if (strcmp(instr_str, uni_instr[c]) == 0)
                {
                    curr_instr_type = UNI_INSTR;
                    *instr = uni_instr_code[c];
                    k = 4;
                    break;
                }
            }
            break;
        default:
            printf("instruction invalid\n");
            *instr = -1;
            return -1;
        }
    }
    return curr_instr_type;
}

char ***parse_program(char **program, int instr_count)
{
    char ***di2hasm_code = malloc(instr_count * sizeof(char **));
    int end;
    int start;
    int offset;
    for (int i = 0; i < instr_count; i++)
    {
        start = 0;
        end = 0;
        di2hasm_code[i] = malloc(3 * sizeof(char *));
        for (int j = 0; j < 3; j++)
        {
            offset = 0;
            while (program[i][end] != ' ' && program[i][end] != '\n' && program[i][end] != '\0' && program[i][end] != ',')
            {
                end++;
                offset++;
            }
            di2hasm_code[i][j] = malloc((offset + 1) * sizeof(char));
            memcpy(di2hasm_code[i][j], &program[i][start], offset);
            di2hasm_code[i][j][offset] = '\0';
            if (program[i][end] == '\n' || program[i][end] == '\0')
            {
                if (j < 2)
                    di2hasm_code[i][2] = NULL;
                if (j == 0)
                    di2hasm_code[i][1] = NULL;
                break;
            }
            end++;
            if (program[i][end] == ' ')
                end++;
            start = end;
        }
    }
    return di2hasm_code;
}