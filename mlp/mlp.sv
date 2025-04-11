
// MLP module

module mlp
    #(
    parameter DATA_WIDTH = 16, // input data is just 1 or 0
    parameter OUTPUT_WIDTH = 1, // result is just 1 or 0
    parameter NUMLAYERS = 2,
    parameter LARGESTWEIGHT = 24, // 8 x 3
    parameter NUM_FEATURES = 2
)(
    input logic clk,
    input logic [DATA_WIDTH-1:0] data [NUM_FEATURES-1:0], // input data
    input logic rst,
    input logic new_data,
    output logic output_ready,
    output logic mlp_output
    //output logic done
);
    typedef enum logic [5:0] { 
        IDLE = 6'b000001,
        LOAD_WEIGHTS = 6'b000010,
        COMPUTE_LAYER= 6'b000100,
        ACTIVATION = 6'b001000,
        RESULT = 6'b010000,
        COMPLETED = 6'b100000
    } mlp_states;
   
    mlp_states mlp_state;
    mlp_states mlp_state_next;

    // STEP 3

    logic [15:0] activation_calculation_1 [0:8];

   logic [15:0] layer_input_1 [0:NUM_FEATURES-1];
    logic [15:0] layer_calculation_1 [0:8];
    logic layer_calc_ready_1;
   logic cur_layer;
   logic  cur_layer_next;
   
    logic [15:0] cur_layer_weights [0:LARGESTWEIGHT-1];
    logic mem_data_ready;

    logic [15:0] layer_input_2 [0:8];
    logic [15:0] layer_calculation_2;
    logic layer_calc_ready_2;
    
    relu #(.WIDTH(9)) relu_1 ( 
    .in(layer_calculation_1),
    .out(activation_calculation_1)
    );

    logic [15:0] activation_calculation_2;

    relu  #(.WIDTH(1)) relu_2( 
    .in(layer_calculation_2),
    .out(activation_calculation_2)
    );

    // STEP 1

    


    get_weights #(.MAXWEIGHTSIZE(24)) get_cur_weights (
    .layer_num(cur_layer),
    .memory_output(cur_layer_weights),
    .data_ready(mem_data_ready)
    );

    // STEP 4


    logic result_val;
    result final_result (
        .result_prob(activation_calculation_2),
        .result_output(result_val)
			 );
   

    // STEP 2

    



    computing_layer #(.WEIGHT_COLS(8), .WEIGHT_ROWS(3)) compute_layer_1( 
    .input_values(layer_input_1),
    .weights(cur_layer_weights),    
    .output_values(layer_calculation_1),
    .data_ready(layer_calc_ready_1)
    );

   

    computing_layer #(.WEIGHT_COLS(1), .WEIGHT_ROWS(9)) compute_layer_2(
    .input_values(layer_input_2),
    .weights(cur__layerweights),
    .output_values(layer_calculation_2),
    .data_ready(layer_calc_ready_2)
    );











    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            mlp_state <= IDLE;
            cur_layer <= 0;
        end else begin
            mlp_state <= mlp_state_next;
            cur_layer <= cur_layer_next;
        end
    end

    always_comb begin
        mlp_state_next = mlp_state;
        cur_layer_next = cur_layer;

        case(mlp_state)
            IDLE: begin
                if (new_data) begin
                    mlp_state_next = LOAD_WEIGHTS;                  
                    layer_input_1 = data;
                end
                else begin
                    mlp_state_next = IDLE;
                end
                cur_layer_next = 0;
                
            end

            LOAD_WEIGHTS: begin
                if (mem_data_ready) begin
                    mlp_state_next = COMPUTE_LAYER;
                    if (cur_layer == 0) begin
                        //layer_input_1 is already set                   

                    end
                    else begin // cur_layer == 1
                        layer_input_2 = activation_calculation_1;
                    end
                    mlp_state_next = COMPUTE_LAYER;
                end
                else begin
                    mlp_state_next = LOAD_WEIGHTS;
                end                    
            end

            COMPUTE_LAYER:

                mlp_state_next = ACTIVATION;


            ACTIVATION:
                if (cur_layer < 1) begin
                    cur_layer_next = cur_layer + 1;
                    mlp_state_next = LOAD_WEIGHTS;
                end
                else begin
                    mlp_state_next = RESULT;
                end
            RESULT:
                mlp_state_next = COMPLETED;
            COMPLETED: begin
                if (new_data) begin
                    mlp_state_next = LOAD_WEIGHTS;
                end
                else begin
                    mlp_state_next = IDLE;
                end
                cur_layer_next = 0;
	       end

    
        endcase

    end // end always_comb
    assign output_ready = mlp_state == COMPLETED;
    assign mlp_output = result_val;



