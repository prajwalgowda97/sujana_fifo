//`timescale 1ns/1ps
module fifo #(parameter DATA_WIDTH   = 32  , // done
                        DEPTH        = 32  , // done
                        ADDR_WIDTH   = 5   , // done
                        RESET_MEM    = 0   , // done
                        SOFT_RESET   = 0   , // done
                        POWER_SAVE   = 1   , // done 
                        STICKY_ERROR = 2   , // done
                        PIPE_READ    = 0     // done
             )
            (
             
            input  logic                          clk                  ,  //////  clock 

            input  logic                          hw_rst                  ,  //////  reset           
            input  logic                          mem_rst              ,  //////  memory reset            
            input  logic                          sw_rst               ,  //////  sotware reset

            input  logic                          wr_en                ,   //////  to write the data 
            input  logic       [DATA_WIDTH-1:0]   wr_data              ,

            
            input  logic                          rd_en                ,   //////  to read the data 
            output logic       [DATA_WIDTH-1:0]   rd_data_out          ,

            
            output logic                          fifo_full            ,   //////  to ack wheather fifo is full or not
            output logic                          fifo_empty           ,

            output logic                          almost_full          ,   //////  to indicate almost full and almost empty
            output logic                          almost_empty         ,

            output logic       [ADDR_WIDTH:0]     wr_lvl               ,   //////  to indicate write and read level
            output logic       [ADDR_WIDTH:0]     rd_lvl               ,

            output logic                          overflow             ,    //////  to indicate overflow and overflow condidtion
            output logic                          underflow           

            );


//////  to know the address of fifo logic
logic [ADDR_WIDTH:0]    wr_ptr           ;
logic [ADDR_WIDTH:0]    rd_ptr           ;


//////  to create a fifo with data_width = 32 and depth = 32
logic [DATA_WIDTH-1:0] fifo [0:DEPTH-1]  ;


////// used to register the data
logic [DATA_WIDTH-1:0] rd_data_reg            ;


////// to the use for almost empty and almost full 
logic temp_empty                        ;
logic temp_full                         ;


////------------------------------ WRITING OPERATION ------------------------------////

