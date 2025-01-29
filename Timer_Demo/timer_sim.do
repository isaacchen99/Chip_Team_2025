setenv LMC_TIMEUNIT -9
vlib work
vmap work work


# compile
vlog -sv -work work "timer.sv"
vlog -sv -work work "timer_tb.sv"

vsim -classdebug -voptargs=+acc +notimingchecks -L work work.timer_tb -wlf timer_tb.wlf

# wave
add wave -noupdate -group TOP -radix hex timer_tb/*

run -all
  