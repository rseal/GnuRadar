
module fifo_cntrl
  (
   input reset,
   input strobe,
   input clk,
   input [2:0] channels,
   input [15:0] d0,
   input [15:0] d1,
   input [15:0] d2,
   input [15:0] d3,
   input [15:0] d4,
   input [15:0] d5,
   input [15:0] d6,
   input [15:0] d7,
   output [15:0] dout,
   output en,
   output [7:0] debug
   );

   wire [2:0] 	sel;

   ch_sel cs
     (
      .clk(clk),
      .reset(reset),
      .strobe(strobe),
      .en(en),
      .sel(sel),
      .channels(channels)
      );
   
   ch_mux mux
     (
      .d0(d0),
      .d1(d1),
      .d2(d2),
      .d3(d3),
      .d4(d4),
      .d5(d5),
      .d6(d6),
      .d7(d7),
      .dout(dout),
      .sel(sel)
      );

/* -----\/----- EXCLUDED -----\/-----
   assign 	debug = {
			 channels[2], //7-9
			 sel,      //4-6
			 en,       //3
			 strobe,   //2
			 clk,      //1 
			 reset,    //0
			 };
 -----/\----- EXCLUDED -----/\----- */
endmodule // ch_mux
