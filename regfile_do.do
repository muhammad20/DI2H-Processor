force -freeze sim:/register_file/Read_Sig 1 0
force -freeze sim:/register_file/Write_Sig 1 0
force -freeze sim:/register_file/rst 1 0
force -freeze sim:/register_file/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/register_file/Address_read1 011 0
force -freeze sim:/register_file/Address_write 011 0
force -freeze sim:/register_file/datain 16'hABCD 0
run

force -freeze sim:/register_file/rst 0 0
run
