// Notes:
// The parameters defined here were designed for a 4-stage CIC filter
// with R_min = 4 and R_max = 128. Using the hogenauer bit-pruning method 
// with N=4 and R_min = 4, we can safely remove 1 bit per stage. 
//
// Since the decimation is variable, the gain is variable, and this 
// must be compensated for at the output stage. To simplify this 
// design and keep gain consistent, the only valid decimation values
// are: 4,8,16,32,64,128
//
// Bit gain is computed using R**N and normalizing this value
// at the output becomes b_msb = N*log2(R)-1.

module cic_4stage
(
	clock,
	reset,
	dec_clk,
	dec_rate,
	din,
	dout
);

// Input/Output bit-widths and gain bit definitions.
localparam INPUT_WIDTH  = 16;
localparam OUTPUT_WIDTH = 16;
localparam GAIN_WIDTH   = 28;

input wire clock;
input wire reset;
input wire dec_clk;
input wire [7:0] dec_rate;
input wire [INPUT_WIDTH-1:0] din;
output reg [OUTPUT_WIDTH-1:0] dout;

// MSB of gain-compensated register
localparam BIT_MAX = INPUT_WIDTH + GAIN_WIDTH - 1;

// Bit-width definitions for integrator stages.
localparam SIG_0_MSB = BIT_MAX - 0;
localparam SIG_1_MSB = BIT_MAX - 1;
localparam SIG_2_MSB = BIT_MAX - 2;
localparam SIG_3_MSB = BIT_MAX - 3;
localparam SIG_4_MSB = BIT_MAX - 4;
localparam SIG_5_MSB = BIT_MAX - 5;
localparam SIG_6_MSB = BIT_MAX - 6;
localparam SIG_7_MSB = BIT_MAX - 7;
localparam SIG_8_MSB = BIT_MAX - 8;

// Interconnecting wires for integrator stages.
reg  [SIG_0_MSB:0] sig_00;
wire [SIG_1_MSB:0] sig_01;
wire [SIG_2_MSB:0] sig_12;
wire [SIG_3_MSB:0] sig_23;
wire [SIG_4_MSB:0] sig_34;
wire [SIG_5_MSB:0] sig_45;
wire [SIG_6_MSB:0] sig_56;
wire [SIG_7_MSB:0] sig_67;
wire [SIG_8_MSB:0] sig_78;

// Holds the scaled output's msb.
wire [ 5:0 ] b_msb;

// register, sign-extend, and place data in wider register.
always @(din) begin
   sig_00 <= $signed( din );
end

// Integrator stages.
cic_integrator #(SIG_0_MSB+1,SIG_1_MSB+1) cic_int0 ( .clock(clock), .reset(reset), .d_in(sig_00), .d_out(sig_01));
cic_integrator #(SIG_1_MSB+1,SIG_2_MSB+1) cic_int1 ( .clock(clock), .reset(reset), .d_in(sig_01), .d_out(sig_12));
cic_integrator #(SIG_2_MSB+1,SIG_3_MSB+1) cic_int2 ( .clock(clock), .reset(reset), .d_in(sig_12), .d_out(sig_23));
cic_integrator #(SIG_3_MSB+1,SIG_4_MSB+1) cic_int3 ( .clock(clock), .reset(reset), .d_in(sig_23), .d_out(sig_34)); 

// Differentiator stages.
cic_differentiator #(SIG_4_MSB+1,SIG_5_MSB+1) cic_dec0 ( .clock(dec_clk), .reset(reset), .d_in(sig_34), .d_out(sig_45));
cic_differentiator #(SIG_5_MSB+1,SIG_6_MSB+1) cic_dec1 ( .clock(dec_clk), .reset(reset), .d_in(sig_45), .d_out(sig_56));
cic_differentiator #(SIG_6_MSB+1,SIG_7_MSB+1) cic_dec2 ( .clock(dec_clk), .reset(reset), .d_in(sig_56), .d_out(sig_67));
cic_differentiator #(SIG_7_MSB+1,SIG_8_MSB+1) cic_dec3 ( .clock(dec_clk), .reset(reset), .d_in(sig_67), .d_out(sig_78)); 

cic_msb_adjust #(.WIDTH( OUTPUT_WIDTH )) cma( .dec_rate( dec_rate ), .msb( b_msb ) );

// Normalize data.
always @(posedge dec_clk) 
   dout <= {sig_78[SIG_8_MSB],sig_78[ (b_msb-1)-:OUTPUT_WIDTH ]} + $signed(~sig_78[ b_msb-OUTPUT_WIDTH+2] && sig_78[ b_msb-OUTPUT_WIDTH+1 ]);


endmodule
