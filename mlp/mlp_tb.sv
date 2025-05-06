module mlp_tb();
    parameter DATA_SIZE = 8; 
    parameter NUM_LAYERS = 2;
    parameter MAX_WEIGHTS_SIZE=32;
    parameter MAX_COL_ROW_BITS = 6;
    parameter LAYER_BITS = 2;
    parameter MAX_BRAM_SIZE = 5;
    parameter MEM_ADDR_WIDTH = 3;
    parameter MAX_COL_ROWS = 9;
  
   


    logic clk;
    logic [DATA_SIZE-1:0] input_data [MAX_WEIGHTS_SIZE];
    logic [MAX_COL_ROW_BITS-1:0] all_rows_sizes [NUM_LAYERS];
    logic [MAX_COL_ROW_BITS-1:0] all_cols_sizes [NUM_LAYERS];
    logic rst;
    logic new_data;
    logic output_ready;
   logic  [DATA_SIZE-1:0] mlp_output;
   

  // clock generation
  always begin
    #5
    clk = ~clk;
     $display("time: %0t", $time);
     $display("output ready: %d, output val: %p", output_ready, mlp_output);
     
     
  end

    mlp #(.DATA_SIZE(DATA_SIZE),
     .NUM_LAYERS(NUM_LAYERS), 
     .MAX_WEIGHTS_SIZE(MAX_WEIGHTS_SIZE),
     .MAX_COL_ROW_BITS(MAX_COL_ROW_BITS),
     .LAYER_BITS(LAYER_BITS),
     .MAX_BRAM_SIZE(MAX_BRAM_SIZE),
     .MEM_ADDR_WIDTH(MEM_ADDR_WIDTH),
     .MAX_COL_ROWS(9)) mlp_module (
        .clk(clk),
        .input_data(input_data),
        .all_rows_sizes(all_rows_sizes),
        .all_cols_sizes(all_cols_sizes),
        .rst(rst),
        .new_data(new_data),
        .output_ready(output_ready),
        .mlp_output(mlp_output)
     );

  // begin simulation
  initial begin
    clk = 0;
    rst = 1;
    new_data = 0;
    # 5
    rst = 0;
    

    #100
    new_data = 1;
    input_data = '{0: 8'h01, 1: 8'h02, default: 8'h0};
    all_rows_sizes = '{0: 8'h03, 1: 8'h01, default: 8'h0};
    all_cols_sizes = '{0: 8'h02, 1: 8'h03, default: 8'h0};
    #10
    new_data = 0;

    #60
     new_data = 1;
    input_data = '{0: 8'h01, 1: 8'h00, default: 8'h0};
    all_rows_sizes = '{0: 8'h03, 1: 8'h01, default: 8'h0};
    all_cols_sizes = '{0: 8'h02, 1: 8'h03, default: 8'h0};
    #10
    new_data = 0;
     #60
        new_data = 1;
    input_data = '{0: 8'h02, 1: 8'h0, 2: 8'h4, 3: 8'h1,  default: 8'h0};
    all_rows_sizes = '{0: 8'h09, 1: 8'h01, default: 8'h0};
    all_cols_sizes = '{0: 8'h04, 1: 8'h09, default: 8'h0};
    #10
    new_data = 0;
     #60

       #100
    
      
    


    $finish;
  end


endmodule
