force -freeze sim:/stackpointer/clk 0 0, 1 {50 ns} -r 100
force -freeze sim:/stackpointer/reset 1 0
force -freeze sim:/stackpointer/subTwo 0 0
force -freeze sim:/stackpointer/subOne 0 0
force -freeze sim:/stackpointer/addOne 0 0
force -freeze sim:/stackpointer/addTwo 0 0
run
force -freeze sim:/stackpointer/reset 0 0
run
force -freeze sim:/stackpointer/subTwo 1 0
run
run
run
force -freeze sim:/stackpointer/subTwo 0 0
force -freeze sim:/stackpointer/addTwo 1 0
run
run
run
force -freeze sim:/stackpointer/subOne 1 0
force -freeze sim:/stackpointer/addTwo 0 0
run
run
run
