class sync_fifo_exm_empty_test extends sync_fifo_test;

//factory registration
`uvm_component_utils(sync_fifo_exm_empty_test)

sync_fifo_exm_empty_sequence exm_empty_seq;
 
int scenario;

//function new constructor
function new(string name = "sync_fifo_exm_empty_test", uvm_component parent);
super.new(name, parent);
exm_empty_seq = sync_fifo_exm_empty_sequence::type_id::create("exm_empty_seq");
endfunction

//build_phase
function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction

//task
virtual task run_phase(uvm_phase phase);

`uvm_info(get_full_name(),$sformatf("it test first line"),UVM_MEDIUM)

phase.raise_objection(this);
`uvm_info(get_type_name(),$sformatf("inside the exm_empty test"),UVM_MEDIUM)

begin
exm_empty_seq.scenario = 1;
exm_empty_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf(" exm_empty scenario 1 is completed"),UVM_MEDIUM)
end 


begin
exm_empty_seq.scenario = 2;
exm_empty_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("exm_empty scenario 2 is completed"),UVM_MEDIUM)
end

phase.drop_objection(this);
phase.phase_done.set_drain_time(this,100);

endtask
 
endclass



