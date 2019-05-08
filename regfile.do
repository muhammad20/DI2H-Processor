force -freeze sim:/register_file/rst 1 0
run
force -freeze sim:/register_file/Read_Sig 1 0
noforce sim:/register_file/Write_Sig
force -freeze sim:/register_file/Write_Sig 1 0
force -freeze sim:/register_file/mul_signal 1 0
force -freeze sim:/register_file/clk 0 0, 1 {50 ns} -r 100
force -freeze sim:/register_file/Address_read2 3'h0 0
force -freeze sim:/register_file/Address_read1 3'h0 0
force -freeze sim:/register_file/Address_write1 3'h2 0
force -freeze sim:/register_file/Address_write2 3'h4 0
force -freeze sim:/register_file/datain 16'hAAAA 0
force -freeze sim:/register_file/datain_mul 16'hBBBB 0
run
force -freeze sim:/register_file/rst 0 0
run
force -freeze sim:/register_file/Address_read1 3'h6 0
force -freeze sim:/register_file/Address_read2 3'h7 0
force -freeze sim:/register_file/Address_write1 3'h7 0
force -freeze sim:/register_file/Address_write2 3'h6 0
run
force -freeze sim:/register_file/mul_signal 0 0
force -freeze sim:/register_file/Address_write1 3'h5 0
force -freeze sim:/register_file/Address_read1 3'h5 0
run