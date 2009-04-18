`timescale 1ns/100ps

module ch_mux_tb;
   
   //test vector to load data from file
   parameter TEST_VECTOR_LENGTH=500;
   parameter CLK_PER_2=25;
   parameter STROBE_PER=250;
   parameter SIM_TIME=1e6;
   
   reg 	     clk,rst;
   reg 	     strobe;
   
   reg [3:0] numch;
   wire [7:0] channel;
   wire [15:0] data;
   
   /*
    CLOCK Generation
    */
   initial
     begin	
	clk=1'b1;
	forever #(CLK_PER_2) clk = ~clk;
     end
   
   /*
    VARIABLE Initialization
    */
   initial
     begin
	sel <= 3'd0;
	numch = 4'd8;
	//reset pulse
	rst <= 1'b0;
	rst <= #10 1'b1;
	rst <= #100 1'b0;
     end

   reg [2:0] sel;
   
   always @(posedge clk)
     sel <= (sel == numch-4'd1) ? 3'd0 : sel + 3'd1;
   
   /*
    MODULE: ch_mux
    */
   ch_mux cm(
	     .sel(sel),
	     .d0(16'd1),
	     .d1(16'd2),
	     .d2(16'd3),
	     .d3(16'd4),
	     .d4(16'd5),
	     .d5(16'd6),
	     .d6(16'd7),
	     .d7(16'd8),
	     .dout(data)
	     );

   //read test vector from file into storage
   initial
     begin	
	$dumpfile("ch_mux_tb.lxt");
	$dumpvars;
	#(SIM_TIME) $finish;
     end
   
endmodule // ch_select_tb

