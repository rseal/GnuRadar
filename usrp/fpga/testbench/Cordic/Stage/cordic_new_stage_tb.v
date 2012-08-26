`timescale 1ns/100ps

module cordic_new_stage_tb;

//test vector to load data from file
parameter TEST_VECTOR_LENGTH = 500;
parameter CLK_PER_2          = 10;
parameter ENABLE_PER         = 5000;
parameter STROBE_PER         = 50;
parameter SIM_TIME           = 1e5;

parameter INPUT_WIDTH    = 16;
parameter OUTPUT_WIDTH   = 16;
parameter Z_INPUT_WIDTH  = 16;
parameter Z_OUTPUT_WIDTH = 16;

parameter STAGE_NUMBER_0 = 0;
parameter STAGE_NUMBER_1 = 1;
parameter STAGE_NUMBER_2 = 2;
parameter STAGE_NUMBER_3 = 3;

reg [INPUT_WIDTH-1:0] x_in;
reg [INPUT_WIDTH-1:0] y_in;
reg [INPUT_WIDTH-1:0] z_in;

wire [OUTPUT_WIDTH-1:0] x_out;
wire [OUTPUT_WIDTH-1:0] y_out;
wire [OUTPUT_WIDTH-1:0] z_out;

parameter c00 =  16'd8192;
parameter c01 =  16'd4836;
parameter c02 =  16'd2555;
parameter c03 =  16'd1297;
parameter c04 =  16'd651;
parameter c05 =  16'd326;
parameter c06 =  16'd163;
parameter c07 =  16'd81;
parameter c08 =  16'd41;
parameter c09 =  16'd20;
parameter c10 =  16'd10;
parameter c11 =  16'd5;
parameter c12 =  16'd3;
parameter c13 =  16'd1;
parameter c14 =  16'd1;
parameter c15 =  16'd0;
parameter c16 =  16'd0;

reg clk,rst;

initial
begin	
clk=1'b1;
forever #(CLK_PER_2) clk = ~clk;
end

always @(negedge clk)
	if(rst)
	begin
		x_in = 100;
		y_in = 50;
		z_in = 10;
	end

	//VARIABLE Initialization
	initial
	begin
		//reset pulse
		rst <= 1'b0;
		rst <= #10 1'b1;
		rst <= #100 1'b0;
	end

	cordic_new_stage 
	#(
		.XY_INPUT_WIDTH( INPUT_WIDTH), .XY_OUTPUT_WIDTH( OUTPUT_WIDTH),
		.Z_INPUT_WIDTH( Z_INPUT_WIDTH), .Z_OUTPUT_WIDTH( Z_OUTPUT_WIDTH), .STAGE_NUMBER( STAGE_NUMBER_1)
	) 
	cns( .xin( x_in ), .yin( y_in ), .zin( z_in ), .xout( x_out ), .yout( y_out ), .zout( z_out ), .atan_const( c00 ) );

	//read test vector from file into storage
	initial
	begin	
	$dumpfile("cordic_new_stage_tb.lxt");
	$dumpvars;
	#(SIM_TIME) $finish;
end

endmodule 


