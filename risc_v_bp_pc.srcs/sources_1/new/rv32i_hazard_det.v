`timescale 1ns / 1ps

module rv32i_hazard_det(
    
    input wire [1:0]      id_ex_mem_read, 
    input wire [4:0] id_ex_rd,       
    
   
    input wire [4:0] if_id_rs1,       
    input wire [4:0] if_id_rs2,      
    
    // Outputs to control the pipeline
    output reg stall_if,              
//    output reg stall_id,
    output reg flush_id              
);

    always @(*) begin
       
        stall_if = 1'b0;
        flush_id=1'b0;
//        stall_id = 1'b0;
        
        // Load-Use Hazard Detection Logic
        if (id_ex_mem_read == 2'b01) begin
            // Check if the Load's destination matches either source of the current instruction
            // THE EDGE CASE: Ignore Register 0! 
            if ((id_ex_rd != 5'b00000) && ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
                
                stall_if = 1'b1;  // Freeze Fetch (Don't load next instruction)
                // Freeze Decode (Hold the BGE instruction here)
//                stall_id=1'b1;
                flush_id= 1'b1;  // Send a NOP into the Execute stage
                
            end
        end
    end

endmodule