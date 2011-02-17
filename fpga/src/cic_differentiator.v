
module cic_differentiator( clock, reset, d_in, d_out);

parameter INPUT_WIDTH  = 16;
parameter OUTPUT_WIDTH = 16;
localparam SHIFT = INPUT_WIDTH-OUTPUT_WIDTH;

input wire clock;
input wire reset;
input wire [ INPUT_WIDTH-1:0 ] d_in;
output reg [ OUTPUT_WIDTH-1:0 ] d_out;

reg [ INPUT_WIDTH-1:0 ] memory;
reg [ INPUT_WIDTH-1:0 ] temp;


always @( posedge clock, posedge reset )
	if(reset)
	begin
		memory <= #1 0;
      d_out <= #1 0;
	end
	else
	begin
		temp = d_in - memory;
		memory <= #1 d_in;
		d_out <= #1 temp[ (INPUT_WIDTH-1)-:OUTPUT_WIDTH ];
	end

endmodule


