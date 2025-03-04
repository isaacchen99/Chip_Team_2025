
// MLP module

module MLP_Module 
    #(
    parameter DATA_WIDTH = 32;
    parameter OUTPUT_WIDTH = 32;
)(
    input logic clk,
    input logic [DATA_WIDTH-1:0] data,
    input logic rst,
    input logic new_data,
    output logic output_ready,
    output logic [OUTPUT_WIDTH-1:0] mlp_output,
    output logic done
);
endmodule


// RELU module
module relu #(parameter WIDTH = 8) (
    input  logic [WIDTH-1:0] in,
    output logic [WIDTH-1:0] out
);

    always_comb begin
        if (in > 0)
            out = in;
        else
            out = 0;
    end

