class sync_fifo_agent extends uvm_agent;
  // factory registration
  `uvm_component_utils(sync_fifo_agent)

  // declaring components
  sync_fifo_driver    driver;
  sync_fifo_sequencer sequencer;
  sync_fifo_monitor   monitor;

  // function new constructor
  function new (string name = "sync_fifo_agent", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info("agent_class", "Inside constructor!", UVM_HIGH)
  endfunction 

  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

   if(get_is_active() == UVM_ACTIVE) begin
      driver = sync_fifo_driver::type_id::create("driver", this);
      sequencer = sync_fifo_sequencer::type_id::create("sequencer", this);
    end

    monitor = sync_fifo_monitor::type_id::create("monitor", this);
    `uvm_info("agent_class", "Inside build_phase!", UVM_HIGH)
  endfunction 

  // connect_phase
  function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);
    if(get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
      `uvm_info("agent_class", "Inside connect_phase!", UVM_HIGH)
    end
  endfunction 

endclass
