module test #(
    parameter DATA_WIDTH = 8, 
    parameter KERNEL_DIM = 3,
    parameter ROW_SIZE = 540    
)(
    input logic clk, rst,
    input logic [DATA_WIDTH-1:0] inputPixel,
    output logic [DATA_WIDTH-1:0] outputPixel
);

    logic [DATA_WIDTH-1:0] window[KERNEL_DIM-1:0][KERNEL_DIM-1:0];
    logic [DATA_WIDTH-1:0] max_val;

    always_ff @(posedge clk) begin
        if (rst) begin
            outputPixel <= 0;
            max_val <= 0;
        end else begin
            // Manually set fixed 3x3 test window
            window[0][0] <= 8'd1;  window[0][1] <= 8'd2;  window[0][2] <= 8'd3;
            window[1][0] <= 8'd4;  window[1][1] <= 8'd9;  window[1][2] <= 8'd2;
            window[2][0] <= 8'd1;  window[2][1] <= 8'd5;  window[2][2] <= 8'd0;

            // Compute max
            max_val = window[0][0];
            for (int i = 0; i < KERNEL_DIM; i++) begin
                for (int j = 0; j < KERNEL_DIM; j++) begin
                    if (window[i][j] > max_val) begin
                        max_val = window[i][j];
                    end
                end
            end

            outputPixel <= max_val;
        end
    end
endmodule
