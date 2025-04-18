module convolution_tb();
    parameter WORD_SIZE = 8;
    parameter ROW_SIZE = 540;
    parameter IMAGE_HEIGHT =360;
    parameter IMAGE_WIDTH = ROW_SIZE;

    logic clk, rst;
    logic [WORD_SIZE-1:0] inputPixel;
    logic [WORD_SIZE-1:0] outputPixel;
    
    logic [WORD_SIZE-1:0] input_image [0:IMAGE_HEIGHT-1][0:IMAGE_WIDTH-1];
    logic [WORD_SIZE-1:0] output_image [0:IMAGE_HEIGHT-1][0:IMAGE_WIDTH-1];

    int i, j, file;

    convolution #(.WORD_SIZE(WORD_SIZE), .ROW_SIZE(ROW_SIZE)) convolution_uut (
        .clk(clk),
        .rst(rst),
        .inputPixel(inputPixel),
        .outputPixel(outputPixel)
    );

    always #5 clk = ~clk;
    always @(posedge clk) begin
        $display("Input: %h, Output: %h", inputPixel, outputPixel);
    end

    initial begin
        clk = 0;
        rst = 1;

        $readmemh("image_data.hex", input_image);

        #10 
        rst = 0;

        for (i = 0; i < IMAGE_HEIGHT; i = i + 1) begin
            for (j = 0; j < IMAGE_WIDTH; j = j + 1) begin
                @(posedge clk); 
                inputPixel = input_image[i][j];
                $display("Sent to DUT: Row %d, Col %d, Pixel: %h", i, j, inputPixel);
                @(posedge clk);     // add this delay to ensure pixel is stable
            end
        end

        // delay
        repeat(50) @(posedge clk);  

        file = $fopen("output_verilog.hex", "w");
        for (i = 0; i < IMAGE_HEIGHT; i = i + 1) begin
            for (j = 0; j < IMAGE_WIDTH; j = j + 1) begin
                @(posedge clk);
                output_image[i][j] = outputPixel;
                $fdisplay(file, "%h", output_image[i][j]);
            end
        end
        $fclose(file);

        $finish;
    end

endmodule