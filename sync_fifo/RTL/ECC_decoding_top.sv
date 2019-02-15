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
* File Name : ECC_decoding.sv

* Purpose :

* Creation Date : 09-10-2023

* Last Modified : Wed 15 Nov 2023 04:55:35 PM IST

* Created By :  

////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

module ECC_decoding#(
                     parameter DATA_WIDTH        = 32                                     ,
                     parameter MEMORY_DATA_WIDTH = 39                                     ,            
                     parameter ADDR_WIDTH        = 5                                      ,
                     parameter REG_ADDR_WIDTH    = 10                                     ,
                     parameter PARITY_BITS       = 6                                       
                    )
                    (
                     input  logic                                ECC_decoding_clk       ,
                     input  logic                                ECC_decoding_rstn      ,
                     input  logic                                ECC_decoding_sw_rst    ,

                     input  logic  [DATA_WIDTH-1:0]              ECC_en                 ,

                     input  logic  [DATA_WIDTH-1:0]              ECC_irq_en             ,

                     input  logic                                rd_en_i                ,
                     input  logic  [ADDR_WIDTH-1:0]              rd_addr_i              ,
                     input  logic  [MEMORY_DATA_WIDTH-1:0]       rd_data_i              ,

                     output logic                                rd_en_o                ,
                     output logic  [ADDR_WIDTH-1:0]              rd_addr_o              ,
                     output logic  [DATA_WIDTH-1:0]              rd_data_o              ,
                     output logic                                data_valid             ,
 
                     output logic  [31:0]                        error_type             ,
                     output logic                                ECC_interrupt          ,
                     output logic                                i_psel                 ,                         
                     output logic                                i_penable              ,
                     output logic  [9:0]                         i_paddr                ,
                     output logic                                i_pwrite               ,
                     output logic  [3:0]                         i_pstrb
                    );

//      INTERNALLY DECLARED SIGNALS 
logic   [DATA_WIDTH-1:0]                rd_data_dec_w                 ;
logic   [PARITY_BITS:0]                 parity_dec_w                  ;

logic   [MEMORY_DATA_WIDTH-1:0]         rd_data_w2                    ;
logic   [MEMORY_DATA_WIDTH-1:0]         rd_data_w                     ;
logic   [PARITY_BITS:0]                 parity_bits_w                 ;
logic                                   rd_en_w                       ;

logic   [ADDR_WIDTH-1:0]                rd_addr_w                     ;
logic   [ADDR_WIDTH-1:0]                rd_addr_w1                    ;


//----ASSIGNING READ ENABLE AND READ ADDRESS---------------------------
assign rd_en_o    =  rd_en_i                                          ;

assign rd_addr_w  =  {rd_addr_i[31:2],{2'd0}}                         ;
assign rd_addr_w1 =  rd_addr_w >> 2'd2                                ;
assign rd_addr_o  =  rd_addr_w1                                       ;
//---------------------------------------------------------------------

//----LOGIC FOR GENERATING READ STROBE---------------------------------
/*
always_ff@(posedge ECC_decoding_clk or negedge ECC_decoding_rstn)
begin
if(!ECC_decoding_rstn)
    begin
    rd_data_w2   <= {(MEMORY_DATA_WIDTH){1'b0}}           ; 
    end
else if(ECC_decoding_sw_rst)
    begin
    rd_data_w2   <= {(MEMORY_DATA_WIDTH){1'b0}}           ; 
    end
else
    begin
    rd_data_w2 <= rd_data_w                               ;
    end
end
*/
//--------------------------------------------------------------------

//----------------DATA DECODING MODULE INSTANTIATION------------------
data_decoding 
                   #( 
                     .DATA_WIDTH           ( DATA_WIDTH             )    ,
                     .PARITY_BITS          ( PARITY_BITS            )    ,
                     .MEMORY_DATA_WIDTH    ( MEMORY_DATA_WIDTH      )
                    )
data_decoding_inst                   
                    (
                     .rd_data_i             ( rd_data_i             )    ,  
                                 
                     .rd_data_o             ( rd_data_w             )    ,
                     .parity_dec_o          ( parity_dec_w          )    ,
                     .rd_data_dec           ( rd_data_dec_w         )
                    );
//--------------------------------------------------------------------             

//----------------PARITY CALCULATION MODULE INSTANTIATION-------------
parity_calc_rd  
                   #( 
                     .DATA_WIDTH            ( DATA_WIDTH            )    ,
                     .PARITY_BITS           ( PARITY_BITS           )
                    )
parity_calc_rd_inst                   
                    (
                     .parity_calc_rd_clk    ( ECC_decoding_clk      )    ,  
                     .parity_calc_rd_rstn   ( ECC_decoding_rstn     )    ,
                     .parity_calc_sw_rst    ( ECC_decoding_sw_rst   )    ,
                                        
                     .rd_en_i               ( rd_en_i               )    ,
                     .ECC_en                ( ECC_en                )    ,
                                        
                     .parity_in_rd          ( parity_dec_w          )    ,                                
                     .rd_data_i             ( rd_data_dec_w         )    ,
                                                       
                     .rd_en_r               ( rd_en_w               )    ,                   
                     .parity_out_rd         ( parity_bits_w         ) 
                    );
//--------------------------------------------------------------------                    

//-----------ERROR DETECTION AND CORRECTION MODULE INSTANTIATION------
err_det_corr 
                   #( 
                      .DATA_WIDTH           ( DATA_WIDTH         )    ,
                      .MEMORY_DATA_WIDTH    ( MEMORY_DATA_WIDTH  )    ,
                      .REG_ADDR_WIDTH       ( REG_ADDR_WIDTH     )    ,
                      .PARITY_BITS          ( PARITY_BITS        )
                    )
err_det_corr_inst                   
                    (                                        
                     .rd_data_i             ( rd_data_w          )    ,  
                     .parity_rd_in          ( parity_bits_w      )    ,
                     .ECC_en                ( ECC_en             )    ,
                    
                     .ECC_irq_en            ( ECC_irq_en         )    ,

                     .rd_en                 ( rd_en_w            )    ,
                     .rd_data_o             ( rd_data_o          )    ,
                     .data_valid            ( data_valid         )    ,

                     .error_type            ( error_type         )    ,
                     .ECC_interrupt         ( ECC_interrupt      )    ,

                     .i_psel                ( i_psel             )    , 
                     .i_penable             ( i_penable          )    ,
                     .i_paddr               ( i_paddr            )    ,
                     .i_pwrite              ( i_pwrite           )    ,
                     .i_pstrb               ( i_pstrb            )    
                    ); 
//-----------------------------------------------------------------                    

endmodule                    
