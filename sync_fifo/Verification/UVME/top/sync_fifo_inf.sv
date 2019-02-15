interface sync_fifo_inf(input bit clk);
  // Input signalsof design
  // bit clk;
  // logic reset;
   logic hw_rst;
   logic sw_rst;
   logic top_wr_en;
   logic [31:0] top_wr_data;
   logic top_rd_en;

  // Output signals of design
   logic [31:0] top_rd_data;

  // input flags of design
   logic [31:0] almost_full_value;
   logic [31:0] almost_empty_value;

  // output flags of design
  logic enq_fifo_full;
  logic valid;
  logic almost_full;
  logic almost_empty;
  logic ext_mem_full;
  logic ext_mem_empty;
  logic overflow;
  logic underflow;


 clocking driver_cb @ (negedge clk);

 // default input #0 output #0;

  //output reset;
  output hw_rst;
  output sw_rst;
  output top_wr_en;
  output top_rd_en;
  output top_wr_data;
  input top_rd_data;
  output almost_full_value;
  output almost_empty_value;
 // output enq_fifo_full;
 // output valid;
//  output almost_full;
//  output almost_empty;
//  output ext_mem_full;
//  output ext_mem_empty;

  endclocking

  clocking monitor_cb @ (posedge clk);

  default input #0 output #1;

  input hw_rst, sw_rst, top_wr_en, top_wr_data, almost_full_value, almost_empty_value, top_rd_en, top_rd_data, enq_fifo_full, valid, almost_full, almost_empty, ext_mem_full, ext_mem_empty, overflow, underflow;
  
  endclocking

modport driver(clocking driver_cb);
modport monitor(clocking monitor_cb);

endinterface
