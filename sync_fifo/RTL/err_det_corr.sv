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
* File Name : err_det_corr.sv

* Purpose :

* Creation Date : 09-10-2023

* Last Modified : Thu 19 Oct 2023 02:19:02 PM IST

* Created By :  

////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
module err_det_corr#(
                     parameter DATA_WIDTH        = 32                                     ,
                     parameter MEMORY_DATA_WIDTH = 39                                     ,
                     parameter REG_ADDR_WIDTH    = 10                                     ,
                     parameter PARITY_BITS       = 6                                       
                    )
                    (                     
                     input   logic    [DATA_WIDTH-1:0]                ECC_en                ,
                     input   logic    [DATA_WIDTH-1:0]                ECC_irq_en            ,

                     input   logic                                    rd_en                 ,
                     input   logic    [MEMORY_DATA_WIDTH-1:0]         rd_data_i             ,
                     input   logic    [PARITY_BITS:0]                 parity_rd_in          ,

                     output  logic    [DATA_WIDTH-1:0]                rd_data_o             ,
                     output  logic                                    data_valid            ,
                     output  logic    [31:0]                          error_type            ,
                     output  logic                                    ECC_interrupt         ,

                     output  logic                                    i_psel                ,                         
                     output  logic                                    i_penable             ,
                     output  logic    [REG_ADDR_WIDTH-1:0]            i_paddr               ,
                     output  logic                                    i_pwrite              ,
                     output  logic    [3:0]                           i_pstrb               

                    );

                    //  DECLERATIONS OF INTERNAL REGISTERS AND WIRES 
                    logic   [MEMORY_DATA_WIDTH-1:0]         rd_data_r                           ;
                    logic   [MEMORY_DATA_WIDTH-1:0]         rd_data_r1                          ; 
                    logic   [MEMORY_DATA_WIDTH-1:0]         rd_data_r2                          ;
                    logic   [DATA_WIDTH-1:0]                rd_data_r3                          ;

                    logic   [PARITY_BITS-1:0]               bit_position                        ;// TO DETECT THE BIT POSITION WHICH GOT CORRUPTED 
                    logic                                   bit_swap_en                         ;// ENABLE SIGNAL TO SWAP THE BIT WHICH GOT CORRUPTED 
                    logic   [MEMORY_DATA_WIDTH-1:0]         mask                                ;// CREATING THE MASK TO BIT SWAP  

                    localparam ECC_STATUS_REG_ADDR  = 10'd0                                     ;

                    //------DETECTING THE SINGLE-BIT ERROR, DOUBLR-BIT ERROR AND NO ERROR------ 
                    always_comb                    
                    begin

                    if((ECC_en[0] == 1'b1) && rd_en)  // IF ECC IS NOT ENABLE 
                    begin
    
                        if((parity_rd_in[0]==1'b0) && (parity_rd_in[6:1]==6'd0))                // NO ERROR
                        begin
                        i_psel        =  1'b1                                          ;
                        i_penable     =  1'b1                                          ;
                        i_pwrite      =  1'b1                                          ;
                        i_paddr       =  ECC_STATUS_REG_ADDR                           ;
                        i_pstrb       =  4'b1111                                       ;

                        data_valid    =  1'b1                                          ;
                        rd_data_r     =  rd_data_i                                     ;
                        rd_data_r1    =  {MEMORY_DATA_WIDTH{1'b0}}                     ;

                        error_type    =  32'd0                                         ;
                        ECC_interrupt =  1'b0                                          ;
                        bit_position  =  6'd0                                          ;
                        bit_swap_en   =  1'b1                                          ; 
                        end
                     
                        else if((parity_rd_in[0]==1'b1) && (parity_rd_in[6:1]!=6'd0))           // DETECTING SINGLE BIT ERROR 
                        begin
                        i_psel       =  1'b1                                          ;
                        i_penable    =  1'b1                                          ;
                        i_pwrite     =  1'b1                                          ;
                        i_paddr      =  ECC_STATUS_REG_ADDR                           ;
                        i_pstrb      =  4'b1111                                       ;

                        data_valid   =  1'b1                                          ;
                        rd_data_r    =  rd_data_i                                     ;
                        rd_data_r1   =  {MEMORY_DATA_WIDTH{1'b0}}                     ;

                        ECC_interrupt=  1'b0                                          ;
                        bit_position =  parity_rd_in[6:1]                             ;
                        bit_swap_en  =  1'b1                                          ;
                        error_type   =  32'd1                                         ;
                        end

                        else if((parity_rd_in[0]==1'b0) && (parity_rd_in[6:1]!=6'd0))           // DETECTING DOUBLE BIT ERROR 
                        begin
                        i_psel       =  1'b1                                           ;
                        i_penable    =  1'b1                                           ;
                        i_pwrite     =  1'b1                                           ;
                        i_paddr      =  ECC_STATUS_REG_ADDR                            ;
                        i_pstrb      =  4'b1111                                        ;

                        data_valid   =  1'b1                                           ;
                        rd_data_r    =  {MEMORY_DATA_WIDTH{1'b0}}                      ;
                        rd_data_r1   =  {MEMORY_DATA_WIDTH{1'b0}}                      ;
                       
                        if(ECC_irq_en[0] == 1'b1)                                               // GENERATING INTERRUPT WHEN 
                            begin                                                               // WHEN DOUBLE BIT ERROR DETECTS
                            ECC_interrupt=  1'b1                                       ;
                            end
                        else
                            begin
                            ECC_interrupt =  1'b0                                      ;
                            end

                        error_type   =  32'd2                                          ;
                        bit_position =  6'd0                                           ;
                        bit_swap_en  =  1'b0                                           ;
                        end
                    
                        else 
                        begin
                        i_psel       =  1'b0                                           ;
                        i_penable    =  1'b0                                           ;
                        i_pwrite     =  1'b0                                           ;
                        i_paddr      =  ECC_STATUS_REG_ADDR                            ;
                        i_pstrb      =  4'd0                                           ;
                        
                        ECC_interrupt=  1'b0                                           ;
                        data_valid   =  1'b0                                           ;
                        rd_data_r    =  {MEMORY_DATA_WIDTH{1'b0}}                      ;
                        rd_data_r1   =  {MEMORY_DATA_WIDTH{1'b0}}                      ;
                        error_type   =  32'd0                                          ;
                        bit_position =  6'd0                                           ;
                        bit_swap_en  =  1'b0                                           ;
                        end

                    end

                    else //  IF ECC IS NOT ENABLE 
                        begin
                        i_psel       =  1'b0                                           ;
                        i_penable    =  1'b0                                           ;
                        i_pwrite     =  1'b0                                           ;
                        i_paddr      =  ECC_STATUS_REG_ADDR                            ;
                        i_pstrb      =  4'd0                                           ;

                        ECC_interrupt=  1'b0                                           ;
                        data_valid   =  1'b1                                           ;
                        rd_data_r    =  {MEMORY_DATA_WIDTH{1'b0}}                      ;
                        rd_data_r1   = {rd_data_i[38:33], 1'b0 , rd_data_i[31:17] , 1'b0 , rd_data_i[15:9] , 1'b0 , rd_data_i[7:5] , 1'b0 , rd_data_i[3], {3{1'b0}} }      ;  
                        error_type   =  32'd0                                          ;
                        bit_position =  6'd0                                           ;
                        bit_swap_en  =  1'b0                                           ;
                        end

                    end
                    //------------------------------------------------------------------
                    
                    //  CREATING MASK TO DO SWAP THE BIT
                    assign mask = 1'b1 << bit_position                                 ;

                    //  DOING BIT-SWAPING AFTER DETECTING SINGLE-BIT ERROR AND ASSIGNING TO THE REGISTER
                    assign rd_data_r2 = (bit_swap_en && ECC_en[0]==1'b1) ? (rd_data_r ^ mask) : rd_data_r1   ;  
                    assign rd_data_r3 = {rd_data_r2[38:33] , rd_data_r2[31:17] , rd_data_r2[15:9] , rd_data_r2[7:5] , rd_data_r2[3]} ;

                    //ASSIGNING TO THE OUTPUT
                    assign rd_data_o = rd_data_r3                                                                                   ;
                    
endmodule                    
