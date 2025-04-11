setenv LMC_TIMEUNIT -9
vlib work
vmap work work


# compile
vlog -sv -work work "mlp.sv"
vlog -sv -work work "mlp_tb.sv"


vsim -classdebug -voptargs=+acc +notimingchecks -L work work.mlp_tb -wlf mlp_tb.wlf


# wave
add wave -noupdate -group TOP -radix hex mlp_tb/*

run -all