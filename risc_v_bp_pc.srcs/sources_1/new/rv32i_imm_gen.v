`timescale 1ns / 1ps
// this is an fully combinational block
module rv32i_imm_gen(
        input [31:0] instr,
        output reg  [31:0] imm
    );
    
    wire [6:0] opcode;
    assign opcode=instr[6:0];
    
    always@(*) begin
        case (opcode)
            // -------------------------------------------------------------
            // I-Type (e.g., ADDI, LW, JALR)
            // -------------------------------------------------------------
            // Opcodes: 0010011 (Arith), 0000011 (Load), 1100111 (JALR)
            7'b0010011, 7'b0000011, 7'b1100111: begin
                // Sign-extend bit 31 twenty times, then attach bits 31:20
                imm = { {20{instr[31]}}, instr[31:20] };
            end

            // -------------------------------------------------------------
            // S-Type (e.g., SW, SH, SB)
            // -------------------------------------------------------------
            // Opcode: 0100011 (Store)
            7'b0100011: begin
                // Sign-extend bit 31, attach top 7 bits, then bottom 5 bits
                imm = { {20{instr[31]}}, instr[31:25], instr[11:7] };
            end

            // -------------------------------------------------------------
            // B-Type (e.g., BEQ, BNE)
            // -------------------------------------------------------------
            // Opcode: 1100011 (Branch)
            7'b1100011: begin
                // Sign-extend, then grab the scrambled bits, and force bit 0 to 0
                imm = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 };
            end

            // -------------------------------------------------------------
            // U-Type (e.g., LUI, AUIPC)
            // -------------------------------------------------------------
            // Opcodes: 0110111 (LUI), 0010111 (AUIPC)
            7'b0110111, 7'b0010111: begin
                // Upper 20 bits stay at the top, bottom 12 bits are forced to 0
                imm = { instr[31:12], 12'b0 };
            end

            // -------------------------------------------------------------
            // J-Type (e.g., JAL)
            // -------------------------------------------------------------
            // Opcode: 1101111 (JAL)
            7'b1101111: begin
                // Sign-extend (12 times), un-scramble the rest, force bit 0 to 0
                imm = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
            end

            // -------------------------------------------------------------
            // R-Type & Default (No Immediate)
            // -------------------------------------------------------------
            default: begin
                imm = 32'b0; 
            end
        endcase
    end
    
    
    
    
endmodule
