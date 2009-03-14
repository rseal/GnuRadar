`timescale 1ns/100ps
`include "../../src/ch_select.v"

module ch_select_tb;
   

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
   
   ///////////////////////// CLOCK GENERATION //////////////////////////
   initial
     begin	
	clk=1'b1;
	forever #(CLK_PER_2) clk = ~clk;
     end

   initial
     begin
	strobe=1'b0;
	repeat(2) #(50) strobe = ~strobe;
	#500000 repeat(2) #(50) strobe = ~strobe;
     end
   ///////////////////////// CLOCK GENERATION //////////////////////////
   
   ///////////////////////// VARIABLE INITIALIZATION ///////////////////
   initial
     begin
	numch = 4'd4;
	//reset pulse
	rst <= 1'b0;
	rst <= #10 1'b1;
	rst <= #100 1'b0;
     end
   ///////////////////////// VARIABLE INITIALIZATION ///////////////////

   ///////////////////////// MODULE INSTANTIATION /////////////////////
   ch_select cs(
		.clk(clk),
		.rst(rst),
		.strobe(strobe),
		.numch(numch),
		.out(channel),
		.d_in({16'd8,16'd7,16'd6,16'd5,16'd4,16'd3,16'd2,16'd1}),
		.d_out(data)
		);

   /* -----\/----- EXCLUDED -----\/-----
    //use strobe module to generate decimated strobe
    strobe_gen rxsbr(
    .clock(~rx_clk),
    .reset(st_reset),
    .enable(st_enable),
    .rate(8'd100),
    .strobe_in(st_in),
    .strobe(rx_strobe)
    );
    -----/\----- EXCLUDED -----/\----- */
   ///////////////////////// MODULE INSTANTIATION /////////////////////

      //read test vector from file into storage
      initial
	begin	
	   $dumpfile("ch_select_tb.gtk");
	   $dumpvars;
	   #(SIM_TIME) $finish;
	end

endmodule // ch_select_tb

