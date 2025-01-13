module counter (
	input logic clk,
	input logic rst,
	
	output logic [9:0] count
);

logic [9:0] count_reg;

always_ff begin
  if (rst) begin
    current_count <= 10'b0;
  end

  else begin
    if (current_count == 10'd999) begin
      current_count <= 10'b0;
    end 
    else if (current_count < 10'd999) begin
      current_count <= current_count + 1'b1;
    end
  end

end

assign count = count_reg;

endmodule