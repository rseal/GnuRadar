
module cic_integrator( clock, reset, d_in, d_out);

parameter INPUT_WIDTH  = 16;
parameter OUTPUT_WIDTH = 16;

input wire clock;
input wire reset;
input wire [ INPUT_WIDTH-1:0 ] d_in;
output reg [ OUTPUT_WIDTH-1:0 ] d_out;

reg [ INPUT_WIDTH-1:0 ] memory;
reg [ INPUT_WIDTH-1:0 ] temp;

always @(posedge clock or posedge reset )
begin
	if( reset )
	begin
      memory<= #1 0;
      d_out <= #1 0;
	end
	else
	begin
		temp = memory + d_in;
      memory <= #1 temp;
      d_out <= #1 temp[ (INPUT_WIDTH-1)-:OUTPUT_WIDTH ];
   end
end

endmodule


