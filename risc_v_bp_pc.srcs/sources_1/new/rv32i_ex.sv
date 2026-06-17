`timescale 1ns / 1ps


module rv32i_ex import rv32i_pkg::*;(
    input id_ex_reg ex_in,
    input clk,
    input flush,
    input stall,
    
    input  wire       ex_mem_reg_write,
    input  wire [4:0] ex_mem_rd,
    
    // Inputs from the MEM/WB Stage (2 steps ahead)
    input  wire       mem_wb_reg_write,
    input  wire [4:0] mem_wb_rd,
    input [31:0] ex_mem_alu_out_fw,
    input [31:0] mem_wb_data_fw,   
    
    
    
    output ex_mem_reg ex_out,
    
    output wire        misprediction,
    output wire        eval_flush,        // Renamed to avoid input 'flush' collision
    output wire [31:0] eval_pc,           // The PC sent to predictors for training
    output wire [31:0] correct_target_pc,
    output wire        write_en,
    output wire        taken_ground_truth,
    output wire        predicted_taken_gshare,
    output wire        train_en,
    output wire [7:0]  correct_bhr
    
    
    );
    
     wire [31:0] alu_out;
    // generating actually taken signal
    // these will go the inputs of subtractors which will be used for generation of actually_taken --> condition met signal
    //rs1,rs2, are address
    wire [1:0] forward_a,forward_b;
    rv32i_forwarding_unit feed_forward_inst (.id_ex_rs1(ex_in.rs1),.id_ex_rs2(ex_in.rs2),.ex_mem_reg_write(ex_mem_reg_write),
                                        .ex_mem_rd(ex_mem_rd),.mem_wb_reg_write(mem_wb_reg_write),. mem_wb_rd( mem_wb_rd),.forward_a(forward_a),.forward_b(forward_b));
    
    // temp_rs1 is to hold the data
    wire [31:0] temp_rs1;
    assign temp_rs1 = (forward_a == 2'b10) ? ex_mem_alu_out_fw :  // Priority 1: EX/MEM
                      (forward_a == 2'b01) ? mem_wb_data_fw    :  // Priority 2: MEM/WB
                                             ex_in.rd1;           // Default: ID/EX

   
    wire [31:0] temp_rs2;
    assign temp_rs2 = (forward_b == 2'b10) ? ex_mem_alu_out_fw :  // Priority 1: EX/MEM
                      (forward_b == 2'b01) ? mem_wb_data_fw    :  // Priority 2: MEM/WB
                                             ex_in.rd2;           // Default: ID/EX
                                             
    
   
    reg condition_met;

    //  this thing synthesizes into 6 to 1 mux , one subtractor with carry,overflow,negative output , zero flags
    always @(*) begin
        case (ex_in.funct3)
            3'b000: condition_met = (temp_rs1 == temp_rs2);                   // BEQ
            3'b001: condition_met = (temp_rs1 != temp_rs2);                   // BNE
            3'b100: condition_met = ($signed(temp_rs1) < $signed(temp_rs2));  // BLT (Signed)
            3'b101: condition_met = ($signed(temp_rs1) >= $signed(temp_rs2)); // BGE (Signed)
            3'b110: condition_met = (temp_rs1 < temp_rs2);                    // BLTU (Unsigned)
            3'b111: condition_met = (temp_rs1 >= temp_rs2);                   // BGEU (Unsigned)
            default: condition_met = 1'b0;                                    // Failsafe
        endcase
    end
    
    wire actual_taken;
    assign actual_taken = ex_in.branch & condition_met;
     wire [31:0] actual_target_pc;
     wire is_jal = ex_in.jump & ~ex_in.alu_src;
    assign actual_target_pc = (ex_in.branch || is_jal) ? (ex_in.pc + ex_in.imm) : alu_out;

    
    
    // Explicit instantiation of the branch evaluation module
    rv32i_branch_eval branch_eval_inst (
        
        // inputs tha comes from previous stage
        .jump            (ex_in.jump),
        .branch          (ex_in.branch),
        .pred_target_pc  (ex_in.predicted_target),
        .cur_pc          (ex_in.pc),
        .predicted_taken (ex_in.predicted_taken),
        .btb_hit         (ex_in.btb_hit_wire),
        .bhr             (ex_in.bhr_snapshot),
        .valid(ex_in.valid),
        //inputs that should be generated in this stage
        .actual_taken    (actual_taken),
        .actual_target_pc(actual_target_pc),
        
        
        .misprediction(eval_misprediction),
        .flush(flush_from_eval),
        .pc(eval_pc),
        .correct_target_pc(correct_target_pc),
        .write_en(write_en),
        .taken_ground_truth(taken_ground_truth),
        .predicted_taken_gshare(predicted_taken_gshare),
        .train_en(train_en),
        .correct_bhr(correct_bhr)
    );

    assign misprediction = eval_misprediction & ex_in.valid;
assign eval_flush    = flush_from_eval & ex_in.valid;
    
   
    wire [31:0] alu_operand_b;
    assign alu_operand_b = (ex_in.alu_src) ? ex_in.imm : temp_rs2;
    rv32i_alu alu_inst (.data1(temp_rs1),.data2(alu_operand_b),.alu_ctrl(ex_in.alu_control),.alu_out(alu_out));
   
    
    always_ff @(posedge clk)begin
        if(flush)begin
            ex_out<='0;
        end
        else if(stall)begin
            ex_out<=ex_out;
        
        end
        else begin
              
            // ---------------------------------------------------------
            // Control Signals (Passing through to MEM and WB)
            // ---------------------------------------------------------
            ex_out.mem_write   <= ex_in.mem_write;
            ex_out.reg_write   <= ex_in.reg_write;
            ex_out.result_src  <= ex_in.result_src;
            
            // ---------------------------------------------------------
            // Pipeline Status & Routing
            // ---------------------------------------------------------
            ex_out.valid       <= ex_in.valid;
            ex_out.rd          <= ex_in.rd;
            
            // ---------------------------------------------------------
            // Data Payloads
            // ---------------------------------------------------------
            ex_out.alu_out     <= alu_out;            // The math/address result
            ex_out.store_data  <= temp_rs2;           // The bypassed payload for SW
            ex_out.pc_plus_4   <= ex_in.pc_plus_4;    // Passed through for JAL/JALR
            ex_out.pc_plus_imm <= actual_target_pc;   // Saved for AUIPC instructions
        
        
        
        end
        
        
    
    
    
    
    
    
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
endmodule
`default_nettype wire
