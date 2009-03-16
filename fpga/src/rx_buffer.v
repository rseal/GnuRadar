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

`include "../../include/fpga_regs_common.v"
`include "../../include/fpga_regs_standard.v"
`include "../../src/megacells/fifo_old.v"
`include "../../src/ch_sel.v"
`include "../../src/fifo_monitor.v"

module rx_buffer
  (
   input rd_clk,
   input wr_clk,
   input reset,
   input bus_reset,
  
   input rd_req,
   output reg packet_rdy,
   output wire overflow,
   input clear_status,
   input strobe,
   input wire [3:0] channels,
  
   input wire [15:0] ch_0,
   input wire [15:0] ch_1,
   input wire [15:0] ch_2,
   input wire [15:0] ch_3,
   input wire [15:0] ch_4,
   input wire [15:0] ch_5,
   input wire [15:0] ch_6,
   input wire [15:0] ch_7,
   output [15:0] d_out,
   output [31:0] debugbus
   );
   
   reg [15:0] 	 d_in;
   
   reg [15:0] 	 din_0,din_1,din_2,din_3,
		 din_4,din_5,din_6,din_7;
   
   wire [11:0] 	 rd_level;
   wire 	 wr_full,rd_full;
   wire 	 rd_empty;
   wire 	 wr_overflow,rd_overflow;
   
   wire [4:0] 	 bitwidth;
   wire [3:0] 	 bitshift;
   wire [3:0] 	 phase;   
   
   // USB Read Side of FIFO
   always @(negedge rd_clk)
     packet_rdy <= (rd_level >= 256);

   // 257 Bug Fix
   reg [8:0] 	 read_count;
   always @(negedge rd_clk)
     read_count <= (rd_req && ~bus_reset) ? read_count + 9'd1 : 9'd0;
   
   fifo_old rxfifo
     (
      .data (d_in),
      .wrreq(~wr_full & (phase !=0)),
      .wrclk ( wr_clk ),
      .wrfull ( wr_full ),
      .wrusedw ( ),
      .q (d_out),
      .rdreq ( rd_req & ~read_count[8] ), 
      .rdclk ( ~rd_clk ),
      .rdfull (rd_full ),
      .rdempty (rd_empty ),
      .rdusedw ( rd_level ),
      .aclr ( reset )
      );

   always @(posedge wr_clk)
     if (strobe)
       begin
          din_0 <= ch_0;
          din_1 <= ch_1;
          din_2 <= ch_2;
          din_3 <= ch_3;
          din_4 <= ch_4;
          din_5 <= ch_5;
          din_6 <= ch_6;
          din_7 <= ch_7;
       end
   
   /*
    * MODULE: ch_sel
    */
   ch_sel chs
     (
      .clk(wr_clk),
      .reset(wr_full),
      .strobe(strobe),
      .num_ch(channels),
      .channel(phase)
      );
   
   
   /* -----\/----- EXCLUDED -----\/-----
    
    always @(posedge wr_clk)
    if(reset || phase==channels)
    phase <= 4'd0;
    else if(phase == 0)
    begin
    if(strobe)
    phase <= 4'd1;
        end
    else if(~wr_full)
    phase <= phase + 4'd1;
    -----/\----- EXCLUDED -----/\----- */
   
   
   always @*
     case(phase)
       4'd1 : d_in = din_0;
       4'd2 : d_in = din_1;
       4'd3 : d_in = din_2;
       4'd4 : d_in = din_3;
       4'd5 : d_in = din_4;
       4'd6 : d_in = din_5;
       4'd7 : d_in = din_6;
       4'd8 : d_in = din_7;
       default : d_in = 16'hFFFF;
     endcase // case(phase)

   /*
    * MODULE: fifo_monitor
    */    
   fifo_monitor fm
     (
      .wr_clk(wr_clk),
      .rd_clk(rd_clk),
      .reset(reset),
      .wr_full(wr_full),
      .rd_full(rd_full),
      .wr_clear(clear_status),
      .rd_clear(clear_status),
      .wr_overflow(wr_overflow),
      .rd_overflow(rd_overflow)
      );

   assign overflow = wr_overflow || rd_overflow;
   
    
/* -----\/----- EXCLUDED -----\/-----
   // Detect overrun
   reg clear_status_dsp, rx_overrun_dsp;
   always @(posedge wr_clk)
     clear_status_dsp <= clear_status;
   
   always @(negedge rd_clk)
     overflow <= rx_overrun_dsp;
   
   always @(posedge wr_clk)
     if(reset || clear_status_dsp)
       rx_overrun_dsp <= 1'b0;
     else if(wr_full)
       rx_overrun_dsp <= 1'b1;
 -----/\----- EXCLUDED -----/\----- */
      
   assign debugbus[0]     = reset;
   assign debugbus[1]     = wr_clk;
   assign debugbus[2]     = rd_clk;
   assign debugbus[3]     = wr_full;
   //   assign debugbus[4]     = wr_empty;
   assign debugbus[5]     = wr_overflow;
   assign debugbus[6]     = rd_full;
   assign debugbus[7]     = rd_empty;
   assign debugbus[8]     = rd_overflow;
   
   
   
endmodule // rx_buffer

