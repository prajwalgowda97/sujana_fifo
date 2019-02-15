class sync_fifo_monitor extends uvm_monitor;
  // factory registration
  `uvm_component_utils(sync_fifo_monitor)

   // Creating interface and sequence item handle
   sync_fifo_seq_item seq_item;
    virtual sync_fifo_inf intf; 
  
  // port declaration
  uvm_analysis_port #(sync_fifo_seq_item) monitor_port;

  // function new constructor
  function new (string name = "sync_fifo_monitor", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info("Monitor_class", "Inside Constructor!", UVM_HIGH)
  endfunction 

  // build_phase 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("Monitor_class", "Inside Build Phase!", UVM_HIGH)
        if (!uvm_config_db#(virtual sync_fifo_inf)::get(this, "*", "sync_fifo_inf", intf)) begin
            `uvm_fatal(get_full_name(), "Error while getting read interface from top monitor")
	    end
    monitor_port=new("monitor_port", this);
  endfunction

  // Run phase 
  task run_phase(uvm_phase phase);
        super.run_phase(phase);
      	seq_item = sync_fifo_seq_item::type_id::create("seq_item",this);
	
	forever begin
        `uvm_info(get_full_name,$sformatf("Monitor start"),UVM_MEDIUM)
      
        `uvm_info(get_full_name,$sformatf("Inside Monitor run phase"),UVM_MEDIUM)
              
            @(intf.monitor_cb);
	//output signals
	seq_item.hw_rst = intf.monitor_cb.hw_rst;
	seq_item.sw_rst = intf.monitor_cb.sw_rst;
	seq_item.top_wr_en = intf.monitor_cb.top_wr_en;
	//#15ns;
	seq_item.top_wr_data = intf.monitor_cb.top_wr_data;
	seq_item.top_rd_en = intf.monitor_cb.top_rd_en;
	seq_item.almost_full_value = intf.monitor_cb.almost_full_value;
	seq_item.almost_empty_value = intf.monitor_cb.almost_empty_value;
	seq_item.top_rd_data = intf.monitor_cb.top_rd_data;
	seq_item.enq_fifo_full = intf.monitor_cb.enq_fifo_full;
	seq_item.valid = intf.monitor_cb.valid;
	seq_item.almost_full = intf.monitor_cb.almost_full;
	seq_item.almost_empty = intf.monitor_cb.almost_empty;
	seq_item.ext_mem_full = intf.monitor_cb.ext_mem_full;
	seq_item.ext_mem_empty = intf.monitor_cb.ext_mem_empty;
	seq_item.overflow = intf.monitor_cb.overflow;
	seq_item.underflow = intf.monitor_cb.underflow;

`uvm_info("SYNC_FIFO_MONITOR", $sformatf(
                    "Time: %0t | hw_rst: %0b, sw_rst: %0b, top_wr_en: %0b, top_wr_data: %0h, top_rd_en: %0b, almost_full_value: %0h, almost_empty_value: %0h, top_rd_data: %0h, enq_fifo_full: %0b, valid: %0b, almost_full: %0b, almost_empty: %0b, ext_mem_full: %0b, ext_mem_empty: %0b, overflow: %0b, underflow: %0b",
                    $realtime, seq_item.hw_rst, seq_item.sw_rst, seq_item.top_wr_en, seq_item.top_wr_data, seq_item.top_rd_en,seq_item.almost_full_value, seq_item.almost_empty_value, seq_item.top_rd_data, seq_item.enq_fifo_full, seq_item.valid, seq_item.almost_full, seq_item.almost_empty, seq_item.ext_mem_full, seq_item.ext_mem_empty, seq_item.overflow, seq_item.underflow), UVM_LOW);
          
             `uvm_info(get_full_name,$sformatf("End of Monitor"),UVM_MEDIUM)
             monitor_port.write(seq_item);

		end 

  endtask

endclass 
