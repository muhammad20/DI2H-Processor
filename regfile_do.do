force -freeze sim:/register_file/rst 1 0
force -freeze sim:/register_file/clk 0 0, 1 {50 ns} -r 100
run
force -freeze sim:/register_file/rst 0 0
force -freeze sim:/register_file/Write_Sig 0 0
force -freeze sim:/register_file/datain 16'hABCD 0
force -freeze sim:/register_file/Read_Sig 1 0
force -freeze sim:/register_file/Address_read1 3'h0 0
force -freeze sim:/register_file/Address_read2 3'h5 0
force -freeze sim:/register_file/Address_write 3'h4 0
run
force -freeze sim:/register_file/Write_Sig 1 0
run
force -freeze sim:/register_file/Address_write 3'h5 0
force -freeze sim:/register_file/datain 16'hFFFF 0
run