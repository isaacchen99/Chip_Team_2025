module multiplication #(parameter MAX_COLS_ROWS = 4,
 parameter MAX_WEIGHTS_SIZE=32, 
parameter DATA_SIZE = 8,
 parameter MAX_COL_ROW_BITS = 4)
   (

    input logic [DATA_SIZE-1:0] weights [MAX_WEIGHTS_SIZE],
    input logic [DATA_SIZE-1:0] layer_input [MAX_WEIGHTS_SIZE],

    input logic [MAX_COL_ROW_BITS-1:0] rows,
    input logic [MAX_COL_ROW_BITS-1:0] cols,

    output logic [DATA_SIZE-1:0] output_values [MAX_WEIGHTS_SIZE]
);
    // matrix * vector : matrix columns = vector size, matrix rows = output vector size, (result is dot product of each row and the vector)


    logic [DATA_SIZE*2-1:0] mult_result;
    logic [MAX_COL_ROW_BITS-1:0] weight_index; 
    logic [DATA_SIZE-1:0] add_to_output;
   
    
    always_comb begin
       //$display("start");
       //$display("input vals: %p", layer_input);
       
       //$display("weights: %p", weights);
       //$display("rows: %i", rows);

       //$display("Cols: %i", cols);
       
       
       
        output_values = '{default: 8'h0};
        for (int i = 0; i < MAX_COLS_ROWS; i++) begin
        for (int j = 0; j < MAX_COLS_ROWS; j ++) begin 
            if (i < rows && j < cols) begin 
                // output_values[i] because row size is output vector size
                weight_index = i*cols+j;
                mult_result = weights[weight_index] * layer_input[j];

	       

                if ((mult_result & 32'hFF00) != 16'h0) begin
                    add_to_output = 8'hFF;
                    output_values[i] = 8'hFF;
		   //$display("REACHED1: %d, %d", i, j);
		   
                end

                else begin
                   add_to_output = mult_result[7:0] + output_values[i];

		   if((mult_result[7:0] == 0) & (weights[weight_index] == 0 | layer_input[j] == 0)) begin
		      output_values[i] += 0;
		      
		   end
		   
		   
                    else if ((add_to_output < output_values[i]) | (add_to_output < weights[weight_index])) begin
                        // there is overflow
                        output_values[i] = 8'hFF;
		       //$display("REACHED2");
		        //$display("REACHED1: %d, %d", i, j);
		       


                    end
                    else begin
                        output_values[i] += mult_result;
		       //$display("REACHED3");
		        //$display("REACHED1: %d, %d", i, j);
		       
                    end


                end
            end
        end
		end // for (int i = 0; i < MAX_COLS_ROWS; i++)
          //$display("output_values in multiplication module : %p", output_values);
       
       
		//$display("END OF MULTIPLICATION");
    end // always_comb

endmodule














