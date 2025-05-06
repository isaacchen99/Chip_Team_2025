`timescale 1ns/1ps

module tb_max_pooling;

    parameter ADDR_WIDTH = 6;
    parameter DATA_WIDTH = 8;
    parameter KERNEL_DIM = 2;
    parameter ROW_SIZE   = 8;

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

        // Initialize memory (8x8)
        input_bram.mem[ 0] =  2;  input_bram.mem[ 1] = 34;  input_bram.mem[ 2] = 18;  input_bram.mem[ 3] = 23;
        input_bram.mem[ 4] = 45;  input_bram.mem[ 5] = 11;  input_bram.mem[ 6] =  8;  input_bram.mem[ 7] = 27;
        input_bram.mem[ 8] = 19;  input_bram.mem[ 9] = 21;  input_bram.mem[10] = 33;  input_bram.mem[11] = 26;
        input_bram.mem[12] = 39;  input_bram.mem[13] = 17;  input_bram.mem[14] = 14;  input_bram.mem[15] = 36;
        input_bram.mem[16] = 44;  input_bram.mem[17] = 13;  input_bram.mem[18] = 28;  input_bram.mem[19] = 30;
        input_bram.mem[20] = 10;  input_bram.mem[21] = 47;  input_bram.mem[22] = 25;  input_bram.mem[23] =  7;
        input_bram.mem[24] = 38;  input_bram.mem[25] = 32;  input_bram.mem[26] = 22;  input_bram.mem[27] =  4;
        input_bram.mem[28] =  9;  input_bram.mem[29] = 50;  input_bram.mem[30] = 12;  input_bram.mem[31] =  6;
        input_bram.mem[32] = 24;  input_bram.mem[33] = 41;  input_bram.mem[34] = 43;  input_bram.mem[35] =  3;
        input_bram.mem[36] = 16;  input_bram.mem[37] = 20;  input_bram.mem[38] = 46;  input_bram.mem[39] =  1;
        input_bram.mem[40] = 35;  input_bram.mem[41] = 31;  input_bram.mem[42] = 29;  input_bram.mem[43] = 15;
        input_bram.mem[44] = 48;  input_bram.mem[45] =  5;  input_bram.mem[46] = 37;  input_bram.mem[47] = 42;
        input_bram.mem[48] = 40;  input_bram.mem[49] = 49;  input_bram.mem[50] =  0;  input_bram.mem[51] = 52;
        input_bram.mem[52] = 51;  input_bram.mem[53] = 53;  input_bram.mem[54] = 54;  input_bram.mem[55] = 55;
        input_bram.mem[56] = 56;  input_bram.mem[57] = 57;  input_bram.mem[58] = 58;  input_bram.mem[59] = 59;
        input_bram.mem[60] = 60;  input_bram.mem[61] = 61;  input_bram.mem[62] = 62;  input_bram.mem[63] = 63;


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
