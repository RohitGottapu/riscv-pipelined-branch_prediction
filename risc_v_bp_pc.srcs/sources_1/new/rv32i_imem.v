`timescale 1ns / 1ps
//combinational memory access
module rv32i_imem (
 
    input  wire [31:0] pc,      // Explicitly declared as wire
    output  wire [31:0] instr    // Declared as reg because it is assigned in an always block
);

    // 4KB memory array using standard Verilog 'reg' type
    reg [31:0] rom_array [0:1023]; 
    
     integer i;
    initial begin
       
        for (i = 0; i < 1024; i = i + 1) rom_array[i] = 32'h0000_0000;
        $readmemh("instructions.mem", rom_array);
    end

    
    
       assign instr = rom_array[pc[11:2]]; 
   

endmodule