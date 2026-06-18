`timescale 1ns / 1ps

module rv32i_if import rv32i_pkg::*; (
    input  logic              clk,
    input  logic              reset,
    input  logic              stall_if,             
    
       
   
    
    input  logic              mispredict_flush_id,  
    input  logic [31:0]       correct_target_id,    
      
    output if_id_reg        if_out_id, 
    
    input  logic write_en,
     input  logic [31:0] target_pc,
    input logic [31:0] write_pc,
    // fro gshare
    input logic train_en,
    input logic [31:0] pc_train,
    input logic [7:0] bhr_snapshot_train,
    input logic taken_pred,
    input logic taken_ground_truth
     
);
    
    // --- Internal Wires ---
    logic [31:0] pc_reg;
    logic [31:0] next_pc;
    logic [31:0] pc_plus_4;
    
    logic [31:0] imem_inst_wire;
    logic [31:0] btb_target_wire;
    logic        btb_hit_wire;
    logic        gshare_predict_wire;
    logic [7:0]  gshare_bhr_wire;

   

    // --- 1. Sub-Modules ---
    rv32i_imem imem_inst ( 
        
        .pc(pc_reg), 
        .instr(imem_inst_wire)
    ); 
    
    rv32i_btb btb_inst (
        .clk(clk),
        .write_en(write_en),
        .read_pc(pc_reg),
        .btb_target(btb_target_wire),
        .btb_hit(btb_hit_wire),
        .target_pc(target_pc),
        .write_pc(write_pc)
    );
    
    rv32i_gshare gshare_inst (
        .clk(clk),
        .train_en(train_en),
        .btb_hit(btb_hit_wire),
        .pc_pred(pc_reg),
        .predict_taken(gshare_predict_wire),
        .current_bhr(gshare_bhr_wire),
        .pc_train(pc_train),
        .bhr_snapshot_train(bhr_snapshot_train),
        .taken_ground_truth(taken_ground_truth),
        .taken_pred(taken_pred)
    );

    // --- 2. Next PC Logic ---
    assign pc_plus_4 = pc_reg + 4;

    always_comb begin
      if (mispredict_flush_id) begin
            next_pc = correct_target_id;            
        end else if (btb_hit_wire && gshare_predict_wire) begin
            next_pc = btb_target_wire;              
        end else begin
            next_pc = pc_plus_4;                    
        end
    end

    // Sequential PC Update
    always_ff @(posedge clk) begin
            if (reset) begin
                pc_reg <= 32'h0000_0000;
            end 
        else if (stall_if) begin
            pc_reg <= pc_reg;  
            end
            else begin
                pc_reg<=next_pc;
            end                    
        
    end

 
 
  

    // --- 3. Combinational Struct Packing ---
 
    always_ff @(posedge clk) begin
        if (reset) begin
            if_out_id <= '0;
        end else if (mispredict_flush_id) begin
            if_out_id <= '0; // Insert NOP on branch flush
        end else if (stall_if) begin
            if_out_id <= if_out_id; // HOLD STATE: Keep the current instruction in ID!
        end else begin
            if_out_id.valid            <= 1'b1;
            if_out_id.pc               <= pc_reg;
            if_out_id.predicted_taken  <= gshare_predict_wire;
            if_out_id.predicted_target <= btb_target_wire;
            if_out_id.bhr_snapshot     <= gshare_bhr_wire;
            if_out_id.btb_hit_wire     <= btb_hit_wire;
            if_out_id.instr            <= imem_inst_wire;
        end
    end
    

endmodule