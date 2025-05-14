setenv LMC_TIMEUNIT -9
vlib work
vmap work work


# compile
vlog -sv -work work "manage_fifo.sv"
vlog -sv -work work "fifo.sv"
vlog -sv -work work "gray_scale.sv"
vlog -sv -work work "sobel.sv"
vlog -sv -work work "edge_detect_top.sv"
vlog -sv -work work "edge_detect_tb.sv"

vsim -classdebug -voptargs=+acc +notimingchecks -L work work.edge_detect_tb -wlf edge_detect_tb.wlf

# wave
add wave -noupdate -group TOP -radix hex edge_detect_tb/*
add wave -noupdate -group TOP -radix unsigned edge_detect_tb/edge_detect_top_dut/sobel_unit/*

run -all
  