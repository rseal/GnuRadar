
module fifo
(
   input rd_clk,
   input wr_clk,
   input reset,
   input bus_reset,
   input rd_req,
   output reg packet_rdy,
   output wire overflow,
   input clear_status,
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

reg [15:0] 	 d_reg0,d_reg1,d_reg2,d_reg3, d_reg4,d_reg5,d_reg6,d_reg7;
wire [15:0] d_mux;
wire [11:0] fifo_level;
wire wr_full,rd_empty;
wire wr_overflow,rd_underflow;
wire wr_req;
reg rd_gate;
reg [8:0] read_count;
wire [7:0] fifo_cntrl_debug;

reg data_rdy;
reg data_tag;

wire [3:0] max_channel;
assign max_channel = channels - 4'd1;


//MODULE: fifo_cntrl
//PURPOSE: control signals for fifo
fifo_cntrl fc
(
   .reset(reset),
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
   .dout(d_mux),
   .en(wr_req),
   .debug(fifo_cntrl_debug)
);

// Alert FX2 of available packet
always @(posedge rd_clk)
   packet_rdy = (fifo_level >= 256);

// FX2 keeps its request high too long
// 257 Bug Fix
always @(posedge rd_clk)
begin
   if(reset)
      read_count <= 9'd0;
   else
      read_count <= rd_req ? read_count + 9'd1 : 9'd0;
end

//alignment here is very important to properly read fifo ---> fx2
always @(posedge rd_clk)
   rd_gate <= (rd_req && ~read_count[8]) ? 1'b1 : 1'b0;

//modified 04/07/09
always @(negedge wr_clk)
   data_rdy <= strobe;
//data_tag <= ~gate_enable && strobe;

always @( data_rdy )
   data_tag <= ~gate_enable ? 1'b1 : 1'b0;

always @(posedge data_rdy)
begin
   //tag data for alignment - the first sample is no good anyway
   if(data_tag)
   begin
      d_reg0 <= 16'b0100000000000000;
      d_reg1 <= 16'b0100000000000000;
      d_reg2 <= 16'b0100000000000000;
      d_reg3 <= 16'b0100000000000000;
      d_reg4 <= 16'b0100000000000000;
      d_reg5 <= 16'b0100000000000000;
      d_reg6 <= 16'b0100000000000000;
      d_reg7 <= 16'b0100000000000000;
   end // else: !if(data_tag)
   else
   begin
      d_reg0 <= din0;
      d_reg1 <= din1;
      d_reg2 <= din2;
      d_reg3 <= din3;
      d_reg4 <= din4;
      d_reg5 <= din5;
      d_reg6 <= din6;
      d_reg7 <= din7;
   end // if (data_tag)
end

// PURPOSE: Buffers incoming data at wr_clk rate 
// and allows FX2 to read at rd_clk rate
alt_fifo rxfifo
(
   .rdclk ( ~rd_clk ),
   .wrclk ( wr_clk ),
   .data (d_mux),
   .wrreq(~wr_full & wr_req),
   .rdreq (rd_gate), 
   .wrfull ( wr_full ),
   .wrusedw (fifo_level),
   .q (dout),
   .rdempty (rd_empty),
   .aclr ( reset || wr_overflow) //added overflow flag to prevent one off 
);

//MODULE: fifo_monitor
//PURPOSE: Detect and send data over/underflow 
fifo_monitor fm
(
   .wr_clk(wr_clk),
   .rd_clk(~rd_clk),
   .reset(reset),
   .wr_full(wr_full),
   .rd_empty(rd_empty),
   .wr_clear(clear_status),
   .rd_clear(clear_status),
   .wr_overflow(wr_overflow),
   .rd_underflow(rd_underflow)
);

assign overflow = wr_overflow;

assign debugbus = {
   gate_enable,
   data_rdy,
   data_tag,              //12 
   wr_full,               //11
   d_mux[3:0],            //7-10
   wr_req,                //3
   strobe,                //2
   wr_clk,                //1
   reset                  //0
   };

   endmodule
