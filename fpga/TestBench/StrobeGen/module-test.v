
module module_test(
	       input clk,
	       input en,
	       input reset,
	       input [7:0] rate,
	       output reg [7:0] out
	       );
   
   always @ (posedge clk)
     if(~en | reset) 
       out <= #1 8'd0;
     else if(en)
       out <= #1 (out==8'd0) ? rate : out - 8'd1;

endmodule // testMod
