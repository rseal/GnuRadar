`timescale 1ns/100ps

//uncomment for altera fifo simulation
`include "../../models/altera_dcfifo.v"

module fifo_tb;

   //test vector to load data from file
   parameter TEST_VECTOR_LENGTH=1024;
   
   reg [15:0] dataVec [0:TEST_VECTOR_LENGTH-1];
   reg [10:0]  iter;
   reg 	      reset;
   reg 	      bus_rst;
   wire [15:0] df_out;
   wire [15:0] ram_out;
   wire        overflow;
   reg 	       gate_enable;
   wire        rx_strobe;
   reg [3:0]   channels;
   reg [15:0]  ch0;
   reg [15:0]  ch1;
   reg [15:0]  ch2;
   reg [15:0]  ch3;
   reg [15:0]  ch4;
   reg [15:0]  ch5;
   reg [15:0]  ch6;
   reg [15:0]  ch7;

   parameter   GATE_PER_2    = 512000;
   parameter   USB_CLK_PER_2 = 10.4;
   parameter   RX_CLK_PER_2  = 7.8;
   parameter   SDI_CLK_PER_2 = 2*USB_CLK_PER_2;

   reg [11:0]   cnt;
   
   reg 	       usb_clk;
   reg 	       rx_clk;
   reg 	       wr_req;

   wire [7:0]  debug_signal;
   
   /* 
    * Generate 48MHz USB clock  
    */
   initial
     begin	
	usb_clk= #10 1'b1;
	forever #(USB_CLK_PER_2) usb_clk = ~usb_clk;
     end
   
   /* 
    * Generate 64MHz Rx clock  
    */
   initial
     begin	
	rx_clk=1'b1;
	forever #(RX_CLK_PER_2) rx_clk = ~rx_clk;
     end

   /*
    * Generate 512usec gate pulses 
    */
   initial
     begin
	gate_enable <= 1'b0;
	#10 gate_enable=1'b0;
	forever #(GATE_PER_2 + $random %(10)) gate_enable=~gate_enable;
     end
   
   /*
    * VARIABLE INITIALIZATION 
    */
   initial
     begin
	//reset pulse
	reset <= 1'd0;
	reset <= #10 1'd1;
	reset <= #20 1'd0;
	channels <= 4'd4;
	iter <= 9'd0;
	bus_rst <= 1'b0;
     end

   /*
    Module Instantiation
    */

   /*
    * MODULE: FX2
    * PURPOSE: Minimal FX2 module to emulate 
    *          data request and read signals
    */
   fx2 fx2
     (
      .packet_rdy(packet_rdy),
      .clk(usb_clk),
      .reset(reset),
      .din(df_out),
      .wr_req(RD)
      );

   /*
    * MODULE: strobe_gen
    * PURPOSE: Generate decimated strobe from rx_clk - rx_clk/rate
    */
   strobe_gen rxsbr
     (
      .clock(rx_clk),
      .reset(reset),
      .enable(gate_enable),
      .rate(8'd64),
      .strobe_in(1'b1),
      .strobe(rx_strobe)
      );
   
   /*
    * MODULE: rx_fifo_new
    * PURPOSE: 
    */
   fifo dut
     (
      .rd_clk(usb_clk),
      .bus_reset(bus_rst),
      .dout(df_out),
      .rd_req(RD),
      .packet_rdy(packet_rdy),
      .overflow(overflow),
      .clear_status(1'b0),
      .wr_clk(rx_clk),
      .reset(reset),
      .strobe(rx_strobe),
      .channels(channels),
      .din0(ch0),
      .din1(ch1),
      .din2(ch2),
      .din3(ch3),
      .din4(ch4),
      .din5(ch5),
      .din6(ch6),
      .din7(ch7),
      .debugbus(debug_signal)
      );

   /*
    * Reads test vector from file into dataVec array
    */
   initial
     begin	
	$readmemb("data/input.vec", dataVec);
	#2000000 $finish;  //2msec simulation time
     end

   /*
    * Dump variables to output file for gtkwave
    */
   initial
     begin
	$dumpfile("fifo_tb.lxt");
	$dumpvars;
     end
   
   /*
    * Load data from vector into channels 
    */
   always @ (posedge rx_strobe)
     begin
	ch0 <=  dataVec[iter];
	ch1 <=  dataVec[iter+1];
	ch2 <=  dataVec[iter+2];
	ch3 <=  dataVec[iter+3];
	ch4 <=  16'd0;
	ch5 <=  16'd0;
	ch6 <=  16'd0;
	ch7 <=  16'd0;
     end
   

   /*
    * Iterator for array indexing
    */
   always @ (posedge rx_strobe)
     iter <= (reset || iter == TEST_VECTOR_LENGTH-8) ? 9'd0 : iter + 9'd4;

endmodule // rx_buffer_mc_ge_tb
