`timescale 1ns / 1ps

// This is purely combinational
// What does it do: Generates control signals given an instr, used in different stages of the pipeline
module rv32i_decoder(
    input  wire [31:0] instr,
    output reg         mem_write,
    output reg         alu_mux_control, // 0 -> alu receives rs2, 1 -> alu receives imm
    output reg         alu_operation,   // 0 -> add, 1 -> sub
    output reg         reg_write,
    output reg         branch,
    output reg         jump,
    output reg         illegal_instr,
    output reg  [1:0]  result_src       // 00 -> alu_out, 01 -> mem_out, 10 -> pc+4, 11-->pc+imm
);  

    wire [6:0] opcode  = instr[6:0];
    wire [2:0] func3   = instr[14:12];
    wire       func7_5 = instr[30];    // Distinguishes ADD (0) from SUB (1)

    always @(*) begin
        // Default assignments to prevent latches
        reg_write       = 1'b0;
        mem_write       = 1'b0;
        branch          = 1'b0;
        jump            = 1'b0;
        illegal_instr   = 1'b0;
        result_src      = 2'b00;
        alu_mux_control = 1'b0;
        alu_operation   = 1'b0; // Default to ADD

        case(opcode)
            
            // --- SW (Store Word) ---
            7'b0100011: begin 
                if (func3 == 3'b010) begin
                    mem_write       = 1'b1;
                    alu_mux_control = 1'b1;   // imm
                    alu_operation   = 1'b0;   // ADD base + offset
                end else begin
                    illegal_instr = 1'b1;
                end
            end
            
            // --- LW (Load Word) ---
            7'b0000011: begin
                if (func3 == 3'b010) begin
                    alu_mux_control = 1'b1;   // imm
                    alu_operation   = 1'b0;   // ADD base + offset
                    reg_write       = 1'b1;
                    result_src      = 2'b01;  // from mem output
                end else begin
                    illegal_instr = 1'b1;
                end
            end
            
            // --- ADDI (Add Immediate) ---
            7'b0010011: begin
                if (func3 == 3'b000) begin
                    alu_mux_control = 1'b1;   // imm
                    alu_operation   = 1'b0;   // ADD
                    reg_write       = 1'b1;
                    result_src      = 2'b00;  // from ALU
                end else begin
                    illegal_instr = 1'b1; 
                end
            end 
            
            // --- ADD / SUB (R-Type) ---
            7'b0110011: begin
                if (func3 == 3'b000) begin
                    alu_mux_control = 1'b0;   // rs2
                    reg_write       = 1'b1;
                    result_src      = 2'b00;  // from ALU
                    alu_operation   = func7_5; // 0 for ADD, 1 for SUB
                end else begin
                    illegal_instr = 1'b1; 
                end
            end
            
            // --- BRANCHES ---
            7'b1100011: begin
                if (func3 != 3'b010 && func3 != 3'b011) begin
                    branch          = 1'b1;
                    // The main ALU doesn't calculate the branch condition anymore because 
                    // the EX stage evaluates it. alu_mux_control and alu_operation stay 0.
                end else begin
                    illegal_instr = 1'b1;
                end
            end
            
           // --- LUI ---
            7'b0110111: begin 
                alu_mux_control = 1'b1;    // Imm
                alu_operation   = 1'b0;    // ADD (Imm + 0 if rs1=0)
                reg_write       = 1'b1;
                result_src      = 2'b00;   // Route alu_out to reg
            end

            // --- AUIPC ---
            7'b0010111: begin
                // Main ALU doesn't matter here because we use the dedicated actual_target_pc adder
                alu_mux_control = 1'b0;    
                alu_operation   = 1'b0;    
                reg_write       = 1'b1;
                result_src      = 2'b11;   // NEW: Tell WB stage to route pc_plus_imm to reg!
            end
            
            // --- JAL ---
            7'b1101111: begin
                jump            = 1'b1;
                reg_write       = 1'b1;    
                result_src      = 2'b10;   // PC+4 routed to register
            end 
            
            // --- JALR ---
            7'b1100111: begin
                if (func3 == 3'b000) begin 
                    jump            = 1'b1;
                    reg_write       = 1'b1;    
                    alu_mux_control = 1'b1;    // Imm
                    alu_operation   = 1'b0;    // ADD (rs1 + Imm for jump target)
                    result_src      = 2'b10;   // PC+4 routed to register
                end else begin
                    illegal_instr = 1'b1;
                end
            end
            
            default: begin
                illegal_instr = 1'b1; 
            end 
            
        endcase
    end
endmodule