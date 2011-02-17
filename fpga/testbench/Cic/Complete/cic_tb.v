`timescale 1ns/100ps

module cic_integrator_tb;

//test vector to load data from file
localparam TEST_VECTOR_LENGTH = 500;
localparam CLK_PER_2          = 10;
localparam ENABLE_PER         = 5000;
localparam STROBE_PER         = 50;
localparam SIM_TIME           = 1e5;

localparam INPUT_WIDTH  = 16;
localparam OUTPUT_WIDTH = 16;

localparam DECIMATION = 8'd8;

integer idx=0;
integer fid, fid_w, fid_out_2, status;

reg [INPUT_WIDTH-1:0] test_vector [0:TEST_VECTOR_LENGTH-1];

reg [INPUT_WIDTH-1:0] d_in;
wire signed [OUTPUT_WIDTH-1:0] d_out;
wire signed [OUTPUT_WIDTH-1:0] d_out2;

reg clk,rst;
reg [7:0] decimation;
wire strobe;

initial
begin	
clk=1'b1;
forever #(CLK_PER_2) clk = ~clk;
end

always @(posedge clk)
begin
   if(rst)
   begin
      d_in <= 0;
   end
   else
   begin
      status = $fscanf( fid, "%f", d_in);
      idx = idx == TEST_VECTOR_LENGTH-1 ? 0 : idx + 1;
   end
end

/*
VARIABLE Initialization
*/
  initial
  begin
     // decimation is entered as 1 less than 
     // the desired value due to strobe_gen 
     // output.
     decimation = DECIMATION;

     //reset pulse
     rst <= 1'b0;
     rst <= #10 1'b1;
     rst <= #100 1'b0;
  end

  strobe_gen strobe_gen1 ( .clock( clk ), .reset( rst ), .enable( 1'b1 ), .rate( decimation-8'd1 ), .strobe( strobe ), .dbus());

  cic_5stage cic
  (
     .clock( clk ),
     .reset( rst ),
     .dec_clk( strobe ),
     .dec_rate( decimation ),
     .din( d_in ),
     .dout( d_out )
  );

  // OLD CIC filter
  cic_decim cic_decim( 
	  .clock(clk),
	  .reset(rst),
	  .enable(1'b1),
	  .rate(decimation-8'd1),
	  .strobe_in(1'b1),
	  .strobe_out(strobe),
	  .signal_in(d_in),
	  .signal_out(d_out2)
  );

  initial begin
     fid = $fopen("data/input.dat","r");
     fid_w = $fopen("data/output.dat","w");
	  fid_out_2 = $fopen("data/output2.dat","w");
  end

  always @(posedge strobe) begin
     if(!rst) begin
        $fwrite(fid_w,"%f\n",d_out);
        $fwrite(fid_out_2,"%f\n",d_out2);
	  end
  end

  //read test vector from file into storage
  initial
  begin	
  $dumpfile("cic_tb.lxt");
  $dumpvars;
  #(SIM_TIME) $finish;
 end

 endmodule 


