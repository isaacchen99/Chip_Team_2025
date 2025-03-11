
// MLP module

module MLP_Module 
    #(
    parameter DATA_WIDTH = 32;
    parameter OUTPUT_WIDTH = 32;
    NUMLAYERBITS = 4; //number of bits needed to store the number of layers
)(
    input logic clk,
    input logic [DATA_WIDTH-1:0] data,
    input logic rst,
    input logic new_data,
    output logic output_ready,
    output logic [OUTPUT_WIDTH-1:0] mlp_output,
    output logic done

    typedf enum logic [2:0] ( 
        IDLE,
        LOAD_DATA
        COMPUTE,
        DONE
    ) mlp_states;

    mlp_states mlp_state;
    mlp_states mlp_state_next;

    logic [NUMLAYERBITS-1:0] cur_layer;
    logic [WEIGHTSSIZE-1:0] cur_layer_weights;
    logic mem_data_ready;
    
    // getting weights from memory: inputs = cur_layer, outputs = cur_layer_weights and ready signal

    get_weights get_layer_weights (
    .layer_num(cur_layer),
    .output(cur_layer_weights)
    .data_ready(mem_data_ready)
    );

    logic [LAYEROUTPUTSIZE-1:0] layer_calculation;
    logic [LAYERINPUTSIZE-1:0] layer_input;

    compute_layer compute_cur_layer ( 
    .input_values(layer_input),
    .output_values(layer_calculation)
    .data_ready(layer_calc_ready)
    );

    compute_activation compute_cur_activation ( 
    .input_values(layer_calculation),
    .output_values(activation_calculation)
    .data_ready(layer_activation_ready)
    );







    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin

        case(conv_state)
            IDLE: begin 
                if (new_data) begin
                    conv_state_next = LOAD_DATA;
                    curlayer = 0;                 
                end else begin
                    conv_state_next = IDLE;
                end
            end
            LOAD_DATA: begin
                // get data from memory
                // get weights for the current layer

                
                if (mem_data) begin
                    conv_state_next = COMPUTE;
                    
                    
                end else begin 
                    conv_state_next = LOAD_DATA;
                end
            end
            COMPUTELAYER: begin
                if (cur_layer < NUM_LAYERS) begin
                    
                    
                    // compute the results of that layer

                    cur_layer = cur_layer + 1
                    conv_state_next = COMPUTING;
                end else begin
                    conv_state_next = COMPLETED;
                end
                
            end
            ACTIVATION: begin
                if ()
            end

            COMPLETED: begin
                if (new_data) begin
                    conv_state_next = LOAD_DATA;
                end else begin
                    cur_layer = 0;
                    conv_state_next = IDLE;
                end
            end




        endcase
    end

    // outputting the results



);
endmodule


// RELU module
module relu #(parameter WIDTH = 8) (
    input  logic [WIDTH-1:0] in,
    output logic [WIDTH-1:0] out
);

    always_comb begin
        if (in > 0)
            out = in;
        else
            out = 0;
    end
endmodule

module get_weights(
    input logic [NUMLAYERBITS-1:0] layer_num,
    output logic [WEIGHTSSIZE-1:0] output,
    output logic data_ready
);

    // get weights from memory
    // output the weights for the current layer
    // output the ready signal
endmodule

module compute_layer(
    input logic [LAYERINPUTSIZE-1:0] input_values,
    output logic [LAYEROUTPUTSIZE-1:0] output_values,
    output logic data_ready
);

    // compute the results of the current layer
    // output the results
    // output the ready signal
endmodule

module compute_layer(
    input logic [LAYERINPUTSIZE-1:0] input_values,
    output logic [LAYEROUTPUTSIZE-1:0] output_values,
    output logic data_ready
);

    // compute the results of using the activation function
    // output the results
    // output the ready signal
endmodule