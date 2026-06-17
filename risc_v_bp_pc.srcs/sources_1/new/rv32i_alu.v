`timescale 1ns / 1ps
// this is purely combinational
module rv32i_alu(
        input [31:0] data1,
        input [31:0] data2,
        input alu_ctrl,  // 0 --> add, 1--> sub
        output [31:0] alu_out
    );

    assign alu_out = (alu_ctrl)?data1-data2:data1+data2;
    

endmodule