////// checking for almost full condition
assign temp_full = (wr_lvl >= 5'd30)        ;


////// assigning almost full 
always_comb
begin
        if(!hw_rst)
        begin
            almost_full = 1'b0                             ;
        end

        else if(!sw_rst && SOFT_RESET)
        begin
            almost_full = 1'b0                             ;
        end

        else if(temp_full)
        begin
            almost_full = 1'b1                             ;
        end

        else
        begin
            almost_full = 1'b0                             ;
        end

end

//////   writing the data to the memory
always_ff@(posedge clk or negedge hw_rst )
begin

    if(!hw_rst)
    begin
         wr_ptr       <= 6'd0                                ;
    end

    else if(!sw_rst && SOFT_RESET)
    begin
         wr_ptr       <= 6'd0                                ;
    end

    else if(wr_en && ~fifo_full && ~overflow)
    begin
         fifo[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data             ;
         wr_ptr                       <= wr_ptr + 1'b1       ; 
    end

end 

////// assigning fifo full 
assign fifo_full  = (({~wr_ptr[5],wr_ptr[ADDR_WIDTH-1:0]} == rd_ptr))                   ;

////// assigning the overflow
 always_ff@(posedge clk or negedge hw_rst)
 begin

 if(!hw_rst)
     begin
     overflow  <= 1'b0                                  ;
     end
  else if(!sw_rst && SOFT_RESET==1)
      begin
      overflow <= 1'b0                                  ;
      end
  else if(overflow==1'b1 && STICKY_ERROR==1)
     begin
     overflow  <= 1'b1                                  ;
     end

  else if(fifo_full &&  wr_en  )
     begin
     overflow  <=  1'b1                                 ; 
     end

  else
     begin
     overflow  <= 1'b0                                  ;
     end

 end
//-------------------------------------------------------------------------------------------

////--------------------------- READING OPERATION ---------------------------------------////

assign rd_data_reg = (PIPE_READ==1 && !fifo_empty) ? fifo[rd_ptr[ADDR_WIDTH-1:0]] : 32'd0   ;


////// to check almost empty condition 
assign temp_empty = (wr_lvl <= 5'd2 )                       ;


////// assigning almost empty 
always_comb
begin

        if(!hw_rst)
        begin
            almost_empty <= 1'b1                            ;     
        end

        else if(!sw_rst && SOFT_RESET)
        begin
             almost_empty <= 1'b1                           ; 
        end

        else if(temp_empty)
        begin
            almost_empty = 1'b1                             ;
        end

        else
        begin
            almost_empty = 1'b0                             ;
        end

end

//////   reading the data from the memory
always_ff@(posedge clk or negedge hw_rst)
begin

     if(!hw_rst)
     begin        
         rd_ptr       <= 6'd0                                ;
         rd_data_out  <= 32'd0                               ;                            
     end

     else if(!sw_rst && SOFT_RESET)
     begin
         rd_ptr       <= 6'd0                                ;
         rd_data_out  <= 32'd0                               ;                           
     end

     else if(!mem_rst && RESET_MEM)
     begin        
        rd_data_out   <= {DATA_WIDTH{1'b0}}                  ;
     end


    else if(rd_en && !fifo_empty && PIPE_READ == 0)
    begin
        
        rd_data_out   <= fifo[rd_ptr[ADDR_WIDTH-1:0]]        ;
        rd_ptr        <= rd_ptr + 1'b1                       ;
    end

    else if(rd_en && !fifo_empty && PIPE_READ == 1)
    begin
        rd_data_out <= rd_data_reg                           ;
        rd_ptr      <= rd_ptr  + 1'b1                        ;
    end


end


//////  calculating fifo empty condition         
assign fifo_empty = (wr_ptr == rd_ptr)                       ;


//////  assigning the underflow 
always_ff@(posedge clk or negedge hw_rst)
 begin
 if(!hw_rst)
     begin
     underflow  <=  1'b0                                 ;
     end
 else if(!sw_rst && SOFT_RESET==1)
     begin
      underflow  <=  1'b0                                ;
     end
 else if(fifo_empty &&  rd_en )
     begin
     underflow  <=  1'b1                                 ; 
     end
 else
     begin
     underflow  <= 1'b0                                  ;
     end
 end

//---------------------------------------------------------------------------------------

////------------------- calculating write level and read level ------------------------////

always_ff@(posedge clk or negedge hw_rst )
begin

    if(!hw_rst)
    begin
        wr_lvl  <= 6'd0                                      ;
        rd_lvl  <= 6'd32                      ;
    end

    else if(!sw_rst && SOFT_RESET)
    begin
        wr_lvl  <= 6'd0                                      ;
        rd_lvl  <= 6'd32                      ;
    end    

    else if( (wr_en && ~fifo_full) && (rd_en && ~fifo_empty) && (~overflow))
    begin
        wr_lvl  <= wr_lvl                                       ;
        rd_lvl  <= rd_lvl                                       ;
    end

    else if(wr_en && ~fifo_full && (~overflow))
    begin
        rd_lvl <= rd_lvl - 1'b1                              ;
        wr_lvl <= wr_lvl + 1'b1                              ;    
    end

    else if(rd_en && ~fifo_empty)
    begin
        rd_lvl  <= rd_lvl + 1'b1                                ;
        wr_lvl  <= wr_lvl - 1'b1                                ; 
    end

    

end

////----------------------------------------------------------------------------------------

////---------------------- memory reset logic ----------------------------------------------

integer i                                   ;

always_ff@(posedge clk or negedge mem_rst)
begin
    if(!mem_rst && RESET_MEM)
    begin

        for(i=0 ; i<=DEPTH-1 ; i=i+1)
        begin
            fifo[i] <= ({DATA_WIDTH{1'b0}});
        end

    end   
     
end

////---------------------------------------------------------------------------------------
endmodule
