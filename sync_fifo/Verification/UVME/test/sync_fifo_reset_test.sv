class sync_fifo_reset_test extends sync_fifo_test;

//factory registration
`uvm_component_utils(sync_fifo_reset_test)

sync_fifo_reset_sequence reset_seq;
 
int scenario;

//function new constructor
function new(string name = "sync_fifo_reset_test", uvm_component parent);
super.new(name, parent);
reset_seq = sync_fifo_reset_sequence::type_id::create("reset_seq");
endfunction

//build_phase
function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction

virtual task run_phase(uvm_phase phase);

`uvm_info(get_full_name(),$sformatf("it test first line"),UVM_MEDIUM)

phase.raise_objection(this);
`uvm_info(get_type_name(),$sformatf("inside the reset test"),UVM_MEDIUM)

begin
reset_seq.scenario = 1;
reset_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("reset scenario 1 is completed"),UVM_MEDIUM)
end

begin
reset_seq.scenario = 2;
reset_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("reset scenario 2 is completed"),UVM_MEDIUM)
end
/*
begin
reset_seq.scenario = 3;
reset_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("reset scenario 3 is completed"),UVM_MEDIUM)
end 
*/
phase.drop_objection(this);
phase.phase_done.set_drain_time(this,100);

endtask
 
endclass
