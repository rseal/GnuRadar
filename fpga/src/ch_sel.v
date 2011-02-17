module ch_sel
(
	input wire clk,
	input wire reset,
	input wire strobe,
	input wire en,
	output reg req_data,
	input [2:0] channels,
	output reg [2:0] sel
);

//localparam IDLE  = 1'b0;
//localparam COUNT = 1'b1;
//reg state;

wire data_enable = strobe && en;

always @(negedge clk) begin
	if(reset)
	begin
		sel <= channels;
		req_data <= 1'b0;
	end
	else if(data_enable) begin
		sel <= 3'd0;
		req_data <= 1'b1;
	end
	else if (sel != channels)
		sel <= sel + 3'd1;
	else begin
		sel <= channels;
		req_data <= 1'b0;
	end
end

endmodule
	//always @( posedge clk or posedge reset ) begin
	//if( reset ) 
		//begin
		//state <= IDLE;
		//sel <= 0;
		//req_data <= 1'b0;
		//end
		//else 
			//begin
			//case( state )
			//IDLE: begin
			//sel <= 0;
			//state <= data_enable ? COUNT : IDLE;
			//req_data <= data_enable ? 1'b1 : 1'b0;
			//end
			//COUNT: begin
			//sel <= sel + 3'd1;
			//state <= sel == channels ? IDLE : COUNT;
			//end
			//endcase
			//end
			//end
			//endmodule


			//always @(posedge clk)
			//begin
			//if(reset)
				//begin
				//sel <= channels;
				//req_data <= 1'b0;
				//end
				//else if( data_enable )
					//begin
					//sel <= 3'd0;
					//req_data <= 1'b1;
					//end
					//else if (sel != channels)
						//sel <= sel + 3'd1;
						//else
							//begin
							//sel <= channels;
							//req_data <= 1'b0;
							//end
							//end

