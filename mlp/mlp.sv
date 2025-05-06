module mlp #(parameter DATA_SIZE = 8, 
parameter NUM_LAYERS = 2, 
parameter MAX_WEIGHTS_SIZE=32,
parameter MAX_COL_ROW_BITS = 6,
parameter LAYER_BITS = 2,
parameter MAX_BRAM_SIZE = 5,
parameter MEM_ADDR_WIDTH = 3,
parameter MAX_COL_ROWS = 9)(



    input logic clk,
    input logic [DATA_SIZE-1:0] input_data [MAX_WEIGHTS_SIZE],
    input logic [MAX_COL_ROW_BITS-1:0] all_rows_sizes [NUM_LAYERS], 
    input logic [MAX_COL_ROW_BITS-1:0] all_cols_sizes [NUM_LAYERS], 
    input logic [LAYER_BITS-1:0] layer_sizes [NUM_LAYERS],
    input logic rst,
    input logic new_data, 
    output logic output_ready,
    output logic [DATA_SIZE-1:0]  mlp_output
);

    logic output_ready_next;
    logic [DATA_SIZE-1:0] mlp_output_not_final [MAX_WEIGHTS_SIZE-1:0];

   logic [MAX_COL_ROW_BITS-1:0] total_rows;

   logic [MAX_COL_ROW_BITS-1] 	rows_left;
   

    typedef enum logic [5:0] { 

        START = 6'b000001,
        COMPUTE_LAYER = 6'b000010,
        COMPLETED = 6'b100,
			       
			       GET_DATA = 6'b1000,
			       FINISH_LAYER = 6'b10000
    } mlp_states;
   
    mlp_states mlp_state;
    mlp_states mlp_state_next;
    logic [LAYER_BITS-1:0] layer_step; // for if layers need multiple steps
    logic [LAYER_BITS-1:0] layer_step_next; // not used yet

    logic [LAYER_BITS-1:0] cur_layer;
    logic [LAYER_BITS-1:0] cur_layer_next;

    logic [DATA_SIZE-1:0] layer_result [MAX_WEIGHTS_SIZE];
   logic [DATA_SIZE-1:0]  layer_output [MAX_WEIGHTS_SIZE];

   logic [DATA_SIZE-1:0]  mlp_output_next;

      logic [DATA_SIZE-1:0] intermediate_result [MAX_WEIGHTS_SIZE];
   logic [DATA_SIZE-1:0]  intermediate_result_next [MAX_WEIGHTS_SIZE];
   
   


    //bram

    logic read_en;
    logic read_en_next;

   logic  bram_data_ready;
   
  
    logic write_en = 0;
    logic [MEM_ADDR_WIDTH-1:0] rd_addr;
   logic [MEM_ADDR_WIDTH-1:0]  rd_addr_next;
   
    logic [MEM_ADDR_WIDTH-1:0] wr_addr = 0;
    logic [DATA_SIZE-1:0] data_in [MAX_WEIGHTS_SIZE];
    logic [DATA_SIZE-1:0] data_out [MAX_WEIGHTS_SIZE];

    //multiplication
    
    logic [DATA_SIZE-1:0] layer_input [MAX_WEIGHTS_SIZE];

    logic [MAX_COL_ROW_BITS-1:0] rows;
    logic [MAX_COL_ROW_BITS-1:0] rows_next;
    logic [MAX_COL_ROW_BITS-1:0] cols;
    logic [MAX_COL_ROW_BITS-1:0] cols_next;


    // modules

    bram  
    bram_module (
    .clk(clk),
    .rst(rst),
    .read_en(read_en),
    .wr_en(write_en),
    .rd_addr(rd_addr),
    .wr_addr(wr_addr),
    .data_in(data_in),
    .data_out(data_out),
		 .data_ready(bram_data_ready)
    );

    multiplication #(.MAX_COLS_ROWS(MAX_COL_ROWS),
     .MAX_WEIGHTS_SIZE(MAX_WEIGHTS_SIZE),
      .DATA_SIZE(DATA_SIZE),
      .MAX_COL_ROW_BITS(MAX_COL_ROW_BITS)) 
      multiplication_module (
        .weights(data_out),
        .layer_input(layer_input),
        .rows(rows),
        .cols(cols),
        .output_values(layer_output)
    );

    always_ff @(posedge clk or posedge rst) begin
       //$display("NEXT STATE");
       //$display("cur read addr: %d",rd_addr);
       
       
        if (rst) begin
           mlp_state <= START;
	   
            cur_layer <= 0;
            read_en <= 0;

        end else begin
	   mlp_output <= mlp_output_next;
	   
            mlp_state <= mlp_state_next;
            cur_layer <= cur_layer_next;
            layer_input <= layer_result;
            output_ready <= output_ready_next;
            read_en <= read_en_next;
            rd_addr <= rd_addr_next;
            //rows <= rows_next;
            //cols <= cols_next;
	   intermediate_result <= intermediate_result_next;
	   



        end
    end


    always_comb begin
        // mlp state and next values
        mlp_state_next = mlp_state;
       //rd_addr_next = 0;
       rows = all_rows_sizes[cur_layer];
      cols = all_cols_sizes[cur_layer];
       

        case(mlp_state) 
            START: begin
	       rd_addr_next = 0;
	       
                if (new_data) begin
                    mlp_state_next = GET_DATA;
                    read_en_next = 1;
                   rd_addr_next = rd_addr+1;
