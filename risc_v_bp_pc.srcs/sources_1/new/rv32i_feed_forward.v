`timescale 1ns / 1ps
// this is purely combinational
module rv32i_forwarding_unit(
    // Inputs from the ID/EX Stage
    input  wire [4:0] id_ex_rs1,
    input  wire [4:0] id_ex_rs2,
    
    // Inputs from the EX/MEM Stage (1 step ahead)
    input  wire       ex_mem_reg_write,
    input  wire [4:0] ex_mem_rd,
    
    // Inputs from the MEM/WB Stage (2 steps ahead)
    input  wire       mem_wb_reg_write,
    input  wire [4:0] mem_wb_rd,
    
    // Outputs to the EX Stage Multiplexers
    output reg  [1:0] forward_a,
    output reg  [1:0] forward_b
);

    always @(*) begin
        // --------------------------------------------------------
        // 1. Default Assignments (No Forwarding)
        // --------------------------------------------------------
        forward_a = 2'b00;
        forward_b = 2'b00;

        // --------------------------------------------------------
        // 2. Forwarding Logic for ALU Input A (rs1)
        // --------------------------------------------------------
        
        // Priority 1: EX/MEM Hazard (Most recent instruction)
        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs1)) begin
            forward_a = 2'b10;
        end
        // Priority 2: MEM/WB Hazard (Older instruction)
        else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs1)) begin
            forward_a = 2'b01;
        end

        // --------------------------------------------------------
        // 3. Forwarding Logic for ALU Input B (rs2)
        // --------------------------------------------------------
        
        // Priority 1: EX/MEM Hazard (Most recent instruction)
        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs2)) begin
            forward_b = 2'b10;
        end
        // Priority 2: MEM/WB Hazard (Older instruction)
        else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs2)) begin
            forward_b = 2'b01;
        end
        
    end

endmodule