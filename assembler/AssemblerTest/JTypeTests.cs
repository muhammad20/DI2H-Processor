using System;
using Assembler;
using Xunit;

namespace AssemblerTest
{
    public class JTypeTests
    {

        [Fact]
        public void JumpTest()
        {
            var converter = new AssemblyConverter();

            string firstInstruction = "JZ R7";
            string machineCode = converter.AssemblyConvert(firstInstruction);

            Assert.NotEmpty(machineCode);

            Assert.Equal(16, machineCode.Length);

            Assert.Equal("0100111100000000", machineCode);
        }

        [Fact]
        public void NoOperandTest()
        {
            var converter = new AssemblyConverter();

            string firstInstruction = "RET";
            string machineCode = converter.AssemblyConvert(firstInstruction);

            Assert.NotEmpty(machineCode);

            Assert.Equal(16, machineCode.Length);

            Assert.Equal("0111000000000000", machineCode);
        }
    }
}