;
                    cur_layer_next = 0;
                    layer_result = input_data;
                    output_ready_next = 0;

                end 
else begin
   layer_result = input_data;
end
          
            end // case: START

	  GET_DATA: begin
	      //if (bram_data_ready) begin
		  //$display("BRAM DATA READY");
		  
		  mlp_state_next = COMPUTE_LAYER;
		  layer_result = input_data; // new
		  rd_addr_next = rd_addr + 1; // newest
		  //cur_layer_next = cur_layer + 1;
		  
		  
		  
		  
		  
	      //end
	     end
	       
		  
		  
             
            COMPUTE_LAYER: begin
                if (cur_layer < NUM_LAYERS-1) begin

                read_en_next = 1;
                rd_addr_next = rd_addr + 1;
      

		if ((rows * cols) > 32) begin
		   rows = MAX_WEIGHTS_SIZE / all_cols_sizes[cur_layer]; 
		   rows_left = all_rows_sizes[cur_layer] - rows;
		   total_rows = all_rows_sizes[cur_layer];
		   
		   
		   cur_layer_next = cur_layer;

		  intermediate_result_next  = layer_output;
		   mlp_state_next = FINISH_LAYER;
		   
		   //layer_result = layer_input[rows:total_rows-1]; // need to use a loop to do this
		   for (int i = 0; i < MAX_COL_ROWS; i++) begin
		      if (i < total_rows-rows) begin
			 layer_result[i] = layer_input[i+rows];
			 
		      end
		      
		      
		   
		   
		   
		   
		   
		   
		   end // for (int i = 0; i < MAX_COL_ROWS; i++)
		end // if ((rows * cols) > 32)
		   
		else begin
		   layer_result = layer_output;

		   cur_layer_next = cur_layer + 1;
		   mlp_state_next = COMPUTE_LAYER;

		   
		   
				 
		end
		   
		   
		   

          
                end
                else begin
                    mlp_state_next = COMPLETED;
                    read_en_next = 0;
                    rd_addr_next = 0;
                    cur_layer_next = 0;
                    output_ready_next = 1;
		   mlp_output_next = layer_output[0];
		   
		   
                    //mlp_output_not_final = layer_result; // not using right now
                end // else: !if(cur_layer < NUM_LAYERS-1)
	      
            end // case: COMPUTE_LAYER
	  FINISH_LAYER: begin
	     // step 1: finish the calculation
	     //rows = MAX_WEIGHTS_SIZE / all_cols_sizes[cur_layer]; // should be integer
	     rows_left = all_rows_sizes[cur_layer] - (MAX_WEIGHTS_SIZE / all_cols_sizes[cur_layer]);
	     total_rows = all_rows_sizes[cur_layer];
	     rows = rows_left; // remaining rows
	     //layer_result = {intermediate_result[0:total_rows-rows_left-1], layer_output[0:rows_left-1]}; 

	      for (int i = 0; i < MAX_COL_ROWS; i++) begin
		      if (i < all_rows_sizes[cur_layer]) begin
			 //$display("i: %d", i);
			 
			 if (i < total_rows-rows_left) begin
			 layer_result[i] = intermediate_result[i];
			 end
			 else begin
			    layer_result[i] = layer_output[i-(MAX_WEIGHTS_SIZE / all_cols_sizes[cur_layer])];
			    
							       end
		      end
		 
		   
		   
	      end // for (int i = 0; i < MAX_COL_ROWS; i++)
	    // $display("layer_result in FINISH_LAYER state: %p, ",layer_result);
	     
	     
	      if (cur_layer < NUM_LAYERS-1) begin

                read_en_next = 1;
                rd_addr_next = rd_addr + 1;


		   cur_layer_next = cur_layer + 1;
		   mlp_state_next = COMPUTE_LAYER;
	       
	      end
	     
	      else	begin
		   
		    mlp_state_next = COMPLETED;
                    read_en_next = 0;
                    rd_addr_next = 0;
                    cur_layer_next = 0;
                    output_ready_next = 1;
		   mlp_output_next = layer_output[0];
        
	      end // else: !if(cur_layer < NUM_LAYERS-1)
	     
	     
	     

	     
	     
	     
	  end // case: FINISH_LAYER
	  
	  
            COMPLETED: begin
                mlp_state_next = START;
                read_en_next = 0;
                rd_addr_next = 0;
                cur_layer_next = 0;
                output_ready_next = 0;
	       
	       


            end


        endcase








      
      // output
      if (mlp_state == COMPLETED) begin
	 //$display("REACHED MLP_OUTPUT");
	 
        //output_ready = 1;
	// $display("layer_output: %p", layer_output);
	 //$display("layer_output[0]: %p", layer_output[0]);
	 
	 
	 
       // mlp_output = layer_output[0];
	 $display("layer_output[0] == mlp_output: %d", mlp_output);
	 
      end


    end


   



endmodule
