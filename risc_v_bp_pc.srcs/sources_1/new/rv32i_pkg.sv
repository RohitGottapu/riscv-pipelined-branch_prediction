`timescale 1ns / 1ps

package rv32i_pkg;


typedef struct packed {

    logic [31:0] pc;
    logic [31:0] instr;
    logic predicted_taken;
    logic btb_hit_wire;
    logic [31:0] predicted_target;
    logic [7:0] bhr_snapshot; // try variable widths
    logic valid;
} if_id_reg; // this is the type name like int for this whole data structure

typedef struct packed {
        // Control Signals (From Decoder)
        logic        reg_write;
        logic [1:0]  result_src;
        logic        mem_write;
        logic        jump;
        logic        branch;
        logic   alu_control;
        logic        alu_src;

        // Branch Prediction Tracking (Passed through from IF/ID)
        logic        predicted_taken;
        logic        btb_hit_wire;
        logic [31:0] predicted_target;
        logic [7:0]  bhr_snapshot;
        logic        valid;              // Crucial for ignoring flushed instructions

        // Data Payload
        logic [31:0] rd1;
        logic [31:0] rd2;
        logic [31:0] imm;
        logic [31:0] pc;                 // EX needs this to calculate actual target
        logic [31:0] pc_plus_4;
      
        // Instruction Sub-fields
        logic [2:0]  funct3;             // EX needs this to know if it's BEQ, BNE, BLT, etc.
//        logic [6:0] opcode;
        // Routing Addresses (For Forwarding and Writeback)
        logic [4:0]  rs1;
        logic [4:0]  rs2;
        logic [4:0]  rd;
    } id_ex_reg;
typedef struct packed {
    
        logic        reg_write;
        logic        mem_write;
        logic [1:0]  result_src;
        
        logic        valid; 
      
        
        logic [4:0]  rd;

        logic [31:0] pc_plus_4;
        logic [31:0] pc_plus_imm;
        logic [31:0] alu_out;
        logic [31:0] store_data;





}ex_mem_reg;
typedef struct packed {

        logic reg_write;
        logic [31:0] pc_plus_4;
        logic [31:0] pc_plus_imm;
        logic [31:0] alu_out;
        logic [31:0] main_mem_out;
        logic [4:0]  rd;
        logic        valid;
        logic [1:0]  result_src;



}mem_wb_reg;
endpackage:rv32i_pkg
