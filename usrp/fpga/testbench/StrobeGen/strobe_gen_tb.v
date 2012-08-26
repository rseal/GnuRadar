//`include "../../src/strobe_gen_new.v"
`include "../../src/strobe_gen.v"

`timescale 1ns/100ps

module strobe_gen_tb;
   
   parameter PERIOD=15.6;
   parameter GATE_PER=512000;
   
   reg 	     clk;
   reg 	     rst;
   reg 	     gate_enable;
   reg	     str_in;
   wire	     str1,str2;

   reg [15:0] cntr1,cntr2;
   
   //strobe rate
   reg [7:0] strobe_rate;
   reg [3:0] delay;
   reg  d;
   
   //initialize variables
   initial
     begin
	//divide by 10 
	strobe_rate <= 8'd9;

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
	forever
	  begin
	     //d = PERIOD/2;
// + $random%(3);
	     clk = #(PERIOD/2 + $random %(0.4)) ~clk;
	  end
     end

   /*
    generate gate_enable
    */
   initial
     begin
	gate_enable = 1'b0;
	#(100) forever gate_enable = #(GATE_PER + $random %(100)) ~gate_enable;
     end
   
   //produce output to view waveforms
   initial
     begin
	$dumpfile("strobe_gen_tb.lxt");
	$dumpvars;
     end

   initial $display("\n Display strobe counts for each gate enable");

   //run length
   initial
     begin	
	#5000000 $finish;
     end

   always @ (negedge clk)
     begin
	if(rst)
	  cntr1 <= 16'd0;
	else if(gate_enable && str1)
	  cntr1 <= cntr1 + 16'd1;
	else if(~gate_enable)
	  cntr1 <= 16'd0;
     end

   always @ (negedge clk)
     begin
	if(rst)
	  cntr2 <= 16'd0;
	else if(gate_enable && str2)
	  cntr2 <= cntr2 + 16'd1;
	else if(~gate_enable)
	  cntr2 <= 16'd0;
     end

   always @ (negedge gate_enable)
     begin
	$display("counter = %d<-->%d", cntr1,cntr2);
     end
   
   strobe_gen 
     dut1(
	  .clock(clk),
	  .reset(rst),
	  .enable(gate_enable),
	  .rate(strobe_rate),
	  .strobe_in(str_in),
	  .strobe(str1)
	  );

/* -----\/----- EXCLUDED -----\/-----
   strobe_gen_new 
     dut2(
	  .clock(clk),
	  .reset(rst),
	  .enable(gate_enable),
	  .rate(strobe_rate),
	  .strobe_in(str_in),
	  .strobe(str2)
	  );
 -----/\----- EXCLUDED -----/\----- */

endmodule // strobe_gen_tb
