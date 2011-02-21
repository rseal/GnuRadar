`timescale 1ns/100ps

module fifo_tb;

//test vector to load data from file
localparam TEST_VECTOR_LENGTH = 1024;
localparam SIMULATION_TIME    = 500000;
localparam CHANNELS = 4'd2;

reg [15:0] dataVec [0:TEST_VECTOR_LENGTH-1];
reg [10:0]  iter;
reg 	      reset;
reg 	      bus_rst;
wire [15:0] df_out;
wire [15:0] ram_out;
wire        overflow;
reg 	       gate_enable;
wire        rx_strobe;
//reg [3:0]   channels;
reg [15:0]  ch0;
reg [15:0]  ch1;
reg [15:0]  ch2;
reg [15:0]  ch3;
reg [15:0]  ch4;
reg [15:0]  ch5;
reg [15:0]  ch6;
reg [15:0]  ch7;

parameter   GATE_PER_2    = 2664;
parameter   USB_CLK_PER_2 = 10.4;
parameter   RX_CLK_PER_2  = 7.8;
parameter   SDI_CLK_PER_2 = 2*USB_CLK_PER_2;

reg [11:0]   cnt;

reg  usb_clk;
reg  rx_clk;
reg  wr_req;
wire RD;

//Generate 48MHz USB clock  
initial begin	
   usb_clk= #10 1'b1;
   forever #(USB_CLK_PER_2) usb_clk = ~usb_clk;
end

//Generate 64MHz Rx clock  
initial begin	
   rx_clk=1'b1;
   forever #(RX_CLK_PER_2) rx_clk = ~rx_clk;
end

//Generate 512usec gate pulses 
initial begin
   gate_enable <= 1'b0;
   #10 gate_enable=1'b0;
   forever #(GATE_PER_2 + $random %(10)) gate_enable=~gate_enable;
end

//VARIABLE INITIALIZATION 
initial begin

   //reset pulse
   reset <= 1'd0;
   reset <= #02 1'd1;
   reset <= #50 1'd0;
   iter <= 9'd0;
   bus_rst <= 1'b0;
end

//MODULE : FX2
//PURPOSE: Minimal FX2 module to emulate 
//         data request and read signals
fx2 fx2
(
   .packet_rdy(packet_rdy),
   .clk(usb_clk),
   .reset(reset),
   .din(df_out),
   .wr_req(RD)
);

//MODULE: strobe_gen
//PURPOSE: Generate decimated strobe from rx_clk - rx_clk/rate
strobe_gen rxsbr
(
   .clock(rx_clk),
   .reset(reset),
   .enable(gate_enable),
   .rate(8'd8),
   .strobe(rx_strobe)
);

//MODULE: rx_fifo_new
//PURPOSE: 
fifo dut
(
   .wr_clk(rx_clk),
   .rd_clk(usb_clk),
   .reset(reset),
   .bus_reset(bus_rst),
   .rd_req(RD),
   .packet_rdy(packet_rdy),
   .overflow(overflow),
   .clear_status(1'b0),
   .strobe(rx_strobe),
   .gate_enable( gate_enable ),
   .channels( CHANNELS ),
   .din0(ch0),
   .din1(ch1),
   .din2(ch2),
   .din3(ch3),
   .din4(ch4),
   .din5(ch5),
   .din6(ch6),
   .din7(ch7),
   .dout(df_out)
);

//Reads test vector from file into dataVec array
initial begin	
   $readmemb("data/input.vec", dataVec);
   #SIMULATION_TIME $finish;  //2msec simulation time
end

//Dump variables to output file for gtkwave
initial begin
   $dumpfile("fifo_tb.lxt");
   $dumpvars;
end

//Load data from vector into channels 
always @ (posedge rx_strobe) begin
   if( reset ) begin
      ch0 <= 16'd0;
      ch1 <= 16'd0;
      ch2 <= 16'd0;
      ch3 <= 16'd0;
      ch4 <= 16'd0;
      ch5 <= 16'd0;
      ch6 <= 16'd0;
      ch7 <= 16'd0;
   end
   else begin
      ch0 <= 8*iter;
      ch1 <= 8*iter+1;
      ch2 <= 8*iter+2;
      ch3 <= 8*iter+3;
      ch4 <= 8*iter+4;
      ch5 <= 8*iter+5;
      ch6 <= 8*iter+6;
      ch7 <= 8*iter+7;
   end
end


//Iterator for array indexing
always @ (posedge rx_strobe) begin
   iter <= (reset || iter == TEST_VECTOR_LENGTH-8) ? 9'd0 : iter + 9'd1;
end

endmodule 
