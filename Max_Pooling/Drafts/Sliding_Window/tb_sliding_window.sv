`timescale 1ns/1ps

module tb_sliding_window;

    parameter DATA_WIDTH = 8;
    parameter KERNEL_DIM = 3;
    parameter ROW_SIZE = 5;
    parameter TOTAL_PIXELS = ROW_SIZE * ROW_SIZE;

    logic clk, rst;
    logic [DATA_WIDTH-1:0] inputPixel;
    logic [DATA_WIDTH-1:0] window[KERNEL_DIM-1:0][KERNEL_DIM-1:0];
    logic valid;

    // Instantiate DUT
    sliding_window #(
        .DATA_WIDTH(DATA_WIDTH),
        .KERNEL_DIM(KERNEL_DIM),
        .ROW_SIZE(ROW_SIZE)
    ) uut (
        .clk(clk),
        .rst(rst),
        .inputPixel(inputPixel),
        .window(window),
        .valid(valid)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Input pixel stream
    logic [DATA_WIDTH-1:0] input_stream [0:TOTAL_PIXELS-1];

    initial begin
        // Fill input stream with values 1 to 25
        for (int i = 0; i < TOTAL_PIXELS; i++) begin
            input_stream[i] = i + 1;
        end
    end

    initial begin
        $display("Starting test...");

        // Show full input matrix once
        $display("Input Stream Matrix:");
        for (int r = 0; r < ROW_SIZE; r++) begin
            $write("  ");
            for (int c = 0; c < ROW_SIZE; c++) begin
                $write("%0d ", input_stream[r * ROW_SIZE + c]);
            end
            $write("\n");
        end
        $display("==============================");

        clk = 0;
        rst = 1;
        inputPixel = 0;
        #12;
        rst = 0;

        // Feed in pixels
        for (int i = 0; i < TOTAL_PIXELS; i++) begin
            inputPixel = input_stream[i];
            #10;

            $display("Cycle %0d: input = %0d", i, inputPixel);

            $display("Window (valid = %0b):", valid);
            for (int r = 0; r < KERNEL_DIM; r++) begin
                $write("  ");
                for (int c = 0; c < KERNEL_DIM; c++) begin
                    $write("%0d ", window[r][c]);
                end
                $write("\n");
            end

            if (!valid)
                $display("!! Above window not yet valid.");

            $display("Buffer content:");
            for (int j = 0; j < uut.BUFFER_SIZE; j++) begin
                $write("%0d ", uut.buffer[j]);
            end
            $write("\n");
            $display("==============================");
        end

        $display("Window (valid = %0b):", valid);
        for (int r = 0; r < KERNEL_DIM; r++) begin
            $write("  ");
            for (int c = 0; c < KERNEL_DIM; c++) begin
                $write("%0d ", window[r][c]);
            end
            $write("\n");
        end

        if (!valid)
            $display("? Above window not yet valid.");

        $display("Buffer content (uut.buffer):");
        for (int j = 0; j < uut.BUFFER_SIZE; j++) begin
            $write("%0d ", uut.buffer[j]);
        end
        $write("\n");
        $display("==============================");

        $finish;
    end

endmodule
