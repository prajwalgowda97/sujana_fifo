/*
`uvm_analysis_imp_decl (_con1)
class sync_fifo_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(sync_fifo_scoreboard)
  uvm_analysis_imp#(sync_fifo_seq_item, sync_fifo_scoreboard) scb_port;

  	sync_fifo_seq_item que[$];
	sync_fifo_seq_item trans;

	bit [9:0] mem[$];
	bit [9:0] tx_data;
	bit read_delay_clk;

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    scb_port = new("scb_port", this);
  endfunction: build_phase
  
  // write
  virtual function void write(sync_fifo_seq_item pkt);
    $display("SCB:: Pkt recived");
    pkt.print();
  endfunction : write 

  // write function implementation
  function void write(sync_fifo_seq_item seq_item);
  que.push_back(seq_item);
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
    
    wait(que.size()>0);
    trans=que.pop_front();

    //WRITE
    if(trans.top_wr_en==1) begin
    mem.push_back(trans.top_wr_data);
    end
          
    //READ
    if(trans.top_rd_en==1 || (read_delay_clk != 35)) 
      	begin //if block starts here
          $display($time, "\t display 1 trans.top_rd_en = %d, read_delay_clk=%d", trans.top_rd_en, read_delay_clk);
          
      	if(read_delay_clk==35) read_delay_clk = 1;
         	 
          			else begin //else
            		if(trans.top_rd_en==0) read_delay_clk = 35;
                      $display($time, "\t display 2 trans.top_rd_en = %d, read_delay_clk=%d", trans.top_rd_en, read_delay_clk);

            		if(mem.size>0) 
                		begin
                  		tx_data = mem.pop_front();
                  		if(trans.top_rd_data==tx_data) 
                    	begin
                          `uvm_info("SCOREBOARD",$sformatf("------ :: EXPECTED MATCH  :: ------"),UVM_MEDIUM)
                     	`uvm_info("SCOREBOARD",$sformatf("Exp_Data: %0h, Act_data=%0h",tx_data,trans.top_rd_data),UVM_MEDIUM)
                     	`uvm_info("SCOREBOARD",$sformatf("-------------------------------------------------------"),UVM_MEDIUM)
                    	end
                  		else 
                    	begin
                          `uvm_info("SCOREBOARD",$sformatf("------ ::  FAILED MATCH  :: ------"),UVM_MEDIUM)
                      	`uvm_info("SCOREBOARD",$sformatf("Exp_Data: %0h, Act_data=%0h",tx_data,trans.top_rd_data),UVM_MEDIUM)
                      	`uvm_info("SCOREBOARD",$sformatf("-------------------------------------------------------"),UVM_MEDIUM)
                    	end
                		end
            		end //else
        end //if block ends here
          
      else
      read_delay_clk = 35;
    end

  endtask


 endclass : sync_fifo_scoreboard

 */


