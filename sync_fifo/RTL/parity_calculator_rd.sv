/////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
* File Name : err_corec_dec.sv

* Purpose :

* Creation Date : 06-10-2023

* Last Modified : Mon 04 Dec 2023 04:16:47 PM IST

* Created By :  

////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
module parity_calc_rd #(
                        parameter   DATA_WIDTH  =  32                                         ,
                        parameter   PARITY_BITS =  6                                          
                       )
                      (
                      input   logic                                   parity_calc_rd_clk      ,
                      input   logic                                   parity_calc_rd_rstn     ,
                      input   logic                                   parity_calc_sw_rst      ,

                      input   logic                                   rd_en_i                 ,                      
                      input   logic  [DATA_WIDTH-1:0]                 ECC_en                  ,

                      input   logic  [PARITY_BITS:0]                  parity_in_rd            ,  

                      input   logic  [DATA_WIDTH-1:0]                 rd_data_i               ,
                                    
                      output  logic                                   rd_en_r                 ,
                      output  logic  [PARITY_BITS:0]                  parity_out_rd           
                      );

                      logic                     rd_en           ;
                      logic                     rd_en_r1        ;

                      //-----------LOGIC FOR GENERATING READ ENABLE SIGNAL----------------- 
                      always_ff@(posedge parity_calc_rd_clk or negedge parity_calc_rd_rstn)
                      begin
                      if(!parity_calc_rd_rstn)
                          begin
                          rd_en    <= 1'b0                             ;
                          rd_en_r1 <= 1'b0                             ;
                          rd_en_r  <= 1'b0                             ;
                          end

                      else if(parity_calc_sw_rst) 
                          begin
                          rd_en    <= 1'b0                             ;
                          rd_en_r1 <= 1'b0                             ;
                          rd_en_r  <= 1'b0                             ;
                          end

                      else 
                          begin
                          rd_en    <= rd_en_i                           ;
                          rd_en_r  <= rd_en                             ;
                          rd_en_r1 <= rd_en_r                           ;
                          end
                      end
                      //---------------------------------------------------------------------

                      //----------CALCULATING THE PARITY FOR THE READ DATA-------------------
                      always_ff@(posedge parity_calc_rd_clk or negedge parity_calc_rd_rstn)
                      begin

                      if(!parity_calc_rd_rstn)
                          begin
                          parity_out_rd     <=      {(PARITY_BITS+1){1'b0}}                 ;                    
                          end
                      
                      else if(parity_calc_sw_rst)
                          begin
                          parity_out_rd     <=      {(PARITY_BITS+1){1'b0}}                 ;                    
                          end

                      else if(rd_en)
                          begin
                    
                                if((ECC_en[0]==1'b1))   //  IF ECC ENABLE IS SET    
                                begin

                                parity_out_rd[1] <= (
                                               rd_data_i[0]  ^ rd_data_i[1]  ^
                                               rd_data_i[3]  ^ rd_data_i[4]  ^
                                               rd_data_i[6]  ^ rd_data_i[8]  ^
                                               rd_data_i[10] ^ rd_data_i[11] ^
                                               rd_data_i[13] ^ rd_data_i[15] ^
                                               rd_data_i[17] ^ rd_data_i[19] ^
                                               rd_data_i[21] ^ rd_data_i[23] ^
                                               rd_data_i[25] ^ rd_data_i[26] ^
                                               rd_data_i[28] ^ rd_data_i[30] ^
                                               parity_in_rd[1]
                                              )                                               ;


                                parity_out_rd[2] <= (
                                               rd_data_i[0]  ^ rd_data_i[2]  ^
                                               rd_data_i[3]  ^ rd_data_i[5]  ^
                                               rd_data_i[6]  ^ rd_data_i[9]  ^
                                               rd_data_i[10] ^ rd_data_i[12] ^
                                               rd_data_i[13] ^ rd_data_i[16] ^
                                               rd_data_i[17] ^ rd_data_i[20] ^
                                               rd_data_i[21] ^ rd_data_i[24] ^
                                               rd_data_i[25] ^ rd_data_i[27] ^
                                               rd_data_i[28] ^ rd_data_i[31] ^
                                               parity_in_rd[2]
                                              )                                              ;


                                parity_out_rd[3] <= (
                                               rd_data_i[1]  ^ rd_data_i[2]  ^
                                               rd_data_i[3]  ^ rd_data_i[7]  ^
                                               rd_data_i[8]  ^ rd_data_i[9]  ^
                                               rd_data_i[10] ^ rd_data_i[14] ^
                                               rd_data_i[15] ^ rd_data_i[16] ^
                                               rd_data_i[17] ^ rd_data_i[22] ^
                                               rd_data_i[23] ^ rd_data_i[24] ^
                                               rd_data_i[25] ^ rd_data_i[29] ^
                                               rd_data_i[30] ^ rd_data_i[31] ^
                                               parity_in_rd[3]
                                              )                                              ;


                                parity_out_rd[4] <= (
                                               rd_data_i[4]  ^ rd_data_i[19]  ^
                                               rd_data_i[5]  ^ rd_data_i[20]  ^
                                               rd_data_i[6]  ^ rd_data_i[21]  ^
                                               rd_data_i[7]  ^ rd_data_i[22]  ^
                                               rd_data_i[8]  ^ rd_data_i[23]  ^
                                               rd_data_i[9]  ^ rd_data_i[24]  ^
                                               rd_data_i[10] ^ rd_data_i[25]  ^
                                               rd_data_i[18] ^ parity_in_rd[4]                                      
                                              )                                              ;


                                parity_out_rd[5] <= (
                                               rd_data_i[11]  ^ rd_data_i[19]  ^
                                               rd_data_i[12]  ^ rd_data_i[20]  ^
                                               rd_data_i[13]  ^ rd_data_i[21]  ^
                                               rd_data_i[14]  ^ rd_data_i[22]  ^
                                               rd_data_i[15]  ^ rd_data_i[23]  ^
                                               rd_data_i[16]  ^ rd_data_i[24]  ^
                                               rd_data_i[17]  ^ rd_data_i[25]  ^
                                               rd_data_i[18]  ^ parity_in_rd[5] 
                                              )                                             ;


                                parity_out_rd[6] <= (
                                               rd_data_i[26]  ^ rd_data_i[29]  ^
                                               rd_data_i[27]  ^ rd_data_i[30]  ^
                                               rd_data_i[28]  ^ rd_data_i[31]  ^
                                               parity_in_rd[6]
                                              )                                             ;
        

                                parity_out_rd[0] <= (
                                               rd_data_i[0]       ^ rd_data_i[16]     ^
                                               rd_data_i[1]       ^ rd_data_i[17]     ^
                                               rd_data_i[2]       ^ rd_data_i[18]     ^
                                               rd_data_i[3]       ^ rd_data_i[19]     ^
                                               rd_data_i[4]       ^ rd_data_i[20]     ^
                                               rd_data_i[5]       ^ rd_data_i[21]     ^
                                               rd_data_i[6]       ^ rd_data_i[22]     ^
                                               rd_data_i[7]       ^ rd_data_i[23]     ^
                                               rd_data_i[8]       ^ rd_data_i[24]     ^
                                               rd_data_i[9]       ^ rd_data_i[25]     ^
                                               rd_data_i[10]      ^ rd_data_i[26]     ^
                                               rd_data_i[11]      ^ rd_data_i[27]     ^
                                               rd_data_i[12]      ^ rd_data_i[28]     ^
                                               rd_data_i[13]      ^ rd_data_i[29]     ^
                                               rd_data_i[14]      ^ rd_data_i[30]     ^
                                               rd_data_i[15]      ^ rd_data_i[31]     ^        
                                               parity_in_rd[0]    ^ parity_in_rd[4]   ^
                                               parity_in_rd[1]    ^ parity_in_rd[5]   ^
                                               parity_in_rd[2]    ^ parity_in_rd[6]   ^
                                               parity_in_rd[3]
                                              )                                           ;
                       
                                end
                      
                                else 
                                begin
                                parity_out_rd     <=      {(PARITY_BITS+1){1'b0}}             ;
                                end

                      end

                      else  // IF ECC ENABLE IS NOT SET 
                          begin
                          parity_out_rd     <=      {(PARITY_BITS+1){1'b0}}                 ;                     
                          end

                      end
                      //--------------------------------------------------------------------

endmodule                       
