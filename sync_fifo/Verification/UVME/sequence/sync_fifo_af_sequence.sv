class sync_fifo_af_sequence extends sync_fifo_base_sequence;
//factory registration
`uvm_object_utils(sync_fifo_af_sequence)

  //creating sequence item handle
sync_fifo_seq_item af_seq_item;

int scenario;

//function new constructor
function new(string name="sync_fifo_af_sequence");
super.new(name);
endfunction

//build phase
function build_phase(uvm_phase, phase);
//super.new(phase);
af_seq_item = sync_fifo_seq_item::type_id::create("af_seq_item");
endfunction

//task
task body();

//reset scenario
`uvm_info (get_type_name(),"Reset seq: inside body", UVM_LOW)

 if (scenario == 1)
        begin
        `uvm_do_with(af_seq_item,{
//	af_seq_item.reset        == 1'b0;
	af_seq_item.hw_rst        == 1'b0;
	af_seq_item.sw_rst        == 1'b0;
	af_seq_item.top_wr_en    == 1'b0;
	af_seq_item.top_wr_data  == 32'h0;
	af_seq_item.top_rd_en    == 1'b0;
	af_seq_item.almost_full_value  == 9'h000;
	af_seq_item.almost_empty_value == 9'h000;
	});
	
	end

 if (scenario == 2)
       repeat(15)
       begin
        `uvm_do_with(af_seq_item,{
//	af_seq_item.reset        == 1'b0;
	af_seq_item.hw_rst        == 1'b1;
	af_seq_item.sw_rst        == 1'b1;
	af_seq_item.top_wr_en    == 1'b1;
//	af_seq_item.top_wr_data  == 32'h00000000;
	af_seq_item.top_rd_en    == 1'b0;
	af_seq_item.almost_empty_value  == 9'h5;   //9'h3FF-9'h000
	af_seq_item.almost_full_value == 9'h9;
	});
	end

endtask

endclass

