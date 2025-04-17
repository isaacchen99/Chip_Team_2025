module convolution #(
    parameter WORD_SIZE = 8, 
    parameter ROW_SIZE = 540,   
    parameter KERNEL_DIM = 3
)(
    input logic clk, rst,
    input logic [WORD_SIZE-1:0] inputPixel,
    output logic [WORD_SIZE-1:0] outputPixel
);

    // The kernel is a 3x3 matrix with signed values
    // Laplacian kernel used for edge detection
    //localparam KERNEL_DIM = 3; *made global
    localparam int KERNEL[KERNEL_DIM][KERNEL_DIM] = '{
        '{-1, -1, -1},
        '{-1, 8, -1}, 
        '{-1, -1, -1}
    };

   
    //sliding_window #(WORD_SIZE, KERNEL_DIM, ROW_SIZE) my_window(.*, .window(window));
    //sliding_window #(
    //    .WORD_SIZE(WORD_SIZE), 
    //    .KERNEL_DIM(KERNEL_DIM), 
    //    .ROW_SIZE(ROW_SIZE)
    //) my_window (
    //    .clk(clk), 
    //    .rst(rst), 
    //    .inputPixel(inputPixel), 
    //    .window(window)
    //);
    //
    // The Sliding Window "module" is below


    //Sliding Window is set to be the size of the kernel
    logic [WORD_SIZE-1:0] window[KERNEL_DIM-1:0][KERNEL_DIM-1:0];
    //Buffer is a 1D array indexted with the following scheme
    // 0 - ROW_SIZE-1 --> bottom row of buffer
    // ROW_SIZE - ROW_SIZE*2-1 --> middle row of buffer
    // ROW_SIZE*2 - ROW_SIZE*2+2 --> top row of buffer (this is just 3px of data)
    logic [WORD_SIZE-1:0] buffer[ROW_SIZE*2+2:0];
    
    logic [$clog2(ROW_SIZE*2+2):0] count;   

    always_ff @(posedge clk) begin
        //if rst then reset both the count and the set the window to all 0
        if (rst) begin
            count <= 0;
            for (int i = 0; i < KERNEL_DIM; i++) begin
                for (int j = 0; j < KERNEL_DIM; j++) begin
                window[i][j] <= 0;
            end
        end 
        //case for when the count is less than the buffer size and needs to be filled
        if (count < ROW_SIZE*2+2) begin
            buffer[count] <= inputPixel;
            count <= count + 1;
        end
        //normal case when buffer is filled and the window is not at an edge
        else begin
            window[2][2] <= buffer[ROW_SIZE*2+2];
            window[2][1] <= buffer[ROW_SIZE*2+1];
            window[2][0] <= buffer[ROW_SIZE*2];
            window[1][2] <= buffer[ROW_SIZE+2];
            window[1][1] <= buffer[ROW_SIZE+1];
            window[1][0] <= buffer[ROW_SIZE];
            window[0][2] <= buffer[2];
            window[0][1] <= buffer[1];
            window[0][0] <= buffer[0];

            //shift in one pixle into the buffer 
            for (int i = 0; i < ROW_SIZE*2+2; i++) begin
                buffer[i] <= buffer[i+1];
            end
            //set the last buffer to the input pixel
            buffer[ROW_SIZE*2+2] <= inputPixel;
        end
        end
    end


    // convolution: product of element-wise multiplication, then total sum of window
    logic signed [WORD_SIZE+4:0] product[KERNEL_DIM-1:0][KERNEL_DIM-1:0];
    logic signed [WORD_SIZE+4:0] sum;

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
