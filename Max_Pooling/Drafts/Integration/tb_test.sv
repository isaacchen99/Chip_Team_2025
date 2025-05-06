// Inside your top-level or testbench
logic [DATA_WIDTH-1:0] win[KERNEL_DIM-1:0][KERNEL_DIM-1:0];
logic val;
logic [DATA_WIDTH-1:0] pooled_out;
logic pooled_valid;

// Instantiate sliding window
sliding_window #(
    .DATA_WIDTH(DATA_WIDTH),
    .KERNEL_DIM(KERNEL_DIM),
    .ROW_SIZE(ROW_SIZE)
) sw_inst (
    .clk(clk),
    .rst(rst),
    .inputPixel(inputPixel),
    .window(win),
    .valid(val)
);

// Instantiate max pooling
max_pooling #(
    .DATA_WIDTH(DATA_WIDTH),
    .KERNEL_DIM(KERNEL_DIM)
) mp_inst (
    .clk(clk),
    .rst(rst),
    .valid(val),
    .window(win),
    .outputPixel(pooled_out),
    .outputValid(pooled_valid)
);
