`timescale 1ns / 1ps
// this is mix of seq and combinational block
// what does this do: it joins all the submodule in ID stage and communicates data with other stages

module rv32i_id import rv32i_pkg::*;(
       input logic clk,
       input logic rst,
       input if_id_reg  id_in_pkg,
       input logic [31:0] write_data_wb,
       input logic wb_reg_write_en,
       input logic [4:0] wb_rd,
//       input logic mem_write_ex, // this is for hazard detection load - use harzard 
       input logic flush,
       input logic stall,
       output id_ex_reg id_out_pkg
//       output hazard_stall 
    );
    
    // wires needed for reg file
    wire logic [4:0] rs1,rs2,rd;
    wire logic reg_write_en;
    wire logic [31:0] data1,data2;
    
    // decoder
    wire logic [31:0]instr;
    wire logic mem_write,alu_mux_control,alu_operation;
    wire logic branch,jump,illegal_instr;
    wire logic [1:0] result_src; // this is for the mux before the write address
    
    //imm_gen
    wire logic [31:0] imm;
    
    
    rv32i_regfile reg_file_inst (.clk(clk),.write_en(wb_reg_write_en),.rs1(rs1),.rs2(rs2),.rd(wb_rd),.write_data(write_data_wb),.data1(data1),.data2(data2));
    
    rv32i_decoder decoder_inst (.instr(instr),.mem_write(mem_write),.reg_write(reg_write_en),.alu_mux_control(alu_mux_control),.alu_operation(alu_operation),.branch(branch),.jump(jump),
                              .illegal_instr(illegal_instr),.result_src(result_src));
    
    rv32i_imm_gen imm_gen_inst (.instr(instr),.imm(imm));
    
    
    //parse the input package
    assign instr=id_in_pkg.instr;
    assign rd=instr[11:7];
    assign rs1=instr[19:15];
    assign rs2=instr[24:20];
    // hazard det
//    assign hazard_stall=(~mem_write_ex & ((rs1==wb_rd)||(rs2==wb_rd));
    
    // filling the output package
    
    
   always_ff @(posedge clk) begin
        if (rst) begin
            id_out_pkg <= '0; 
        end 
       
        else if (flush) begin
            id_out_pkg <= '0;         // Insert NOP
        end
         else if (stall) begin
            id_out_pkg <= id_out_pkg; // Hold state
        end
        else if (id_in_pkg.valid & ~illegal_instr) begin
            // Pack Control Signals
            id_out_pkg.reg_write   <= reg_write_en;
            id_out_pkg.result_src  <= result_src;
            id_out_pkg.mem_write   <= mem_write;
            id_out_pkg.jump        <= jump;
            id_out_pkg.branch      <= branch;
            id_out_pkg.alu_src     <= alu_mux_control;
            id_out_pkg.alu_control <= alu_operation; 
            
            // INDEPENDENT Forwarding Logic for rd1 and rd2
            id_out_pkg.rd1 <= data1;
            id_out_pkg.rd2 <= data2;
            
            id_out_pkg.imm         <= imm;
            id_out_pkg.pc          <= id_in_pkg.pc;
            id_out_pkg.pc_plus_4   <= id_in_pkg.pc + 32'd4;
            
//            id_out_pkg.opcode      <= instr[6:0];
            id_out_pkg.funct3      <= instr[14:12];
            id_out_pkg.rs1         <= rs1;
            id_out_pkg.rs2         <= rs2;
            id_out_pkg.rd          <= rd;
            
            id_out_pkg.predicted_taken  <= id_in_pkg.predicted_taken;
            id_out_pkg.btb_hit_wire     <= id_in_pkg.btb_hit_wire;
            id_out_pkg.predicted_target <= id_in_pkg.predicted_target;
            id_out_pkg.bhr_snapshot     <= id_in_pkg.bhr_snapshot;
            id_out_pkg.valid            <= 1'b1;
        end 
        else begin
            id_out_pkg <= '0;
        end
    end
    
endmodule
