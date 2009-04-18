// -*- verilog -*-
//
//  USRP - Universal Software Radio Peripheral
//
//  Copyright (C) 2003,2005 Matt Ettus
//  Copyright (C) 2007 Corgan Enterprises LLC
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

// March 15, 2009
// Author: Ryan Seal
// This version strips out all of the unused modules (tx, atr, etc...)
// Also adds an external gate_enable signal to provide selective sampling

// Clock, enable, and reset controls for whole system
module master_cntrl 
  ( 
    input master_clk, 
    input usbclk,
    //serial control
    input wire [6:0] serial_addr, 
    input wire [31:0] serial_data, 
    input wire serial_strobe,
    //rx control
    output rx_bus_reset,
    output wire rx_dsp_reset,
    output wire enable_rx,
    output wire [7:0] decim_rate,
    output rx_sample_strobe, 
    output strobe_decim,
    //new addition
    input wire gate_enable,
    output wire [15:0] debug_bus
    );

   // FIXME need a separate reset for all control settings 
   // Master Controls assignments
   wire [7:0] master_controls;
   wire [15:0] dbus;
   
   setting_reg #(`FR_MASTER_CTRL) sr_mstr_ctrl
     (
      .clock(master_clk),
      .reset(1'b0),
      .strobe(serial_strobe),
      .addr(serial_addr),
      .in(serial_data),
      .out(master_controls)
      );
   
   assign      enable_rx = master_controls[1];
   assign      rx_dsp_reset = master_controls[3];
   assign      rx_bus_reset = 1'b0;
   
   //get decimation rate from serial stream
   setting_reg #(`FR_DECIM_RATE) sr_decim
     (
      .clock(master_clk),
      .reset(rx_dsp_reset),
      .strobe(serial_strobe),
      .addr(serial_addr),
      .in(serial_data),
      .out(decim_rate)
      );
   
   assign      rx_sample_strobe = 1'b1;

   reg 	       latched_enable;

   //use flip-flop to sync master_clk with gate_enable
   always @(posedge master_clk)
     latched_enable <= gate_enable ? 1'b1 : 1'b0;
   
   // generate decimation strobe for rx
   strobe_gen 
     ds(
	.clock(master_clk),
	.reset(rx_dsp_reset),
	.enable(latched_enable),
	.rate(decim_rate),
	.strobe_in(rx_sample_strobe),
	.strobe(strobe_decim),
	.dbus(dbus)
	);


   assign      debug_bus = dbus;
   
   /* -----\/----- EXCLUDED -----\/-----
    assign  debug_bus[0] = master_clk;
    assign  debug_bus[1] = usbclk;
    assign  debug_bus[2] = rx_dsp_reset;
    assign  debug_bus[3] = rx_bus_reset;
    assign  debug_bus[4] = gate_enable;
    assign  debug_bus[5] = strobe_decim;
    bug_bus[6] = ;
    assign  debug_bus[7] = dbus[9]; //strobe
    assign  debug_bus[8] = dbus[10]; //strobe_in
    -----/\----- EXCLUDED -----/\----- */
   
   
   //dbus{reset,enable,strobe_in,strobe,counter};
   
endmodule // master_control
