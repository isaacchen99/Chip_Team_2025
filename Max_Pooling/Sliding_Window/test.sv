module test #(
    parameter DATA_WIDTH = 8,
    parameter KERNEL_DIM = 3,
    parameter ROW_SIZE = 5
)(
    input  logic clk, rst,
    input  logic [DATA_WIDTH-1:0] inputPixel,
    output logic [DATA_WIDTH-1:0] window[KERNEL_DIM-1:0][KERNEL_DIM-1:0],
    output logic valid  // High when window has valid data
);

    // Constants
    localparam BUFFER_SIZE = ROW_SIZE * (KERNEL_DIM - 1) + KERNEL_DIM;      // Allocate space
    localparam VALID_START = BUFFER_SIZE -1;
    logic [DATA_WIDTH-1:0] buffer [0:BUFFER_SIZE-1];

    // Pointers & Counters
    logic [$clog2(ROW_SIZE*ROW_SIZE)-1:0] pixel_count;           // Total pixels streamed in

    // Main logic
    always_ff @(posedge clk) begin
        if (rst) begin
            pixel_count <= 0;
            valid <= 0;

            // Clear window output
            for (int i = 0; i < KERNEL_DIM; i++)
                for (int j = 0; j < KERNEL_DIM; j++)
                    window[i][j] <= 0;

            // Clear buffer
            for (int i = 0; i < BUFFER_SIZE; i++)
                buffer[i] <= 0;
        end

        else begin
             // Shift out oldest data, FIFO
            for (int i = BUFFER_SIZE - 1; i > 0; i--) begin
                buffer[i] <= buffer[i-1];
            end
            // Shift new data into buffer
            buffer[0] <= inputPixel;
            
            // Shift existing window left (col 1 -> col 0, col 2 -> col 1)
            for (int row = 0; row < KERNEL_DIM; row++) begin
                for (int col = 0; col < KERNEL_DIM - 1; col++) begin
                    window[row][col] <= window[row][col+1];
                end
            end

            // Insert rightmost column
            for (int r = 0; r < KERNEL_DIM; r++) begin
                window[r][KERNEL_DIM-1] <= buffer[(KERNEL_DIM - 1 - r) * ROW_SIZE];
            end

            // Increment count for VALID
            pixel_count <= pixel_count + 1;
            valid <= (pixel_count > VALID_START);
        end
    end
endmodule
