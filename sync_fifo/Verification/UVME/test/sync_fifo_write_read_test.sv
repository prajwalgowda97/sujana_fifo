class sync_fifo_write_read_test extends sync_fifo_test;

//factory registration
`uvm_component_utils(sync_fifo_write_read_test)

sync_fifo_write_read_sequence wr_seq;
 
int scenario;

//function new constructor
function new(string name = "sync_fifo_write_read_test", uvm_component parent);
super.new(name, parent);
wr_seq = sync_fifo_write_read_sequence::type_id::create("wr_seq");
endfunction

//build_phase
function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction

//task
virtual task run_phase(uvm_phase phase);

`uvm_info(get_full_name(),$sformatf("it test first line"),UVM_MEDIUM)

phase.raise_objection(this);
`uvm_info(get_type_name(),$sformatf("inside the write_read test"),UVM_MEDIUM)

begin
wr_seq.scenario = 1;
wr_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("write_read scenario 1 is completed"),UVM_MEDIUM)
end 


begin
wr_seq.scenario = 2;
wr_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("write_read scenario 2 is completed"),UVM_MEDIUM)
end

begin
wr_seq.scenario = 3;
wr_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("write_read scenario 3 is completed"),UVM_MEDIUM)
end

begin
wr_seq.scenario = 4;
wr_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("write_read scenario 4 is completed"),UVM_MEDIUM)
end 

begin
wr_seq.scenario = 5;
wr_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("write_read scenario 5 is completed"),UVM_MEDIUM)
end

begin
wr_seq.scenario = 6;
wr_seq.start(env.sync_fifo_agnt.sequencer);
`uvm_info(get_type_name(),$sformatf("write_read scenario 6 is completed"),UVM_MEDIUM)
end 

phase.drop_objection(this);
phase.phase_done.set_drain_time(this,100);

endtask
 
endclass
