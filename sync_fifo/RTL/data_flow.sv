module DataFlowController #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5,
    parameter MEM_CTRL_ADDR_WIDTH =14,
    parameter EXT_MEM_DEPTH = 1024
)(
    input logic clk,
    input logic reset,

    // Enqueue FIFO Interface (Writing to Memory via ECC-MC)
    output reg en_fifo_rd_en,
    input logic [DATA_WIDTH-1:0] en_fifo_rd_data,
    input logic en_fifo_empty,

    // ECC Memory Controller Interface (New)
    output reg ECC_ctrl_wr_en,  
    output reg [MEM_CTRL_ADDR_WIDTH-1:0] ECC_ctrl_wr_addr_bus,
    output reg [DATA_WIDTH-1:0] ECC_ctrl_write_data_bus,
    //input logic [1:0] wr_resp,

    output logic mem_full,
    output logic mem_empty,

    output reg ECC_ctrl_rd_en,
    output reg [MEM_CTRL_ADDR_WIDTH-1:0] ECC_ctrl_rd_addr_bus,
    input logic [DATA_WIDTH-1:0] ECC_ctrl_data_out,
    //input logic [1:0] rd_resp,

    output logic mem_almost_empty,
    output logic mem_almost_full,

    // Dequeue FIFO Interface (Reading from Memory via ECC-MC)
    input logic top_rd_en,     
    output reg dq_fifo_wr_en, 
    output reg [DATA_WIDTH-1:0] dq_fifo_wr_data,
    //input logic dq_fifo_full,
    input logic dq_fifo_empty,
    output logic dq_fifo_rd_en
);

    logic [ADDR_WIDTH-1:0] data_count;

    assign mem_full = (data_count == EXT_MEM_DEPTH);
    assign mem_empty = (data_count==0);
    assign en_fifo_rd_en = ~en_fifo_empty;
    assign ECC_ctrl_write_data_bus = en_fifo_rd_data;
    assign dq_fifo_rd_en = ~dq_fifo_empty;
    assign dq_fifo_wr_data = ECC_ctrl_data_out;
    assign mem_almost_full = (data_count == (2**ADDR_WIDTH - 2)); 
    assign mem_almost_empty = (data_count <= 2); 

    // **Write Enable Signal to ECC Memory Controller**
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            ECC_ctrl_wr_en <= 1'b0;
        end else begin
            ECC_ctrl_wr_en <= en_fifo_rd_en;  // Enable write when FIFO has data
        end
    end

    // **Write Address Generation**
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            ECC_ctrl_wr_addr_bus <= 0;
            data_count <= 0;
        end else if (ECC_ctrl_wr_en /*&& wr_resp == 2'b00*/) begin  // Ensure successful write
            ECC_ctrl_wr_addr_bus <= ECC_ctrl_wr_addr_bus + 1;
            data_count <= data_count + 1;
        end
    end

    // Read Enable Signal to ECC Memory Controller
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            ECC_ctrl_rd_en <= 1'b0;
        end else begin
            ECC_ctrl_rd_en <= top_rd_en;  // Read when requested
        end
    end

    // Read Address Generation
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            ECC_ctrl_rd_addr_bus <= 0;
            data_count <= 0;
        end else if (ECC_ctrl_rd_en /*&& rd_resp == 2'b00*/) begin  // Ensure successful read
            ECC_ctrl_rd_addr_bus <= ECC_ctrl_rd_addr_bus + 1;
            data_count <= data_count - 1;
        end
    end

    // Write Enable for Dequeue FIFO
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            dq_fifo_wr_en <= 1'b0;
        end else begin
            dq_fifo_wr_en <= ECC_ctrl_rd_en;  // Write to dequeue FIFO when memory read is enabled
        end
    end

endmodule

