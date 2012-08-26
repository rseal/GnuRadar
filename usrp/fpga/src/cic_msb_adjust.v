
module cic_msb_adjust( dec_rate, msb );

parameter WIDTH= 6'd16;

input wire [ 7:0 ] dec_rate;
output reg [ 5:0 ] msb;

always @(dec_rate)
begin
	case( dec_rate )
		8'd8    : msb  <= WIDTH + 6'd15 - 6'd16;
		8'd16   : msb  <= WIDTH + 6'd20 - 6'd16;
		8'd32   : msb  <= WIDTH + 6'd25 - 6'd16;
		8'd64   : msb  <= WIDTH + 6'd30 - 6'd16;
		8'd128  : msb  <= WIDTH + 6'd35 - 6'd16;
		default : msb  <= WIDTH + 6'd15 - 6'd16;
	endcase
end

endmodule
