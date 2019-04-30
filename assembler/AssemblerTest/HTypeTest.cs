using System;
using Xunit;
using Assembler;

namespace AssemblerTest
{
    public class HTypeTest
    {
        [Fact]
        public void TestMov()
        {
            var converter = new AssemblyConverter();

            string firstInstruction = "MOV R0, R7";
            string machineCode = converter.AssemblyConvert(firstInstruction, true);

            Assert.NotEmpty(machineCode);

            Assert.Equal(4, machineCode.Length);

            Assert.Equal("80E0", machineCode);
        }

        [Fact]
        public void TestShift()
        {
            var converter = new AssemblyConverter();

            string instruction = "SHL R3, A";

            string machineCode = converter.AssemblyConvert(instruction, hex: true);

            Assert.NotEmpty(machineCode);

            Assert.Equal(4, machineCode.Length);

            Assert.Equal("B314", machineCode);
        }
    }
}
