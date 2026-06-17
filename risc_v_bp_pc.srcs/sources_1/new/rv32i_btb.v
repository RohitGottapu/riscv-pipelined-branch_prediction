`timescale 1ns / 1ps
// this module is combinational reading, sequenctial for writing
module rv32i_btb(

            input write_en, // by default read mode
            input clk,
            //read ports
            input [31:0] read_pc,
            output  wire [31:0]  btb_target, 
            output   reg  btb_hit, //actually it act as  wire
            
            //write ports
            
            input wire [31:0] target_pc,
            input wire [31:0] write_pc
            
    );
    
    reg [20:0] tag [0:511];
    reg [31:0] value [0:511];
    reg        valid [0:511];
    
    // initializing valid to 0
    integer i;
    initial begin
        for(i=0;i<512;i=i+1)valid[i]=1'b0;
    end
    
    // reading logic
    
        
        assign btb_target=value[read_pc[10:2]];
        always @(*) begin
        if(tag[read_pc[10:2]]==read_pc[31:11] & valid[read_pc[10:2]] == 1'b1 )btb_hit=1'b1;
        else btb_hit=1'b0;
        end
    
    
    
    //writing logic
    
    
    always @(posedge clk)begin
            if(write_en)begin
                tag[write_pc[10:2]]<=write_pc[31:11];
                value[write_pc[10:2]]<=target_pc;
                valid[write_pc[10:2]]<=1'b1;
            end
            
    end 
    

    
endmodule
