module DualPortRAM #(
    parameter DATA_WIDTH = 39,   // Data width (bits per memory location)
    parameter ADDR_WIDTH = 14    // Address width (2^ADDR_WIDTH locations)
) (
    input logic clk,                  // Common Clock for both Read and Write
    input logic reset,                // Reset Signal

    // Write Port
    input wire we,                   // Write Enable
    input logic[ADDR_WIDTH-1:0] wr_ptr, // Write Address
    input logic [DATA_WIDTH-1:0] din, // Data Input

    // Read Port
    input wire re,                   // Read Enable
    input wire [ADDR_WIDTH-1:0] rd_ptr, // Read Address
    output reg [DATA_WIDTH-1:0] dout, // Data Output

    // Status Flags
    input reg full,                 // Memory full flag
    input reg empty                 // Memory empty flag
);

    // Memory Array
    reg [DATA_WIDTH-1:0] mem [0:(1 << ADDR_WIDTH) - 1];
    // Write Operation
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            //we <= 1'b0; 
        end else if (we && !full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= din; // Write data to memory
        end
    end

    // Read Operation
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            dout <= 32'b0;   // Clear output data
        end else if (re && !empty) begin
            dout <= mem[rd_ptr[ADDR_WIDTH-1:0]]; // Read data from memory
        end
    end

endmodule

