module timer(
	input logic clk,
	input logic rst,
	input logic [15:0] end_time,
	output logic [15:0] current_time,
	output logic timer_done
	);
	
	// declare internal logic here!
	
	
	// synchronous block
	always_ff @(posedge clk) begin
	
	end
	
	// asynchronous block
	always_comb begin
	
	end
	
endmodule