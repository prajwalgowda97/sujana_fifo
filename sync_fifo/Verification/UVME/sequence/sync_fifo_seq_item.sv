class sync_fifo_seq_item extends uvm_sequence_item;  
 
//  rand bit reset;
  rand bit hw_rst;
  rand bit sw_rst;
  rand bit top_wr_en;
  rand bit [31:0] top_wr_data;
  rand bit top_rd_en;
       bit [31:0] top_rd_data;
  rand bit [9:0] almost_full_value;
  rand bit [9:0] almost_empty_value;
       bit enq_fifo_full;
       bit valid;
       bit almost_full;
       bit almost_empty;
       bit ext_mem_full;
       bit ext_mem_empty;
       bit overflow;
       bit underflow;
  
   `uvm_object_utils_begin(sync_fifo_seq_item)
   
    
//    `uvm_field_int(reset,   UVM_ALL_ON)
    `uvm_field_int(hw_rst,   UVM_ALL_ON)
    `uvm_field_int(sw_rst,   UVM_ALL_ON)   
    `uvm_field_int(top_wr_en,   UVM_ALL_ON)
    `uvm_field_int(top_wr_data, UVM_ALL_ON)
    `uvm_field_int(top_rd_en,   UVM_ALL_ON)
    `uvm_field_int(top_rd_data, UVM_ALL_ON)
    `uvm_field_int(enq_fifo_full, UVM_ALL_ON)
    `uvm_field_int(valid, UVM_ALL_ON)
    `uvm_field_int(almost_full, UVM_ALL_ON)
    `uvm_field_int(almost_empty, UVM_ALL_ON)
    `uvm_field_int(ext_mem_full, UVM_ALL_ON)
    `uvm_field_int(ext_mem_empty, UVM_ALL_ON)
    `uvm_field_int(overflow, UVM_ALL_ON)
    `uvm_field_int(underflow, UVM_ALL_ON)
    
  `uvm_object_utils_end 
  
  //Constructor
  function new(string name = "sync_fifo_seq_item");
    super.new(name);
  endfunction

 // constraint fifo_c{!(top_wr_en&&top_rd_en);};

endclass
