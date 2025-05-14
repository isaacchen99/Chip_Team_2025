module edge_detect_top #(
  DATA_WIDTH = 8
) (
  input logic clk,
  input logic rst,
  input logic wr_inputs,
  input logic rd_output,

  input logic [DATA_WIDTH-1:0] red_in,  
  input logic [DATA_WIDTH-1:0] green_in,
  input logic [DATA_WIDTH-1:0] blue_in,  
  output logic fifo_in_gray_full,
  output logic out_empty,

  output logic [DATA_WIDTH-1:0] data_out  
);

  logic [DATA_WIDTH-1:0] red_in_to_gray;
  logic [DATA_WIDTH-1:0] green_in_to_gray; 
  logic [DATA_WIDTH-1:0] blue_in_to_gray;

  logic empty_in_to_gray;
  logic full_gray_in_to_fifo;
  logic rd_in_fifo;
  logic wr_in_fifo;

  logic [DATA_WIDTH-1:0] gray_in;

  logic [DATA_WIDTH-1:0] gray_in_fifo_out;
  logic gray_in_fifo_empty;

  logic wr_sobel_fifo;
  logic [DATA_WIDTH-1:0] sobel_out;
  logic full_sobel_out_fifo;


  fifo #(
    .FIFO_DATA_WIDTH(3 * DATA_WIDTH),
    .FIFO_BUFFER_SIZE(4)
  ) in_to_gray_fifo (
    .reset(rst),
    .wr_clk(clk),
    .wr_en(wr_inputs),
    .din({red_in, green_in, blue_in}),
    .full(fifo_in_gray_full),
    .rd_clk(clk),
    .rd_en(rd_in_fifo),
    .dout({red_in_to_gray, green_in_to_gray, blue_in_to_gray}),
    .empty(empty_in_to_gray)
  );
  
  gray_scale #(
    .DATA_WIDTH(DATA_WIDTH)
  ) gray_scale_in (
    .clk(clk),
    .rst(rst),
    .input_empty(empty_in_to_gray),
    .output_full(full_gray_in_to_fifo),
    .red(red_in_to_gray),
    .green(green_in_to_gray),
    .blue(blue_in_to_gray),
    .read_fifo(rd_in_fifo),
    .write_fifo(wr_in_fifo),
    .gray_image(gray_in)
  );

  fifo #(
    .FIFO_DATA_WIDTH(DATA_WIDTH),
    .FIFO_BUFFER_SIZE(4)
  ) gray_in_fifo (
    .reset(rst),
    .wr_clk(clk),
    .wr_en(wr_in_fifo),
    .din(gray_in),
    .full(full_gray_in_to_fifo),
    .rd_clk(clk),
    .rd_en(rd_gray_fifo),
    // .rd_en(rd_output),
    .dout(gray_in_fifo_out),
    // .dout(data_out), 
    .empty(gray_in_fifo_empty)
    // .empty(out_empty)
    );
    
  sobel #(
    .DATA_WIDTH(DATA_WIDTH), 
    .IMAGE_WIDTH(720),
    .IMAGE_HEIGHT(540),
    .KERNEL_LEN(3)
  ) sobel_unit (
    .clk(clk),
    .rst(rst),
    .input_empty(gray_in_fifo_empty),
    .output_full(full_sobel_out_fifo),
    .gray_in(gray_in_fifo_out),
    .read_fifo(rd_gray_fifo),
    .write_fifo(wr_sobel_fifo),
    .sobel_out(sobel_out)
  );

  fifo #(
    .FIFO_DATA_WIDTH(DATA_WIDTH),
    .FIFO_BUFFER_SIZE(4)
  ) sobel_out_fifo (
    .reset(rst),
    .wr_clk(clk),
    .wr_en(wr_sobel_fifo),
    .din(sobel_out),
    .full(full_sobel_out_fifo),
    .rd_clk(clk),
    .rd_en(rd_output),
    .dout(data_out), 
    .empty(out_empty)
  );

endmodule