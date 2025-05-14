module gray_scale #(
  DATA_WIDTH = 8
) (
  input logic clk,
  input logic rst,
  input logic input_empty,
  input logic output_full,
  input logic [DATA_WIDTH-1:0] red,
  input logic [DATA_WIDTH-1:0] green,
  input logic [DATA_WIDTH-1:0] blue,
  output logic read_fifo,
  output logic write_fifo,
  output logic [DATA_WIDTH-1:0] gray_image
);

  logic [DATA_WIDTH-1:0] gray_value; 

  assign gray_value = 8'(($unsigned({2'b0, red}) +
    $unsigned({2'b0, green}) + $unsigned({2'b0, blue})) / $unsigned(10'd3));
  
  manage_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_INPUTS(1),
    .NUM_OUTPUTS(1)
  ) manage_gray (
    .clk(clk),
    .rst(rst),
    .inputs_empty(input_empty),
    .outputs_full(output_full),
    .din(gray_value),
    .read_fifo(read_fifo),
    .write_fifo(write_fifo),
    .dout(gray_image)
  );
  

endmodule



