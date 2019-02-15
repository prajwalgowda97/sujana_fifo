class sync_fifo_ae_sequence extends sync_fifo_base_sequence;
//factory registration
`uvm_object_utils(sync_fifo_ae_sequence)

  //creating sequence item handle
sync_fifo_seq_item ae_seq_item;

int scenario;

//function new constructor
function new(string name="sync_fifo_ae_sequence");
super.new(name);
endfunction

//build phase
function build_phase(uvm_phase, phase);
//super.new(phase);
ae_seq_item = sync_fifo_seq_item::type_id::create("ae_seq_item");
endfunction

//task
task body();

//reset scenario
`uvm_info (get_type_name(),"Reset seq: inside body", UVM_LOW)

 if (scenario == 1)
        begin
        `uvm_do_with(ae_seq_item,{
//	ae_seq_item.reset        == 1'b0;
	ae_seq_item.hw_rst        == 1'b0;
	ae_seq_item.sw_rst        == 1'b0;	
	ae_seq_item.top_wr_en    == 1'b0;
	ae_seq_item.top_wr_data  == 32'h0;
	ae_seq_item.top_rd_en    == 1'b0;
	ae_seq_item.almost_full_value  == 10'h000;
	ae_seq_item.almost_empty_value == 10'h000;
	});
	
	end

 if (scenario == 2)
       repeat(10)
       begin
        `uvm_do_with(ae_seq_item,{
//	ae_seq_item.reset        == 1'b1;
	ae_seq_item.hw_rst        == 1'b1;
	ae_seq_item.sw_rst        == 1'b1;	
	ae_seq_item.top_wr_en    == 1'b1;
//	ae_seq_item.top_wr_data  == 32'h00000000;
	ae_seq_item.top_rd_en    == 1'b0;
	ae_seq_item.almost_empty_value  == 10'h5;   //9'h3FF-9'h000
	ae_seq_item.almost_full_value == 10'h9;
	});
	end

if (scenario == 3)
       repeat(5) begin
        `uvm_do_with(ae_seq_item,{
//	ae_seq_item.reset        == 1'b1;
	ae_seq_item.hw_rst        == 1'b1;
	ae_seq_item.sw_rst        == 1'b1;	
	ae_seq_item.top_wr_en    == 1'b0;
	ae_seq_item.top_wr_data  == 32'h0;
	ae_seq_item.top_rd_en    == 1'b0;
	ae_seq_item.almost_full_value  == 10'h000;
	ae_seq_item.almost_empty_value == 10'h000;
	});
	
	end

endtask

endclass


