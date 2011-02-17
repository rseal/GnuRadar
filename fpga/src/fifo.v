
module fifo
(
   input rd_clk,
   input wr_clk,
   input reset,
   input bus_reset,
   input rd_req,
   output wire packet_rdy,
   output wire overflow,
   input wire clear_status,
   input strobe,
   input gate_enable,
   input wire [3:0] channels,
   input wire [15:0] din0,
   input wire [15:0] din1,
   input wire [15:0] din2,
   input wire [15:0] din3,
   input wire [15:0] din4,
   input wire [15:0] din5,
   input wire [15:0] din6,
   input wire [15:0] din7,
   output [15:0] dout,
   output [15:0] debugbus
);

reg  [15:0] d_reg0,d_reg1,d_reg2,d_reg3, d_reg4,d_reg5,d_reg6,d_reg7;
reg  [15:0] d_mux;
wire [15:0] fifo_data_out;

wire [11:0] fifo_level;
wire wr_full,rd_empty;
wire wr_overflow,rd_underflow;
wire wr_req;
reg rd_gate;
reg [8:0] read_count;
wire [7:0] fifo_cntrl_debug;

wire tag;
wire wr_rest,rd_reset;

wire [3:0] max_channel;
assign max_channel = channels - 4'd1;

// cross-domain reset synchronizer
synchronizer sync( 
	.snd_clk( wr_clk ), 
	.rcv_clk( rd_clk ),
	.snd_signal( reset ),
	.rcv_signal1( ),
	.rcv_signal2( ),
	.rcv_signal3( rd_reset )
);

//MODULE: fifo_cntrl
//PURPOSE: control signals for fifo
fifo_cntrl fc
(
	.reset( reset ),
	.strobe(strobe),
	.clk(wr_clk),
	.channels(max_channel[2:0]),
	.d0(d_reg0),
	.d1(d_reg1),
	.d2(d_reg2),
	.d3(d_reg3),
	.d4(d_reg4),
	.d5(d_reg5),
	.d6(d_reg6),
	.d7(d_reg7),
	.dout( fifo_data_out ),
	.en( gate_enable ),
	.req_data( wr_req),
	.debug(fifo_cntrl_debug)
);

data_tag dt
(
	.clock( wr_clk ),
	.reset( reset ),
	.strobe(strobe),
	.enable(gate_enable),
	.tag(tag)
);

// Alert FX2 of available packet
assign packet_rdy =  fifo_level > 12'd256 ? 1'b1 : 1'b0;

// FX2 keeps its request high too long. 257 Bug Fix
// This can be removed when using the high bandwidth firmware image created by a 3rd party.
always @(posedge rd_clk or posedge rd_reset )
begin
	if( rd_reset )
		read_count <= 9'd0;
	else
		read_count <= rd_req ? read_count + 9'd1 : 9'd0;
end

// 05Feb2011 - Verified. The following block MUST be present 
// to prevent the one off bug from getting us. This will likely
// be removed when moving to the optimized FX2 code. 
always @(posedge rd_clk)
	rd_gate <= (rd_req && ~read_count[8]) ? 1'b1 : 1'b0;


// Insert the data tag when "tag" is enabled.
always @(negedge wr_clk)
	d_mux <= tag ? 16'h4000 : fifo_data_out;

// Register incoming data.
always @(posedge wr_clk)
begin
	if( strobe )
	begin
		d_reg0 <= din0;
		d_reg1 <= din1;
		d_reg2 <= din2;
		d_reg3 <= din3;
		d_reg4 <= din4;
		d_reg5 <= din5;
		d_reg6 <= din6;
		d_reg7 <= din7;
	end
end

// Altera megacell dual-clock FIFO. Buffers data before 
// being sent to the FX2 chip. 
alt_fifo rxfifo
(
	.rdclk ( ~rd_clk ),
	.wrclk ( wr_clk ),
	.data (d_mux),
	.wrreq(~wr_full & wr_req),
	.rdreq (rd_gate ), 
	.wrfull ( wr_full ),
	.wrusedw (fifo_level),
	.q (dout),
	.rdempty (rd_empty),
	.aclr ( reset || wr_overflow ) //added overflow flag to prevent one off 
);

//MODULE: fifo_monitor
//PURPOSE: Detect and send data over/underflow 
fifo_monitor fm
(
	.wr_clk(wr_clk),
	.rd_clk(~rd_clk),
	.reset( reset ),
	.wr_full(wr_full),
	.rd_empty(rd_empty),
	.clear( clear_status ),
	.wr_overflow(wr_overflow),
	.rd_underflow(rd_underflow)
);

assign overflow = wr_overflow;

assign debugbus = {
	{7'b0},   // 9-15
	wr_full,     // 8
	wr_req,      // 7
	overflow,    // 6
	tag,         // 5 
	packet_rdy,  // 4
	gate_enable, // 3 
	strobe,      // 2
	rd_reset,    // 1 
	reset        // 0
	};

	endmodule
