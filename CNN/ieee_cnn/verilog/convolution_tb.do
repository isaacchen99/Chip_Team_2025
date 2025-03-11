setenv LMC_TIMEUNIT -9
vlib work
vmap work work


# compile
vlog -sv -work work "convolution.sv"
vlog -sv -work work "sliding_window.sv"
vlog -sv -work work "convolution_tb.sv"

vsim -classdebug -voptargs=+acc +notimingchecks -L work work.convolution_tb -wlf convolution_tb.wlf

# wave
add wave -noupdate -group TOP -radix hex convolution_tb/*

run -all
  