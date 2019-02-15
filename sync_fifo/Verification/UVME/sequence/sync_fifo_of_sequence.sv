class sync_fifo_of_sequence extends sync_fifo_base_sequence;
//factory registration
`uvm_object_utils(sync_fifo_of_sequence)

  //creating sequence item handle
sync_fifo_seq_item of_seq_item;

int scenario;

//function new constructor
function new(string name="sync_fifo_of_sequence");
super.new(name);
endfunction

//build phase
function build_phase(uvm_phase, phase);
//super.new(phase);
of_seq_item = sync_fifo_seq_item::type_id::create("of_seq_item");
endfunction

//task
task body();

//reset scenario
`uvm_info (get_type_name(),"Reset seq: inside body", UVM_LOW)

 if (scenario == 1)
        begin
        `uvm_do_with(of_seq_item,{
//	of_seq_item.reset        == 1'b0;
	of_seq_item.hw_rst        == 1'b0;
	of_seq_item.sw_rst        == 1'b0;	
	of_seq_item.top_wr_en    == 1'b0;
	of_seq_item.top_wr_data  == 32'h0;
	of_seq_item.top_rd_en    == 1'b0;
	of_seq_item.almost_full_value  == 9'h000;
	of_seq_item.almost_empty_value == 9'h000;
	});
	
	end

 if (scenario == 2)
       repeat(1024)
       begin
        `uvm_do_with(of_seq_item,{
//	of_seq_item.reset        == 1'b0;
	of_seq_item.hw_rst        == 1'b1;
	of_seq_item.sw_rst        == 1'b1;
	of_seq_item.top_wr_en    == 1'b1;
//	of_seq_item.top_wr_data  == 32'h00000000;
	of_seq_item.top_rd_en    == 1'b0;
	of_seq_item.almost_full_value  == 10'h3FF;
	of_seq_item.almost_empty_value == 10'h009;
	});
	end

 if (scenario == 3)
       repeat(1030)
       begin
        `uvm_do_with(of_seq_item,{
//	of_seq_item.reset        == 1'b0;
	of_seq_item.hw_rst        == 1'b1;
	of_seq_item.sw_rst        == 1'b1;
	of_seq_item.top_wr_en    == 1'b0;
//	of_seq_item.top_wr_data  == 32'h00000000;
	of_seq_item.top_rd_en    == 1'b1;
	of_seq_item.almost_full_value  == 10'h3FF;
	of_seq_item.almost_empty_value == 10'h009;
	});
	end

if (scenario == 4)
      // repeat(1024)
       begin
        `uvm_do_with(of_seq_item,{
//	of_seq_item.reset        == 1'b0;
	of_seq_item.hw_rst        == 1'b1;
	of_seq_item.sw_rst        == 1'b1;
	of_seq_item.top_wr_en    == 1'b0;
//	of_seq_item.top_wr_data  == 32'h00000000;
	of_seq_item.top_rd_en    == 1'b0;
	of_seq_item.almost_full_value  == 10'h3FF;
	of_seq_item.almost_empty_value == 10'h009;
	});
	end


endtask

endclass
