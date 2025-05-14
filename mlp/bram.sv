module bram #(parameter DATA_WIDTH = 8,
parameter MAX_OUTPUT_SIZE = 32,
parameter MAX_BRAM_SIZE = 5,
parameter ADDR_WIDTH = 3)
(
    input logic 		  clk,
    input logic 		  rst,
    input logic 		  read_en,
    input logic 		  wr_en,
    input logic [ADDR_WIDTH-1:0]  rd_addr,
    input logic [ADDR_WIDTH-1:0]  wr_addr,
    input logic [DATA_WIDTH-1:0]  data_in [MAX_OUTPUT_SIZE],
    output logic [DATA_WIDTH-1:0] data_out [MAX_OUTPUT_SIZE],
    output logic 		  data_ready
); 

  // logic [DATA_WIDTH-1:0] 	  memory [MAX_BRAM_SIZE][MAX_OUTPUT_SIZE] = '{'{0: 8'h01, 1: 8'h02, 2: 8'h03, 3: 8'h01, 4: 8'h02, 5: 8'h03, default: 8'h00}, '{0: 8'h5, 1: 8'h04, 2: 8'h06, default: 8'h0},  '{default: 8'h0},  '{default: 8'h0},  '{default: 8'h0}};
    logic [DATA_WIDTH-1:0] 	  memory [MAX_BRAM_SIZE][MAX_OUTPUT_SIZE] = '{'{0: 8'h02, 1: 8'h00, 2: 8'h05, 3: 8'h03, 4: 8'h01, 5: 8'h04, 6: 8'h06, 7: 8'h02, 8: 8'h00,
  9: 8'h01, 10: 8'h04, 11: 8'h03, 12: 8'h00, 13: 8'h02, 14: 8'h05, 15: 8'h01, 16: 8'h03, 17: 8'h02,
  18: 8'h00, 19: 8'h01, 20: 8'h03, 21: 8'h02, 22: 8'h01, 23: 8'h01, 24: 8'h03, 25: 8'h00, 26: 8'h02,
										27: 8'h00, 28: 8'h01, 29: 8'h02, 30: 8'h01, 31: 8'h03}, '{0: 8'h00, 1: 8'h02, 2: 8'h04, 3: 8'h01, default: 8'h00}, '{0: 8'h03, 1: 8'h00, 2: 8'h02, 3: 8'h00, 4: 8'h04, 5: 8'h00, 6: 8'h01, 7: 8'h00, 8: 8'h03}, '{default: 8'h0},  '{default: 8'h0}};
   

   
    logic [ADDR_WIDTH-1:0] cur_read_addr; 
    always_ff @(posedge clk) begin 
        if (rst) begin
            cur_read_addr <= 0;
        end 
    else begin
       // if (wr_en) begin
           // memory[wr_addr] <= data_in;
	   //$display("memory: %p", memory);
	   
       // end
        if (read_en) begin
	   cur_read_addr <= rd_addr;
	   data_out <= memory[cur_read_addr];
	   data_ready <= 1;
	   
	   
	end
	else
	  begin
	     cur_read_addr <= 0; // temp for testing
	     $display("cur_read_addr next modified");
	     data_ready <= 0;
	     
	     
	  end
       
       
    end
    end

    //always_comb begin
      //// $display("REACHED addr %d", cur_read_addr);
       
       
        //data_out = memory[cur_read_addr]; 
    //end

   


endmodule
