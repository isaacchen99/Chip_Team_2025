setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# Compile
vlog -sv -work work max_pooling.sv
vlog -sv -work work BRAM.sv
vlog -sv -work work max_pooling_tb.sv

# Simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.max_pooling_tb -wlf max_pooling_tb.wlf

# Add waveform signals
add wave -noupdate -group TOP -radix unsigned tb_max_pooling/*
add wave -noupdate -group DUT -radix unsigned tb_max_pooling/dut/*
add wave -noupdate -group INPUT_BRAM tb_max_pooling/input_bram/*
add wave -noupdate -group OUTPUT_BRAM tb_max_pooling/output_bram/*

# Run simulation
run -all