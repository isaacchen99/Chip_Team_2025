module convolution #(
    parameter WORD_SIZE = 8, 
    parameter ROW_SIZE = 10, 
    signed int KERNEL[3][3] = '{'{-1, -1, -1}, '{-1, 8, -1}, '{-1, -1, -1}}
)(
    input logic clk, rst,
    input logic [WORD_SIZE-1:0] inputPixel,
    output logic [WORD_SIZE-1:0] outputPixel
);
    localparam BUFFER_SIZE = 3;

    logic [WORD_SIZE-1:0] window[BUFFER_SIZE-1:0][BUFFER_SIZE-1:0];

    // sliding_window #(WORD_SIZE, BUFFER_SIZE, ROW_SIZE) my_window(.*, .window(window));
    sliding_window #(
        .WORD_SIZE(WORD_SIZE), 
        .BUFFER_SIZE(BUFFER_SIZE), 
        .ROW_SIZE(ROW_SIZE)
    ) my_window (
        .clk(clk), 
        .rst(rst), 
        .inputPixel(inputPixel), 
        .window(window)
    );

    logic signed [WORD_SIZE+4:0] product[BUFFER_SIZE-1:0][BUFFER_SIZE-1:0];
    logic signed [WORD_SIZE+4:0] sum;

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < BUFFER_SIZE; i++) begin
                for (int j = 0; j < BUFFER_SIZE; j++) begin
                    product[i][j] <= 0;
                end
            end
        end
        else begin
            for (int i = 0; i < BUFFER_SIZE; i++) begin
                for (int j = 0; j < BUFFER_SIZE; j++) begin
                    product[i][j] <= window[i][j] * KERNEL[i][j];
                end
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) sum <= 0;
        else sum <= product[0][0] + product[0][1] + product[0][2] +
                    product[1][0] + product[1][1] + product[1][2] +
                    product[2][0] + product[2][1] + product[2][2];
    end

    always_ff @(posedge clk) begin
        if (rst) outputPixel <= 0;
        else outputPixel <= (sum > 255) ? 255 : (sum < 0) ? 0 : sum[WORD_SIZE+4:5];
    end
endmodule
