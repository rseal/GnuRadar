

module ram16 ( clock, reset, we, wr_addr, wr_data, rd_addr, rd_data );

input clock;
input reset;
input we; 
input [3:0] wr_addr; 
input [15:0] wr_data;
input [3:0] rd_addr; 
output reg [15:0] rd_data;

reg [15:0] ram_array [0:9];
   
always @(posedge clock)
begin
	rd_data <= ram_array[ rd_addr ];
end

always @(posedge clock)
begin
	if( we )
	begin
		ram_array[ wr_addr ] <= #1 wr_data;
	end
end

endmodule // ram16

