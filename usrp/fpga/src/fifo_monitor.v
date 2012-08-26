module fifo_monitor
  (
   input wr_clk,
   input rd_clk,
   input reset,
   input wr_full,
   input rd_empty,
	input clear,
   output reg wr_overflow,
   output reg rd_underflow
   );

	wire wr_reset, rd_reset;
	wire wr_clear, rd_clear;

	synchronizer sync( 
		.snd_clk( wr_clk ), 
		.rcv_clk( rd_clk ),
		.snd_signal( reset ),
		.rcv_signal1( wr_reset ),
		.rcv_signal2( ),
		.rcv_signal3( rd_reset )
	);

	synchronizer clear_sync(
		.snd_clk( wr_clk ),
		.rcv_clk( rd_clk ),
		.snd_signal( clear ),
		.rcv_signal1( wr_clear ),
		.rcv_signal2( ),
		.rcv_signal3( rd_clear )
	);

   always @ (posedge wr_clk )
		if( wr_reset || wr_clear)
       wr_overflow <= 1'b0;
     else if(wr_full)
       wr_overflow <= 1'b1;

   always @ (posedge rd_clk )
     if( rd_reset || rd_clear)
       rd_underflow <= 1'b0;
     else if(rd_empty)
       rd_underflow <= 1'b1;
   

endmodule // fifo_monitor
