module fx2(
	   input packet_rdy,
	   input clk,
	   input reset,
	   input [15:0] din,
	   output reg wr_req,
	   input rd_req
	   );
   
   reg [2:0] 	  packet_delay;
   reg [8:0] 	  p_count;

   //packet counter
   always @ (posedge clk)
     if(reset || ~wr_req)
       p_count <= 9'd0;
     else 
       p_count <= p_count + 9'd1;

   //wr_req control
   always @ (posedge clk)
     if(reset)
       begin
	  wr_req <= 1'b0;
	  packet_delay <= 1'b0;
       end
     else if(packet_rdy)
       if(packet_delay==5)
	 wr_req <= #($random %(5)) 1'b1;
       else
	 packet_delay <= packet_delay + 3'd1;
     else if(p_count == 9'd257)
       wr_req <= #($random %(5)) 1'b0;

endmodule // fx2
