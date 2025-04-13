module convolution #(
    parameter WORD_SIZE = 8, 
    parameter ROW_SIZE = 540    
)(
    input logic clk, rst,
    input logic [WORD_SIZE-1:0] inputPixel,
    output logic [WORD_SIZE-1:0] outputPixel
);
    localparam KERNEL_DIM = 3;

    logic [WORD_SIZE-1:0] window[KERNEL_DIM-1:0][KERNEL_DIM-1:0];

    // sliding_window #(WORD_SIZE, KERNEL_DIM, ROW_SIZE) my_window(.*, .window(window));
    sliding_window #(
        .WORD_SIZE(WORD_SIZE), 
        .KERNEL_DIM(KERNEL_DIM), 
        .ROW_SIZE(ROW_SIZE)
    ) my_window (
        .clk(clk), 
        .rst(rst), 
        .inputPixel(inputPixel), 
        .window(window)
    );

    // convolution: product of element-wise multiplication, then total sum of window
    logic signed [WORD_SIZE+4:0] product[KERNEL_DIM-1:0][KERNEL_DIM-1:0];
    logic signed [WORD_SIZE+4:0] sum;

    logic signed [7:0] KERNEL [0:KERNEL_DIM-1][0:KERNEL_DIM-1];

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
            for (int i = 0; i < KERNEL_DIM; i++) begin
                for (int j = 0; j < KERNEL_DIM; j++) begin
                    product[i][j] <= 0;
                end
            end
        end
        else begin
            for (int i = 0; i < KERNEL_DIM; i++) begin
                for (int j = 0; j < KERNEL_DIM; j++) begin
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

    

    // The output pixel is calculated as the sum of the products, clamped to the range [0, 255].
    // The output pixel is stored in the outputPixel register.
    // The output pixel is clamped to the range [0, 255] to ensure that the output
    // pixel is a valid 8-bit value.
    always_ff @(posedge clk) begin
        if (rst) outputPixel <= 0;
        else begin
            if (sum < 0) outputPixel <= 0;
            else if (sum > 255) outputPixel <= 255;
            else outputPixel <= sum[WORD_SIZE-1:0];
        end
    end
endmodule
