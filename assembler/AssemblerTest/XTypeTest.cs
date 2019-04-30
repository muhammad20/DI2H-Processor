using System;
using Xunit;
using Assembler;

namespace AssemblerTest
{
    public class XTypeTest
    {
        [Fact]
        public void OneOperandTest()
        {
            var converter = new AssemblyConverter();

            string firstInstruction = "INC R5";
            string machineCode = converter.AssemblyConvert(firstInstruction);

            Assert.NotEmpty(machineCode);

            Assert.Equal(16, machineCode.Length);

            Assert.Equal("1110010100000000", machineCode);
        }

        [Fact]
        public void NoOperandTest()
        {
            var converter = new AssemblyConverter();

            string firstInstruction = "SETC";
            string machineCode = converter.AssemblyConvert(firstInstruction);

            Assert.NotEmpty(machineCode);

            Assert.Equal(16, machineCode.Length);

            Assert.Equal("1100100000000000", machineCode);

        }
    }
}
