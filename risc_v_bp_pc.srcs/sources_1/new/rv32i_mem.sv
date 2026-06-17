`timescale 1ns / 1ps

module rv32i_mem import rv32i_pkg ::*;(
    input ex_mem_reg mem_in,
    input stall,
    input flush,
    input clk,
    
    output mem_wb_reg mem_out
    );
    
    wire [31:0] mem_data_out;
    
    rv32i_main_mem main_mem_inst (.clk(clk),.we(mem_in.mem_write & mem_in.valid),.addr(mem_in.alu_out),.wd(mem_in.store_data),.rd(mem_data_out));
    
    
    always_ff @(posedge clk)begin
        if(flush )begin
        
            mem_out<='0;
        
        end
        else if(stall)begin
        
            mem_out<=mem_out;
        
        end
        else begin
        mem_out.reg_write<=mem_in.reg_write;
        mem_out.pc_plus_4<=mem_in.pc_plus_4;
        mem_out.pc_plus_imm<=mem_in.pc_plus_imm;
         mem_out.alu_out<=mem_in.alu_out;
           mem_out.main_mem_out<=mem_data_out;
           mem_out.rd<=mem_in.rd;
           mem_out.valid<=mem_in.valid;
           mem_out.result_src<=mem_in.result_src;
    
    end
    
    
    
    
    
    
    
    end
    
    
    
    
    
    
    
endmodule