endmodule


// RELU module
module relu #(parameter WIDTH = 8) (
    input logic [15:0] in [0:WIDTH-1], // array with numvals values of 16 bits each
    output logic [15:0] out [0:WIDTH-1]
);
    always_comb begin
        for (int i = 0; i < WIDTH; i++) begin
            if (in[15] == 0)
                out[i] = in[i];
            else
                out[i] = 16'b0;
        end
    end
endmodule


module get_weights #(MAXWEIGHTSIZE = 24)(
    input logic  layer_num, // 0 for layer 1, 1 for layer 2
    output logic [15:0] memory_output [0:MAXWEIGHTSIZE-1],
    output logic data_ready
);
    // weights 1 has 8 columns and 3 rows (24 total)
    logic [15:0] weights1 [0:23] = '{ 16'b0001010011010000, 16'b1111110011100001, 16'b0001001101101001, 16'b0000001111010010, 16'b0000000101101111, 16'b1111111010011100, 16'b0000011001000010, 16'b1110110110111010, 16'b0000110000000011, 16'b0001011001010000, 16'b0001010000000001, 16'b1111000100011111, 16'b0001111001100011, 16'b0001101111011101, 16'b1110000110011011, 16'b1111010011110001, 16'b0000000101100000, 16'b0000011101100101, 16'b0000101001001110, 16'b0000101011010000, 16'b0000011001110000, 16'b1111111111110011, 16'b0011001001101101, 16'b1100110110000110 };
    logic [15:0] weights2 [0:8]= '{ 16'b0000100101100111, 16'b0000110000000111, 16'b0000000101001111, 16'b0001011100111001, 16'b1111000011011111, 16'b1101101111111000, 16'b0000010101011111, 16'b1111101001101111, 16'b0100011010001100};


    always_comb begin
        if (layer_num == 0) begin
            memory_output = weights1;
        end else begin // layernum == 1
            memory_output[0:8] = weights2;
            memory_output[9:23] = '{default:0}; // fill the rest with 0s
        end
        data_ready = 1; 
    end



    // get weights from memory
    // output the weights for the current layer
    // output the ready signal
endmodule



module computing_layer #(WEIGHT_COLS = 8, WEIGHT_ROWS = 8) (
    input logic [15:0] input_values [0:WEIGHT_COLS-2],
    input logic [15:0] weights [0:WEIGHT_COLS*WEIGHT_ROWS-1],
    output logic [15:0] output_values [0:WEIGHT_COLS-1],
    output logic data_ready
);
    logic [15:0] new_input_values [0:WEIGHT_COLS-1];
   logic [31:0]  multiplication_result [0:WEIGHT_COLS-1];

    always_comb begin

        
        new_input_values[0] = 16'b0001000000000000;
        new_input_values[1:WEIGHT_COLS-1] = input_values;

        
       
        

        for (int i = 0; i < WEIGHT_COLS; i++) begin
            multiplication_result[i] = 0;
            for (int j = 0; j < WEIGHT_ROWS; j++) begin
               multiplication_result[i] += weights[j*WEIGHT_ROWS+i] * new_input_values[j];
	       
            end
           output_values[i] = multiplication_result[i][20:4];
	   
        end
        
        data_ready = 1; 
    end
endmodule


module result (
    input logic signed [15:0] result_prob,
    output logic result_output);
    // need a module to convert probability predictions to one or zero
    always_comb begin
        if (result_prob[12] == 1) begin // >= 0.5
            result_output = 1;
        end else begin
            result_output = 0;
        end
    end
endmodule



