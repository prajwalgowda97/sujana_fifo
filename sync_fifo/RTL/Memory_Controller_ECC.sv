//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////Copyright © 2022 PravegaSemi PVT LTD., All rights reserved//////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                              //
//All works published under Zilla_Gen_0 by PravegaSemi PVT LTD is copyrighted by the Association and ownership  // 
//of all right, title and interest in and to the works remains with PravegaSemi PVT LTD. No works or documents  //
//published under Zilla_Gen_0 by PravegaSemi PVT LTD may be reproduced,transmitted or copied without the express//
//written permission of PravegaSemi PVT LTD will be considered as a violations of Copyright Act and it may lead //
//to legal action.                                                                                         //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*////////////////////////////////////////////////////////////////////////////////////////////////////////////////
* File Name : memory_controller.sv

* Purpose :

* Creation Date : 10-10-2023

* Last Modified : Mon 04 Dec 2023 05:16:59 PM IST

* Created By : Karthik BG 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

module mem_ctrl 
               #(
                 GLOBAL_MEM_INIT    =  0                                        ,
                 ADDR_WIDTH         =  14                                       ,
                 DEPTH              =  1<<ADDR_WIDTH                            ,
                 DATA_WIDTH         =  32                                       ,
                 PARITY_BITS        =  6                                        ,
                 MEMORY_DATA_WIDTH  =  39                                       ,
                 REG_ADDR_WIDTH     =  10
                )
                (
                 //     MEMORY_CONTROL SIGNALS
                 input    logic                             MEM_ctrl_clk                             ,
                 input    logic                             MEM_ctrl_rstn                            ,
                 input    logic                             MEM_ctrl_sw_rst                          ,
                 input    logic                             MEM_ctrl_mem_init                        ,

                 input    logic                             MEM_ctrl_wr_en                           ,
                 input    logic [ADDR_WIDTH-1:0]            MEM_ctrl_wr_addr_bus                     ,
                 input    logic [DATA_WIDTH-1:0]            MEM_ctrl_write_data_bus                  ,
                 input    logic [3:0]                       MEM_ctrl_wr_strobe                       ,
                 output   logic [1:0]                       wr_resp                                  ,

                 input    logic                             MEM_ctrl_rd_en                           ,
                 input    logic [ADDR_WIDTH-1:0]            MEM_ctrl_rd_addr_bus                     ,
                 output   logic [DATA_WIDTH-1:0]            MEM_ctrl_data_out                        ,
                 output   logic [1:0]                       rd_resp                                  ,
               
                 output   logic                             ECC_interrupt                            ,
                 output   logic                             MEM_init_ACK                              ,


                 //     BRAM SIGNALS
                 output   logic                             BRAM_en                                  ,
 
                 output   logic                             BRAM_wr_en                               ,
                 output   logic [ADDR_WIDTH-1:0]            BRAM_wr_addr                             ,                 
                 output   logic [MEMORY_DATA_WIDTH-1:0]     BRAM_wr_data                             ,

                 output   logic                             BRAM_rd_en                               ,
                 output   logic [ADDR_WIDTH-1:0]            BRAM_rd_addr                             ,                 
                 input    logic [MEMORY_DATA_WIDTH-1:0]     BRAM_rd_data                             ,

                 output   logic [DATA_WIDTH-1:0]            o_ECC_STAUS_REG_ECC_STATUS               ,

                 //     REGISTERS SIGNALS
                 input    logic                             i_psel                                   ,
                 input    logic                             i_penable                                ,
                 input    logic                             i_pwrite                                 ,
                 input    logic [DATA_WIDTH-1:0]            i_pwdata                                 ,
                 input    logic [REG_ADDR_WIDTH-1:0]        i_paddr                                  ,
                 input    logic [3:0]                       i_pstrb                                  ,
                 input    logic                             i_ECC_STAUS_REG_ECC_STATUS_clear        
                );

//------INTERNALLY DECLARED SIGNALS FOR CONNECTIONS------------ 
logic   [ADDR_WIDTH-1:0]            wr_addr_w       ;
logic   [ADDR_WIDTH-1:0]            rd_addr_w       ;
logic   [DATA_WIDTH-1:0]            ECC_en_w        ;
logic   [DATA_WIDTH-1:0]            ECC_status_w    ;

logic                               data_valid_w    ;

logic                               i_psel_w        ;
logic                               i_penable_w     ;
logic  [REG_ADDR_WIDTH-1:0]         i_paddr_w       ;
logic                               i_pwrite_w      ;
logic  [3:0]                        i_pstrb_w       ;

