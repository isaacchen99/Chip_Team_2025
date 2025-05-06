`timescale 1ns/1ps

module tb_max_pooling;

    parameter ADDR_WIDTH = 6;
    parameter DATA_WIDTH = 8;
    parameter KERNEL_DIM = 2;
    parameter ROW_SIZE   = 6;

    localparam TOTAL_SIZE = ROW_SIZE * ROW_SIZE;
    localparam OUT_SIZE   = ROW_SIZE / KERNEL_DIM;

    // Clock & Reset
    logic clk, rst;
    initial clk = 0;
    always #5 clk = ~clk;  // 10ns clock

    // BRAM wires
    logic [ADDR_WIDTH-1:0] rd_addr_in, rd_addr_out;
    logic [DATA_WIDTH-1:0] rd_data_in, rd_data_out;
    logic wr_en_out;
    logic [ADDR_WIDTH-1:0] wr_addr_out;
    logic [DATA_WIDTH-1:0] wr_data_out;

    // Instantiate input BRAM
    BRAM #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) input_bram (
        .clk(clk),
        .rst(rst),
        .wr_en(1'b0),
        .wr_addr('0),
        .wr_data('0),
        .rd_addr(rd_addr_in),
        .rd_data(rd_data_in)
    );

    // Instantiate output BRAM
    BRAM #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) output_bram (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en_out),
        .wr_addr(wr_addr_out),
        .wr_data(wr_data_out),
        .rd_addr(rd_addr_out),
        .rd_data(rd_data_out)
    );

    // Instantiate DUT
    max_pooling #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .KERNEL_DIM(KERNEL_DIM),
        .ROW_SIZE(ROW_SIZE)
    ) dut (
        .clk(clk),
        .rst(rst),
        .rd_addr(rd_addr_in),
        .rd_data(rd_data_in),
        .wr_addr(wr_addr_out),
        .wr_data(wr_data_out),
        .wr_en(wr_en_out)
    );

    // Populate input BRAM manually
    initial begin
        rst = 1;
        #20;
        rst = 0;

        // Initialize memory (6x6)
        input_bram.mem[ 0] =  1;  input_bram.mem[ 1] =  3;  input_bram.mem[ 2] =  5;
        input_bram.mem[ 3] =  7;  input_bram.mem[ 4] =  9;  input_bram.mem[ 5] = 11;
        input_bram.mem[ 6] =  2;  input_bram.mem[ 7] =  4;  input_bram.mem[ 8] =  6;
        input_bram.mem[ 9] =  8;  input_bram.mem[10] = 10;  input_bram.mem[11] = 12;
        input_bram.mem[12] = 13;  input_bram.mem[13] = 15;  input_bram.mem[14] = 17;
        input_bram.mem[15] = 19;  input_bram.mem[16] = 21;  input_bram.mem[17] = 23;
        input_bram.mem[18] = 14;  input_bram.mem[19] = 16;  input_bram.mem[20] = 18;
        input_bram.mem[21] = 20;  input_bram.mem[22] = 22;  input_bram.mem[23] = 24;
        input_bram.mem[24] = 25;  input_bram.mem[25] = 27;  input_bram.mem[26] = 29;
        input_bram.mem[27] = 31;  input_bram.mem[28] = 33;  input_bram.mem[29] = 35;
        input_bram.mem[30] = 26;  input_bram.mem[31] = 28;  input_bram.mem[32] = 30;
        input_bram.mem[33] = 32;  input_bram.mem[34] = 34;  input_bram.mem[35] = 36;
    end

    // Enhanced monitor
    always_ff @(posedge clk) begin
        $display("[CLK %0t] base_addr = %0d, KERN_COUNT = %0d, rd_addr = %0d, rd_data = %0d, max_val = %0d, wr_en = %0b, wr_addr = %0d, wr_data = %0d",
                 $time,
                 dut.base_addr,
                 dut.kern_count,
                 rd_addr_in,
                 rd_data_in,
                 dut.max_val,
                 wr_en_out,
                 wr_addr_out,
                 wr_data_out);
    end

    // Display final result
    initial begin
        #1000;
        $display("\n===== INPUT IMAGE (%0dx%0d) =====", ROW_SIZE, ROW_SIZE);
        for (int i = 0; i < TOTAL_SIZE; i++) begin
            $write("%2d ", input_bram.mem[i]);
            if ((i + 1) % ROW_SIZE == 0) $write("\n");
        end

        $display("\n===== OUTPUT IMAGE (%0dx%0d, max-pooled) =====", OUT_SIZE, OUT_SIZE);
        for (int i = 0; i < OUT_SIZE * OUT_SIZE; i++) begin
            $write("%2d ", output_bram.mem[i]);
            if ((i + 1) % OUT_SIZE == 0) $write("\n");
        end

        $display("\nSimulation done.");
        $finish;
    end

endmodule
