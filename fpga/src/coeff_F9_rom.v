

module coeff_F9_rom (input clock, input [2:0] addr, output reg [15:0] data);

always @(posedge clock)
   case (addr)
      3'd0 : data <= #1 16'd26530;
      3'd1 : data <= #1 16'd16329;
      3'd2 : data <= #1 -16'd4135;
      3'd3 : data <= #1 16'd1389;
      3'd4 : data <= #1 -16'd375;
      3'd5 : data <= #1 16'd58;
   endcase // case(addr)

endmodule // coeff_rom


