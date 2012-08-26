
module cordic_12stage ( clock, reset, xin, yin, zin, xout, yout, zout );

parameter XY_WIDTH       = 16;
parameter XY_GUARD_BITS  = 2;
parameter Z_GUARD_BITS   = 2;
parameter Z_INPUT_WIDTH  = 16;
parameter Z_OUTPUT_WIDTH = 5;
parameter ATAN_WIDTH     = 5'd15;

localparam c00 =  15'd8192;
localparam c01 =  14'd4836;
localparam c02 =  13'd2555;
localparam c03 =  12'd1297;
localparam c04 =  11'd651;
localparam c05 =  10'd326;
localparam c06 =  9'd163;
localparam c07 =  8'd81;
localparam c08 =  7'd41;
localparam c09 =  6'd20;
localparam c10 =  5'd10;
localparam c11 =  4'd5;

input wire clock;
input wire reset;

input wire  signed [ XY_WIDTH -1:0 ] xin;
input wire  signed [ XY_WIDTH -1:0 ] yin;
input wire  [ Z_INPUT_WIDTH - 1:0  ]  zin;

output reg  signed [ XY_WIDTH -1:0 ] xout;
output reg  signed [ XY_WIDTH -1:0 ] yout;
output reg  signed [ Z_OUTPUT_WIDTH - 1:0  ]  zout;

wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] x_map;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] y_map;
wire signed [ Z_INPUT_WIDTH + Z_GUARD_BITS - 2: 0 ] z_map;

wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] x_00;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] x_01;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] x_02;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] x_03;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] x_04;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] x_05;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] x_06;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] x_07;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] x_08;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] x_09;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] x_10;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] x_11;

wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] y_00;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] y_01;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] y_02;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] y_03;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] y_04;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] y_05;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] y_06;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] y_07;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] y_08;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] y_09;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] y_10;
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1:0 ] y_11;

wire signed [ Z_INPUT_WIDTH + Z_GUARD_BITS -3:0 ] z_00;
wire signed [ Z_INPUT_WIDTH + Z_GUARD_BITS -4:0 ] z_01;
wire signed [ Z_INPUT_WIDTH + Z_GUARD_BITS -5:0 ] z_02;
wire signed [ Z_INPUT_WIDTH + Z_GUARD_BITS -6:0 ] z_03;
wire signed [ Z_INPUT_WIDTH + Z_GUARD_BITS -7:0 ] z_04;
wire signed [ Z_INPUT_WIDTH + Z_GUARD_BITS -8:0 ] z_05;
wire signed [ Z_INPUT_WIDTH + Z_GUARD_BITS -9:0 ] z_06;
wire signed [ Z_INPUT_WIDTH + Z_GUARD_BITS -10:0 ] z_07;
wire signed [ Z_INPUT_WIDTH + Z_GUARD_BITS -11:0 ] z_08;
wire signed [ Z_INPUT_WIDTH + Z_GUARD_BITS -12:0 ] z_09;
wire signed [ Z_INPUT_WIDTH + Z_GUARD_BITS -13:0 ] z_10;
wire signed [ Z_INPUT_WIDTH + Z_GUARD_BITS -14:0 ] z_11;


	//assign out = {{(bits_out-bits_in){in[bits_in-1]}},in};
// Extend input data to 18-bits internally.
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1 :0 ]  x_ext = xin; 
wire signed [ XY_WIDTH + XY_GUARD_BITS - 1 :0 ]  y_ext = yin; 

cordic_theta_map
#(
.XY_WIDTH ( XY_WIDTH + XY_GUARD_BITS ),
.Z_INPUT_WIDTH ( Z_INPUT_WIDTH ),
.Z_GUARD_BITS( Z_GUARD_BITS ),
.Z_OUTPUT_WIDTH ( Z_INPUT_WIDTH - 1 )
)
ctm ( .clock ( clock ), .reset ( reset ), .xin ( x_ext ), .yin ( y_ext ), .zin ( zin ), .xout ( x_map  ), .yout ( y_map ), .zout ( z_map ) );

cordic_new_stage
#(
.XY_WIDTH ( XY_WIDTH + XY_GUARD_BITS ),
.Z_INPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 1 ), .Z_OUTPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 2 ),
.ATAN_WIDTH( ATAN_WIDTH ),
.STAGE_NUMBER ( 0 )
)
cns_0 ( .clock( clock ), .reset( reset ), .xin ( x_map ), .yin ( y_map ), .zin ( z_map ), .xout ( x_00 ), .yout ( y_00 ), .zout ( z_00 ), .atan_const ( c00 ) );

cordic_new_stage
#(
.XY_WIDTH ( XY_WIDTH + XY_GUARD_BITS ),
.Z_INPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS  - 2), .Z_OUTPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 3 ),
.ATAN_WIDTH( ATAN_WIDTH - 1 ),
.STAGE_NUMBER ( 1 )
)
cns_1 ( .clock( clock ), .reset( reset ), .xin ( x_00 ), .yin ( y_00 ), .zin ( z_00 ), .xout ( x_01 ), .yout ( y_01 ), .zout ( z_01 ), .atan_const ( c01 ) );

cordic_new_stage
#(
.XY_WIDTH ( XY_WIDTH + XY_GUARD_BITS ),
.Z_INPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 3 ), .Z_OUTPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 4),
.ATAN_WIDTH( ATAN_WIDTH - 2 ),
.STAGE_NUMBER ( 2 )
)
cns_2 ( .clock( clock ), .reset( reset ), .xin ( x_01 ), .yin ( y_01 ), .zin ( z_01 ), .xout ( x_02 ), .yout ( y_02 ), .zout ( z_02 ), .atan_const ( c02 ) );

