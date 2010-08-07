//state machine based strobe implementation

module strobe_gen
( input clock,
   input reset,
   input enable,
   input [7:0] rate, // Rate should be 1 LESS THAN your desired divide ratio
   input strobe_in,
   output reg strobe,
   output [15:0] dbus
);

reg [7:0] counter;

parameter LOAD  = 2'b01,
   COUNT = 2'b10;

reg [2:0] state;


/* -----\/----- EXCLUDED -----\/-----
reg 	     sync;
   always @(posedge clock)
      sync <= enable ? 1'b1 : 1'b0;
   -----/\----- EXCLUDED -----/\----- */

  always @(posedge clock)
  begin
     if(reset || ~enable)
     begin
        state <= #1 LOAD;
        strobe <= 1'b0;
        counter <= 8'd0;
     end
     else
     begin
        case (state)
           LOAD:
              if(enable)
              begin
                 counter <= rate-8'd1;
                 strobe <= 1'b1;
                 state <= COUNT;
              end
              COUNT:
              begin
                 strobe <= 1'b0;
                 if(counter==8'd0)
                    state <= LOAD;
                 else
                    counter <= counter - 8'd1;
              end
              default:
                 state <= LOAD;
           endcase // casestate
        end // else: !if(reset || ~enable)
     end

     assign dbus = {
        2'b0,
        clock,
        reset,
        enable,
        strobe_in,
        strobe,
        counter
        };


        endmodule // strobe_gen

