`timescale 1ns / 1ps



module rv32i_regfile(
        input clk,
        input write_en,
        input [4:0] rs1,
        input [4:0] rs2,
        input [4:0] rd, // this is the rd of the wb stage
      
        input [31:0] write_data,
        output reg [31:0] data1, // still theya re wires
        output reg [31:0] data2
        //output valid_rs
        );
        
     reg [31:0] reg_file [31:0];
     
     
   //  reg valid [31:0];   
    // integer i;
//        initial begin
//            for(i=0;i<32;i=i+1)valid[i]=1'b0;
//        end
    integer i;
     initial begin
         reg_file[0] = 32'd0; // RISC-V x0 is ALWAYS 0
         
         for(i = 1; i < 32; i = i + 1) begin
             // $urandom generates an unsigned 32-bit random number
             reg_file[i] =0; 
         end
     end
    // for reading data
   always @(*)begin
        data1=reg_file[rs1];
        data2=reg_file[rs2];
   end
        
        
        
        // for writing data
    always @(negedge clk)begin // --> * changed from posedge to negedge clk 
            if(write_en & rd != 5'd0)reg_file[rd]<=write_data; // in risv v addr 0 is always harswired to 0
    end    
        
        
        
        
        
        
        
        
        
        
        
endmodule
