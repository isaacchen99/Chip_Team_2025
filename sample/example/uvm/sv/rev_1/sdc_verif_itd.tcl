set paths_array(margin_msg,1) {}
set paths_array(margin_msg,2) {}
set paths_array(margin_msg,3) {}
set paths_array(start_clock,1) {edge_detect_top|clk:rising}
set paths_array(start_clock,2) {System:rising}
set paths_array(start_clock,3) {edge_detect_top|clk:rising}
set paths_array(data_delay,1) {0}
set paths_array(end_point,1) {sobel_out_fifo/fifo_buf.sobel_out_fifo.fifo_buf_ram0_[0]}
set paths_array(end_point,2) {sobel_unit/vertical_product_ff\[0\]_0[8]}
set paths_array(data_delay,2) {0}
set paths_array(data_delay,3) {0}
set paths_array(s_line,1) {0}
set paths_array(end_point,3) {sobel_unit/shift_reg_0}
set paths_array(s_line,2) {0}
set paths_array(s_line,3) {0}
set paths_array(slack,1) {-2.155}
set paths_array(slack,2) {7.428}
set paths_array(slack,3) {7.797}
set paths_array(end_clk_dly,1) {0.000}
set paths_array(end_clk_dly,2) {0.000}
set paths_array(end_clk_dly,3) {0.000}
set paths_array(pro_slack,1) {0}
set paths_array(start_clk_dly,1) {0.000}
set paths_array(start_type,1) {reg}
set paths_array(pro_slack,2) {0}
set paths_array(pro_slack,3) {0}
set paths_array(start_type,2) {reg}
set paths_array(start_clk_dly,2) {0.000}
set paths_array(start_clk_dly,3) {0.000}
set paths_array(start_type,3) {reg}
set paths_array(start_point,1) {sobel_unit/vertical_product_ff\[2\]_0[0]}
set paths_array(start_point,2) {sobel_unit/shift_reg_0}
set paths_array(start_point,3) {sobel_unit/shift_reg_1_rst_cntr_rst}
set paths_array(margin,1) {0}
set paths_array(margin,2) {0}
set paths_array(margin,3) {0}
set paths_array(index,1) {1}
set paths_array(index,2) {2}
set paths_array(index,3) {3}
set paths_array(end_clock,1) {edge_detect_top|clk:rising}
set paths_array(status_msg,1) {}
set paths_array(end_clock,2) {edge_detect_top|clk:rising}
set paths_array(status_msg,2) {}
set paths_array(status_msg,3) {}
set paths_array(e_line,1) {0}
set paths_array(end_clock,3) {System:rising}
set paths_array(e_line,2) {0}
set paths_array(e_line,3) {0}
set paths_array(req_time,1) {8.975}
set paths_array(TS,1) {}
set paths_array(req_time,2) {8.975}
set paths_array(req_time,3) {8.975}
set paths_array(TS,2) {}
set paths_array(TS,3) {}
set paths_array(skew,1) {0.0}
set paths_array(skew,2) {0.0}
set paths_array(skew,3) {0.0}
set paths_array(sig) {/home/dcc3637/Courses/CE_387/assignment4/uvm/sv/proj_1.prj|rev_1 {} /home/dcc3637/Courses/CE_387/assignment4/uvm/sv/rev_1/sdc_verif_slack.itd correlate 1 slack 1 {} {} {} {} {} {} 0 1 0 1 1}
set paths_array(end_type,1) {reg}
set paths_array(passed,1) {0}
set paths_array(end_type,2) {reg}
set paths_array(passed,2) {0}
set paths_array(passed,3) {0}
set paths_array(end_type,3) {reg}
set synth_array(end_clock,2) {}
set synth_array(end_clock,3) {}
set synth_array(req_time,1) {}
set synth_array(slack,1) {}
set synth_array(slack,2) {}
set synth_array(req_time,2) {}
set synth_array(start_point,1) {}
set synth_array(slack,3) {}
set synth_array(req_time,3) {}
set synth_array(end_clk_dly,1) {}
set synth_array(start_point,2) {}
set synth_array(start_point,3) {}
set synth_array(end_clk_dly,2) {}
set synth_array(start_clock,1) {}
set synth_array(end_clk_dly,3) {}
set synth_array(start_clock,2) {}
set synth_array(skew,1) {}
set synth_array(start_clock,3) {}
set synth_array(skew,2) {}
set synth_array(skew,3) {}
set synth_array(start_type,1) {}
set synth_array(start_clk_dly,1) {}
set synth_array(start_clk_dly,2) {}
set synth_array(start_type,2) {}
set synth_array(end_point,1) {}
set synth_array(end_type,1) {}
set synth_array(start_clk_dly,3) {}
set synth_array(start_type,3) {}
set synth_array(end_type,2) {}
set synth_array(end_point,2) {}
set synth_array(end_type,3) {}
set synth_array(end_point,3) {}
set synth_array(end_clock,1) {}
set sort_list {1 NA 2 NA 3 NA}
set clock_list {}
set foo {ctd_ta_point,sobel_unit/shift_reg_1_rst_cntr_rst}
set ta_array($foo) {sobel_unit.shift_reg_1_rst_cntr_rst}
set foo {ctd_ta_point,sobel_unit/shift_reg_0}
set ta_array($foo) {sobel_unit.shift_reg_0}
set foo {ctd_ta_point,sobel_unit/vertical_product_ff\[2\]_0[0]}
set ta_array($foo) {sobel_unit.vertical_product_ff\[2\]_0[0]}
set foo {ctd_ta_point,sobel_unit/vertical_product_ff\[0\]_0[8]}
set ta_array($foo) {sobel_unit.vertical_product_ff\[0\]_0[8]}
set foo {ctd_ta_point,sobel_out_fifo/fifo_buf.sobel_out_fifo.fifo_buf_ram0_[0]}
set ta_array($foo) {sobel_out_fifo.fifo_buf.sobel_out_fifo.fifo_buf_ram0_[0]}
puts ""
