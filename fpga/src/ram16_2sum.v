
module ram16_2sum
(
   input clock,
   input we, 
   input [3:0] wr_addr, 
   input [15:0] wr_data,
   input [3:0] rd_addr1, 
   input [3:0] rd_addr2,
   output reg [15:0] sum
);

reg  signed [15:0] ram_array [0:9];
reg  signed [15:0] a,b;
wire signed [16:0] sum_int;

// The write address is designed to go beyond the boundary. Check for this
// condition and wrap-around to provide correct behavior.
always @(posedge clock)
begin
   if( we )
   begin
      ram_array[ wr_addr ] <= wr_data;
   end
end

always @(posedge clock)
begin
   a <= #1 ram_array[rd_addr1];
   b <= #1 ram_array[rd_addr2];
end

//Shouldn't signed values automatically handle the sign extension?
assign sum_int = a + b;//{a[15],a} + {b[15],b};

// Convergent ( round-to-even ) rounding on output.
always @(posedge clock)
   sum <= #1 sum_int[16:1] + (~sum_int[1] && sum_int[0]);

endmodule // ram16_2sum
