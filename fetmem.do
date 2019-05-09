mem load -i {C:/Users/Ismail/Documents/Gam3a/Senior 1/Semester 8/Arch/Project/DI2H-Processor/assembler/Assembler/output/output1.mem} -format mti /fetchmemoryunit/memory/r0/s_ram
force -freeze sim:/fetchmemoryunit/clock 1 0, 0 {50 ns} -r 100
force -freeze sim:/fetchmemoryunit/reset 1 0
force -freeze sim:/fetchmemoryunit/INT 0 0
run
force -freeze sim:/fetchmemoryunit/reset 0 0
run
run
run
run
run