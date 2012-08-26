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
    reg feature_family_has_stratixiii_style_ram;
    reg feature_family_has_stratixii_style_ram;
    reg feature_family_stratixii;
    reg feature_family_cycloneii;
    reg feature_family_stratix;

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
    integer i_mem_address;
    integer i_first_bit_position;

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
    
    feature_family_has_stratixiii_style_ram = dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family);
    feature_family_has_stratixii_style_ram = dev.FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM(intended_device_family);
    feature_family_stratixii = dev.FEATURE_FAMILY_STRATIXII(intended_device_family);
    feature_family_cycloneii = dev.FEATURE_FAMILY_CYCLONEII(intended_device_family);
    feature_family_stratix = dev.FEATURE_FAMILY_STRATIX(intended_device_family);
    
        if ((lpm_showahead != "ON") && (lpm_showahead != "OFF"))
            $display ("Error! LPM_SHOWAHEAD must be ON or OFF.");
        if ((underflow_checking != "ON") && (underflow_checking != "OFF"))
            $display ("Error! UNDERFLOW_CHECKING must be ON or OFF.");
        if ((overflow_checking != "ON") && (overflow_checking != "OFF"))
            $display ("Error! OVERFLOW_CHECKING must be ON or OFF.");
        if (lpm_numwords > (1 << lpm_widthu))
            $display ("Error! LPM_NUMWORDS must be less than or equal to 2**LPM_WIDTHU.");
        if (dev.IS_VALID_FAMILY(intended_device_family) == 0)
            $display ("Error! Unknown INTENDED_DEVICE_FAMILY=%s.", intended_device_family);

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
        i_mem_address <= 0;
        i_first_bit_position <= 0;

        i_maximize_speed = str_to_int(eva.GET_PARAMETER_VALUE(lpm_hint, "MAXIMIZE_SPEED"));

        if (feature_family_has_stratixiii_style_ram == 1)
        begin
            use_wrempty_speed <= 1;
            use_rdfull_speed <= 1;
        end
        else if (feature_family_has_stratixii_style_ram == 1)
        begin
            use_wrempty_speed <= ((i_maximize_speed > 5) || (wrsync_delaypipe >= 2)) ? 1 : 0;
            use_rdfull_speed <= ((i_maximize_speed > 5) || (rdsync_delaypipe >= 2)) ? 1 : 0;
        end
        else
        begin
            use_wrempty_speed <= 0;
            use_rdfull_speed <= 0;
        end

        if (feature_family_has_stratixii_style_ram == 1)
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
        ((feature_family_stratixii == 1) ||
        ((feature_family_cycloneii == 1))))
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
        i_mem_address <= 0;
        i_first_bit_position <= 0;

        if(i_q_is_registered)
            i_q <= 0;
        else if ((feature_family_stratixii == 1) ||
        (feature_family_cycloneii == 1))
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
                    if (((feature_family_has_stratixii_style_ram == 1) &&
                        ((use_eab == "ON") || ((use_eab == "OFF") && (lpm_width != lpm_width_r) && (lpm_width_r != 0)) ||
                        ((lpm_numwords < 16) && (clocks_are_synchronized == "FALSE")))) ||
                        ((feature_family_stratix == 1) && (use_eab == "ON") &&
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
                        i_mem_address <= i_wrptr_g1 /WIDTH_RATIO;
                        i_first_bit_position <= (i_wrptr_g1 % WIDTH_RATIO) *lpm_width;
                        for(i = 0; i < lpm_width; i = i+1)
                            mem_data[i_mem_address][i_first_bit_position + i] <= data[i];
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
                    if (((feature_family_has_stratixii_style_ram == 1) &&
                        ((use_eab == "ON") || ((use_eab == "OFF") && (lpm_width != lpm_width_r) && (lpm_width_r != 0)) ||
                        ((lpm_numwords < 16) && (clocks_are_synchronized == "FALSE")))) ||
                        ((feature_family_stratix == 1) && (use_eab == "ON") &&
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
                if (aclr && ((feature_family_stratixii == 1) ||
                (feature_family_cycloneii == 1)))
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

        if ((~aclr) && (write_aclr_synch == "ON") && ((feature_family_stratixii == 1) ||
            (feature_family_cycloneii == 1)))
            i_wrfull_wreg <= (i_wrfull | write_aclr);            
        else
            i_wrfull_wreg <= i_wrfull;
    end // @(posedge wrclk)

// CONTINOUS ASSIGNMENT
    assign i_rden = (underflow_checking == "OFF") ? rdreq : (rdreq && !i_rdempty);
    assign i_wren = (((feature_family_stratixii == 1) ||
                    (feature_family_cycloneii == 1)) &&
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
                        (((feature_family_stratixii == 1) ||
                        (feature_family_cycloneii == 1)) &&
                        (write_aclr_synch == "ON")) ? (i_wrfull | write_aclr) : i_wrfull;
    assign wrusedw = (is_underflow || is_overflow) ? {lpm_widthu{1'bx}} :
                        i_wrusedw[lpm_widthu-1:0];
    assign rdusedw = (is_underflow || is_overflow) ? {lpm_widthu_r{1'bx}} :
                        i_rdusedw[lpm_widthu_r-1:0];
    assign q = (is_underflow || is_overflow) ? {lpm_width_r{1'bx}} : i_q;
    assign write_aclr = (((feature_family_stratixii == 1) ||
                        (feature_family_cycloneii == 1)) &&
                        (write_aclr_synch == "ON")) ? sync_aclr : aclr;

endmodule // dcfifo_low_latency
