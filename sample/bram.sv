module RAM_param #(
    parameter int ADDR_WIDTH = 4,           // address width
    parameter int DATA_WIDTH = 8            // data width
) (
    input  logic                     clk,
    input  logic                     rst,

    // Write port
    input  logic                     wr_en,
    input  logic [ADDR_WIDTH-1:0]    wr_addr,
    input  logic [DATA_WIDTH-1:0]    write_data,

    // Read port
    input  logic [ADDR_WIDTH-1:0]    rd_addr,
    output logic [DATA_WIDTH-1:0]    read_data
);

    logic [2**ADDR_WIDTH-1:0][DATA_WIDTH-1:0] mem;

    // Synchronous rst + write
    always_ff @(posedge clk) begin
        if (rst) begin
  
        end else if (wr_en) begin
            mem[wr_addr] <= write_data;
        end
    end

    // Synchronous read (registered output)
    always_ff @(posedge clk) begin
        if (rst)
          read_data <= '0;
        else
          read_data <= mem[rd_addr];
    end

endmodule
