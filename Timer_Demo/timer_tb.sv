module timer_tb;

  // Parameters
  localparam DATA_WIDTH = 8;

  // Signals
  logic clk;
  logic rst;
  logic start;
  logic stop;
  logic [DATA_WIDTH-1:0] data_in;
  logic done;

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk; // 100 MHz clock (10 ns period)

  // DUT instantiation
  timer #(
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .stop(stop),
    .data_in(data_in),
    .done(done)
  );

  // Test sequence
  initial begin
    $display("Starting test bench...");

    // Initialize inputs
    rst = 1;
    start = 0;
    stop = 0;
    data_in = 0;
    
    // Reset the system
    @(negedge clk);
    rst = 1;
    @(negedge clk);
    rst = 0;

    // Test Case 1: Start the timer
    $display("Test Case 1: Start the timer");
    data_in = 8'h0A; // Set max count to 10
    start = 1;
    @(negedge clk);
    start = 0;

    // Wait for the timer to finish
    wait(done);
    $display("Timer reached done state at time %t", $time);

    // Test Case 2: Pause and resume the timer
    $display("Test Case 2: Pause and resume");
    rst = 1;
    @(negedge clk);
    rst = 0;
    data_in = 8'h0F; // Set max count to 15
    start = 1;
    @(negedge clk);
    start = 0;

    // Wait for a few clock cycles
    repeat(5) @(negedge clk);
    stop = 1;
    @(negedge clk);
    stop = 0;

    // Resume the timer
    start = 1;
    @(negedge clk);
    start = 0;

    // Wait for the timer to finish
    wait(done);
    $display("Timer reached done state after pause at time %t", $time);

    // Test Case 3: Reset during operation
    $display("Test Case 3: Reset during operation");
    rst = 1;
    @(negedge clk);
    rst = 0;
    data_in = 8'h10; // Set max count to 16
    start = 1;
    @(negedge clk);
    start = 0;

    // Wait for a few clock cycles
    repeat(8) @(negedge clk);

    // Assert reset
    rst = 1;
    @(negedge clk);
    rst = 0;

    $display("Reset occurred during operation, timer state should reset.");

    // End simulation
    $display("All tests completed at time %t", $time);
    $stop;
  end

endmodule