// `default_nettype none
module sobel #(
  DATA_WIDTH  = 8,
  IMAGE_WIDTH = 720,
  IMAGE_HEIGHT = 540,
  KERNEL_LEN = 3
) (
  input logic clk,
  input logic rst,
  input logic input_empty,
  input logic output_full,
  input logic [DATA_WIDTH-1:0] gray_in,
  output logic read_fifo,
  output logic write_fifo,
  output logic [DATA_WIDTH-1:0] sobel_out
);

  logic [IMAGE_WIDTH*2+KERNEL_LEN-1:0][DATA_WIDTH-1:0] shift_reg;
  logic [IMAGE_WIDTH*2+KERNEL_LEN-1:0][DATA_WIDTH-1:0] shift_reg_next;

  logic [8:0][DATA_WIDTH-1:0] kernel;
  logic [$clog2(IMAGE_WIDTH+1)-1:0] width_counter;
  logic [$clog2(IMAGE_HEIGHT+1)-1:0] height_counter;

  // logic max_width_prev;

  logic min_width;
  logic min_height;

  logic max_width;
  logic max_height;
  
  logic [2:0][DATA_WIDTH:0] vertical_product; 
  logic [2:0][DATA_WIDTH:0] horizontal_product;

  logic [2:0][DATA_WIDTH:0] vertical_product_ff; 
  logic [2:0][DATA_WIDTH:0] horizontal_product_ff;

  logic [DATA_WIDTH+2:0] vertical_sum; 
  logic [DATA_WIDTH+2:0] abs_vertical_sum;

  logic [DATA_WIDTH+2:0] horizontal_sum; 
  logic [DATA_WIDTH+2:0] abs_horizontal_sum;

  logic [DATA_WIDTH+1:0] total_avg;

  logic increment_counters;


  typedef enum logic [2:0] {  
    IDLE,
    FILL_SHIFT,
    PAD_WIDTH,
    PAD_LENGTH,
    PERFORM_SOBEL
  } sobel_state_t;

  sobel_state_t sobel_state;
  sobel_state_t sobel_state_next;

  logic write_fifo_next;
  logic read_fifo_next;

  always_comb begin
    min_width  = width_counter == 0;
    min_height = height_counter == 0;
    
    max_width  = width_counter == IMAGE_WIDTH-1;
    max_height = height_counter == IMAGE_HEIGHT;
    increment_counters = 0;
    write_fifo_next = 0;
    read_fifo_next = 0;

    sobel_state_next = sobel_state;
    shift_reg_next = shift_reg;

    case(sobel_state)
      FILL_SHIFT: begin
        if(!input_empty) begin
          read_fifo_next = 1;
          shift_reg_next = {shift_reg[IMAGE_WIDTH*2+KERNEL_LEN-2:0], gray_in};
          increment_counters = 1;
          if(height_counter > 0 && width_counter > 0 ) begin
            sobel_state_next = PAD_WIDTH; 
          end
        end
      end

      PAD_WIDTH: begin
        if(!input_empty && !output_full) begin
          shift_reg_next = {shift_reg[IMAGE_WIDTH*2+KERNEL_LEN-2:0], gray_in};
          increment_counters = 1;
          write_fifo_next = 1;
          read_fifo_next = 1;

          if(min_width) begin
            if(min_height)begin
              sobel_state_next = FILL_SHIFT;
            end else begin
              sobel_state_next = PAD_LENGTH; 
            end
            
          end
        end
      end
      PAD_LENGTH: begin
        if(!input_empty && !output_full) begin
          increment_counters = 1;
          write_fifo_next = 1;
          read_fifo_next = 1;
          shift_reg_next = {shift_reg[IMAGE_WIDTH*2+KERNEL_LEN-2:0], gray_in};

          if(width_counter > 1) begin
            sobel_state_next = PERFORM_SOBEL; 
          end
        end
      end

      PERFORM_SOBEL: begin
        if(!input_empty && !output_full) begin
          increment_counters = 1;
          write_fifo_next = 1;
          read_fifo_next = 1;
          shift_reg_next = {shift_reg[IMAGE_WIDTH*2+KERNEL_LEN-2:0], gray_in};
        
          if(min_width) begin
            if(max_height) begin
              sobel_state_next = PAD_WIDTH; 
            end else begin
              sobel_state_next = PAD_LENGTH; 
            end
          end
        end
      end
    endcase
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      width_counter <= 0;
      shift_reg <= 0;
      height_counter <= 0;
      sobel_state <= FILL_SHIFT;
      write_fifo <= 0;
      read_fifo <= 0;
      horizontal_product_ff <= 0;
      vertical_product_ff <= 0;

    end else begin
      shift_reg <= shift_reg_next;
      write_fifo <= write_fifo_next;
      read_fifo <= read_fifo_next;
      sobel_state <= sobel_state_next;
      
      horizontal_product_ff <= horizontal_product;
      vertical_product_ff <= vertical_product;

      if(increment_counters) begin
        if (max_width) begin
          width_counter   <= 0;
          height_counter  <= height_counter + 1;
        end else begin
          width_counter <= width_counter + 1;
        end
        if (max_width && max_height) begin
          height_counter <= 0;  
        end
      end
    end
  end



  always_comb begin
    kernel[8:6] = {shift_reg_next[IMAGE_WIDTH*2+2], shift_reg_next[IMAGE_WIDTH*2+1], shift_reg_next[IMAGE_WIDTH*2]};
    kernel[5:3] = {shift_reg_next[IMAGE_WIDTH+2], shift_reg_next[IMAGE_WIDTH+1], shift_reg_next[IMAGE_WIDTH]};
    kernel[2:0] = {shift_reg_next[2], shift_reg_next[1], shift_reg_next[0]};

    if (sobel_state == PAD_LENGTH || sobel_state == PAD_WIDTH) begin
      horizontal_product = 0;
      vertical_product = 0;
    end else begin
      for (int i = 0; i < 3; i++) begin
        horizontal_product[i] = $signed({1'b0, kernel[3*i]}) - $signed({1'b0, kernel[3*i+2]});
        vertical_product[i] = $signed({1'b0, kernel[i]}) - $signed({1'b0, kernel[i+6]});
      end
    end
  end


  always_comb begin
    vertical_sum  = $signed(vertical_product_ff[0]) 
                  + $signed(vertical_product_ff[1]) * 2
                  + $signed(vertical_product_ff[2]);

    horizontal_sum  = $signed(horizontal_product_ff[0]) 
                    + $signed(horizontal_product_ff[1]) * 2  
                    + $signed(horizontal_product_ff[2]); 

    if(horizontal_sum[$high(horizontal_sum)]) begin
      abs_horizontal_sum = horizontal_sum * -1;
    end else begin
      abs_horizontal_sum = horizontal_sum;
    end

    if(vertical_sum[$high(vertical_sum)]) begin
      abs_vertical_sum = vertical_sum * -1;
    end else begin
      abs_vertical_sum = vertical_sum;
    end

    total_avg = ($unsigned(abs_vertical_sum[$high(vertical_sum)-1:0])
              + $unsigned(abs_horizontal_sum[$high(horizontal_sum)-1:0])) / 2; 

    sobel_out = (total_avg > 255) ? 255 : total_avg[DATA_WIDTH-1:0];
  end

endmodule