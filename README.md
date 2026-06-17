# riscv-pipelined-branch_prediction
A 32-bit RISC-V core featuring a 5-stage pipeline and branch prediction using gshare , written in Verilog and SystemVerilog
### RTL Module Hierarchy

tb.sv
 ┗  rv32i_main.sv
    ┣  rv32i_if.sv
    ┃  ┣  rv32i_imem.v
    ┃  ┣  rv32i_btb.v
    ┃  ┗  rv32i_gshare.v
    ┣  rv32i_id.sv
    ┃  ┣  rv32i_regfile.v
    ┃  ┣  rv32i_decoder.v
    ┃  ┗  rv32i_imm_gen.v
    ┣  rv32i_ex.sv
    ┃  ┣  rv32i_feed_forward.v
    ┃  ┣  rv32i_branch_eval.v
    ┃  ┗  rv32i_alu.v
    ┣  rv32i_mem.sv
    ┃  ┗  rv32i_main_mem.v
    ┗  rv32i_wb.sv
