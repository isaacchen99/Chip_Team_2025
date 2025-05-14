`timescale 1ns/1ps

module max_pooling_tb;

    parameter ADDR_WIDTH = 4;
    parameter DATA_WIDTH = 8;
    parameter KERNEL_DIM = 2;
    parameter ROW_SIZE   = 4;

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

        // Initialize memory
        for (int i = 0; i < 16; i++) begin
            input_bram.mem[i] = i;
        end
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

    initial begin
        #500;
        $display("\n===== INPUT IMAGE (4x4) =====");
        for (int i = 0; i < 16; i++) begin
            $write("%2d ", input_bram.mem[i]);
            if ((i + 1) % 4 == 0) $write("\n");
        end

        $display("\n===== OUTPUT IMAGE (2x2, max-pooled) =====");
        for (int i = 0; i < 4; i++) begin
            $write("%2d ", output_bram.mem[i]);
            if ((i + 1) % 2 == 0) $write("\n");
        end

        $display("\nSimulation done.");
        $finish;
    end

endmodule


