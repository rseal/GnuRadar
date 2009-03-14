
module ch_select
  (
   input clk,
   input rst,
   input strobe,
   input [3:0] numch,
   output reg [7:0] out,
   input [127:0] d_in,
   output reg [15:0] d_out
   );

   reg [2:0] sel;

   always @ (posedge clk)
     begin
	if(rst)
	  sel <= 3'd0;
	else if(strobe)
	  sel <= (sel == numch-4'd1) ? 3'd0 : sel + 3'd1;
     end
   
   always @ (*)
     begin
	if(rst)
	  begin
	     out <= 8'b00000001;
	     d_out <= d_in[15:0];
	  end
	case(sel)
	  3'd0:
	    begin
	       out <= 8'b00000001;
	       d_out <= d_in[15:0];
	    end
	  3'd1: 
	    begin
	       out <= 8'b00000010;
	       d_out <= d_in[31:16];
	    end
	  3'd2:
	    begin
	       out <= 8'b00000100;
	       d_out <= d_in[47:32];
	    end
	  3'd3:
	    begin
	       out <= 8'b00001000;
	       d_out <= d_in[63:48];
	    end
	  3'd4:
	    begin
	       out <= 8'b00010000;
	       d_out <= d_in[79:64];
	    end
	  3'd5:
	    begin
	       out <= 8'b00100000;
	       d_out <= d_in[95:80];
	    end
	  3'd6:
	    begin
	       out <= 8'b01000000;
	       d_out <= d_in[111:96];
	    end
	  3'd7:
	    begin
	       out <= 8'b10000000;
	       d_out <= d_in[127:112];
	    end
	endcase // case(sel)
     end // always @ (sel)
endmodule // ch_select

