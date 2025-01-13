module counter_tb();

  // internal regs
  logic clk, rst;
  logic [9:0] count;

  // clock generation
  always begin
    #5
    clk = ~clk;
  end

  // instantiate uut
  counter counter_uut (
      .clk(clk),
      .rst(rst),
      .count(count)
  );

  // begin simulation
  initial begin
    clk = 0;

    rst = 1;
    #5
    rst = 0;

    #2000

    $finish
  end

endmodule