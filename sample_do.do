setenv LMC_TIMEUNIT -9
vlib work
vmap work work


# compile
vlog -sv -work work "fibonacci.sv"
vlog -sv -work work "fibonacci_tb.sv"


vsim -classdebug -voptargs=+acc +notimingchecks -L work work.fibonacci_tb -wlf fibonacci_tb.wlf


# wave
add wave -noupdate -group TOP -radix hex fibonacci_tb/*

run -all
  