class sync_fifo_scoreboard extends uvm_scoreboard;
  // Factory registration
  `uvm_component_utils(sync_fifo_scoreboard)
  
  // Analysis port to receive transactions from monitor
  uvm_analysis_imp#(sync_fifo_seq_item, sync_fifo_scoreboard) scoreboard_port;
  virtual sync_fifo_inf intf; 
  
  // Reference model - a queue to model FIFO behavior
  bit [31:0] fifo_queue[$];
  
  // Statistics
  int num_writes;
  int num_reads;
  int num_matches;
  int num_mismatches;
  
  // Configuration parameters
  int fifo_depth = 1024;  // Default depth - may need to be updated based on your design
  int almost_full_threshold;
  int almost_empty_threshold;
  
  // Current state tracking
  bit fifo_full;
  bit fifo_empty;
  bit almost_full;
  bit almost_empty;
  bit overflow_detected;
  bit underflow_detected;
  
  // Constructor
  function new(string name = "sync_fifo_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info("SCOREBOARD", "Constructor called", UVM_HIGH)
  endfunction : new
  
  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    scoreboard_port = new("scoreboard_port", this);
    if (!uvm_config_db#(virtual sync_fifo_inf)::get(this, "*", "sync_fifo_inf", intf)) begin
            `uvm_fatal(get_full_name(), "Error while getting read interface from scoreboard")
	    end

    `uvm_info("SCOREBOARD", "Build phase completed", UVM_HIGH)
  endfunction : build_phase
  
  // Write method - called when monitor sends a transaction
  virtual function void write(sync_fifo_seq_item item);
    sync_fifo_seq_item cloned_item;
    $cast(cloned_item, item.clone());
    
    // Process the item
    process_item(cloned_item);
  endfunction : write
  
  // Process an item and check for correctness
  function void process_item(sync_fifo_seq_item item);
    // Update thresholds from transaction
    almost_full_threshold = item.almost_full_value;
    almost_empty_threshold = item.almost_empty_value;
    
    // Check if reset is active
    if (!item.hw_rst || !item.sw_rst) begin
      // Reset reference model
      reset_model();
      return;
    end
    
    // Check write operation
    if (item.top_wr_en) begin
      // Check for overflow condition
      if (fifo_queue.size() >= fifo_depth) begin
        fifo_full = 1;
        overflow_detected = 1;
        `uvm_info("SCOREBOARD", $sformatf("FIFO overflow detected! Data: %0h", item.top_wr_data), UVM_MEDIUM)
        
        // Verify DUT overflow signal
        if (item.overflow !== 1'b1) begin
          `uvm_error("SCOREBOARD", $sformatf("Overflow signal mismatch - Expected: 1, Got: %0b", item.overflow))
        end
      end
      else begin
        // Valid write operation
        fifo_queue.push_back(item.top_wr_data);
        `uvm_info("SCOREBOARD", $sformatf("Write operation: Time: %0t, Data = %0h, Queue size = %0d", 
                                         $realtime, item.top_wr_data, fifo_queue.size()), UVM_MEDIUM)
        num_writes++;
        
        // Update internal state
        update_state();
      end
    end
    
    // Check read operation
    if (item.top_rd_en) begin
      bit [31:0] expected_data;
      
      // Check for underflow condition
      if (fifo_queue.size() == 0) begin
        fifo_empty = 1;
        underflow_detected = 1;
        `uvm_info("SCOREBOARD", "FIFO underflow detected!", UVM_MEDIUM)
        
       // Verify DUT underflow signal
        if (item.underflow !== 1'b1) begin
          `uvm_error("SCOREBOARD", $sformatf("Underflow signal mismatch - Expected: 1, Got: %0b", item.underflow))
        end
        
        // Valid should be low for underflow
        if (item.valid !== 1'b0) begin
          `uvm_error("SCOREBOARD", $sformatf("Valid signal mismatch during underflow - Expected: 0, Got: %0b", item.valid))
        end
      end
      else begin
        // Valid read operation
	if(item.valid==1)begin
        expected_data = fifo_queue.pop_front();
        num_reads++;
	end
        
        // Valid should be high for valid read
        if (item.valid !== 1'b1) begin
          `uvm_error("SCOREBOARD", $sformatf("Valid signal mismatch - Expected: 1, Got: %0b", item.valid))
        end
        
        // Check read data
        if (item.top_rd_data !== expected_data) begin
          `uvm_error("SCOREBOARD", $sformatf("Read data mismatch - Expected: %0h, Got: %0h", 
                                            expected_data, item.top_rd_data))
          num_mismatches++;
        end
        else begin
          `uvm_info("SCOREBOARD", $sformatf("Read data match - expeted_Data: %0h actual_data: %0h", expected_data, item.top_rd_data), UVM_MEDIUM)
          num_matches++;
        end
        
        // Update internal state
        update_state();
      end
    end
    
    // Verify status signals
    verify_status_signals(item);
  endfunction : process_item
  
  // Reset the model
  function void reset_model();
    fifo_queue.delete();
    fifo_full = 0;
    fifo_empty = 1;
    almost_full = 0;
    almost_empty = 0;
    overflow_detected = 0;
    underflow_detected = 0;
    `uvm_info("SCOREBOARD", "Reference model reset", UVM_MEDIUM)
  endfunction : reset_model
  
  // Update internal state based on queue size
  function void update_state();
    // Update empty/full status
    	if(fifo_queue.size()==0)
    	fifo_empty=1;
    	else
    	fifo_empty=0;
    //fifo_empty = (fifo_queue.size() == 0);

    if(fifo_queue.size()>=fifo_depth)
    fifo_full=1;
    else
    fifo_full=0;
    //fifo_full = (fifo_queue.size() >= fifo_depth);
    
    // Update almost empty/full status
    if(almost_full_threshold<=fifo_queue.size())
    almost_full=1;
    else
    almost_full=0;
   // almost_empty = (fifo_queue.size() <= almost_empty_threshold);

   if(almost_empty_threshold>=fifo_queue.size())
   almost_empty=1;
   else
   almost_empty=0;

    //almost_full = (fifo_queue.size() >= almost_full_threshold);

  endfunction : update_state
  
  // Verify status signals match expected states
  function void verify_status_signals(sync_fifo_seq_item item);
    // Check full flag
    if (item.ext_mem_full !== fifo_full) begin
      `uvm_error("SCOREBOARD", $sformatf("Full flag mismatch - Expected: %0b, Got: %0b", 
                                        fifo_full, item.ext_mem_full))
    end
    
    // Check enq_fifo_full flag (should match ext_mem_full)
    if (item.enq_fifo_full !== fifo_full) begin
      `uvm_error("SCOREBOARD", $sformatf("enq_fifo_full flag mismatch - Expected: %0b, Got: %0b", 
                                        fifo_full, item.enq_fifo_full))
    end
    
    // Check empty flag
    if (item.ext_mem_empty !== fifo_empty) begin
      `uvm_error("SCOREBOARD", $sformatf("Empty flag mismatch - Time: %t, Expected: %0b, Got: %0b", 
                                        $realtime, fifo_empty, item.ext_mem_empty))
    end
    
    // Check almost full flag
    if (item.almost_full !== almost_full) begin
      `uvm_error("SCOREBOARD", $sformatf("Almost full flag mismatch - Expected: %0b, Got: %0b", 
                                        almost_full, item.almost_full))
    end
    
    // Check almost empty flag
    if (item.almost_empty !== almost_empty) begin
      `uvm_error("SCOREBOARD", $sformatf("Almost empty flag mismatch - Expected: %0b, Got: %0b, fifo_queue_size: %d", 
                                        almost_empty, item.almost_empty, fifo_queue.size() ))
    end
  endfunction : verify_status_signals
  
  // Report phase - print statistics
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCOREBOARD", $sformatf("Report: \n\tWrites: %0d\n\tReads: %0d\n\tMatches: %0d\n\tMismatches: %0d", 
                                      num_writes, num_reads, num_matches, num_mismatches), UVM_LOW)
                                      
    if (num_mismatches == 0) begin
      `uvm_info("SCOREBOARD", "TEST PASSED - All read data matched expected values", UVM_LOW)
    end else begin
      `uvm_error("SCOREBOARD", $sformatf("TEST FAILED - %0d mismatches detected", num_mismatches))
    end
  endfunction : report_phase
endclass
