`default_nettype none

module edge_detect_tb();

  localparam string image_in = "copper_720_540.bmp";
  localparam string gray_scale = "stage0_grayscale.bmp";
  localparam string expected_out_file = "stage2_sobel.bmp";
  localparam string output_image = "rtl_output.bmp";
  localparam CLK_PERIOD = 10ns;

  localparam DATA_WIDTH = 8;

  logic clk;
  logic rst;
  logic wr_inputs;
  logic rd_output;

  logic [DATA_WIDTH-1:0] red_in;
  logic [DATA_WIDTH-1:0] green_in;
  logic [DATA_WIDTH-1:0] blue_in;
  
  logic fifo_in_gray_full;
  
  logic [DATA_WIDTH-1:0] data_out;
  logic out_empty;
  
  // logic [DATA_WIDTH-1:0] expected_red_out;
  // logic [DATA_WIDTH-1:0] expected_green_out;
  // logic [DATA_WIDTH-1:0] expected_blue_out;
  logic [DATA_WIDTH-1:0] expected_out;

  int out_file;
  int i;
  int j;
  int k;

  edge_detect_top #(
    .DATA_WIDTH(8)
  ) edge_detect_top_dut (
    .clk(clk),
    .rst(rst),
    .wr_inputs(wr_inputs),
    .rd_output(rd_output),
    .red_in(red_in),
    .green_in(green_in),
    .blue_in(blue_in),
    .fifo_in_gray_full(fifo_in_gray_full),
    .out_empty(out_empty),
    .data_out(data_out)  
  );
  

  function int read_bmp(input string filename, output byte header[54], output int height, output int width, output byte data[]);

    int f;
    int size;
    int w, h;

    int return_val;
    
    // Open the file in binary mode
    f = $fopen(filename, "rb");
    if (f == 0) begin
      $display("Error opening BMP file");
      return -1;
    end

    // Read the first 54 bytes into the header
    return_val = $fread(header, f);

    if (return_val != 54) begin
      $display("Error reading BMP header. Return val: %d", return_val);
      $fclose(f);
      return -1;
    end

    w = {header[19], header[18]}; 
    h = {header[23], header[22]}; 

    size = ((w * h)) * 3;
    // $display("Size of data is %d", size);
    data = new[size];

    if ($fread(data, f) < size) begin
      $display("Error reading BMP image. Return val: %d", return_val);
      $fclose(f);
      return -1;
    end

    width = w;
    height = h;

    $fclose(f);

    return 0;
  endfunction

  always begin
    #(CLK_PERIOD / 2);
    clk = ~clk;
  end

  initial begin
    byte header[54];
    byte data_in [];
    byte expect_data [];

    byte output_data [];
    byte gray_data [];
    int height;
    int width;
    int size;
    int k;

    read_bmp(image_in, header, height, width, data_in);    
    size = height * width * 3;
    output_data = new[size]; 

    read_bmp(expected_out_file, header, height, width, expect_data);  

    read_bmp(gray_scale, header, height, width, gray_data);  

    rst = 1;
    clk = 0;
    wr_inputs = 0;
    
    red_in   = 0;
    green_in = 0;
    blue_in  = 0; 

    rd_output = 0;

    #CLK_PERIOD;
    rst = 0;
    #CLK_PERIOD;
    
    
    i = 0;
    j = 0;

    
    while(i < ($size(data_in))) begin
      if(!fifo_in_gray_full) begin
        red_in   = data_in[i+2]; 
        green_in = data_in[i+1]; 
        blue_in  = data_in[i];

        wr_inputs = 1;
        i+= 3;
      end else begin
        wr_inputs = 0;
      end
      
      rd_output = 0;
      if (!out_empty) begin
        rd_output = 1;
        // expected_red_out   = expect_data[j+2]; 
        // expected_green_out = expect_data[j+1];   
        expected_out  = expect_data[j];  
        
        output_data[j+2] = data_out;  
        output_data[j+1] = data_out;  
        output_data[j]   = data_out;  
        k = j - 6;
        assert (data_out ==  expected_out) 
          else $error("Expected output %d doesn't match real output %d\n 
          The data in the kernel is %d, %d, %d,\n %d, %d, %d,\n %d, %d, %d\n"
          ,expected_out,  data_out, 
          $unsigned(gray_data[k-width*3-3]), $unsigned(gray_data[k-width*3]), $unsigned(gray_data[k-width*3+3]),
          $unsigned(gray_data[k-3]), $unsigned(gray_data[k]), $unsigned(gray_data[k+3]),
          $unsigned(gray_data[k+width*3-3]), $unsigned(gray_data[k+width*3]), $unsigned(gray_data[k+width*3+3]));
          
        j += 3;
        // if (i == 3* 1500) begin
        //   $stop();
        // end
      end
      #CLK_PERIOD;

    end
    wr_inputs = 0;

    while(!out_empty) begin
      rd_output = 1;
      // expected_red_out   = expect_data[j+2]; 
      // expected_green_out = expect_data[j+1];   
      expected_out  = expect_data[j];  
      
      output_data[j+2] = data_out;  
      output_data[j+1] = data_out;  
      output_data[j]   = data_out;  
       
      assert (data_out ==  expected_out) 
        else $error("Expected output %d doesn't match real output %d\n",  expected_out,  data_out);
          
      j += 3;
      #CLK_PERIOD;
    end

    #CLK_PERIOD;

    
    out_file = $fopen("output_image.bmp", "wb");
    if (out_file == 0) begin
      $display("Error opening file!");
      $stop();
    end
    
    foreach (header[k]) 
      $fwrite(out_file, "%c", header[k]);

    foreach (output_data[k]) 
      $fwrite(out_file, "%c", output_data[k]);

    $fclose(out_file);
    $display("File written successfully.");

    $stop();
  end
  
endmodule