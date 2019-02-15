class sync_fifo_uf_sequence extends sync_fifo_base_sequence;
//factory registration
`uvm_object_utils(sync_fifo_uf_sequence)

  //creating sequence item handle
sync_fifo_seq_item uf_seq_item;

int scenario;

//function new constructor
function new(string name="sync_fifo_uf_sequence");
super.new(name);
endfunction

//build phase
function build_phase(uvm_phase, phase);
//super.new(phase);
uf_seq_item = sync_fifo_seq_item::type_id::create("uf_seq_item");
endfunction

//task
task body();

//reset scenario
`uvm_info (get_type_name(),"Reset seq: inside body", UVM_LOW)

 if (scenario == 1)
        begin
        `uvm_do_with(uf_seq_item,{
//	uf_seq_item.reset        == 1'b0;
	uf_seq_item.hw_rst        == 1'b0;
	uf_seq_item.sw_rst        == 1'b0;	
	uf_seq_item.top_wr_en    == 1'b0;
	uf_seq_item.top_wr_data  == 32'h0;
	uf_seq_item.top_rd_en    == 1'b0;
	uf_seq_item.almost_full_value  == 9'h000;
	uf_seq_item.almost_empty_value == 9'h000;
	});
	
	end

 if (scenario == 2)
       repeat(5)begin
        `uvm_do_with(uf_seq_item,{
//	uf_seq_item.reset        == 1'b0;
	uf_seq_item.hw_rst        == 1'b1;
	uf_seq_item.sw_rst        == 1'b1;	
	uf_seq_item.top_wr_en    == 1'b0;
	uf_seq_item.top_wr_data  == 32'h00000000;
	uf_seq_item.top_rd_en    == 1'b1;
	uf_seq_item.almost_full_value  == 9'h1FF;
	uf_seq_item.almost_empty_value == 9'h005;
	});
	end

if (scenario == 3)
       repeat(5)begin
        `uvm_do_with(uf_seq_item,{
//	uf_seq_item.reset        == 1'b0;
	uf_seq_item.hw_rst        == 1'b1;
	uf_seq_item.sw_rst        == 1'b1;	
	uf_seq_item.top_wr_en    == 1'b1;
//	uf_seq_item.top_wr_data  == 32'h00000000;
	uf_seq_item.top_rd_en    == 1'b0;
	uf_seq_item.almost_full_value  == 9'h1FF;
	uf_seq_item.almost_empty_value == 9'h005;
	});
	end

if (scenario == 4)
       repeat(10)begin
        `uvm_do_with(uf_seq_item,{
//	uf_seq_item.reset        == 1'b0;
	uf_seq_item.hw_rst        == 1'b1;
	uf_seq_item.sw_rst        == 1'b1;	
	uf_seq_item.top_wr_en    == 1'b0;
//	uf_seq_item.top_wr_data  == 32'h00000000;
	uf_seq_item.top_rd_en    == 1'b1;
	uf_seq_item.almost_full_value  == 9'h1FF;
	uf_seq_item.almost_empty_value == 9'h005;
	});
	end

if (scenario == 5)
       begin
        `uvm_do_with(uf_seq_item,{
//	uf_seq_item.reset        == 1'b0;
	uf_seq_item.hw_rst        == 1'b1;
	uf_seq_item.sw_rst        == 1'b1;	
	uf_seq_item.top_wr_en    == 1'b0;
	uf_seq_item.top_wr_data  == 32'h00000000;
	uf_seq_item.top_rd_en    == 1'b0;
	uf_seq_item.almost_full_value  == 9'h1FF;
	uf_seq_item.almost_empty_value == 9'h005;
	});
	end

endtask

endclass
