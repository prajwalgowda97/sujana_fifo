class sync_fifo_reset_sequence extends sync_fifo_base_sequence;
//factory registration
`uvm_object_utils(sync_fifo_reset_sequence)

  //creating sequence item handle
sync_fifo_seq_item seq_item;

int scenario;

//function new constructor
function new(string name="sync_fifo_reset_sequence");
super.new(name);
endfunction

//build phase
function build_phase(uvm_phase, phase);
//super.new(phase);
seq_item = sync_fifo_seq_item::type_id::create("seq_item");
endfunction

//task
task body();

//reset scenario
`uvm_info (get_type_name(),"Reset sequence: inside body", UVM_LOW)

 if (scenario == 1)
       // repeat(5) 
       begin
        `uvm_do_with(seq_item,{
//	seq_item.reset        == 1'b0;
	seq_item.hw_rst        == 1'b0;
	seq_item.sw_rst        == 1'b0;		
	seq_item.top_wr_en    == 1'b0;
	seq_item.top_wr_data  == 32'h00000000;
	seq_item.top_rd_en    == 1'b0;
	seq_item.almost_full_value  == 9'h000;
	seq_item.almost_empty_value == 9'h000;
	});
	
	end

 if (scenario == 2)
      repeat(5) 
       begin
        `uvm_do_with(seq_item,{
//	seq_item.reset        == 1'b1;
	seq_item.hw_rst        == 1'b1;
	seq_item.sw_rst        == 1'b1;	
	seq_item.top_wr_en    == 1'b0;
	seq_item.top_wr_data  == 32'h0;
	seq_item.top_rd_en    == 1'b0;
	seq_item.almost_full_value  == 9'h000;
	seq_item.almost_empty_value == 9'h000;
	});
	end
/*
 if (scenario == 3)
      repeat(15) 
       begin
        `uvm_do_with(seq_item,{
//	seq_item.reset        == 1'b1;
	seq_item.hw_rst        == 1'b1;
	seq_item.sw_rst        == 1'b1;	
	seq_item.top_wr_en    == 1'b0;
	seq_item.top_wr_data  == 32'h00000000;
	seq_item.top_rd_en    == 1'b1;
	seq_item.almost_full_value  == 9'h011;
	seq_item.almost_empty_value == 9'h010;
	});
	end
*/
endtask

endclass
