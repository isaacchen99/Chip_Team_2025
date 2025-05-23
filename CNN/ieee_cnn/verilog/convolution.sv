module convolution #(
    parameter WORD_SIZE = 8, 
    parameter ROW_SIZE = 540,   
    parameter KERNEL_DIM = 3
)(
    input logic clk, rst,
    input logic [WORD_SIZE-1:0] inputPixel,
    output logic [WORD_SIZE-1:0] outputPixel,
    output logic [1:0] valid
);

    // The kernel is a 3x3 matrix with signed values
    // Laplacian kernel used for edge detection
    //localparam KERNEL_DIM = 3; *made global
    localparam int signed KERNEL[KERNEL_DIM][KERNEL_DIM] = '{
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
    logic [1:0] validInternal;
    logic [1:0] validInternal1;
    logic [1:0] validInternal2;
    //Buffer is a 1D array indexted with the following scheme
    // 0 - ROW_SIZE-1 --> bottom row of buffer
    // ROW_SIZE - ROW_SIZE*2-1 --> middle row of buffer
    // ROW_SIZE*2 - ROW_SIZE*2+2 --> top row of buffer (this is just 3px of data)
    logic [WORD_SIZE-1:0] buffer[ROW_SIZE*2+2:0];
    logic signed [WORD_SIZE+4:0] product[KERNEL_DIM-1:0][KERNEL_DIM-1:0];
    logic signed [WORD_SIZE+4:0] sum;
    //logic [1:0] valid;
    logic [$clog2(ROW_SIZE*2+2):0] countInit;    //size of the buffer
    logic [$clog2(ROW_SIZE-1):0] countRunning;   //size of ONE row of the buffer

    always_ff @(posedge clk) begin
        //if rst then reset both the count and the set the window to all 0
      if (rst) begin
          validInternal <= 0;
          validInternal1 <= 0;
          validInternal2 <= 0;
          valid <= 0;
          countInit <= 0;
          countRunning <= 0;
        //  for (int i = 0; i < KERNEL_DIM; i++) begin
       //     for (int j = 0; j < KERNEL_DIM; j++) begin
       //     window[i][j] <= 0;
     //     end

      //    for (int i = 0; i < KERNEL_DIM; i++) begin
      //      for (int j = 0; j < KERNEL_DIM; j++) begin
      //        product[i][j] <= 0;
      //      end
      //    end

       // end
        //case for when the count is less than the buffer size and needs to be filled
      end else begin
        if (countInit < ROW_SIZE*2+3) begin
         // buffer[count] <= inputPixel;
          countInit <= countInit + 1;
          validInternal <= 0; 
          //$display("Here");
        end
        else if (countRunning == ROW_SIZE) begin
          //Restart the countRunning as we have moved to a new "line"
          countRunning <= 0;
          validInternal <= 0; // I changed this to a zero from a 1. Might still be a one 
        end
        else if (countRunning == 0) begin 
          countRunning <= countRunning + 1;
          validInternal <= 0;           
        end
        else begin
        //normal case when buffer is filled and the window is not at an edge 
        //we will need to add a case for when the window is at the theoretical edge and 
        //extra buffer shift ins need to occur without being read
          validInternal <= 1;
          countRunning <= countRunning + 1; // indicate that we have moved one pixel forward in running count
          //buffer <= {inputPixel, buffer[ROW_SIZE*2+2:1]};
          //shift in one pixle into the buffer (and one pixle out)
          //for (int i = 0; i < ROW_SIZE*2+2; i++) begin
          //  buffer[i] <= buffer[i+1];
          //end
         // buffer <= {inputPixel, buffer[ROW_SIZE*2+2:1]};
          //set the last buffer to the input pixel
          //buffer[ROW_SIZE*2+2] <= inputPixel;
        end 
      end
    buffer <= {inputPixel, buffer[ROW_SIZE*2+2:1]};
    end

    always_comb begin
          window[2][2] = buffer[ROW_SIZE*2+2];
          window[2][1] = buffer[ROW_SIZE*2+1];
          window[2][0] = buffer[ROW_SIZE*2];
          window[1][2] = buffer[ROW_SIZE+2];
          window[1][1] = buffer[ROW_SIZE+1];
          window[1][0] = buffer[ROW_SIZE];
          window[0][2] = buffer[2];
          window[0][1] = buffer[1];
          window[0][0] = buffer[0];
    end


    // convolution: product of element-wise multiplication, then total sum of window

    // Convolution operation
    always_ff @(posedge clk) begin
        if (rst) begin
          for (int i = 0; i < KERNEL_DIM; i++) begin
            for (int j = 0; j < KERNEL_DIM; j++) begin
              validInternal1 <= validInternal;
              product[i][j] <= 0;
            end
          end
        end else begin
          if (validInternal == 0) begin
            for (int i = 0; i < KERNEL_DIM; i++) begin
              for (int j = 0; j < KERNEL_DIM; j++) begin
                validInternal1 <= validInternal;
                product[i][j] <= 0;
              end
            end
          end else begin
            //convolution  occurs here
            for (int i = 0; i < KERNEL_DIM; i++) begin
              for (int j = 0; j < KERNEL_DIM; j++) begin
                validInternal1 <= validInternal;
                product[i][j] <= window[i][j] * KERNEL[i][j];
              end
            end
      end
    end
  end

  
    always_ff @(posedge clk) begin
      if (rst) begin 
        validInternal2 <= validInternal1;
        sum <= 0;
      end
      else begin 
        validInternal2 <= validInternal1;
        sum <= product[0][0] + product[0][1] + product[0][2] + product[1][0] + product[1][1] + product[1][2] + product[2][0] + product[2][1] + product[2][2];
      end
    end

    

    // The output pixel is calculated as the sum of the products, clamped to the range [0, 255].
    // The output pixel is stored in the outputPixel register.
    // The output pixel is clamped to the range [0, 255] to ensure that the output
    // pixel is a valid 8-bit value.
    always_ff @(posedge clk) begin
        if (rst) begin 
            valid <= validInternal2;
            outputPixel <= 0;
        end
        else begin
            if (sum < 0) begin 
              valid <= validInternal2;
              outputPixel <= 0;
            end
            else if (sum > 255) begin 
              valid <= validInternal2;
              outputPixel <= 255;
            end
            else begin
              valid <= validInternal2;
              outputPixel <= sum;
            end
        end
    end
endmodule
