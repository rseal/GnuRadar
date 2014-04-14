module data_tag2
(
	input clock,
   input reset,
   input strobe,
   input enable,
   output tag
);

wire sync1;
wire sync2;

assign tag = sync1 && ~sync2;

synchronizer sync
(
   .snd_clk(clock),
   .rcv_clk(strobe), 
   .snd_signal(enable), 
   .rcv_signal1(), 
   .rcv_signal2(sync1), 
   .rcv_signal3(sync2)
);

endmodule

