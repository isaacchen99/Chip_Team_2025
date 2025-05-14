module manage_fifo #(
  DATA_WIDTH = 32,
  NUM_INPUTS = 1,
  NUM_OUTPUTS = 1  
)(
  input logic clk,
  input logic rst,
  input logic [NUM_INPUTS-1:0] inputs_empty,
  input logic [NUM_OUTPUTS-1:0] outputs_full,
  input logic [DATA_WIDTH-1:0] din,
  output logic read_fifo,
  output logic write_fifo,
  output logic [DATA_WIDTH-1:0] dout
);
  
  typedef enum logic[1:0] {
    OUT_FULL    = 2'b01,
    OUT_EMPTY   = 2'b10
  } out_ff_state_t;


  logic can_read;
  logic can_write;

  out_ff_state_t out_ff_state;
  out_ff_state_t out_ff_state_next;

  logic [DATA_WIDTH-1:0] dout_next;

  always_comb begin
    can_read = ~(|inputs_empty);
    can_write = ~(|outputs_full);

    out_ff_state_next = out_ff_state;
    dout_next = dout;

    read_fifo = 0;
    write_fifo = 0;

    case(out_ff_state)
      OUT_EMPTY: begin
        if(can_read) begin
          read_fifo = 1;
          out_ff_state_next = OUT_FULL;
          dout_next = din;
        end
      end

      OUT_FULL: begin
        if(can_write) begin
          write_fifo = 1;
          if (can_read) begin
            read_fifo = 1;
            dout_next = din;
          end else begin
            out_ff_state_next = OUT_EMPTY;
          end
        end
      end
    endcase
  end

  always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
      out_ff_state <= OUT_EMPTY;
      dout <= 0;
    end else begin
      out_ff_state <= out_ff_state_next;
      dout <= dout_next;
    end
  end


endmodule


