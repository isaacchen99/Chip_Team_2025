module mlp_tb();

  logic clk, rst, new_data, mlp_output, output_ready;
  logic [1:0] data [15:0];

  // clock generation
  always begin
    #5
    clk = ~clk;
  end

  always begin
        #5;
        $display("Time: %0t | output_ready: %b | mlp_output: %b", $time, output_ready, mlp_output);
    end

  // instantiate uut
  mlp mlp_module (
      .clk(clk),
      .rst(rst),
      .data(data)
      .new_data(new_data)
      .output_ready(output_ready)
      .mlp_output(mlp_output)
      
  );

  // begin simulation
  initial begin
    clk = 0;
    

    rst = 1;
    #5
    rst = 0;

    #5
    new_data = 1;
    data = '{ 16'b0001000000000000, 16'b0  }

    // Monitor output_ready and mlp_output every 5 time units
    

    #2000

    $finish;
  end


endmodule