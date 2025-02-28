


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