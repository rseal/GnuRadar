
module synchronizer( snd_clk, rcv_clk, snd_signal, rcv_signal1, rcv_signal2, rcv_signal3 );

input wire snd_clk;
input wire rcv_clk; 
input wire snd_signal;
output reg rcv_signal1;
output reg rcv_signal2;
output reg rcv_signal3;

always @( posedge snd_clk )
	rcv_signal1 <= #1 snd_signal;

always @( posedge rcv_clk )
begin
	rcv_signal2 <= #1 rcv_signal1;
	rcv_signal3 <= #1 rcv_signal2;
end

endmodule
