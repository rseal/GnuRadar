// cosimulated agains systemc implementation - 12Feb2011 
module cordic_theta_map( clock, reset, xin, yin, zin, xout, yout, zout );

parameter XY_WIDTH  = 16;
parameter Z_INPUT_WIDTH   = 16;
parameter Z_OUTPUT_WIDTH  = 15;
parameter Z_GUARD_BITS    = 0;

input wire clock;
input wire reset;

input wire signed [ XY_WIDTH -1:0 ] xin;
input wire signed [ XY_WIDTH -1:0 ] yin;
input wire [ Z_INPUT_WIDTH -1:0  ]  zin;

output reg signed [ XY_WIDTH -1:0 ] xout;
output reg signed [ XY_WIDTH -1:0 ] yout;
output reg signed [ Z_OUTPUT_WIDTH + Z_GUARD_BITS - 1:0  ]  zout;

reg sign;

always @(posedge clock)
begin

   // determine quadrant of performance variable - blocking assignment
   sign = zin[ Z_INPUT_WIDTH -1 ] ^ zin[ Z_INPUT_WIDTH -2 ];

	xout <= sign ? -xin : xin;
	yout <= sign ? -yin : yin;

   // trims MSB.
	zout <= {{(Z_GUARD_BITS+1){zin[Z_INPUT_WIDTH-2]}},zin[Z_INPUT_WIDTH-2:0]};

end


endmodule
