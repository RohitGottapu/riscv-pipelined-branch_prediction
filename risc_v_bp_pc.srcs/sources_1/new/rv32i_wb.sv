`timescale 1ns / 1ps
// this is purely combinational logic 
module rv32i_wb import rv32i_pkg::*;(
    input  mem_wb_reg   wb_in,
    
    
    output logic        reg_write,
    output logic [31:0] data,
    output logic [4:0]  rd
);

    // 1. Pass the destination register back to the Decode stage
    assign rd = wb_in.rd;

    // 2. Safety Guard: Only write to the register if the instruction is valid
    assign reg_write = wb_in.reg_write & wb_in.valid;

    // 3. The 4-to-1 Multiplexer (Pure Combinational)
    always_comb begin
        case(wb_in.result_src)
            2'b00:   data = wb_in.alu_out;
            2'b01:   data = wb_in.main_mem_out;
            2'b10:   data = wb_in.pc_plus_4;
            2'b11:   data = wb_in.pc_plus_imm;
            default: data = 32'h00000000;
        endcase
    end

endmodule