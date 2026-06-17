`timescale 1ns / 1ps
// this is the main file to run the processor

module rv32i_main import rv32i_pkg::*;(input wire clk,
                    input wire reset);
                    
    /// this part is only for IPC finding               
       reg [63:0] cycle_count;

always @(posedge clk) begin
    if (reset) begin
        cycle_count <= 64'b0;
    end else begin
        cycle_count <= cycle_count + 1;
    end
end             
                    
///

    wire stall_if;
    wire mispredict_flush_id;
    wire [31:0] correct_target_id;
    if_id_reg if_out;
    wire write_en;
    wire [31:0] target_pc;
    wire [31:0] write_pc;
    wire train_en;
    wire [31:0] pc_train;
    wire [7:0] bhr_snapshot_train;
    wire taken_pred;
    wire taken_ground_truth;
    
    
    rv32i_if if_inst (.clk(clk),.reset(reset),.stall_if(stall_if),.mispredict_flush_id(mispredict_flush_id),.correct_target_id(correct_target_id),
                        .if_out_id(if_out),.write_en(write_en),.target_pc(target_pc),.write_pc(write_pc),.train_en(train_en),.pc_train(pc_train),
                        .bhr_snapshot_train(bhr_snapshot_train),.taken_pred(taken_pred),.taken_ground_truth(taken_ground_truth));
       assign correct_target_id=target_pc;
      wire [31:0] write_data_wb;
       wire wb_reg_write_en;                 
        wire [4:0] wb_rd;
       wire flush_id;
       wire stall_id;
         id_ex_reg id_out;
                       
     rv32i_id id_inst (.clk(clk),.rst(reset),.id_in_pkg(if_out),.write_data_wb(write_data_wb),.wb_reg_write_en(wb_reg_write_en),
                                        .wb_rd(wb_rd),.flush(flush_id),.stall(stall_id),.id_out_pkg(id_out));                   
    wire flush_ex;
    wire stall_ex;
    wire ex_mem_reg_write;
    wire [4:0] ex_mem_rd;
    wire mem_wb_reg_write;
    wire [4:0] mem_wb_rd;
   wire  [31:0] ex_mem_alu_out_fw;
    wire [31:0] mem_wb_data_fw;  
    ex_mem_reg ex_out; 
    // droppe dmisprediction port
    assign ex_mem_alu_out_fw = ex_out.alu_out;
    assign ex_mem_rd         = ex_out.rd;
    assign ex_mem_reg_write  = ex_out.reg_write & ex_out.valid;
    assign mem_wb_data_fw    = write_data_wb;   // WB mux output
    assign mem_wb_rd         = wb_rd;
    assign mem_wb_reg_write  = wb_reg_write_en;
    
    rv32i_ex ex_inst (.clk(clk),.ex_in(id_out),.flush(flush_ex),.stall(stall_ex),.ex_mem_reg_write(ex_mem_reg_write),.ex_mem_rd(ex_mem_rd),.mem_wb_reg_write(mem_wb_reg_write),
                                  .mem_wb_rd(mem_wb_rd),.ex_mem_alu_out_fw(ex_mem_alu_out_fw),.mem_wb_data_fw(mem_wb_data_fw),.ex_out(ex_out),
                                  .eval_flush(mispredict_flush_id),.eval_pc(pc_train),.correct_target_pc(target_pc),.write_en(write_en),.taken_ground_truth(taken_ground_truth),
                                  .predicted_taken_gshare(taken_pred),.train_en(train_en),.correct_bhr(bhr_snapshot_train));
                                  
    
    
  // flush_if has assigned mispredict_flus_id in its port
    assign write_pc=pc_train;


    wire stall_mem;
    wire flush_mem;
    mem_wb_reg mem_out;
    
    rv32i_mem mem_inst (.clk(clk),.mem_in(ex_out),.stall(stall_mem),.flush(flush_mem),.mem_out(mem_out));

    rv32i_wb wb_inst (.wb_in(mem_out),.reg_write(wb_reg_write_en),.data(write_data_wb),.rd(wb_rd));


assign stall_ex = 1'b0; assign  flush_ex=1'b0; assign stall_mem = 1'b0;
assign flush_mem = 1'b0; assign stall_id=1'b0; assign stall_if=1'b0;

// wire flush_id_hazard;
assign flush_id=(mispredict_flush_id  );

//    assign is_ex_instr_sw = (id_out.instr[6:0]==7'b0000011)&(id_out.instr[14:12]==3'b010); // opcode and func3 matching for det lw instr 
//    rv32i_hazard_det hazard_det_inst (.id_ex_mem_read(id_out.result_src),.id_ex_rd(id_out.rd),.if_id_rs1(if_out.instr[19:15]),.if_id_rs2(if_out.instr[24:20]),.stall_if(stall_if),
//                                    .flush_id(flush_id_hazard));


///
reg [63:0] retired_inst_count;

always @(posedge clk) begin
    if (reset) begin
        retired_inst_count <= 64'b0;
    end else if (mem_out.valid) begin // Only count if a real instruction finishes!
        retired_inst_count <= retired_inst_count + 1;
    end
end
///

endmodule
