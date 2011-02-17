`timescale 1ns/100ps

module cordic_12stage_tb;

//test vector to load data from file
localparam TEST_VECTOR_LENGTH = 500;
localparam CLK_PER_2          = 15.68;
localparam ENABLE_PER         = 5000;
localparam STROBE_PER         = 50;
localparam SIM_TIME           = 1e5;

localparam INPUT_WIDTH    = 16;
localparam OUTPUT_WIDTH   = 16;
localparam Z_INPUT_WIDTH  = 16;
localparam Z_OUTPUT_WIDTH = 5;

localparam DATA_FILENAME   = "data/input.dat";
localparam PHASE_FILENAME  = "data/phase.dat";
localparam OUTPUT_FILENAME = "data/output.dat";

reg signed [INPUT_WIDTH-1:0] x_in;
reg signed [INPUT_WIDTH-1:0] y_in;
reg signed [INPUT_WIDTH-1:0] x_temp;
reg signed [INPUT_WIDTH-1:0] z_temp;
reg [INPUT_WIDTH-1:0] z_in;

wire signed [OUTPUT_WIDTH-1:0] x_out;
wire signed [OUTPUT_WIDTH-1:0] y_out;
wire signed [Z_OUTPUT_WIDTH-1:0] z_out;

reg clk,rst;
integer fid_data,fid_phase, fid_output;
integer status;

initial
begin	
clk=1'b1;
forever #(CLK_PER_2) clk = ~clk;
end

always @(posedge clk) begin
	if(rst) begin
		x_in <= 0;
      y_in <= 0;
      z_in <= 0;
   end
   else begin
      status = $fscanf( fid_data, "%d", x_temp);
      status = $fscanf( fid_phase, "%d", z_temp);
      x_in <= x_temp;
      z_in <= z_temp;
      //$display(" data = %d", x_in );
      //$display(" phase = %d", z_in );
	end
end

always @( posedge clk) begin
   if(!rst) begin
      $fwrite( fid_output, "%f\n", x_out);
   end
end


//VARIABLE Initialization
initial begin
   //reset pulse
   rst <= 1'b0;
   rst <= #10 1'b1;
   rst <= #100 1'b0;
end

cordic_12stage 
#(
	.XY_WIDTH( INPUT_WIDTH), .Z_INPUT_WIDTH( Z_INPUT_WIDTH), .Z_OUTPUT_WIDTH( Z_OUTPUT_WIDTH)
) 
c12s( .clock( clk ), .reset( rst ), .xin( x_in ), .yin( y_in ), .zin( z_in ), .xout( x_out ), .yout( y_out ), .zout( z_out ) );

// Original CORDIC implementation
//cordic cordic_old( .clock( clk ), .reset( rst ), .enable(1'b1), .xi( x_in ), .yi( y_in ), .zi( z_in ), .xo( x_out ), .yo( y_out ), .zo( z_out ) );

//read test vector from file into storage
initial begin	
fid_data   = $fopen( DATA_FILENAME, "r" );
fid_phase  = $fopen( PHASE_FILENAME, "r" );
fid_output = $fopen( OUTPUT_FILENAME, "w" );
status = $fscanf( fid_data, "%d", x_in);
$dumpfile("cordic_12stage_tb.lxt");
$dumpvars;
#(SIM_TIME) $finish;
end

endmodule 


