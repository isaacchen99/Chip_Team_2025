module convolution #(
    parameter WORD_SIZE = 8, 
    parameter ROW_SIZE = 540    
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

    logic signed [7:0] KERNEL [0:2][0:2];

    // The kernel is a 3x3 matrix with signed values
    // Laplacian kernel used for edge detection

    initial begin
        KERNEL[0][0] = -1; KERNEL[0][1] = -1; KERNEL[0][2] = -1;
        KERNEL[1][0] = -1; KERNEL[1][1] =  8; KERNEL[1][2] = -1;
        KERNEL[2][0] = -1; KERNEL[2][1] = -1; KERNEL[2][2] = -1;
    end

    // Convolution operation
    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < BUFFER_SIZE; i++) begin
                for (int j = 0; j < BUFFER_SIZE; j++) begin
                    product[i][j] <= 0;
                end
            end
        end
        else begin
            $display("Convolution Received Input: %h", inputPixel);
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

    // Case block to handle sliding window edge cases

always_ff @(posedge clk) begin
    if (rst) begin
        for (int i = 0; i < BUFFER_SIZE; i++) begin
            for (int j = 0; j < BUFFER_SIZE; j++) begin
                window[i][j] <= 0;
            end
        end
    end else begin
        case (inputPixel) 
            // Top-left corner
            0: begin
                window[0][0] <= window[0][1];
                window[0][1] <= window[0][2];
                window[1][0] <= window[1][1];
                window[1][1] <= window[1][2];
            end

            // Top row (excluding corners)
            ROW_SIZE-1: begin
                for (int j = 0; j < BUFFER_SIZE; j++) begin
                    window[0][j] <= window[1][j];
                    window[1][j] <= window[2][j];
                end
            end

            // Bottom row (excluding corners)
            ROW_SIZE*(ROW_SIZE-1): begin
                for (int j = 0; j < BUFFER_SIZE; j++) begin
                    window[2][j] <= window[1][j];
                    window[1][j] <= window[0][j];
                end
            end

            // General case (not at edges)
            default: begin
                for (int i = 0; i < BUFFER_SIZE; i++) begin
                    for (int j = 0; j < BUFFER_SIZE; j++) begin
                        window[i][j] <= window[i][j];
                    end
                end
            end
        endcase
    end
end

    // The output pixel is calculated as the sum of the products, clamped to the range [0, 255].
    // The output pixel is stored in the outputPixel register.
    // The output pixel is clamped to the range [0, 255] to ensure that the output
    // pixel is a valid 8-bit value.
    always_ff @(posedge clk) begin
        if (rst) outputPixel <= 0;
        else begin
            outputPixel <= (sum > 255) ? 255 : (sum < 0) ? 0 : sum[WORD_SIZE+4:5];
            $display("Stored OutputPixel: %h", outputPixel);
        end
    end
endmodule
