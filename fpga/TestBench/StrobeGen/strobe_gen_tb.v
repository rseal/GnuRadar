`include "../../src/strobe_gen.v"

`timescale 1ns/100ps

module strobe_gen_tb;
   
   parameter PERIOD=15;
   
   reg 	     clk;
   reg 	     rst;
   reg 	     en;
   reg	     str_in;
   wire	     str_out;
   
   //strobe rate
   reg [7:0] strobe_rate;

   //initialize variables
   initial
     begin
	//divide by 10 
	strobe_rate <= 63'd9;

	//enable signal 
	en  <= 1'b0;
	en  <= #(20*PERIOD) 1'b1;

	//reset signal for initialization
	rst <= 1'b0;
	rst <= #(2*PERIOD) 1'b1;
	rst <= #(4*PERIOD) 1'b0;
	
	//strobe in signal 
	str_in <= 1'b0;
	str_in <= #(30*PERIOD) 1'b1;
     end
   
   //generate clock
   initial
     begin	
	clk=1'b1;
	forever #(PERIOD/2) clk = ~clk;
     end

      //produce output to view waveforms
   initial
     begin
	$dumpfile("strobe_gen_tb.gtk");
	$dumpvars;
     end

   //run length
   initial
     begin	
	#150000 $finish;
     end

   strobe_gen dut(
		  .clock(clk),
		  .reset(rst),
		  .enable(en),
		  .rate(strobe_rate),
		  .strobe_in(str_in),
		  .strobe(str_out)
		  );

endmodule // strobe_gen_tb
