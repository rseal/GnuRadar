
module cordic_new_stage( clock, reset, xin, yin, zin, xout, yout, zout, atan_const );

parameter STAGE_NUMBER   = 0;
parameter XY_WIDTH       = 16;
parameter Z_INPUT_WIDTH  = 16;
parameter Z_OUTPUT_WIDTH = 16;
parameter ATAN_WIDTH     = 16;

input wire clock;
input wire reset;

input  wire [ ATAN_WIDTH-1:0     ] atan_const;
input  wire [ XY_WIDTH-1:0       ] xin;
input  wire [ XY_WIDTH-1:0       ] yin;
input  wire [ Z_INPUT_WIDTH-1:0  ] zin;

output reg  [ XY_WIDTH-1:0       ] xout;
output reg  [ XY_WIDTH-1:0       ] yout;
output reg  [ Z_OUTPUT_WIDTH-1:0 ] zout;

wire sign = zin[ Z_INPUT_WIDTH-1 ];
//wire signed [ Z_INPUT_WIDTH - 1:0 ] z_trim = zin + (sign ? atan_const : -atan_const );

wire [ XY_WIDTH-1:0] x_shift = xin >>> STAGE_NUMBER;
wire [ XY_WIDTH-1:0] y_shift = yin >>> STAGE_NUMBER;

wire [ XY_WIDTH-1:0 ] x_temp, y_temp;
wire [ Z_INPUT_WIDTH-1:0 ] z_temp;

always @(posedge clock or posedge reset ) begin

   if( reset )
   begin
      xout <= 0;
      yout <= 0;
      zout <= 0;
   end
   else
   begin
      // Adding this code increases the size by almost 15% - but the RTL
      // schematic looks the same ( likely optimizations using add/sub
      // block???)
      //xout <= xin + (( sign ? yin : -yin ) >>> STAGE_NUMBER );
      //yout <= yin + (( sign ? -xin : xin  ) >>> STAGE_NUMBER );
      //// trim MSBs
      //zout <= z_trim[Z_OUTPUT_WIDTH-1:0];
      xout <= x_temp;
      yout <= y_temp;
      zout <= z_temp[Z_OUTPUT_WIDTH-1:0];

   end
end

cordic_shift_adder 
#( .A_WIDTH( XY_WIDTH ), .B_WIDTH( XY_WIDTH-STAGE_NUMBER), .O_WIDTH( XY_WIDTH ) ) 
csa_x( .a(xin), .b(y_shift[ XY_WIDTH-STAGE_NUMBER-1:0] ), .out(x_temp), .sign(~sign) );

cordic_shift_adder 
#(.A_WIDTH( XY_WIDTH ), .B_WIDTH( XY_WIDTH-STAGE_NUMBER), .O_WIDTH( XY_WIDTH ) ) 
csa_y( .a(yin), .b(x_shift[ XY_WIDTH-STAGE_NUMBER-1:0] ), .out(y_temp), .sign(sign) );

cordic_shift_adder 
#(.A_WIDTH( Z_INPUT_WIDTH ), .B_WIDTH( ATAN_WIDTH), .O_WIDTH( Z_INPUT_WIDTH ))
csa_z( .a(zin), .b(atan_const), .out(z_temp), .sign(~sign) );

endmodule
