
setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# compile
vlog -sv -work work "../sv/manage_fifo.sv"
vlog -sv -work work "../sv/fifo.sv"
vlog -sv -work work "../sv/gray_scale.sv"
vlog -sv -work work "../sv/sobel.sv"
vlog -sv -work work "../sv/edge_detect_top.sv"
vlog -sv -work work "../sv/edge_detect_tb.sv"

# uvm library
vlog -work work +incdir+$env(UVM_HOME)/src $env(UVM_HOME)/src/uvm.sv
vlog -work work +incdir+$env(UVM_HOME)/src $env(UVM_HOME)/src/uvm_macros.svh
vlog -work work +incdir+$env(UVM_HOME)/src $env(MTI_HOME)/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv

# uvm package
vlog -work work +incdir+$env(UVM_HOME)/src "../uvm/my_uvm_pkg.sv"
vlog -work work +incdir+$env(UVM_HOME)/src "../uvm/my_uvm_tb.sv"

# start uvm simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.my_uvm_tb -wlf my_uvm_tb.wlf -sv_lib lib/uvm_dpi -dpicpppath /usr/bin/gcc +incdir+$env(MTI_HOME)/verilog_src/questa_uvm_pkg-1.2/src/

# start basic simulation
#vsim -voptargs=+acc +notimingchecks -L work work.edge_detect_tb -wlf edge_detect_tb.wlf

do edge_detect_wave.do

run -all
#quit;