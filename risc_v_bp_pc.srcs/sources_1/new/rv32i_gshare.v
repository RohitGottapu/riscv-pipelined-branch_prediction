`timescale 1ns / 1ps

// combinational prediction, but sequenctial training
module rv32i_gshare(
        input clk,
        input train_en,
        input btb_hit,
        // prediction
        input [31:0] pc_pred,
        output reg  predict_taken, // not a flipflop
        output [7:0] current_bhr,
        //training
        
        input [31:0] pc_train,
         input [7:0] bhr_snapshot_train, // try variable widths
         input taken_ground_truth,
         input taken_pred
        
    );
    
    reg [7:0] bhr;
    reg [1:0] pht [255:0];
    wire [7:0] key,key2;
    //initialization of pht and bhr
    integer i;
    initial begin
        for(i=0;i<256;i=i+1)pht[i]<=2'b01;
        bhr<=8'd0;
    
    end
    
    
    
    //prediction phase
    assign mispredicted=(taken_pred!=taken_ground_truth);
    
    assign key = bhr ^ pc_pred[9:2];
    assign current_bhr=bhr;
    always @(*)begin
    
           if(pht[key]>=2'd2) begin 
           predict_taken<=1'b1;
           
           end
           else begin
            predict_taken<=1'b0;
            
            end
        
       

    end
    
    
    // training
    assign key2=bhr_snapshot_train^pc_train[9:2];
    always @(posedge clk)begin
         if(train_en)begin
            
            if(taken_ground_truth & !taken_pred)begin
                if(pht[key2]<2'd3)pht[key2]<=pht[key2]+1'b1;
                
            end
            else if (!taken_ground_truth & taken_pred)begin
                if(pht[key2]>2'd0)pht[key2]<=pht[key2]-1'b1;
               
            end
            else if (taken_ground_truth & taken_pred)begin
                if(pht[key2]<2'd3)pht[key2]<=pht[key2]+1'b1;
            end
            else if(pht[key2]>2'd0)pht[key2]<=pht[key2]-1'b1;
        end
        
        if(train_en & mispredicted)begin
            bhr<={bhr_snapshot_train[6:0],taken_ground_truth};
        end
        else if(btb_hit) begin
            bhr<={bhr[6:0],pht[key]>=2'd2};
        end
        
    
    end
    
    
    
endmodule
