class sync_fifo_driver extends uvm_driver #(sync_fifo_seq_item);
  // factory registration
  `uvm_component_utils(sync_fifo_driver)
  
  // call seq_item
    sync_fifo_seq_item seq_item;
    virtual sync_fifo_inf intf;

  // function new constructor
  function new(string name = "sync_fifo_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction 

  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    seq_item=sync_fifo_seq_item::type_id::create("seq_item");
    if(!uvm_config_db#(virtual sync_fifo_inf)::get(this,"*","sync_fifo_inf",intf))
   	 `uvm_fatal(get_full_name(),"unable to get interface in read driver")
  endfunction

  // run phase
  task run_phase(uvm_phase phase);
  super.run_phase(phase);
	`uvm_info (get_type_name(),"Insider driver run phase", UVM_LOW)

    
 // Initialize signals
    intf.driver_cb.hw_rst <= 1'b0;
    intf.driver_cb.sw_rst <= 1'b0;
    intf.driver_cb.top_wr_en <= 1'b0;
    intf.driver_cb.top_rd_en <= 1'b0;
    intf.driver_cb.top_wr_data <= 32'h0;
    intf.driver_cb.almost_full_value <= 10;
    intf.driver_cb.almost_empty_value <= 4;

forever begin
      seq_item_port.get_next_item(seq_item);
      `uvm_info("Driver_class", "Got new sequence item", UVM_LOW);
      
      // Always drive the signals
      drive_data(seq_item);
      
      seq_item_port.item_done();
    end
  endtask : run_phase
  
  // Drive_data task - drive signals to the interface
  task drive_data(sync_fifo_seq_item seq_item);
    @(intf.driver_cb);
    intf.driver_cb.hw_rst <= seq_item.hw_rst;
    intf.driver_cb.sw_rst <= seq_item.sw_rst;
    intf.driver_cb.top_wr_en <= seq_item.top_wr_en;
    intf.driver_cb.top_rd_en <= seq_item.top_rd_en;
    intf.driver_cb.top_wr_data <= seq_item.top_wr_data;
    intf.driver_cb.almost_full_value <= seq_item.almost_full_value;
    intf.driver_cb.almost_empty_value <= seq_item.almost_empty_value;
    
    // Debug information
    if (seq_item.hw_rst || seq_item.sw_rst)
      `uvm_info("Driver_class", "Driving reset signals", UVM_LOW)
    else if (seq_item.top_wr_en)
      `uvm_info("Driver_class", $sformatf("Driving write: data = 0x%0h", seq_item.top_wr_data), UVM_LOW)
    else if (seq_item.top_rd_en)
      `uvm_info("Driver_class", "Driving read operation", UVM_LOW)
  endtask : drive_data
endclass : sync_fifo_driver

