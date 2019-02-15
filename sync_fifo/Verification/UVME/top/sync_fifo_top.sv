`ifndef SOFT_RESET
	`define SOFT_RESET 1
`endif

module sync_fifo_top;
 
  import uvm_pkg::*;
  import sync_fifo_pkg::*;

  `include "uvm_macros.svh"

  //clock and reset signal declaration
    bit clk;

//creatinng instance of interface, in order to connect DUT and testcase
  sync_fifo_inf intf(clk);
  
  //DUT instance, interface signals are connected to the DUT ports
  TopModule #(
  .SOFT_RESET(`SOFT_RESET)
  ) dut (
    .clk(intf.clk),
   // .reset(intf.reset),
    .hw_rst(intf.hw_rst),
    .sw_rst(intf.sw_rst),
    .top_wr_en(intf.top_wr_en),
    .top_wr_data(intf.top_wr_data),
    .top_rd_en(intf.top_rd_en),
    .top_rd_data(intf.top_rd_data),
    .almost_full_value(intf.almost_full_value),
    .almost_empty_value(intf.almost_empty_value),
    .enq_fifo_full(intf.enq_fifo_full),
    .valid(intf.valid),
    .almost_full(intf.almost_full),
    .almost_empty(intf.almost_empty),
    .ext_mem_full(intf.ext_mem_full),
    .ext_mem_empty(intf.ext_mem_empty),
    .overflow(intf.overflow),
    .underflow(intf.underflow)
);

  //clock generation
  initial begin 
  clk=1'b0;
  forever begin
  #5 clk = ~clk;
  end
  end

  //set interface in config_db 
  initial begin 
    uvm_config_db#(virtual sync_fifo_inf)::set(null,"*","sync_fifo_inf",intf);
  end
  
// Waveform Dumping 
  initial begin
    $shm_open("wave.shm");  // Open SHM database
    $shm_probe("AS");        // Probe all signals (A=All, )
  end

  initial begin 
    run_test("sync_fifo_test");
    uvm_top.set_report_verbosity_level(UVM_HIGH);
  end
endmodule  
