`timescale 1ns/100ps

`include "../../src/rx_fifo.v"
//this file contains dcfifo simulation models parsed from altera_mf.v
`include "../../models/altera_dcfifo.v"

`include "../../src/strobe_gen.v"

module rx_fifo_tb;

   //test vector to load data from file
   parameter TEST_VECTOR_LENGTH=500;
   
   reg [15:0] dataVec [0:TEST_VECTOR_LENGTH-1];
   reg [8:0]  iter;
   
   reg 	      reset;

   wire [15:0] data_out;
   reg 	       RD;
   wire        packet_rdy;
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

   wire [31:0] debug_out;

   parameter   USB_CLK_PER_2 = 10.4;
   parameter   RX_CLK_PER_2 = 7.8;
   parameter   SDI_CLK_PER_2 = 2*USB_CLK_PER_2;
   
   reg 	       usb_clk;
   reg 	       rx_clk;

   reg [8:0]   p_count;
   reg 	       usb_data_read;
   
   /* 
    CLOCK GENERATION 
    */
   
   initial
     begin	
	usb_clk= #10 1'b1;
	forever #(USB_CLK_PER_2) usb_clk = ~usb_clk;
     end
   
   //generate clock
   initial
     begin	
	rx_clk=1'b1;
	forever #(RX_CLK_PER_2) rx_clk = ~rx_clk;
     end

   initial
     begin
	gate_enable <= 1'b0;
	#1000 gate_enable=1'b0;
	forever #5000 gate_enable=~gate_enable;
     end
   
   /*
    //////////////////////// 
    VARIABLE INITIALIZATION 
    ///////////////////
    */
   
   initial
     begin
	
	//reset pulse
	reset <= 1'd1;
	reset <= #100 1'd0;
	
	channels <= 4'd4;
     end
   ///////////////////////// VARIABLE INITIALIZATION ///////////////////

   ///////////////////////// MODULE INSTANTIATION /////////////////////

     //use strobe module to generate decimated strobe
     strobe_gen rxsbr(
		      .clock(~rx_clk),
		      .reset(reset),
		      .enable(1'b1),
		      .rate(8'd64),
		      .strobe_in(1'b1),
		      .strobe(rx_strobe)
		      );

   //device under test
   rx_fifo dut(
	       .rd_clk(usb_clk),
	       .bus_reset(bus_rst),
	       .usbdata(data_out),
	       .RD(RD),
	       .packet_rdy(packet_rdy),
	       .overflow(overflow),
	       .clear_status(1'b0),
	       .wr_clk(rx_clk),
	       .gate_enable(gate_enable),
	       .reset(reset),
	       .rxstrobe(rx_strobe),
	       .channels(channels),
	       .ch_0(16'd1),
	       .ch_1(16'd2),
	       .ch_2(16'd3),
	       .ch_3(16'd4),
	       .ch_4(16'd5),
	       .ch_5(16'd6),
	       .ch_6(16'd7),
	       .ch_7(16'd8),
	       .debugbus()
	       );
   ///////////////////////// MODULE INSTANTIATION /////////////////////

     ///////////////////////// MODULE INSTANTIATION /////////////////////

   //read test vector from file into storage
   initial
     begin	
	$readmemb("data/input.vec", dataVec);
	#1000000 $finish;
     end

   //produce output to view waveforms
   initial
     begin
	$dumpfile("rx_fifo_tb.lxt");
	$dumpvars;
     end

   //////////////////////USB EMULATION /////////////////////
   always @ (posedge usb_clk)
     RD <= packet_rdy ? 1'b1 : 1'b0;
         
   //data is updated on negative edge
/* -----\/----- EXCLUDED -----\/-----
   always @ (posedge rx_strobe)
     begin
	if(we)
	  begin
	     ch0 <= #1 dataVec[iter];
	     ch1 <= #1 dataVec[iter];
	     ch2 <= #1 dataVec[iter];
	     ch3 <= #1 dataVec[iter];
	     ch4 <= #1 dataVec[iter];
	     ch5 <= #1 dataVec[iter];
	     ch6 <= #1 dataVec[iter];
	     ch7 <= #1 dataVec[iter];
     	     iter <= iter+1;
	  end
     end
 -----/\----- EXCLUDED -----/\----- */

   //reset iterator when vector data is read
   always @ (posedge rx_clk)
     iter <= (reset || iter == TEST_VECTOR_LENGTH-9) ? 9'd0 : iter + 9'd1;
   
endmodule // rx_buffer_mc_ge_tb
