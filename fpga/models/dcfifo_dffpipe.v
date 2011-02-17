//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  dcfifo_dffpipe
//
// Description     :  Dual Clocks FIFO
//
// Limitation      :
//
// Results expected:
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module dcfifo_dffpipe ( d, clock, aclr,
                        q);

// GLOBAL PARAMETER DECLARATION
    parameter lpm_delay = 1;
    parameter lpm_width = 64;

// LOCAL PARAMETER DECLARATION
    parameter delay = (lpm_delay < 2) ? 1 : lpm_delay-1;

// INPUT PORT DECLARATION
    input [lpm_width-1:0] d;
    input clock;
    input aclr;

// OUTPUT PORT DECLARATION
    output [lpm_width-1:0] q;

// INTERNAL REGISTERS DECLARATION
    reg [(lpm_width*delay)-1:0] dffpipe;
    reg [lpm_width-1:0] q;

// LOCAL INTEGER DECLARATION

// INITIAL CONSTRUCT BLOCK
    initial
    begin
        dffpipe = {(lpm_width*delay){1'b0}};
        q <= 0;
    end

// ALWAYS CONSTRUCT BLOCK
    always @(posedge clock or posedge aclr)
    begin
        if (aclr)
        begin
            dffpipe <= {(lpm_width*delay){1'b0}};
            q <= 0;
        end
        else
        begin
            if ((lpm_delay > 0) && ($time > 0))
            begin
                if (lpm_delay > 1)
                begin
                    {q, dffpipe} <= {dffpipe, d};
                end
                else
                    q <= d;
            end
        end
    end // @(posedge aclr or posedge clock)

    always @(d)
    begin
        if (lpm_delay == 0)
            q <= d;
    end // @(d)

endmodule // dcfifo_dffpipe
// END OF MODULE

