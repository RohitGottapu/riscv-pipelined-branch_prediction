`timescale 1ns / 1ps

module rv32i_main_mem (
    input  wire        clk,
    input  wire        we,       // Write Enable (mem_write)
    input  wire [31:0] addr,     // Full 32-bit address from ALU
    input  wire [31:0] wd,       // Write Data (store_data)
    output wire [31:0] rd        // Read Data (goes to Writeback stage)
);

    // 1. Define the physical silicon memory array
    // 1024 rows, each row is 32 bits wide = 4 Kilobytes total
    reg [31:0] ram [0:1023];

    // 2. The Address Slicer (The Magic Trick)
    // Grab exactly 10 bits, starting above the 2 byte-offset bits
    wire [9:0] word_index;
    assign word_index = addr[11:2];

    // 3. Synchronous Write
    always @(posedge clk) begin
        if (we) begin
            ram[word_index] <= wd;
        end
    end

    // 4. Asynchronous Read (Standard for basic 5-stage pipelines)
    // The data appears instantly so it can be captured by the MEM/WB register
    assign rd = ram[word_index];

endmodule