logic                               i_psel_w2       ;
logic                               i_penable_w2    ;
logic  [REG_ADDR_WIDTH-1:0]         i_paddr_w2      ;
logic                               i_pwrite_w2     ;
logic  [DATA_WIDTH-1:0]             i_pwdata_w2     ;
logic  [3:0]                        i_pstrb_w2      ;

logic                               penable         ; 
logic                               penable_w       ;

logic  [DATA_WIDTH-1:0]             MEM_ctrl_data_out_w2 ;
logic  [DATA_WIDTH-1:0]             MEM_ctrl_data_out_w  ;

logic  [DATA_WIDTH-1:0]             ECC_irq_en_w         ; 

logic  [13:0]                       counter              ;
logic                               BRAM_wr_en_w         ;  
logic  [MEMORY_DATA_WIDTH-1:0]      BRAM_wr_data_w       ;

logic                               wr_addr_valid        ;
logic                               rd_addr_valid        ;

logic                               wr_resp_r            ;
logic                               wr_resp_reg          ;

logic                               rd_resp_r            ;
logic                               rd_resp_reg          ;

logic                               MEM_ctrl_wr_en_w       ; 
logic  [ADDR_WIDTH-1:0]             MEM_ctrl_wr_addr_bus_w ;

logic                               MEM_ctrl_rd_en_w       ; 
logic  [ADDR_WIDTH-1:0]             MEM_ctrl_rd_addr_bus_w ;

//--------------------------------------------------------------------------------------

//     CHECKING WRITE ADDRESS IS VALID OR NOT 
assign wr_addr_valid = ((MEM_ctrl_wr_addr_bus >= 32'd0) && (MEM_ctrl_wr_addr_bus <= 32'd16383))   ;

always_ff@(posedge MEM_ctrl_clk or negedge MEM_ctrl_rstn)
begin

if(!MEM_ctrl_rstn)
    begin
    wr_resp_r   <= 2'b00           ;
    end
else if(MEM_ctrl_sw_rst)
    begin
    wr_resp_r   <= 2'b00           ;
    end
else if(!wr_addr_valid) 
    begin
    wr_resp_r   <= 2'b11           ;
    end
else 
    begin
    wr_resp_r  <= 2'b00           ;
    end

end

