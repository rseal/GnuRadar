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



module strobe_gen 
  ( input clock,
    input reset,
    input enable,
    input [7:0] rate, // Rate should be 1 LESS THAN your desired divide ratio
    input strobe_in,
    output reg strobe );
   
//   parameter width = 8;
   
   reg [7:0] counter;

   //bug --- causes glitch that may or may not be harmful -- 03/12/09
   // ~|counter = nor all bits of counter => all bits 0 produces 1
   // strobe = 1 when counter==0 and enable==1 and strobe_in==1 for one clock cycle
   //assign strobe = ~|counter && enable && strobe_in;
   
   always @(posedge clock)
     if(reset || ~enable)
       counter <=  8'd0;
     else if(strobe_in)
       begin
	  counter <= (counter==8'b0) ? rate : counter - 8'd1;
	  strobe  <= (counter==8'b0) ? 1'b1 : 1'b0;
       end
endmodule // strobe_gen
