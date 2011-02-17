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

// Following defines conditionally include RX path circuitry

`include "config.vh"	// resolved relative to project root

module rx_chain
  (input clock,
   input reset,
   input enable,
   input wire [7:0] decim_rate,
   input sample_strobe,
   input decimator_strobe,
   input [6:0] serial_addr, input [31:0] serial_data, input serial_strobe,
   input wire [15:0] i_in,
   input wire [15:0] q_in,
   output wire [15:0] i_out,
   output wire [15:0] q_out,
   output wire [15:0] debugdata,
   output wire [15:0] debugctrl
   );

   parameter FREQADDR = 0;
   parameter PHASEADDR = 0;
   
   wire [31:0] phase;
   wire [15:0] bb_i, bb_q;
   wire [15:0] hb_in_i, hb_in_q;
   
   // 32-bit phase accumulator block. We take the upper 16 bits and use this
   // for down-conversion in the cordic block.
    phase_acc #(FREQADDR,PHASEADDR,32) rx_phase_acc
     (.clk(clock),.reset(reset),.enable(enable),
      .serial_addr(serial_addr),.serial_data(serial_data),.serial_strobe(serial_strobe),
      .strobe(sample_strobe),.phase(phase) );

   // 12-stage cordic block. This block prunes z-variable bits, 1 per stage,
   // since we know that each successive stage will reduce the error by
   // a factor of 2.
   cordic_12stage c12s( .clock( clock ), .reset( reset ), .xin( i_in ), .yin( q_in ), .zin( phase[31:16] ), .xout( bb_i ), .yout( bb_q ), .zout(  ) );

	// Original CORDIC implementation
	//cordic cordic_old( .clock( clock ), .reset( reset ), .enable(1'b1), .xi( i_in ), .yi( q_in ), .zi( phase[31:16] ), .xo( bb_i ), .yo( bb_q ), .zo( ) );

   
   // 5-stage CIC filter for in-phase data - this version implements bit
	// pruning.
	cic_5stage cic_decim_i_0
	( 
		.clock( clock ), 
		.reset( reset ), 
		.dec_rate( decim_rate+1'b1 ), 
		.dec_clk( decimator_strobe ),
		.din( bb_i ), 
		.dout( i_out )
	);

   // 5-stage CIC filter for quadrature data - this version implements bit
	// pruning.
	cic_5stage cic_decim_q_0
	( 
		.clock( clock ), 
		.reset( reset ), 
		.dec_rate( decim_rate+1'b1 ), 
		.dec_clk( decimator_strobe ),
		.din( bb_q ), 
		.dout( q_out )
	);

//cic_decim cic_decim_i_0 ( 
	//.clock( clock ) ,
	//.reset( reset ),
	//.enable( 1'b1 ),
	//.rate( decim_rate),
	//.strobe_in( 1'b1),
	//.strobe_out( decimator_strobe ),
	//.signal_in( bb_i),
	//.signal_out( i_out)
//);

//cic_decim cic_decim_q_0 ( 
	//.clock( clock ) ,
	//.reset( reset ),
	//.enable( 1'b1 ),
	//.rate( decim_rate),
	//.strobe_in( 1'b1),
	//.strobe_out( decimator_strobe ),
	//.signal_in( bb_q),
	//.signal_out( q_out)
//);


   endmodule // rx_chain
