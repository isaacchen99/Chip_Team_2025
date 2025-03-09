module sliding_window #(
    parameter WORD_SIZE = 8, 
    parameter BUFFER_SIZE = 3, 
    parameter ROW_SIZE = 10 
)
(
    input logic clk, rst,
    input logic [WORD_SIZE-1:0] inputPixel,
    output logic [WORD_SIZE-1:0] window[BUFFER_SIZE-1:0][BUFFER_SIZE-1:0]
);

    logic [WORD_SIZE-1:0] buffer[ROW_SIZE-1:0][BUFFER_SIZE-1:0];
    logic [$clog2(ROW_SIZE)-1:0] ptr;

    always_ff @(posedge clk) begin
        if (rst) begin
            ptr <= 0;
            for (int i = 0; i < BUFFER_SIZE; i++) begin
                for (int j = 0; j < BUFFER_SIZE; j++) begin
                    window[i][j] <= 0;
                end
            end
        end 
        else begin
            // shift downward
            for (int i = BUFFER_SIZE-1; i > 0; i--) begin
                for (int j = 0; j < BUFFER_SIZE; j++) begin
                    window[i][j] <= window[i-1][j];
                end
            end

            // restore from buffer
            if (ptr > BUFFER_SIZE-1) begin
                for (int j = 0; j < BUFFER_SIZE; j++) begin
                    window[0][j] <= buffer[ptr-1][j];
                end
            end
            else begin
                // shift right
                for (int j = BUFFER_SIZE-1; j > 0; j--) begin
                    window[0][j] <= window[0][j-1];
                end
                window[0][0] <= inputPixel;
            end

            // store last row to buffer
            for (int j = 0; j < BUFFER_SIZE; j++) begin
                buffer[ptr][j] <= window[BUFFER_SIZE-1][j];
            end

            // update pointer
            if (ptr < ROW_SIZE - BUFFER_SIZE) begin
                ptr <= ptr + 1;
            end 
            else begin
                ptr <= 0;
            end
        end
    end
endmodule
