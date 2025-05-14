

#add wave -noupdate -group my_uvm_tb
#add wave -noupdate -group my_uvm_tb -radix hexadecimal /my_uvm_tb/*

add wave -noupdate -group my_uvm_tb/edge_detect_top_inst
add wave -noupdate -group my_uvm_tb/edge_detect_top_inst -radix hexadecimal /my_uvm_tb/edge_detect_top_inst/*

add wave -noupdate -group my_uvm_tb/edge_detect_top_inst/gray_scale_in
add wave -noupdate -group my_uvm_tb/edge_detect_top_inst/gray_scale_in -radix hexadecimal /my_uvm_tb/edge_detect_top_inst/gray_scale_in/*

add wave -noupdate -group my_uvm_tb/edge_detect_top_inst/in_to_gray_fifo
add wave -noupdate -group my_uvm_tb/edge_detect_top_inst/in_to_gray_fifo -radix hexadecimal /my_uvm_tb/edge_detect_top_inst/in_to_gray_fifo/*

add wave -noupdate -group my_uvm_tb/edge_detect_top_inst/gray_in_fifo
add wave -noupdate -group my_uvm_tb/edge_detect_top_inst/gray_in_fifo -radix hexadecimal /my_uvm_tb/edge_detect_top_inst/gray_in_fifo/*

add wave -noupdate -group my_uvm_tb/edge_detect_top_inst/sobel_unit
add wave -noupdate -group my_uvm_tb/edge_detect_top_inst/sobel_unit -radix hexadecimal /my_uvm_tb/edge_detect_top_inst/sobel_unit/*


add wave -noupdate -group my_uvm_tb/edge_detect_top_inst/sobel_out_fifo
add wave -noupdate -group my_uvm_tb/edge_detect_top_inst/sobel_out_fifo -radix hexadecimal /my_uvm_tb/edge_detect_top_inst/sobel_out_fifo/*

