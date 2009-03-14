// -*- verilog -*-
//
//  USRP - Universal Software Radio Peripheral
//
//  Copyright (C) 2003 Matt Ettus
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 51 Franklin Street, Boston, MA  02110-1301  USA
//

// Interface to Cypress FX2 bus
// A packet is 512 Bytes, the fifo has 4096 lines of 18 bits each

`include "../include/fpga_regs_common.v"
`include "../include/fpga_regs_standard.v"
`include "ch_select.v"
`include "megacells/fifo_mc.v"

module rx_fifo
  (
   //clocks
   input rd_clk,
   input wr_clk,
   //reset
   input reset,
   input bus_reset,
   //control/status signals
   input RD,
   input clear_status,
   input gate_enable,
   input rxstrobe,
   input wire [3:0] channels,
   output reg packet_rdy,
   output reg overflow,
   //data i/o
   input wire [15:0] ch_0,
   input wire [15:0] ch_1,
   input wire [15:0] ch_2,
   input wire [15:0] ch_3,
   input wire [15:0] ch_4,
   input wire [15:0] ch_5,
   input wire [15:0] ch_6,
   input wire [15:0] ch_7,
   output [15:0] usbdata,
   output [15:0] debugbus
   );

   wire 	 rd_full_any,wr_empty_any;
   wire 	 wr_full_any,rd_empty_any;
   
   reg 		 rd_full_bit;
   reg [7:0] 	 wr_req_mask;
   
   wire [7:0] 	 rd_req, rd_empty, rd_full,
		 wr_req, wr_empty, wr_full;
   
   wire [8:0] 	 rd_level_0, rd_level_1, rd_level_2, rd_level_3,
		 rd_level_4, rd_level_5, rd_level_6, rd_level_7;
   
   // dsp-side data registers
   reg [15:0] 	 din_0, din_1, din_2, din_3,
		 din_4, din_5, din_6, din_7;
   
   //usb-side data path
   wire [15:0] 	 dout_0, dout_1, dout_2, dout_3,
		 dout_4, dout_5, dout_6, dout_7;
   
   reg [8:0] 	 rd_count, wr_count, read_count;
   wire 	 rd_enable, wr_enable;

   //full and empty buffers masked with channels in use
   assign 	 wr_full_any  = (wr_full & wr_req_mask)  != 8'd0 ? 1'b1 : 1'b0;
   assign 	 rd_full_any  = (rd_full & wr_req_mask)  != 8'd0 ? 1'b1 : 1'b0;
   assign 	 wr_empty_any = (wr_empty & wr_req_mask) != 8'd0 ? 1'b1 : 1'b0;
   assign 	 rd_empty_any = (rd_empty & wr_req_mask) != 8'd0 ? 1'b1 : 1'b0;

   //mask for write requests into fifo
   always @(*)
     begin
	case(channels)
	  4'd1: wr_req_mask <= 8'b00000001;
	  4'd2: wr_req_mask <= 8'b00000011;
	  4'd4: wr_req_mask <= 8'b00001111;
	  4'd8: wr_req_mask <= 8'b11111111;
	  default: wr_req_mask <= 8'b00000001;
	endcase // case(channels)
     end
   
   //set the proper level for packet reading
   always @(*)
     begin
	case(channels)
	  4'd1: rd_full_bit <= 8;
	  4'd2: rd_full_bit <= 7;
	  4'd4: rd_full_bit <= 6;
	  4'd8: rd_full_bit <= 5;
	  default: rd_full_bit <=8;
	endcase // case(channels)
     end

   assign rd_enable = ~read_count[8] && RD;
   assign wr_enable = rxstrobe && gate_enable;
   //write request on rxstrobe && gate_enable
   assign wr_req = wr_enable ? 8'b11111111 & wr_req_mask : 8'b00000000 & wr_req_mask;

   always @ (negedge wr_clk)
     packet_rdy <= wr_count[7] ? 1'b1 : rd_count[7] ? 1'b0 : packet_rdy;
   
   // 257 Bug Fix
   always @(negedge rd_clk)
     if(bus_reset)
       read_count <= 9'd0;
     else if(RD)
       read_count <= read_count + 9'd1;
     else
       read_count <= 9'd0;

   //write counter to track fifo input data
   always @(posedge wr_clk)
     begin
	if(reset)
	  wr_count <= 9'd0;
	else if(wr_enable)
	  wr_count <= wr_count[7] || wr_empty_any ? 9'd0 : wr_count + 9'd1;
     end

   //read counter to track fifo output data
   always @(posedge rd_clk)
     begin
	if(reset)
	  rd_count <= 9'd0;
	else if(rd_req[0])
	  rd_count <= rd_count[7] || rd_empty_any ? 9'd0 : rd_count + 9'd1;
     end
   
   //register input data channels
   always @(negedge wr_clk)
     if (wr_enable)
       begin
          din_0 <= ch_0;
          din_1 <= ch_1;
          din_2 <= ch_2;
          din_3 <= ch_3;
          din_4 <= ch_4;
          din_5 <= ch_5;
          din_6 <= ch_6;
          din_7 <= ch_7;
       end // if (wr_enable)
   
   //channel 0 16x512 fifo
   fifo_mc buf_0(
		 .aclr(reset),
		 .data(din_0),
		 .rdclk(~rd_clk),
		 .rdreq(rd_req[0] && rd_enable),
		 .wrclk(wr_clk),
		 .wrreq(wr_req[0] ),
		 .q(dout_0),
		 .rdempty(rd_empty[0]),
		 .rdfull(rd_full[0]),
		 .rdusedw(rd_level_0),
		 .wrempty(wr_empty[0]),
		 .wrfull(wr_full[0]),
		 .wrusedw()
		 );

   //channel 1 16x512 fifo
   fifo_mc buf_1(
		 .aclr(reset),
		 .data(din_1),
		 .rdclk(~rd_clk),
		 .rdreq(rd_req[1] && rd_enable),
		 .wrclk(wr_clk),
		 .wrreq(wr_req[1] ),
		 .q(dout_1),
		 .rdempty(rd_empty[1]),
		 .rdfull(rd_full[1]),
		 .rdusedw(rd_level_1),
		 .wrempty(wr_empty[1]),
		 .wrfull(wr_full[1]),
		 .wrusedw()
		 );

   //channel 2 16x512 fifo
   fifo_mc buf_2(
		 .aclr(reset),
		 .data(din_2),
		 .rdclk(~rd_clk),
		 .rdreq(rd_req[2] && rd_enable),
		 .wrclk(wr_clk),
		 .wrreq(wr_req[2] ),
		 .q(dout_2),
		 .rdempty(rd_empty[2]),
		 .rdfull(rd_full[2]),
		 .rdusedw(rd_level_2),
		 .wrempty(wr_empty[2]),
		 .wrfull(wr_full[2]),
		 .wrusedw()
		 );

   //channel 3 16x512 fifo
   fifo_mc buf_3(
		 .aclr(reset),
		 .data(din_3),
		 .rdclk(~rd_clk),
		 .rdreq(rd_req[3] && rd_enable),
		 .wrclk(wr_clk),
		 .wrreq(wr_req[3] ),
		 .q(dout_3),
		 .rdempty(rd_empty[3]),
		 .rdfull(rd_full[3]),
		 .rdusedw(rd_level_3),
		 .wrempty(wr_empty[3]),
		 .wrfull(wr_full[3]),
		 .wrusedw()
		 );

   //channel 4 16x512 fifo
   fifo_mc buf_4(
		 .aclr(reset),
		 .data(din_4),
		 .rdclk(~rd_clk),
		 .rdreq(rd_req[4] && rd_enable),
		 .wrclk(wr_clk),
		 .wrreq(wr_req[4] ),
		 .q(dout_4),
		 .rdempty(rd_empty[4]),
		 .rdfull(rd_full[4]),
		 .rdusedw(rd_level_4),
		 .wrempty(wr_empty[4]),
		 .wrfull(wr_full[4]),
		 .wrusedw()
		 );

   //channel 5 16x512 fifo
   fifo_mc buf_5(
		 .aclr(reset),
		 .data(din_5),
		 .rdclk(~rd_clk),
		 .rdreq(rd_req[5] && rd_enable),
		 .wrclk(wr_clk),
		 .wrreq(wr_req[5] ),
		 .q(dout_5),
		 .rdempty(rd_empty[5]),
		 .rdfull(rd_full[5]),
		 .rdusedw(rd_level_5),
		 .wrempty(wr_empty[5]),
		 .wrfull(wr_full[5]),
		 .wrusedw()
		 );

   //channel 6 16x512 fifo
   fifo_mc buf_6(
		 .aclr(reset),
		 .data(din_6),
		 .rdclk(~rd_clk),
		 .rdreq(rd_req[6] && rd_enable),
		 .wrclk(wr_clk),
		 .wrreq(wr_req[6] ),
		 .q(dout_6),
		 .rdempty(rd_empty[6]),
		 .rdfull(rd_full[6]),
		 .rdusedw(rd_level_6),
		 .wrempty(wr_empty[6]),
		 .wrfull(wr_full[6]),
		 .wrusedw()
		 );

   //channel 7 16x512 fifo
   fifo_mc buf_7(
		 .aclr(reset),
		 .data(din_7),
		 .rdclk(~rd_clk),
		 .rdreq(rd_req[7] && rd_enable),
		 .wrclk(wr_clk),
		 .wrreq(wr_req[7] ),
		 .q(dout_7),
		 .rdempty(rd_empty[7]),
		 .rdfull(rd_full[7]),
		 .rdusedw(rd_level_7),
		 .wrempty(wr_empty[7]),
		 .wrfull(wr_full[7]),
		 .wrusedw()
		 );

   //output-side read request selector - verified (check posedge/negedge)
   ch_select cs(
			  .clk(~rd_clk),
			  .rst(reset),
			  .strobe(rd_enable),
			  .numch(channels),
			  .out(rd_req),
			  .d_in({dout_7,dout_6,dout_5,dout_4,dout_3,dout_2,dout_1,dout_0}),
			  .d_out(usbdata)
			  );
   
   
   //rewrite this stuff and stick it in a module   
   // Detect overrun
   reg clear_status_dsp, overflow_dsp;
   always @(posedge wr_clk)
     clear_status_dsp <= clear_status;
   
   always @(negedge rd_clk)
     overflow <= overflow_dsp;
   
   always @(posedge wr_clk)
     if(reset)
       overflow_dsp <= 1'b0;
     else if(rxstrobe && wr_full_any)
       //change for debugging
       overflow_dsp <= 1'b1;
     else if(clear_status_dsp)
       overflow_dsp <= 1'b0;
   

   //debug signals piped to logic analyzer through d-board headers
   assign debugbus[0]  = wr_clk;
   assign debugbus[1]  = rxstrobe;
   assign debugbus[2]  = gate_enable;
   assign debugbus[3]  = wr_enable;
   assign debugbus[4]  = wr_req[0];
   assign debugbus[5]  = wr_count[7];
   assign debugbus[6]  = overflow_dsp;
   assign debugbus[7]  = wr_full_any;
   assign debugbus[8]  = wr_empty_any;
   assign debugbus[9]  = rd_full_any;
   assign debugbus[10] = rd_empty_any;
   assign debugbus[11] = read_count[8];
   assign debugbus[12] = packet_rdy;
   assign debugbus[13] = rd_level_0[8];
   assign debugbus[14] = rd_enable;
   assign debugbus[15] = rd_count[7];
   
   
endmodule // rx_fifo



