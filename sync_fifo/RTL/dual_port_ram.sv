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
* File Name : single_port_ram.sv

* Purpose :

* Creation Date : 16-10-2023

* Last Modified : Mon 04 Dec 2023 04:26:08 PM IST

* Created By :  

////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
module dual_port_ram
                   #(
                     parameter MEMORY_DATA_WIDTH = 39                              ,
                     parameter ADDR_WIDTH        = 14                              ,
                     parameter DEPTH             = 1<<ADDR_WIDTH
                    )
                    (
                     //             RAM SIGNALS
                     input   logic                          RAM_clk             ,
                     input   logic                          RAM_rstn            ,
                     
                     input   logic                          RAM_en              ,

                     input   logic                          RAM_wr_en           ,
                     input   logic [ADDR_WIDTH-1:0]         RAM_wr_addr         ,
                     input   logic [MEMORY_DATA_WIDTH-1:0]  RAM_wr_data         ,

                     input   logic                          RAM_rd_en           ,
                     input   logic [ADDR_WIDTH-1:0]         RAM_rd_addr         ,                     
                     output  logic [MEMORY_DATA_WIDTH-1:0]  RAM_rd_data         
                    );

                    //          DECLARING AN INTERNAL MEMORY 
                    logic [MEMORY_DATA_WIDTH-1:0] int_ram [0:DEPTH-1]              ;

                    //----------WRITING OPERATION OF THE INTERNAL MEMORY-------  
                    always_ff@(posedge RAM_clk)
                    begin
                   
                   if(RAM_wr_en)
                        begin
                        int_ram[RAM_wr_addr]    <=  RAM_wr_data                              ;          
                        //int_ram[RAM_wr_addr+1]  <=  RAM_wr_data[15:8]                      ;          
                        //int_ram[RAM_wr_addr+2]  <=  RAM_wr_data[23:16]                     ;          
                        //int_ram[RAM_wr_addr+3]  <=  RAM_wr_data[31:24]                     ;          
                        end
                  
                    end
                    //----------------------------------------------------------------------
                    
                    //-------READING OPERATION OF THE INTERNAL MEMORY-------------
                    always_ff@(posedge RAM_clk or negedge RAM_rstn)
                    begin
                   
                    if(!RAM_rstn)
                        begin
                        RAM_rd_data        <=  {MEMORY_DATA_WIDTH{1'b0}}           ;
                        end

                    else if(RAM_rd_en)
                        begin
                        RAM_rd_data        <=  int_ram[RAM_rd_addr]                ;
                        end 
                     
                    else 
                        begin
                        RAM_rd_data        <=  {MEMORY_DATA_WIDTH{1'b0}}           ;
                        end

                    end
                    //----------------------------------------------------------------------


endmodule                    


