using System;
using System.Collections.Generic;
using System.IO;

namespace Assembler
{
    class Program
    {
        static void Main(string[] args)
        {
            var converter = new AssemblyConverter();
            
            converter.AssemblyConvert("MOV R0,R1");
            converter.AssemblyConvert("SHR R1, 15");
            
            converter.AssemblyConvert("RTI");
            converter.AssemblyConvert("JZ R0");
            
            converter.AssemblyConvert("SETC");
            converter.AssemblyConvert("INC R1");
            // string filename = args[0];
            // // Okay so we need to parse the input file.
            // using(var reader = new StreamReader(filename))
            // {
            //     // Get each line of the instructions, this is still assembly code.
            //     var assemblyInstruction = reader.ReadLine();
                
            //     // Convert this to our memory code.
                
            // }
        }
    }

    class AssemblyConverter
    {
        private Dictionary<string, string> _opCodeLookup;
        private Dictionary<string, string> _registerLookup;

        public AssemblyConverter()
        {
            // Initialize the lookup table of the opcode.
            InitializeOpCodeLookup();

            // Initialize the lookup table of the registers. 
            InitializeRegisterLookup();
        }

        private void InitializeRegisterLookup()
        {
            _registerLookup = new Dictionary<string, string>();

            _registerLookup["R0"] = "000";
            _registerLookup["R1"] = "001";
            _registerLookup["R2"] = "010";
            _registerLookup["R3"] = "011";
            _registerLookup["R4"] = "100";
            _registerLookup["R5"] = "101";
            _registerLookup["R6"] = "110";
            _registerLookup["R7"] = "111";
        }
        private void InitializeOpCodeLookup()
        {
            _opCodeLookup = new Dictionary<string, string>();
            
            // M-Type Instructions.
            _opCodeLookup["PUSH"] = "00000";
            _opCodeLookup["POP"] =  "00001";
            _opCodeLookup["LDD"] =  "00111";
            _opCodeLookup["LDM"] =  "00011";
            _opCodeLookup["STD"] =  "00100";
            _opCodeLookup["IN"] =   "00101";
            _opCodeLookup["OUT"] =  "00110";
            
            // J-Type Instructions.
            _opCodeLookup["JZ"] =   "01001";
            _opCodeLookup["JN"] =   "01010";
            _opCodeLookup["JC"] =   "01011";
            _opCodeLookup["CALL"] = "01100";
            _opCodeLookup["JMP"] =  "01101";
            _opCodeLookup["RET"] =  "01110";
            _opCodeLookup["RTI"] =  "01111";

            // H-Type Instructions
            _opCodeLookup["MOV"] = "10000";
            _opCodeLookup["ADD"] = "10001";
            _opCodeLookup["SUB"] = "10010";
            _opCodeLookup["MUL"] = "10011";
            _opCodeLookup["AND"] = "10100";
            _opCodeLookup["OR"]  = "10101";
            _opCodeLookup["SHL"] = "10110";
            _opCodeLookup["SHR"] = "10111";

            // X-Type Instructions
            _opCodeLookup["NOT"] =  "11000";
            _opCodeLookup["SETC"] = "11001";
            _opCodeLookup["CLRC"] = "11010";
            _opCodeLookup["NOP"]  = "11011";
            _opCodeLookup["INC"]  = "11100";
            _opCodeLookup["DEC"]  = "11101";
        }

        /// <summary> 
        /// Takes an assembly instruction as input and outputs the respective binary code for it.
        /// <param name="assembly">The whole instruction in assembly language</param>
        /// </summary>
        /// <returns>Returns a string of 0s and 1s representing the machine code </returns>  
        public string AssemblyConvert(string assembly)
        {
            string machineCode = "";
            
            // First extract the opcode from the assmebly.
            string opCode = this.ExtractOpCode(assembly);
            machineCode += _opCodeLookup[opCode.ToUpper()];

            // Check the type and identify the missing bits and pieces.
            var typeCode = $"{machineCode[0]}" + $"{machineCode[1]}";

            // Extract the instruction parts
            var instructionParts = this.ExtractInstructionParts(assembly);

            bool hasNext = false;

            switch (typeCode)
            {
                case "00":

                    break;
                case "01":
                    
                    switch(machineCode.Substring(2))
                    {
                        case "110":
                        case "111":
                            
                            break;
                        default:
                            machineCode += _registerLookup[instructionParts[0].ToUpper()];
                            break;
                    }

                    break;
                case "10":
                    
                    machineCode += _registerLookup[instructionParts[0]];
                    
                    // Shift instructions will use one register.
                    int immediateValue;
                    if(int.TryParse(instructionParts[1] , out immediateValue))
                    {
                        machineCode += "000";
                        string immediateValueBinary = Convert.ToString(immediateValue, 2);
                        if(immediateValueBinary.Length > 4)
                        {
                            throw new Exception("Invalid shift amount");
                        }
                        machineCode += immediateValueBinary;
                    }else 
                    {
                        machineCode += _registerLookup[instructionParts[1].ToUpper()];    
                    }

                    break;
                case "11":
                    if(_registerLookup.ContainsKey(instructionParts[0]))
                    {
                        machineCode += _registerLookup[instructionParts[0]];
                    }
                    break;
                default:
                    throw new Exception("Wrong op code");
            }
            
            if(machineCode.Length < 16)
            {
                machineCode = machineCode.PadRight(16, '0');
            } else 
            {

            }

            char[] arr = machineCode.ToCharArray();
            arr[15] = (char)(hasNext ? '1' : '0');
            machineCode = new string(arr);
            return machineCode;         
        }

        private string ExtractOpCode(string assembly)
        {
            string opCode;
            // Place the opcode.
            if(assembly.Contains(' ')){
                opCode = assembly.Substring(0, assembly.IndexOf(' '));

            }else {
                opCode = assembly;
            }
            return opCode;
        }

        private string[] ExtractInstructionParts(string assembly)
        {
            var instructionParts = assembly.Substring(assembly.IndexOf(' ') + 1).Split(',');
            for(int i = 0; i < instructionParts.Length; i++)
            {
                if(instructionParts[i].Contains(' '))
                {
                    instructionParts[i] = instructionParts[i].Replace(" ", string.Empty);
                }
            }
            return instructionParts;
        }
    }
}
