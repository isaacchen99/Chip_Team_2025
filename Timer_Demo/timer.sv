module timer #(
  DATA_WIDTH = 8
) (
  input logic clk,
  input logic rst,
  input logic start,
  input logic stop,
  input logic [DATA_WIDTH-1:0] data_in,
  output logic done
);

  typedef enum logic[3:0] {  
    IDLE  = 4'b0001,
    COUNT = 4'b0010,
    PAUSE = 4'b0100,
    DONE = 4'b1000
  } timer_state_t;

  timer_state_t timer_state;
  timer_state_t timer_state_next;

  logic [DATA_WIDTH-1:0] counter;
  logic [DATA_WIDTH-1:0] counter_next;

  logic [DATA_WIDTH-1:0] counter_max;
  logic [DATA_WIDTH-1:0] counter_max_next;


  always_ff @(posedge clk) begin
    if(rst) begin
      counter <= 0;
      timer_state <= IDLE;
      counter_max = 0;
    end else begin
      counter     <= counter_next;
      timer_state <= timer_state_next;
      counter_max <= counter_max_next;
    end
  end


  always_comb begin
    counter_next = counter;
    timer_state_next = timer_state;
    counter_max_next = counter_max;
    case(timer_state)
      IDLE: begin
        if(start) begin
          timer_state_next = COUNT;
          counter_max_next = data_in;
        end
      end
      
      COUNT: begin
        counter_next = counter + 1;
        if(counter_next == counter_max) begin
          timer_state_next = DONE;
        end else if(stop) begin
          timer_state_next = PAUSE;
        end
        
      end

      PAUSE: begin
        if(start) begin
          timer_state_next = COUNT;
        end
        
      end
      DONE: begin
        if(stop) begin
          timer_state_next = IDLE;
        end
      end
    endcase;
  end
  
  
  assign done = (timer_state == DONE);
endmodule