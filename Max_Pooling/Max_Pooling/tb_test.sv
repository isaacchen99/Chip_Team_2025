`timescale 1ns/1ps

module tb_test;

    parameter DATA_WIDTH = 8;
    parameter KERNEL_DIM = 3;

    logic clk, rst;
    logic [DATA_WIDTH-1:0] inputPixel;
    logic [DATA_WIDTH-1:0] outputPixel;

    test #(
        .DATA_WIDTH(DATA_WIDTH),
        .KERNEL_DIM(KERNEL_DIM)
    ) uut (
        .clk(clk),
        .rst(rst),
        .inputPixel(inputPixel),
        .outputPixel(outputPixel)
    );

    always #5 clk = ~clk;

    initial begin
        $display("Starting Max Pooling Test...");
        clk = 0;
        rst = 1;
        inputPixel = 0;
        #12;

        rst = 0;

        #10;  // Cycle 1 after reset
        $display("Intermediate Output: %0d (Expected: still 0)", outputPixel);

        #10;  // Cycle 2 after reset
        $display("Final Output: %0d (Expected: 9)", outputPixel);

        $finish;
    end

endmodule
