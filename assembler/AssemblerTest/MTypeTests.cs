using System;
using Xunit;
using Assembler;

namespace AssemblerTest
{
    public class MTypeTests
    {
        [Fact]
        public void TestOneLine()
        {
            var converter = new AssemblyConverter();

            string firstInstruction = "PUSH R6";
            string machineCode = converter.AssemblyConvert(firstInstruction);

            Assert.NotEmpty(machineCode);

            Assert.Equal(16, machineCode.Length);

            Assert.Equal("0000011000000000", machineCode);
        }

        [Fact]
        public void EATest()
        {
            var converter = new AssemblyConverter();

            string firstInstruction = "LDD R1, 0128F";
            string machineCode = converter.AssemblyConvert(firstInstruction);

            Assert.NotEmpty(machineCode);

            Assert.Contains("\n", machineCode);

            var lines = machineCode.Split('\n');
            string part1 = machineCode.Substring(0, machineCode.IndexOf('\n'));

            Assert.Equal(16, part1.Length);

            //Assert.Equal("0011100100000001‬", part1);
            
            //Assert.Equal("1001010001111000", lines[1]);

        }
    }
}
