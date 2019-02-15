class sync_fifo_read_test extends sync_fifo_test;

//factory registration
`uvm_component_utils(sync_fifo_read_test)

sync_fifo_read_sequence read_seq;
 
int scenario;

//function new constructor
function new(string name = "sync_fifo_read_test", uvm_component parent);
super.new(name, parent);
read_seq = sync_fifo_read_sequence::type_id::create("read_seq");
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
`uvm_info(get_type_name(),$sformatf("inside the read test"),UVM_MEDIUM)

begin
read_seq.scenario = 1;
read_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("read scenario 1 is completed"),UVM_MEDIUM)
end

begin
read_seq.scenario = 2;
read_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("read scenario 2 is completed"),UVM_MEDIUM)
end

begin
read_seq.scenario = 3;
read_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("read scenario 3 is completed"),UVM_MEDIUM)
end 

begin
read_seq.scenario = 4;
read_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("read scenario 4 is completed"),UVM_MEDIUM)
end

begin
read_seq.scenario = 5;
read_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("read scenario 5 is completed"),UVM_MEDIUM)
end


phase.drop_objection(this);
phase.phase_done.set_drain_time(this,100);

endtask
 
endclass
