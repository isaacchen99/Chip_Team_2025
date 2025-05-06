module max_pooling #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8,
    parameter KERNEL_DIM = 2,
    parameter ROW_SIZE   = 4
)(
    input  logic clk,
    input  logic rst,

    // BRAM read ports
    output logic [ADDR_WIDTH-1:0] rd_addr,
    input  logic [DATA_WIDTH-1:0] rd_data,

    // BRAM write ports
    output logic [ADDR_WIDTH-1:0] wr_addr,
    output logic [DATA_WIDTH-1:0] wr_data,
    output logic wr_en
);

    localparam TOTAL_SIZE = ROW_SIZE * ROW_SIZE;
    localparam KERNEL_SIZE = KERNEL_DIM * KERNEL_DIM;

    // base + offset(0 to 3 for 2x2 kernal) address
    logic [$clog2(TOTAL_SIZE)-1:0] base_addr;
    logic [$clog2(KERNEL_SIZE)-1:0] kern_count;
    assign rd_addr = base_addr + (kern_count[1] ? ROW_SIZE : 0) + (kern_count[0] ? 1 : 0); // read address = base_addr + row/col offset

    // Latched max value
    logic [DATA_WIDTH-1:0] max_val;
    assign wr_data = max_val;   // default


    always_ff @(posedge clk) begin
        if (rst) begin
            base_addr   <= 0;
            kern_count  <= 0;
            max_val     <= 0;
            wr_en       <= 0;
            wr_addr     <= -2; // don;t know why theres an offset but this fixes it
        end else begin
            wr_en <= 0;

            // update max_val
            if (kern_count == 1)
                max_val <= rd_data;
            else if (rd_data > max_val)
                max_val <= rd_data;

            // kernel counter +
            if (kern_count == KERNEL_SIZE - 1) begin    // rewind
                kern_count <= 0;

                // Move to next 2x2 block
                if ((base_addr % ROW_SIZE) <= ROW_SIZE - 2*KERNEL_DIM)  // finds column index
                    base_addr <= base_addr + KERNEL_DIM; // move right
                else
                    base_addr <= base_addr + KERNEL_DIM + ROW_SIZE; // move to next row
            end
            else begin
                kern_count <= kern_count + 1;   // increment within window
                if (kern_count == 0) begin      // write on every first value (there's 1 clk delay)
                    wr_en <= 1;
                    wr_addr <= wr_addr + 1;
                end
            end
        end
    end

endmodule

//=======================================================================================//

module BRAM #(
    parameter int ADDR_WIDTH = 4,
    parameter int DATA_WIDTH = 8
) (
    input  logic            clk,
    input  logic            rst,

    // Write port
    input  logic                     wr_en,
    input  logic [ADDR_WIDTH-1:0]    wr_addr,
    input  logic [DATA_WIDTH-1:0]    wr_data,

    // Read port
    input  logic [ADDR_WIDTH-1:0]    rd_addr,
    output logic [DATA_WIDTH-1:0]    rd_data
);

    logic [2**ADDR_WIDTH-1:0][DATA_WIDTH-1:0] mem;

    // Synchronous rst + write
    always_ff @(posedge clk) begin
        if (rst) begin
  
        end else if (wr_en) begin
            mem[wr_addr] <= wr_data;
        end
    end

    // Synchronous read (registered output)
    always_ff @(posedge clk) begin
        if (rst)
          rd_data <= '0;
        else
          rd_data <= mem[rd_addr];
    end

endmodule