module data_tag
(
	input clock,
   input reset,
   input strobe,
   input enable,
   output tag
);

reg strobe_en;
reg strobe_en_neg;
reg reset_int; 

always @(posedge clock )
begin
	reset_int <= (~enable && strobe_en && strobe_en_neg ) || reset;
end

assign tag = strobe_en && ~strobe_en_neg;

always @(posedge strobe or posedge reset_int )
   strobe_en <= reset_int ? 1'b0 : enable;

always @(negedge strobe or posedge reset_int )
   strobe_en_neg <= reset_int ? 1'b0 : enable;

endmodule

