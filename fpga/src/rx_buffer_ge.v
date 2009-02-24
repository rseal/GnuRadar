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

`include "megacells/fifo_4k_18.v"
//`include "setting_reg.v"

module rx_buffer_ge
  ( // Read/USB side

    input usbclk,
    input bus_reset,
    output [15:0] usbdata,
    input RD,
    output reg have_pkt_rdy,
    output reg rx_overrun,
    input clear_status,
    // Write/DSP side
    input rxclk,
    input gate_enable,
    input reset,  // DSP side reset (used here), do not reset registers
    input rxstrobe,
    input wire [3:0] channels,
    input wire [15:0] ch_0,
    input wire [15:0] ch_1,
    input wire [15:0] ch_2,
    input wire [15:0] ch_3,
    input wire [15:0] ch_4,
    input wire [15:0] ch_5,
    input wire [15:0] ch_6,
    input wire [15:0] ch_7,
    output [31:0] debugbus
    );

   reg [3:0] 	  phase;
   
   //wire [15:0] 	  fifodata;
   reg [15:0] 	  fifodata;
   
   wire [11:0] 	  rxfifolevel;
   wire 	  rx_full;
   
   // USB Read Side of FIFO
   always @(negedge usbclk)
     have_pkt_rdy <= (rxfifolevel >= 256);

   // 257 Bug Fix
   reg [8:0] 	  read_count;

   //modified 01/21/09
   always @(negedge usbclk)
     read_count <= (bus_reset || ~RD) ? 9'd0 : read_count + 1;
   
   // FIFO
   wire 	  ch0_in, ch0_out, iq_out;
   assign 	  ch0_in = (phase == 4'b1);
   wire		  usb_read_empty;
   
   fifo_4k_18 rxfifo 
     ( 
       // DSP Write Side
       .data ( {ch0_in, phase[0], fifodata} ),
       .wrreq(~rx_full && (phase !=4'd0) && gate_enable),
       .wrclk ( rxclk ),
       .wrfull ( rx_full ),
       .wrempty ( ),
       .wrusedw ( ),
       // USB Read Side
       .q ( {ch0_out,iq_out,usbdata} ),
       .rdreq ( RD & ~read_count[8] ), 
       .rdclk ( ~usbclk ),
       .rdfull ( ),
       .rdempty ( usb_read_empty),
       .rdusedw ( rxfifolevel ),
       // Async, shared
       .aclr ( reset ) 
       );

   // DSP Write Side of FIFO
   reg [15:0] 	  ch_0_reg;
   reg [15:0] 	  ch_1_reg;
   reg [15:0] 	  ch_2_reg;
   reg [15:0] 	  ch_3_reg;
   reg [15:0] 	  ch_4_reg;
   reg [15:0] 	  ch_5_reg;
   reg [15:0] 	  ch_6_reg;
   reg [15:0] 	  ch_7_reg;

   always @(posedge rxclk)
     if (rxstrobe)
       begin
          ch_0_reg <= ch_0;
          ch_1_reg <= ch_1;
          ch_2_reg <= ch_2;
          ch_3_reg <= ch_3;
          ch_4_reg <= ch_4;
          ch_5_reg <= ch_5;
          ch_6_reg <= ch_6;
          ch_7_reg <= ch_7;
       end

   //simplified logic - added 01/21/09 - test against rx_buffer

   wire en1,en2,en3;
   wire [1:0] state;
   
   assign en1 = (phase == channels) && ~rx_full;
   assign en2 = (phase == 4'd0) && rxstrobe;
   assign en3 = (phase != channels && phase != 4'd0 && ~rx_full);
   assign state = {en3,en2};

   always @(posedge rxclk)
     begin
	if(reset || en1)
	  phase <= 4'd0;
	else
	  begin
	     case(state)
	       3'd01: phase <= 4'd1;
	       3'b10: phase <= phase + 4'd1;
	       default: phase <= phase;
	     endcase // case(state)
	  end
     end // always @ (posedge rxclk)

   always @(phase)
     case(phase)
       4'd1 : fifodata = ch_0_reg;
       4'd2 : fifodata = ch_1_reg;
       4'd3 : fifodata = ch_2_reg;
       4'd4 : fifodata = ch_3_reg;
       4'd5 : fifodata = ch_4_reg;
       4'd6 : fifodata = ch_5_reg;
       4'd7 : fifodata = ch_6_reg;
       4'd8 : fifodata = ch_7_reg;
       default : fifodata = 16'hFFFF;
     endcase // case(phase)
      
   // Detect overrun
   reg clear_status_dsp, rx_overrun_dsp;
   always @(posedge rxclk)
     clear_status_dsp <= clear_status;

   always @(negedge usbclk)
     rx_overrun <= rx_overrun_dsp;

   always @(posedge rxclk)
     if(reset)
       rx_overrun_dsp <= 1'b0;
     else if(rxstrobe & (phase != 0))
       rx_overrun_dsp <= 1'b1;
     else if(clear_status_dsp)
       rx_overrun_dsp <= 1'b0;
   
   // Debug bus
   //
   // 15:0  rxclk  domain => TXA 15:0
   // 31:16 usbclk domain => RXA 15:0
   
   assign debugbus[0]     = reset;
   assign debugbus[1]     = usb_read_empty;
   assign debugbus[2]     = rxstrobe;
   assign debugbus[6:3]   = channels;
   assign debugbus[7]     = rx_full;
   assign debugbus[11:8]  = phase;
   assign debugbus[12]    = ch0_in;
   assign debugbus[13]    = clear_status_dsp;
   assign debugbus[14]    = rx_overrun_dsp;
   assign debugbus[15]    = rxclk;
   assign debugbus[16]    = bus_reset;   
   assign debugbus[17]    = RD;
   assign debugbus[18]    = have_pkt_rdy;
   assign debugbus[19]    = rx_overrun;
   assign debugbus[20]    = read_count[0];
   assign debugbus[21]    = read_count[8];
   assign debugbus[22]    = ch0_out;
   assign debugbus[23]    = iq_out;
   assign debugbus[24]    = clear_status;
   assign debugbus[30:25] = 0;   
   assign debugbus[31]    = usbclk;
   
endmodule // rx_buffer

