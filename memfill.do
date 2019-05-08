
// H-Type Instructions
mem load -filltype value -filldata 80E0 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(0)
mem load -filltype value -filldata 8940 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(1)
mem load -filltype value -filldata 9380 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(2)
mem load -filltype value -filldata 9DC0 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(3)
mem load -filltype value -filldata A060 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(4)
mem load -filltype value -filldata AAA0 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(5)
mem load -filltype value -filldata B314 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(6)
mem load -filltype value -filldata BF06 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(7)

//X-Type Instructions
mem load -filltype value -filldata D800 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(0)
mem load -filltype value -filldata C800 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(1)
mem load -filltype value -filldata D000 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(2)
mem load -filltype value -filldata C000 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(3)
mem load -filltype value -filldata E100 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(4)
mem load -filltype value -filldata ED00 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(5)

force -freeze sim:/fetchmemoryunit/clock 1 0, 0 {50 ps} -r 100
force -freeze sim:/fetchmemoryunit/reset 1 0
force -freeze sim:/fetchmemoryunit/fetch_enable 1 0
force -freeze sim:/fetchmemoryunit/mem_read 1 0
run
mem load -filltype value -filldata E100 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(0)

force -freeze sim:/fetchmemoryunit/reset 0 0
run
run
run

//Test multiply
force -freeze sim:/fetchmemoryunit/clock 1 0, 0 {50 ps} -r 100
force -freeze sim:/fetchmemoryunit/reset 1 0
force -freeze sim:/fetchmemoryunit/fetch_enable 1 0
force -freeze sim:/fetchmemoryunit/mem_read 1 0
mem load -filltype value -filldata E100 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(0)
mem load -filltype value -filldata E200 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(1)
mem load -filltype value -filldata D800 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(2)
mem load -filltype value -filldata D800 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(3)
mem load -filltype value -filldata 8A20 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(4)
mem load -filltype value -filldata D800 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(5)
mem load -filltype value -filldata D800 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(6)
mem load -filltype value -filldata 8940 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(7)
mem load -filltype value -filldata D800 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(8)
mem load -filltype value -filldata D800 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(9)
mem load -filltype value -filldata 9940 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(10)
run
force -freeze sim:/fetchmemoryunit/reset 0 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run



//ALU
force -freeze sim:/arithmeticlogicunit/alu_enable 1 0
force -freeze sim:/arithmeticlogicunit/clock 1 0, 0 {50 ps} -r 100
force -freeze sim:/arithmeticlogicunit/reset 1 0
force -freeze sim:/arithmeticlogicunit/setc 1 0
force -freeze sim:/arithmeticlogicunit/src 16'hABCD 0
force -freeze sim:/arithmeticlogicunit/dest 16'h0001 0
force -freeze sim:/arithmeticlogicunit/h_type 0 0
run
force -freeze sim:/arithmeticlogicunit/reset 0 0
run


// M-Type


mem load -filltype value -filldata 3901 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(0)
mem load -filltype value -filldata 0018 -fillradix hexadecimal /fetchmemoryunit/memory/r0/s_ram(1)
force -freeze sim:/fetchmemoryunit/clock 1 0, 0 {50 ps} -r 100
force -freeze sim:/fetchmemoryunit/reset 1 0
force -freeze sim:/fetchmemoryunit/fetch_enable 1 0
force -freeze sim:/fetchmemoryunit/mem_read 1 0
run
force -freeze sim:/fetchmemoryunit/reset 0 0
run
run
run
run
run