// -*- verilog -*-
//
//  USRP - Universal Software Radio Peripheral
//
//  Copyright (C) 2003,2004 Matt Ettus
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

// Top level module for a full setup with DUCs and DDCs

// Define DEBUG_OWNS_IO_PINS if we're using the daughterboard i/o pins
// for debugging info.  NB, This can kill the m'board and/or d'board if you
// have anything except basic d'boards installed.

// Uncomment the following to include optional circuitry

`include "config.vh"
`include "../include/fpga_regs_common.v"
`include "../include/fpga_regs_standard.v"

/*
* MODULE: usrp_trigger
*/
module usrp_trigger
(
   output MYSTERY_SIGNAL,
   input master_clk,
   input SCLK,
   input SDI,
   inout SDO,
   input SEN_FPGA,

   input FX2_1,
   output FX2_2,
   output FX2_3,

   input wire [11:0] rx_a_a,
   input wire [11:0] rx_b_a,
   input wire [11:0] rx_a_b,
   input wire [11:0] rx_b_b,

   output wire [13:0] tx_a,
   output wire [13:0] tx_b,

   output wire TXSYNC_A,
   output wire TXSYNC_B,

   // USB interface

   input usbclk,
   input wire [2:0] usbctl,
   output wire [1:0] usbrdy,
   inout [15:0] usbdata,

   //GPIO
   output wire [15:0] io_tx_a,
      output wire [15:0] io_tx_b,
      input  wire [15:0] io_rx_a,
      output wire [15:0] io_rx_b
   );	

   wire   gate_enable;
   assign gate_enable = io_rx_a[15];

   assign MYSTERY_SIGNAL = 1'b0;

   wire   clk64,clk128;
   wire   WR = usbctl[0];
   wire   RD = usbctl[1];
   wire   OE = usbctl[2];

   wire   have_space, packet_rdy;
   assign usbrdy[0] = have_space;
   assign usbrdy[1] = packet_rdy;

   wire   rx_overrun;
   wire   clear_status = FX2_1;
   assign FX2_2 = rx_overrun;

   wire [15:0] usbdata_out;

   wire [3:0]  rx_numchan;
   wire [7:0]  decim_rate;
   wire        enable_rx;
   wire        rx_dsp_reset, rx_bus_reset;
   wire [7:0]  settings;
   wire        clk48;
   wire        serial_strobe;
   wire [6:0]  serial_addr;
   wire [31:0] serial_data;
   reg 	       latch,rst;
   reg [2:0]   cnt;

   /*
   * MODULE: bustri
   */
  bustri bustri
  ( 
     .data(usbdata_out),
     .enabledt(OE),
     .tridata(usbdata)
  );

  /*
  * MODULE: pll64
  */
  pll64 pll
  (
     .areset(1'b0),
     .inclk0(master_clk),
     .c0(clk64),
     .c1(),
     .locked()
  );

  /*
  * MODULE: pll48
  */
  pll48 pll2
  (
     .areset(1'b0),
     .inclk0(usbclk),
     .c0(clk48),
     .c1(),
     .locked()
  );


  `ifdef RX_ON

     wire rx_sample_strobe,strobe_decim,hb_strobe;

     wire [15:0] bb_rx_i0,bb_rx_q0,bb_rx_i1,bb_rx_q1,
        bb_rx_i2,bb_rx_q2,bb_rx_i3,bb_rx_q3;

     wire [15:0] ddc0_in_i,ddc0_in_q,
        ddc1_in_i,ddc1_in_q,
        ddc2_in_i,ddc2_in_q,
        ddc3_in_i,ddc3_in_q;

     wire [31:0] rssi_0,rssi_1,
        rssi_2,rssi_3;

     /*
     * MODULE: adc_interface
     */
    adc_interface adci
    (
       .clock(clk64),
       .reset(rx_dsp_reset),
       .enable(1'b1),
       .serial_addr(serial_addr),
       .serial_data(serial_data),
       .serial_strobe(serial_strobe),
       .rx_a_a(rx_a_a),
       .rx_b_a(rx_b_a),
       .rx_a_b(rx_a_b),
       .rx_b_b(rx_b_b),
       .rssi_0(rssi_0),
       .rssi_1(rssi_1),
       .rssi_2(rssi_2),
       .rssi_3(rssi_3),
       .ddc0_in_i(ddc0_in_i),
       .ddc0_in_q(ddc0_in_q),
       .ddc1_in_i(ddc1_in_i),
       .ddc1_in_q(ddc1_in_q),
       .ddc2_in_i(ddc2_in_i),
       .ddc2_in_q(ddc2_in_q),
       .ddc3_in_i(ddc3_in_i),
       .ddc3_in_q(ddc3_in_q),
       .rx_numchan(rx_numchan)
    );

    /*
    * MODULE: rx_buffer
    */
   fifo fnew
   (
      .rd_clk(clk48),
      .wr_clk(clk64),
      .reset(rx_dsp_reset),
      .bus_reset(rx_bus_reset),
      .rd_req(RD),
      .packet_rdy(packet_rdy),
      .overflow(rx_overrun),
      .clear_status(clear_status),
      .strobe(hb_strobe),
      .gate_enable(gate_enable),
      .channels(rx_numchan),
      .din0(bb_rx_i0), .din1(bb_rx_q0),
      .din2(bb_rx_i1), .din3(bb_rx_q1),
      .din4(bb_rx_i2), .din5(bb_rx_q2),
      .din6(bb_rx_q3), .din7(bb_rx_i3),
      .dout(usbdata_out),
      .debugbus(io_rx_b)
   );

   `ifdef RX_EN_0
      /*
      * MODULE: rx_chain (channel 0)
      */
     rx_chain #(`FR_RX_FREQ_0,`FR_RX_PHASE_0) 
     rxc_0
     (
        .clock(clk64),
        .reset(~gate_enable),
        .enable(enable_rx),
        .decim_rate(decim_rate),
        .sample_strobe(rx_sample_strobe),
        .decimator_strobe(strobe_decim),
        .hb_strobe(hb_strobe),
        .serial_addr(serial_addr),
        .serial_data(serial_data),
        .serial_strobe(serial_strobe),
        .i_in(ddc0_in_i),
        .q_in(ddc0_in_q),
        .i_out(bb_rx_i0),
        .q_out(bb_rx_q0),
        .debugdata(),
        .debugctrl(io_tx_a)
     );
  `else
     assign      bb_rx_i0=16'd0;
     assign      bb_rx_q0=16'd0;
  `endif

  `ifdef RX_EN_1
     /*
     * MODULE: rx_chain (channel 1)
     */
    rx_chain #(`FR_RX_FREQ_1,`FR_RX_PHASE_1) 
    rxc_1
    (
       .clock(clk64),
       .reset(~gate_enable),
       .enable(enable_rx),
       .decim_rate(decim_rate),
       .sample_strobe(rx_sample_strobe),
       .decimator_strobe(strobe_decim),
       .hb_strobe(),
       .serial_addr(serial_addr),
       .serial_data(serial_data),
       .serial_strobe(serial_strobe),
       .i_in(ddc1_in_i),
       .q_in(ddc1_in_q),
       .i_out(bb_rx_i1),
       .q_out(bb_rx_q1)
    );
 `else
    assign      bb_rx_i1=16'd0;
    assign      bb_rx_q1=16'd0;
 `endif

 `ifdef RX_EN_2
    /*
    * MODULE: rx_chain (channel 2)
    */
   rx_chain #(`FR_RX_FREQ_2,`FR_RX_PHASE_2) 
   rxc_2
   ( 
      .clock(clk64),
      .reset(~gate_enable),
      .enable(enable_rx),
      .decim_rate(decim_rate),
      .sample_strobe(rx_sample_strobe),
      .decimator_strobe(strobe_decim),
      .hb_strobe(),
      .serial_addr(serial_addr),
      .serial_data(serial_data),
      .serial_strobe(serial_strobe),
      .i_in(ddc2_in_i),
      .q_in(ddc2_in_q),
      .i_out(bb_rx_i2),
      .q_out(bb_rx_q2)
   );
`else
   assign      bb_rx_i2=16'd0;
   assign      bb_rx_q2=16'd0;
`endif

`ifdef RX_EN_3
   /*
   * MODULE: rx_chain (channel 3)
   */
  rx_chain #(`FR_RX_FREQ_3,`FR_RX_PHASE_3) 
  rxc_3
  ( 
     .clock(clk64),
     .reset(~gate_enable),
     .enable(enable_rx),
     .decim_rate(decim_rate),
     .sample_strobe(rx_sample_strobe),
     .decimator_strobe(strobe_decim),
     .hb_strobe(),
     .serial_addr(serial_addr),
     .serial_data(serial_data),
     .serial_strobe(serial_strobe),
     .i_in(ddc3_in_i),
     .q_in(ddc3_in_q),
     .i_out(bb_rx_i3),
     .q_out(bb_rx_q3)
  );
`else
   assign      bb_rx_i3=16'd0;
   assign      bb_rx_q3=16'd0;
`endif

`endif //  `ifdef RX_ON

// Control Functions
wire [31:0] capabilities;
assign      capabilities[7] =   `TX_CAP_HB;
assign      capabilities[6:4] = `TX_CAP_NCHAN;
assign      capabilities[3] =   `RX_CAP_HB;
assign      capabilities[2:0] = `RX_CAP_NCHAN;

/*
* MODULE: serial_io
*/
   serial_io sio
   (
      .master_clk(clk64),
      .serial_clock(SCLK),
      .serial_data_in(SDI),
      .enable(SEN_FPGA),
      .reset(1'b0),
      .serial_data_out(SDO),
      .serial_addr(serial_addr),
      .serial_data(serial_data),
      .serial_strobe(serial_strobe),
      .readback_2(capabilities),
      .readback_3(32'hf0f0931a),
      .readback_4(rssi_0),
      .readback_5(rssi_1),
      .readback_6(rssi_2),
      .readback_7(rssi_3)
   );
   /*
   * MODULE: master_control
   */
  master_cntrl mcm
  (
     .master_clk(clk64),
     .usbclk(clk48),
     .serial_addr(serial_addr),
     .serial_data(serial_data),
     .serial_strobe(serial_strobe),
     .rx_bus_reset(rx_bus_reset),
     .rx_dsp_reset(rx_dsp_reset),
     .enable_rx(enable_rx),
     .decim_rate(decim_rate),
     .rx_sample_strobe(rx_sample_strobe),
     .strobe_decim(strobe_decim),
     .gate_enable(gate_enable),
     .debug_bus(io_tx_b)
  );

  /* 
  * MODULE: setting_reg (misc settings)
  */
 setting_reg #(`FR_MODE) 
 sr_misc(
    .clock(clk64),
    .reset(rx_dsp_reset),
    .strobe(serial_strobe),
    .addr(serial_addr),
    .in(serial_data),
    .out(settings)
 );

 endmodule // usrp_trigger