assign MEM_ctrl_wr_en_w       = wr_addr_valid ? MEM_ctrl_wr_en       : 1'b0                 ;                            
assign MEM_ctrl_wr_addr_bus_w = wr_addr_valid ? MEM_ctrl_wr_addr_bus : {ADDR_WIDTH{1'b0}}   ;  

assign wr_resp = MEM_ctrl_wr_en ? wr_resp_r : wr_resp_reg       ;

always_ff@(posedge MEM_ctrl_clk or negedge MEM_ctrl_rstn)
begin

if(!MEM_ctrl_rstn)
    begin
    wr_resp_reg   <= 2'b00           ;
    end
else if(MEM_ctrl_sw_rst)
    begin
    wr_resp_reg   <= 2'b00           ;
    end
else 
    begin
    wr_resp_reg   <= wr_resp         ;
    end

end

/////////////////////////////////////////////////////////////////////////////////////

//     CHECKING READ ADDRESS IS VALID OR NOT 
assign rd_addr_valid = ((MEM_ctrl_rd_addr_bus >= 32'd0) && (MEM_ctrl_rd_addr_bus < 32'd16383))   ;

always_ff@(posedge MEM_ctrl_clk or negedge MEM_ctrl_rstn)
begin

if(!MEM_ctrl_rstn)
    begin
    rd_resp_r  <= 2'b00           ;
    end
else if(MEM_ctrl_sw_rst)
    begin
    rd_resp_r  <= 2'b00           ;
    end
else if(!rd_addr_valid) 
    begin
    rd_resp_r  <= 2'b11           ;
    end
else 
    begin
    rd_resp_r  <= 2'b00           ;
    end

end

assign MEM_ctrl_rd_en_w       = rd_addr_valid ? MEM_ctrl_rd_en       : 1'b0                 ;                            
assign MEM_ctrl_rd_addr_bus_w = rd_addr_valid ? MEM_ctrl_rd_addr_bus : {ADDR_WIDTH{1'b0}}   ;  

assign rd_resp = MEM_ctrl_rd_en ? rd_resp_r : rd_resp_reg       ;

always_ff@(posedge MEM_ctrl_clk or negedge MEM_ctrl_rstn)
begin

if(!MEM_ctrl_rstn)
    begin
    rd_resp_reg   <= 2'b00           ;
    end
else if(MEM_ctrl_sw_rst)
    begin
    rd_resp_reg   <= 2'b00           ;
    end
else 
    begin
    rd_resp_reg   <= rd_resp         ;
    end

end

//----COUNTER LOGIC---------------------------------------------------------------------
always_ff@(posedge MEM_ctrl_clk or negedge MEM_ctrl_rstn)
begin

if(!MEM_ctrl_rstn)
    begin
    counter  <= 13'd0                                   ; 
    end
else if(MEM_ctrl_sw_rst)
    begin
    counter  <= 13'd0                                   ;
    end
else if(((GLOBAL_MEM_INIT==1) || (GLOBAL_MEM_INIT==0))  && (MEM_ctrl_mem_init) && (counter<DEPTH)) 
    begin
    counter  <=  counter + 1'b1                        ;
    end
else
    begin
    counter  <= 13'd0                                   ;   
    end

end
//--------------------------------------------------------------------------------------

//----LOGIC TO GENERATE MEMORY RESET SIGNAL--------
always_ff@(posedge MEM_ctrl_clk or negedge MEM_ctrl_rstn)
begin

if(!MEM_ctrl_rstn)
    begin
       MEM_init_ACK  <= 1'b0                         ;
    end
else if(MEM_ctrl_sw_rst)
    begin
       MEM_init_ACK  <= 1'b0                         ;
    end
else if(counter == 14'd16383)
    begin
       MEM_init_ACK  <= 1'b1                         ;            
    end
else 
    begin
       MEM_init_ACK  <= 1'b0                         ;
    end

end        
//-------------------------------------------------

//----LOGIC TO GENERATE RAM ENABLE SIGNAL----------
always_comb
begin
BRAM_en = 1'b0  ;

if(wr_addr_valid || rd_addr_valid)
    begin
        if(((GLOBAL_MEM_INIT==1)||(GLOBAL_MEM_INIT==0)) && (MEM_ctrl_mem_init)  && (counter<DEPTH))
            begin
            BRAM_en = 1'b1      ;
            end
        else if(BRAM_wr_en || BRAM_rd_en) 
            begin
            BRAM_en = 1'b1      ;
            end
        else
            begin
            BRAM_en = 1'b0      ;
            end
    end        

end
//-------------------------------------------------


//----LOGIC TO GENERATE WRITE ADDRESS FOR THE RAM---- 
always_comb
begin

if(((GLOBAL_MEM_INIT==1)||(GLOBAL_MEM_INIT==0)) && (MEM_ctrl_mem_init) && (counter<DEPTH))
    begin
    BRAM_wr_addr = counter                    ;
    end    
else if(BRAM_wr_en) 
    begin
    BRAM_wr_addr = wr_addr_w                  ;
    end
else 
    begin
    BRAM_wr_addr = {ADDR_WIDTH{1'b0}}         ;
    end

end
//--------------------------------------------------------------------

//----LOGIC TO GENERATE READ ADDRESS FOR THE RAM---- 
always_comb
begin
    
if(BRAM_rd_en) 
    begin
    BRAM_rd_addr =  rd_addr_w                 ;
    end
else 
    begin
    BRAM_rd_addr = {ADDR_WIDTH{1'b0}}         ;
    end

end
//--------------------------------------------------------------------


//----LOGIC TO GENERATE BRAM WR_EN------------------------------------
always_comb
begin

if(((GLOBAL_MEM_INIT==1)||(GLOBAL_MEM_INIT==0)) && (MEM_ctrl_mem_init) && (counter<DEPTH)) 
    begin
    BRAM_wr_en    =  1'b1                  ;
    end
else
    begin
    BRAM_wr_en    =   BRAM_wr_en_w        ;
    end

end
//-------------------------------------------------------------------


//----LOGIC TO GENERATE RAM WRITE DATA------------------------------- 
always_comb
begin

if((GLOBAL_MEM_INIT==0) && (MEM_ctrl_mem_init) && (counter<DEPTH)) 
    begin
    BRAM_wr_data   = {MEMORY_DATA_WIDTH{1'b0}}          ;
    end
else if((GLOBAL_MEM_INIT==1) && (MEM_ctrl_mem_init) && (counter<DEPTH)) 
    begin
    BRAM_wr_data   = {MEMORY_DATA_WIDTH{1'b1}}          ;
    end    
else
    begin
    BRAM_wr_data   =  wr_addr_valid ? BRAM_wr_data_w   : {DATA_WIDTH{1'b0}}       ;
    end

end
//-------------------------------------------------------------------


//----LOGIC TO GENERATE THE PSEL--------------------------------------  
always_comb
begin

if(i_psel)
    begin
    i_psel_w2 = i_psel                      ;  
    end
else if(i_psel_w) 
    begin
    i_psel_w2 = i_psel_w                    ;
    end
else 
    begin
    i_psel_w2 = 1'b0                        ;
    end

end
//--------------------------------------------------------------------


always_ff@(posedge MEM_ctrl_clk)
begin
penable   <= i_penable_w                      ;
penable_w <= penable                          ;    
end


//----LOGIC TO GENERATE OUTPUT BASED ON DATA VALID SIGNAL------------
always_comb
begin

 if(data_valid_w)
    begin
    MEM_ctrl_data_out_w2  <=  MEM_ctrl_data_out_w       ;
    end
else
    begin
    MEM_ctrl_data_out_w2  <=  {DATA_WIDTH{1'b0}}   ;
    end

end
//-----------------------------------------------------------------


//--------------ASSIGNING  OUTPUT----------------------------------
assign MEM_ctrl_data_out = MEM_ctrl_data_out_w2         ;


//----LOGIC TO GENERATE THE PENABLE--------------------------------
always_comb
begin

if(i_penable)
    begin
    i_penable_w2 = i_penable                ;  
    end
else if(i_psel_w) 
    begin
    i_penable_w2 = penable_w                ;
    end
else 
    begin
    i_penable_w2 = 1'b0                     ;
    end

end
//------------------------------------------------------------------


//----LOGIC TO GENERATE THE PWRITE----------------------------------
always_comb
begin

if(i_pwrite && (i_paddr==10'd0))
    begin
    i_pwrite_w2 = 1'b0                      ;  
    end
else if(i_pwrite && (i_paddr!=10'd0))
    begin
    i_pwrite_w2 = i_pwrite                  ;  
    end    
else if(i_pwrite_w) 
    begin
    i_pwrite_w2 = i_pwrite_w                ;
    end    
else 
    begin
    i_pwrite_w2 = 1'b0                     ;
    end

end
//------------------------------------------------------------------


//----LOGIC TO GENERATE THE PWDATA----------------------------------
always_comb
begin

if(i_pwrite)
    begin
    i_pwdata_w2 = i_pwdata                ;  
    end
else if(i_pwrite_w) 
    begin
    i_pwdata_w2 = ECC_status_w             ;
    end
else 
    begin
    i_pwdata_w2 = 32'd0                     ;
    end

end
//------------------------------------------------------------------


//----LOGIC TO GENERATE THE PADDR-----------------------------------
always_comb
begin

if(i_pwrite)
    begin
    i_paddr_w2 = i_paddr                  ;  
    end
else if(i_pwrite_w) 
    begin
    i_paddr_w2 = i_paddr_w                ;
    end
else 
    begin
    i_paddr_w2 = 10'd0                     ;
    end

end
//-----------------------------------------------------------------


//----LOGIC TO GENERATE THE PSTROBE--------------------------------
always_comb
begin

if(i_pwrite)
    begin
    i_pstrb_w2 = i_pstrb                  ;  
    end
else if(i_psel_w) 
    begin
    i_pstrb_w2 = i_pstrb_w                ;
    end
else 
    begin
    i_pstrb_w2 = 1'b0                     ;
    end

end
//-----------------------------------------------------------------


//--------------ECC_ENCODING INSTANTIATION---------------------------------------------------
ECC_encoding
               #( 
                 .DATA_WIDTH         ( DATA_WIDTH                )           ,
                 .MEMORY_DATA_WIDTH  ( MEMORY_DATA_WIDTH         )           ,
                 .ADDR_WIDTH         ( ADDR_WIDTH                )           ,
                 .PARITY_BITS        ( PARITY_BITS               )
                )
 ECC_encoding_inst               
                (
                 .ecc_enc_clk        ( MEM_ctrl_clk              )           ,
                 .ecc_enc_rstn       ( MEM_ctrl_rstn             )           ,
                 .ecc_enc_sw_rst     ( MEM_ctrl_sw_rst           )           ,
                                
                 .ECC_en             ( ECC_en_w                  )           ,
                 
                 .wr_en_i            ( MEM_ctrl_wr_en_w          )           ,
                 .wr_addr_i          ( MEM_ctrl_wr_addr_bus_w    )           ,
                 .wr_strobe          ( MEM_ctrl_wr_strobe        )           ,
                 .data_in            ( MEM_ctrl_write_data_bus   )           ,
                             
                 .wr_en_o            ( BRAM_wr_en_w              )           ,
                 .wr_addr_o          ( wr_addr_w                 )           ,
                 .encoded_data       ( BRAM_wr_data_w            )   
                 );
//-------------------------------------------------------------------------------------------


//------------------ECC_DECODING INSTANTIATION-----------------------------------------------
ECC_decoding 
               #( 
                 .DATA_WIDTH         ( DATA_WIDTH                )           ,
                 .ADDR_WIDTH         ( ADDR_WIDTH                )           ,
                 .MEMORY_DATA_WIDTH  ( MEMORY_DATA_WIDTH         )           ,
                 .REG_ADDR_WIDTH     ( REG_ADDR_WIDTH            )           ,
                 .PARITY_BITS        ( PARITY_BITS               )
                )
ECC_decoding_inst               
                (
                 .ECC_decoding_clk     ( MEM_ctrl_clk              )           ,
                 .ECC_decoding_rstn    ( MEM_ctrl_rstn             )           ,
                 .ECC_decoding_sw_rst  ( MEM_ctrl_sw_rst           )           ,
                  
                 .ECC_en               ( ECC_en_w                  )           ,
                    
                 .ECC_irq_en           ( ECC_irq_en_w              )           ,

                 .rd_en_i              ( MEM_ctrl_rd_en_w          )           ,
                 .rd_addr_i            ( MEM_ctrl_rd_addr_bus_w    )           ,
                 .rd_data_i            ( BRAM_rd_data              )           ,

                 .rd_en_o              ( BRAM_rd_en                )           ,
                 .rd_addr_o            ( rd_addr_w                 )           ,
                 
                 .rd_data_o            ( MEM_ctrl_data_out_w       )           ,
                 .data_valid           ( data_valid_w              )           ,
                 .error_type           ( ECC_status_w              )           ,
                 .ECC_interrupt        ( ECC_interrupt             )           ,
                 .i_psel               ( i_psel_w                  )           ,   
                 .i_penable            ( i_penable_w               )           ,
                 .i_paddr              ( i_paddr_w                 )           ,
                 .i_pwrite             ( i_pwrite_w                )           ,
                 .i_pstrb              ( i_pstrb_w                 )
                );
//-------------------------------------------------------------------------------------------


//--------MEMORY CONTROLLER CSR REGISTERS FILE INSTANTIATION---------------------------------
CSR_registers CSR_registers_inst
                (
                 .i_clk                             ( MEM_ctrl_clk                   )       ,              
                 .i_rst_n                           ( MEM_ctrl_rstn                  )       ,

                 .i_psel                            ( i_psel_w2                      )       ,
                 .i_penable                         ( i_penable_w2                   )       ,
                 .i_paddr                           ( i_paddr_w2                     )       ,
                 .i_pprot                           (                                )       ,
                 .i_pwrite                          ( i_pwrite_w2                    )       ,
                 .i_pstrb                           ( i_pstrb_w2                     )       ,
                 .i_pwdata                          ( i_pwdata_w2                    )       ,
                 .o_pready                          (                                )       ,
                 .o_prdata                          (                                )       ,
                 .o_pslverr                         (                                )       ,

                 .i_ECC_STAUS_REG_ECC_STATUS_clear  (i_ECC_STAUS_REG_ECC_STATUS_clear)       ,
                 .o_ECC_STAUS_REG_ECC_STATUS        (o_ECC_STAUS_REG_ECC_STATUS      )       ,
                 .o_ECC_EN_IRQ_REG_ECC_EN_IRQ_REG   ( ECC_irq_en_w                   )       ,
                 .o_ECC_ONOFF_REG_ECC_ONOFF_REG     ( ECC_en_w                       )       ,
                 .o_CE_CNT_REG_CE_CNT_REG           (                                )       ,
                 .i_CE_FFD_REG_CE_FFD_REG           (                                )       ,
                 .i_CE_FFE_REG_CE_FFE_REG           (                                )       ,
                 .i_UE_FFE_REG_UE_FFE_REG           (                                )       ,
                 .i_UE_FFD_REG_UE_FFD_REG           (                                )
                );
//-------------------------------------------------------------------------------------------
                
endmodule                




