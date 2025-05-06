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