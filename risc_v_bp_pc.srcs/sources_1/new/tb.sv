module tb();
    
    
    reg clk;
    reg reset;
    
    rv32i_main main_inst (.clk(clk),.reset(reset));
    
    always #5 clk=~clk;
    
    initial begin
        clk=1'b0;
        reset=1'b1;
        #7 reset=1'b0;
        
        #3000 $finish;
        
         
    
    end
    
    
 
    
    


endmodule