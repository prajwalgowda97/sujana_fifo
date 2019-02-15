class sync_fifo_base_sequence extends uvm_sequence#(sync_fifo_seq_item);
//factory registration
  `uvm_object_utils(sync_fifo_base_sequence)
  
  sync_fifo_seq_item sq;

  function new(string name = "sync_fifo_base_sequence");
    super.new(name);
      sq = sync_fifo_seq_item::type_id::create("sq");

  endfunction
  
  /*
  function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  endfunction
  */
  
  task body();
      
      start_item(sq);
      
      finish_item(sq);

  endtask
  
endclass
