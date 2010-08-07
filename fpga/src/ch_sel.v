module ch_sel
(
   input clk,
   input reset,
   input strobe,
   input [2:0] channels,
   output reg en,
   output reg [2:0] sel
);

reg [1:0]   state;
parameter   INIT = 2'b01,
   LOAD = 2'b10;

always @(negedge clk)
   if(reset)
   begin
      sel <= channels;
      en <= 1'b0;
   end
   else if(strobe)
   begin
      sel <= 3'd0;
      en <= 1'b1;
   end
   else if (sel != channels)
      sel <= sel + 3'd1;
   else
   begin
      sel <= channels;
      en <= 1'b0;
   end


   //verified via logic analyze 04/04/2009
   /* -----\/----- EXCLUDED -----\/-----
   always @(negedge clk)
      if(reset)
      begin
         state <= INIT;
         en <= 1'b0;
         sel <= 3'd0;
      end
      else
      begin
         case(state)
            INIT:
               if(strobe)
               begin
                  en <= 1'b1;
                  state <= LOAD;
                  //		   sel <= 4'd1;
               end
               else
               begin
                  sel <= 3'd0;
                  en <= 1'b0;
               end // else: !if(strobe)
               LOAD:
                  if({1'b0,sel} == channels-4'd1)
                  begin
                     state <= INIT;
                     en <= 1'b0;
                     sel <= 3'd0;
                  end	    
                  else
                     sel <= sel + 3'd1;
                  default:
                     state <= INIT;
               endcase // case(state)
            end // else: !if(reset)
            -----/\----- EXCLUDED -----/\----- */




           endmodule
