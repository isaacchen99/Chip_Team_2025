module counter (
	input logic clk,
	input logic rst,
	
	output logic [9:0] count
);

logic [9:0] count_reg;

always_ff @(posedge clk or posedge rst) begin
  if (rst) begin
    count_reg <= 10'b0;
  end

  else begin
    if (count_reg == 10'd999) begin
      count_reg <= 10'b0;
    end 
    else if (count_reg < 10'd999) begin
      count_reg <= count_reg + 1'b1;
    end
  end

end

assign count = count_reg;

endmodule