cordic_new_stage
#(
.XY_WIDTH ( XY_WIDTH + XY_GUARD_BITS ),
.Z_INPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 4 ), .Z_OUTPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 5),
.ATAN_WIDTH( ATAN_WIDTH - 3 ),
.STAGE_NUMBER ( 3 )
)
cns_3 ( .clock( clock ), .reset( reset ), .xin ( x_02 ), .yin ( y_02 ), .zin ( z_02 ), .xout ( x_03 ), .yout ( y_03 ), .zout ( z_03 ), .atan_const ( c03 ) );

cordic_new_stage
#(
.XY_WIDTH ( XY_WIDTH + XY_GUARD_BITS ),
.Z_INPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS -5 ), .Z_OUTPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 6 ),
.ATAN_WIDTH( ATAN_WIDTH - 4 ),
.STAGE_NUMBER ( 4 )
)
cns_4 ( .clock( clock ), .reset( reset ), .xin ( x_03 ), .yin ( y_03 ), .zin ( z_03 ), .xout ( x_04 ), .yout ( y_04 ), .zout ( z_04 ), .atan_const ( c04 ) );

cordic_new_stage
#(
.XY_WIDTH ( XY_WIDTH + XY_GUARD_BITS ),
.Z_INPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 6 ), .Z_OUTPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 7  ),
.ATAN_WIDTH( ATAN_WIDTH - 5 ),
.STAGE_NUMBER ( 5 )
)
cns_5 ( .clock( clock ), .reset( reset ), .xin ( x_04 ), .yin ( y_04 ), .zin ( z_04 ), .xout ( x_05 ), .yout ( y_05 ), .zout ( z_05 ), .atan_const ( c05 ) );

cordic_new_stage
#(
.XY_WIDTH ( XY_WIDTH + XY_GUARD_BITS ),
.Z_INPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 7), .Z_OUTPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 8 ),
.ATAN_WIDTH( ATAN_WIDTH - 6 ),
.STAGE_NUMBER ( 6 )
)
cns_6 ( .clock( clock ), .reset( reset ), .xin ( x_05 ), .yin ( y_05 ), .zin ( z_05 ), .xout ( x_06 ), .yout ( y_06 ), .zout ( z_06 ), .atan_const ( c06 ) );

cordic_new_stage
#(
.XY_WIDTH ( XY_WIDTH + XY_GUARD_BITS ),
.Z_INPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 8 ), .Z_OUTPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 9  ),
.ATAN_WIDTH( ATAN_WIDTH - 7 ),
.STAGE_NUMBER ( 7 )
)
cns_7 ( .clock( clock ), .reset( reset ), .xin ( x_06 ), .yin ( y_06 ), .zin ( z_06 ), .xout ( x_07 ), .yout ( y_07 ), .zout ( z_07 ), .atan_const ( c07 ) );

cordic_new_stage
#(
.XY_WIDTH ( XY_WIDTH + XY_GUARD_BITS ),
.Z_INPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 9 ), .Z_OUTPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 10 ),
.ATAN_WIDTH( ATAN_WIDTH - 8 ),
.STAGE_NUMBER ( 8 )
)
cns_8 ( .clock( clock ), .reset( reset ), .xin ( x_07 ), .yin ( y_07 ), .zin ( z_07 ), .xout ( x_08 ), .yout ( y_08 ), .zout ( z_08 ), .atan_const ( c08 ) );

cordic_new_stage
#(
.XY_WIDTH ( XY_WIDTH + XY_GUARD_BITS ),
.Z_INPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 10 ), .Z_OUTPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 11 ),
.ATAN_WIDTH( ATAN_WIDTH - 9 ),
.STAGE_NUMBER ( 9 )
)
cns_9 ( .clock( clock ), .reset( reset ), .xin ( x_08 ), .yin ( y_08 ), .zin ( z_08 ), .xout ( x_09 ), .yout ( y_09 ), .zout ( z_09 ), .atan_const ( c09 ) );

cordic_new_stage
#(
.XY_WIDTH ( XY_WIDTH + XY_GUARD_BITS ),
.Z_INPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 11 ), .Z_OUTPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 12 ),
.ATAN_WIDTH( ATAN_WIDTH - 10),
.STAGE_NUMBER ( 10 )
)
cns_10 ( .clock( clock ), .reset( reset ), .xin ( x_09 ), .yin ( y_09 ), .zin ( z_09 ), .xout ( x_10 ), .yout ( y_10 ), .zout ( z_10 ), .atan_const ( c10 ) );

cordic_new_stage
#(
.XY_WIDTH ( XY_WIDTH + XY_GUARD_BITS ),
.Z_INPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 12 ), .Z_OUTPUT_WIDTH ( Z_INPUT_WIDTH + Z_GUARD_BITS - 13 ),
.ATAN_WIDTH( ATAN_WIDTH - 11),
.STAGE_NUMBER ( 11 )
)
cns_11 ( .clock( clock ), .reset( reset ), .xin ( x_10 ), .yin ( y_10 ), .zin ( z_10 ), .xout ( x_11 ), .yout ( y_11 ), .zout ( z_11 ), .atan_const ( c11 ) );

always @ ( posedge clock )
begin
xout <= x_11[ XY_WIDTH:1 ] ;//+ ( x_11[ 1 ] && x_11[ 0 ] );
yout <= y_11[ XY_WIDTH:1 ] ;//+ ( y_11[ 1 ] && y_11[ 0 ] );
zout <= z_11[ ( Z_INPUT_WIDTH + Z_GUARD_BITS -14 )-:Z_OUTPUT_WIDTH ];
end

endmodule
