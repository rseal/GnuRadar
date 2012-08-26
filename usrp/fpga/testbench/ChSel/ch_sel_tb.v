`timescale 1ns/100ps

module ch_sel_tb;
   
   //test vector to load data from file
   parameter TEST_VECTOR_LENGTH=500;
   parameter CLK_PER_2=25;
   parameter STROBE_PER=250;
   parameter SIM_TIME=1e6;
   
   reg 	     clk,rst;

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
	//reset pulse
	rst <= 1'b0;
	rst <= #10 1'b1;
	rst <= #100 1'b0;
     end

   wire [2:0] sel;
   reg [2:0] channels;


   always @(posedge clk)
     if(rst)
       channels <= 3'd1;
   
   /*
    *MODULE: ch_sel
    */
   ch_sel cs
     (
      .clk(clk),
      .reset(rst),
      .strobe(strobe),
      .sel(sel),
      .channels(channels)
      );

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
   
   //read test vector from file into storage
   initial
     begin	
	$dumpfile("ch_sel_tb.lxt");
	$dumpvars;
	#(SIM_TIME) $finish;
     end
   
endmodule // ch_sel_tb


