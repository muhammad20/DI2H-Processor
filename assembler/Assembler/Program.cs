﻿using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;

namespace Assembler
{
    class Program
    {
        private const double LASTMEMORYPOSITION = 1048575;
        static void Main(string[] args)
        {   
            var converter = new AssemblyConverter();

            string filename, outputFilename;

            if(args.Length == 0)
            {            
                filename = Path.Combine(Environment.CurrentDirectory, "test-cases\\test_forward.asm");
                outputFilename = Path.Combine(Environment.CurrentDirectory, "output\\output1.mem");
            } else 
            {
                filename = Path.Combine(Environment.CurrentDirectory, $"test-cases\\{args[0]}");
                outputFilename = Path.Combine(Environment.CurrentDirectory, $"output\\{args[1]}");
            }

            int i = 0;
            // // Okay so we need to parse the input file.
            using(var reader = new StreamReader(filename))
            using(var writer = new StreamWriter(outputFilename))
            {
                writer.WriteLine("// memory data file (do not edit the following line - required for mem load use");
                writer.WriteLine("// instance=/fetchmemoryunit/memory/r0/s_ram");
                writer.WriteLine("// format=mti addressradix=h dataradix=h version=1.0 wordsperline=1");
                while(!reader.EndOfStream)
                {
                    // Get each line of the instructions, this is still assembly code.
                    var assemblyInstruction = reader.ReadLine();
                    
                    // Ignore comment lines
                    if(assemblyInstruction == "" || assemblyInstruction[0] == '#')
                    {
                        continue;
                    }

                    // Remove white spaces.

                    // Check if this is org
                    if(assemblyInstruction.ToUpper().StartsWith(".ORG"))
                    {
                        var lines = assemblyInstruction.Split(' ');
                        var integer = Convert.ToInt32(lines[1], 16);
                        
                        for(; i < integer; i++)
                        {
                            writer.WriteLine($"{i.ToString("X")}: 0000");
                        }

                        continue;
                    }
                    
                    if(int.TryParse(assemblyInstruction, NumberStyles.HexNumber, null, out int theInteger))
                    {
                        var hexNumber = theInteger.ToString("X").PadLeft(4, '0');
                        writer.WriteLine($"{i.ToString("X")}: {hexNumber}");
                        i++;
                        continue;
                    }

                    if(assemblyInstruction.Contains('#'))
                    {
                        assemblyInstruction = assemblyInstruction.Substring(0, assemblyInstruction.IndexOf('#'));
                    }
                    if(assemblyInstruction.All(x => x == ' '))
                    {
                        continue;
                    }
                    // Convert this to our memory code.
                    var machineCode = converter.AssemblyConvert(assemblyInstruction, true);
                    if(machineCode.Contains('\n'))
                    {
                        writer.WriteLine($"{i.ToString("X")}: {machineCode.Substring(0,machineCode.IndexOf('\n')).PadLeft(4, '0')}");
                        writer.WriteLine($"{(i+1).ToString("X")}: {machineCode.Substring(machineCode.IndexOf('\n') + 1).PadLeft(4, '0')}");
                        i+=2;    
                        continue;
                    }
                    writer.WriteLine($"{i.ToString("X")}: {machineCode.PadLeft(4, '0')}");
                    i++;
                }

                while(i < LASTMEMORYPOSITION)
                {
                    writer.WriteLine($"{i.ToString("X")}: {converter.AssemblyConvert("NOP", true).PadLeft(4, '0')}");
                    i++;
                }
            }
        }
    }

    public class AssemblyConverter
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
            _registerLookup = new Dictionary<string, string>
            {
                ["R0"] = "000",
                ["R1"] = "001",
                ["R2"] = "010",
                ["R3"] = "011",
                ["R4"] = "100",
                ["R5"] = "101",
                ["R6"] = "110",
                ["R7"] = "111"
            };
        }
        private void InitializeOpCodeLookup()
        {
            _opCodeLookup = new Dictionary<string, string>
            {

                // M-Type Instructions.
                ["PUSH"] = "00000",
                ["POP"] = "00001",
                ["LDD"] = "00111",
                ["LDM"] = "00011",
                ["STD"] = "00100",
                ["IN"] = "00101",
                ["OUT"] = "00110",

                // J-Type Instructions.
                ["JZ"] = "01001",
                ["JN"] = "01010",
                ["JC"] = "01011",
                ["CALL"] = "01100",
                ["JMP"] = "01101",
                ["RET"] = "01110",
                ["RTI"] = "01111",

                // H-Type Instructions
                ["MOV"] = "10000",
                ["ADD"] = "10001",
                ["SUB"] = "10010",
                ["MUL"] = "10011",
                ["AND"] = "10100",
                ["OR"] = "10101",
                ["SHL"] = "10110",
                ["SHR"] = "10111",

                // X-Type Instructions
                ["NOT"] = "11000",
                ["SETC"] = "11001",
                ["CLRC"] = "11010",
                ["NOP"] = "11011",
                ["INC"] = "11100",
                ["DEC"] = "11101"
            };
        }

        /// <summary> 
        /// Takes an assembly instruction as input and outputs the respective binary code for it.
        /// <param name="assembly">The whole instruction in assembly language</param>
        /// </summary>
        /// <returns>Returns a string of 0s and 1s representing the machine code </returns>  
        public string AssemblyConvert(string assembly, bool hex = false)
        {
            string machineCode = "";
            
            // First extract the opcode from the assmebly.
            string opCode = this.ExtractOpCode(assembly);
            machineCode += _opCodeLookup[opCode.ToUpper()];

            // Check the type and identify the missing bits and pieces.
            var typeCode = machineCode.Substring(0, 2);

            // Extract the instruction parts
            var instructionParts = this.ExtractInstructionParts(assembly);

            bool hasNext = false;

            switch (typeCode)
            {
                case "00":
                    machineCode += _registerLookup[instructionParts[0]];

                    if(instructionParts.Length > 1)
                    {
                        hasNext = true;
                        if(opCode == "LDM")
                        {

                            // It has an immediate value.
                            string binary = HexToBinary(instructionParts[1], 16);
                            machineCode += binary;
                        }else 
                        {
                            string binary = HexToBinary(instructionParts[1] , 20);

                            if(binary.Length > 20)
                            {
                                throw new Exception("Invalid ");
                            }
                            machineCode += binary;
                        }
                    }
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
                    if(instructionParts[1][0] != 'R')
                    {
                        machineCode += "000";
                        string immediateValueBinary = HexToBinary(instructionParts[1], 4);
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
                machineCode = machineCode.PadRight(31, '0');
                string firstMemoryLocation = machineCode.Substring(0, 16);
                string secondMemoryLocation = machineCode.Substring(15, 16);
                machineCode = firstMemoryLocation + "\n" + secondMemoryLocation;
                char[] array = firstMemoryLocation.ToCharArray();
                array[15] = '1';
                firstMemoryLocation = new string(array);
                return hex? Convert.ToInt64(firstMemoryLocation, 2).ToString("X")  + "\n" + Convert.ToInt64(secondMemoryLocation, 2).ToString("X") : machineCode; 
            }

            char[] arr = machineCode.ToCharArray();
            arr[15] = (char)(hasNext ? '1' : '0');
            machineCode = new string(arr);
            return hex? Convert.ToInt64(machineCode , 2).ToString("X") : machineCode;         
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

        private string HexToBinary(string hexString, int padding = 0)
        {
            string binary = Convert.ToString(Convert.ToInt64(hexString, 16), 2);
            return padding == 0 ? binary : binary.PadLeft(padding ,'0');
        }
    }
}
