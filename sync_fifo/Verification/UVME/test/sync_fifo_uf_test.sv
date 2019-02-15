class sync_fifo_uf_test extends sync_fifo_test;

//factory registration
`uvm_component_utils(sync_fifo_uf_test)

sync_fifo_uf_sequence uf_seq;
 
int scenario;

//function new constructor
function new(string name = "sync_fifo_uf_test", uvm_component parent);
super.new(name, parent);
uf_seq = sync_fifo_uf_sequence::type_id::create("uf_seq");
endfunction

//build_phase
function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction

//task
virtual task run_phase(uvm_phase phase);

`uvm_info(get_full_name(),$sformatf("it test first line"),UVM_MEDIUM)

phase.raise_objection(this);
`uvm_info(get_type_name(),$sformatf("inside the under_flow test"),UVM_MEDIUM)

begin
uf_seq.scenario = 1;
uf_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("under_flow scenario 1 is completed"),UVM_MEDIUM)
end 


begin
uf_seq.scenario = 2;
uf_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("under_flow scenario 2 is completed"),UVM_MEDIUM)
end

begin
uf_seq.scenario = 3;
uf_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("under_flow scenario 3 is completed"),UVM_MEDIUM)
end 

begin
uf_seq.scenario = 4;
uf_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("under_flow scenario 4 is completed"),UVM_MEDIUM)
end

begin
uf_seq.scenario = 5;
uf_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("under_flow scenario 5 is completed"),UVM_MEDIUM)
end

phase.drop_objection(this);
phase.phase_done.set_drain_time(this,100);

endtask
 
endclass


