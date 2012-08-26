`timescale 1ns/100ps

module halfband_tb;

   parameter SAMPLE_RATE=4;
   parameter   GATE_PER_2    = 5120;
   parameter   USB_CLK_PER_2 = 10.4;
   parameter   RX_CLK_PER_2  = 7.8;
   parameter   SDI_CLK_PER_2 = 2*USB_CLK_PER_2;   

   reg 	       clk;
   reg 	       reset;
   reg [15:0]  i_in, q_in;
   wire [15:0] i_out, q_out;
   wire        strobe_in;
   wire        strobe_out;
   reg 	       coeff_write;
   reg [15:0]  coeff_data;
   reg [4:0]   coeff_addr;
   reg 	       gate_enable;
   
   /*
    * Master Clock 64 MHz
    */
   initial
     begin
	clk=1'b0;
	forever #(RX_CLK_PER_2) clk = ~clk;
     end

   initial
     begin
	reset = 1'b0;
	#10 reset = 1'b1;
	#20 reset = 1'b0;
     end

   /*
    * Generate 512usec gate pulses 
    */
   initial
     begin
	gate_enable <= 1'b0;
	#100 gate_enable=1'b1;
	forever #(GATE_PER_2 + $random %(10)) gate_enable=~gate_enable;
     end

   initial $dumpfile("halfband_decim_tb.lxt");
   initial $dumpvars;

   /*
    * MODULE: strobe_gen
    * PURPOSE: Generate decimated strobe from rx_clk - rx_clk/rate
    */
   strobe_gen rxsbr
     (
      .clock(clk),
      .reset(reset),
      .enable(gate_enable),
      .rate(8'd63),
      .strobe_in(1'b1),
      .strobe(strobe_in)
      );

 /*
  * MODULE: halfband_decim
  */  
   halfband_decim halfband_decim 
     ( .clock(clk),
       .reset(reset),
       .enable(),
       .strobe_in(strobe_in),
       .strobe_out(strobe_out),
       .data_in(i_in),
       .data_out(i_out) );
   
   always @(posedge strobe_out)
     if(i_out[15])
       $display("-%d",65536-i_out);
     else
       $display("%d",i_out);

   initial #10000000 $finish;    // Just in case...

   initial
     begin
	i_in <= #1 16'd0;
	repeat (40) @(posedge strobe_in);
	i_in <= #1 16'd16384;
	@(posedge strobe_in);
	i_in <= #1 16'd0;
	repeat (40) @(posedge strobe_in);
	i_in <= #1 16'd16384;
	@(posedge strobe_in);
	i_in <= #1 16'd0;
	repeat (40) @(posedge strobe_in);
	i_in <= #1 16'd16384;
	repeat (40) @(posedge strobe_in);
	i_in <= #1 16'd0;
	repeat (41) @(posedge strobe_in);
	i_in <= #1 16'd16384;
	repeat (40) @(posedge strobe_in);
	i_in <= #1 16'd0;
	repeat (40) @(posedge strobe_in);
	repeat (7) @(posedge clk);
	$finish;
     end // initial begin
endmodule // test_hb
