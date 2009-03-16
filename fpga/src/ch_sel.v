
module ch_sel(
	      input clk,
	      input reset,
	      input strobe,
	      input num_ch,
	      output reg [3:0] channel
	      );
   
   parameter 	    IDLE  = 1'b0;
   parameter 	    ACCUM = 1'b1;
   reg 		    state;
   //   reg [3:0] 	    channel;
   
   always @(posedge clk)
     begin
	if(reset)
	  begin
	     state <= IDLE;
	     channel <= 4'd0;
	  end
	else
	  begin
	     case(state)
	       IDLE:
		 if(strobe)
		   begin 
		      channel <= 4'd1;
		      state <= ACCUM;
		   end
		 else
		   channel <= 4'd0;
	       ACCUM:
		 if(channel==num_ch)
		   begin
		      state <= IDLE;
		      channel <= 4'd0;
		   end
		 else
		   channel <= channel + 4'd1;
	     endcase // case(state)
	  end
     end // always @ (posedge clk)
endmodule // ch_sel
