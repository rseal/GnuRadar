module fx2(
	input packet_rdy,
	input clk,
	input reset,
	input [15:0] din,
	output reg wr_req
);

localparam IDLE              = 2'b00;
localparam REQUEST_DELAY     = 2'b01;
localparam REQUEST_DATA      = 2'b10;
localparam RESET             = 2'b11;

localparam LAST_DATA_SAMPLE  = 9'd257;
localparam LAST_DELAY_SAMPLE = 3'd5;

reg [1:0] state;
reg [2:0] packet_delay;
reg [8:0] p_count;


//wr_req control
always @ (posedge clk or posedge reset ) begin

	if(reset)
	begin
		state <= IDLE;
		wr_req <= 1'b0;
		packet_delay <= 1'b0;
		p_count <= 9'd0;
	end
	else begin
		case( state )
			IDLE: begin
				state <= packet_rdy ? REQUEST_DELAY : IDLE;
			end
			REQUEST_DELAY: begin
				packet_delay <= packet_delay + 3'd1;
				state <= packet_delay == LAST_DELAY_SAMPLE ? REQUEST_DATA : REQUEST_DELAY;
			end
			REQUEST_DATA: begin
				wr_req <= #1 1'b1;

            if( wr_req ) 
            begin
               p_count <= p_count + 9'd1;
            end

				state <= p_count == LAST_DATA_SAMPLE ? RESET : REQUEST_DATA;
			end
			RESET: begin
				wr_req <= 1'b0;
				packet_delay <= 1'b0;
				p_count <= 9'd0;
				state <= IDLE;
			end
		endcase
	end
end

endmodule // fx2
