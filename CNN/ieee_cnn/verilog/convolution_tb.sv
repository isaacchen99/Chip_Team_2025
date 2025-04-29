module convolution_tb();
    parameter WORD_SIZE = 8;
    parameter ROW_SIZE = 540;
    parameter IMAGE_HEIGHT =360;
    parameter IMAGE_WIDTH = ROW_SIZE;

    logic clk, rst;
    logic [WORD_SIZE-1:0] inputPixel;
    logic [WORD_SIZE-1:0] outputPixel;
    logic [1:0] valid;
    
    logic [WORD_SIZE-1:0] input_image [0:IMAGE_HEIGHT-1][0:IMAGE_WIDTH-1];
    logic [WORD_SIZE-1:0] output_image [0:IMAGE_HEIGHT-1][0:IMAGE_WIDTH-1];

    int i, j, file;

    convolution #(.WORD_SIZE(WORD_SIZE), .ROW_SIZE(ROW_SIZE)) convolution_uut (
        .clk(clk),
        .rst(rst),
        .inputPixel(inputPixel),
        .outputPixel(outputPixel),
        .valid(valid)
    );

    always #5 clk = ~clk;
    always @(posedge clk) begin
    //  $display("Input: %h, Output: %h", inputPixel, outputPixel);
    end

    initial begin
        clk = 0;
        rst = 1;

        $readmemh("image_data.hex", input_image);

        #10 
        rst = 0;
        // This would assume a top left to bottom right scan of the image
        //for (i = 0; i < IMAGE_HEIGHT; i = i + 1) begin
        //    for (j = 0; j < IMAGE_WIDTH; j = j + 1) begin
        //        @(posedge clk); 
        //        inputPixel = input_image[i][j];
        //        $display("Sent to DUT: Row %d, Col %d, Pixel: %h", i, j, inputPixel);
        //        @(posedge clk);     // add this delay to ensure pixel is stable
        //    end
        //end

        //scan written from bottom left to top right

        file = $fopen("output_verilog.hex", "w");
        for (i = IMAGE_HEIGHT-1; i >= 0; i = i - 1) begin
            for (j = 0; j < IMAGE_WIDTH; j = j + 1) begin
                @(posedge clk); 
                inputPixel = input_image[i][j];
                $display("Sent to DUT: Row %d, Col %d, Pixel: %h", i, j, inputPixel);
                //@(posedge clk);     // add this delay to ensure pixel is stable
                if (valid == 1) begin
                $display("Input: %h, Output: %h", inputPixel, outputPixel);
                $fdisplay(file, "%h", outputPixel);
                end
            end
            //$fdisplay(file, "");
        end

        // delay
        repeat(50) @(posedge clk);  

        //for (i = 0; i < IMAGE_HEIGHT; i = i + 1) begin
        //    for (j = 0; j < IMAGE_WIDTH; j = j + 1) begin
        //        @(posedge clk);
        //        output_image[i][j] = outputPixel;
        //        $fdisplay(file, "%h", output_image[i][j]);
        //    end
        //end
        //for (i = IMAGE_HEIGHT - 1; i >= 0; i = i - 1) begin
        //    for (j = 0; j < IMAGE_WIDTH; j = j + 1) begin
        //        @(posedge clk);
        //        $display("Input: %h, Output: %h", inputPixel, outputPixel);
        //        $fwrite(file, "%h", outputPixel);
        //    end
        //    $fdisplay(file, "");
        //end
        $fclose(file);

        $finish;
    end

endmodule