setenv LMC_TIMEUNIT -9
vlib work
vmap work work


# compile
vlog -work work "counter_tb.sv"
vlog -work work "counter.sv"


vsim -classdebug -voptargs=+acc +notimingchecks -L work work.counter_tb -wlf counter_tb.wlf


# wave
add wave -noupdate -group TOP -radix binary counter_tb/*




run -all
