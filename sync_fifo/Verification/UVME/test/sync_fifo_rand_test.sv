class sync_fifo_rand_test extends sync_fifo_test;

//factory registration
`uvm_component_utils(sync_fifo_rand_test)

sync_fifo_rand_sequence rand_seq;
 
int scenario;

//function new constructor
function new(string name = "sync_fifo_rand_test", uvm_component parent);
super.new(name, parent);
rand_seq = sync_fifo_rand_sequence::type_id::create("rand_seq");
endfunction

//build_phase
function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction

//task
virtual task run_phase(uvm_phase phase);

`uvm_info(get_full_name(),$sformatf("it test first line"),UVM_MEDIUM)

phase.raise_objection(this);
`uvm_info(get_type_name(),$sformatf("inside the randomize test"),UVM_MEDIUM)

begin
rand_seq.scenario = 1;
rand_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("randomize scenario 1 is completed"),UVM_MEDIUM)
end 

begin
rand_seq.scenario = 2;
rand_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("randomize scenario 2 is completed"),UVM_MEDIUM)
end

begin
rand_seq.scenario = 3;
rand_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("randimize scenario 3 is completed"),UVM_MEDIUM)
end 

begin
rand_seq.scenario = 4;
rand_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("randomize scenario 4 is completed"),UVM_MEDIUM)
end

phase.drop_objection(this);
phase.phase_done.set_drain_time(this,100);

endtask
 
endclass
