module fifo_monitor
  (
   input wr_clk,
   input rd_clk,
   input reset,
   input wr_full,
   input rd_full,
   input wr_clear,
   input rd_clear,
   output reg wr_overflow,
   output reg rd_overflow
   );

   always @ (posedge wr_clk)
     if(reset || wr_clear)
       wr_overflow <= 1'b0;
     else if(wr_full)
       wr_overflow <= 1'b1;

   always @ (posedge rd_clk)
     if(reset || rd_clear)
       rd_overflow <= 1'b0;
     else if(rd_full)
       rd_overflow <= 1'b1;
   

endmodule // fifo_monitor
