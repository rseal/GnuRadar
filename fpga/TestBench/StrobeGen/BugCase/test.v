`include "module-test.v"

`timescale 1ns/100ps

module test;
   
   parameter PERIOD=4;
   
   reg 	     clk;
   reg 	     reset;
   wire [7:0] out;
   reg       en;
   reg [7:0] rate;
   
   //initialize variables
   initial
     begin
	rate    <= 8'd9;

	reset   <= 1'b0;
	reset   <= #3 1'b1;
	reset   <= #10 1'b0;

	en <= 1'b0;
	en <= #25 1'b1;
	en <= #180 1'b0;
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
	$dumpfile("test.gtk");
	$dumpvars;
     end

   //run length
   initial
     begin	
	#200 $finish;
     end

   module_test dut(clk,en,reset,rate,out);

endmodule 
