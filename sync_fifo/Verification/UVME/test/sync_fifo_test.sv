class sync_fifo_test extends uvm_test;
  // factory registration
  `uvm_component_utils(sync_fifo_test)

 // call environment, sequence
  sync_fifo_env env;
  sync_fifo_base_sequence base_seq;

 // function new constructor
  function new(string name = "sync_fifo_test",uvm_component parent);
    super.new(name,parent);
    `uvm_info(get_type_name(), "Inside Constuctor!", UVM_HIGH)     
  endfunction 

 // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

 // create handle for env, seq
    env = sync_fifo_env::type_id::create("env", this);
    base_seq = sync_fifo_base_sequence::type_id::create("base_seq");
    `uvm_info(get_type_name(), "Inside build_phase!", UVM_HIGH)     
   endfunction

  //end of elaboration phase
 	function void end_of_elaboration_phase(uvm_phase phase);
  	uvm_top.print_topology();
	endfunction

 // run_phase
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    phase.drop_objection(this);
  endtask

endclass

