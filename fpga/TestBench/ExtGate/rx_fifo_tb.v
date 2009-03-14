`timescale 1ns/100ps

`include "../../src/rx_fifo.v"
`include "../../models/dcfifo.v"
`include "../../src/strobe_gen.v"

module rx_fifo_tb;

   //test vector to load data from file
   parameter TEST_VECTOR_LENGTH=500;
   
   reg [15:0] dataVec [0:2*TEST_VECTOR_LENGTH-1];
   reg [8:0]  Iter;
   
   reg 	      we;
   reg 	      init;
   reg 	      st_in;
   reg 	      st_reset;
   reg 	      st_enable;
   reg 	      reset;
	      
   reg 	      bus_rst;
   wire [15:0] data_out;
   reg 	      RD;
   wire	      packet_rdy;
   wire	      overflow;
   reg 	      gate_enable;
   wire	      rx_strobe;
   reg [3:0]  channels;
   reg [15:0] ch0;
   reg [15:0] ch1;
   reg [15:0] ch2;
   reg [15:0] ch3;
   reg [15:0] ch4;
   reg [15:0] ch5;
   reg [15:0] ch6;
   reg [15:0] ch7;

   wire [31:0] debug_out;

   parameter   USB_CLK_PER_2 = 10.4;
   parameter   RX_CLK_PER_2 = 7.8;
   parameter   SDI_CLK_PER_2 = 2*USB_CLK_PER_2;
   
   reg 	      usb_clk;
   reg 	      rx_clk;

   reg [8:0] p_count;
   reg [15:0] gate_count;
   reg 	     usb_data_read;
   
   ///////////////////////// CLOCK GENERATION //////////////////////////
   //generate usb clock
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
   ///////////////////////// CLOCK GENERATION //////////////////////////
   
   ///////////////////////// VARIABLE INITIALIZATION ///////////////////
   initial
     begin

	//reset pulse
	reset <= 1'd1;
	reset <= #50 1'd0;
	
	bus_rst <= 1'd1;
	bus_rst <= #50 1'd0;
	
	//strobe signals
	st_reset <= 1'd1;
	st_reset <= #50 1'd0;
	st_enable <= 1'd1;
	st_in     <= 1'd1;
	
	Iter <= 9'd0;
	p_count <= 9'd0;
	gate_enable <= 1'b0;
	
	RD <= 1'b0;
	
	we <= 1'd0;
	@(posedge rx_clk) we <= #200 1'd1;

	channels <= 4'd4;
     end
   ///////////////////////// VARIABLE INITIALIZATION ///////////////////

   ///////////////////////// MODULE INSTANTIATION /////////////////////

   //use strobe module to generate decimated strobe
   strobe_gen rxsbr(
		    .clock(~rx_clk),
		    .reset(st_reset),
		    .enable(st_enable),
		    .rate(8'd64),
		    .strobe_in(st_in),
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
	#400000 $finish;
     end

   //produce output to view waveforms
   initial
     begin
	$dumpfile("rx_fifo_tb.gtk");
	$dumpvars;
     end

   //////////////////////USB EMULATION /////////////////////
   //if packet available and bus not in reset, load counter
   always @ (posedge usb_clk && packet_rdy)
     p_count <= #1 bus_rst ? 9'd0 : 9'd255;
   
   //as long as p_count != 0, keep reading data from fifo
   always @ (posedge usb_clk)
     if(p_count != 9'd0)
       begin
	  RD <= 1'b1;
	  p_count <= p_count - 9'd1;
       end
     else
       RD <= 1'b0;
   //////////////////////USB EMULATION /////////////////////
   
   always @ (posedge rx_clk)
     if(gate_count == 16'd0 || reset == 1'b1)
       begin
	  gate_count <= 16'd5000;
	  gate_enable <= ~gate_enable;
       end
     else
       gate_count <= gate_count - 16'd1;
         
   //data is updated on negative edge
   always @ (posedge rx_strobe)
     begin
	if(we)
	  begin
	     ch0 <= #1 dataVec[Iter];
	     ch1 <= #1 dataVec[Iter];
	     ch2 <= #1 dataVec[Iter];
	     ch3 <= #1 dataVec[Iter];
	     ch4 <= #1 dataVec[Iter];
	     ch5 <= #1 dataVec[Iter];
	     ch6 <= #1 dataVec[Iter];
	     ch7 <= #1 dataVec[Iter];
     	     Iter <= Iter+1;
	  end
     end

   //reset iterator when vector data is read
   always @ (posedge rx_clk)
     begin
	if(Iter == TEST_VECTOR_LENGTH-9)
	  begin
	     we <= 0;
	     Iter <= 0;	     
	  end
     end // always @ (posedge clk)
endmodule // rx_buffer_mc_ge_tb
