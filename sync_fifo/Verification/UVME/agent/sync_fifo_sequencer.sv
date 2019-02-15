class sync_fifo_sequencer extends uvm_sequencer#(sync_fifo_seq_item);
  // factory registration
  `uvm_component_utils(sync_fifo_sequencer) 

  // function new constructor
  function new(string name = "sync_fifo_sequencer", uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
endclass
