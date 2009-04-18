
module ch_mux
  (
   input [15:0] d0,
   input [15:0] d1,
   input [15:0] d2,
   input [15:0] d3,
   input [15:0] d4,
   input [15:0] d5,
   input [15:0] d6,
   input [15:0] d7,
   output reg [15:0] dout,
   input [2:0] sel
   );

   
   always @(*)
     case(sel)
       3'd0: dout <= d0;
       3'd1: dout <= d1;
       3'd2: dout <= d2;
       3'd3: dout <= d3;
       3'd4: dout <= d4;
       3'd5: dout <= d5;
       3'd6: dout <= d6;
       3'd7: dout <= d7;
     endcase
endmodule // mux8to1
