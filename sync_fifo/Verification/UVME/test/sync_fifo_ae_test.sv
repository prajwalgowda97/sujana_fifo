class sync_fifo_ae_test extends sync_fifo_test;

//factory registration
`uvm_component_utils(sync_fifo_ae_test)

sync_fifo_ae_sequence ae_seq;
 
int scenario;

//function new constructor
function new(string name = "sync_fifo_ae_test", uvm_component parent);
super.new(name, parent);
ae_seq = sync_fifo_ae_sequence::type_id::create("ae_seq");
endfunction

//build_phase
function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction
/*
//run_phase
function run_phase(uvm_phase phase);
super.run_phase(phase);
endfunction
*/
//task
virtual task run_phase(uvm_phase phase);

`uvm_info(get_full_name(),$sformatf("it test first line"),UVM_MEDIUM)

phase.raise_objection(this);
`uvm_info(get_type_name(),$sformatf("inside the ae test"),UVM_MEDIUM)

begin
ae_seq.scenario = 1;
ae_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("ae scenario 1 is completed"),UVM_MEDIUM)
end

begin
ae_seq.scenario = 2;
ae_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("ae scenario 2 is completed"),UVM_MEDIUM)
end

begin
ae_seq.scenario = 3;
ae_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("ae scenario 3 is completed"),UVM_MEDIUM)
end 


phase.drop_objection(this);
phase.phase_done.set_drain_time(this,100);

endtask
 
endclass
