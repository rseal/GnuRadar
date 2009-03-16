`timescale 1ns/100ps

`include "../../src/megacells/fifo_mc.v"

//this file contains dcfifo simulation models parsed from altera_mf.v
`include "../../models/altera_dcfifo.v"

`include "../../src/strobe_gen.v"

module fifo_mc_tb;

   //test vector to load data from file
   parameter TEST_VECTOR_LENGTH=500;
   
   reg [15:0] d_in_vec [0:TEST_VECTOR_LENGTH-1];
   reg [15:0] d_out_vec [0:TEST_VECTOR_LENGTH-1];
   
   reg [15:0] d_in;
   
   reg [8:0]  iter1,iter2;
   reg 	      reset;
   
   wire [15:0] d_out;
   
   reg 	       rd_req;
   wire        wr_req;
   reg         packet_rdy;
   wire        overflow;
   reg 	       gate_enable;
   wire        rx_strobe;
   
   parameter   RD_CLK_PER_2  = 10.4;
   parameter   WR_CLK_PER_2  = 7.8;
   parameter   SDI_CLK_PER_2 = 2*WR_CLK_PER_2;
   
   reg 	       rd_clk;
   reg 	       wr_clk;
   wire        dec_clk;
   
   reg 	       usb_data_read;

   wire [8:0]  wr_used,rd_used;
   
   wire        rd_empty,rd_full,
	       wr_empty,wr_full;
   
   ////////////////////////////////////////////////
   //            CLOCK/SIGNAL GENERATION 
   //////////////////////////////////////////////
   initial
     begin	
	rd_clk= #10 1'b1;
	forever #(RD_CLK_PER_2) rd_clk = ~rd_clk;
     end
   
   initial
     begin	
	wr_clk=1'b1;
	forever #(WR_CLK_PER_2) wr_clk = ~wr_clk;
     end
   
   initial
     begin
	gate_enable=1'b0;
	#1000 gate_enable=1'b0;
	forever #5000 gate_enable=~gate_enable;
     end

   
   ////////////////////////////////////////////////
   //     VARIABLE INITIALIZATION 
   ////////////////////////////////////////////////
   initial
     begin
	//reset pulse
	reset <= 1'd1;
	reset <= #50 1'd0;
     end // initial begin
   

   /////////////////////////////////// 
   //      MODULE INSTANTIATION 
   ///////////////////////////////////

   //use strobe module to generate decimated strobe
   strobe_gen rxsbr(
		    .clock(wr_clk),
		    .reset(reset),
		    .enable(gate_enable),
		    .rate(8'd8),
		    .strobe_in(1'b1),
		    .strobe(dec_clk)
		    );

   fifo_mc dut(
	       .aclr(reset),
	       .data(d_in),
	       .rdclk(rd_clk),
	       .rdreq(rd_req),
	       .wrclk(wr_clk),
	       .wrreq(wr_req),
	       .q(d_out),
	       .rdempty(rd_empty),
	       .rdfull(rd_full),
	       .rdusedw(rd_used),
	       .wrempty(wr_empty),
	       .wrfull(wr_full),
	       .wrusedw(wr_used)
	       );

   /////////////////////////////////////// 
   //         MODULE INSTANTIATION 
   /////////////////////////////////////// 

   //read test vector from file into storage
   initial
     begin	
	$readmemb("data/input.vec", d_in_vec);
	#1500000 $finish;
     end

   //produce output to view waveforms
   initial
     begin
	$dumpfile("fifo_mc_tb.lxt");
	$dumpvars;
     end

   ///////////////////////////////
   //         USB EMULATION
   ///////////////////////////////
   always @ (posedge rd_clk)
     if(reset)
       packet_rdy <= #1 1'b0;
     else 
       packet_rdy <= #1 rd_used[8] ? 1'b1 : 1'b0;
      
   //if packet available and bus not in reset, load counter
   always @ (posedge rd_clk)
     rd_req <= #1 (reset || ~packet_rdy) ? 1'b0 : 1'b1;

   always @ (negedge rd_clk)
     if(reset)
       iter2 <= #1 9'd0;
     else if(rd_req && iter2 != TEST_VECTOR_LENGTH)
       d_out_vec[iter2] <= #1 d_out;
   
   //reset iterator when vector data is read
   always @ (negedge wr_clk)
     begin
	if(reset)
	  iter1 <= #1 9'd0;
	else if(dec_clk)
	  begin
	     iter1 <= (iter1==TEST_VECTOR_LENGTH) ? 9'd0 : iter1 + 9'd1;
	     d_in <= #1 d_in_vec[iter1];
	  end
     end

   assign wr_req = dec_clk;
   
/* -----\/----- EXCLUDED -----\/-----
   always @ (negedge wr_clk)
     wr_req <= #1 dec_clk ? 1'b1 : 1'b0;
 -----/\----- EXCLUDED -----/\----- */
   
endmodule // rx_buffer_mc_ge_tb
