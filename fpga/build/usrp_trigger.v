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
`include "../src/megacells/bustri.v"
`include "../src/megacells/pll.v"
`include "../src/adc_interface.v"
`include "../src/rx_buffer_ge.v"
`include "../src/rx_chain.v"
`include "../src/serial_io.v"
`include "../src/master_control.v"
`include "../src/io_pins.v"
`include "../src/setting_reg.v"
`include "../src/cordic_stage.v"

/////////////////////////////////// MODULE: usrp_trigger ///////////////////////////////////   
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
   inout [15:0] usbdata,  // NB Careful, inout

   ////////////Modification 02/20/2009///////////////////////
   //The following definitions were changed from inouts to inputs
   //for daughterboard GPIO definitions    
   //These are the general purpose i/o's that go to the daughterboard slots
   input wire [15:0] io_tx_a,
   input wire [15:0] io_tx_b,
   input wire [15:0] io_rx_a,
   input wire [15:0] io_rx_b
   );	
   
   assign      MYSTERY_SIGNAL = 1'b0;
   
   wire        clk64,clk128;
   wire        WR = usbctl[0];
   wire        RD = usbctl[1];
   wire        OE = usbctl[2];

   wire        have_space, have_pkt_rdy;
   assign      usbrdy[0] = have_space;
   assign      usbrdy[1] = have_pkt_rdy;

   wire        tx_underrun, rx_overrun;    
   wire        clear_status = FX2_1;
   assign      FX2_2 = rx_overrun;
   assign      FX2_3 = tx_underrun;
   
   wire [15:0] usbdata_out;
   wire [3:0]  dac0mux,dac1mux,dac2mux,dac3mux;
   wire        tx_realsignals;
   wire [3:0]  rx_numchan;
   wire [2:0]  tx_numchan;
   wire [7:0]  interp_rate, decim_rate;
   //wire [31:0] tx_debugbus, rx_debugbus;
   wire        enable_tx, enable_rx;
   wire        tx_dsp_reset, rx_dsp_reset, tx_bus_reset, rx_bus_reset;
   wire [7:0]  settings;

   
   // Tri-state bus macro
   bustri bustri( 
		  .data(usbdata_out),
		  .enabledt(OE),
		  .tridata(usbdata)
		  );

   pll pll(
	   .areset(1'b0),
	   .inclk0(master_clk),
	   .c0(clk64),
	   .c1(),
	   .locked()
	   );

   //assign      clk64 = master_clk;
   
   wire        serial_strobe;
   wire [6:0]  serial_addr;
   wire [31:0] serial_data;

   reg [15:0]  debug_counter;
   reg [15:0]  loopback_i_0,loopback_q_0;
   
`ifdef RX_ON
   
   wire        rx_sample_strobe,strobe_decim,hb_strobe;
   wire [15:0] bb_rx_i0,bb_rx_q0,bb_rx_i1,bb_rx_q1,
	       bb_rx_i2,bb_rx_q2,bb_rx_i3,bb_rx_q3;
   wire        loopback = settings[0];
   wire        counter = settings[1];

   wire [15:0] ddc0_in_i,ddc0_in_q,ddc1_in_i,ddc1_in_q,ddc2_in_i,ddc2_in_q,ddc3_in_i,ddc3_in_q;
   wire [31:0] rssi_0,rssi_1,rssi_2,rssi_3;

/////////////////////////////////// MODULE: adc_interface //////////////////////////////////   
   adc_interface adc_interface(
			       .clock(clk64),.reset(rx_dsp_reset),.enable(1'b1),
			       .serial_addr(serial_addr),.serial_data(serial_data),.serial_strobe(serial_strobe),
			       .rx_a_a(rx_a_a),.rx_b_a(rx_b_a),.rx_a_b(rx_a_b),.rx_b_b(rx_b_b),
			       .rssi_0(rssi_0),.rssi_1(rssi_1),.rssi_2(rssi_2),.rssi_3(rssi_3),
			       .ddc0_in_i(ddc0_in_i),.ddc0_in_q(ddc0_in_q),
			       .ddc1_in_i(ddc1_in_i),.ddc1_in_q(ddc1_in_q),
			       .ddc2_in_i(ddc2_in_i),.ddc2_in_q(ddc2_in_q),
			       .ddc3_in_i(ddc3_in_i),.ddc3_in_q(ddc3_in_q),.rx_numchan(rx_numchan)
			       );
/////////////////////////////////// MODULE: adc_interface //////////////////////////////////   

/////////////////////////////////// MODULE: rx_buffer_ge ///////////////////////////////////   
   rx_buffer_ge rx_buffer_ge
     (
      .usbclk(usbclk),
      .rxclk(clk64),.rxstrobe(hb_strobe),      
      .bus_reset(rx_bus_reset),
      .reset(rx_dsp_reset),
      .gate_enable(io_rx_a[15]),
      .usbdata(usbdata_out),.RD(RD),.have_pkt_rdy(have_pkt_rdy),.rx_overrun(rx_overrun),
      .channels(rx_numchan),
      .ch_0(bb_rx_i0),.ch_1(bb_rx_q0),.ch_2(bb_rx_i1),.ch_3(bb_rx_q1),
      .ch_4(bb_rx_i2),.ch_5(bb_rx_q2),.ch_6(bb_rx_i3),.ch_7(bb_rx_q3),
      .clear_status(clear_status),
      .debugbus()
      );
/////////////////////////////////// MODULE: rx_buffer_ge ///////////////////////////////////   
   
      `ifdef RX_EN_0
/////////////////////////////////// MODULE: rx_chain ///////////////////////////////////////   
   rx_chain #(`FR_RX_FREQ_0,`FR_RX_PHASE_0) rx_chain_0
     (
      .clock(clk64),.reset(1'b0),.enable(enable_rx),
      .decim_rate(decim_rate),.sample_strobe(rx_sample_strobe),.decimator_strobe(strobe_decim),.hb_strobe(hb_strobe),
      .serial_addr(serial_addr),.serial_data(serial_data),.serial_strobe(serial_strobe),
      .i_in(ddc0_in_i),.q_in(ddc0_in_q),.i_out(bb_rx_i0),.q_out(bb_rx_q0),.debugdata(debugdata),.debugctrl(debugctrl)
      );
/////////////////////////////////// MODULE: rx_chain ///////////////////////////////////////   
      `else
   assign      bb_rx_i0=16'd0;
   assign      bb_rx_q0=16'd0;
      `endif
   
      `ifdef RX_EN_1
/////////////////////////////////// MODULE: rx_chain ///////////////////////////////////////   
   rx_chain #(`FR_RX_FREQ_1,`FR_RX_PHASE_1) rx_chain_1
     (
      .clock(clk64),.reset(1'b0),.enable(enable_rx),
      .decim_rate(decim_rate),.sample_strobe(rx_sample_strobe),.decimator_strobe(strobe_decim),.hb_strobe(),
      .serial_addr(serial_addr),.serial_data(serial_data),.serial_strobe(serial_strobe),
      .i_in(ddc1_in_i),.q_in(ddc1_in_q),.i_out(bb_rx_i1),.q_out(bb_rx_q1)
      );
/////////////////////////////////// MODULE: rx_chain ///////////////////////////////////////   
      `else
   assign      bb_rx_i1=16'd0;
   assign      bb_rx_q1=16'd0;
      `endif
   
      `ifdef RX_EN_2
/////////////////////////////////// MODULE: rx_chain ///////////////////////////////////////   
   rx_chain #(`FR_RX_FREQ_2,`FR_RX_PHASE_2) rx_chain_2
     ( 
       .clock(clk64),.reset(1'b0),.enable(enable_rx),
       .decim_rate(decim_rate),.sample_strobe(rx_sample_strobe),.decimator_strobe(strobe_decim),.hb_strobe(),
       .serial_addr(serial_addr),.serial_data(serial_data),.serial_strobe(serial_strobe),
       .i_in(ddc2_in_i),.q_in(ddc2_in_q),.i_out(bb_rx_i2),.q_out(bb_rx_q2)
       );
      `else
/////////////////////////////////// MODULE: rx_chain ///////////////////////////////////////   
   assign      bb_rx_i2=16'd0;
   assign      bb_rx_q2=16'd0;
      `endif

       `ifdef RX_EN_3
/////////////////////////////////// MODULE: rx_chain ///////////////////////////////////////   
   rx_chain #(`FR_RX_FREQ_3,`FR_RX_PHASE_3) rx_chain_3
     ( 
       .clock(clk64),.reset(1'b0),.enable(enable_rx),
       .decim_rate(decim_rate),.sample_strobe(rx_sample_strobe),.decimator_strobe(strobe_decim),.hb_strobe(),
       .serial_addr(serial_addr),.serial_data(serial_data),.serial_strobe(serial_strobe),
       .i_in(ddc3_in_i),.q_in(ddc3_in_q),.i_out(bb_rx_i3),.q_out(bb_rx_q3)
       );
       `else
/////////////////////////////////// MODULE: rx_chain ////////////////////////////////////////   
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


/////////////////////////////////// MODULE: serial_io //////////////////////////////////////   
   serial_io serial_io
     (
      .master_clk(clk64),.serial_clock(SCLK),.serial_data_in(SDI),
      .enable(SEN_FPGA),.reset(1'b0),.serial_data_out(SDO),
      .serial_addr(serial_addr),.serial_data(serial_data),.serial_strobe(serial_strobe),
      .readback_2(capabilities),.readback_3(32'hf0f0931a),
      .readback_4(rssi_0),.readback_5(rssi_1),.readback_6(rssi_2),.readback_7(rssi_3)
      );
/////////////////////////////////// MODULE: serial_io //////////////////////////////////////   

   wire [15:0] reg_0,reg_1,reg_2,reg_3;
   
/////////////////////////////////// MODULE: master_control /////////////////////////////////   
   master_control master_control
     (
      .master_clk(clk64),.usbclk(usbclk),
      .serial_addr(serial_addr),.serial_data(serial_data),.serial_strobe(serial_strobe),
      .tx_bus_reset(),.rx_bus_reset(rx_bus_reset),
      .tx_dsp_reset(),.rx_dsp_reset(rx_dsp_reset),
      .enable_tx(),.enable_rx(enable_rx),
      .interp_rate(interp_rate),.decim_rate(decim_rate),
      .tx_sample_strobe(),.strobe_interp(strobe_interp),
      .rx_sample_strobe(rx_sample_strobe),.strobe_decim(strobe_decim),
      .tx_empty(),
      .debug_0(),.debug_1(),
      .debug_2(),.debug_3(),
      .reg_0(reg_0),.reg_1(reg_1),.reg_2(reg_2),.reg_3(reg_3) 
      );
/////////////////////////////////// MODULE: master_control//////////////////////////////////   
   
/* -----\/----- EXCLUDED -----\/-----
/////////////////////////////////// MODULE: io_pins ////////////////////////////////////////   
   io_pins io_pins
     (
      .io_0(io_tx_a),
      .io_1(io_tx_b),
      .io_2(io_rx_a),
      .io_3(io_rx_b),
      .reg_0(reg_0),.reg_1(reg_1),.reg_2(reg_2),.reg_3(reg_3),
      .clock(clk64),.rx_reset(rx_dsp_reset),.tx_reset(),
      .serial_addr(serial_addr),.serial_data(serial_data),.serial_strobe(serial_strobe)
      );
/////////////////////////////////// MODULE: io_pins ////////////////////////////////////////   
 -----/\----- EXCLUDED -----/\----- */
   
/////////////////////////////////// MODULE: setting_reg ////////////////////////////////////   
   setting_reg #(`FR_MODE) sr_misc(.clock(clk64),.reset(rx_dsp_reset),.strobe(serial_strobe),.addr(serial_addr),.in(serial_data),.out(settings));
/////////////////////////////////// MODULE: setting_reg ////////////////////////////////////   

endmodule // usrp_trigger
/////////////////////////////////// MODULE: usrp_trigger ///////////////////////////////////   


