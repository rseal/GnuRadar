`include "altera_common.v"

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

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  dcfifo_fefifo
//
// Description     :  Dual Clock FIFO
//
// Limitation      :
//
// Results expected:
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module dcfifo_fefifo  ( usedw_in, wreq, rreq, clock, aclr,
                        empty, full);

// GLOBAL PARAMETER DECLARATION
    parameter lpm_widthad = 1;
    parameter lpm_numwords = 1;
    parameter underflow_checking = "ON";
    parameter overflow_checking = "ON";
    parameter lpm_mode = "READ";

// INPUT PORT DECLARATION
    input [lpm_widthad-1:0] usedw_in;
    input wreq, rreq;
    input clock;
    input aclr;

// OUTPUT PORT DECLARATION
    output empty, full;

// INTERNAL REGISTERS DECLARATION
    reg [1:0] sm_empty;
    reg lrreq;
    reg i_empty, i_full;

// LOCAL INTEGER DECLARATION
    integer almostfull;

// INITIAL CONSTRUCT BLOCK
    initial
    begin
        if ((lpm_mode != "READ") && (lpm_mode != "WRITE"))
            $display ("Error! LPM_MODE must be READ or WRITE.");
        if ((underflow_checking != "ON") && (underflow_checking != "OFF"))
            $display ("Error! UNDERFLOW_CHECKING must be ON or OFF.");
        if ((overflow_checking != "ON") && (overflow_checking != "OFF"))
            $display ("Error! OVERFLOW_CHECKING must be ON or OFF.");

        sm_empty <= 2'b00;
        i_empty <= 1'b1;
        i_full <= 1'b0;

        if (lpm_numwords >= 3)
            almostfull <= lpm_numwords - 3;
        else
            almostfull <= 0;
    end

// ALWAYS CONSTRUCT BLOCK
    always @(posedge aclr)
    begin
        sm_empty <= 2'b00;
        i_empty <= 1'b1;
        i_full <= 1'b0;
        lrreq <= 1'b0;
    end // @(posedge aclr)

    always @(posedge clock)
    begin
        if (underflow_checking == "OFF")
            lrreq <= rreq;
        else
            lrreq <= rreq && ~i_empty;

        if (~aclr && $time > 0)
        begin
            if (lpm_mode == "READ")
            begin
                casex (sm_empty)
                    // state_empty
                    2'b00:
                        if (usedw_in != 0)
                            sm_empty <= 2'b01;
                    // state_non_empty
                    2'b01:
                        if (rreq && (((usedw_in == 1) && !lrreq) || ((usedw_in == 2) && lrreq)))
                            sm_empty <= 2'b10;
                    // state_emptywait
                    2'b10:
                        if (usedw_in > 1)
                            sm_empty <= 2'b01;
                        else
                            sm_empty <= 2'b00;
                    default:
                        $display ("Error! Invalid sm_empty state in read mode.");
                endcase
            end // if (lpm_mode == "READ")
            else if (lpm_mode == "WRITE")
            begin
                casex (sm_empty)
                    // state_empty
                    2'b00:
                        if (wreq)
                            sm_empty <= 2'b01;
                    // state_one
                    2'b01:
                        if (!wreq)
                            sm_empty <= 2'b11;
                    // state_non_empty
                    2'b11:
                        if (wreq)
                            sm_empty <= 2'b01;
                        else if (usedw_in == 0)
                            sm_empty <= 2'b00;
                    default:
                        $display ("Error! Invalid sm_empty state in write mode.");
                endcase
            end // if (lpm_mode == "WRITE")

            if (~aclr && (usedw_in >= almostfull) && ($time > 0))
                i_full <= 1'b1;
            else
                i_full <= 1'b0;
        end // if (~aclr && $time > 0)
    end // @(posedge clock)

    always @(sm_empty)
    begin
        i_empty <= !sm_empty[0];
    end
    // @(sm_empty)

// CONTINOUS ASSIGNMENT
    assign empty = i_empty;
    assign full = i_full;
endmodule // dcfifo_fefifo
// END OF MODULE

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  dcfifo_async
//
// Description     :  Asynchronous Dual Clocks FIFO
//
// Limitation      :
//
// Results expected:
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module dcfifo_async (data, rdclk, wrclk, aclr, rdreq, wrreq,
                    rdfull, wrfull, rdempty, wrempty, rdusedw, wrusedw, q);

// GLOBAL PARAMETER DECLARATION
    parameter lpm_width = 1;
    parameter lpm_widthu = 1;
    parameter lpm_numwords = 2;
    parameter delay_rdusedw = 1;
    parameter delay_wrusedw = 1;
    parameter rdsync_delaypipe = 0;
    parameter wrsync_delaypipe = 0;
    parameter intended_device_family = "APEX20KE";
    parameter lpm_showahead = "OFF";
    parameter underflow_checking = "ON";
    parameter overflow_checking = "ON";
    parameter use_eab = "ON";
    parameter add_ram_output_register = "OFF";

// INPUT PORT DECLARATION
    input [lpm_width-1:0] data;
    input rdclk;
    input wrclk;
    input aclr;
    input wrreq;
    input rdreq;

// OUTPUT PORT DECLARATION
    output rdfull;
    output wrfull;
    output rdempty;
    output wrempty;
    output [lpm_widthu-1:0] rdusedw;
    output [lpm_widthu-1:0] wrusedw;
    output [lpm_width-1:0] q;

// INTERNAL REGISTERS DECLARATION
    reg [lpm_width-1:0] mem_data [(1<<lpm_widthu)-1:0];
    reg [lpm_width-1:0] mem_data2 [(1<<lpm_widthu)-1:0];
    reg data_ready [(1<<lpm_widthu)-1:0];
    reg [2:0] data_delay_count [(1<<lpm_widthu)-1:0];
    reg [lpm_width-1:0] i_data_tmp;
    reg [lpm_widthu-1:0] i_rdptr;
    reg [lpm_widthu-1:0] i_wrptr;
    reg [lpm_widthu-1:0] i_wrptr_tmp;
    reg i_rdenclock;
    reg i_wren_tmp;
    reg i_showahead_flag;
    reg i_showahead_flag1;
    reg i_showahead_flag2;
    reg i_showahead_flag3;
    reg [lpm_widthu-1:0] i_wr_udwn;
    reg [lpm_widthu-1:0] i_rd_udwn;
    reg [lpm_widthu:0] i_rdusedw;
    reg [lpm_widthu-1:0] i_wrusedw;
    reg [lpm_width-1:0] i_q_tmp;

// INTERNAL WIRE DECLARATION
    wire i_rden;
    wire i_wren;
    wire w_rdempty;
    wire w_wrempty;
    wire w_rdfull;
    wire w_wrfull;
    wire [lpm_widthu-1:0] w_rdptrrg;
    wire [lpm_widthu-1:0] w_wrdelaycycle;
    wire [lpm_widthu-1:0] w_ws_nbrp;
    wire [lpm_widthu-1:0] w_rs_nbwp;
    wire [lpm_widthu-1:0] w_ws_dbrp;
    wire [lpm_widthu-1:0] w_rs_dbwp;
    wire [lpm_widthu-1:0] w_rd_dbuw;
    wire [lpm_widthu-1:0] w_wr_dbuw;
    wire [lpm_widthu-1:0] w_rdusedw;
    wire [lpm_widthu-1:0] w_wrusedw;

// INTERNAL TRI DECLARATION
    tri0 aclr;

// LOCAL INTEGER DECLARATION
    integer i;
    integer j;
    integer k;

// COMPONENT INSTANTIATION
   ALTERA_DEVICE_FAMILIES dev ();

// INITIAL CONSTRUCT BLOCK
    initial
    begin
        if((lpm_showahead != "ON") && (lpm_showahead != "OFF"))
            $display ("Error! lpm_showahead must be ON or OFF.");
        if((underflow_checking != "ON") && (underflow_checking != "OFF"))
            $display ("Error! underflow_checking must be ON or OFF.");
        if((overflow_checking != "ON") && (overflow_checking != "OFF"))
            $display ("Error! overflow_checking must be ON or OFF.");
        if((use_eab != "ON") && (use_eab != "OFF"))
            $display ("Error! use_eab must be ON or OFF.");
        if((add_ram_output_register != "ON") && (add_ram_output_register != "OFF"))
            $display ("Error! add_ram_output_register must be ON or OFF.");
        if (dev.IS_VALID_FAMILY(intended_device_family) == 0)
            $display ("Error! Unknown INTENDED_DEVICE_FAMILY=%s.", intended_device_family);

        for (i = 0; i < (1 << lpm_widthu); i = i + 1)
        begin
            mem_data[i] <= 0;
            mem_data2[i] <= 0;
            data_ready[i] <= 1'b0;
            data_delay_count[i] <= 0;
        end
        
        if ((add_ram_output_register == "OFF") &&
            (dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family) ||
            dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family)))
        begin
            for (i = 0; i < (1 << lpm_widthu); i = i + 1)
            begin
                mem_data2[i] <= {lpm_width{1'bx}};
            end
        end
        else
        begin
            for (i = 0; i < (1 << lpm_widthu); i = i + 1)
            begin
                mem_data2[i] <= 0;
            end            
        end
        
        i_data_tmp <= 0;
        i_rdptr <= 0;
        i_wrptr <= 0;
        i_wrptr_tmp <= 0;
        i_wren_tmp <= 0;
        i_wr_udwn <= 0;
        i_rd_udwn <= 0;
        i_rdusedw <= 0;
        i_wrusedw <= 0;
        i_q_tmp <= 0;
    end

// COMPONENT INSTANTIATIONS
    // Delays & DFF Pipes
    dcfifo_dffpipe DP_RDPTR_D (
        .d (i_rdptr),
        .clock (i_rdenclock),
        .aclr (aclr),
        .q (w_rdptrrg));
    dcfifo_dffpipe DP_WRPTR_D (
        .d (i_wrptr),
        .clock (wrclk),
        .aclr (aclr),
        .q (w_wrdelaycycle));
    defparam
        DP_RDPTR_D.lpm_delay = 0,
        DP_RDPTR_D.lpm_width = lpm_widthu,
        DP_WRPTR_D.lpm_delay = 1,
        DP_WRPTR_D.lpm_width = lpm_widthu;

    dcfifo_dffpipe DP_WS_NBRP (
        .d (w_rdptrrg),
        .clock (wrclk),
        .aclr (aclr),
        .q (w_ws_nbrp));
    dcfifo_dffpipe DP_RS_NBWP (
        .d (w_wrdelaycycle),
        .clock (rdclk),
        .aclr (aclr),
        .q (w_rs_nbwp));
    dcfifo_dffpipe DP_WS_DBRP (
        .d (w_ws_nbrp),
        .clock (wrclk),
        .aclr (aclr),
        .q (w_ws_dbrp));
    dcfifo_dffpipe DP_RS_DBWP (
        .d (w_rs_nbwp),
        .clock (rdclk),
        .aclr (aclr),
        .q (w_rs_dbwp));
    defparam
        DP_WS_NBRP.lpm_delay = wrsync_delaypipe,
        DP_WS_NBRP.lpm_width = lpm_widthu,
        DP_RS_NBWP.lpm_delay = rdsync_delaypipe,
        DP_RS_NBWP.lpm_width = lpm_widthu,
        DP_WS_DBRP.lpm_delay = 1,              // gray_delaypipe
        DP_WS_DBRP.lpm_width = lpm_widthu,
        DP_RS_DBWP.lpm_delay = 1,              // gray_delaypipe
        DP_RS_DBWP.lpm_width = lpm_widthu;

    dcfifo_dffpipe DP_WRUSEDW (
        .d (i_wr_udwn),
        .clock (wrclk),
        .aclr (aclr),
        .q (w_wrusedw));
    dcfifo_dffpipe DP_RDUSEDW (
        .d (i_rd_udwn),
        .clock (rdclk),
        .aclr (aclr),
        .q (w_rdusedw));
    dcfifo_dffpipe DP_WR_DBUW (
        .d (i_wr_udwn),
        .clock (wrclk),
        .aclr (aclr),
        .q (w_wr_dbuw));
    dcfifo_dffpipe DP_RD_DBUW (
        .d (i_rd_udwn),
        .clock (rdclk),
        .aclr (aclr),
        .q (w_rd_dbuw));
    defparam
        DP_WRUSEDW.lpm_delay = delay_wrusedw,
        DP_WRUSEDW.lpm_width = lpm_widthu,
        DP_RDUSEDW.lpm_delay = delay_rdusedw,
        DP_RDUSEDW.lpm_width = lpm_widthu,
        DP_WR_DBUW.lpm_delay = 1,              // wrusedw_delaypipe
        DP_WR_DBUW.lpm_width = lpm_widthu,
        DP_RD_DBUW.lpm_delay = 1,              // rdusedw_delaypipe
        DP_RD_DBUW.lpm_width = lpm_widthu;

    // Empty/Full
    dcfifo_fefifo WR_FE (
        .usedw_in (w_wr_dbuw),
        .wreq (wrreq),
        .rreq (rdreq),
        .clock (wrclk),
        .aclr (aclr),
        .empty (w_wrempty),
        .full (w_wrfull));
    dcfifo_fefifo RD_FE (
        .usedw_in (w_rd_dbuw),
        .rreq (rdreq),
        .wreq(wrreq),
        .clock (rdclk),
        .aclr (aclr),
        .empty (w_rdempty),
        .full (w_rdfull));
    defparam
        WR_FE.lpm_widthad = lpm_widthu,
        WR_FE.lpm_numwords = lpm_numwords,
        WR_FE.underflow_checking = underflow_checking,
        WR_FE.overflow_checking = overflow_checking,
        WR_FE.lpm_mode = "WRITE",
        RD_FE.lpm_widthad = lpm_widthu,
        RD_FE.lpm_numwords = lpm_numwords,
        RD_FE.underflow_checking = underflow_checking,
        RD_FE.overflow_checking = overflow_checking,
        RD_FE.lpm_mode = "READ";

// ALWAYS CONSTRUCT BLOCK
    always @(posedge aclr)
    begin
        i_rdptr <= 0;
        i_wrptr <= 0;
        if (!(dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family) ||
        dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family)) ||
        (use_eab == "OFF"))
        begin
            if (lpm_showahead == "ON")
                i_q_tmp <= mem_data[0];
            else
                i_q_tmp <= 0;
        end
        else if ((add_ram_output_register == "ON") &&
                (dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family) ||
                dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family)))
        begin
            if (lpm_showahead == "OFF")
                i_q_tmp <= 0;
            else
            begin
                i_q_tmp <= {lpm_width{1'bx}};

                for (j = 0; j < (1<<lpm_widthu); j = j + 1)
                begin
                    data_ready[i_wrptr_tmp] <= 1'b0;
                    data_delay_count[k] <= 0;
                end
            end
        end
    end // @(posedge aclr)

    always @(posedge wrclk)
    begin
        if (aclr && (!(dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family) ||
            dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family)) ||
            (add_ram_output_register == "ON") || (use_eab == "OFF")))
        begin
            i_data_tmp <= 0;
            i_wrptr_tmp <= 0;
            i_wren_tmp <= 0;
        end
        else if (wrclk && ($time > 0))
        begin
            i_data_tmp <= data;
            i_wrptr_tmp <= i_wrptr;
            i_wren_tmp <= i_wren;

            if (i_wren)
            begin
                if (~aclr && ((i_wrptr < (1<<lpm_widthu)-1) || (overflow_checking == "OFF")))
                    i_wrptr <= i_wrptr + 1;
                else
                    i_wrptr <= 0;

                if (use_eab == "OFF")
                begin
                    mem_data[i_wrptr] <= data;

                    if (lpm_showahead == "ON")
                        i_showahead_flag3 <= 1'b1;
                end
            end
        end
    end // @(posedge wrclk)

    always @(negedge wrclk)
    begin
        if ((~wrclk && (use_eab == "ON")) && ($time > 0))
        begin
            if (i_wren_tmp)
            begin
                mem_data[i_wrptr_tmp] <= i_data_tmp;
                data_ready[i_wrptr_tmp] <= 1'b0;
            end

            if ((lpm_showahead == "ON") &&
                (!(dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family) ||
                    dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family))))
                i_showahead_flag3 <= 1'b1;
        end
    end // @(negedge wrclk)

    always @(posedge rdclk)
    begin
    
        if (rdclk && ($time > 0))
        begin
            if ((lpm_showahead == "ON") && (add_ram_output_register == "ON") &&
                (dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family) ||
                dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family)))
            begin
                for (k = 0; k < (1<<lpm_widthu); k = k + 1)
                begin
                    if (data_ready[k] == 1'b0)
                        data_delay_count[k] <= data_delay_count[k] + 1;

                    if (data_delay_count[k] == (rdsync_delaypipe+2))
                    begin
                        data_ready[k] <= 1'b1;
                        data_delay_count[k] <= 0;
                    end
                end
                
                if (~aclr)
                begin
                    i_showahead_flag3 <= 1'b1;
                end
            end

        end

        if (aclr && (!(dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family) ||
            dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family)) ||
            (use_eab == "OFF")))
        begin
            if (lpm_showahead == "ON")
                i_q_tmp <= mem_data[0];
            else
                i_q_tmp <= 0;
        end
        else if (aclr && (add_ram_output_register == "ON") &&
                (dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family) ||
                dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family)))
        begin
            if (lpm_showahead == "ON")
                i_q_tmp <= {lpm_width{1'bx}};
            else
                i_q_tmp <= 0;
        end
        else if (rdclk && i_rden && ($time > 0))
        begin
            if (~aclr && ((i_rdptr < (1<<lpm_widthu)-1) || (underflow_checking == "OFF")))
                i_rdptr <= i_rdptr + 1;
            else
                i_rdptr <= 0;

            if (lpm_showahead == "ON")
                i_showahead_flag3 <= 1'b1;
            else
                i_q_tmp <= mem_data[i_rdptr];
        end
    end // @(posedge rdclk)
    
    always @(i_showahead_flag3)
    begin
        i_showahead_flag2 <= i_showahead_flag3;
    end
    
    always @(i_showahead_flag2)
    begin
        i_showahead_flag1 <= i_showahead_flag2;
    end
    
    always @(i_showahead_flag1)
    begin
        i_showahead_flag <= i_showahead_flag1;
    end
    
    
    always @(posedge i_showahead_flag)
    begin
        if ((lpm_showahead == "ON") && (add_ram_output_register == "ON") &&
            (dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family) ||
            dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family)))
        begin
            if (w_rdempty == 1'b0)
            begin
                if (data_ready[i_rdptr] == 1'b1)
                begin
                    i_q_tmp <= mem_data[i_rdptr];
                    mem_data2[i_rdptr] <= mem_data[i_rdptr];
                end
                else
                i_q_tmp <= mem_data2[i_rdptr];
            end
        end
        else
            i_q_tmp <= mem_data[i_rdptr];
        i_showahead_flag3 <= 1'b0;
    end // @(posedge i_showahead_flag)

    // Delays & DFF Pipes
    always @(negedge rdclk)
    begin
        i_rdenclock <= 0;
    end // @(negedge rdclk)

    always @(posedge rdclk)
    begin
        if (i_rden)
            i_rdenclock <= 1;
    end // @(posedge rdclk)

    always @(i_wrptr or w_ws_dbrp)
    begin
        i_wr_udwn = i_wrptr - w_ws_dbrp;
    end // @(i_wrptr or w_ws_dbrp)

    always @(i_rdptr or w_rs_dbwp)
    begin
        i_rd_udwn = w_rs_dbwp - i_rdptr;
    end // @(i_rdptr or w_rs_dbwp)


// CONTINOUS ASSIGNMENT
    assign i_rden = (underflow_checking == "OFF") ? rdreq : (rdreq && !w_rdempty);
    assign i_wren = (overflow_checking == "OFF")  ? wrreq : (wrreq && !w_wrfull);
    assign q = i_q_tmp;
    assign wrfull = w_wrfull;
    assign rdfull = w_rdfull;
    assign wrempty = w_wrempty;
    assign rdempty = w_rdempty;
    assign wrusedw = w_wrusedw;
    assign rdusedw = w_rdusedw;

endmodule // dcfifo_async
// END OF MODULE

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  dcfifo_sync
//
// Description     :  Synchronous Dual Clock FIFO
//
// Limitation      :
//
// Results expected:
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module dcfifo_sync (data, rdclk, wrclk, aclr, rdreq, wrreq,
                    rdfull, wrfull, rdempty, wrempty, rdusedw, wrusedw, q);

// GLOBAL PARAMETER DECLARATION
    parameter lpm_width = 1;
    parameter lpm_widthu = 1;
    parameter lpm_numwords = 2;
    parameter intended_device_family = "APEX20KE";
    parameter lpm_showahead = "OFF";
    parameter underflow_checking = "ON";
    parameter overflow_checking = "ON";
    parameter use_eab = "ON";
    parameter add_ram_output_register = "OFF";

// INPUT PORT DECLARATION
    input [lpm_width-1:0] data;
    input rdclk;
    input wrclk;
    input aclr;
    input rdreq;
    input wrreq;

// OUTPUT PORT DECLARATION
    output rdfull;
    output wrfull;
    output rdempty;
    output wrempty;
    output [lpm_widthu-1:0] rdusedw;
    output [lpm_widthu-1:0] wrusedw;
    output [lpm_width-1:0] q;

// INTERNAL REGISTERS DECLARATION
    reg [lpm_width-1:0] mem_data [(1<<lpm_widthu)-1:0];
    reg [lpm_width-1:0] i_data_tmp;
    reg [lpm_widthu:0] i_rdptr;
    reg [lpm_widthu:0] i_wrptr;
    reg [lpm_widthu-1:0] i_wrptr_tmp;
    reg i_wren_tmp;
    reg i_showahead_flag;
    reg i_showahead_flag2;
    reg [lpm_widthu:0] i_rdusedw;
    reg [lpm_widthu:0] i_wrusedw;
    reg [lpm_width-1:0] i_q_tmp;

// INTERNAL WIRE DECLARATION
    wire [lpm_widthu:0] w_rdptr_s;
    wire [lpm_widthu:0] w_wrptr_s;
    wire [lpm_widthu:0] w_wrptr_r;
    wire i_rden;
    wire i_wren;
    wire i_rdempty;
    wire i_wrempty;
    wire i_rdfull;
    wire i_wrfull;

// LOCAL INTEGER DECLARATION
    integer cnt_mod;
    integer i;

// COMPONENT INSTANTIATION
    ALTERA_DEVICE_FAMILIES dev ();

// INITIAL CONSTRUCT BLOCK
    initial
    begin
        if ((lpm_showahead != "ON") && (lpm_showahead != "OFF"))
            $display ("Error! LPM_SHOWAHEAD must be ON or OFF.");
        if ((underflow_checking != "ON") && (underflow_checking != "OFF"))
            $display ("Error! UNDERFLOW_CHECKING must be ON or OFF.");
        if ((overflow_checking != "ON") && (overflow_checking != "OFF"))
            $display ("Error! OVERFLOW_CHECKING must be ON or OFF.");
        if ((use_eab != "ON") && (use_eab != "OFF"))
            $display ("Error! USE_EAB must be ON or OFF.");
        if (lpm_numwords > (1 << lpm_widthu))
            $display ("Error! LPM_NUMWORDS must be less than or equal to 2**LPM_WIDTHU.");
        if((add_ram_output_register != "ON") && (add_ram_output_register != "OFF"))
            $display ("Error! add_ram_output_register must be ON or OFF.");
        if (dev.IS_VALID_FAMILY(intended_device_family) == 0)
            $display ("Error! Unknown INTENDED_DEVICE_FAMILY=%s.", intended_device_family);

        for (i = 0; i < (1 << lpm_widthu); i = i + 1)
            mem_data[i] <= 0;
        i_data_tmp <= 0;
        i_rdptr <= 0;
        i_wrptr <= 0;
        i_wrptr_tmp <= 0;
        i_wren_tmp <= 0;

        i_rdusedw <= 0;
        i_wrusedw <= 0;
        i_q_tmp <= 0;

        if (lpm_numwords == (1 << lpm_widthu))
            cnt_mod <= 1 << (lpm_widthu + 1);
        else
            cnt_mod <= 1 << lpm_widthu;
    end

// COMPONENT INSTANTIATIONS
    dcfifo_dffpipe RDPTR_D (
        .d (i_rdptr),
        .clock (wrclk),
        .aclr (aclr),
        .q (w_rdptr_s));
    dcfifo_dffpipe WRPTR_D (
        .d (i_wrptr),
        .clock (wrclk),
        .aclr (aclr),
        .q (w_wrptr_r));
    dcfifo_dffpipe WRPTR_E (
        .d (w_wrptr_r),
        .clock (rdclk),
        .aclr (aclr),
        .q (w_wrptr_s));
    defparam
        RDPTR_D.lpm_delay = 1,
        RDPTR_D.lpm_width = lpm_widthu + 1,
        WRPTR_D.lpm_delay = 1,
        WRPTR_D.lpm_width = lpm_widthu + 1,
        WRPTR_E.lpm_delay = 1,
        WRPTR_E.lpm_width = lpm_widthu + 1;

// ALWAYS CONSTRUCT BLOCK
    always @(posedge aclr)
    begin
        i_rdptr <= 0;
        i_wrptr <= 0;
        if (!(dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family) ||
        dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family)) ||
        ((add_ram_output_register == "ON") && (use_eab == "OFF")))
            if (lpm_showahead == "ON")
            begin
                if (dev.FEATURE_FAMILY_STRATIXII(intended_device_family) ||
                    dev.FEATURE_FAMILY_CYCLONEII(intended_device_family))
                    i_q_tmp <= {lpm_width{1'bX}};
                else
                    i_q_tmp <= mem_data[0];
            end
            else
                i_q_tmp <= 0;
    end // @(posedge aclr)

    always @(posedge wrclk)
    begin
        if (aclr && (!(dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family) ||
        dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family)) ||
        ((add_ram_output_register == "ON") && (use_eab == "OFF"))))
        begin
            i_data_tmp <= 0;
            i_wrptr_tmp <= 0;
            i_wren_tmp <= 0;
        end
        else if (wrclk && ($time > 0))
        begin
            i_data_tmp <= data;
            i_wrptr_tmp <= i_wrptr[lpm_widthu-1:0];
            i_wren_tmp <= i_wren;

            if (i_wren)
            begin
                if (~aclr && (i_wrptr < cnt_mod - 1))
                    i_wrptr <= i_wrptr + 1;
                else
                    i_wrptr <= 0;

                if (use_eab == "OFF")
                begin
                    mem_data[i_wrptr[lpm_widthu-1:0]] <= data;

                    if (lpm_showahead == "ON")
                        i_showahead_flag2 <= 1'b1;
                end
            end
        end
    end // @(posedge wrclk)

    always @(negedge wrclk)
    begin
        if ((~wrclk && (use_eab == "ON")) && ($time > 0))
        begin
            if (i_wren_tmp)
            begin
                mem_data[i_wrptr_tmp] <= i_data_tmp;
            end

            if ((lpm_showahead == "ON") &&
                (!( dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family) ||
                    dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family))))
                i_showahead_flag2 <= 1'b1;
        end
    end // @(negedge wrclk)

    always @(posedge rdclk)
    begin
        if (aclr && (!(dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family) ||
        dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family)) ||
        ((add_ram_output_register == "ON") && (use_eab == "OFF"))))
        begin
            if (lpm_showahead == "ON")
            begin
                if (dev.FEATURE_FAMILY_STRATIXII(intended_device_family) ||
                    dev.FEATURE_FAMILY_CYCLONEII(intended_device_family))
                    i_q_tmp <= {lpm_width{1'bX}};
                else
                    i_q_tmp <= mem_data[0];
            end
            else
                i_q_tmp <= 0;
        end
        else if (rdclk && i_rden && ($time > 0))
        begin
            if (~aclr && (i_rdptr < cnt_mod - 1))
                i_rdptr <= i_rdptr + 1;
            else
                i_rdptr <= 0;

            if ((lpm_showahead == "ON") && (!((use_eab == "ON") &&
                (dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family) ||
                    dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family)))))
                i_showahead_flag2 <= 1'b1;
            else
                i_q_tmp <= mem_data[i_rdptr[lpm_widthu-1:0]];
        end
    end // @(rdclk)

    always @(posedge i_showahead_flag)
    begin
        i_q_tmp <= mem_data[i_rdptr[lpm_widthu-1:0]];
        i_showahead_flag2 <= 1'b0;
    end // @(posedge i_showahead_flag)

    always @(i_showahead_flag2)
    begin
        i_showahead_flag <= i_showahead_flag2;
    end // @(i_showahead_flag2)
    
    // Usedw, Empty, Full
    always @(i_rdptr or w_wrptr_s or cnt_mod)
    begin
        if (w_wrptr_s >= i_rdptr)
            i_rdusedw <= w_wrptr_s - i_rdptr;
        else
            i_rdusedw <= w_wrptr_s + cnt_mod - i_rdptr;
    end // @(i_rdptr or w_wrptr_s)

    always @(i_wrptr or w_rdptr_s or cnt_mod)
    begin
        if (i_wrptr >= w_rdptr_s)
            i_wrusedw <= i_wrptr - w_rdptr_s;
        else
            i_wrusedw <= i_wrptr + cnt_mod - w_rdptr_s;
    end // @(i_wrptr or w_rdptr_s)


// CONTINOUS ASSIGNMENT
    assign i_rden = (underflow_checking == "OFF") ? rdreq : (rdreq && !i_rdempty);
    assign i_wren = (overflow_checking == "OFF")  ? wrreq : (wrreq && !i_wrfull);
    assign i_rdempty = (i_rdusedw == 0) ? 1'b1 : 1'b0;
    assign i_wrempty = (i_wrusedw == 0) ? 1'b1 : 1'b0;
    assign i_rdfull = (((lpm_numwords == (1 << lpm_widthu)) && i_rdusedw[lpm_widthu]) ||
                    ((lpm_numwords < (1 << lpm_widthu)) && (i_rdusedw == lpm_numwords)))
                    ? 1'b1 : 1'b0;
    assign i_wrfull = (((lpm_numwords == (1 << lpm_widthu)) && i_wrusedw[lpm_widthu]) ||
                    ((lpm_numwords < (1 << lpm_widthu)) && (i_wrusedw == lpm_numwords)))
                    ? 1'b1 : 1'b0;
    assign rdempty = i_rdempty;
    assign wrempty = i_wrempty;
    assign rdfull = i_rdfull;
    assign wrfull = i_wrfull;
    assign wrusedw = i_wrusedw[lpm_widthu-1:0];
    assign rdusedw = i_rdusedw[lpm_widthu-1:0];
    assign q = i_q_tmp;

endmodule // dcfifo_sync
// END OF MODULE

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  dcfifo_low_latency
//
// Description     :  Dual Clocks FIFO with lowest latency. This fifo implements
//                    the fifo behavior for Stratix II, Cyclone II, Stratix III,
//                    Cyclone III and Stratix showahead area mode (LPM_SHOWAHEAD=
//                    ON, ADD_RAM_OUTPUT_REGISTER=OFF)
//
// Limitation      :
//
// Results expected:
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module dcfifo_low_latency (data, rdclk, wrclk, aclr, rdreq, wrreq,
                    rdfull, wrfull, rdempty, wrempty, rdusedw, wrusedw, q);

// GLOBAL PARAMETER DECLARATION
    parameter lpm_width = 1;
    parameter lpm_widthu = 1;
    parameter lpm_width_r = lpm_width;
    parameter lpm_widthu_r = lpm_widthu;
    parameter lpm_numwords = 2;
    parameter delay_rdusedw = 2;
    parameter delay_wrusedw = 2;
    parameter rdsync_delaypipe = 0;
    parameter wrsync_delaypipe = 0;
    parameter intended_device_family = "Stratix";
    parameter lpm_showahead = "OFF";
    parameter underflow_checking = "ON";
    parameter overflow_checking = "ON";
    parameter add_usedw_msb_bit = "OFF";
    parameter write_aclr_synch = "OFF";
    parameter use_eab = "ON";
    parameter clocks_are_synchronized = "FALSE";
    parameter add_ram_output_register = "OFF";
    parameter lpm_hint = "USE_EAB=ON";

// LOCAL PARAMETER DECLARATION
    parameter WIDTH_RATIO = (lpm_width > lpm_width_r) ? lpm_width / lpm_width_r :
                            lpm_width_r / lpm_width;
    parameter FIFO_DEPTH = (add_usedw_msb_bit == "OFF") ? lpm_widthu_r : lpm_widthu_r -1;

// INPUT PORT DECLARATION
    input [lpm_width-1:0] data;
    input rdclk;
    input wrclk;
    input aclr;
    input rdreq;
    input wrreq;

// OUTPUT PORT DECLARATION
    output rdfull;
    output wrfull;
    output rdempty;
    output wrempty;
    output [lpm_widthu_r-1:0] rdusedw;
    output [lpm_widthu-1:0] wrusedw;
    output [lpm_width_r-1:0] q;

// INTERNAL REGISTERS DECLARATION
    reg [lpm_width_r-1:0] mem_data [(1<<FIFO_DEPTH) + WIDTH_RATIO : 0];
    reg [lpm_width-1:0] i_data_tmp;
    reg [lpm_width-1:0] i_temp_reg;
    reg [lpm_widthu_r:0] i_rdptr_g;
    reg [lpm_widthu:0] i_wrptr_g;
    reg [lpm_widthu:0] i_wrptr_g_tmp;
    reg [lpm_widthu:0] i_wrptr_g1;
    reg [lpm_widthu_r:0] i_rdptr_g1p;
    reg [lpm_widthu:0] i_delayed_wrptr_g;

    reg i_wren_tmp;
    reg i_rdempty;
    reg i_wrempty_area;
    reg i_wrempty_speed;
    reg i_rdempty_rreg;
    reg i_rdfull_speed;
    reg i_rdfull_area;
    reg i_wrfull;
    reg i_wrfull_wreg;
    reg [lpm_widthu_r:0] i_rdusedw_tmp;
    reg [lpm_widthu:0] i_wrusedw_tmp;
    reg [lpm_width_r-1:0] i_q;
    reg i_q_is_registered;
    reg use_wrempty_speed;
    reg use_rdfull_speed;
    reg sync_aclr_pre;
    reg sync_aclr;
    reg is_underflow;
    reg is_overflow;
    reg no_warn;

// INTERNAL WIRE DECLARATION
    wire [lpm_widthu:0] i_rs_dgwp;
    wire [lpm_widthu_r:0] i_ws_dgrp;
    wire [lpm_widthu_r:0] i_rdusedw;
    wire [lpm_widthu:0] i_wrusedw;
    wire i_rden;
    wire i_wren;
    wire write_aclr;

// INTERNAL TRI DECLARATION
    tri0 aclr;

// LOCAL INTEGER DECLARATION
    integer cnt_mod;
    integer cnt_mod_r;
    integer i;
    integer i_maximize_speed;

// COMPONENT INSTANTIATION
    ALTERA_DEVICE_FAMILIES dev ();
    ALTERA_MF_HINT_EVALUATION eva();

// FUNCTION DELCRARATION
    // Convert string to integer
    function integer str_to_int;
        input [8*16:1] s; 

        reg [8*16:1] reg_s;
        reg [8:1] digit;
        reg [8:1] tmp;
        integer m, ivalue;
        
        begin
            ivalue = 0;
            reg_s = s;
            for (m=1; m<=16; m=m+1)
            begin 
                tmp = reg_s[128:121];
                digit = tmp & 8'b00001111;
                reg_s = reg_s << 8; 
                ivalue = ivalue * 10 + digit; 
            end
            str_to_int = ivalue;
        end
    endfunction
    
// INITIAL CONSTRUCT BLOCK
    initial
    begin
        if ((lpm_showahead != "ON") && (lpm_showahead != "OFF"))
            $display ("Error! LPM_SHOWAHEAD must be ON or OFF.");
        if ((underflow_checking != "ON") && (underflow_checking != "OFF"))
            $display ("Error! UNDERFLOW_CHECKING must be ON or OFF.");
        if ((overflow_checking != "ON") && (overflow_checking != "OFF"))
            $display ("Error! OVERFLOW_CHECKING must be ON or OFF.");
        if (lpm_numwords > (1 << lpm_widthu))
            $display ("Error! LPM_NUMWORDS must be less than or equal to 2**LPM_WIDTHU.");
/* -----\/----- EXCLUDED -----\/-----
        if (dev.IS_VALID_FAMILY(intended_device_family) == 0)
            $display ("Error! Unknown INTENDED_DEVICE_FAMILY=%s.", intended_device_family);
 -----/\----- EXCLUDED -----/\----- */

        for (i = 0; i < (1 << lpm_widthu_r) + WIDTH_RATIO; i = i + 1)
            mem_data[i] <= {lpm_width_r{1'b0}};
        i_data_tmp <= 0;
        i_temp_reg <= 0;
        i_wren_tmp <= 0;
        i_rdptr_g <= 0;
        i_rdptr_g1p <= 1;
        i_wrptr_g <= 0;
        i_wrptr_g_tmp <= 0;
        i_wrptr_g1 <= 1;
        i_delayed_wrptr_g <= 0;
        i_rdempty <= 1;
        i_wrempty_area <= 1;
        i_wrempty_speed <= 1;
        i_rdempty_rreg <= 1;
        i_rdfull_speed <= 0;
        i_rdfull_area  <= 0;
        i_wrfull <= 0;
        i_wrfull_wreg <= 0;
        sync_aclr_pre <= 1'b1;
        sync_aclr <= 1'b1;
        i_q <= {lpm_width_r{1'b0}};
        is_underflow <= 0;
        is_overflow <= 0;
        no_warn <= 0;

        i_maximize_speed = str_to_int(eva.GET_PARAMETER_VALUE(lpm_hint, "MAXIMIZE_SPEED"));

        if (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family))
        begin
            use_wrempty_speed <= 1;
            use_rdfull_speed <= 1;
        end
        else if (dev.FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM(intended_device_family))
        begin
            use_wrempty_speed <= ((i_maximize_speed > 5) || (wrsync_delaypipe >= 2)) ? 1 : 0;
            use_rdfull_speed <= ((i_maximize_speed > 5) || (rdsync_delaypipe >= 2)) ? 1 : 0;
        end
        else
        begin
            use_wrempty_speed <= 0;
            use_rdfull_speed <= 0;
        end

        if (dev.FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM(intended_device_family))
        begin
            if (add_usedw_msb_bit == "OFF")
            begin
                if (lpm_width_r > lpm_width)
                begin
                    cnt_mod <= (1 << lpm_widthu) + WIDTH_RATIO;
                    cnt_mod_r <= (1 << lpm_widthu_r) + 1;
                end
                else
                begin
                    cnt_mod <= (1 << lpm_widthu) + 1;
                    cnt_mod_r <= (1 << lpm_widthu_r) + WIDTH_RATIO;
                end
            end
            else
            begin
                if (lpm_width_r > lpm_width)
                begin
                    cnt_mod <= (1 << (lpm_widthu-1)) + WIDTH_RATIO;
                    cnt_mod_r <= (1 << (lpm_widthu_r-1)) + 1;
                end
                else
                begin
                    cnt_mod <= (1 << (lpm_widthu-1)) + 1;
                    cnt_mod_r <= (1 << (lpm_widthu_r-1)) + WIDTH_RATIO;
                end
            end
        end
        else
        begin
            cnt_mod <= 1 << lpm_widthu;
            cnt_mod_r <= 1 << lpm_widthu_r;
        end

        if ((lpm_showahead == "OFF") &&
            ((dev.FEATURE_FAMILY_STRATIXII(intended_device_family)) ||
            (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family))))
            i_q_is_registered = 1'b1;
        else
            i_q_is_registered = 1'b0;
    end

// COMPONENT INSTANTIATIONS
    dcfifo_dffpipe DP_WS_DGRP (
        .d (i_rdptr_g),
        .clock (wrclk),
        .aclr (aclr),
        .q (i_ws_dgrp));
    defparam
        DP_WS_DGRP.lpm_delay = wrsync_delaypipe,
        DP_WS_DGRP.lpm_width = lpm_widthu_r + 1;

    dcfifo_dffpipe DP_RS_DGWP (
        .d (i_delayed_wrptr_g),
        .clock (rdclk),
        .aclr (aclr),
        .q (i_rs_dgwp));
    defparam
        DP_RS_DGWP.lpm_delay = rdsync_delaypipe,
        DP_RS_DGWP.lpm_width = lpm_widthu + 1;

    dcfifo_dffpipe DP_RDUSEDW (
        .d (i_rdusedw_tmp),
        .clock (rdclk),
        .aclr (aclr),
        .q (i_rdusedw));
    dcfifo_dffpipe DP_WRUSEDW (
        .d (i_wrusedw_tmp),
        .clock (wrclk),
        .aclr (aclr),
        .q (i_wrusedw));
    defparam
        DP_RDUSEDW.lpm_delay = (delay_rdusedw > 2) ? 2 : delay_rdusedw,
        DP_RDUSEDW.lpm_width = lpm_widthu_r + 1,
        DP_WRUSEDW.lpm_delay = (delay_wrusedw > 2) ? 2 : delay_wrusedw,
        DP_WRUSEDW.lpm_width = lpm_widthu + 1;

// ALWAYS CONSTRUCT BLOCK
    always @(posedge aclr)
    begin
        i_data_tmp <= 0;
        i_wren_tmp <= 0;
        i_rdptr_g <= 0;
        i_rdptr_g1p <= 1;
        i_wrptr_g <= 0;
        i_wrptr_g_tmp <= 0;
        i_wrptr_g1 <= 1;
        i_delayed_wrptr_g <= 0;
        i_rdempty <= 1;
        i_wrempty_area <= 1;
        i_wrempty_speed <= 1;
        i_rdempty_rreg <= 1;
        i_rdfull_speed <= 0;
        i_rdfull_area <= 0;
        i_wrfull <= 0;
        i_wrfull_wreg <= 0;
        is_underflow <= 0;
        is_overflow <= 0;
        no_warn <= 0;

        if(i_q_is_registered)
            i_q <= 0;
        else if ((dev.FEATURE_FAMILY_STRATIXII(intended_device_family)) ||
            (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family)))
            i_q <= {lpm_width_r{1'bx}};

    end // @(posedge aclr)
    
    always @(posedge wrclk or posedge aclr)
    begin
        if ($time > 0)
        begin
            if (aclr)
            begin
                sync_aclr <= 1'b1;
                sync_aclr_pre <= 1'b1;
            end
            else
            begin
                sync_aclr <= sync_aclr_pre;
                sync_aclr_pre <= 1'b0;
            end
        end
    end

    always @(posedge wrclk)
    begin
        i_data_tmp <= data;
        i_wrptr_g_tmp <= i_wrptr_g;
        i_wren_tmp <= i_wren;

        if (~write_aclr && ($time > 0))
        begin
            if (i_wren)
            begin
                if (i_wrfull && (overflow_checking == "OFF"))
                begin
                    if ((dev.FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM(intended_device_family) &&
                        ((use_eab == "ON") || ((use_eab == "OFF") && (lpm_width != lpm_width_r) && (lpm_width_r != 0)) ||
                        ((lpm_numwords < 16) && (clocks_are_synchronized == "FALSE")))) ||
                    (dev.FEATURE_FAMILY_STRATIX(intended_device_family) && (use_eab == "ON") &&
                        (((lpm_showahead == "ON") && (add_ram_output_register == "OFF")) ||
                        (clocks_are_synchronized == "FALSE_LOW_LATENCY"))))
                    begin
                        if (no_warn == 1'b0)
                        begin
                            $display("Warning : Overflow occurred! Fifo output is unknown until the next reset is asserted.");
                            $display("Time: %0t  Instance: %m", $time);
                            no_warn <= 1'b1;
                        end
                        is_overflow <= 1'b1;
                    end
                end
                else
                begin
                    if (i_wrptr_g1 < cnt_mod - 1)
                        i_wrptr_g1 <= i_wrptr_g1 + 1;
                    else
                        i_wrptr_g1 <= 0;
    
                    i_wrptr_g <= i_wrptr_g1;
                    
                    if (lpm_width > lpm_width_r)
                    begin
                        for (i = 0; i < WIDTH_RATIO; i = i+1)
                            mem_data[i_wrptr_g*WIDTH_RATIO+i] <= data >> (lpm_width_r*i);
                    end
                    else if (lpm_width < lpm_width_r)
                    begin
                        {mem_data[i_wrptr_g/WIDTH_RATIO], i_temp_reg} <= {data, mem_data[i_wrptr_g/WIDTH_RATIO]};
                    end
                    else
                        mem_data[i_wrptr_g] <= data;
                end
            end
            i_delayed_wrptr_g <= i_wrptr_g;
        end
    end // @(wrclk)

    always @(posedge rdclk)
    begin
        if(~aclr)
        begin
            if (i_rden && ($time > 0))
            begin
                if (i_rdempty && (underflow_checking == "OFF"))
                begin
                    if ((dev.FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM(intended_device_family) &&
                        ((use_eab == "ON") || ((use_eab == "OFF") && (lpm_width != lpm_width_r) && (lpm_width_r != 0)) ||
                        ((lpm_numwords < 16) && (clocks_are_synchronized == "FALSE")))) ||
                    (dev.FEATURE_FAMILY_STRATIX(intended_device_family) && (use_eab == "ON") &&
                        (((lpm_showahead == "ON") && (add_ram_output_register == "OFF")) ||
                        (clocks_are_synchronized == "FALSE_LOW_LATENCY"))))
                    begin
                        if (no_warn == 1'b0)
                        begin
                            $display("Warning : Underflow occurred! Fifo output is unknown until the next reset is asserted.");
                            $display("Time: %0t  Instance: %m", $time);
                            no_warn <= 1'b1;
                        end
                        is_underflow <= 1'b1;
                    end
                end
                else
                begin
                    if (i_rdptr_g1p < cnt_mod_r - 1)
                        i_rdptr_g1p <= i_rdptr_g1p + 1;
                    else
                        i_rdptr_g1p <= 0;
    
                    i_rdptr_g <= i_rdptr_g1p;
                end
            end
        end
    end

    always @(posedge rdclk)
    begin
        if (is_underflow || is_overflow)
            i_q <= {lpm_width_r{1'bx}};
        else
        begin
            if ((! i_q_is_registered) && ($time > 0))
            begin
                if (aclr && ((dev.FEATURE_FAMILY_STRATIXII(intended_device_family)) ||
                (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family))))
                    i_q <= {lpm_width_r{1'bx}};
                else
                begin
                    if (i_rdempty == 1'b1)
                        i_q <= mem_data[i_rdptr_g];
                    else if (i_rden)
                        i_q <= mem_data[i_rdptr_g1p];
                end
            end
            else if (~aclr && i_rden && ($time > 0))
                i_q <= mem_data[i_rdptr_g];
        end
    end

    // Usedw, Empty, Full
    always @(i_wrptr_g or i_ws_dgrp or cnt_mod)
    begin
        if (i_wrptr_g < (i_ws_dgrp*lpm_width_r/lpm_width))
            i_wrusedw_tmp <= cnt_mod + i_wrptr_g - i_ws_dgrp*lpm_width_r/lpm_width;
        else
            i_wrusedw_tmp <= i_wrptr_g - i_ws_dgrp*lpm_width_r/lpm_width;

        if (lpm_width > lpm_width_r)
        begin
            if (i_wrptr_g == (i_ws_dgrp/WIDTH_RATIO))
                i_wrempty_speed <= 1;
            else
                i_wrempty_speed <= 0;
        end
        else
        begin
            if ((i_wrptr_g/WIDTH_RATIO) == i_ws_dgrp)
                i_wrempty_speed <= 1;
            else
                i_wrempty_speed <= 0;
        end
    end // @(i_wrptr_g or i_ws_dgrp)

    always @(i_rdptr_g or i_rs_dgwp or cnt_mod)
    begin
        if ((i_rs_dgwp*lpm_width/lpm_width_r) < i_rdptr_g)
            i_rdusedw_tmp <= (cnt_mod + i_rs_dgwp)*lpm_width/lpm_width_r - i_rdptr_g;
        else
            i_rdusedw_tmp <= i_rs_dgwp*lpm_width/lpm_width_r - i_rdptr_g;

        if (lpm_width < lpm_width_r)
        begin
            if ((i_rdptr_g*lpm_width_r/lpm_width) == (i_rs_dgwp + WIDTH_RATIO) %cnt_mod)
                i_rdfull_speed <= 1;
            else
                i_rdfull_speed <= 0;
        end
        else
        begin
            if (i_rdptr_g == ((i_rs_dgwp +1) % cnt_mod)*lpm_width/lpm_width_r)
                i_rdfull_speed <= 1;
            else
                i_rdfull_speed <= 0;
        end
    end // @(i_wrptr_g or i_rs_dgwp)
    
    always @(i_wrptr_g1 or i_ws_dgrp or cnt_mod)
    begin
        if (lpm_width < lpm_width_r)
        begin
            if ((i_wrptr_g1 + WIDTH_RATIO -1) % cnt_mod == (i_ws_dgrp*lpm_width_r/lpm_width))
                i_wrfull <= 1;
            else
                i_wrfull <= 0;
        end
        else
        begin
            if (i_wrptr_g1 == (i_ws_dgrp*lpm_width_r/lpm_width))
                i_wrfull <= 1;
            else
                i_wrfull <= 0;
        end
    end // @(i_wrptr_g1 or i_ws_dgrp)

    always @(i_rdptr_g or i_rs_dgwp)
    begin
        if (lpm_width > lpm_width_r)
        begin
            if ((i_rdptr_g/WIDTH_RATIO) == i_rs_dgwp)
                i_rdempty <= 1;
            else
                i_rdempty <= 0;
        end
        else
        begin
            if (i_rdptr_g == i_rs_dgwp/WIDTH_RATIO)
                i_rdempty <= 1;
            else
                i_rdempty <= 0;
        end
    end // @(i_rdptr_g or i_rs_dgwp)

    always @(posedge rdclk)
    begin
        i_rdfull_area <= i_wrfull_wreg;
        i_rdempty_rreg <= i_rdempty;
    end // @(posedge rdclk)

    always @(posedge wrclk)
    begin
        i_wrempty_area <= i_rdempty_rreg;

        if ((~aclr) && (write_aclr_synch == "ON") && (dev.FEATURE_FAMILY_STRATIXII(intended_device_family) ||
                        dev.FEATURE_FAMILY_CYCLONEII(intended_device_family)))
            i_wrfull_wreg <= (i_wrfull | write_aclr);            
        else
            i_wrfull_wreg <= i_wrfull;
    end // @(posedge wrclk)

// CONTINOUS ASSIGNMENT
    assign i_rden = (underflow_checking == "OFF") ? rdreq : (rdreq && !i_rdempty);
    assign i_wren = ((dev.FEATURE_FAMILY_STRATIXII(intended_device_family) ||
                    dev.FEATURE_FAMILY_CYCLONEII(intended_device_family)) &&
                    (write_aclr_synch == "ON")) ?
                        ((overflow_checking == "OFF")   ? wrreq && (!sync_aclr)
                                                        : (wrreq && !(i_wrfull | sync_aclr))) :
                    (overflow_checking == "OFF")  ? wrreq : (wrreq && !i_wrfull);     
    assign rdempty = (is_underflow || is_overflow) ? 1'bx : i_rdempty;
    assign wrempty = (is_underflow || is_overflow) ? 1'bx :
                        (use_wrempty_speed) ? i_wrempty_speed : i_wrempty_area;
    assign rdfull = (is_underflow || is_overflow) ? 1'bx :
                        (use_rdfull_speed)  ? i_rdfull_speed : i_rdfull_area;
    assign wrfull = (is_underflow || is_overflow) ? 1'bx :
                        ((dev.FEATURE_FAMILY_STRATIXII(intended_device_family) ||
                        dev.FEATURE_FAMILY_CYCLONEII(intended_device_family)) &&
                        (write_aclr_synch == "ON")) ? (i_wrfull | write_aclr) : i_wrfull;
    assign wrusedw = (is_underflow || is_overflow) ? {lpm_widthu{1'bx}} :
                        i_wrusedw[lpm_widthu-1:0];
    assign rdusedw = (is_underflow || is_overflow) ? {lpm_widthu_r{1'bx}} :
                        i_rdusedw[lpm_widthu_r-1:0];
    assign q = (is_underflow || is_overflow) ? {lpm_width_r{1'bx}} : i_q;
    assign write_aclr = ((dev.FEATURE_FAMILY_STRATIXII(intended_device_family) ||
                        dev.FEATURE_FAMILY_CYCLONEII(intended_device_family)) &&
                        (write_aclr_synch == "ON")) ? sync_aclr : aclr;

endmodule // dcfifo_low_latency
// END OF MODULE

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  dcfifo_mixed_widths
//
// Description     :  Mixed widths Dual Clocks FIFO
//
// Limitation      :
//
// Results expected:
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module dcfifo_mixed_widths ( data, rdclk, wrclk, aclr, rdreq, wrreq,
                rdfull, wrfull, rdempty, wrempty, rdusedw, wrusedw, q);

// GLOBAL PARAMETER DECLARATION
    parameter lpm_width = 1;
    parameter lpm_widthu = 1;
    parameter lpm_width_r = lpm_width;
    parameter lpm_widthu_r = lpm_widthu;
    parameter lpm_numwords = 2;
    parameter delay_rdusedw = 1;
    parameter delay_wrusedw = 1;
    parameter rdsync_delaypipe = 0;
    parameter wrsync_delaypipe = 0;
    parameter intended_device_family = "APEX20KE";
    parameter lpm_showahead = "OFF";
    parameter underflow_checking = "ON";
    parameter overflow_checking = "ON";
    parameter clocks_are_synchronized = "FALSE";
    parameter use_eab = "ON";
    parameter add_ram_output_register = "OFF";
    parameter add_width = 1;
    parameter lpm_hint = "USE_EAB=ON";
    parameter lpm_type = "dcfifo_mixed_widths";
    parameter ram_block_type = "AUTO";
    parameter add_usedw_msb_bit = "OFF";
    parameter write_aclr_synch = "OFF";

// LOCAL PARAMETER DECLARATION
    parameter FAMILY_HAS_STRATIXII_STYLE_RAM = (((((intended_device_family == "Stratix II") || (intended_device_family == "STRATIX II") || (intended_device_family == "stratix ii") || (intended_device_family == "StratixII") || (intended_device_family == "STRATIXII") || (intended_device_family == "stratixii") || (intended_device_family == "Armstrong") || (intended_device_family == "ARMSTRONG") || (intended_device_family == "armstrong"))
                                || ((intended_device_family == "HardCopy II") || (intended_device_family == "HARDCOPY II") || (intended_device_family == "hardcopy ii") || (intended_device_family == "HardCopyII") || (intended_device_family == "HARDCOPYII") || (intended_device_family == "hardcopyii") || (intended_device_family == "Fusion") || (intended_device_family == "FUSION") || (intended_device_family == "fusion"))
                                || (((intended_device_family == "Stratix II GX") || (intended_device_family == "STRATIX II GX") || (intended_device_family == "stratix ii gx") || (intended_device_family == "StratixIIGX") || (intended_device_family == "STRATIXIIGX") || (intended_device_family == "stratixiigx"))
                                || ((intended_device_family == "Arria GX") || (intended_device_family == "ARRIA GX") || (intended_device_family == "arria gx") || (intended_device_family == "ArriaGX") || (intended_device_family == "ARRIAGX") || (intended_device_family == "arriagx") || (intended_device_family == "Stratix II GX Lite") || (intended_device_family == "STRATIX II GX LITE") || (intended_device_family == "stratix ii gx lite") || (intended_device_family == "StratixIIGXLite") || (intended_device_family == "STRATIXIIGXLITE") || (intended_device_family == "stratixiigxlite"))
                                ) || (((intended_device_family == "Stratix III") || (intended_device_family == "STRATIX III") || (intended_device_family == "stratix iii") || (intended_device_family == "StratixIII") || (intended_device_family == "STRATIXIII") || (intended_device_family == "stratixiii") || (intended_device_family == "Titan") || (intended_device_family == "TITAN") || (intended_device_family == "titan") || (intended_device_family == "SIII") || (intended_device_family == "siii"))
                                || (((intended_device_family == "Stratix IV") || (intended_device_family == "STRATIX IV") || (intended_device_family == "stratix iv") || (intended_device_family == "TGX") || (intended_device_family == "tgx") || (intended_device_family == "StratixIV") || (intended_device_family == "STRATIXIV") || (intended_device_family == "stratixiv") || (intended_device_family == "StratixIIIGX") || (intended_device_family == "STRATIXIIIGX") || (intended_device_family == "stratixiiigx") || (intended_device_family == "Stratix IV (GT/GX/E)") || (intended_device_family == "STRATIX IV (GT/GX/E)") || (intended_device_family == "stratix iv (gt/gx/e)") || (intended_device_family == "StratixIV(GT/GX/E)") || (intended_device_family == "STRATIXIV(GT/GX/E)") || (intended_device_family == "stratixiv(gt/gx/e)") || (intended_device_family == "Stratix IV (GX/E)") || (intended_device_family == "STRATIX IV (GX/E)") || (intended_device_family == "stratix iv (gx/e)") || (intended_device_family == "StratixIV(GX/E)") || (intended_device_family == "STRATIXIV(GX/E)") || (intended_device_family == "stratixiv(gx/e)"))
                                || ((intended_device_family == "Arria II GX") || (intended_device_family == "ARRIA II GX") || (intended_device_family == "arria ii gx") || (intended_device_family == "ArriaIIGX") || (intended_device_family == "ARRIAIIGX") || (intended_device_family == "arriaiigx") || (intended_device_family == "Arria IIGX") || (intended_device_family == "ARRIA IIGX") || (intended_device_family == "arria iigx") || (intended_device_family == "ArriaII GX") || (intended_device_family == "ARRIAII GX") || (intended_device_family == "arriaii gx") || (intended_device_family == "Arria II") || (intended_device_family == "ARRIA II") || (intended_device_family == "arria ii") || (intended_device_family == "ArriaII") || (intended_device_family == "ARRIAII") || (intended_device_family == "arriaii") || (intended_device_family == "Arria II (GX/E)") || (intended_device_family == "ARRIA II (GX/E)") || (intended_device_family == "arria ii (gx/e)") || (intended_device_family == "ArriaII(GX/E)") || (intended_device_family == "ARRIAII(GX/E)") || (intended_device_family == "arriaii(gx/e)") || (intended_device_family == "PIRANHA") || (intended_device_family == "piranha"))
                                || ((intended_device_family == "HardCopy IV") || (intended_device_family == "HARDCOPY IV") || (intended_device_family == "hardcopy iv") || (intended_device_family == "HardCopyIV") || (intended_device_family == "HARDCOPYIV") || (intended_device_family == "hardcopyiv") || (intended_device_family == "HCXIV") || (intended_device_family == "hcxiv") || (intended_device_family == "HardCopy IV (GX/E)") || (intended_device_family == "HARDCOPY IV (GX/E)") || (intended_device_family == "hardcopy iv (gx/e)") || (intended_device_family == "HardCopyIV(GX/E)") || (intended_device_family == "HARDCOPYIV(GX/E)") || (intended_device_family == "hardcopyiv(gx/e)"))
                                ) || ((intended_device_family == "HardCopy III") || (intended_device_family == "HARDCOPY III") || (intended_device_family == "hardcopy iii") || (intended_device_family == "HardCopyIII") || (intended_device_family == "HARDCOPYIII") || (intended_device_family == "hardcopyiii") || (intended_device_family == "HCX") || (intended_device_family == "hcx"))
                                ) ) || (((intended_device_family == "Cyclone II") || (intended_device_family == "CYCLONE II") || (intended_device_family == "cyclone ii") || (intended_device_family == "Cycloneii") || (intended_device_family == "CYCLONEII") || (intended_device_family == "cycloneii") || (intended_device_family == "Magellan") || (intended_device_family == "MAGELLAN") || (intended_device_family == "magellan"))
                                || (((intended_device_family == "Cyclone III") || (intended_device_family == "CYCLONE III") || (intended_device_family == "cyclone iii") || (intended_device_family == "CycloneIII") || (intended_device_family == "CYCLONEIII") || (intended_device_family == "cycloneiii") || (intended_device_family == "Barracuda") || (intended_device_family == "BARRACUDA") || (intended_device_family == "barracuda") || (intended_device_family == "Cuda") || (intended_device_family == "CUDA") || (intended_device_family == "cuda") || (intended_device_family == "CIII") || (intended_device_family == "ciii"))
                                || ((intended_device_family == "Cyclone III LS") || (intended_device_family == "CYCLONE III LS") || (intended_device_family == "cyclone iii ls") || (intended_device_family == "CycloneIIILS") || (intended_device_family == "CYCLONEIIILS") || (intended_device_family == "cycloneiiils") || (intended_device_family == "Cyclone III LPS") || (intended_device_family == "CYCLONE III LPS") || (intended_device_family == "cyclone iii lps") || (intended_device_family == "Cyclone LPS") || (intended_device_family == "CYCLONE LPS") || (intended_device_family == "cyclone lps") || (intended_device_family == "CycloneLPS") || (intended_device_family == "CYCLONELPS") || (intended_device_family == "cyclonelps") || (intended_device_family == "Tarpon") || (intended_device_family == "TARPON") || (intended_device_family == "tarpon") || (intended_device_family == "Cyclone IIIE") || (intended_device_family == "CYCLONE IIIE") || (intended_device_family == "cyclone iiie"))
                                ) ) ))
                                ? 1 : 0;

    parameter FAMILY_HAS_STRATIXIII_STYLE_RAM = (((((intended_device_family == "Stratix III") || (intended_device_family == "STRATIX III") || (intended_device_family == "stratix iii") || (intended_device_family == "StratixIII") || (intended_device_family == "STRATIXIII") || (intended_device_family == "stratixiii") || (intended_device_family == "Titan") || (intended_device_family == "TITAN") || (intended_device_family == "titan") || (intended_device_family == "SIII") || (intended_device_family == "siii"))
                                || (((intended_device_family == "Stratix IV") || (intended_device_family == "STRATIX IV") || (intended_device_family == "stratix iv") || (intended_device_family == "TGX") || (intended_device_family == "tgx") || (intended_device_family == "StratixIV") || (intended_device_family == "STRATIXIV") || (intended_device_family == "stratixiv") || (intended_device_family == "StratixIIIGX") || (intended_device_family == "STRATIXIIIGX") || (intended_device_family == "stratixiiigx") || (intended_device_family == "Stratix IV (GT/GX/E)") || (intended_device_family == "STRATIX IV (GT/GX/E)") || (intended_device_family == "stratix iv (gt/gx/e)") || (intended_device_family == "StratixIV(GT/GX/E)") || (intended_device_family == "STRATIXIV(GT/GX/E)") || (intended_device_family == "stratixiv(gt/gx/e)") || (intended_device_family == "Stratix IV (GX/E)") || (intended_device_family == "STRATIX IV (GX/E)") || (intended_device_family == "stratix iv (gx/e)") || (intended_device_family == "StratixIV(GX/E)") || (intended_device_family == "STRATIXIV(GX/E)") || (intended_device_family == "stratixiv(gx/e)"))
                                || ((intended_device_family == "Arria II GX") || (intended_device_family == "ARRIA II GX") || (intended_device_family == "arria ii gx") || (intended_device_family == "ArriaIIGX") || (intended_device_family == "ARRIAIIGX") || (intended_device_family == "arriaiigx") || (intended_device_family == "Arria IIGX") || (intended_device_family == "ARRIA IIGX") || (intended_device_family == "arria iigx") || (intended_device_family == "ArriaII GX") || (intended_device_family == "ARRIAII GX") || (intended_device_family == "arriaii gx") || (intended_device_family == "Arria II") || (intended_device_family == "ARRIA II") || (intended_device_family == "arria ii") || (intended_device_family == "ArriaII") || (intended_device_family == "ARRIAII") || (intended_device_family == "arriaii") || (intended_device_family == "Arria II (GX/E)") || (intended_device_family == "ARRIA II (GX/E)") || (intended_device_family == "arria ii (gx/e)") || (intended_device_family == "ArriaII(GX/E)") || (intended_device_family == "ARRIAII(GX/E)") || (intended_device_family == "arriaii(gx/e)") || (intended_device_family == "PIRANHA") || (intended_device_family == "piranha"))
                                || ((intended_device_family == "HardCopy IV") || (intended_device_family == "HARDCOPY IV") || (intended_device_family == "hardcopy iv") || (intended_device_family == "HardCopyIV") || (intended_device_family == "HARDCOPYIV") || (intended_device_family == "hardcopyiv") || (intended_device_family == "HCXIV") || (intended_device_family == "hcxiv") || (intended_device_family == "HardCopy IV (GX/E)") || (intended_device_family == "HARDCOPY IV (GX/E)") || (intended_device_family == "hardcopy iv (gx/e)") || (intended_device_family == "HardCopyIV(GX/E)") || (intended_device_family == "HARDCOPYIV(GX/E)") || (intended_device_family == "hardcopyiv(gx/e)"))
                                ) || ((intended_device_family == "HardCopy III") || (intended_device_family == "HARDCOPY III") || (intended_device_family == "hardcopy iii") || (intended_device_family == "HardCopyIII") || (intended_device_family == "HARDCOPYIII") || (intended_device_family == "hardcopyiii") || (intended_device_family == "HCX") || (intended_device_family == "hcx"))
                                ) || (((intended_device_family == "Cyclone III") || (intended_device_family == "CYCLONE III") || (intended_device_family == "cyclone iii") || (intended_device_family == "CycloneIII") || (intended_device_family == "CYCLONEIII") || (intended_device_family == "cycloneiii") || (intended_device_family == "Barracuda") || (intended_device_family == "BARRACUDA") || (intended_device_family == "barracuda") || (intended_device_family == "Cuda") || (intended_device_family == "CUDA") || (intended_device_family == "cuda") || (intended_device_family == "CIII") || (intended_device_family == "ciii"))
                                || ((intended_device_family == "Cyclone III LS") || (intended_device_family == "CYCLONE III LS") || (intended_device_family == "cyclone iii ls") || (intended_device_family == "CycloneIIILS") || (intended_device_family == "CYCLONEIIILS") || (intended_device_family == "cycloneiiils") || (intended_device_family == "Cyclone III LPS") || (intended_device_family == "CYCLONE III LPS") || (intended_device_family == "cyclone iii lps") || (intended_device_family == "Cyclone LPS") || (intended_device_family == "CYCLONE LPS") || (intended_device_family == "cyclone lps") || (intended_device_family == "CycloneLPS") || (intended_device_family == "CYCLONELPS") || (intended_device_family == "cyclonelps") || (intended_device_family == "Tarpon") || (intended_device_family == "TARPON") || (intended_device_family == "tarpon") || (intended_device_family == "Cyclone IIIE") || (intended_device_family == "CYCLONE IIIE") || (intended_device_family == "cyclone iiie"))
                                ) ))
                                ? 1 : 0;

    parameter WRITE_SIDE_SYNCHRONIZERS = (wrsync_delaypipe != 0) ? wrsync_delaypipe :
                                (((FAMILY_HAS_STRATIXII_STYLE_RAM == 1) || (FAMILY_HAS_STRATIXIII_STYLE_RAM == 1))
                                && (clocks_are_synchronized == "FALSE"))
                                ?  4 : 3;

    parameter READ_SIDE_SYNCHRONIZERS = (rdsync_delaypipe != 0) ? rdsync_delaypipe :
                                (((FAMILY_HAS_STRATIXII_STYLE_RAM == 1) || (FAMILY_HAS_STRATIXIII_STYLE_RAM == 1))
                                && (clocks_are_synchronized == "FALSE"))
                                ?  4 : 3;

// INPUT PORT DECLARATION
    input [lpm_width-1:0] data;
    input rdclk;
    input wrclk;
    input aclr;
    input rdreq;
    input wrreq;

// OUTPUT PORT DECLARATION
    output rdfull;
    output wrfull;
    output rdempty;
    output wrempty;
    output [lpm_widthu_r-1:0] rdusedw;
    output [lpm_widthu-1:0] wrusedw;
    output [lpm_width_r-1:0] q;

// INTERNAL WIRE DECLARATION
    wire w_rdfull_s;
    wire w_wrfull_s;
    wire w_rdempty_s;
    wire w_wrempty_s;
    wire w_rdfull_a;
    wire w_wrfull_a;
    wire w_rdempty_a;
    wire w_wrempty_a;
    wire w_rdfull_l;
    wire w_wrfull_l;
    wire w_rdempty_l;
    wire w_wrempty_l;
    wire [lpm_widthu-1:0] w_rdusedw_s;
    wire [lpm_widthu-1:0] w_wrusedw_s;
    wire [lpm_widthu-1:0] w_rdusedw_a;
    wire [lpm_widthu-1:0] w_wrusedw_a;
    wire [lpm_widthu_r-1:0] w_rdusedw_l;
    wire [lpm_widthu-1:0] w_wrusedw_l;
    wire [lpm_width-1:0] w_q_s;
    wire [lpm_width-1:0] w_q_a;
    wire [lpm_width_r-1:0] w_q_l;

// INTERNAL TRI DECLARATION
    tri0 aclr;

// COMPONENT INSTANTIATIONS
    ALTERA_DEVICE_FAMILIES dev ();

    dcfifo_sync SYNC (
        .data (data),
        .rdclk (rdclk),
        .wrclk (wrclk),
        .aclr (aclr),
        .rdreq (rdreq),
        .wrreq (wrreq),
        .rdfull (w_rdfull_s),
        .wrfull (w_wrfull_s),
        .rdempty (w_rdempty_s),
        .wrempty (w_wrempty_s),
        .rdusedw (w_rdusedw_s),
        .wrusedw (w_wrusedw_s),
        .q (w_q_s));
    defparam
        SYNC.lpm_width = lpm_width,
        SYNC.lpm_widthu = lpm_widthu,
        SYNC.lpm_numwords = lpm_numwords,
        SYNC.intended_device_family = intended_device_family,
        SYNC.lpm_showahead = lpm_showahead,
        SYNC.underflow_checking = underflow_checking,
        SYNC.overflow_checking = overflow_checking,
        SYNC.use_eab = use_eab,
        SYNC.add_ram_output_register = add_ram_output_register;

    dcfifo_async ASYNC (
        .data (data),
        .rdclk (rdclk),
        .wrclk (wrclk),
        .aclr (aclr),
        .rdreq (rdreq),
        .wrreq (wrreq),
        .rdfull (w_rdfull_a),
        .wrfull (w_wrfull_a),
        .rdempty (w_rdempty_a),
        .wrempty (w_wrempty_a),
        .rdusedw (w_rdusedw_a),
        .wrusedw (w_wrusedw_a),
        .q (w_q_a) );
    defparam
        ASYNC.lpm_width = lpm_width,
        ASYNC.lpm_widthu = lpm_widthu,
        ASYNC.lpm_numwords = lpm_numwords,
        ASYNC.delay_rdusedw = delay_rdusedw,
        ASYNC.delay_wrusedw = delay_wrusedw,
        ASYNC.rdsync_delaypipe = READ_SIDE_SYNCHRONIZERS,
        ASYNC.wrsync_delaypipe = WRITE_SIDE_SYNCHRONIZERS,
        ASYNC.intended_device_family = intended_device_family,
        ASYNC.lpm_showahead = lpm_showahead,
        ASYNC.underflow_checking = underflow_checking,
        ASYNC.overflow_checking = overflow_checking,
        ASYNC.use_eab = use_eab,
        ASYNC.add_ram_output_register = add_ram_output_register;

    dcfifo_low_latency LOWLATENCY (
        .data (data),
        .rdclk (rdclk),
        .wrclk (wrclk),
        .aclr (aclr),
        .rdreq (rdreq),
        .wrreq (wrreq),
        .rdfull (w_rdfull_l),
        .wrfull (w_wrfull_l),
        .rdempty (w_rdempty_l),
        .wrempty (w_wrempty_l),
        .rdusedw (w_rdusedw_l),
        .wrusedw (w_wrusedw_l),
        .q (w_q_l) );
    defparam
        LOWLATENCY.lpm_width = lpm_width,
        LOWLATENCY.lpm_widthu = lpm_widthu,
        LOWLATENCY.lpm_width_r = lpm_width_r,
        LOWLATENCY.lpm_widthu_r = lpm_widthu_r,
        LOWLATENCY.lpm_numwords = lpm_numwords,
        LOWLATENCY.delay_rdusedw = delay_rdusedw,
        LOWLATENCY.delay_wrusedw = delay_wrusedw,
        LOWLATENCY.rdsync_delaypipe = (READ_SIDE_SYNCHRONIZERS > 3 ? READ_SIDE_SYNCHRONIZERS - 2 : 1),
        LOWLATENCY.wrsync_delaypipe = (WRITE_SIDE_SYNCHRONIZERS > 3 ? WRITE_SIDE_SYNCHRONIZERS - 2 : 1),
        LOWLATENCY.intended_device_family = intended_device_family,
        LOWLATENCY.lpm_showahead = lpm_showahead,
        LOWLATENCY.underflow_checking = underflow_checking,
        LOWLATENCY.overflow_checking = overflow_checking,
        LOWLATENCY.add_usedw_msb_bit = add_usedw_msb_bit,
        LOWLATENCY.write_aclr_synch = write_aclr_synch,
        LOWLATENCY.use_eab = use_eab,
        LOWLATENCY.clocks_are_synchronized = clocks_are_synchronized,
        LOWLATENCY.add_ram_output_register = add_ram_output_register,
        LOWLATENCY.lpm_hint = lpm_hint;

// INITIAL CONSTRUCT BLOCK
    initial
    begin
        if(((wrsync_delaypipe == 0) || (rdsync_delaypipe == 0)) && (clocks_are_synchronized == "FALSE"))
        begin
            if ((FAMILY_HAS_STRATIXII_STYLE_RAM == 1) || (FAMILY_HAS_STRATIXIII_STYLE_RAM == 1))
            begin
                $display ("Warning! Number of metastability protection registers is not specified. Based on the parameter value CLOCKS_ARE_SYNCHRONIZED=FALSE, the synchronization register chain length between read and write clock domains will be 2.");
                $display("Time: %0t  Instance: %m", $time);
            end
        end    
    end

// CONTINOUS ASSIGNMENT
    assign  rdfull = (dev.FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM(intended_device_family) &&
                        ((use_eab == "ON") || ((use_eab == "OFF") && (lpm_width != lpm_width_r) && (lpm_width_r != 0)) ||
                        ((lpm_numwords < 16) && (clocks_are_synchronized == "FALSE")))) ||
                    (dev.FEATURE_FAMILY_STRATIX(intended_device_family) && (use_eab == "ON") &&
                        (((lpm_showahead == "ON") && (add_ram_output_register == "OFF")) ||
                        (clocks_are_synchronized == "FALSE_LOW_LATENCY"))) ? w_rdfull_l :
                    (clocks_are_synchronized == "TRUE")  ? w_rdfull_s : w_rdfull_a;

    assign  wrfull = (dev.FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM(intended_device_family) &&
                        ((use_eab == "ON") || ((use_eab == "OFF") && (lpm_width != lpm_width_r) && (lpm_width_r != 0)) ||
                        ((lpm_numwords < 16) && (clocks_are_synchronized == "FALSE")))) ||
                    (dev.FEATURE_FAMILY_STRATIX(intended_device_family) && (use_eab == "ON") &&
                        (((lpm_showahead == "ON") && (add_ram_output_register == "OFF")) ||
                        (clocks_are_synchronized == "FALSE_LOW_LATENCY"))) ? w_wrfull_l :
                    (clocks_are_synchronized == "TRUE")  ? w_wrfull_s : w_wrfull_a;

    assign rdempty = (dev.FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM(intended_device_family) &&
                        ((use_eab == "ON") || ((use_eab == "OFF") && (lpm_width != lpm_width_r) && (lpm_width_r != 0)) ||
                        ((lpm_numwords < 16) && (clocks_are_synchronized == "FALSE")))) ||
                    (dev.FEATURE_FAMILY_STRATIX(intended_device_family) && (use_eab == "ON") &&
                        (((lpm_showahead == "ON") && (add_ram_output_register == "OFF")) ||
                        (clocks_are_synchronized == "FALSE_LOW_LATENCY"))) ? w_rdempty_l :
                    (clocks_are_synchronized == "TRUE")  ? w_rdempty_s : w_rdempty_a;

    assign wrempty = (dev.FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM(intended_device_family) &&
                        ((use_eab == "ON") || ((use_eab == "OFF") && (lpm_width != lpm_width_r) && (lpm_width_r != 0)) ||
                        ((lpm_numwords < 16) && (clocks_are_synchronized == "FALSE")))) ||
                    (dev.FEATURE_FAMILY_STRATIX(intended_device_family) && (use_eab == "ON") &&
                        (((lpm_showahead == "ON") && (add_ram_output_register == "OFF")) ||
                        (clocks_are_synchronized == "FALSE_LOW_LATENCY"))) ? w_wrempty_l :
                    (clocks_are_synchronized == "TRUE")  ? w_wrempty_s : w_wrempty_a;

    assign rdusedw = (dev.FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM(intended_device_family) &&
                        ((use_eab == "ON") || ((use_eab == "OFF") && (lpm_width != lpm_width_r) && (lpm_width_r != 0)) ||
                        ((lpm_numwords < 16) && (clocks_are_synchronized == "FALSE")))) ||
                    (dev.FEATURE_FAMILY_STRATIX(intended_device_family) && (use_eab == "ON") &&
                        (((lpm_showahead == "ON") && (add_ram_output_register == "OFF")) ||
                        (clocks_are_synchronized == "FALSE_LOW_LATENCY"))) ? w_rdusedw_l :
                    (clocks_are_synchronized == "TRUE")  ? w_rdusedw_s : w_rdusedw_a;

    assign wrusedw = (dev.FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM(intended_device_family) &&
                        ((use_eab == "ON") || ((use_eab == "OFF") && (lpm_width != lpm_width_r) && (lpm_width_r != 0)) ||
                        ((lpm_numwords < 16) && (clocks_are_synchronized == "FALSE")))) ||
                    (dev.FEATURE_FAMILY_STRATIX(intended_device_family) && (use_eab == "ON") &&
                        (((lpm_showahead == "ON") && (add_ram_output_register == "OFF")) ||
                        (clocks_are_synchronized == "FALSE_LOW_LATENCY"))) ? w_wrusedw_l :
                    (clocks_are_synchronized == "TRUE")  ? w_wrusedw_s : w_wrusedw_a;

    assign       q = (dev.FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM(intended_device_family) &&
                        ((use_eab == "ON") || ((use_eab == "OFF") && (lpm_width != lpm_width_r) && (lpm_width_r != 0)) ||
                        ((lpm_numwords < 16) && (clocks_are_synchronized == "FALSE")))) ||
                    (dev.FEATURE_FAMILY_STRATIX(intended_device_family) && (use_eab == "ON") &&
                        (((lpm_showahead == "ON") && (add_ram_output_register == "OFF")) ||
                        (clocks_are_synchronized == "FALSE_LOW_LATENCY"))) ? w_q_l :
                    (clocks_are_synchronized == "TRUE")  ? w_q_s : w_q_a;

endmodule // dcfifo_mixed_widths
// END OF MODULE

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  dcfifo
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
module dcfifo ( data, rdclk, wrclk, aclr, rdreq, wrreq,
                rdfull, wrfull, rdempty, wrempty, rdusedw, wrusedw, q);

// GLOBAL PARAMETER DECLARATION
    parameter lpm_width = 1;
    parameter lpm_widthu = 1;
    parameter lpm_numwords = 2;
    parameter delay_rdusedw = 1;
    parameter delay_wrusedw = 1;
    parameter rdsync_delaypipe = 0;
    parameter wrsync_delaypipe = 0;
    parameter intended_device_family = "APEX20KE";
    parameter lpm_showahead = "OFF";
    parameter underflow_checking = "ON";
    parameter overflow_checking = "ON";
    parameter clocks_are_synchronized = "FALSE";
    parameter use_eab = "ON";
    parameter add_ram_output_register = "OFF";
    parameter add_width = 1;
    parameter lpm_hint = "USE_EAB=ON";
    parameter lpm_type = "dcfifo";
    parameter ram_block_type = "AUTO";
    parameter add_usedw_msb_bit = "OFF";
    parameter write_aclr_synch = "OFF";

// INPUT PORT DECLARATION
    input [lpm_width-1:0] data;
    input rdclk;
    input wrclk;
    input aclr;
    input rdreq;
    input wrreq;

// OUTPUT PORT DECLARATION
    output rdfull;
    output wrfull;
    output rdempty;
    output wrempty;
    output [lpm_widthu-1:0] rdusedw;
    output [lpm_widthu-1:0] wrusedw;
    output [lpm_width-1:0] q;

// INTERNAL WIRE DECLARATION
    wire w_rdfull;
    wire w_wrfull;
    wire w_rdempty;
    wire w_wrempty;
    wire [lpm_widthu-1:0] w_rdusedw;
    wire [lpm_widthu-1:0] w_wrusedw;
    wire [lpm_width-1:0] w_q;

// INTERNAL TRI DECLARATION
    tri0 aclr;

    dcfifo_mixed_widths DCFIFO_MW (
        .data (data),
        .rdclk (rdclk),
        .wrclk (wrclk),
        .aclr (aclr),
        .rdreq (rdreq),
        .wrreq (wrreq),
        .rdfull (w_rdfull),
        .wrfull (w_wrfull),
        .rdempty (w_rdempty),
        .wrempty (w_wrempty),
        .rdusedw (w_rdusedw),
        .wrusedw (w_wrusedw),
        .q (w_q) );
    defparam
        DCFIFO_MW.lpm_width = lpm_width,
        DCFIFO_MW.lpm_widthu = lpm_widthu,
        DCFIFO_MW.lpm_width_r = lpm_width,
        DCFIFO_MW.lpm_widthu_r = lpm_widthu,
        DCFIFO_MW.lpm_numwords = lpm_numwords,
        DCFIFO_MW.delay_rdusedw = delay_rdusedw,
        DCFIFO_MW.delay_wrusedw = delay_wrusedw,
        DCFIFO_MW.rdsync_delaypipe = rdsync_delaypipe,
        DCFIFO_MW.wrsync_delaypipe = wrsync_delaypipe,
        DCFIFO_MW.intended_device_family = intended_device_family,
        DCFIFO_MW.lpm_showahead = lpm_showahead,
        DCFIFO_MW.underflow_checking = underflow_checking,
        DCFIFO_MW.overflow_checking = overflow_checking,
        DCFIFO_MW.clocks_are_synchronized = clocks_are_synchronized,
        DCFIFO_MW.use_eab = use_eab,
        DCFIFO_MW.add_ram_output_register = add_ram_output_register,
        DCFIFO_MW.add_width = add_width,
        DCFIFO_MW.ram_block_type = ram_block_type,
        DCFIFO_MW.add_usedw_msb_bit = add_usedw_msb_bit,
        DCFIFO_MW.write_aclr_synch = write_aclr_synch,
        DCFIFO_MW.lpm_hint = lpm_hint;

// CONTINOUS ASSIGNMENT
    assign  rdfull = w_rdfull;
    assign  wrfull = w_wrfull;
    assign rdempty = w_rdempty;
    assign wrempty = w_wrempty;
    assign rdusedw = w_rdusedw;
    assign wrusedw = w_wrusedw;
    assign       q = w_q;

endmodule // dcfifo
