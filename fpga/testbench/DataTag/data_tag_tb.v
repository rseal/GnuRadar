`timescale 1ns/100ps

module data_tag_tb;
   
   //test vector to load data from file
   parameter TEST_VECTOR_LENGTH=500;
   parameter CLK_PER_2=10;
   parameter ENABLE_PER=5000;
   parameter STROBE_PER=50;
   parameter SIM_TIME=1e5;
   
   reg clk,rst;
   reg enable;
   wire strobe;
   wire tag;

   initial
   begin	
   clk=1'b1;
   forever #(CLK_PER_2) clk = ~clk;
   end

   initial
   begin	
   enable=1'b1;
   forever #(ENABLE_PER) enable = ~enable;
   end

  /*
  VARIABLE Initialization
  */
 initial
 begin
    //reset pulse
    rst <= 1'b0;
    rst <= #10 1'b1;
    rst <= #100 1'b0;
 end

 /*
 *MODULE: strobe_gen
 */
strobe_gen sgn
(
   .clock(clk),
   .reset(rst),
   .enable(1'b1),
   .rate(8'd63), // Rate should be 1 LESS THAN your desired divide ratio
   .strobe_in(1'b1),
   .strobe(strobe),
   .dbus()
);


 data_tag dt
 (
    .clk(clk),
    .reset(rst),
    .strobe(strobe),
    .enable(enable),
    .tag(tag)
 );


//read test vector from file into storage
initial
begin	
$dumpfile("data_tag_tb.lxt");
$dumpvars;
#(SIM_TIME) $finish;
  end

  endmodule // ch_sel_tb


