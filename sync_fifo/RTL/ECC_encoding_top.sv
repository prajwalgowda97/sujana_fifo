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
* File Name : ecc_enc.sv

* Purpose :

* Creation Date : 09-10-2023

* Last Modified : Thu 19 Oct 2023 11:57:39 AM IST

* Created By :  

////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
module ECC_encoding
              #(
                parameter DATA_WIDTH        =  32                               ,
                parameter MEMORY_DATA_WIDTH =  39                               ,
                parameter ADDR_WIDTH        =  32                               ,
                parameter PARITY_BITS       =  6
               )
              (
               input   logic                                    ecc_enc_clk             ,
               input   logic                                    ecc_enc_rstn            ,
               input   logic                                    ecc_enc_sw_rst          ,

               input   logic   [DATA_WIDTH-1:0]                 ECC_en                  ,

               input   logic                                    wr_en_i                 ,
               input   logic   [ADDR_WIDTH-1:0]                 wr_addr_i               ,
               input   logic   [3:0]                            wr_strobe               ,
               input   logic   [DATA_WIDTH-1:0]                 data_in                 , 

               output  logic                                    wr_en_o                 ,
               output  logic   [ADDR_WIDTH-1:0]                 wr_addr_o               ,
               output  logic   [MEMORY_DATA_WIDTH-1:0]          encoded_data
              );

//      declerations for internal connections
logic                       wr_en_w             ;
logic  [PARITY_BITS:1]      parity_out_w        ;
logic  [ADDR_WIDTH-1:0]     wr_addr_w           ;
logic  [DATA_WIDTH-1:0]     data_w              ;


//      PARITY CALCULATOR INSTANTIATION
parity_calculator 
             #( 
                 .DATA_WIDTH    ( DATA_WIDTH      )           ,
                 .ADDR_WIDTH    ( ADDR_WIDTH      )           ,
                 .PARITY_BITS   ( PARITY_BITS     )
              )
parity_calculator_inst             
              (
                .ECC_en         ( ECC_en          )           ,
                                                  
                .wr_en_i        ( wr_en_i         )           ,
                .wr_addr_i      ( wr_addr_i       )           ,
                .wr_strobe      ( wr_strobe       )           ,
                .data_in        ( data_in         )           ,
                           
                .wr_en_o        ( wr_en_w         )           ,
                .parity_out     ( parity_out_w    )           ,
                .wr_addr_o      ( wr_addr_w       )           ,
                .data_out       ( data_w          )  
              );

//      PARITY AND DATA ENCODING MODULE INSTANTIATION
data_enc 
             #( 
                 .DATA_WIDTH       ( DATA_WIDTH        )      ,
                 .MEMORY_DATA_WIDTH( MEMORY_DATA_WIDTH )      ,
                 .ADDR_WIDTH       ( ADDR_WIDTH        )      ,
                 .PARITY_BITS      ( PARITY_BITS       )
              )
data_enc_inst             
              (
                .wr_en_i        ( wr_en_w         )           , 
                .wr_addr_i      ( wr_addr_w       )           ,
                .data_in        ( data_w          )           ,
                .parity_bits_in ( parity_out_w    )           ,
                              
                .wr_en_o        ( wr_en_o         )           ,  
                .wr_addr_o      ( wr_addr_o       )           ,
                .encoded_data   ( encoded_data    )      
              );

endmodule               
