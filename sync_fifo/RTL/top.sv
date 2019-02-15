module top_sync_fifo_with_ecc #(

	parameter FIFO_DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 10,
	parameter FIFO_ADDR_WIDTH = 5,
	parameter FIFO_DEPTH = 32,
	parameter EXT_MEM_DEPTH = 1024,
	parameter MEM_CTRL_ADDR_WIDTH = 14,
	parameter GLOBAL_MEM_INIT = 0,
	parameter PARITY_BITS = 6,
	parameter MEM_DATA_WIDTH = 39,
	parameter REG_ADDR_WIDTH = 10,
	parameter MEM_CTRL_DEPTH = 16384
)(
	input clk,
	input reset,
	
	//Top module signals
	input logic top_wr_en,
	input logic [FIFO_DATA_WIDTH-1:0] top_wr_data,
	
	input logic top_rd_en,
	output logic [FIFO_DATA_WIDTH-1:0] top_rd_data,

	//Status flag
	output logic ext_mem_full,
	output logic ext_mem_empty,
	input logic [ADDR_WIDTH-1:0]almost_full_value,
	input logic [ADDR_WIDTH-1:0]almost_empty_value,
	output logic almost_full,
	output logic almost_empty,
	output logic valid,
	output logic ECC_interrupt_output,

	input logic i_psel,
	input logic i_penable,
	input logic i_pwrite,
	input logic [FIFO_DATA_WIDTH-1:0] i_pwdata,
	input logic [REG_ADDR_WIDTH-1:0] i_paddr,
	input logic [3:0] i_pstrb,
	input logic top_i_ECC_STAUS_REG_ECC_STATUS_clear,

	output logic [FIFO_DATA_WIDTH-1:0] o_ECC_STAUS_REG_ECC_STATUS
);

	//Enqueue fifo signals
	logic enq_fifo_wr_en;
	logic [FIFO_DATA_WIDTH-1:0]enq_fifo_wr_data;
	logic en_fifo_rd_en;
	logic [FIFO_DATA_WIDTH-1:0]enq_fifo_rd_data;
	logic enq_fifo_empty;

	//Dequeue fifo signals
	logic deq_fifo_wr_en;
	logic [FIFO_DATA_WIDTH-1:0] deq_fifo_wr_data;
	logic deq_rd_en;
	logic [FIFO_DATA_WIDTH-1:0] deq_fifo_rd_data;
	logic deq_fifo_empty;

	//Memory control with ECC signals
	logic ctrl_wr_en;
	logic [MEM_CTRL_ADDR_WIDTH-1:0] ctrl_wr_addr_bus;
	logic [FIFO_DATA_WIDTH-1:0] ctrl_wr_data_bus;
	logic ctrl_rd_en;
	logic [MEM_CTRL_ADDR_WIDTH-1:0] ctrl_rd_addr_bus;
	logic [FIFO_DATA_WIDTH-1:0] ctrl_data_out;

	logic interrupt_status;

	logic i_ECC_STAUS_REG_ECC_STATUS_clear_internal;

	//BRAM signals (External Memory)
	logic ext_mem_we;
	logic [MEM_CTRL_ADDR_WIDTH-1:0] ext_mem_wr_addr;
	logic [MEM_DATA_WIDTH-1:0] ext_mem_wr_data;
	logic ext_mem_re;
	logic [MEM_CTRL_ADDR_WIDTH-1:0] ext_mem_rd_addr;
	logic [MEM_DATA_WIDTH-1:0] ext_mem_rd_data;

	logic mem_full_status;
	logic mem_empty_status;
	
	assign ECC_interrupt_output = interrupt_status;
	assign ext_mem_full = mem_full_status;
	assign ext_mem_empty = mem_empty_status;
	assign i_ECC_STAUS_REG_ECC_STATUS_clear_internal = top_i_ECC_STAUS_REG_ECC_STATUS_clear;


	//Generating valid signal
	always @(posedge clk or negedge reset)
	begin
		if(!reset)
		begin
			valid <= 1'b0;
		end
		else
		begin
			valid <= ~deq_fifo_empty;
		end
	end




	//Enqueue fifo instantiation
	fifo#(
		.DATA_WIDTH(FIFO_DATA_WIDTH),
		.ADDR_WIDTH(FIFO_ADDR_WIDTH),
		.DEPTH(FIFO_DEPTH)
		)
		enqueue_fifo(
			.clk(clk),
			.hw_rst(reset),
			.sw_rst(1'b0),
			.wr_en(top_wr_en),
			.wr_data(top_wr_data),
			.rd_en(enq_fifo_rd_en),
			.rd_data_out(enq_fifo_rd_data),
			.fifo_empty(enq_fifo_empty),
			.fifo_full(),
			.almost_full(),
			.almost_empty(),
			.underflow(),
			.overflow(),
			.mem_rst(),
			.wr_lvl(),
			.rd_lvl()
		);


	//Dequeue fifo instantiation
	fifo#(
		.DATA_WIDTH(FIFO_DATA_WIDTH),
		.ADDR_WIDTH(FIFO_ADDR_WIDTH),
		.DEPTH(FIFO_DEPTH)
		)
		dequeue_fifo(
			.clk(clk),
			.hw_rst(reset),
			.sw_rst(1'b0),
			.wr_en(deq_fifo_wr_en),
			.wr_data(deq_fifo_wr_data),
			.rd_en(deq_fifo_rd_en),
			.rd_data_out(top_rd_data),
			.fifo_empty(deq_fifo_empty),
			.fifo_full(),
			.almost_full(),
			.almost_empty(),
			.underflow(),
			.overflow(),
			.mem_rst(),
			.wr_lvl(),
			.rd_lvl()
		);

	//Data Flow Controller instantiation
	DataFlowController #(
		.DATA_WIDTH(FIFO_DATA_WIDTH),
		.ADDR_WIDTH(FIFO_ADDR_WIDTH),
		.MEM_CTRL_ADDR_WIDTH(MEM_CTRL_ADDR_WIDTH),
		.EXT_MEM_DEPTH(EXT_MEM_DEPTH)
		)
		data_flow_control(
			.clk(clk),
			.reset(reset),
			
			//Enqueue fifo signals
			.en_fifo_rd_en(enq_fifo_rd_en),
			.en_fifo_rd_data(enq_fifo_rd_data),
			.en_fifo_empty(enq_fifo_empty),

			.mem_full(mem_full_status),
			.mem_empty(mem_empty_status),
			.mem_almost_full(almost_full),
			.mem_almost_empty(almost_empty),

			//Memory controller with ECC signals
			.ECC_ctrl_wr_en(ctrl_wr_en),
			.ECC_ctrl_wr_addr_bus(ctrl_wr_addr_bus),
			.ECC_ctrl_write_data_bus(ctrl_wr_data_bus),
			//.wr_resp(),
		
			.ECC_ctrl_rd_en(ctrl_rd_en),
			.ECC_ctrl_rd_addr_bus(ctrl_rd_addr_bus),
			.ECC_ctrl_data_out(ctrl_data_out),
			//.rd_resp(),

			//Dequeue fifo signals
			.top_rd_en(top_rd_en),
			.dq_fifo_wr_en(deq_fifo_wr_en),
			.dq_fifo_wr_data(deq_fifo_wr_data),
			.dq_fifo_rd_en(deq_fifo_rd_en),
			.dq_fifo_empty(deq_fifo_empty)
		);

	//Memory controller with ECC instantiation
	mem_ctrl #(
		.GLOBAL_MEM_INIT(GLOBAL_MEM_INIT),
                .ADDR_WIDTH(MEM_CTRL_ADDR_WIDTH),
                .DEPTH(MEM_CTRL_DEPTH),
                .DATA_WIDTH(FIFO_DATA_WIDTH),
                .PARITY_BITS(PARITY_BITS),
                .MEMORY_DATA_WIDTH(MEM_DATA_WIDTH),
                .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
		)
		memory_controll_ECC(
			.MEM_ctrl_clk(clk),
			.MEM_ctrl_rstn(reset),
			.MEM_ctrl_sw_rst(1'b0),
			.MEM_ctrl_mem_init(),
			
			//Memory COntrol Signals
			.MEM_ctrl_wr_en(ctrl_wr_en),
			.MEM_ctrl_wr_addr_bus(ctrl_wr_addr_bus),
			.MEM_ctrl_wr_strobe(4'd15),
			.MEM_ctrl_write_data_bus(ctrl_wr_data_bus),
			.wr_resp(),
			.MEM_ctrl_rd_en(ctrl_rd_en),
			.MEM_ctrl_rd_addr_bus(ctrl_rd_addr_bus),
			.MEM_ctrl_data_out(ctrl_data_out),
			.rd_resp(),
			.ECC_interrupt(interrupt_status),

			//Register Signals
			.i_psel(i_psel),
			.i_penable(i_penable),
			.i_pwrite(i_pwrite),
			.i_pwdata(i_pwdata),
			.i_paddr(i_paddr),
			.i_pstrb(i_pstrb),
			.i_ECC_STAUS_REG_ECC_STATUS_clear(i_ECC_STAUS_REG_ECC_STATUS_clear_internal),
			.o_ECC_STAUS_REG_ECC_STATUS(o_ECC_STAUS_REG_ECC_STATUS),
			.MEM_init_ACK(),

			//BRAM signal connected with the external memory
			.BRAM_wr_en(ext_mem_we),
			.BRAM_wr_addr(ext_mem_wr_addr),
			.BRAM_wr_data(ext_mem_wr_data),
			.BRAM_rd_en(ext_mem_re),
			.BRAM_rd_addr(ext_mem_rd_addr),
			.BRAM_rd_data(ext_mem_rd_data),
			.BRAM_en()
			);


	//External memory instantiation
	DualPortRAM #(
		.DATA_WIDTH(MEM_DATA_WIDTH),
		.ADDR_WIDTH(MEM_CTRL_ADDR_WIDTH)
		)
		external_memory(
			.clk(clk),
			.reset(reset),
			.we(ext_mem_we),
			.wr_ptr(ext_mem_wr_addr),
			.din(ext_mem_wr_data),
			.re(ext_mem_re),
			.rd_ptr(ext_mem_rd_addr),
			.dout(ext_mem_rd_data),
			.full(mem_full_status),
			.empty(mem_empty_status)
		);
endmodule
	
