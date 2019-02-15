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
* File Name : parity_calculator.sv

* Purpose :

* Creation Date : 06-10-2023

* Last Modified : Thu 09 Mar 2023 06:23:03 PM IST

* Created By :  

////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
module parity_calculator  
                   #(
                      parameter DATA_WIDTH    =  32                               ,
                      parameter ADDR_WIDTH    =  5                                ,
                      parameter PARITY_BITS   =  6                                
                   )
                   (
                   input   logic   [DATA_WIDTH-1:0]                 ECC_en        ,

                   input   logic                                    wr_en_i       ,
                   input   logic   [ADDR_WIDTH-1:0]                 wr_addr_i     ,                   
                   input   logic   [DATA_WIDTH-1:0]                 data_in       ,
                   input   logic   [3:0]                            wr_strobe     ,

                   output  logic                                    wr_en_o       ,
                   output  logic   [PARITY_BITS:1]                  parity_out    ,
                   output  logic   [ADDR_WIDTH-1:0]                 wr_addr_o     ,
                   output  logic   [DATA_WIDTH-1:0]                 data_out                                            
                   );

                   logic    [DATA_WIDTH-1:0]    data_in_r           ;
                   logic                        str_flag            ;
                   //---------DATA SELECTING BASED ON STROBE VALUE-------------------------- 
                   always_comb
                   begin
                   str_flag=1'b1;                

                   if(wr_strobe == 4'b0001)        // BYTE 
                       begin
                       data_in_r = {24'd0,data_in[7:0]}     ;
                       end

                   else if(wr_strobe == 4'b0010)    // BYTE
                       begin
                       data_in_r = {16'd0,data_in[15:8],8'd0}     ;
                       end

                   else if(wr_strobe == 4'b0100)    // BYTE
                       begin
                       data_in_r = {8'd0,data_in[23:16],16'd0}     ;
                       end
                   
                   else if(wr_strobe == 4'b1000)    // BYTE
                       begin
                       data_in_r = {data_in[31:24],24'd0}     ;
                       end
                   

                   else if(wr_strobe == 4'b0011)   // HALF WORD  
                       begin
                       data_in_r = {16'd0,data_in[15:0]}    ;
                       end

                   else if (wr_strobe == 4'b0110)  // HALF WORD
                       begin
                       data_in_r = {8'd0,data_in[23:8],8'd0}    ;
                       end

                   else if (wr_strobe == 4'b1100) // HALF WORD
                       begin
                       data_in_r = {data_in[31:16],8'd0}    ;
                       end

                   else if(wr_strobe == 4'b1111)   // FULL WORD    
                       begin
                       data_in_r = data_in                  ;
                       end
                   
                   
                       
                   else 
                       begin
                       str_flag=1'b0;
                       data_in_r = {DATA_WIDTH{1'b0}}       ;
                       end

                   end
                   //------------------------------------------------------------------------

                   //------------PARITY(check bits) CALCULATION BLOCK------------------------ 
                   always_comb
                   begin
                   parity_out       =     {PARITY_BITS{1'b0}}         ;
                   wr_en_o          =     1'b0                        ;     
                   wr_addr_o        =     {ADDR_WIDTH{1'b0}}          ;
                   data_out         =     {DATA_WIDTH{1'b0}}          ;
                   
                   if(wr_en_i && str_flag)
                       begin

                            if((ECC_en[0]==1'b1))
                            begin

                            wr_en_o       = wr_en_i                            ;
                            wr_addr_o     = wr_addr_i                          ;
                            data_out      = data_in_r                          ;

                            parity_out[1] = (
                                              data_in_r[0]  ^ data_in_r[1]  ^
                                              data_in_r[3]  ^ data_in_r[4]  ^
                                              data_in_r[6]  ^ data_in_r[8]  ^
                                              data_in_r[10] ^ data_in_r[11] ^
                                              data_in_r[13] ^ data_in_r[15] ^
                                              data_in_r[17] ^ data_in_r[19] ^
                                              data_in_r[21] ^ data_in_r[23] ^
                                              data_in_r[25] ^ data_in_r[26] ^
                                              data_in_r[28] ^ data_in_r[30] 
                                             )                                   ;


                            parity_out[2] = (
                                              data_in_r[0]  ^ data_in_r[2]  ^
                                              data_in_r[3]  ^ data_in_r[5]  ^
                                              data_in_r[6]  ^ data_in_r[9]  ^
                                              data_in_r[10] ^ data_in_r[12] ^
                                              data_in_r[13] ^ data_in_r[16] ^
                                              data_in_r[17] ^ data_in_r[20] ^
                                              data_in_r[21] ^ data_in_r[24] ^
                                              data_in_r[25] ^ data_in_r[27] ^
                                              data_in_r[28] ^ data_in_r[31]
                                             )                                  ;


                            parity_out[3] = (
                                              data_in_r[1]  ^ data_in_r[2]  ^
                                              data_in_r[3]  ^ data_in_r[7]  ^
                                              data_in_r[8]  ^ data_in_r[9]  ^
                                              data_in_r[10] ^ data_in_r[14] ^
                                              data_in_r[15] ^ data_in_r[16] ^
                                              data_in_r[17] ^ data_in_r[22] ^
                                              data_in_r[23] ^ data_in_r[24] ^
                                              data_in_r[25] ^ data_in_r[29] ^
                                              data_in_r[30] ^ data_in_r[31]
                                             )                                  ;


                            parity_out[4] = (
                                              data_in_r[4]  ^ data_in_r[19]  ^
                                              data_in_r[5]  ^ data_in_r[20]  ^
                                              data_in_r[6]  ^ data_in_r[21]  ^
                                              data_in_r[7]  ^ data_in_r[22]  ^
                                              data_in_r[8]  ^ data_in_r[23]  ^
                                              data_in_r[9]  ^ data_in_r[24]  ^
                                              data_in_r[10] ^ data_in_r[25]  ^
                                              data_in_r[18]                                        
                                             )                                  ;


                            parity_out[5] = (
                                              data_in_r[11]  ^ data_in_r[19]  ^
                                              data_in_r[12]  ^ data_in_r[20]  ^
                                              data_in_r[13]  ^ data_in_r[21]  ^
                                              data_in_r[14]  ^ data_in_r[22]  ^
                                              data_in_r[15]  ^ data_in_r[23]  ^
                                              data_in_r[16]  ^ data_in_r[24]  ^
                                              data_in_r[17]  ^ data_in_r[25]  ^
                                              data_in_r[18]
                                             )                                  ;


                            parity_out[6] = (
                                              data_in_r[26]  ^ data_in_r[29]  ^
                                              data_in_r[27]  ^ data_in_r[30]  ^
                                              data_in_r[28]  ^ data_in_r[31]
                                             )                                  ;
                            end

                            else
                            begin
                            parity_out       =     {PARITY_BITS{1'b0}}        ;
                            data_out         =     data_in_r                  ;
                            wr_en_o          =     wr_en_i                    ;
                            wr_addr_o        =     wr_addr_i                  ;
                            end
                   end

                   else
                       begin
                       parity_out       =     {PARITY_BITS{1'b0}}        ;
                       data_out         =     {DATA_WIDTH{ 1'b0}}        ;
                       wr_en_o          =     1'd0                       ;
                       wr_addr_o        =     wr_addr_i                  ;
                       end
                   end                
                   //---------------------------------------------------------------------

endmodule                    

