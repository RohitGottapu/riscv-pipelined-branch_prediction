`timescale 1ns / 1ps
// this is purely combinationla  block
module rv32i_branch_eval(
        input jump,
        input actual_taken,
        input branch,
        input [31:0] pred_target_pc,
        input [31:0] actual_target_pc,
        input [31:0] cur_pc,
        input predicted_taken,
        input btb_hit,
        input [7:0] bhr,
        input valid,
        
        output reg misprediction,
        output reg flush,
        output reg [31:0] pc, 
        output reg [31:0] correct_target_pc,
        output reg write_en,
        output reg taken_ground_truth,
        output reg predicted_taken_gshare,
        output reg train_en,
        output reg [7:0] correct_bhr
    );
    
    always @(*) begin
        
        // --------------------------------------------------------
        // 1. DEFAULT ASSIGNMENTS (The baseline state)
        // --------------------------------------------------------
        misprediction          = 1'b0;
        flush                  = 1'b0;
        pc                     = cur_pc;
        correct_target_pc      = actual_target_pc;
        write_en               = 1'b0;
        train_en               = 1'b0;
        taken_ground_truth     = 1'b0;
        predicted_taken_gshare = 1'b0;
        correct_bhr            = bhr;
        
        // --------------------------------------------------------
        // 2. OVERRIDES (Only change what needs to change!)
        // --------------------------------------------------------
        if(valid) begin
            if (jump || actual_taken) begin
                // CASE A: The instruction actually jumped
                train_en           = 1'b1;
                taken_ground_truth = 1'b1;
                write_en           = 1'b1; 
                
                if (~predicted_taken || ~btb_hit || pred_target_pc != actual_target_pc) begin
                    misprediction          = 1'b1;
                    flush                  = 1'b1;
                    predicted_taken_gshare = 1'b0; 
                    correct_target_pc = actual_target_pc;
                    
                end
                else begin
                    predicted_taken_gshare = 1'b1; 
                end
            end
            
            else if (branch) begin
                // CASE B: It's a branch, but it evaluated to NOT taken (e.g., BNE failed)
                train_en = 1'b1;
                
                if (predicted_taken && btb_hit) begin
                    misprediction          = 1'b1;
                    flush                  = 1'b1;
                    correct_target_pc      = cur_pc + 4; // Fix the eager jump
                    predicted_taken_gshare = 1'b1;
                end
               else  predicted_taken_gshare = predicted_taken;
               end
            else begin
                // CASE C: Normal Instruction (ADD, SUB, LW, etc.)
                if (predicted_taken && btb_hit) begin // we not training gshare for mispred non-branch instr any btb will not be hit for them
                    // Predictor hallucinated a jump on an ALU instruction!
                    misprediction     = 1'b1;
                    flush             = 1'b1;
                    correct_target_pc = cur_pc + 4; // Force it to the next line 
                end
            end 
        
        end
        
        
    end
endmodule