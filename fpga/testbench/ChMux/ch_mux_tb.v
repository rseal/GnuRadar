`timescale 1ns/100ps

module ch_mux_tb;
   
   //test vector to load data from file
   parameter TEST_VECTOR_LENGTH=500;
   parameter CLK_PER_2=25;
   parameter STROBE_PER=250;
   parameter SIM_TIME=1e6;
   
   reg 	     clk,rst;
   wire 	     strobe;
   
   reg [3:0] numch;
   reg [3:0] maxChannels;
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
	numch = 4'd2;
   maxChannels = numch - 4'd1;
	//reset pulse
	rst <= 1'b0;
	rst <= #10 1'b1;
	rst <= #100 1'b0;
     end

   wire [2:0] sel;
   
   //always @(posedge clk)
   //  sel <= (sel == numch-4'd1) ? 3'd0 : sel + 3'd1;
   //
   /*
    *MODULE: strobe_gen
    */
   strobe_gen sgn
     (
      .clock(clk),
      .reset(rst),
      .enable(1'b1),
      .rate(8'd63), // Rate should be 1 LESS THAN your desired divide ratio
      .strobe_in(1'b1),
      .strobe(strobe),
      .dbus()
    );
   
   /*
    *MODULE: ch_sel
    */
   ch_sel cs
     (
      .clk(clk),
      .reset(rst),
      .strobe(strobe),
      .sel(sel),
      .channels(maxChannels[2:0])
      );

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

