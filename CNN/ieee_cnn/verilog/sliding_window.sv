module sliding_window #(
    parameter WORD_SIZE = 8, 
    parameter KERNEL_DIM = 3, 
    parameter ROW_SIZE = 540 
)
(
    input logic clk, rst,
    input logic [WORD_SIZE-1:0] inputPixel,
    output logic [WORD_SIZE-1:0] window[KERNEL_DIM-1:0][KERNEL_DIM-1:0]
);

    logic [WORD_SIZE-1:0] buffer[ROW_SIZE-1:0][KERNEL_DIM-1:0];
    logic [$clog2(ROW_SIZE)-1:0] ptr;

    always_ff @(posedge clk) begin
        if (rst) begin
            ptr <= 0;
            for (int i = 0; i < KERNEL_DIM; i++) begin
                for (int j = 0; j < KERNEL_DIM; j++) begin
                window[i][j] <= 0;
                end
            end
        end 
        else begin
            // shift downward
            window[2][0] <= window[1][0];
            window[2][1] <= window[1][1];
            window[2][2] <= window[1][2];
            window[1][0] <= window[0][0];
            window[1][1] <= window[0][1];
            window[1][2] <= window[0][2];

            // shift first row right
            window[0][0] <= inputPixel;
            window[0][1] <= window[0][0]; 
            window[0][2] <= window[0][1]; 

            // buffer data
            buffer[ptr] <= window[KERNEL_DIM-1];
            window[0] <= buffer[ptr];

            // increment ptr
            if(ptr < ROW_SIZE - KERNEL_DIM) begin
                ptr <= ptr + 1;
            end
            else begin
                ptr <= 0;
            end
        end
    end
endmodule
