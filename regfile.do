force -freeze sim:/register_file/Read_Sig 1 0
force -freeze sim:/register_file/Write_Sig 1 0
force -freeze sim:/register_file/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/register_file/rst 1 0
force -freeze sim:/register_file/Address_read1 010 0
force -freeze sim:/register_file/Address_read2 001 0
force -freeze sim:/register_file/Address_write 010 0
force -freeze sim:/register_file/datain 16'h1 0
run

force -freeze sim:/register_file/rst 0 0
run
run