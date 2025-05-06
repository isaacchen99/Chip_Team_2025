setenv LMC_TIMEUNIT -9
vlib work
vmap work work


# compile
vlog -work work "mlp_tb.sv"
vlog -work work "mlp.sv"
vlog -work work "bram.sv"
vlog -work work "multiplication.sv"



vsim -classdebug -voptargs=+acc +notimingchecks -L work work.mlp_tb -wlf mlp_tb.wlf


# wave
add wave -noupdate -group TOP -radix binary mlp_tb/*
add wave -r -radix decimal sim:/mlp_tb/mlp_module/*




run -all