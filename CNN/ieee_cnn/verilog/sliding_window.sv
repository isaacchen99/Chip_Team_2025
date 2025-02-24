parameter WORD_SIZE = 8;
parameter ROW_SIZE = 10;
parameter BUFFER_SIZE = 3;

module sliding_window #(parameter WORD_SIZE = 8, BUFFER_SIZE = 3)
(
    input logic clk, rst,
    input logic [WORD_SIZE-1:0] inputPixel,
    output logic [BUFFER_SIZE-1:0][WORD_SIZE-1:0] window[BUFFER_SIZE-1:0]
);

logic [(BUFFER_SIZE-1)*WORD_SIZE-1:0] buffer[ROW_SIZE-1:0];
logic [$clog2(ROW_SIZE)-1:0] ptr;

always_ff @(posedge clk) begin

    // rst
    if (rst) begin
        ptr <= 0;
        for (int i=0; i < BUFFER_SIZE; i = i + 1) begin
            for (int j=0; j < BUFFER_SIZE; j = j + 1) begin
                window[i][j] <= 0;
            end
        end
    end
    else begin
        // shift bits into window
        sliding[0][0] <= inputPixel;
        sliding[1][0] <= sliding[0][0];
        sliding[1][1] <= sliding[0][1];
        sliding[1][2] <= sliding[0][2];
        sliding[2][0] <= sliding[1][0];
        sliding[2][1] <= sliding[1][1];
        sliding[2][2] <= sliding[1][2]; 

        if (ptr < ROW_SIZE - BUFFER_SIZE) begin
            ptr <= ptr + 1;
        end
        else begin
            ptr <= 0;
        end
    end
end

endmodule