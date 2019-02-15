class sync_fifo_env extends uvm_env;
 
   `uvm_component_utils(sync_fifo_env)

  // agent and scoreboard instance
  sync_fifo_agent sync_fifo_agnt;
  sync_fifo_scoreboard sync_fifo_scb;
  
  // constructor
  function new(string name = "sync_fifo_env", uvm_component parent);
    super.new(name, parent);
     `uvm_info("env_class", "Inside constructor!", UVM_HIGH)
  endfunction 

  // build_phase - crate the components
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sync_fifo_agnt = sync_fifo_agent::type_id::create("sync_fifo_agnt", this);
   sync_fifo_scb  = sync_fifo_scoreboard::type_id::create("sync_fifo_scb", this);
  `uvm_info("env_class", "Inside Build Phase!", UVM_HIGH)
  endfunction

  // connect_phase - connecting monitor and scoreboard port
  function void connect_phase(uvm_phase phase);
  // uvm_test_top.print_topology();
   sync_fifo_agnt.monitor.monitor_port.connect(sync_fifo_scb.scoreboard_port);
  `uvm_info("env_class", "Inside connect Phase!", UVM_HIGH)
  endfunction

endclass 
