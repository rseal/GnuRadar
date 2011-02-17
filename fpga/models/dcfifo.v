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
    parameter intended_device_family = "Stratix";
    parameter lpm_showahead = "OFF";
    parameter underflow_checking = "ON";
    parameter overflow_checking = "ON";
    parameter clocks_are_synchronized = "FALSE";
    parameter use_eab = "ON";
    parameter add_ram_output_register = "OFF";
    parameter lpm_hint = "USE_EAB=ON";
    parameter lpm_type = "dcfifo";
    parameter add_usedw_msb_bit = "OFF";
    parameter write_aclr_synch = "OFF";

// LOCAL_PARAMETERS_BEGIN

    parameter add_width = 1;
    parameter ram_block_type = "AUTO";

// LOCAL_PARAMETERS_END

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
// END OF MODULE

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  altaccumulate
//
// Description     :  Parameterized accumulator megafunction. The accumulator
// performs an add function or a subtract function based on the add_sub
// parameter. The input data can be signed or unsigned.
//
// Limitation      : n/a
//
// Results expected:  result - The results of add or subtract operation. Output
//                             port [width_out-1 .. 0] wide.
//                    cout   - The cout port has a physical interpretation as 
//                             the carry-out (borrow-in) of the MSB. The cout
//                             port is most meaningful for detecting overflow
//                             in unsigned operations. The cout port operates
//                             in the same manner for signed and unsigned
//                             operations.
//                    overflow - Indicates the accumulator is overflow.
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE

`timescale 1 ps / 1 ps

module altaccumulate (cin, data, add_sub, clock, sload, clken, sign_data, aclr,
                        result, cout, overflow);

    parameter width_in = 4;     // Required
    parameter width_out = 8;    // Required
    parameter lpm_representation = "UNSIGNED";
    parameter extra_latency = 0;
    parameter use_wys = "ON";
    parameter lpm_hint = "UNUSED";
    parameter lpm_type = "altaccumulate";

    // INPUT PORT DECLARATION
    input cin;
    input [width_in-1:0] data;  // Required port
    input add_sub;              // Default = 1
    input clock;                // Required port
    input sload;                // Default = 0
    input clken;                // Default = 1
    input sign_data;            // Default = 0
    input aclr;                 // Default = 0

    // OUTPUT PORT DECLARATION
    output [width_out-1:0] result;  //Required port
    output cout;
    output overflow;

    // INTERNAL REGISTERS DECLARATION
    reg [width_out:0] temp_sum;
    reg overflow_int;
    reg cout_int;


    reg [width_out+1:0] result_int;
    reg [(width_out - width_in) : 0] zeropad;

    reg borrow;
    reg cin_int;

    reg [width_out-1:0] fb_int;
    reg [width_out -1:0] data_int;

    reg [width_out+1:0] result_pipe [extra_latency:0];
    reg [width_out+1:0] result_full;
    reg [width_out+1:0] result_full2;

    reg a;

    // INTERNAL WIRE DECLARATION
    wire [width_out:0] temp_sum_wire;
    wire cout;
    wire cout_int_wire;
    wire cout_delayed_wire;
    wire overflow_int_wire;
    wire [width_out+1:0] result_int_wire;

    // INTERNAL TRI DECLARATION

    tri0 aclr_int;
    tri0 sign_data_int;
    tri0 sload_int;

    tri1 clken_int;
    tri1 add_sub_int;

    // LOCAL INTEGER DECLARATION
    integer head;
    integer i;

    // INITIAL CONSTRUCT BLOCK
    initial
    begin
    
        // Checking for invalid parameters
        if( width_in <= 0 )
        begin
            $display("Error! Value of width_in parameter must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if( width_out <= 0 )
        begin
            $display("Error! Value of width_out parameter must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if( extra_latency > width_out )
        begin
            $display("Info: Value of extra_latency parameter should be lower than width_out parameter for better performance/utilization.");
        end
        
        if( width_in > width_out )
        begin
            $display("Error! Value of width_in parameter should be lower than or equal to width_out.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
    
        result_full = 0;
        head = 0;
        result_int = 0;
        for (i = 0; i <= extra_latency; i = i +1)
        begin
            result_pipe [i] = 0;
        end
    end

    // ALWAYS CONSTRUCT BLOCK
    always @(posedge clock or posedge aclr_int)
    begin

        if (aclr_int == 1)
        begin
            result_int <= 0;
            result_full <= 0;
            head <= 0;
            for (i = 0; i <= extra_latency; i = i +1)
            begin
                result_pipe [i] <= 0;
            end
            
        end
        else
        begin
            if (clken_int == 1)
            begin
                //get result from output register
                if (extra_latency > 0)
                begin
                    result_pipe [head] <= {
                                            result_int [width_out+1],
                                            {cout_int_wire, result_int [width_out-1:0]}
                                        };

                    head <= (head + 1) % (extra_latency);

                end
                else
                begin
                    result_full <= {overflow_int_wire, {cout_int_wire, temp_sum_wire [width_out-1:0]}};
                    
                end

                result_int <= {overflow_int_wire, {cout_int_wire, temp_sum_wire [width_out-1:0]}};
            end
        end
    end

    always @ (result_pipe[head] or head)
    begin
        if (extra_latency > 0)
                result_full = result_pipe [head];
                
    end

    always @ (data or cin or add_sub_int or sign_data_int or
                result_int_wire [width_out -1:0] or sload_int)
    begin
        
        if ((lpm_representation == "SIGNED") || (sign_data_int == 1))
        begin
            zeropad = (data [width_in-1] ==0) ? 0 : -1;
        end
        else
        begin
            zeropad = 0;
        end

        fb_int = (sload_int == 1'b1) ? 0 : result_int_wire [width_out-1:0];
        data_int = {zeropad, data};

        if ((add_sub_int == 1) || (sload_int == 1))
        begin
            cin_int = ((sload_int == 1'b1) ? 0 : ((cin === 1'bz) ? 0 : cin));
            temp_sum = fb_int + data_int + cin_int;
            cout_int = temp_sum [width_out];
        end
        else
        begin
            cin_int = (cin === 1'bz) ? 1 : cin;
            borrow = ~cin_int;

            temp_sum = fb_int - data_int - borrow;

            result_full2 = data_int + borrow;
            cout_int = (fb_int >= result_full2) ? 1 : 0;
        end

        if ((lpm_representation == "SIGNED") || (sign_data_int == 1))
        begin
            a = (data [width_in-1] ~^ fb_int [width_out-1]) ^ (~add_sub_int);
            overflow_int = a & (fb_int [width_out-1] ^ temp_sum[width_out-1]);
        end
        else
        begin
            overflow_int = (add_sub_int == 1) ? cout_int : ~cout_int;
        end

        if (sload_int == 1)
        begin
            cout_int = !add_sub_int;
            overflow_int = 0;
        end
       
    end

    // CONTINOUS ASSIGNMENT

    // Get the input data and control signals.
    assign sign_data_int = sign_data;
    assign sload_int =  sload;
    assign add_sub_int = add_sub;

    assign clken_int = clken;
    assign aclr_int = aclr;
    assign result_int_wire = result_int;
    assign temp_sum_wire = temp_sum;
    assign cout_int_wire = cout_int;
    assign overflow_int_wire = overflow_int;
    assign cout = (extra_latency == 0) ? cout_int_wire : cout_delayed_wire;
    assign cout_delayed_wire = result_full[width_out];
    assign result = result_full [width_out-1:0];
    assign overflow = result_full [width_out+1];

endmodule   // End of altaccumulate

// END OF MODULE

//--------------------------------------------------------------------------
// Module Name      : altmult_accum
//
// Description      : a*b + x (MAC)
//
// Limitation       : Stratix DSP block
//
// Results expected : signed & unsigned, maximum of 3 pipelines(latency) each.
//
//--------------------------------------------------------------------------

`timescale 1 ps / 1 ps

module altmult_accum (  dataa, 
                        datab, 
			            datac,
                        scanina,
                        scaninb,
                        sourcea,
                        sourceb,
                        accum_sload_upper_data,
                        addnsub, 
                        accum_sload, 
                        signa, 
                        signb,
                        clock0, 
                        clock1, 
                        clock2, 
                        clock3,
                        ena0, 
                        ena1, 
                        ena2, 
                        ena3,
                        aclr0, 
                        aclr1, 
                        aclr2, 
                        aclr3,
                        result, 
                        overflow, 
                        scanouta, 
                        scanoutb,
                        mult_round,
                        mult_saturation,
                        accum_round,
                        accum_saturation,
                        mult_is_saturated,
                        accum_is_saturated,
			            coefsel0,
		             	coefsel1,
			            coefsel2,
			            coefsel3);

    // ---------------------
    // PARAMETER DECLARATION
    // ---------------------
    parameter width_a                   = 2;
    parameter width_b                   = 2;
	parameter width_c					= 22;
    parameter width_result              = 5;
    parameter number_of_multipliers		= 1;
    parameter input_reg_a               = "CLOCK0";
    parameter input_aclr_a              = "ACLR3";
    parameter multiplier1_direction		= "UNUSED";
    parameter multiplier3_direction		= "UNUSED";

    parameter input_reg_b               = "CLOCK0";
    parameter input_aclr_b              = "ACLR3";
    parameter port_addnsub              = "PORT_CONNECTIVITY";
    parameter addnsub_reg               = "CLOCK0";
    parameter addnsub_aclr              = "ACLR3";
    parameter addnsub_pipeline_reg      = "CLOCK0";
    parameter addnsub_pipeline_aclr     = "ACLR3";
    parameter accum_direction           = "ADD";
    parameter accum_sload_reg           = "CLOCK0";
    parameter accum_sload_aclr          = "ACLR3";
    parameter accum_sload_pipeline_reg  = "CLOCK0";
    parameter accum_sload_pipeline_aclr = "ACLR3";
    parameter representation_a          = "UNSIGNED";
    parameter port_signa                = "PORT_CONNECTIVITY";
    parameter sign_reg_a                = "CLOCK0";
    parameter sign_aclr_a               = "ACLR3";
    parameter sign_pipeline_reg_a       = "CLOCK0";
    parameter sign_pipeline_aclr_a      = "ACLR3";
    parameter port_signb                = "PORT_CONNECTIVITY";
    parameter representation_b          = "UNSIGNED";
    parameter sign_reg_b                = "CLOCK0";
    parameter sign_aclr_b               = "ACLR3";
    parameter sign_pipeline_reg_b       = "CLOCK0";
    parameter sign_pipeline_aclr_b      = "ACLR3";
    parameter multiplier_reg            = "CLOCK0";
    parameter multiplier_aclr           = "ACLR3";
    parameter output_reg                = "CLOCK0";
    parameter output_aclr               = "ACLR3";
    parameter lpm_type                  = "altmult_accum";
    parameter lpm_hint                  = "UNUSED";

    parameter extra_multiplier_latency       = 0;
    parameter extra_accumulator_latency      = 0;
    parameter dedicated_multiplier_circuitry = "AUTO";
    parameter dsp_block_balancing            = "AUTO";
    parameter intended_device_family         = "Stratix";

    // StratixII related parameter
    parameter accum_round_aclr = "ACLR3";
    parameter accum_round_pipeline_aclr = "ACLR3";
    parameter accum_round_pipeline_reg = "CLOCK0";
    parameter accum_round_reg = "CLOCK0";
    parameter accum_saturation_aclr = "ACLR3";
    parameter accum_saturation_pipeline_aclr = "ACLR3";
    parameter accum_saturation_pipeline_reg = "CLOCK0";
    parameter accum_saturation_reg = "CLOCK0";
    parameter accum_sload_upper_data_aclr = "ACLR3";
    parameter accum_sload_upper_data_pipeline_aclr = "ACLR3";
    parameter accum_sload_upper_data_pipeline_reg = "CLOCK0";
    parameter accum_sload_upper_data_reg = "CLOCK0";
    parameter mult_round_aclr = "ACLR3";
    parameter mult_round_reg = "CLOCK0";
    parameter mult_saturation_aclr = "ACLR3";
    parameter mult_saturation_reg = "CLOCK0";
    
    parameter input_source_a  = "DATAA";
    parameter input_source_b  = "DATAB";
    parameter width_upper_data = 1;
    parameter multiplier_rounding = "NO";
    parameter multiplier_saturation = "NO";
    parameter accumulator_rounding = "NO";
    parameter accumulator_saturation = "NO";
    parameter port_mult_is_saturated = "UNUSED";
    parameter port_accum_is_saturated = "UNUSED";

// LOCAL_PARAMETERS_BEGIN

    parameter int_width_a = ((multiplier_saturation == "NO") && (multiplier_rounding == "NO") && (accumulator_saturation == "NO") && (accumulator_rounding == "NO")) ? width_a : 18;
    parameter int_width_b = ((multiplier_saturation == "NO") && (multiplier_rounding == "NO") && (accumulator_saturation == "NO") && (accumulator_rounding == "NO")) ? width_b : 18;
    parameter int_width_result = ((multiplier_saturation == "NO") && (multiplier_rounding == "NO") && (accumulator_saturation == "NO") && (accumulator_rounding == "NO")) ?
                                    ((int_width_a + int_width_b - 1) > width_result ? (int_width_a + int_width_b - 1) : width_result) :
                                    ((int_width_a + int_width_b - 1) > 52 ? (int_width_a + int_width_b - 1) : 52);
    parameter int_extra_width = ((multiplier_saturation == "NO") && (multiplier_rounding == "NO") && (accumulator_saturation == "NO") && (accumulator_rounding == "NO")) ? 0 : (int_width_a + int_width_b - width_a - width_b);
    parameter diff_width_a = (int_width_a > width_a) ? int_width_a - width_a : 1;
    parameter diff_width_b = (int_width_b > width_b) ? int_width_b - width_b : 1;
    parameter sat_for_ini = ((multiplier_saturation == "NO") && (accumulator_saturation == "NO")) ? 0 : (int_width_a + int_width_b - 34);
    parameter mult_round_for_ini = ((multiplier_rounding == "NO")? 0 : (int_width_a + int_width_b - 18));
    parameter bits_to_round = (((multiplier_rounding == "NO") && (accumulator_rounding == "NO"))? 0 : int_width_a + int_width_b - 18);
    parameter sload_for_limit = (width_result < width_upper_data)? width_result + int_extra_width : width_upper_data ;
    parameter accum_sat_for_limit = ((accumulator_saturation == "NO")? int_width_result - 1 : int_width_a + int_width_b - 33 );
    parameter int_width_extra_bit = (int_width_result - int_width_a - int_width_b > 0) ? int_width_result - int_width_a - int_width_b : 0;
	//StratixV parameters
  	parameter preadder_mode	= "SIMPLE";
  	parameter loadconst_value = 0;
  	parameter width_coef = 0;
  	
  	parameter loadconst_control_register = "CLOCK0";
  	parameter loadconst_control_aclr	= "ACLR0";
 	
	parameter coefsel0_register = "CLOCK0";
  	parameter coefsel1_register	= "CLOCK0";
  	parameter coefsel2_register	= "CLOCK0";
  	parameter coefsel3_register	= "CLOCK0";
   	parameter coefsel0_aclr	= "ACLR0";
   	parameter coefsel1_aclr	= "ACLR0";
	parameter coefsel2_aclr	= "ACLR0";
   	parameter coefsel3_aclr	= "ACLR0";
	
   	parameter preadder_direction_0	= "ADD";
	parameter preadder_direction_1	= "ADD";
	parameter preadder_direction_2	= "ADD";
	parameter preadder_direction_3	= "ADD";
	
	parameter systolic_delay1 = "UNREGISTERED";
	parameter systolic_delay3 = "UNREGISTERED";
	parameter systolic_aclr1 = "NONE";
	parameter systolic_aclr3 = "NONE";
	
	//coefficient storage
	parameter coef0_0 = 0;
	parameter coef0_1 = 0;
	parameter coef0_2 = 0;
	parameter coef0_3 = 0;
	parameter coef0_4 = 0;
	parameter coef0_5 = 0;
	parameter coef0_6 = 0;
	parameter coef0_7 = 0;
	
	parameter coef1_0 = 0;
	parameter coef1_1 = 0;
	parameter coef1_2 = 0;
	parameter coef1_3 = 0;
	parameter coef1_4 = 0;
	parameter coef1_5 = 0;
	parameter coef1_6 = 0;
	parameter coef1_7 = 0;
	
	parameter coef2_0 = 0;
	parameter coef2_1 = 0;
	parameter coef2_2 = 0;
	parameter coef2_3 = 0;
	parameter coef2_4 = 0;
	parameter coef2_5 = 0;
	parameter coef2_6 = 0;
	parameter coef2_7 = 0;
	
	parameter coef3_0 = 0;
	parameter coef3_1 = 0;
	parameter coef3_2 = 0;
	parameter coef3_3 = 0;
	parameter coef3_4 = 0;
	parameter coef3_5 = 0;
	parameter coef3_6 = 0;
	parameter coef3_7 = 0;

// LOCAL_PARAMETERS_END

    // ----------------
    // PORT DECLARATION
    // ----------------

    // data input ports
    input [width_a -1 : 0] dataa;
    input [width_b -1 : 0] datab;
	input [width_c -1 : 0] datac;
    input [width_a -1 : 0] scanina;
    input [width_b -1 : 0] scaninb;
    input sourcea;
    input sourceb;
    input [width_result -1 : width_result - width_upper_data] accum_sload_upper_data;

    // control signals
    input addnsub;
    input accum_sload;
    input signa;
    input signb;

    // clock ports
    input clock0;
    input clock1;
    input clock2;
    input clock3;

    // clock enable ports
    input ena0;
    input ena1;
    input ena2;
    input ena3;

    // clear ports
    input aclr0;
    input aclr1;
    input aclr2;
    input aclr3;

    // round and saturate ports
    input mult_round;
    input mult_saturation;
    input accum_round;
    input accum_saturation;

	//StratixV only input ports
	input [2:0]coefsel0;
	input [2:0]coefsel1;
	input [2:0]coefsel2;
	input [2:0]coefsel3;
	
    // output ports
    output [width_result -1 : 0] result;
    output overflow;
    output [width_a -1 : 0] scanouta;
    output [width_b -1 : 0] scanoutb;

    output mult_is_saturated;
    output accum_is_saturated;


    // ---------------
    // REG DECLARATION
    // ---------------
    reg [width_result -1 : 0] result;
    
    reg [int_width_result -1 : 0] mult_res_out;
    reg [int_width_result : 0] temp_sum;


    reg [width_result + 1 : 0] result_pipe [extra_accumulator_latency : 0];
    reg [width_result + 1 : 0] result_full ;

    reg [int_width_result - 1 : 0] result_int;
    
    reg [int_width_a - 1 : 0] mult_a_reg;
    reg [int_width_a - 1 : 0] mult_a_int;
    reg [int_width_a + int_width_b - 1 : 0] mult_res;
    reg [int_width_a + int_width_b - 1 : 0] temp_mult_1;
    reg [int_width_a + int_width_b - 1 : 0] temp_mult;


    reg [int_width_b -1 :0] mult_b_reg;
    reg [int_width_b -1 :0] mult_b_int;
    
    reg [5 + int_width_a + int_width_b + width_upper_data : 0] mult_pipe [extra_multiplier_latency:0];
    reg [5 + int_width_a + int_width_b + width_upper_data : 0] mult_full;
    
    reg [width_upper_data - 1 : 0] sload_upper_data_reg;

    reg [width_result - width_upper_data -1 + 4 : 0] lower_bits;

    reg mult_signed_out;
    reg [width_upper_data - 1 : 0] sload_upper_data_pipe_reg;


    reg zero_acc_reg;
    reg zero_acc_pipe_reg;
    reg sign_a_reg;
    reg sign_a_pipe_reg;
    reg sign_b_reg;
    reg sign_b_pipe_reg;
    reg addsub_reg;
    reg addsub_pipe_reg;

    reg mult_signed;
    reg temp_mult_signed;
    reg neg_a;
    reg neg_b;

    reg overflow_int;
    reg cout_int;
    reg overflow_tmp_int;

    reg overflow;
    
    reg [int_width_a + int_width_b -1 : 0] mult_round_out;
    reg mult_saturate_overflow;
    reg [int_width_a + int_width_b -1 : 0] mult_saturate_out;
    reg [int_width_a + int_width_b -1 : 0] mult_result;
    reg [int_width_a + int_width_b -1 : 0] mult_final_out;

    reg [int_width_result -1 : 0] accum_round_out;
    reg accum_saturate_overflow;
    reg [int_width_result -1 : 0] accum_saturate_out;
    reg [int_width_result -1 : 0] accum_result;
    reg [int_width_result -1 : 0] accum_final_out;

    tri0 mult_is_saturated_latent;
    reg mult_is_saturated_int;
    reg mult_is_saturated_reg;
    
    reg accum_is_saturated_latent;
    reg [extra_accumulator_latency : 0] accum_saturate_pipe;
    reg [extra_accumulator_latency : 0] mult_is_saturated_pipe;
    
    reg  mult_round_tmp;
    reg  mult_saturation_tmp;
    reg  accum_round_tmp1;
    reg  accum_round_tmp2;
    reg  accum_saturation_tmp1;
    reg  accum_saturation_tmp2;
    reg is_stratixv;
    reg is_stratixiii;
    reg is_stratixii;
    reg is_cycloneii;
    
    reg  [int_width_result - int_width_a - int_width_b + 2 - 1 : 0] accum_result_sign_bits;

    reg [31:0] head_result;

    // -------------------
    // INTEGER DECLARATION
    // -------------------
    integer i;
    integer i2;
    integer i3;
    integer i4;
    integer head_mult;
    integer flag;


    //-----------------
    // TRI DECLARATION
    //-----------------

    tri0 [width_a -1 : 0] dataa;
    tri0 [width_b -1 : 0] datab;
    tri0 [width_a -1 : 0] scanina;
    tri0 [width_b -1 : 0] scaninb;
    tri0 sourcea;
    tri0 sourceb;
    tri1 ena0;
    tri1 ena1;
    tri1 ena2;
    tri1 ena3;
    tri0 aclr0;
    tri0 aclr1;
    tri0 aclr2;
    tri0 aclr3;
    tri0 mult_round;
    tri0 mult_saturation;
    tri0 accum_round;
    tri0 accum_saturation;

    // Tri wire for clear signal

    tri0 input_a_wire_clr;
    tri0 input_b_wire_clr;

    tri0 addsub_wire_clr;
    tri0 addsub_pipe_wire_clr;

    tri0 zero_wire_clr;
    tri0 zero_pipe_wire_clr;

    tri0 sign_a_wire_clr;
    tri0 sign_pipe_a_wire_clr;

    tri0 sign_b_wire_clr;
    tri0 sign_pipe_b_wire_clr;

    tri0 multiplier_wire_clr;
    tri0 mult_pipe_wire_clr;

    tri0 output_wire_clr;

    tri0 mult_round_wire_clr;
    tri0 mult_saturation_wire_clr;

    tri0 accum_round_wire_clr;
    tri0 accum_round_pipe_wire_clr;

    tri0 accum_saturation_wire_clr;
    tri0 accum_saturation_pipe_wire_clr;

    tri0 accum_sload_upper_data_wire_clr;
    tri0 accum_sload_upper_data_pipe_wire_clr;

    
    // Tri wire for enable signal

    tri1 input_a_wire_en;
    tri1 input_b_wire_en;

    tri1 addsub_wire_en;
    tri1 addsub_pipe_wire_en;

    tri1 zero_wire_en;
    tri1 zero_pipe_wire_en;

    tri1 sign_a_wire_en;
    tri1 sign_pipe_a_wire_en;

    tri1 sign_b_wire_en;
    tri1 sign_pipe_b_wire_en;

    tri1 multiplier_wire_en;
    tri1 mult_pipe_wire_en; 

    tri1 output_wire_en;

    tri1 mult_round_wire_en;
    tri1 mult_saturation_wire_en;

    tri1 accum_round_wire_en;
    tri1 accum_round_pipe_wire_en;

    tri1 accum_saturation_wire_en;
    tri1 accum_saturation_pipe_wire_en;

    tri1 accum_sload_upper_data_wire_en;
    tri1 accum_sload_upper_data_pipe_wire_en;

    // ------------------------
    // SUPPLY WIRE DECLARATION
    // ------------------------

    supply0 [int_width_a + int_width_b - 1 : 0] temp_mult_zero;


    // ----------------
    // WIRE DECLARATION
    // ----------------

    // Wire for Clock signals

    wire input_a_wire_clk;
    wire input_b_wire_clk;

    wire addsub_wire_clk;
    wire addsub_pipe_wire_clk;

    wire zero_wire_clk;
    wire zero_pipe_wire_clk;

    wire sign_a_wire_clk;
    wire sign_pipe_a_wire_clk;

    wire sign_b_wire_clk;
    wire sign_pipe_b_wire_clk;

    wire multiplier_wire_clk;
    wire mult_pipe_wire_clk; 

    wire output_wire_clk;

    wire [width_a -1 : 0] scanouta;
    wire [int_width_a + int_width_b -1 : 0] mult_out_latent;
    wire [width_b -1 : 0] scanoutb;

    wire addsub_int;
    wire sign_a_int;
    wire sign_b_int;

    wire zero_acc_int;
    wire sign_a_reg_int;
    wire sign_b_reg_int;

    wire addsub_latent;
    wire zeroacc_latent;
    wire signa_latent;
    wire signb_latent;
    wire mult_signed_latent;

    wire [width_upper_data - 1 : 0] sload_upper_data_latent;
    reg [int_width_result - 1 : 0] sload_upper_data_pipe_wire;

    wire [int_width_a -1 :0] mult_a_wire;
    wire [int_width_b -1 :0] mult_b_wire;
    wire [width_upper_data - 1 : 0] sload_upper_data_wire;
    reg [int_width_a -1 : 0] mult_a_tmp;
    reg [int_width_b -1 : 0] mult_b_tmp;

    wire zero_acc_wire;
    wire zero_acc_pipe_wire;

    wire sign_a_wire;
    wire sign_a_pipe_wire;
    wire sign_b_wire;
    wire sign_b_pipe_wire;

    wire addsub_wire;
    wire addsub_pipe_wire;

    wire mult_round_int;
    wire mult_round_wire_clk;
    wire mult_saturation_int;
    wire mult_saturation_wire_clk;

    wire accum_round_tmp1_wire;
    wire accum_round_wire_clk;
    wire accum_round_int;
    wire accum_round_pipe_wire_clk;
    
    wire accum_saturation_tmp1_wire;
    wire accum_saturation_wire_clk;
    wire accum_saturation_int;
    wire accum_saturation_pipe_wire_clk;

    wire accum_sload_upper_data_wire_clk;
    wire accum_sload_upper_data_pipe_wire_clk;
    wire [width_result -1 : width_result - width_upper_data] accum_sload_upper_data_int;
   
    tri0 mult_is_saturated_wire;
    
    wire [31:0] head_result_wire;

    // ------------------------
    // COMPONENT INSTANTIATIONS
    // ------------------------
    ALTERA_DEVICE_FAMILIES dev ();


    // --------------------
    // ASSIGNMENT STATEMENTS
    // --------------------
    
                            
    assign addsub_int = (port_addnsub == "PORT_USED") ? addsub_pipe_wire :
                                (port_addnsub == "PORT_UNUSED") ? ((accum_direction == "ADD") ? 1'b1 : 1'b0) :
                                    ((addnsub ===1'bz) ||
                                    (addsub_wire_clk ===1'bz) ||
                                    (addsub_pipe_wire_clk ===1'bz)) ?
                                        ((accum_direction == "ADD") ? 1'b1 : 1'b0) : addsub_pipe_wire;                    
                              
    assign sign_a_int = (port_signa == "PORT_USED") ? sign_a_pipe_wire :
                                (port_signa == "PORT_UNUSED") ? ((representation_a == "SIGNED") ? 1'b1 : 1'b0) :
                                    ((signa ===1'bz) ||
                                    (sign_a_wire_clk ===1'bz) ||
                                    (sign_pipe_a_wire_clk ===1'bz)) ?
                                        ((representation_a == "SIGNED") ? 1'b1 : 1'b0) : sign_a_pipe_wire;   
           
    assign sign_b_int = (port_signb == "PORT_USED") ? sign_b_pipe_wire :
                                (port_signb == "PORT_UNUSED") ? ((representation_b == "SIGNED") ? 1'b1 : 1'b0) :
                                    ((signb ===1'bz) ||
                                    (sign_b_wire_clk ===1'bz) ||
                                    (sign_pipe_b_wire_clk ===1'bz)) ?
                                        ((representation_b == "SIGNED") ? 1'b1 : 1'b0) : sign_b_pipe_wire;                        
          
                            

    assign sign_a_reg_int = (port_signa == "PORT_USED") ? sign_a_wire :
                                (port_signa == "PORT_UNUSED") ? ((representation_a == "SIGNED") ? 1'b1 : 1'b0) :
                                    ((signa ===1'bz) ||
                                    (sign_a_wire_clk ===1'bz) ||
                                    (sign_pipe_a_wire_clk ===1'bz)) ?
                                        ((representation_a == "SIGNED") ? 1'b1 : 1'b0) : sign_a_wire;

    assign sign_b_reg_int = (port_signb == "PORT_USED") ? sign_b_wire :
                                (port_signb == "PORT_UNUSED") ? ((representation_b == "SIGNED") ? 1'b1 : 1'b0) :
                                    ((signb ===1'bz) ||
                                    (sign_b_wire_clk ===1'bz) ||
                                    (sign_pipe_b_wire_clk ===1'bz)) ?
                                        ((representation_b == "SIGNED") ? 1'b1 : 1'b0) : sign_b_wire;
                                         
    assign zero_acc_int   = ((accum_sload ===1'bz) ||
                            (zero_wire_clk===1'bz) ||
                            (zero_pipe_wire_clk===1'bz)) ?
                                1'b0 : zero_acc_pipe_wire;
                                 
    assign accum_sload_upper_data_int = ((accum_sload_upper_data === {width_upper_data{1'bz}}) ||
                                        (accum_sload_upper_data_wire_clk === 1'bz) ||
                                        (accum_sload_upper_data_pipe_wire_clk === 1'bz)) ?
                                            {width_upper_data{1'b0}} : accum_sload_upper_data;

    assign scanouta       = mult_a_wire[int_width_a - 1 : int_width_a - width_a];
    assign scanoutb       = mult_b_wire[int_width_b - 1 : int_width_b - width_b];
    
    assign {addsub_latent, zeroacc_latent, signa_latent, signb_latent, mult_signed_latent, mult_out_latent, sload_upper_data_latent, mult_is_saturated_latent} = (extra_multiplier_latency > 0) ?
                mult_full : {addsub_wire, zero_acc_wire, sign_a_wire, sign_b_wire, temp_mult_signed, mult_final_out, sload_upper_data_wire, mult_saturate_overflow};

    assign mult_is_saturated = (port_mult_is_saturated != "UNUSED") ? mult_is_saturated_int : 1'b0;
    assign accum_is_saturated = (port_accum_is_saturated != "UNUSED") ? accum_is_saturated_latent : 1'b0;    

    // ---------------------------------------------------------------------------------
    // Initialization block where all the internal signals and registers are initialized
    // ---------------------------------------------------------------------------------
    initial
    begin

        is_stratixv = dev.FEATURE_FAMILY_STRATIXV(intended_device_family);
        is_stratixiii = dev.FEATURE_FAMILY_STRATIXIII(intended_device_family);
        is_stratixii = dev.FEATURE_FAMILY_STRATIXII(intended_device_family);
        is_cycloneii = dev.FEATURE_FAMILY_CYCLONEII(intended_device_family);
        
        // Checking for invalid parameters, in case Wizard is bypassed (hand-modified).
        if ((dedicated_multiplier_circuitry != "AUTO") && 
            (dedicated_multiplier_circuitry != "YES") && 
            (dedicated_multiplier_circuitry != "NO"))
        begin
            $display("Error: The DEDICATED_MULTIPLIER_CIRCUITRY parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end                
        if (width_a <= 0)
        begin
            $display("Error: width_a must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        if (width_b <= 0)
        begin
            $display("Error: width_b must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        if (width_result <= 0)
        begin
            $display("Error: width_result must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if (( (is_stratixii == 0) &&
                (is_cycloneii == 0))
                && (input_source_a != "DATAA"))
        begin
            $display("Error: The input source for port A are limited to input dataa.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if (( (is_stratixii == 0) && 
            (is_cycloneii == 0))
            && (input_source_b != "DATAB"))
        begin
            $display("Error: The input source for port B are limited to input datab.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((is_stratixii == 0) && (multiplier_rounding != "NO"))
        begin
            $display("Error: There is no rounding feature for %s device.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((is_stratixii == 0) && (accumulator_rounding != "NO"))
        begin
            $display("Error: There is no rounding feature for %s device.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((is_stratixii == 0) && (multiplier_saturation != "NO"))
        begin
            $display("Error: There is no saturation feature for %s device.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((is_stratixii == 0) && (accumulator_saturation != "NO"))
        begin
            $display("Error: There is no saturation feature for %s device.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((is_stratixiii) && (port_addnsub != "PORT_UNUSED"))
        begin
            $display ("Error: The addnsub port is not available for %s device.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((is_stratixiii) && (accum_direction != "ADD") &&
            (accum_direction != "SUB"))
        begin
            $display ("Error: Invalid value for ACCUM_DIRECTION parameter for %s device.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((is_stratixiii) && (input_source_a == "VARIABLE"))
        begin
            $display ("Error: Invalid value for INPUT_SOURCE_A parameter for %s device.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        
        temp_sum             = 0;
        head_result          = 0;
        head_mult            = 0;
        overflow_int         = 0;
        mult_a_reg           = 0;
        mult_b_reg           = 0;
        flag                 = 0;

        zero_acc_reg         = 0;
        zero_acc_pipe_reg     = 0;
        sload_upper_data_reg = 0;
        lower_bits           = 0;
        sload_upper_data_pipe_reg = 0;

        sign_a_reg  = (signa ===1'bz)   ? ((representation_a == "SIGNED") ? 1 : 0) : 0;
        sign_a_pipe_reg = (signa ===1'bz)   ? ((representation_a == "SIGNED") ? 1 : 0) : 0;
        sign_b_reg  = (signb ===1'bz)   ? ((representation_b == "SIGNED") ? 1 : 0) : 0;
        sign_b_pipe_reg = (signb ===1'bz)   ? ((representation_b == "SIGNED") ? 1 : 0) : 0;
        addsub_reg  = (addnsub ===1'bz) ? ((accum_direction == "ADD")     ? 1 : 0) : 0;
        addsub_pipe_reg = (addnsub ===1'bz) ? ((accum_direction == "ADD")     ? 1 : 0) : 0;

        result_int      = 0;
        result          = 0;
        overflow        = 0;
        mult_full       = 0;
        mult_res_out    = 0;
        mult_signed_out = 0;
        mult_res        = 0;

        mult_is_saturated_int = 0;
        mult_is_saturated_reg = 0;
        mult_saturation_tmp = 0;
        mult_saturate_overflow = 0;
        
        accum_result = 0;
        accum_saturate_overflow = 0;
        accum_is_saturated_latent = 0;
        
        mult_a_tmp = 0;
        mult_b_tmp = 0;
        mult_final_out = 0;
        temp_mult = 0;
        temp_mult_signed = 0;
        
        for (i=0; i<=extra_accumulator_latency; i=i+1)
        begin
            result_pipe [i] = 0;
            accum_saturate_pipe[i] = 0;
            mult_is_saturated_pipe[i] = 0;
        end

        for (i=0; i<= extra_multiplier_latency; i=i+1)
        begin
            mult_pipe [i] = 0;
        end

    end


    // ---------------------------------------------------------
    // This block updates the internal clock signals accordingly
    // every time the global clock signal changes state
    // ---------------------------------------------------------

    assign input_a_wire_clk =   (input_reg_a == "CLOCK0")? clock0:
                                (input_reg_a == "UNREGISTERED")? 1'b0:
                                (input_reg_a == "CLOCK1")? clock1:
                                (input_reg_a == "CLOCK2")? clock2:
                                (input_reg_a == "CLOCK3")? clock3: 1'b0;

    assign input_b_wire_clk =   (input_reg_b == "CLOCK0")? clock0:
                                (input_reg_b == "UNREGISTERED")? 1'b0:
                                (input_reg_b == "CLOCK1")? clock1:
                                (input_reg_b == "CLOCK2")? clock2:
                                (input_reg_b == "CLOCK3")? clock3: 1'b0;


    assign addsub_wire_clk =    (addnsub_reg == "CLOCK0")? clock0:
                                (addnsub_reg == "UNREGISTERED")? 1'b0:
                                (addnsub_reg == "CLOCK1")? clock1:
                                (addnsub_reg == "CLOCK2")? clock2:
                                (addnsub_reg == "CLOCK3")? clock3: 1'b0;


    assign addsub_pipe_wire_clk =   (addnsub_pipeline_reg == "CLOCK0")? clock0:
                                    (addnsub_pipeline_reg == "UNREGISTERED")? 1'b0:
                                    (addnsub_pipeline_reg == "CLOCK1")? clock1:
                                    (addnsub_pipeline_reg == "CLOCK2")? clock2:
                                    (addnsub_pipeline_reg == "CLOCK3")? clock3: 1'b0;


    assign zero_wire_clk =  (accum_sload_reg == "CLOCK0")? clock0:
                            (accum_sload_reg == "UNREGISTERED")? 1'b0:
                            (accum_sload_reg == "CLOCK1")? clock1:
                            (accum_sload_reg == "CLOCK2")? clock2:
                            (accum_sload_reg == "CLOCK3")? clock3: 1'b0;

    assign accum_sload_upper_data_wire_clk =    (accum_sload_upper_data_reg == "CLOCK0")? clock0:
                                                (accum_sload_upper_data_reg == "UNREGISTERED")? 1'b0:
                                                (accum_sload_upper_data_reg == "CLOCK1")? clock1:
                                                (accum_sload_upper_data_reg == "CLOCK2")? clock2:
                                                (accum_sload_upper_data_reg == "CLOCK3")? clock3: 1'b0;

    assign zero_pipe_wire_clk = (accum_sload_pipeline_reg == "CLOCK0")? clock0:
                                (accum_sload_pipeline_reg == "UNREGISTERED")? 1'b0:
                                (accum_sload_pipeline_reg == "CLOCK1")? clock1:
                                (accum_sload_pipeline_reg == "CLOCK2")? clock2:
                                (accum_sload_pipeline_reg == "CLOCK3")? clock3: 1'b0;

    assign accum_sload_upper_data_pipe_wire_clk =   (accum_sload_upper_data_pipeline_reg == "CLOCK0")? clock0:
                                                    (accum_sload_upper_data_pipeline_reg == "UNREGISTERED")? 1'b0:
                                                    (accum_sload_upper_data_pipeline_reg == "CLOCK1")? clock1:
                                                    (accum_sload_upper_data_pipeline_reg == "CLOCK2")? clock2:
                                                    (accum_sload_upper_data_pipeline_reg == "CLOCK3")? clock3: 1'b0;

    assign sign_a_wire_clk =(sign_reg_a == "CLOCK0")? clock0:
                            (sign_reg_a == "UNREGISTERED")? 1'b0:
                            (sign_reg_a == "CLOCK1")? clock1:
                            (sign_reg_a == "CLOCK2")? clock2:
                            (sign_reg_a == "CLOCK3")? clock3: 1'b0;


    assign sign_b_wire_clk =(sign_reg_b == "CLOCK0")? clock0:
                            (sign_reg_b == "UNREGISTERED")? 1'b0:
                            (sign_reg_b == "CLOCK1")? clock1:
                            (sign_reg_b == "CLOCK2")? clock2:
                            (sign_reg_b == "CLOCK3")? clock3: 1'b0;



    assign sign_pipe_a_wire_clk = (sign_pipeline_reg_a == "CLOCK0")? clock0:
                            (sign_pipeline_reg_a == "UNREGISTERED")? 1'b0:
                            (sign_pipeline_reg_a == "CLOCK1")? clock1:
                            (sign_pipeline_reg_a == "CLOCK2")? clock2:
                            (sign_pipeline_reg_a == "CLOCK3")? clock3: 1'b0;


    assign sign_pipe_b_wire_clk = (sign_pipeline_reg_b == "CLOCK0")? clock0:
                            (sign_pipeline_reg_b == "UNREGISTERED")? 1'b0:
                            (sign_pipeline_reg_b == "CLOCK1")? clock1:
                            (sign_pipeline_reg_b == "CLOCK2")? clock2:
                            (sign_pipeline_reg_b == "CLOCK3")? clock3: 1'b0;


    assign multiplier_wire_clk =(multiplier_reg == "CLOCK0")? clock0:
                                (multiplier_reg == "UNREGISTERED")? 1'b0:
                                (multiplier_reg == "CLOCK1")? clock1:
                                (multiplier_reg == "CLOCK2")? clock2:
                                (multiplier_reg == "CLOCK3")? clock3: 1'b0;

    assign output_wire_clk =    (output_reg == "CLOCK0")? clock0:
                                (output_reg == "UNREGISTERED")? 1'b0:
                                (output_reg == "CLOCK1")? clock1:
                                (output_reg == "CLOCK2")? clock2:
                                (output_reg == "CLOCK3")? clock3: 1'b0;


    assign mult_pipe_wire_clk  =   (multiplier_reg == "UNREGISTERED")? clock0:
                                    multiplier_wire_clk;

    assign mult_round_wire_clk =(mult_round_reg == "CLOCK0")? clock0:
                                (mult_round_reg == "UNREGISTERED")? 1'b0:
                                (mult_round_reg == "CLOCK1")? clock1:
                                (mult_round_reg == "CLOCK2")? clock2:
                                (mult_round_reg == "CLOCK3")? clock3: 1'b0;

    assign mult_saturation_wire_clk = (mult_saturation_reg == "CLOCK0")? clock0:
                            (mult_saturation_reg == "UNREGISTERED")? 1'b0:
                            (mult_saturation_reg == "CLOCK1")? clock1:
                            (mult_saturation_reg == "CLOCK2")? clock2:
                            (mult_saturation_reg == "CLOCK3")? clock3: 1'b0;

    assign accum_round_wire_clk = (accum_round_reg == "CLOCK0")? clock0:
                            (accum_round_reg == "UNREGISTERED")? 1'b0:
                            (accum_round_reg == "CLOCK1")? clock1:
                            (accum_round_reg == "CLOCK2")? clock2:
                            (accum_round_reg == "CLOCK3")? clock3: 1'b0;

    assign accum_round_pipe_wire_clk = (accum_round_pipeline_reg == "CLOCK0")? clock0:
                            (accum_round_pipeline_reg == "UNREGISTERED")? 1'b0:
                            (accum_round_pipeline_reg == "CLOCK1")? clock1:
                            (accum_round_pipeline_reg == "CLOCK2")? clock2:
                            (accum_round_pipeline_reg == "CLOCK3")? clock3: 1'b0;

    assign accum_saturation_wire_clk = (accum_saturation_reg == "CLOCK0")? clock0:
                            (accum_saturation_reg == "UNREGISTERED")? 1'b0:
                            (accum_saturation_reg == "CLOCK1")? clock1:
                            (accum_saturation_reg == "CLOCK2")? clock2:
                            (accum_saturation_reg == "CLOCK3")? clock3: 1'b0;

    assign accum_saturation_pipe_wire_clk = (accum_saturation_pipeline_reg == "CLOCK0")? clock0:
                            (accum_saturation_pipeline_reg == "UNREGISTERED")? 1'b0:
                            (accum_saturation_pipeline_reg == "CLOCK1")? clock1:
                            (accum_saturation_pipeline_reg == "CLOCK2")? clock2:
                            (accum_saturation_pipeline_reg == "CLOCK3")? clock3: 1'b0;

                            
    // ----------------------------------------------------------------
    // This block updates the internal clock enable signals accordingly
    // every time the global clock enable signal changes state
    // ----------------------------------------------------------------



    assign input_a_wire_en =(input_reg_a == "CLOCK0")? ena0:
                            (input_reg_a == "UNREGISTERED")? 1'b1:
                            (input_reg_a == "CLOCK1")? ena1:
                            (input_reg_a == "CLOCK2")? ena2:
                            (input_reg_a == "CLOCK3")? ena3: 1'b1;

    assign input_b_wire_en =(input_reg_b == "CLOCK0")? ena0:
                            (input_reg_b == "UNREGISTERED")? 1'b1:
                            (input_reg_b == "CLOCK1")? ena1:
                            (input_reg_b == "CLOCK2")? ena2:
                            (input_reg_b == "CLOCK3")? ena3: 1'b1;


    assign addsub_wire_en = (addnsub_reg == "CLOCK0")? ena0:
                            (addnsub_reg == "UNREGISTERED")? 1'b1:
                            (addnsub_reg == "CLOCK1")? ena1:
                            (addnsub_reg == "CLOCK2")? ena2:
                            (addnsub_reg == "CLOCK3")? ena3: 1'b1;


    assign addsub_pipe_wire_en =(addnsub_pipeline_reg == "CLOCK0")? ena0:
                                (addnsub_pipeline_reg == "UNREGISTERED")? 1'b1:
                                (addnsub_pipeline_reg == "CLOCK1")? ena1:
                                (addnsub_pipeline_reg == "CLOCK2")? ena2:
                                (addnsub_pipeline_reg == "CLOCK3")? ena3: 1'b1;


    assign zero_wire_en =   (accum_sload_reg == "CLOCK0")? ena0:
                            (accum_sload_reg == "UNREGISTERED")? 1'b1:
                            (accum_sload_reg == "CLOCK1")? ena1:
                            (accum_sload_reg == "CLOCK2")? ena2:
                            (accum_sload_reg == "CLOCK3")? ena3: 1'b1;

    assign accum_sload_upper_data_wire_en =  (accum_sload_upper_data_reg == "CLOCK0")? ena0:
                            (accum_sload_upper_data_reg == "UNREGISTERED")? 1'b1:
                            (accum_sload_upper_data_reg == "CLOCK1")? ena1:
                            (accum_sload_upper_data_reg == "CLOCK2")? ena2:
                            (accum_sload_upper_data_reg == "CLOCK3")? ena3: 1'b1;

    assign zero_pipe_wire_en =  (accum_sload_pipeline_reg == "CLOCK0")? ena0:
                                (accum_sload_pipeline_reg == "UNREGISTERED")? 1'b1:
                                (accum_sload_pipeline_reg == "CLOCK1")? ena1:
                                (accum_sload_pipeline_reg == "CLOCK2")? ena2:
                                (accum_sload_pipeline_reg == "CLOCK3")? ena3: 1'b1;

    assign accum_sload_upper_data_pipe_wire_en =  (accum_sload_upper_data_pipeline_reg == "CLOCK0")? ena0:
                                (accum_sload_upper_data_pipeline_reg == "UNREGISTERED")? 1'b1:
                                (accum_sload_upper_data_pipeline_reg == "CLOCK1")? ena1:
                                (accum_sload_upper_data_pipeline_reg == "CLOCK2")? ena2:
                                (accum_sload_upper_data_pipeline_reg == "CLOCK3")? ena3: 1'b1;

    assign sign_a_wire_en = (sign_reg_a == "CLOCK0")? ena0:
                            (sign_reg_a == "UNREGISTERED")? 1'b1:
                            (sign_reg_a == "CLOCK1")? ena1:
                            (sign_reg_a == "CLOCK2")? ena2:
                            (sign_reg_a == "CLOCK3")? ena3: 1'b1;


    assign sign_b_wire_en = (sign_reg_b == "CLOCK0")? ena0:
                            (sign_reg_b == "UNREGISTERED")? 1'b1:
                            (sign_reg_b == "CLOCK1")? ena1:
                            (sign_reg_b == "CLOCK2")? ena2:
                            (sign_reg_b == "CLOCK3")? ena3: 1'b1;



    assign sign_pipe_a_wire_en = (sign_pipeline_reg_a == "CLOCK0")? ena0:
                            (sign_pipeline_reg_a == "UNREGISTERED")? 1'b1:
                            (sign_pipeline_reg_a == "CLOCK1")? ena1:
                            (sign_pipeline_reg_a == "CLOCK2")? ena2:
                            (sign_pipeline_reg_a == "CLOCK3")? ena3: 1'b1;


    assign sign_pipe_b_wire_en = (sign_pipeline_reg_b == "CLOCK0")? ena0:
                            (sign_pipeline_reg_b == "UNREGISTERED")? 1'b1:
                            (sign_pipeline_reg_b == "CLOCK1")? ena1:
                            (sign_pipeline_reg_b == "CLOCK2")? ena2:
                            (sign_pipeline_reg_b == "CLOCK3")? ena3: 1'b1;


    assign multiplier_wire_en = (multiplier_reg == "CLOCK0")? ena0:
                            (multiplier_reg == "UNREGISTERED")? 1'b1:
                            (multiplier_reg == "CLOCK1")? ena1:
                            (multiplier_reg == "CLOCK2")? ena2:
                            (multiplier_reg == "CLOCK3")? ena3: 1'b1;

    assign output_wire_en = (output_reg == "CLOCK0")? ena0:
                            (output_reg == "UNREGISTERED")? 1'b1:
                            (output_reg == "CLOCK1")? ena1:
                            (output_reg == "CLOCK2")? ena2:
                            (output_reg == "CLOCK3")? ena3: 1'b1;


    assign mult_pipe_wire_en  = (multiplier_reg == "UNREGISTERED")? ena0:
                                multiplier_wire_en;


    assign mult_round_wire_en = (mult_round_reg == "CLOCK0")? ena0:
                            (mult_round_reg == "UNREGISTERED")? 1'b1:
                            (mult_round_reg == "CLOCK1")? ena1:
                            (mult_round_reg == "CLOCK2")? ena2:
                            (mult_round_reg == "CLOCK3")? ena3: 1'b1;


    assign mult_saturation_wire_en = (mult_saturation_reg == "CLOCK0")? ena0:
                            (mult_saturation_reg == "UNREGISTERED")? 1'b1:
                            (mult_saturation_reg == "CLOCK1")? ena1:
                            (mult_saturation_reg == "CLOCK2")? ena2:
                            (mult_saturation_reg == "CLOCK3")? ena3: 1'b1;

    assign accum_round_wire_en = (accum_round_reg == "CLOCK0")? ena0:
                            (accum_round_reg == "UNREGISTERED")? 1'b1:
                            (accum_round_reg == "CLOCK1")? ena1:
                            (accum_round_reg == "CLOCK2")? ena2:
                            (accum_round_reg == "CLOCK3")? ena3: 1'b1;
                            
    assign accum_round_pipe_wire_en = (accum_round_pipeline_reg == "CLOCK0")? ena0:
                            (accum_round_pipeline_reg == "UNREGISTERED")? 1'b1:
                            (accum_round_pipeline_reg == "CLOCK1")? ena1:
                            (accum_round_pipeline_reg == "CLOCK2")? ena2:
                            (accum_round_pipeline_reg == "CLOCK3")? ena3: 1'b1;

    assign accum_saturation_wire_en = (accum_saturation_reg == "CLOCK0")? ena0:
                            (accum_saturation_reg == "UNREGISTERED")? 1'b1:
                            (accum_saturation_reg == "CLOCK1")? ena1:
                            (accum_saturation_reg == "CLOCK2")? ena2:
                            (accum_saturation_reg == "CLOCK3")? ena3: 1'b1;
                            
    assign accum_saturation_pipe_wire_en = (accum_saturation_pipeline_reg == "CLOCK0")? ena0:
                            (accum_saturation_pipeline_reg == "UNREGISTERED")? 1'b1:
                            (accum_saturation_pipeline_reg == "CLOCK1")? ena1:
                            (accum_saturation_pipeline_reg == "CLOCK2")? ena2:
                            (accum_saturation_pipeline_reg == "CLOCK3")? ena3: 1'b1;
                            
    // ---------------------------------------------------------
    // This block updates the internal clear signals accordingly
    // every time the global clear signal changes state
    // ---------------------------------------------------------

    assign input_a_wire_clr =(input_aclr_a == "ACLR3")? aclr3:
                            (input_aclr_a == "UNUSED")? 1'b0:
                            (input_aclr_a == "ACLR0")? aclr0:
                            (input_aclr_a == "ACLR1")? aclr1:
                            (input_aclr_a == "ACLR2")? aclr2: 1'b0;
                             
    assign input_b_wire_clr = (input_aclr_b == "ACLR3")? aclr3:
                            (input_aclr_b == "UNUSED")? 1'b0:
                            (input_aclr_b == "ACLR0")? aclr0:
                            (input_aclr_b == "ACLR1")? aclr1:
                            (input_aclr_b == "ACLR2")? aclr2: 1'b0;
                             

    assign addsub_wire_clr =(addnsub_aclr == "ACLR3")? aclr3:
                            (addnsub_aclr == "UNUSED")? 1'b0:
                            (addnsub_aclr == "ACLR0")? aclr0:
                            (addnsub_aclr == "ACLR1")? aclr1:
                            (addnsub_aclr == "ACLR2")? aclr2: 1'b0;
                              

    assign addsub_pipe_wire_clr =   (addnsub_pipeline_aclr == "ACLR3")? aclr3:
                                    (addnsub_pipeline_aclr == "UNUSED")? 1'b0:
                                    (addnsub_pipeline_aclr == "ACLR0")? aclr0:
                                    (addnsub_pipeline_aclr == "ACLR1")? aclr1:
                                    (addnsub_pipeline_aclr == "ACLR2")? aclr2: 1'b0;
                                   

    assign zero_wire_clr =  (accum_sload_aclr == "ACLR3")? aclr3:
                            (accum_sload_aclr == "UNUSED")? 1'b0:
                            (accum_sload_aclr == "ACLR0")? aclr0:
                            (accum_sload_aclr == "ACLR1")? aclr1:
                            (accum_sload_aclr == "ACLR2")? aclr2: 1'b0;
                           
    assign accum_sload_upper_data_wire_clr =  (accum_sload_upper_data_aclr == "ACLR3")? aclr3:
                            (accum_sload_upper_data_aclr == "UNUSED")? 1'b0:
                            (accum_sload_upper_data_aclr == "ACLR0")? aclr0:
                            (accum_sload_upper_data_aclr == "ACLR1")? aclr1:
                            (accum_sload_upper_data_aclr == "ACLR2")? aclr2: 1'b0;
                           
    assign zero_pipe_wire_clr =  (accum_sload_pipeline_aclr == "ACLR3")? aclr3:
                            (accum_sload_pipeline_aclr == "UNUSED")? 1'b0:
                            (accum_sload_pipeline_aclr == "ACLR0")? aclr0:
                            (accum_sload_pipeline_aclr == "ACLR1")? aclr1:
                            (accum_sload_pipeline_aclr == "ACLR2")? aclr2: 1'b0;
                                
    assign accum_sload_upper_data_pipe_wire_clr =  (accum_sload_upper_data_pipeline_aclr == "ACLR3")? aclr3:
                            (accum_sload_upper_data_pipeline_aclr == "UNUSED")? 1'b0:
                            (accum_sload_upper_data_pipeline_aclr == "ACLR0")? aclr0:
                            (accum_sload_upper_data_pipeline_aclr == "ACLR1")? aclr1:
                            (accum_sload_upper_data_pipeline_aclr == "ACLR2")? aclr2: 1'b0;
                                
    assign sign_a_wire_clr =(sign_aclr_a == "ACLR3")? aclr3:
                            (sign_aclr_a == "UNUSED")? 1'b0:
                            (sign_aclr_a == "ACLR0")? aclr0:
                            (sign_aclr_a == "ACLR1")? aclr1:
                            (sign_aclr_a == "ACLR2")? aclr2: 1'b0;
                        

    assign sign_b_wire_clr =    (sign_aclr_b == "ACLR3")? aclr3:
                                (sign_aclr_b == "UNUSED")? 1'b0:
                                (sign_aclr_b == "ACLR0")? aclr0:
                                (sign_aclr_b == "ACLR1")? aclr1:
                                (sign_aclr_b == "ACLR2")? aclr2: 1'b0;
                            



    assign sign_pipe_a_wire_clr = (sign_pipeline_aclr_a == "ACLR3")? aclr3:
                            (sign_pipeline_aclr_a == "UNUSED")? 1'b0:
                            (sign_pipeline_aclr_a == "ACLR0")? aclr0:
                            (sign_pipeline_aclr_a == "ACLR1")? aclr1:
                            (sign_pipeline_aclr_a == "ACLR2")? aclr2: 1'b0;
                            

    assign sign_pipe_b_wire_clr = (sign_pipeline_aclr_b == "ACLR3")? aclr3:
                            (sign_pipeline_aclr_b == "UNUSED")? 1'b0:
                            (sign_pipeline_aclr_b == "ACLR0")? aclr0:
                            (sign_pipeline_aclr_b == "ACLR1")? aclr1:
                            (sign_pipeline_aclr_b == "ACLR2")? aclr2: 1'b0;
                            

    assign multiplier_wire_clr = (multiplier_aclr == "ACLR3")? aclr3:
                            (multiplier_aclr == "UNUSED")? 1'b0:
                            (multiplier_aclr == "ACLR0")? aclr0:
                            (multiplier_aclr == "ACLR1")? aclr1:
                            (multiplier_aclr == "ACLR2")? aclr2: 1'b0;
                             
    assign output_wire_clr =(output_aclr == "ACLR3")? aclr3:
                            (output_aclr == "UNUSED")? 1'b0:
                            (output_aclr == "ACLR0")? aclr0:
                            (output_aclr == "ACLR1")? aclr1:
                            (output_aclr == "ACLR2")? aclr2: 1'b0;
                            
                            
    assign mult_pipe_wire_clr  = (multiplier_reg == "UNREGISTERED")? aclr0:
                            multiplier_wire_clr;

    assign mult_round_wire_clr = (mult_round_aclr == "ACLR3")? aclr3:
                            (mult_round_aclr == "UNUSED")? 1'b0:
                            (mult_round_aclr == "ACLR0")? aclr0:
                            (mult_round_aclr == "ACLR1")? aclr1:
                            (mult_round_aclr == "ACLR2")? aclr2: 1'b0;
                            
    assign mult_saturation_wire_clr = (mult_saturation_aclr == "ACLR3")? aclr3:
                            (mult_saturation_aclr == "UNUSED")? 1'b0:
                            (mult_saturation_aclr == "ACLR0")? aclr0:
                            (mult_saturation_aclr == "ACLR1")? aclr1:
                            (mult_saturation_aclr == "ACLR2")? aclr2: 1'b0;
                            
    assign accum_round_wire_clr = (accum_round_aclr == "ACLR3")? aclr3:
                            (accum_round_aclr == "UNUSED")? 1'b0:
                            (accum_round_aclr == "ACLR0")? aclr0:
                            (accum_round_aclr == "ACLR1")? aclr1:
                            (accum_round_aclr == "ACLR2")? aclr2: 1'b0;
                             
    assign accum_round_pipe_wire_clr = (accum_round_pipeline_aclr == "ACLR3")? aclr3:
                            (accum_round_pipeline_aclr == "UNUSED")? 1'b0:
                            (accum_round_pipeline_aclr == "ACLR0")? aclr0:
                            (accum_round_pipeline_aclr == "ACLR1")? aclr1:
                            (accum_round_pipeline_aclr == "ACLR2")? aclr2: 1'b0;
                            
    assign accum_saturation_wire_clr = (accum_saturation_aclr == "ACLR3")? aclr3:
                            (accum_saturation_aclr == "UNUSED")? 1'b0:
                            (accum_saturation_aclr == "ACLR0")? aclr0:
                            (accum_saturation_aclr == "ACLR1")? aclr1:
                            (accum_saturation_aclr == "ACLR2")? aclr2: 1'b0;
                            
    assign accum_saturation_pipe_wire_clr = (accum_saturation_pipeline_aclr == "ACLR3")? aclr3:
                            (accum_saturation_pipeline_aclr == "UNUSED")? 1'b0:
                            (accum_saturation_pipeline_aclr == "ACLR0")? aclr0:
                            (accum_saturation_pipeline_aclr == "ACLR1")? aclr1:
                            (accum_saturation_pipeline_aclr == "ACLR2")? aclr2: 1'b0;
                              
    // ------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_a)
    // Signal Registered : dataa
    //
    // Register is controlled by posedge input_wire_a_clk
    // Register has an asynchronous clear signal, input_reg_a_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_reg_a is unregistered and dataa changes value
    // ------------------------------------------------------------------------
    assign mult_a_wire = (input_reg_a == "UNREGISTERED")? mult_a_tmp : mult_a_reg;

    always @ (dataa or sourcea or scanina)
    begin
        if (int_width_a == width_a)
        begin
            if (input_source_a == "DATAA")
                mult_a_tmp = dataa;
            else if ((input_source_a == "SCANA") || (sourcea == 1))
                mult_a_tmp = scanina;
            else
                mult_a_tmp = dataa;
        end
        else
        begin
            if (input_source_a == "DATAA")
                mult_a_tmp = {dataa, {(diff_width_a){1'b0}}};
            else if ((input_source_a == "SCANA") || (sourcea == 1)) 
                mult_a_tmp = {scanina, {(diff_width_a){1'b0}}};
            else
                mult_a_tmp = {dataa, {(diff_width_a){1'b0}}};
        end
    end

    always @(posedge input_a_wire_clk or posedge input_a_wire_clr)
    begin
        if (input_a_wire_clr == 1)
            mult_a_reg <= 0;
        else if ((input_a_wire_clk == 1) && (input_a_wire_en == 1))
        begin
            if (input_source_a == "DATAA")
                mult_a_reg <= (int_width_a == width_a) ? dataa : {dataa, {(diff_width_a){1'b0}}};
            else if (input_source_a == "SCANA")
                mult_a_reg <= (int_width_a == width_a) ? scanina : {scanina,{(diff_width_a){1'b0}}};
            else if  (input_source_a == "VARIABLE")
            begin
                if (sourcea == 1)
                    mult_a_reg <= (int_width_a == width_a) ? scanina : {scanina, {(diff_width_a){1'b0}}};
                else
                    mult_a_reg <= (int_width_a == width_a) ? dataa : {dataa, {(diff_width_a){1'b0}}};
                end
        end
    end


    // ------------------------------------------------------------------------                                                                                                                                    
    // This block contains 1 register and 1 combinatorial block (to set mult_b)
    // Signal Registered : datab
    //
    // Register is controlled by posedge input_wire_b_clk
    // Register has an asynchronous clear signal, input_reg_b_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_reg_b is unregistered and datab changes value
    // ------------------------------------------------------------------------
    assign mult_b_wire = (input_reg_b == "UNREGISTERED")? mult_b_tmp : mult_b_reg;
    
    always @ (datab or sourceb or scaninb)
    begin
        if (int_width_b == width_b)
        begin
            if (input_source_b == "DATAB")
                mult_b_tmp = datab;
            else if ((input_source_b == "SCANB") || (sourceb == 1)) 
                mult_b_tmp = scaninb;
            else
                mult_b_tmp = datab;
        end
        else
        begin
            if (input_source_b == "DATAB")
                mult_b_tmp = {datab, {(diff_width_b){1'b0}}};
        else if ((input_source_b == "SCANB") || (sourceb == 1)) 
                mult_b_tmp = {scaninb, {(diff_width_b){1'b0}}};
            else
                mult_b_tmp = {datab, {(diff_width_b){1'b0}}};
        end
    end

    always @(posedge input_b_wire_clk or posedge input_b_wire_clr )
    begin
        if (input_b_wire_clr == 1)
            mult_b_reg <= 0;
        else if ((input_b_wire_clk == 1) && (input_b_wire_en == 1))
        begin
            if (input_source_b == "DATAB")
                mult_b_reg <= (int_width_b == width_b) ? datab : {datab, {(diff_width_b){1'b0}}};
            else if (input_source_b == "SCANB")
                mult_b_reg <= (int_width_b == width_b) ? scaninb : {scaninb, {(diff_width_b){1'b0}}};
            else if  (input_source_b == "VARIABLE")
            begin
                if (sourceb == 1)
                    mult_b_reg <= (int_width_b == width_b) ? scaninb : {scaninb, {(diff_width_b){1'b0}}};
                else
                    mult_b_reg <= (int_width_b == width_b) ? datab : {datab, {(diff_width_b){1'b0}}};
            end
        end
    end


    // -----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addnsub_reg)
    // Signal Registered : addnsub
    //
    // Register is controlled by posedge addsub_wire_clk
    // Register has an asynchronous clear signal, addsub_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub_reg is unregistered and addnsub changes value
    // -----------------------------------------------------------------------------
    assign addsub_wire = ((addnsub_reg == "UNREGISTERED") )? addnsub : addsub_reg;

    always @(posedge addsub_wire_clk or posedge addsub_wire_clr)
    begin
        if (addsub_wire_clr == 1)
            addsub_reg <= 0;
        else if ((addsub_wire_clk == 1) && (addsub_wire_en == 1))
            addsub_reg <= addnsub;
    end


    // -----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addsub_pipe)
    // Signal Registered : addsub_latent
    //
    // Register is controlled by posedge addsub_pipe_wire_clk
    // Register has an asynchronous clear signal, addsub_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addsub_pipeline_reg is unregistered and addsub_latent changes value
    // -----------------------------------------------------------------------------
    assign addsub_pipe_wire = (addnsub_pipeline_reg == "UNREGISTERED")?addsub_latent : addsub_pipe_reg;

    always @(posedge addsub_pipe_wire_clk or posedge addsub_pipe_wire_clr )
    begin
        if (addsub_pipe_wire_clr == 1)
            addsub_pipe_reg <= 0;
        else if ((addsub_pipe_wire_clk == 1) && (addsub_pipe_wire_en == 1))
            addsub_pipe_reg <= addsub_latent;

    end


    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set zero_acc_reg)
    // Signal Registered : accum_sload
    //
    // Register is controlled by posedge zero_wire_clk
    // Register has an asynchronous clear signal, zero_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_sload_reg is unregistered and accum_sload changes value
    // ------------------------------------------------------------------------------
    assign zero_acc_wire = (accum_sload_reg == "UNREGISTERED")?accum_sload : zero_acc_reg;

    always @(posedge zero_wire_clk or posedge zero_wire_clr)
    begin
        if (zero_wire_clr == 1)
        begin
            zero_acc_reg <= 0;
        end
        else if ((zero_wire_clk == 1) && (zero_wire_en == 1))
        begin
            zero_acc_reg <=  accum_sload;
        end
    end

    assign sload_upper_data_wire = (accum_sload_upper_data_reg == "UNREGISTERED")? accum_sload_upper_data_int : sload_upper_data_reg;

                                
    always @(posedge accum_sload_upper_data_wire_clk or posedge accum_sload_upper_data_wire_clr)
    begin
        if (accum_sload_upper_data_wire_clr == 1)
        begin
            sload_upper_data_reg <= 0;
        end
        else if ((accum_sload_upper_data_wire_clk == 1) && (accum_sload_upper_data_wire_en == 1))
        begin
            sload_upper_data_reg <= accum_sload_upper_data_int;
        end
    end

    // --------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set zero_acc_pipe)
    // Signal Registered : zeroacc_latent
    //
    // Register is controlled by posedge zero_pipe_wire_clk
    // Register has an asynchronous clear signal, zero_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_sload_pipeline_reg is unregistered and zeroacc_latent changes value
    // --------------------------------------------------------------------------------
    assign zero_acc_pipe_wire = (accum_sload_pipeline_reg == "UNREGISTERED")?zeroacc_latent : zero_acc_pipe_reg;

    always @(posedge zero_pipe_wire_clk or posedge zero_pipe_wire_clr)
    begin
        if (zero_pipe_wire_clr == 1)
        begin
            zero_acc_pipe_reg <= 0;
        end
        else if ((zero_pipe_wire_clk == 1) && (zero_pipe_wire_en == 1))
        begin
            zero_acc_pipe_reg <= zeroacc_latent;
        end

    end

                                
    always @(posedge accum_sload_upper_data_pipe_wire_clk or posedge accum_sload_upper_data_pipe_wire_clr)
    begin
        if (accum_sload_upper_data_pipe_wire_clr == 1)
        begin
            sload_upper_data_pipe_reg <= 0;
        end
        else if ((accum_sload_upper_data_pipe_wire_clk == 1) && (accum_sload_upper_data_pipe_wire_en == 1))
        begin
            sload_upper_data_pipe_reg <= sload_upper_data_latent;
        end

    end

    always @(sload_upper_data_latent or sload_upper_data_pipe_reg or sign_a_int or sign_b_int )
    begin
        if (accum_sload_upper_data_pipeline_reg == "UNREGISTERED")
        begin
            if(int_width_result > width_result)
            begin
                
                if(sign_a_int | sign_b_int)
                begin
                    sload_upper_data_pipe_wire[int_width_result - 1 : 0] = {int_width_result{sload_upper_data_latent[width_upper_data-1]}};
                end
                else
                begin
                    sload_upper_data_pipe_wire[int_width_result - 1 : 0] = {int_width_result{1'b0}};
                end

                if(width_result > width_upper_data)
                begin
                    for(i4 = 0; i4 < width_result - width_upper_data + int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width : width_result - width_upper_data + int_extra_width] = sload_upper_data_latent;
                end
                else if(width_result == width_upper_data)
                begin
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width: 0 + int_extra_width] = sload_upper_data_latent;
                end
                else
                begin
                    for(i4 = int_extra_width; i4 < sload_for_limit; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = sload_upper_data_latent[i4];
                    end                    
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                end
            end
            else
            begin
                if(width_result > width_upper_data)
                begin
                    for(i4 = 0; i4 < width_result - width_upper_data + int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width : width_result - width_upper_data + int_extra_width] = sload_upper_data_latent;
                end
                else if(width_result == width_upper_data)
                begin
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width : 0 + int_extra_width] = sload_upper_data_latent;
                end
                else
                begin
                    for(i4 = int_extra_width; i4 < sload_for_limit; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = sload_upper_data_latent[i4];
                    end
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end                    
                end
            end
        end
        else
        begin
            if(int_width_result > width_result)
            begin

                if(sign_a_int | sign_b_int)
                begin
                    sload_upper_data_pipe_wire[int_width_result - 1 : 0] = {int_width_result{sload_upper_data_pipe_reg[width_upper_data-1]}};
                end
                else
                begin
                    sload_upper_data_pipe_wire[int_width_result - 1 : 0] = {int_width_result{1'b0}};
                end

                if(width_result > width_upper_data)
                begin
                    for(i4 = 0; i4 < width_result - width_upper_data + int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width : width_result - width_upper_data + int_extra_width] = sload_upper_data_pipe_reg;
                end
                else if(width_result == width_upper_data)
                begin
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width: 0 + int_extra_width] = sload_upper_data_pipe_reg;
                end
                else
                begin
                    for(i4 = int_extra_width; i4 < sload_for_limit; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = sload_upper_data_pipe_reg[i4];
                    end                    
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                end
            end
            else
            begin
                if(width_result > width_upper_data)
                begin
                    for(i4 = 0; i4 < width_result - width_upper_data + int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width : width_result - width_upper_data + int_extra_width] = sload_upper_data_pipe_reg;
                end
                else if(width_result == width_upper_data)
                begin
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width : 0 + int_extra_width] = sload_upper_data_pipe_reg;
                end
                else
                begin
                    for(i4 = int_extra_width; i4 < sload_for_limit; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = sload_upper_data_pipe_reg[i4];
                    end
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end                    
                end
            end
        end
    end
    
    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_a_reg)
    // Signal Registered : signa
    //
    // Register is controlled by posedge sign_a_wire_clk
    // Register has an asynchronous clear signal, sign_a_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        sign_reg_a is unregistered and signa changes value
    // ----------------------------------------------------------------------------
    assign  sign_a_wire = (sign_reg_a == "UNREGISTERED")? signa : sign_a_reg;

    always @(posedge sign_a_wire_clk or posedge sign_a_wire_clr)
    begin
        if (sign_a_wire_clr == 1)
            sign_a_reg <= 0;
        else if ((sign_a_wire_clk == 1) && (sign_a_wire_en == 1))
            sign_a_reg <= signa;
    end


    // -----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_a_pipe)
    // Signal Registered : signa_latent
    //
    // Register is controlled by posedge sign_pipe_a_wire_clk
    // Register has an asynchronous clear signal, sign_pipe_a_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        sign_pipeline_reg_a is unregistered and signa_latent changes value
    // -----------------------------------------------------------------------------
    assign  sign_a_pipe_wire = (sign_pipeline_reg_a == "UNREGISTERED")? signa_latent : sign_a_pipe_reg;

    always @(posedge sign_pipe_a_wire_clk or posedge sign_pipe_a_wire_clr)
    begin
        if (sign_pipe_a_wire_clr == 1)
            sign_a_pipe_reg <= 0;
        else if ((sign_pipe_a_wire_clk == 1) && (sign_pipe_a_wire_en == 1))
            sign_a_pipe_reg <= signa_latent;
    end


    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_b_reg)
    // Signal Registered : signb
    //
    // Register is controlled by posedge sign_b_wire_clk
    // Register has an asynchronous clear signal, sign_b_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        sign_reg_b is unregistered and signb changes value
    // ----------------------------------------------------------------------------
    assign  sign_b_wire = (sign_reg_b == "UNREGISTERED") ? signb : sign_b_reg;

    always @(posedge sign_b_wire_clk or posedge sign_b_wire_clr)
    begin
            if (sign_b_wire_clr == 1)
                sign_b_reg <= 0;
            else if ((sign_b_wire_clk == 1) && (sign_b_wire_en == 1))
                sign_b_reg <= signb;
    end


    // -----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_b_pipe)
    // Signal Registered : signb_latent
    //
    // Register is controlled by posedge sign_pipe_b_wire_clk
    // Register has an asynchronous clear signal, sign_pipe_b_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        sign_pipeline_reg_b is unregistered and signb_latent changes value
    // -----------------------------------------------------------------------------
    assign sign_b_pipe_wire = (sign_pipeline_reg_b == "UNREGISTERED" )? signb_latent : sign_b_pipe_reg;

    always @(posedge sign_pipe_b_wire_clk or posedge sign_pipe_b_wire_clr )
    begin
        if (sign_pipe_b_wire_clr == 1)
            sign_b_pipe_reg <= 0;
        else if ((sign_pipe_b_wire_clk == 1) && (sign_pipe_b_wire_en == 1))
            sign_b_pipe_reg <=  signb_latent;

    end

    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_round)
    // Signal Registered : mult_round
    //
    // Register is controlled by posedge mult_round_wire_clk
    // Register has an asynchronous clear signal, mult_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        mult_round_reg is unregistered and mult_round changes value
    // ----------------------------------------------------------------------------
    
    assign mult_round_int = (mult_round_reg == "UNREGISTERED")? mult_round : mult_round_tmp;

    always @(posedge mult_round_wire_clk or posedge mult_round_wire_clr)
    begin
        if (mult_round_wire_clr == 1)
            mult_round_tmp <= 0;
        else if ((mult_round_wire_clk == 1) && (mult_round_wire_en == 1))
            mult_round_tmp <= mult_round;
    end

    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_saturation)
    // Signal Registered : mult_saturation
    //
    // Register is controlled by posedge mult_saturation_wire_clk
    // Register has an asynchronous clear signal, mult_saturation_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        mult_saturation_reg is unregistered and mult_saturation changes value
    // ----------------------------------------------------------------------------
    
    assign mult_saturation_int = (mult_saturation_reg == "UNREGISTERED")? mult_saturation : mult_saturation_tmp;

    always @(posedge mult_saturation_wire_clk or posedge mult_saturation_wire_clr)
    begin
        if (mult_saturation_wire_clr == 1)
            mult_saturation_tmp <= 0;
        else if ((mult_saturation_wire_clk == 1) && (mult_saturation_wire_en == 1))
            mult_saturation_tmp <= mult_saturation;
    end
    
    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set accum_round)
    // Signal Registered : accum_round
    //
    // Register is controlled by posedge accum_round_wire_clk
    // Register has an asynchronous clear signal, accum_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_round_reg is unregistered and accum_round changes value
    // ----------------------------------------------------------------------------
    
    assign accum_round_tmp1_wire = (accum_round_reg == "UNREGISTERED")? ((is_stratixiii == 1) ? accum_sload : accum_round) : accum_round_tmp1;

    always @(posedge accum_round_wire_clk or posedge accum_round_wire_clr)
    begin
        if (accum_round_wire_clr == 1)
            accum_round_tmp1 <= 0;
        else if ((accum_round_wire_clk == 1) && (accum_round_wire_en == 1))
        begin
            if (is_stratixiii == 1)
                accum_round_tmp1 <= accum_sload;
            else
                accum_round_tmp1 <= accum_round;
        end
    end

    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set accum_round_tmp1)
    // Signal Registered : accum_round_tmp1
    //
    // Register is controlled by posedge accum_round_pipe_wire_clk
    // Register has an asynchronous clear signal, accum_round_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_round_pipeline_reg is unregistered and accum_round_tmp1_wire changes value
    // ----------------------------------------------------------------------------
    
    assign accum_round_int = (accum_round_pipeline_reg == "UNREGISTERED")? accum_round_tmp1_wire : accum_round_tmp2;

    always @(posedge accum_round_pipe_wire_clk or posedge accum_round_pipe_wire_clr)
    begin
        if (accum_round_pipe_wire_clr == 1)
            accum_round_tmp2 <= 0;
        else if ((accum_round_pipe_wire_clk == 1) && (accum_round_pipe_wire_en == 1))
            accum_round_tmp2 <= accum_round_tmp1_wire;
    end
    

    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set accum_saturation)
    // Signal Registered : accum_saturation
    //
    // Register is controlled by posedge accum_saturation_wire_clk
    // Register has an asynchronous clear signal, accum_saturation_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_saturation_reg is unregistered and accum_saturation changes value
    // ----------------------------------------------------------------------------
    
    assign accum_saturation_tmp1_wire = (accum_saturation_reg == "UNREGISTERED")? accum_saturation : accum_saturation_tmp1;

    always @(posedge accum_saturation_wire_clk or posedge accum_saturation_wire_clr)
    begin
        if (accum_saturation_wire_clr == 1)
            accum_saturation_tmp1 <= 0;
        else if ((accum_saturation_wire_clk == 1) && (accum_saturation_wire_en == 1))
            accum_saturation_tmp1 <= accum_saturation;
    end

    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set accum_saturation_tmp1)
    // Signal Registered : accum_saturation_tmp1
    //
    // Register is controlled by posedge accum_saturation_pipe_wire_clk
    // Register has an asynchronous clear signal, accum_saturation_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_saturation_pipeline_reg is unregistered and accum_saturation_tmp1_wire changes value
    // ----------------------------------------------------------------------------
    
    assign accum_saturation_int = (accum_saturation_pipeline_reg == "UNREGISTERED")? accum_saturation_tmp1_wire : accum_saturation_tmp2;

    always @(posedge accum_saturation_pipe_wire_clk or posedge accum_saturation_pipe_wire_clr)
    begin
        if (accum_saturation_pipe_wire_clr == 1)
            accum_saturation_tmp2 <= 0;
        else if ((accum_saturation_pipe_wire_clk == 1) && (accum_saturation_pipe_wire_en == 1))
            accum_saturation_tmp2 <= accum_saturation_tmp1_wire;
    end
    
        
    // ------------------------------------------------------------------------------------------------------
    // This block checks if the two numbers to be multiplied (mult_a/mult_b) is to be interpreted
    // as a negative number or not. If so, then two's complement is performed.
    // The numbers are then multipled
    // The sign of the result (positive or negative) is determined based on the sign of the two input numbers
    // ------------------------------------------------------------------------------------------------------

    always @(mult_a_wire or mult_b_wire or sign_a_reg_int or sign_b_reg_int or temp_mult_zero)
    begin
        neg_a = mult_a_wire [int_width_a-1] & (sign_a_reg_int);
        neg_b = mult_b_wire [int_width_b-1] & (sign_b_reg_int);

        mult_a_int = (neg_a == 1) ? ~mult_a_wire + 1 : mult_a_wire;
        mult_b_int = (neg_b == 1) ? ~mult_b_wire + 1 : mult_b_wire;

        temp_mult_1        = mult_a_int * mult_b_int;
        temp_mult_signed = sign_a_reg_int | sign_b_reg_int;
        temp_mult        = (neg_a ^ neg_b) ? (temp_mult_zero - temp_mult_1) : temp_mult_1;

    end
     
    always @(temp_mult or mult_saturation_int or mult_round_int)
    begin

        if (is_stratixii == 1)
        begin
            // StratixII rounding support
        
            // This is based on both input is in Q1.15 format

            if ((multiplier_rounding == "YES") ||
                ((multiplier_rounding == "VARIABLE") && (mult_round_int == 1)))
            begin
                mult_round_out = temp_mult + ( 1 << (bits_to_round));

            end
            else
            begin
                mult_round_out = temp_mult;
            end

            // StratixII saturation support

            if ((multiplier_saturation == "YES") || 
                (( multiplier_saturation == "VARIABLE") && (mult_saturation_int == 1)))
            begin
                mult_saturate_overflow = (mult_round_out[int_width_a + int_width_b - 1] == 0 && mult_round_out[int_width_a + int_width_b - 2] == 1);
                if (mult_saturate_overflow == 0)
                begin
                    mult_saturate_out = mult_round_out;
                end
                else
                begin
                    for (i = (int_width_a + int_width_b - 1); i >= (int_width_a + int_width_b - 2); i = i - 1)
                    begin
                        mult_saturate_out[i] = mult_round_out[int_width_a + int_width_b - 1];
                    end

                    for (i = (int_width_a + int_width_b - 3); i >= 0; i = i - 1)
                    begin
                        mult_saturate_out[i] = ~mult_round_out[int_width_a + int_width_b - 1];
                    end

                    for (i= sat_for_ini; i >=0; i = i - 1)
                    begin
                        mult_saturate_out[i] = 1'b0;
                    end

                end
            end
            else
            begin
                mult_saturate_out = mult_round_out;
                mult_saturate_overflow = 0;
            end
        
            if ((multiplier_rounding == "YES") ||
                ((multiplier_rounding == "VARIABLE") && (mult_round_int == 1)))
            begin
                    mult_result = mult_saturate_out;
                    
                    for (i = mult_round_for_ini; i >= 0; i = i - 1)
                    begin
                        mult_result[i] = 1'b0;
                    end
            end
            else
            begin
                    mult_result = mult_saturate_out;
            end
        end
        
        mult_final_out = (is_stratixii == 0) ?
                            temp_mult : mult_result;

    end


    // ---------------------------------------------------------------------------------------
    // This block contains 2 register (to set mult_res and mult_signed)
    // Signals Registered : mult_out_latent, mult_signed_latent
    //
    // Both the registers are controlled by the same clock signal, posedge multiplier_wire_clk
    // Both registers share the same clock enable signal multipler_wire_en
    // Both registers have the same asynchronous signal, posedge multiplier_wire_clr
    // ---------------------------------------------------------------------------------------
    assign mult_is_saturated_wire = (multiplier_reg == "UNREGISTERED")? mult_is_saturated_latent : mult_is_saturated_reg;
    
    always @(posedge multiplier_wire_clk or posedge multiplier_wire_clr)
    begin
        if (multiplier_wire_clr == 1)
        begin
            mult_res <=0;
            mult_signed <=0;
            mult_is_saturated_reg <=0;
        end
        else if ((multiplier_wire_clk == 1) && (multiplier_wire_en == 1))
        begin
            mult_res <= mult_out_latent;
            mult_signed <= mult_signed_latent;
            mult_is_saturated_reg <= mult_is_saturated_latent;
        end
    end


    // --------------------------------------------------------------------
    // This block contains 1 register (to set mult_full)
    // Signal Registered : mult_pipe
    //
    // Register is controlled by posedge mult_pipe_wire_clk
    // Register also has an asynchronous clear signal posedge mult_pipe_wire_clr
    // --------------------------------------------------------------------
    always @(posedge mult_pipe_wire_clk or posedge mult_pipe_wire_clr )
    begin
        if (mult_pipe_wire_clr ==1)
        begin
            // clear the pipeline
            for (i2=0; i2<=extra_multiplier_latency; i2=i2+1)
            begin
                mult_pipe [i2] = 0;
            end
            mult_full = 0;
        end
        else if ((mult_pipe_wire_clk == 1) && (mult_pipe_wire_en == 1))
        begin
            mult_pipe [head_mult] = {addsub_wire, zero_acc_wire, sign_a_wire, sign_b_wire, temp_mult_signed, mult_final_out, sload_upper_data_wire, mult_saturate_overflow};
            head_mult             = (head_mult +1) % (extra_multiplier_latency);
            mult_full             = mult_pipe[head_mult];
        end
    end


    // -------------------------------------------------------------
    // This is the main process block that performs the accumulation
    // -------------------------------------------------------------
    always @(posedge output_wire_clk or posedge output_wire_clr)
    begin
        if (output_wire_clr == 1)
        begin
            temp_sum = 0;
            accum_result = 0;
            
            result_int = (is_stratixii == 0) ?
                            temp_sum[int_width_result -1 : 0] : accum_result;
            
            overflow_int = 0;
            accum_saturate_overflow = 0;
            mult_is_saturated_int = 0;
            for (i3=0; i3<=extra_accumulator_latency; i3=i3+1)
            begin
                result_pipe [i3] = 0;
                accum_saturate_pipe[i3] = 0;
                mult_is_saturated_pipe[i3] = 0;
            end
            
            flag = ~flag;
            
        end
        else if (output_wire_clk ==1) 
        begin
                
        if (output_wire_en ==1)
        begin
            if (extra_accumulator_latency == 0)
            begin
                mult_is_saturated_int = mult_is_saturated_wire;
            end
        
            if (multiplier_reg == "UNREGISTERED")
            begin
                if (int_width_extra_bit > 0) begin
    				mult_res_out    =  {{int_width_extra_bit {(sign_a_int | sign_b_int) & mult_out_latent [int_width_a+int_width_b -1]}}, mult_out_latent};
    			end
    			else begin
    				mult_res_out    =  mult_out_latent;
    			end
                mult_signed_out =  (sign_a_int | sign_b_int);
            end
            else
            begin
                if (int_width_extra_bit > 0) begin
        			mult_res_out    =  {{int_width_extra_bit {(sign_a_int | sign_b_int) & mult_res [int_width_a+int_width_b -1]}}, mult_res};
        		end
        		else begin
        			mult_res_out    =  mult_res;
        		end
                mult_signed_out =  (sign_a_int | sign_b_int);
            end

            if (addsub_int)
            begin
                //add
                if (is_stratixii == 0 &&
                    is_cycloneii == 0)
                begin
                    temp_sum = ( (zero_acc_int==0) ? result_int : 0) + mult_res_out;
                end
                else
                begin
                    temp_sum = ( (zero_acc_int==0) ? result_int : sload_upper_data_pipe_wire) + mult_res_out;
                end

                cout_int = temp_sum [int_width_result];
            end
            else
            begin
                //subtract
                if (is_stratixii == 0 &&
                    is_cycloneii == 0)
                begin
                    temp_sum = ( (zero_acc_int==0) ? result_int : 0) - (mult_res_out);
                    cout_int = (( (zero_acc_int==0) ? result_int : 0) >= mult_res_out) ? 1 : 0;
                end
                else
                begin
                    temp_sum = ( (zero_acc_int==0) ? result_int : sload_upper_data_pipe_wire) - mult_res_out;
                    cout_int = (( (zero_acc_int==0) ? result_int : sload_upper_data_pipe_wire) >= mult_res_out) ? 1 : 0;
                end
            end

            //compute overflow
            if ((mult_signed_out==1) && (mult_res_out != 0))
            begin
                if (zero_acc_int == 0)
                begin
                    overflow_tmp_int = (mult_res_out [int_width_a+int_width_b -1] ~^ result_int [int_width_result-1]) ^ (~addsub_int);
                    overflow_int     =  overflow_tmp_int & (result_int [int_width_result -1] ^ temp_sum[int_width_result -1]);
                end
                else
                begin
                    overflow_tmp_int = (mult_res_out [int_width_a+int_width_b -1] ~^ sload_upper_data_pipe_wire [int_width_result-1]) ^ (~addsub_int);
                    overflow_int     =  overflow_tmp_int & (sload_upper_data_pipe_wire [int_width_result -1] ^ temp_sum[int_width_result -1]);
                end                
            end
            else
            begin
                overflow_int = (addsub_int ==1)? cout_int : ~cout_int;
            end

            if (is_stratixii == 1)
            begin
                // StratixII rounding support
            
                // This is based on both input is in Q1.15 format
            
                if ((accumulator_rounding == "YES") ||
                    ((accumulator_rounding == "VARIABLE") && (accum_round_int == 1)))
                begin
                    accum_round_out = temp_sum[int_width_result -1 : 0] + ( 1 << (bits_to_round));
                end
                else
                begin
                    accum_round_out = temp_sum[int_width_result - 1 : 0];
                end

                // StratixII saturation support

                if ((accumulator_saturation == "YES") || 
                    ((accumulator_saturation == "VARIABLE") && (accum_saturation_int == 1)))
                begin
                    accum_result_sign_bits = accum_round_out[int_width_result-1 : int_width_a + int_width_b - 2];
                    
                    if ( (((&accum_result_sign_bits) | (|accum_result_sign_bits) | (^accum_result_sign_bits)) == 0) ||
                        (((&accum_result_sign_bits) & (|accum_result_sign_bits) & !(^accum_result_sign_bits)) == 1))
                    begin
                        accum_saturate_overflow = 1'b0;
                    end
                    else
                    begin
                        accum_saturate_overflow = 1'b1;
                    end

                    if (accum_saturate_overflow == 0)
                    begin
                        accum_saturate_out = accum_round_out;
                        accum_saturate_out[sat_for_ini] = 1'b0;
                    end
                    else
                    begin
                        
                        for (i = (int_width_result - 1); i >= (int_width_a + int_width_b - 2); i = i - 1)
                        begin
                            accum_saturate_out[i] = accum_round_out[int_width_result-1];
                        end


                        for (i = (int_width_a + int_width_b - 3); i >= accum_sat_for_limit; i = i - 1)
                        begin
                            accum_saturate_out[i] = ~accum_round_out[int_width_result -1];
                        end
                        
                        for (i = sat_for_ini; i >= 0; i = i - 1)
                        begin
                            accum_saturate_out[i] = 1'b0;
                        end

                    end
                end
                else
                begin
                    accum_saturate_out = accum_round_out;
                    accum_saturate_overflow = 0;
                end
            
                if ((accumulator_rounding == "YES") ||
                    ((accumulator_rounding == "VARIABLE") && (accum_round_int == 1)))
                begin
                    accum_result = accum_saturate_out;

                    for (i = bits_to_round; i >= 0; i = i - 1)
                    begin
                        accum_result[i] = 1'b0;
                    end
                end
                else
                begin
                    accum_result = accum_saturate_out;
                end
            end
                
            result_int = (is_stratixii == 0) ?
                            temp_sum[int_width_result -1 : 0] : accum_result;

            flag = ~flag;
        end
        
        end    
    end
    
    always @ (posedge flag or negedge flag)
    begin        
        if (extra_accumulator_latency == 0)
        begin
            result   <= result_int[width_result - 1 + int_extra_width : int_extra_width];
            overflow <= overflow_int;
            accum_is_saturated_latent <= accum_saturate_overflow;
        end
        else
        begin
            result_pipe [head_result] <= {overflow_int, result_int[width_result - 1 + int_extra_width : int_extra_width]};
            //mult_is_saturated_pipe[head_result] = mult_is_saturated_wire;            
            accum_saturate_pipe[head_result] <= accum_saturate_overflow;
            head_result               <= (head_result +1) % (extra_accumulator_latency + 1);
            mult_is_saturated_int     <= mult_is_saturated_wire;  
        end
        
    end

    assign head_result_wire = head_result[31:0];
    
    always @ (head_result_wire or result_pipe[head_result_wire])
    begin
        if (extra_accumulator_latency != 0)
        begin
            result_full <= result_pipe[head_result_wire];
        end
    end
    
    always @ (accum_saturate_pipe[head_result_wire] or head_result_wire)
    begin
        if (extra_accumulator_latency != 0)
        begin
            accum_is_saturated_latent <= accum_saturate_pipe[head_result_wire];
        end
    end

    always @ (result_full[width_result:0])
    begin
        if (extra_accumulator_latency != 0)
        begin
            result   <= result_full [width_result-1:0];
            overflow <= result_full [width_result];
        end
    end

endmodule  // end of ALTMULT_ACCUM

//--------------------------------------------------------------------------
// Module Name      : altmult_add
//
// Description      : a*b + c*d
//
// Limitation       : Stratix DSP block
//
// Results expected : signed & unsigned, maximum of 3 pipelines(latency) each.
//                    possible of zero pipeline.
//
//--------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module altmult_add (    dataa, 
                        datab,
                        datac,
                        scanina,
                        scaninb,
                        sourcea,
                        sourceb,
                        clock3, 
                        clock2, 
                        clock1, 
                        clock0, 
                        aclr3, 
                        aclr2, 
                        aclr1, 
                        aclr0, 
                        ena3, 
                        ena2, 
                        ena1, 
                        ena0, 
                        signa, 
                        signb, 
                        addnsub1, 
                        addnsub3, 
                        result, 
                        scanouta, 
                        scanoutb,
                        mult01_round,
                        mult23_round,
                        mult01_saturation,
                        mult23_saturation,
                        addnsub1_round,
                        addnsub3_round,
                        mult0_is_saturated,
                        mult1_is_saturated,
                        mult2_is_saturated,
                        mult3_is_saturated,
                        output_round,
                        chainout_round,
                        output_saturate,
                        chainout_saturate,
                        overflow,
                        chainout_sat_overflow,
                        chainin,
                        zero_chainout,
                        rotate,
                        shift_right,
                        zero_loopback,
                        accum_sload,
			            coefsel0,
		             	coefsel1,
			            coefsel2,
			            coefsel3);
			            

    // ---------------------
    // PARAMETER DECLARATION
    // ---------------------

    parameter width_a               = 16;
    parameter width_b               = 16;
	parameter width_c				= 22;
    parameter width_result          = 34;
    parameter number_of_multipliers = 1;
    parameter lpm_type              = "altmult_add";
    parameter lpm_hint              = "UNUSED";

    // A inputs

    parameter multiplier1_direction = "UNUSED";
    parameter multiplier3_direction = "UNUSED";

    parameter input_register_a0 = "CLOCK0";
    parameter input_aclr_a0     = "ACLR3";
    parameter input_source_a0   = "DATAA";

    parameter input_register_a1 = "CLOCK0";
    parameter input_aclr_a1     = "ACLR3";
    parameter input_source_a1   = "DATAA";

    parameter input_register_a2 = "CLOCK0";
    parameter input_aclr_a2     = "ACLR3";
    parameter input_source_a2   = "DATAA";

    parameter input_register_a3 = "CLOCK0";
    parameter input_aclr_a3     = "ACLR3";
    parameter input_source_a3   = "DATAA";

    parameter port_signa                 = "PORT_CONNECTIVITY";
    parameter representation_a           = "UNSIGNED";
    parameter signed_register_a          = "CLOCK0";
    parameter signed_aclr_a              = "ACLR3";
    parameter signed_pipeline_register_a = "CLOCK0";
    parameter signed_pipeline_aclr_a     = "ACLR3";
    
    parameter scanouta_register = "UNREGISTERED";
    parameter scanouta_aclr = "NONE";

    // B inputs

    parameter input_register_b0 = "CLOCK0";
    parameter input_aclr_b0     = "ACLR3";
    parameter input_source_b0   = "DATAB";

    parameter input_register_b1 = "CLOCK0";
    parameter input_aclr_b1     = "ACLR3";
    parameter input_source_b1   = "DATAB";

    parameter input_register_b2 = "CLOCK0";
    parameter input_aclr_b2     = "ACLR3";
    parameter input_source_b2   = "DATAB";

    parameter input_register_b3 = "CLOCK0";
    parameter input_aclr_b3     = "ACLR3";
    parameter input_source_b3   = "DATAB";

    parameter port_signb                 = "PORT_CONNECTIVITY";
    parameter representation_b           = "UNSIGNED";
    parameter signed_register_b          = "CLOCK0";
    parameter signed_aclr_b              = "ACLR3";
    parameter signed_pipeline_register_b = "CLOCK0";
    parameter signed_pipeline_aclr_b     = "ACLR3";

    //C inputs
    parameter input_register_c0	= "CLOCK0";
	parameter input_aclr_c0		= "ACLR0";
	
   	parameter input_register_c1	= "CLOCK0";
   	parameter input_aclr_c1	 	= "ACLR0";
	
	parameter input_register_c2	= "CLOCK0";
    parameter input_aclr_c2		= "ACLR0";
	
	parameter input_register_c3	= "CLOCK0";
	parameter input_aclr_c3		= "ACLR0";
	
    // multiplier parameters

    parameter multiplier_register0 = "CLOCK0";
    parameter multiplier_aclr0     = "ACLR3";
    parameter multiplier_register1 = "CLOCK0";
    parameter multiplier_aclr1     = "ACLR3";
    parameter multiplier_register2 = "CLOCK0";
    parameter multiplier_aclr2     = "ACLR3";
    parameter multiplier_register3 = "CLOCK0";
    parameter multiplier_aclr3     = "ACLR3";

    parameter port_addnsub1                         = "PORT_CONNECTIVITY";
    parameter addnsub_multiplier_register1          = "CLOCK0";
    parameter addnsub_multiplier_aclr1              = "ACLR3";
    parameter addnsub_multiplier_pipeline_register1 = "CLOCK0";
    parameter addnsub_multiplier_pipeline_aclr1     = "ACLR3";
   
    parameter port_addnsub3                         = "PORT_CONNECTIVITY";
    parameter addnsub_multiplier_register3          = "CLOCK0";
    parameter addnsub_multiplier_aclr3              = "ACLR3";
    parameter addnsub_multiplier_pipeline_register3 = "CLOCK0";
    parameter addnsub_multiplier_pipeline_aclr3     = "ACLR3";

    parameter addnsub1_round_aclr                   = "ACLR3";
    parameter addnsub1_round_pipeline_aclr          = "ACLR3";
    parameter addnsub1_round_register               = "CLOCK0";
    parameter addnsub1_round_pipeline_register      = "CLOCK0";
    parameter addnsub3_round_aclr                   = "ACLR3";
    parameter addnsub3_round_pipeline_aclr          = "ACLR3";
    parameter addnsub3_round_register               = "CLOCK0";
    parameter addnsub3_round_pipeline_register      = "CLOCK0";

    parameter mult01_round_aclr                     = "ACLR3";
    parameter mult01_round_register                 = "CLOCK0";
    parameter mult01_saturation_register            = "CLOCK0";
    parameter mult01_saturation_aclr                = "ACLR3";
    parameter mult23_round_register                 = "CLOCK0";
    parameter mult23_round_aclr                     = "ACLR3";
    parameter mult23_saturation_register            = "CLOCK0";
    parameter mult23_saturation_aclr                = "ACLR3";
    
    // StratixII parameters
    parameter multiplier01_rounding = "NO";
    parameter multiplier01_saturation = "NO";
    parameter multiplier23_rounding = "NO";
    parameter multiplier23_saturation = "NO";
    parameter adder1_rounding = "NO";
    parameter adder3_rounding = "NO";
    parameter port_mult0_is_saturated = "UNUSED";
    parameter port_mult1_is_saturated = "UNUSED";
    parameter port_mult2_is_saturated = "UNUSED";
    parameter port_mult3_is_saturated = "UNUSED";
    
    // Stratix III parameters
    // Rounding parameters
    parameter output_rounding = "NO";
    parameter output_round_type = "NEAREST_INTEGER";
    parameter width_msb = 17;
    parameter output_round_register = "UNREGISTERED";
    parameter output_round_aclr = "NONE";
    parameter output_round_pipeline_register = "UNREGISTERED";
    parameter output_round_pipeline_aclr = "NONE";
    
    parameter chainout_rounding = "NO";
    parameter chainout_round_register = "UNREGISTERED";
    parameter chainout_round_aclr = "NONE";
    parameter chainout_round_pipeline_register = "UNREGISTERED";
    parameter chainout_round_pipeline_aclr = "NONE";
    parameter chainout_round_output_register = "UNREGISTERED";
    parameter chainout_round_output_aclr = "NONE";
    
    // saturation parameters
    parameter port_output_is_overflow = "PORT_UNUSED";
    parameter port_chainout_sat_is_overflow = "PORT_UNUSED";
    parameter output_saturation = "NO";
    parameter output_saturate_type = "ASYMMETRIC";
    parameter width_saturate_sign = 1;
    parameter output_saturate_register = "UNREGISTERED";
    parameter output_saturate_aclr = "NONE";
    parameter output_saturate_pipeline_register = "UNREGISTERED";
    parameter output_saturate_pipeline_aclr = "NONE";
    
    parameter chainout_saturation = "NO";
    parameter chainout_saturate_register = "UNREGISTERED";
    parameter chainout_saturate_aclr = "NONE";
    parameter chainout_saturate_pipeline_register = "UNREGISTERED";
    parameter chainout_saturate_pipeline_aclr = "NONE";
    parameter chainout_saturate_output_register = "UNREGISTERED";
    parameter chainout_saturate_output_aclr = "NONE";
    
    // chainout parameters
    parameter chainout_adder = "NO";
    parameter chainout_register = "UNREGISTERED";
    parameter chainout_aclr = "ACLR3";
    parameter width_chainin = 1;
    parameter zero_chainout_output_register = "UNREGISTERED";
    parameter zero_chainout_output_aclr = "NONE";

    // rotate & shift parameters
    parameter shift_mode = "NO";
    parameter rotate_aclr = "NONE";
    parameter rotate_register = "UNREGISTERED";
    parameter rotate_pipeline_register = "UNREGISTERED";
    parameter rotate_pipeline_aclr = "NONE";
    parameter rotate_output_register = "UNREGISTERED";
    parameter rotate_output_aclr = "NONE";
    parameter shift_right_register = "UNREGISTERED";
    parameter shift_right_aclr = "NONE";
    parameter shift_right_pipeline_register = "UNREGISTERED";
    parameter shift_right_pipeline_aclr = "NONE";
    parameter shift_right_output_register = "UNREGISTERED";
    parameter shift_right_output_aclr = "NONE";
    
    // loopback parameters
    parameter zero_loopback_register = "UNREGISTERED";
    parameter zero_loopback_aclr = "NONE";
    parameter zero_loopback_pipeline_register = "UNREGISTERED";
    parameter zero_loopback_pipeline_aclr = "NONE";
    parameter zero_loopback_output_register = "UNREGISTERED";
    parameter zero_loopback_output_aclr = "NONE";

    // accumulator parameters
    parameter accum_sload_register = "UNREGISTERED";
    parameter accum_sload_aclr = "NONE";
    parameter accum_sload_pipeline_register = "UNREGISTERED";
    parameter accum_sload_pipeline_aclr = "NONE";
    parameter accum_direction = "ADD";
    parameter accumulator = "NO";
	
	//StratixV parameters
  	parameter preadder_mode	= "SIMPLE";
  	parameter loadconst_value = 0;
  	parameter width_coef = 0;
  	
  	parameter loadconst_control_register = "CLOCK0";
  	parameter loadconst_control_aclr	= "ACLR0";
 	
	parameter coefsel0_register = "CLOCK0";
  	parameter coefsel1_register	= "CLOCK0";
  	parameter coefsel2_register	= "CLOCK0";
  	parameter coefsel3_register	= "CLOCK0";
   	parameter coefsel0_aclr	= "ACLR0";
   	parameter coefsel1_aclr	= "ACLR0";
	parameter coefsel2_aclr	= "ACLR0";
   	parameter coefsel3_aclr	= "ACLR0";
	
   	parameter preadder_direction_0	= "ADD";
	parameter preadder_direction_1	= "ADD";
	parameter preadder_direction_2	= "ADD";
	parameter preadder_direction_3	= "ADD";
	
	parameter systolic_delay1 = "UNREGISTERED";
	parameter systolic_delay3 = "UNREGISTERED";
	parameter systolic_aclr1 = "NONE";
	parameter systolic_aclr3 = "NONE";
	
	//coefficient storage
	parameter coef0_0 = 0;
	parameter coef0_1 = 0;
	parameter coef0_2 = 0;
	parameter coef0_3 = 0;
	parameter coef0_4 = 0;
	parameter coef0_5 = 0;
	parameter coef0_6 = 0;
	parameter coef0_7 = 0;
	
	parameter coef1_0 = 0;
	parameter coef1_1 = 0;
	parameter coef1_2 = 0;
	parameter coef1_3 = 0;
	parameter coef1_4 = 0;
	parameter coef1_5 = 0;
	parameter coef1_6 = 0;
	parameter coef1_7 = 0;
	
	parameter coef2_0 = 0;
	parameter coef2_1 = 0;
	parameter coef2_2 = 0;
	parameter coef2_3 = 0;
	parameter coef2_4 = 0;
	parameter coef2_5 = 0;
	parameter coef2_6 = 0;
	parameter coef2_7 = 0;
	
	parameter coef3_0 = 0;
	parameter coef3_1 = 0;
	parameter coef3_2 = 0;
	parameter coef3_3 = 0;
	parameter coef3_4 = 0;
	parameter coef3_5 = 0;
	parameter coef3_6 = 0;
	parameter coef3_7 = 0;
    // output parameters
  
    parameter output_register = "CLOCK0";
    parameter output_aclr     = "ACLR3";
 
    // general setting parameters

    parameter extra_latency                  = 0;
    parameter dedicated_multiplier_circuitry = "AUTO";
    parameter dsp_block_balancing            = "AUTO";
    parameter intended_device_family         = "Stratix";
    
    // ----------------
    // PORT DECLARATION
    // ----------------

    // data input ports
    input [number_of_multipliers * width_a -1 : 0] dataa;
    input [number_of_multipliers * width_b -1 : 0] datab;
	input [number_of_multipliers * width_c -1 : 0] datac;

    input [width_a -1 : 0] scanina;
    input [width_b -1 : 0] scaninb;

    input [number_of_multipliers -1 : 0] sourcea;
    input [number_of_multipliers -1 : 0] sourceb;
 
    // clock ports
    input clock3;
    input clock2;
    input clock1;
    input clock0;

    // clear ports
    input aclr3;
    input aclr2;
    input aclr1;
    input aclr0;

    // clock enable ports
    input ena3;
    input ena2;
    input ena1;
    input ena0;

    // control signals
    input signa;
    input signb;
    input addnsub1;
    input addnsub3;

    // StratixII only input ports
    input mult01_round;
    input mult23_round;
    input mult01_saturation;
    input mult23_saturation;
    input addnsub1_round;
    input addnsub3_round;
 
    // Stratix III only input ports
    input output_round;
    input chainout_round;
    input output_saturate;
    input chainout_saturate;
    input [width_chainin - 1 : 0] chainin;
    input zero_chainout;
    input rotate;
    input shift_right;
    input zero_loopback;
    input accum_sload;

	//StratixV only input ports
	input [2:0]coefsel0;
	input [2:0]coefsel1;
	input [2:0]coefsel2;
	input [2:0]coefsel3;
	
    // output ports
    output [width_result -1 : 0] result;
    output [width_a -1 : 0] scanouta;
    output [width_b -1 : 0] scanoutb;

    // StratixII only output ports
    output mult0_is_saturated;
    output mult1_is_saturated;
    output mult2_is_saturated;
    output mult3_is_saturated; 
    
    // Stratix III only output ports
    output overflow;
    output chainout_sat_overflow;

// LOCAL_PARAMETERS_BEGIN

    // -----------------------------------
    //  Parameters internally used
    // -----------------------------------
    // Represent the internal used width_a
    parameter int_width_c = ((preadder_mode == "INPUT" )? width_c: 1);
    
    parameter int_width_preadder = ((preadder_mode == "INPUT" || preadder_mode == "SQUARE" || preadder_mode == "COEF" )?((width_a > width_b)? width_a + 1 : width_b + 1):width_a);
    
    parameter int_width_a = ((preadder_mode == "INPUT" || preadder_mode == "SQUARE" || preadder_mode == "COEF" )?((width_a > width_b)? width_a + 1 : width_b + 1):
    						((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO") &&
                            (multiplier01_rounding == "NO") && (multiplier23_rounding == "NO") &&
                            (output_rounding == "NO") && (output_saturation == "NO") && 
                            (chainout_rounding == "NO") && (chainout_saturation == "NO") &&
                            (chainout_adder == "NO") && (input_source_b0 != "LOOPBACK"))? width_a:
                            (width_a < 18)? 18 : width_a);
    // Represent the internal used width_b
    parameter int_width_b = ((preadder_mode == "SQUARE" )?((width_a > width_b)? width_a + 1 : width_b + 1):
    						(preadder_mode == "COEF" || preadder_mode == "CONSTANT")?width_coef:
    						((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO") &&
                            (multiplier01_rounding == "NO") && (multiplier23_rounding == "NO") &&
                            (output_rounding == "NO") && (output_saturation == "NO") &&
                            (chainout_rounding == "NO") && (chainout_saturation == "NO") &&
                            (chainout_adder == "NO") && (input_source_b0 != "LOOPBACK"))? width_b:
                            (width_b < 18)? 18 : width_b);

    parameter int_width_multiply_b = ((preadder_mode == "SIMPLE" || preadder_mode =="SQUARE")? int_width_b :
                                      (preadder_mode == "INPUT") ? int_width_c :
                                      (preadder_mode == "CONSTANT" || preadder_mode == "COEF") ? width_coef: int_width_b);

    //Represent the internally used width_result                              
    parameter int_width_result = (((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO") &&
                                    (multiplier01_rounding == "NO") && (multiplier23_rounding == "NO") &&
                                    (output_rounding == "NO") && (output_saturation == "NO")
                                    && (chainout_rounding == "NO") && (chainout_saturation == "NO") && 
                                    (chainout_adder == "NO") && (shift_mode == "NO"))? width_result:
                                    (shift_mode != "NO") ? 64 :
                                    (chainout_adder == "YES") ? 44 :
                                    (width_result > (int_width_a + int_width_b))? 
                                    (width_result + width_result - int_width_a - int_width_b):
                                    int_width_a + int_width_b);     
                                    
    parameter mult_b_pre_width = int_width_b + 19;
                                
    // Represent the internally used width_result                                  
    parameter int_mult_diff_bit = (((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO") &&
                                    (multiplier01_rounding == "NO") && (multiplier23_rounding == "NO") 
                                    && (output_rounding == "NO") && (output_saturation == "NO") &&
                                    (chainout_rounding == "NO") && (chainout_saturation == "NO") && 
                                    (chainout_adder == "NO"))? 0:
                                    (chainout_adder == "YES") ? ((width_result > width_a + width_b + 8) ? 0: (int_width_a - width_a + int_width_b - width_b)) :
                                    (int_width_a - width_a + int_width_b - width_b));
                                    
    parameter int_mult_diff_bit_loopbk = (int_width_result > width_result)? (int_width_result - width_result) :
                                            (width_result - int_width_result);
                                    
    parameter sat_ini_value = (((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO"))? 3:
                                int_width_a + int_width_b - 3);   

    parameter round_position = ((output_rounding != "NO") || (output_saturate_type == "SYMMETRIC")) ?
                                (input_source_b0 == "LOOPBACK")? 18 : 
                                ((width_a + width_b) > width_result)?
                                (int_width_a + int_width_b - width_msb - (width_a + width_b - width_result)) :
                                ((width_a + width_b) == width_result)?
                                (int_width_a + int_width_b - width_msb): 
                                (int_width_a + int_width_b - width_msb + (width_result - width_msb) + (width_msb - width_a - width_b)):
                                2;
                                
    parameter chainout_round_position = ((chainout_rounding != "NO") || (output_saturate_type == "SYMMETRIC")) ?
                                (width_result >= int_width_result)? width_result - width_msb : 
                                (width_result - width_msb > 0)? width_result + int_mult_diff_bit - width_msb:
                                0 : 2; 
                                                                
    parameter saturation_position = (output_saturation != "NO") ? (chainout_saturation == "NO")?  
                                ((width_a + width_b) > width_result)? 
                                (int_width_a + int_width_b - width_saturate_sign - (width_a + width_b - width_result)) :
                                ((width_a + width_b) == width_result)?
                                (int_width_a + int_width_b - width_saturate_sign): 
                                (int_width_a + int_width_b - width_saturate_sign + (width_result - width_saturate_sign) + (width_saturate_sign - width_a - width_b)): //2;
                                (width_result >= int_width_result)? width_result - width_saturate_sign : 
                                (width_result - width_saturate_sign > 0)? width_result + int_mult_diff_bit - width_saturate_sign:
                                0 : 2;
    
    parameter chainout_saturation_position = (chainout_saturation != "NO") ?
                                (width_result >= int_width_result)? width_result - width_saturate_sign : 
                                (width_result - width_saturate_sign > 0)? width_result + int_mult_diff_bit - width_saturate_sign:
                                0 : 2; 
                                                
    parameter result_msb_stxiii = ((number_of_multipliers == 1) && (width_result > width_a + width_b))? 
                                (width_a + width_b - 1): 
                                (((number_of_multipliers == 2) || (input_source_b0 == "LOOPBACK")) && (width_result > width_a + width_b + 1))?
                                (width_a + width_b):
                                ((number_of_multipliers > 2) && (width_result > width_a + width_b + 2))?
                                (width_a + width_b + 1):
                                (width_result - 1);

    parameter result_msb = (width_a + width_b - 1); 
                                  
    parameter shift_partition = (shift_mode == "NO") ? 1 : (int_width_result / 2);
    parameter shift_msb = (shift_mode == "NO") ? 1 : (int_width_result - 1);
    parameter sat_msb = (int_width_a + int_width_b - 1);
    parameter chainout_sat_msb = (int_width_result - 1);

    parameter chainout_input_a = (width_a < 18) ? (18 - width_a) : 
                                                1; 
                                                
    parameter chainout_input_b = (width_b < 18) ? (18 - width_b) : 
                                                1; 
   
    parameter mult_res_pad = (int_width_result > int_width_a + int_width_b)? (int_width_result - int_width_a - int_width_b) :
                                                1;                                                                                                            
                                                            
    parameter result_pad = ((width_result - 1 + int_mult_diff_bit) > int_width_result)? (width_result + 1 + int_mult_diff_bit - int_width_result) :
                                                1;               
                                             
    parameter result_stxiii_pad = (width_result > width_a + width_b)? 
                                                (width_result - width_a - width_b) :   1;                                               
                                                                              
    parameter loopback_input_pad = (int_width_b > width_b)? (int_width_b - width_b) : 1; 
                                                                              
    parameter loopback_lower_bound = (int_width_b > width_b)? width_b : 0 ;
    
    parameter accum_width = (int_width_a + int_width_b < 44)? 44: int_width_a + int_width_b;
    
    parameter feedback_width = ((accum_width + int_mult_diff_bit) < 2*int_width_result)? accum_width + int_mult_diff_bit : 2*int_width_result;

    parameter lower_range = ((2*int_width_result - 1) < (int_width_a + int_width_b)) ? int_width_result : int_width_a + int_width_b;
    
    parameter addsub1_clr = ((port_addnsub1 == "PORT_USED") || ((port_addnsub1 == "PORT_CONNECTIVITY")&&(multiplier1_direction== "UNUSED")))? 1 : 0;
    
    parameter addsub3_clr = ((port_addnsub3 == "PORT_USED") || ((port_addnsub3 == "PORT_CONNECTIVITY")&&(multiplier3_direction== "UNUSED")))? 1 : 0;
    
    parameter lsb_position = 36 - width_a - width_b;
    
    parameter extra_sign_bit_width = (port_signa == "PORT_USED" || port_signb == "PORT_USED")? accum_width - width_result - lsb_position :
                                (representation_a == "UNSIGNED" && representation_b == "UNSIGNED")? accum_width - width_result - lsb_position:
                                accum_width - width_result + 1 - lsb_position;
    
    parameter bit_position = accum_width - lsb_position - extra_sign_bit_width - 1;

    

// LOCAL_PARAMETERS_END

    // -----------------------------------
    // Constants internally used
    // -----------------------------------
    // Represent the number of bits needed to be rounded in multiplier where the
    // value 17 here refers to the 2 sign bits and the 15 wanted bits for rounding
    `define MULT_ROUND_BITS  (((multiplier01_rounding == "NO") && (multiplier23_rounding == "NO"))? 1 : (int_width_a + int_width_b) - 17) 
    
    // Represent the number of bits needed to be rounded in adder where the
    // value 18 here refers to the 3 sign bits and the 15 wanted bits for rounding.
    `define ADDER_ROUND_BITS (((adder1_rounding == "NO") && (adder3_rounding == "NO"))? 1 :(int_width_a + int_width_b) - 17)

    // Represent the user defined width_result
    `define RESULT_WIDTH 44

    // Represent the range for shift mode
    `define SHIFT_MODE_WIDTH (shift_mode != "NO")? 31 : width_result - 1
    
    // Represent the range for loopback input
    `define LOOPBACK_WIRE_WIDTH (input_source_b0 == "LOOPBACK")? (width_a + 18) : (int_width_result < width_a + 18) ? (width_a + 18) : int_width_result
    // ---------------
    // REG DECLARATION
    // ---------------

    reg  [2*int_width_result - 1 :0] temp_sum;
    reg  [2*int_width_result : 0] mult_res_ext;
    reg  [2*int_width_result - 1 : 0] temp_sum_reg;
    
    reg  [4 * int_width_a -1 : 0] mult_a_reg;
    reg  [4 * int_width_b -1 : 0] mult_b_reg;
    reg  [int_width_c -1 : 0] mult_c_reg;


    reg  [(int_width_a + int_width_b) -1:0] mult_res_0;
    reg  [(int_width_a + int_width_b) -1:0] mult_res_1;
    reg  [(int_width_a + int_width_b) -1:0] mult_res_2;
    reg  [(int_width_a + int_width_b) -1:0] mult_res_3;


    reg  [4 * (int_width_a + int_width_b) -1:0] mult_res_reg;
    reg  [(int_width_a + int_width_b - 1) :0] mult_res_temp;

   
    reg sign_a_pipe_reg;
    reg sign_a_reg;
    reg sign_b_pipe_reg;
    reg sign_b_reg;

    reg addsub1_reg;
    reg addsub1_pipe_reg;

    reg addsub3_reg;
    reg addsub3_pipe_reg;  


    // StratixII features related internal reg type

    reg [(int_width_a + int_width_b + 3) -1 : 0] mult0_round_out;
    reg [(int_width_a + int_width_b + 3) -1 : 0] mult0_saturate_out;
    reg [(int_width_a + int_width_b + 3) -1 : 0] mult0_result;
    reg mult0_saturate_overflow;
    reg mult0_saturate_overflow_stat;

    reg [(int_width_a + int_width_b + 3) -1 : 0] mult1_round_out;
    reg [(int_width_a + int_width_b + 3) -1 : 0] mult1_saturate_out;
    reg [(int_width_a + int_width_b) -1 : 0] mult1_result;
    reg mult1_saturate_overflow;
    reg mult1_saturate_overflow_stat;

    reg [(int_width_a + int_width_b + 3) -1 : 0] mult2_round_out;
    reg [(int_width_a + int_width_b + 3) -1 : 0] mult2_saturate_out;
    reg [(int_width_a + int_width_b) -1 : 0] mult2_result;
    reg mult2_saturate_overflow;
    reg mult2_saturate_overflow_stat;

    reg [(int_width_a + int_width_b + 3) -1 : 0] mult3_round_out;
    reg [(int_width_a + int_width_b + 3) -1 : 0] mult3_saturate_out;
    reg [(int_width_a + int_width_b) -1 : 0] mult3_result;
    reg mult3_saturate_overflow;
    reg mult3_saturate_overflow_stat;

    reg mult01_round_reg;
    reg mult01_saturate_reg;
    reg mult23_round_reg;
    reg mult23_saturate_reg;
    reg [3 : 0] mult_saturate_overflow_reg;
    reg [3 : 0] mult_saturate_overflow_pipe_reg;

    reg [int_width_result : 0] adder1_round_out;
    reg [int_width_result : 0] adder1_result;
    reg [int_width_result : 0] adder2_result;
    reg addnsub1_round_reg;
    reg addnsub1_round_pipe_reg;

    reg [int_width_result : 0] adder3_round_out;
    reg [int_width_result : 0] adder3_result;
    reg addnsub3_round_reg;
    reg addnsub3_round_pipe_reg;
    
    // Stratix III only internal registers
    reg outround_reg;
    reg outround_pipe_reg;
    reg chainout_round_reg;
    reg chainout_round_pipe_reg;
    reg chainout_round_out_reg;
    reg outsat_reg;
    reg outsat_pipe_reg;
    reg chainout_sat_reg;
    reg chainout_sat_pipe_reg;
    reg chainout_sat_out_reg;
    reg zerochainout_reg;
    reg rotate_reg;
    reg rotate_pipe_reg;
    reg rotate_out_reg;
    reg shiftr_reg;
    reg shiftr_pipe_reg;
    reg shiftr_out_reg;
    reg zeroloopback_reg;
    reg zeroloopback_pipe_reg;
    reg zeroloopback_out_reg;
    reg accumsload_reg;
    reg accumsload_pipe_reg;

    reg [int_width_a -1 : 0] scanouta_reg;
    reg [2*int_width_result - 1: 0] adder1_reg;
    reg [2*int_width_result - 1: 0] adder3_reg;
    reg [2*int_width_result - 1: 0] adder1_sum;
    reg [2*int_width_result - 1: 0] adder3_sum;
    reg [accum_width + int_mult_diff_bit : 0] adder1_res_ext;
    reg [2*int_width_result: 0] adder3_res_ext;
    reg [2*int_width_result - 1: 0] round_block_result;
    reg [2*int_width_result - 1: 0] sat_block_result;
    reg [2*int_width_result - 1: 0] round_sat_blk_res;
    reg [int_width_result: 0] chainout_round_block_result;
    reg [int_width_result: 0] chainout_sat_block_result;
    reg [2*int_width_result - 1: 0] round_sat_in_result;
    reg [int_width_result: 0] chainout_rnd_sat_blk_res;
    reg [int_width_result: 0] chainout_output_reg;
    reg [int_width_result: 0] chainout_final_out;
    reg [int_width_result : 0] shift_rot_result;
    reg [2*int_width_result - 1: 0] acc_feedback_reg;
    reg [int_width_result: 0] chout_shftrot_reg;
    reg [int_width_result: 0] loopback_wire_reg;
    reg [int_width_result: 0] loopback_wire_latency;
    
    reg overflow_status;
    reg overflow_stat_reg;
    reg [extra_latency : 0] overflow_stat_pipe_reg;
    reg [extra_latency : 0] accum_overflow_stat_pipe_reg;
    reg [extra_latency : 0] unsigned_sub1_overflow_pipe_reg;
    reg [extra_latency : 0] unsigned_sub3_overflow_pipe_reg;
    reg chainout_overflow_status;
    reg chainout_overflow_stat_reg;
    reg stick_bits_or;
    reg cho_stick_bits_or;
    reg sat_bits_or;
    reg cho_sat_bits_or;
    reg round_happen;
    reg cho_round_happen;

    reg overflow_checking;
    reg round_checking;
    
    reg [accum_width + int_mult_diff_bit : 0] accum_res_temp;
    reg [accum_width + int_mult_diff_bit : 0] accum_res;
    reg [accum_width + int_mult_diff_bit : 0] acc_feedback_temp;
    reg accum_overflow;
    reg accum_overflow_int;
    reg accum_overflow_reg;
    reg [accum_width + int_mult_diff_bit : 0] adder3_res_temp;
    reg unsigned_sub1_overflow;
    reg unsigned_sub3_overflow;
    reg unsigned_sub1_overflow_reg;
    reg unsigned_sub3_overflow_reg;
    reg unsigned_sub1_overflow_mult_reg;
    reg unsigned_sub3_overflow_mult_reg;
    wire unsigned_sub1_overflow_wire;
    wire unsigned_sub3_overflow_wire;

    wire [mult_b_pre_width - 1 : 0] loopback_wire_temp;
    
    // StratixV internal register
    reg [2:0]coeffsel_a_reg;
    reg [2:0]coeffsel_b_reg;
    reg [2:0]coeffsel_c_reg;
    reg [2:0]coeffsel_d_reg;

    reg [2*int_width_a - 1: 0] preadder_sum1a;
    reg [2*int_width_b - 1: 0] preadder_sum2a;

    reg [(int_width_a + int_width_b + 1) -1 : 0] preadder0_result;
    reg [(int_width_a + int_width_b + 1) -1 : 0] preadder1_result;
    reg [(int_width_a + int_width_b + 1) -1 : 0] preadder2_result;
    reg [(int_width_a + int_width_b + 1) -1 : 0] preadder3_result;
    
    reg  [(int_width_a + int_width_b) -1:0] preadder_res_0;
    reg  [(int_width_a + int_width_b) -1:0] preadder_res_1;
    reg  [(int_width_a + int_width_b) -1:0] preadder_res_2;
    reg  [(int_width_a + int_width_b) -1:0] preadder_res_3;
    
    reg  [(int_width_a + int_width_b) -1:0] mult_res_reg_0;
    reg  [(int_width_a + int_width_b) -1:0] mult_res_reg_2;
    reg  [2*int_width_result - 1: 0] adder1_res_reg_0;
    reg  [2*int_width_result - 1: 0] adder1_res_reg_1;
    reg  [(width_chainin) -1:0] chainin_reg;
    reg  [2*int_width_result - 1: 0] round_sat_in_reg;
   

    //-----------------
    // TRI DECLARATION
    //-----------------
    tri0 signa_z;
    tri0 signb_z;  
    tri1 addnsub1_z;
    tri1 addnsub3_z; 
    tri0  [4 * int_width_a -1 : 0] dataa_int;
    tri0  [4 * int_width_b -1 : 0] datab_int;
    tri0  [4 * int_width_c -1 : 0] datac_int;
    tri0  [4 * int_width_a -1 : 0] new_dataa_int;
    tri0  [4 * int_width_a -1 : 0] chainout_new_dataa_int;
    tri0  [4 * int_width_b -1 : 0] new_datab_int;
    tri0  [4 * int_width_b -1 : 0] chainout_new_datab_int;
    reg  [4 * int_width_a -1 : 0] dataa_reg;
    reg  [4 * int_width_b -1 : 0] datab_reg;
    tri0  [int_width_a - 1 : 0] scanina_z;
    tri0  [int_width_b - 1 : 0] scaninb_z;
    
    // Stratix III signals
    tri0 outround_int;
    tri0 chainout_round_int;
    tri0 outsat_int;
    tri0 chainout_sat_int;
    tri0 zerochainout_int;
    tri0 rotate_int;
    tri0 shiftr_int;
    tri0 zeroloopback_int;
    tri0 accumsload_int;
    tri0 [width_chainin - 1 : 0] chainin_int;
    
    // Stratix V signals
    //tri0 loadconst_int;
    //tri0 negate_int;
    //tri0 accum_int;
	tri0 [2:0]coeffsel_a_int;
    tri0 [2:0]coeffsel_b_int;
    tri0 [2:0]coeffsel_c_int;
    tri0 [2:0]coeffsel_d_int;
    
    // Tri wire for clear signal
    tri0 input_reg_a0_wire_clr;
    tri0 input_reg_a1_wire_clr;
    tri0 input_reg_a2_wire_clr;
    tri0 input_reg_a3_wire_clr;

    tri0 input_reg_b0_wire_clr;
    tri0 input_reg_b1_wire_clr;
    tri0 input_reg_b2_wire_clr;
    tri0 input_reg_b3_wire_clr;
	
    tri0 input_reg_c0_wire_clr;
    tri0 input_reg_c1_wire_clr;
    tri0 input_reg_c2_wire_clr;
    tri0 input_reg_c3_wire_clr;
    
    tri0 sign_reg_a_wire_clr;
    tri0 sign_pipe_a_wire_clr;

    tri0 sign_reg_b_wire_clr;
    tri0 sign_pipe_b_wire_clr;

    tri0 addsub1_reg_wire_clr;
    tri0 addsub1_pipe_wire_clr;

    tri0 addsub3_reg_wire_clr;
    tri0 addsub3_pipe_wire_clr;
    
    // Stratix III only aclr signals
    tri0 outround_reg_wire_clr;
    tri0 outround_pipe_wire_clr;
    tri0 chainout_round_reg_wire_clr;
    tri0 chainout_round_pipe_wire_clr;
    tri0 chainout_round_out_reg_wire_clr;
    tri0 outsat_reg_wire_clr;
    tri0 outsat_pipe_wire_clr;
    tri0 chainout_sat_reg_wire_clr;
    tri0 chainout_sat_pipe_wire_clr;
    tri0 chainout_sat_out_reg_wire_clr;
    tri0 scanouta_reg_wire_clr;
    tri0 chainout_reg_wire_clr;
    tri0 zerochainout_reg_wire_clr;
    tri0 rotate_reg_wire_clr;
    tri0 rotate_pipe_wire_clr;
    tri0 rotate_out_reg_wire_clr;
    tri0 shiftr_reg_wire_clr;
    tri0 shiftr_pipe_wire_clr;
    tri0 shiftr_out_reg_wire_clr;
    tri0 zeroloopback_reg_wire_clr;
    tri0 zeroloopback_pipe_wire_clr;
    tri0 zeroloopback_out_wire_clr;
    tri0 accumsload_reg_wire_clr;
    tri0 accumsload_pipe_wire_clr;
    // end Stratix III only aclr signals
	
    // Stratix V only aclr signals
    tri0 coeffsela_reg_wire_clr;
    tri0 coeffselb_reg_wire_clr;
    tri0 coeffselc_reg_wire_clr;
    tri0 coeffseld_reg_wire_clr;
    
    // end Stratix V only aclr signals
    
    tri0 multiplier_reg0_wire_clr;
    tri0 multiplier_reg1_wire_clr;
    tri0 multiplier_reg2_wire_clr;
    tri0 multiplier_reg3_wire_clr;

    tri0 addnsub1_round_wire_clr;
    tri0 addnsub1_round_pipe_wire_clr;
    
    tri0 addnsub3_round_wire_clr;
    tri0 addnsub3_round_pipe_wire_clr;
    
    tri0 mult01_round_wire_clr;
    tri0 mult01_saturate_wire_clr;
    
    tri0 mult23_round_wire_clr;
    tri0 mult23_saturate_wire_clr;
    
    tri0 output_reg_wire_clr;

    tri0 [3 : 0] sourcea_wire;
    tri0 [3 : 0] sourceb_wire;


    
    // Tri wire for enable signal

    tri1 input_reg_a0_wire_en;
    tri1 input_reg_a1_wire_en;
    tri1 input_reg_a2_wire_en;
    tri1 input_reg_a3_wire_en;

    tri1 input_reg_b0_wire_en;
    tri1 input_reg_b1_wire_en;
    tri1 input_reg_b2_wire_en;
    tri1 input_reg_b3_wire_en;
	
    tri1 input_reg_c0_wire_en;
    tri1 input_reg_c1_wire_en;
    tri1 input_reg_c2_wire_en;
    tri1 input_reg_c3_wire_en;

    tri1 sign_reg_a_wire_en;
    tri1 sign_pipe_a_wire_en;

    tri1 sign_reg_b_wire_en;
    tri1 sign_pipe_b_wire_en;

    tri1 addsub1_reg_wire_en;
    tri1 addsub1_pipe_wire_en;

    tri1 addsub3_reg_wire_en;
    tri1 addsub3_pipe_wire_en;

    // Stratix III only ena signals
    tri1 outround_reg_wire_en;
    tri1 outround_pipe_wire_en;
    tri1 chainout_round_reg_wire_en;
    tri1 chainout_round_pipe_wire_en;
    tri1 chainout_round_out_reg_wire_en;
    tri1 outsat_reg_wire_en;
    tri1 outsat_pipe_wire_en;
    tri1 chainout_sat_reg_wire_en;
    tri1 chainout_sat_pipe_wire_en;
    tri1 chainout_sat_out_reg_wire_en;
    tri1 scanouta_reg_wire_en;
    tri1 chainout_reg_wire_en;
    tri1 zerochainout_reg_wire_en;
    tri1 rotate_reg_wire_en;
    tri1 rotate_pipe_wire_en;
    tri1 rotate_out_reg_wire_en;
    tri1 shiftr_reg_wire_en;
    tri1 shiftr_pipe_wire_en;
    tri1 shiftr_out_reg_wire_en;
    tri1 zeroloopback_reg_wire_en;
    tri1 zeroloopback_pipe_wire_en;
    tri1 zeroloopback_out_wire_en;
    tri1 accumsload_reg_wire_en;
    tri1 accumsload_pipe_wire_en;
    // end Stratix III only ena signals
	
    // Stratix V only ena signals
    tri1 coeffsela_reg_wire_en;
    tri1 coeffselb_reg_wire_en;
    tri1 coeffselc_reg_wire_en;
    tri1 coeffseld_reg_wire_en;
    
    // end Stratix V only ena signals
    
    tri1 multiplier_reg0_wire_en;
    tri1 multiplier_reg1_wire_en;
    tri1 multiplier_reg2_wire_en;
    tri1 multiplier_reg3_wire_en;

    tri1 addnsub1_round_wire_en;
    tri1 addnsub1_round_pipe_wire_en;
    
    tri1 addnsub3_round_wire_en;
    tri1 addnsub3_round_pipe_wire_en;
    
    tri1 mult01_round_wire_en;
    tri1 mult01_saturate_wire_en;
    
    tri1 mult23_round_wire_en;
    tri1 mult23_saturate_wire_en;
        
    tri1 output_reg_wire_en;

    tri0 mult0_source_scanin_en;
    tri0 mult1_source_scanin_en;
    tri0 mult2_source_scanin_en;
    tri0 mult3_source_scanin_en;



    // ----------------
    // WIRE DECLARATION
    // ----------------

    // Wire for Clock signals
    wire input_reg_a0_wire_clk;
    wire input_reg_a1_wire_clk;
    wire input_reg_a2_wire_clk;
    wire input_reg_a3_wire_clk;

    wire input_reg_b0_wire_clk;
    wire input_reg_b1_wire_clk;
    wire input_reg_b2_wire_clk;
    wire input_reg_b3_wire_clk;
    
    wire input_reg_c0_wire_clk;
    wire input_reg_c1_wire_clk;
    wire input_reg_c2_wire_clk;
    wire input_reg_c3_wire_clk;

    wire sign_reg_a_wire_clk;
    wire sign_pipe_a_wire_clk;

    wire sign_reg_b_wire_clk;
    wire sign_pipe_b_wire_clk;

    wire addsub1_reg_wire_clk;
    wire addsub1_pipe_wire_clk;

    wire addsub3_reg_wire_clk;
    wire addsub3_pipe_wire_clk;
    
    // Stratix III only clock signals
    wire outround_reg_wire_clk;
    wire outround_pipe_wire_clk;
    wire chainout_round_reg_wire_clk;
    wire chainout_round_pipe_wire_clk;
    wire chainout_round_out_reg_wire_clk;
    wire outsat_reg_wire_clk;
    wire outsat_pipe_wire_clk;
    wire chainout_sat_reg_wire_clk;
    wire chainout_sat_pipe_wire_clk;
    wire chainout_sat_out_reg_wire_clk;
    wire scanouta_reg_wire_clk;
    wire chainout_reg_wire_clk;
    wire zerochainout_reg_wire_clk;
    wire rotate_reg_wire_clk;
    wire rotate_pipe_wire_clk;
    wire rotate_out_reg_wire_clk;
    wire shiftr_reg_wire_clk;
    wire shiftr_pipe_wire_clk;
    wire shiftr_out_reg_wire_clk;    
    wire zeroloopback_reg_wire_clk;
    wire zeroloopback_pipe_wire_clk;
    wire zeroloopback_out_wire_clk;
    wire accumsload_reg_wire_clk;
    wire accumsload_pipe_wire_clk;
    // end Stratix III only clock signals
    
    //Stratix V only clock signals
    wire coeffsela_reg_wire_clk;
    wire coeffselb_reg_wire_clk;
    wire coeffselc_reg_wire_clk;
    wire coeffseld_reg_wire_clk;
    wire  [4 * (int_width_preadder) -1:0] preadder_res_wire;
    wire [26:0] coeffsel_a_pre;
    wire [26:0] coeffsel_b_pre;
    wire [26:0] coeffsel_c_pre;
    wire [26:0] coeffsel_d_pre;
    // end Stratix V only clock signals
     
    wire multiplier_reg0_wire_clk;
    wire multiplier_reg1_wire_clk;
    wire multiplier_reg2_wire_clk;
    wire multiplier_reg3_wire_clk;

    wire output_reg_wire_clk;
    
    wire addnsub1_round_wire_clk;
    wire addnsub1_round_pipe_wire_clk;
    wire addnsub1_round_wire;
    wire addnsub1_round_pipe_wire;
    wire addnsub1_round_pre;
    wire addnsub3_round_wire_clk;
    wire addnsub3_round_pipe_wire_clk;
    wire addnsub3_round_wire;
    wire addnsub3_round_pipe_wire;
    wire addnsub3_round_pre;
    
    wire mult01_round_wire_clk;
    wire mult01_saturate_wire_clk;
    wire mult23_round_wire_clk;
    wire mult23_saturate_wire_clk;
    wire mult01_round_pre;
    wire mult01_saturate_pre;
    wire mult01_round_wire;
    wire mult01_saturate_wire;
    wire mult23_round_pre;
    wire mult23_saturate_pre;
    wire mult23_round_wire;
    wire mult23_saturate_wire;
    wire [3 : 0] mult_is_saturate_vec;
    wire [3 : 0] mult_saturate_overflow_vec;
    
    wire [4 * int_width_a -1 : 0] mult_a_pre;
    wire [4 * int_width_b -1 : 0] mult_b_pre;
    wire [int_width_c -1 : 0] mult_c_pre;

    wire [int_width_a -1 : 0] scanouta;
    wire [int_width_b -1 : 0] scanoutb; 

    wire sign_a_int;
    wire sign_b_int;

    wire addsub1_int;
    wire addsub3_int;

    wire  [4 * int_width_a -1 : 0] mult_a_wire;
    wire  [4 * int_width_b -1 : 0] mult_b_wire;
    wire  [4 * int_width_c -1 : 0] mult_c_wire;
    wire  [4 * (int_width_a + int_width_b) -1:0] mult_res_wire;
    wire sign_a_pipe_wire;
    wire sign_a_wire;
    wire sign_b_pipe_wire;
    wire sign_b_wire;
    wire addsub1_wire;
    wire addsub1_pipe_wire;
    wire addsub3_wire;
    wire addsub3_pipe_wire;

    wire ena_aclr_signa_wire;
    wire ena_aclr_signb_wire;
  
    wire [int_width_a -1 : 0] i_scanina;
    wire [int_width_b -1 : 0] i_scaninb;

    wire [(2*int_width_result - 1): 0] output_reg_wire_result;
    wire [31:0] head_result_wire;
    reg [(2*int_width_result - 1): 0] output_laten_result;
    reg [(2*int_width_result - 1): 0] result_pipe [extra_latency : 0];
    reg [(2*int_width_result - 1): 0] result_pipe1 [extra_latency : 0];
    reg [31:0] head_result;
    integer head_result_int; 

    // Stratix III only wires
    wire outround_wire;
    wire outround_pipe_wire;
    wire chainout_round_wire;
    wire chainout_round_pipe_wire;
    wire chainout_round_out_wire;
    wire outsat_wire;
    wire outsat_pipe_wire;
    wire chainout_sat_wire;
    wire chainout_sat_pipe_wire;
    wire chainout_sat_out_wire;
    wire [int_width_a -1 : 0] scanouta_wire;
    wire [int_width_result: 0] chainout_add_result;
    wire [2*int_width_result - 1: 0] adder1_res_wire;
    wire [2*int_width_result - 1: 0] adder3_res_wire;
    wire [int_width_result - 1: 0] chainout_adder_in_wire;
    wire zerochainout_wire;
    wire rotate_wire;
    wire rotate_pipe_wire;
    wire rotate_out_wire;
    wire shiftr_wire;
    wire shiftr_pipe_wire;
    wire shiftr_out_wire;
    wire zeroloopback_wire;
    wire zeroloopback_pipe_wire;
    wire zeroloopback_out_wire;
    wire accumsload_wire;
    wire accumsload_pipe_wire;
    wire [int_width_result: 0] chainout_output_wire;
    wire [int_width_result: 0] shift_rot_blk_in_wire;
    wire [int_width_result - 1: 0] loopback_out_wire;
    wire [int_width_result - 1: 0] loopback_out_wire_feedback;
    reg [int_width_result: 0] loopback_wire;
    wire [2*int_width_result - 1: 0] acc_feedback;
    
    wire [width_result - 1 : 0] result_stxiii;
    wire [width_result - 1 : 0] result_stxiii_ext;
    
    wire  [width_result - 1 : 0] result_ext; 
    wire  [width_result - 1 : 0] result_stxii_ext;
    
    // StratixV only wires
    wire [width_result - 1 : 0]accumsload_sel;
    wire [63 : 0]load_const_value;
    wire [2:0]coeffsel_a_wire;
    wire [2:0]coeffsel_b_wire;
    wire [2:0]coeffsel_c_wire;
    wire [2:0]coeffsel_d_wire;
    wire  [(int_width_a + int_width_b) -1:0] systolic_register1;
    wire  [(int_width_a + int_width_b) -1:0] systolic_register3;
    wire  [2*int_width_result - 1: 0] adder1_systolic_register0;
    wire  [2*int_width_result - 1: 0] adder1_systolic_register1;
    wire  [2*int_width_result - 1: 0] adder1_systolic;
    wire  [(width_chainin) -1:0] chainin_register1;

    //fix lint warning
    wire [chainout_input_a + width_a - 1 :0] chainout_new_dataa_temp;
    wire [chainout_input_a + width_a - 1 :0] chainout_new_dataa_temp2;
    wire [chainout_input_a + width_a - 1 :0] chainout_new_dataa_temp3;
    wire [chainout_input_a + width_a - 1 :0] chainout_new_dataa_temp4;
    wire [chainout_input_b + width_b +width_coef - 1 :0] chainout_new_datab_temp;
    wire [chainout_input_b + width_b +width_coef - 1 :0] chainout_new_datab_temp2;
    wire [chainout_input_b + width_b +width_coef - 1 :0] chainout_new_datab_temp3;
    wire [chainout_input_b + width_b +width_coef - 1 :0] chainout_new_datab_temp4;
    wire [int_width_b - 1: 0] mult_b_pre_temp;
    wire [result_pad + int_width_result + 1 - int_mult_diff_bit : 0] result_stxiii_temp;
    wire [result_pad + int_width_result - int_mult_diff_bit : 0] result_stxiii_temp2;
    wire [result_pad + int_width_result - int_mult_diff_bit : 0] result_stxiii_temp3;
    wire [result_pad + int_width_result - 1 - int_mult_diff_bit : 0] result_stxii_ext_temp;
    wire [result_pad + int_width_result - 1 - int_mult_diff_bit : 0] result_stxii_ext_temp2;
    
    wire stratixii_block;
    wire stratixiii_block;
	wire stratixv_block;
    
    //accumulator overflow fix
    integer x;
    integer i;
    
    reg and_sign_wire;
    reg or_sign_wire;
    reg [extra_sign_bit_width - 1 : 0] extra_sign_bits;
    reg msb;
    
    // -------------------
    // INTEGER DECLARATION
    // -------------------
    integer num_bit_mult0;
    integer num_bit_mult1;
    integer num_bit_mult2;
    integer num_bit_mult3;
    integer j;
    integer num_mult;
    integer num_stor;
    integer rnd_bit_cnt;
    integer sat_bit_cnt;
    integer cho_rnd_bit_cnt;
    integer cho_sat_bit_cnt;
    integer sat_all_bit_cnt;
    integer cho_sat_all_bit_cnt;
    integer lpbck_cnt;
    integer overflow_status_bit_pos; 

    // ------------------------
    // COMPONENT INSTANTIATIONS
    // ------------------------
    ALTERA_DEVICE_FAMILIES dev ();


    // -----------------------------------------------------------------------------    
    // This block checks if the two numbers to be multiplied (mult_a/mult_b) is to 
    // be interpreted as a negative number or not. If so, then two's complement is 
    // performed.
    // The numbers are then multipled. The sign of the result (positive or negative) 
    // is determined based on the sign of the two input numbers
    // ------------------------------------------------------------------------------
    
    function [(int_width_a + int_width_b - 1):0] do_multiply;
        input [32 : 0] multiplier;
        input signa_wire;
        input signb_wire;
    begin:MULTIPLY
   
        reg [int_width_a + int_width_b -1 :0] temp_mult_zero;
        reg [int_width_a + int_width_b -1 :0] temp_mult;
        reg [int_width_a -1 :0]        op_a; 
        reg [int_width_b -1 :0]        op_b; 
        reg [int_width_a -1 :0]        op_a_int; 
        reg [int_width_b -1 :0]        op_b_int; 
        reg neg_a;
        reg neg_b;
        reg temp_mult_signed;

        temp_mult_zero = 0;
        temp_mult = 0;
	
        op_a = mult_a_wire >> (multiplier * int_width_a); 
        op_b = mult_b_wire >> (multiplier * int_width_b); 
     
        neg_a = op_a[int_width_a-1] & (signa_wire);
        neg_b = op_b[int_width_b-1] & (signb_wire);

        op_a_int = (neg_a == 1) ? (~op_a + 1) : op_a;
        op_b_int = (neg_b == 1) ? (~op_b + 1) : op_b;
      
        temp_mult = op_a_int * op_b_int;
        temp_mult = (neg_a ^ neg_b) ? (temp_mult_zero - temp_mult) : temp_mult;
       
        do_multiply = temp_mult;
    end
    endfunction

    function [(int_width_a + int_width_b - 1):0] do_multiply_loopback;
        input [32 : 0] multiplier;
        input signa_wire;
        input signb_wire;
    begin:MULTIPLY
   
        reg [int_width_a + int_width_b -1 :0] temp_mult_zero;
        reg [int_width_a + int_width_b -1 :0] temp_mult;
        reg [int_width_a -1 :0]        op_a; 
        reg [int_width_b -1 :0]        op_b; 
        reg [int_width_a -1 :0]        op_a_int; 
        reg [int_width_b -1 :0]        op_b_int; 
        reg neg_a;
        reg neg_b;
        reg temp_mult_signed;

        temp_mult_zero = 0;
        temp_mult = 0;
        
        op_a = mult_a_wire >> (multiplier * int_width_a); 
        op_b = mult_b_wire >> (multiplier * int_width_b + (int_width_b - width_b)); 
        
        if(int_width_b > width_b)
            op_b[int_width_b - 1: loopback_lower_bound] = ({(loopback_input_pad){(op_b[width_b - 1])& (sign_b_pipe_wire)}});
     
        neg_a = op_a[int_width_a-1] & (signa_wire);
        neg_b = op_b[int_width_b-1] & (signb_wire);

        op_a_int = (neg_a == 1) ? (~op_a + 1) : op_a;
        op_b_int = (neg_b == 1) ? (~op_b + 1) : op_b;
      
        temp_mult = op_a_int * op_b_int;
        temp_mult = (neg_a ^ neg_b) ? (temp_mult_zero - temp_mult) : temp_mult;
       
        do_multiply_loopback = temp_mult;
    end
    endfunction
	
    function [(int_width_a + int_width_b  - 1):0] do_multiply_stratixv;
        input [32 : 0] multiplier;
        input signa_wire;
        input signb_wire;
    begin:MULTIPLY_STRATIXV
   
        reg [int_width_a + int_width_multiply_b -1 :0] temp_mult_zero;
        reg [int_width_a + int_width_b -1 :0] temp_mult;
        reg [int_width_a -1 :0]        op_a; 
        reg [int_width_multiply_b -1 :0]        op_b; 
        reg [int_width_a -1 :0]        op_a_int; 
        reg [int_width_multiply_b -1 :0]        op_b_int; 
        reg neg_a;
        reg neg_b;
        reg temp_mult_signed;

        temp_mult_zero = 0;
        temp_mult = 0;
	
        op_a = preadder_sum1a; 
        op_b = preadder_sum2a; 
     
        neg_a = op_a[int_width_a-1] & (signa_wire);
        neg_b = op_b[int_width_multiply_b-1] & (signb_wire);

        op_a_int = (neg_a == 1) ? (~op_a + 1) : op_a;
        op_b_int = (neg_b == 1) ? (~op_b + 1) : op_b;
      
        temp_mult = op_a_int * op_b_int;
        temp_mult = (neg_a ^ neg_b) ? (temp_mult_zero - temp_mult) : temp_mult;
       
        do_multiply_stratixv = temp_mult;
    end
    endfunction
   
    
// -----------------------------------------------------------------------------    
    // This block checks if the two numbers to be added (mult_a/mult_b) is to 
    // be interpreted as a negative number or not. If so, then two's complement is 
    // performed.
    // The 1st number subtracts the 2nd number. The sign of the result (positive or negative) 
    // is determined based on the sign of the two input numbers
    // ------------------------------------------------------------------------------
    
    function [2*int_width_result:0] do_sub1_level1;
        input [32:0] adder;
        input signa_wire;
        input signb_wire;
    begin:SUB_LV1
   
        reg [2*int_width_result - 1 :0] temp_sub;
        reg [2*int_width_result - 1 :0] op_a; 
        reg [2*int_width_result - 1 :0] op_b; 

        temp_sub = 0;
        unsigned_sub1_overflow = 0;


        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            op_a = temp_sum;
            op_b = mult_res_ext;
            op_a[2*int_width_result - 1:int_width_result] = {(2*int_width_result - int_width_result){op_a[int_width_result - 1] & (signa_wire | signb_wire)}}; 
            op_b[2*int_width_result - 1:int_width_result] = {(2*int_width_result - int_width_result){op_b[int_width_result - 1] & (signa_wire | signb_wire)}};  
        end
        else
        begin
            op_a = adder1_sum; 
            op_b = mult_res_ext;
            op_a[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_a[lower_range - 1] & (signa_wire | signb_wire)}}; 
            op_b[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_b[lower_range - 1] & (signa_wire | signb_wire)}};  
        end
     
        temp_sub = op_a - op_b;
        if(temp_sub[2*int_width_result - 1] == 1)
        begin
            unsigned_sub1_overflow = 1'b1;
        end
        do_sub1_level1 = temp_sub;
    end
    endfunction 
    
    function [2*int_width_result - 1:0] do_add1_level1;
        input [32:0] adder;
        input signa_wire;
        input signb_wire;
    begin:ADD_LV1
   
        reg [2*int_width_result - 1 :0] temp_add;
        reg [2*int_width_result - 1 :0] op_a; 
        reg [2*int_width_result - 1 :0] op_b; 

        temp_add = 0;

        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            op_a = temp_sum;
            op_b = mult_res_ext;
            op_a[2*int_width_result - 1:int_width_result] = {(2*int_width_result - int_width_result){op_a[int_width_result - 1] & (signa_wire | signb_wire)}}; 
            op_b[2*int_width_result - 1:int_width_result] = {(2*int_width_result - int_width_result){op_b[int_width_result - 1] & (signa_wire | signb_wire)}}; 
        end
        else
        begin
            op_a = adder1_sum; 
            op_b = mult_res_ext;
            op_a[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_a[lower_range - 1] & (signa_wire | signb_wire)}}; 
            op_b[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_b[lower_range - 1] & (signa_wire | signb_wire)}}; 
        end
        
        temp_add = op_a + op_b + chainin_register1;
        do_add1_level1 = temp_add;
    end
    endfunction    
          
    // -----------------------------------------------------------------------------    
    // This block checks if the two numbers to be added (mult_a/mult_b) is to 
    // be interpreted as a negative number or not. If so, then two's complement is 
    // performed.
    // The 1st number subtracts the 2nd number. The sign of the result (positive or negative) 
    // is determined based on the sign of the two input numbers
    // ------------------------------------------------------------------------------
    
    function [2*int_width_result - 1:0] do_sub3_level1;
        input [32:0] adder;
        input signa_wire;
        input signb_wire;
    begin:SUB3_LV1
   
        reg [2*int_width_result - 1 :0] temp_sub;
        reg [2*int_width_result - 1 :0] op_a; 
        reg [2*int_width_result - 1 :0] op_b; 

        temp_sub = 0;
        unsigned_sub3_overflow = 0;

        op_a = adder3_sum; 
        op_b = mult_res_ext;
        
        op_a[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_a[lower_range - 1] & (signa_wire | signb_wire)}}; 
        op_b[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_b[lower_range - 1] & (signa_wire | signb_wire)}};  
        
        temp_sub = op_a - op_b ;
        if(temp_sub[2*int_width_result - 1] == 1)
        begin
            unsigned_sub3_overflow = 1'b1;
        end
        do_sub3_level1 = temp_sub;
    end
    endfunction 
    
    function [2*int_width_result - 1:0] do_add3_level1;
        input [32:0] adder;
        input signa_wire;
        input signb_wire;
        begin:ADD3_LV1
   
        reg [2*int_width_result - 1 :0] temp_add;
        reg [2*int_width_result - 1 :0] op_a; 
        reg [2*int_width_result - 1 :0] op_b; 

        temp_add = 0;

        op_a = adder3_sum; 
        op_b = mult_res_ext;
        
        op_a[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_a[lower_range - 1] & (signa_wire | signb_wire)}}; 
        op_b[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_b[lower_range - 1] & (signa_wire | signb_wire)}};  
        
        temp_add = op_a + op_b;
        do_add3_level1 = temp_add;
    end
    endfunction    
    
// -----------------------------------------------------------------------------    
    // This block checks if the two numbers to be added (data_a/data_b) is to 
    // be interpreted as a negative number or not. If so, then two's complement is 
    // performed.
    // The 1st number subtracts the 2nd number. The sign of the result (positive or negative) 
    // is determined based on the sign of the two input numbers
    // ------------------------------------------------------------------------------
    
    function [2*int_width_result - 1:0] do_preadder_sub;
        input [32:0] adder;
        input signa_wire;
        input signb_wire;
    begin:PREADDER_SUB
   
        reg [2*int_width_result - 1 :0] temp_sub;
        reg [2*int_width_result - 1 :0] op_a; 
        reg [2*int_width_result - 1 :0] op_b; 

        temp_sub = 0;

        op_a = mult_a_wire >> (adder * int_width_a); 
   		op_b = mult_b_wire >> (adder * int_width_b); 
        op_a[2*int_width_result - 1:width_a] = {(2*int_width_result - width_a){op_a[width_a - 1] & (signa_wire | signb_wire)}}; 
        op_b[2*int_width_result - 1:width_b] = {(2*int_width_result - width_b){op_b[width_b - 1] & (signa_wire | signb_wire)}};  

        temp_sub = op_a - op_b;
	    do_preadder_sub = temp_sub;
    end
    endfunction 
    
    function [2*int_width_result - 1:0] do_preadder_add;
        input [32:0] adder;
        input signa_wire;
        input signb_wire;
    begin:PREADDER_ADD
   
        reg [2*int_width_result - 1 :0] temp_add;
        reg [2*int_width_result - 1 :0] op_a; 
        reg [2*int_width_result - 1 :0] op_b; 

        temp_add = 0;

        op_a = mult_a_wire >> (adder * int_width_a); 
   		op_b = mult_b_wire >> (adder * int_width_b); 
        op_a[2*int_width_result - 1:width_a] = {(2*int_width_result - width_a){op_a[width_a - 1] & (signa_wire | signb_wire)}}; 
        op_b[2*int_width_result - 1:width_b] = {(2*int_width_result - width_b){op_b[width_b - 1] & (signa_wire | signb_wire)}}; 
        
        temp_add = op_a + op_b;
        do_preadder_add = temp_add;
    end
    endfunction  
    
    // --------------------------------------------------------------
    // initialization block of all the internal signals and registers
    // --------------------------------------------------------------
    initial
    begin
        // Checking for invalid parameters, in case Wizard is bypassed (hand-modified).
        if (number_of_multipliers > 4)
        begin
            $display("Altmult_add does not currently support NUMBER_OF_MULTIPLIERS > 4");
            $stop;
        end        
        if (number_of_multipliers <= 0)
        begin
            $display("NUMBER_OF_MULTIPLIERS must be greater than 0.");
            $stop;
        end        
       
       
        if (width_a <= 0)
        begin
            $display("Error: width_a must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        if (width_b <= 0)
        begin
            $display("Error: width_b must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
		if (width_c < 0)
        begin
            $display("Error: width_c must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        if (width_result <= 0)
        begin
            $display("Error: width_result must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_a0 != "DATAA") &&
            (input_source_a0 != "SCANA") &&
            (input_source_a0 != "PREADDER") &&
            (input_source_a0 != "VARIABLE"))
        begin
            $display("Error: The INPUT_SOURCE_A0 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_a1 != "DATAA") &&
            (input_source_a1 != "SCANA") &&
            (input_source_a1 != "PREADDER") &&
            (input_source_a1 != "VARIABLE"))
        begin
            $display("Error: The INPUT_SOURCE_A1 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_a2 != "DATAA") &&
            (input_source_a2 != "SCANA") &&
            (input_source_a2 != "PREADDER") &&
            (input_source_a2 != "VARIABLE"))
        begin
            $display("Error: The INPUT_SOURCE_A2 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_a3 != "DATAA") &&
            (input_source_a3 != "SCANA") &&
            (input_source_a3 != "PREADDER") &&
            (input_source_a3 != "VARIABLE"))
        begin
            $display("Error: The INPUT_SOURCE_A3 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_b0 != "DATAB") &&
            (input_source_b0 != "SCANB") &&
            (input_source_b0 != "PREADDER") &&
            (input_source_b0 != "DATAC") &&
            (input_source_b0 != "VARIABLE") && (input_source_b0 != "LOOPBACK"))
        begin
            $display("Error: The INPUT_SOURCE_B0 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_b1 != "DATAB") &&
            (input_source_b1 != "SCANB") &&
            (input_source_b1 != "PREADDER") &&
            (input_source_b1 != "VARIABLE"))
        begin
            $display("Error: The INPUT_SOURCE_B1 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_b2 != "DATAB") &&
            (input_source_b2 != "SCANB") &&
            (input_source_b2 != "PREADDER") &&
            (input_source_b2 != "DATAC") &&
            (input_source_b2 != "VARIABLE"))
        begin
            $display("Error: The INPUT_SOURCE_B2 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_b3 != "DATAB") &&
            (input_source_b3 != "SCANB") &&
            (input_source_b3 != "PREADDER") &&
            (input_source_b3 != "VARIABLE"))
        begin
            $display("Error: The INPUT_SOURCE_B3 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_a0 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_a1 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_a2 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_a3 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_b0 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_b1 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_b2 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_b3 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dedicated_multiplier_circuitry != "AUTO") && 
            (dedicated_multiplier_circuitry != "YES") && 
            (dedicated_multiplier_circuitry != "NO"))
        begin
            $display("Error: The DEDICATED_MULTIPLIER_CIRCUITRY parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) &&
            ((multiplier01_rounding == "YES") || (multiplier23_rounding == "YES") ||
            (multiplier01_rounding == "VARIABLE") || (multiplier23_rounding == "VARIABLE")))
        begin
            $display("Error: Rounding for multiplier is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) &&
            ((adder1_rounding == "YES") || (adder3_rounding == "YES") ||
            (adder1_rounding == "VARIABLE") || (adder3_rounding == "VARIABLE")))
        begin
            $display("Error: Rounding for adder is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) &&
            ((multiplier01_saturation == "YES") || (multiplier23_saturation == "YES") ||
            (multiplier01_saturation == "VARIABLE") || (multiplier23_saturation == "VARIABLE")))
        begin
            $display("Error: Saturation for multiplier is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO") &&
            (multiplier01_rounding == "NO") && (multiplier23_rounding == "NO")
            && (output_saturation == "NO") && (output_rounding == "NO") && (chainout_rounding == "NO") 
            && (chainout_saturation == "NO") && (chainout_adder =="NO") && (shift_mode == "NO"))
        begin
            if (int_width_result != width_result)
            begin
                $display ("Error: Internal parameter setting of int_width_result is illegal");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
            end
            
            if (int_mult_diff_bit != 0)
            begin
                $display ("Error: Internal parameter setting of int_mult_diff_bit is illegal");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
            end
        
        end
        else
        begin
            if (((width_a < 18) && (int_width_a != 18)) ||
                ((width_a >= 18) && (int_width_a != width_a)))
            begin
                $display ("Error: Internal parameter setting of int_width_a is illegal");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
            end
           
            
            if (((width_b < 18) && (int_width_b != 18)) ||
                ((width_b >= 18) && (int_width_b != width_b)))
            begin
                $display ("Error: Internal parameter setting of int_width_b is illegal");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
            end
                      
            if ((chainout_adder == "NO") && (shift_mode == "NO"))
            begin
                if ((int_width_result > (int_width_a + int_width_b)))
                begin
                    if (int_width_result != (width_result + width_result - int_width_a - int_width_b))
                    begin
                        $display ("Error: Internal parameter setting for int_width_result is illegal");
                        $display("Time: %0t  Instance: %m", $time);
                        $stop;
                    end
                end
                else
                    if ((int_width_result != (int_width_a + int_width_b)))
                    begin
                        $display ("Error: Internal parameter setting for int_width_result is illegal");
                        $display("Time: %0t  Instance: %m", $time);
                        $stop;
                    end
    
                if ((int_mult_diff_bit != (int_width_a - width_a + int_width_b - width_b)))
                begin
                    $display ("Error: Internal parameter setting of int_mult_diff_bit is illegal");
                    $display("Time: %0t  Instance: %m", $time);
                    $stop;
                end
            end
        end
        
        // Stratix III parameters checking
        if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) && ((output_rounding == "YES") ||
            (output_rounding == "VARIABLE") || (chainout_rounding == "YES") || (chainout_rounding == "VARIABLE")))
        begin
            $display ("Error: Output rounding and/or Chainout rounding are not supported for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) && ((output_saturation == "YES") ||
            (output_saturation == "VARIABLE") || (chainout_saturation == "YES") || (chainout_saturation == "VARIABLE")))
        begin
            $display ("Error: Output saturation and/or Chainout saturation are not supported for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) && (input_source_b0 == "LOOPBACK"))
        begin
            $display ("Error: Loopback mode is not supported for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) && (chainout_adder == "YES"))
        begin
            $display("Error: Chainout mode is not supported for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) && (shift_mode != "NO"))
        begin
            $display ("Error: shift and rotate modes are not supported for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) && (accumulator == "YES"))
        begin
            $display ("Error: Accumulator mode is not supported for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((output_rounding != "YES") && (output_rounding != "NO") && (output_rounding != "VARIABLE"))
        begin
            $display ("Error: The OUTPUT_ROUNDING parameter is set to an invalid value");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((chainout_rounding != "YES") && (chainout_rounding != "NO") && (chainout_rounding != "VARIABLE"))
        begin
            $display ("Error: The CHAINOUT_ROUNDING parameter is set to an invalid value");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((output_saturation != "YES") && (output_saturation != "NO") && (output_saturation != "VARIABLE"))
        begin
            $display ("Error: The OUTPUT_SATURATION parameter is set to an invalid value");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((chainout_saturation != "YES") && (chainout_saturation != "NO") && (chainout_saturation != "VARIABLE"))
        begin
            $display ("Error: The CHAINOUT_SATURATION parameter is set to an invalid value");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((output_rounding != "NO") && ((output_round_type != "NEAREST_INTEGER") && (output_round_type != "NEAREST_EVEN")))
        begin
            $display ("Error: The OUTPUT_ROUND_TYPE parameter is set to an invalid value");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((output_saturation != "NO") && ((output_saturate_type != "ASYMMETRIC") && (output_saturate_type != "SYMMETRIC")))
        begin
            $display ("Error: The OUTPUT_SATURATE_TYPE parameter is set to an invalid value");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if ((shift_mode != "NO") && (shift_mode != "LEFT") && (shift_mode != "RIGHT") && (shift_mode != "ROTATION") &&
            (shift_mode != "VARIABLE"))
        begin
            $display ("Error: The SHIFT_MODE parameter is set to an invalid value");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        
        if (accumulator == "YES")
        begin
            if ((accum_direction != "ADD") && (accum_direction != "SUB"))
            begin
                $display ("Error: The ACCUM_DIRECTION parameter is set to an invalid value");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
            end
        end
        
        if (dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 1)
        begin
            if ((output_rounding == "YES") && (accumulator == "YES"))
            begin
                $display ("Error: In accumulator mode, the OUTPUT_ROUNDING parameter has to be set to VARIABLE if used");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
            end
            
            if ((chainout_adder == "YES") && (output_rounding != "NO"))
            begin
                $display ("Error: In chainout mode, output rounding cannot be turned on");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
            end
        end
        
		if(dev.FEATURE_FAMILY_STRATIXV(intended_device_family) ==1 && preadder_mode != "SIMPLE")
		begin
				$display ("Error: Stratix V simulation model not support other mode beside simple mode in the current Quartus II Version");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
		end
		
     
              
        temp_sum_reg = 0;
        mult_a_reg = 0; 
        mult_b_reg   = 0;
        mult_c_reg   = 0;
        mult_res_reg = 0;

        sign_a_reg  =   ((port_signa == "PORT_CONNECTIVITY")? 
                        (representation_a != "UNUSED" ? (representation_a == "SIGNED" ? 1 : 0) : 0) :
                        (port_signa == "PORT_USED")? 0 :
                        (port_signa == "PORT_UNUSED")? (representation_a == "SIGNED" ? 1 : 0) : 0);
                        
        sign_a_pipe_reg =   ((port_signa == "PORT_CONNECTIVITY")?
                            (representation_a != "UNUSED" ? (representation_a == "SIGNED" ? 1 : 0) : 0) :
                            (port_signa == "PORT_USED")? 0 :
                            (port_signa == "PORT_UNUSED")? (representation_a == "SIGNED" ? 1 : 0) : 0);
                             
        sign_b_reg  =   ((port_signb == "PORT_CONNECTIVITY")?
                        (representation_b != "UNUSED" ? (representation_b == "SIGNED" ? 1 : 0) : 0) :
                        (port_signb == "PORT_USED")? 0 :
                        (port_signb == "PORT_UNUSED")? (representation_b == "SIGNED" ? 1 : 0) : 0);
                         
        sign_b_pipe_reg =   ((port_signb == "PORT_CONNECTIVITY")?
                            (representation_b != "UNUSED" ? (representation_b == "SIGNED" ? 1 : 0) : 0) :
                            (port_signb == "PORT_USED")? 0 :
                            (port_signb == "PORT_UNUSED")? (representation_b == "SIGNED" ? 1 : 0) : 0);  
            
        addsub1_reg  =  ((port_addnsub1 == "PORT_CONNECTIVITY")?
                        (multiplier1_direction != "UNUSED" ? (multiplier1_direction == "ADD" ? 1 : 0) : 0) :
                        (port_addnsub1 == "PORT_USED")? 0 :
                        (port_addnsub1 == "PORT_UNUSED")? (multiplier1_direction == "ADD" ? 1 : 0) : 0);
            
        addsub1_pipe_reg = addsub1_reg; 
        
        addsub3_reg  =  ((port_addnsub3 == "PORT_CONNECTIVITY")?
                        (multiplier3_direction != "UNUSED" ? (multiplier3_direction == "ADD" ? 1 : 0) : 0) :
                        (port_addnsub3 == "PORT_USED")? 0 :
                        (port_addnsub3 == "PORT_UNUSED")? (multiplier3_direction == "ADD" ? 1 : 0) : 0);
                        
        addsub3_pipe_reg = addsub3_reg;

        // StratixII related reg type initialization

        mult0_round_out = 0;
        mult0_saturate_out = 0;
        mult0_result = 0;
        mult0_saturate_overflow = 0;

        mult1_round_out = 0;
        mult1_saturate_out = 0;
        mult1_result = 0;
        mult1_saturate_overflow = 0;

        mult_saturate_overflow_reg [3] = 0;
        mult_saturate_overflow_reg [2] = 0;
        mult_saturate_overflow_reg [1] = 0;
        mult_saturate_overflow_reg [0] = 0;
        
        mult_saturate_overflow_pipe_reg [3] = 0;
        mult_saturate_overflow_pipe_reg [2] = 0;
        mult_saturate_overflow_pipe_reg [1] = 0;
        mult_saturate_overflow_pipe_reg [0] = 0;
        head_result = 0;

        // Stratix III reg type initialization
        chainout_overflow_status = 0;
        overflow_status = 0;
        outround_reg = 0;
        outround_pipe_reg = 0;
        chainout_round_reg = 0;
        chainout_round_pipe_reg = 0;
        chainout_round_out_reg = 0;
        outsat_reg = 0;
        outsat_pipe_reg = 0;
        chainout_sat_reg = 0;
        chainout_sat_pipe_reg = 0;
        chainout_sat_out_reg = 0;
        zerochainout_reg = 0;
        rotate_reg = 0;
        rotate_pipe_reg = 0;
        rotate_out_reg = 0;
        shiftr_reg = 0;
        shiftr_pipe_reg = 0;
        shiftr_out_reg = 0;
        zeroloopback_reg = 0;
        zeroloopback_pipe_reg = 0;
        zeroloopback_out_reg = 0;
        accumsload_reg = 0;
        accumsload_pipe_reg = 0;

        scanouta_reg = 0;
        adder1_reg = 0;
        adder3_reg = 0;
        adder1_sum = 0;
        adder3_sum = 0;
        adder1_res_ext = 0;
        adder3_res_ext = 0;
        round_block_result = 0;
        sat_block_result = 0;
        round_sat_blk_res = 0;
        chainout_round_block_result = 0;
        chainout_sat_block_result = 0;
        round_sat_in_result = 0;
        chainout_rnd_sat_blk_res = 0;
        chainout_output_reg = 0;
        chainout_final_out = 0;
        shift_rot_result = 0;
        acc_feedback_reg = 0;
        chout_shftrot_reg = 0;
    
        overflow_status = 0;
        overflow_stat_reg = 0;
        chainout_overflow_status = 0;
        chainout_overflow_stat_reg = 0;
        stick_bits_or = 0;
        cho_stick_bits_or = 0;
        accum_overflow = 0;
        accum_overflow_reg = 0;
        unsigned_sub1_overflow = 0;
        unsigned_sub3_overflow = 0;
        unsigned_sub1_overflow_reg = 0;
        unsigned_sub3_overflow_reg = 0;
        unsigned_sub1_overflow_mult_reg = 0;
        unsigned_sub3_overflow_mult_reg = 0;
        
        preadder_sum1a = 0;
        preadder_sum2a = 0;
        preadder_res_0 = 0;
        preadder_res_1 = 0;
        preadder_res_2 = 0;
        preadder_res_3 = 0;
        coeffsel_a_reg = 0;
        coeffsel_b_reg = 0;
        coeffsel_c_reg = 0;
        coeffsel_d_reg = 0;
        adder1_res_reg_0 = 0;
        adder1_res_reg_1 = 0;
		round_sat_in_reg = 0;
		chainin_reg = 0;
		
        for ( num_stor = extra_latency; num_stor >= 0; num_stor = num_stor - 1 )
        begin
            result_pipe[num_stor] = {int_width_result{1'b0}};
            result_pipe1[num_stor] = {int_width_result{1'b0}};
            overflow_stat_pipe_reg = 1'b0;
            unsigned_sub1_overflow_pipe_reg <= 1'b0;
            unsigned_sub3_overflow_pipe_reg <= 1'b0;
            accum_overflow_stat_pipe_reg = 1'b0;
        end
        
        for (lpbck_cnt = 0; lpbck_cnt <= int_width_result; lpbck_cnt = lpbck_cnt+1)
        begin
            loopback_wire_reg[lpbck_cnt] = 1'b0;
        end

    end // end initialization block

    assign stratixii_block = dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) || (stratixiii_block && (dedicated_multiplier_circuitry=="NO"));
    assign stratixiii_block = dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) && (dedicated_multiplier_circuitry!="NO");
	
	//SPR 356362: Force stratixv_block to false as StratixV does not support simulation atom
    assign stratixv_block = dev.FEATURE_FAMILY_STRATIXV(intended_device_family) && (dedicated_multiplier_circuitry!="NO") && 1'b0; 
    
    assign signa_z = signa;
    assign signb_z = signb;
    assign addnsub1_z = addnsub1;
    assign addnsub3_z = addnsub3;
    assign scanina_z[width_a - 1 : 0] = scanina[width_a - 1 : 0];
    assign scaninb_z[width_b - 1 : 0] = scaninb[width_b - 1 : 0];

    always @(dataa or datab)
    begin
        dataa_reg[(number_of_multipliers * width_a) - 1:0] = dataa[(number_of_multipliers* width_a) -1:0];
        datab_reg[(number_of_multipliers * width_b) - 1:0] = datab[(number_of_multipliers * width_b) - 1:0];
    end
     
    assign new_dataa_int[int_width_a - 1:int_width_a - width_a] = (number_of_multipliers >= 1) ? 
                                                                    dataa_reg[width_a - 1:0]: {width_a{1'b0}};

    assign chainout_new_dataa_temp =  ((sign_a_int == 1) ?
                                        {{(chainout_input_a) {dataa_reg[width_a - 1]}}, dataa_reg[width_a - 1:0]} :
                                        {{(chainout_input_a) {1'b0}}, dataa_reg[width_a - 1:0]});

    assign chainout_new_dataa_int[int_width_a -1:0] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                        (((number_of_multipliers >= 1) && (width_result > width_a + width_b + 8) && (width_a < 18)) ?
                                                        chainout_new_dataa_temp[int_width_a - 1 : 0] :
                                                        {int_width_a{1'b0}}) : {int_width_a{1'b0}};
                                                                  
    assign new_dataa_int[(2 * int_width_a) - 1: (2 * int_width_a) - width_a] = (number_of_multipliers >= 2)? 
                                                                                dataa_reg[(2 * width_a) - 1: width_a] : {width_a{1'b0}};
   
    assign chainout_new_dataa_temp2 = ((sign_a_int == 1) ?
                                    {{(chainout_input_a) {dataa_reg[(2*width_a) - 1]}}, dataa_reg[(2*width_a) - 1:width_a]} :
                                    {{(chainout_input_a) {1'b0}}, dataa_reg[(2*width_a) - 1:width_a]});

    assign chainout_new_dataa_int[(2 *int_width_a) - 1: int_width_a] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                                        (((number_of_multipliers >= 2) && (width_result > width_a + width_b + 8) && (width_a < 18)) ?
                                                                        chainout_new_dataa_temp2[int_width_a - 1 : 0] :
                                                                        {int_width_a{1'b0}}) : {int_width_a{1'b0}};
                                                                        
    assign new_dataa_int[(3 * int_width_a) - 1: (3 * int_width_a) - width_a] = (number_of_multipliers >= 3)? 
                                                                                dataa_reg[(3 * width_a) - 1:(2 * width_a)] : {width_a{1'b0}};
                                                                                
    assign chainout_new_dataa_temp3 = ((sign_a_int == 1) ?
                                        {{(chainout_input_a) {dataa_reg[(3*width_a) - 1]}}, dataa_reg[(3*width_a) - 1:(2*width_a)]} :
                                        {{(chainout_input_a) {1'b0}}, dataa_reg[(3*width_a) - 1:(2*width_a)]});

    assign chainout_new_dataa_int[(3 *int_width_a) - 1: (2*int_width_a)] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                                            (((number_of_multipliers >= 3) && (width_result > width_a + width_b + 8) && (width_a < 18)) ?
                                                                            chainout_new_dataa_temp3[int_width_a - 1 : 0]:
                                                                            {int_width_a{1'b0}}) : {int_width_a{1'b0}};

    assign new_dataa_int[(4 * int_width_a) - 1: (4 * int_width_a) - width_a] = (number_of_multipliers >= 4) ? 
                                                                                dataa_reg[(4 * width_a) - 1:(3 * width_a)] : {width_a{1'b0}};
                                                                                
    assign chainout_new_dataa_temp4 = ((sign_a_int == 1) ?
                                    {{(chainout_input_a) {dataa_reg[(4*width_a) - 1]}}, dataa_reg[(4*width_a) - 1:(3*width_a)]} :
                                    {{(chainout_input_a) {1'b0}}, dataa_reg[(4*width_a) - 1:(3*width_a)]});

    assign chainout_new_dataa_int[(4 *int_width_a) - 1: (3*int_width_a)] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                                            (((number_of_multipliers >= 4) && (width_result > width_a + width_b + 8) && (width_a < 18)) ?
                                                                            chainout_new_dataa_temp4[int_width_a - 1 : 0]:
                                                                            {int_width_a{1'b0}}) : {int_width_a{1'b0}};

    assign new_datab_int[int_width_b - 1:int_width_b - width_b] = (number_of_multipliers >= 1) ? 
                                                                    datab_reg[width_b - 1:0]: {width_b{1'b0}};
                                                                    
    assign chainout_new_datab_temp = ((sign_b_int == 1) ?
                                    {{(chainout_input_b) {datab_reg[width_b - 1]}}, datab_reg[width_b - 1:0]} :
                                    {{(chainout_input_b) {1'b0}}, datab_reg[width_b - 1:0]});

    assign chainout_new_datab_int[int_width_b -1:0] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                        (((number_of_multipliers >= 1) && (width_result > width_a + width_b + 8) && (width_b < 18)) ? 
                                                        chainout_new_datab_temp[int_width_b -1:0]:
                                                        {int_width_b{1'b0}}) : {int_width_b{1'b0}};
                                                                  
    assign new_datab_int[(2 * int_width_b) - 1: (2 * int_width_b) - width_b] = (number_of_multipliers >= 2)? 
                                                                                datab_reg[(2 * width_b) - 1:width_b]:{width_b{1'b0}};
                                                                                
    assign chainout_new_datab_temp2 = ((sign_b_int == 1) ?
                                    {{(chainout_input_b) {datab_reg[(2*width_b) - 1]}}, datab_reg[(2*width_b) - 1:width_b]} :
                                    {{(chainout_input_b) {1'b0}}, datab_reg[(2*width_b) - 1:width_b]});

    assign chainout_new_datab_int[(2*int_width_b) -1:int_width_b] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                                        (((number_of_multipliers >= 2) && (width_result > width_a + width_b + 8) && (width_b < 18)) ? 
                                                                        chainout_new_datab_temp2[int_width_b -1:0]:
                                                                        {int_width_b{1'b0}}) : {int_width_b{1'b0}};

    assign new_datab_int[(3 * int_width_b) - 1: (3 * int_width_b) - width_b] = (number_of_multipliers >= 3)? 
                                                                                datab_reg[(3 * width_b) - 1:(2 * width_b)] : {width_b{1'b0}};
                                                                                
    assign chainout_new_datab_temp3 = ((sign_b_int == 1) ?
                                    {{(chainout_input_b) {datab_reg[(3*width_b) - 1]}}, datab_reg[(3*width_b) - 1:(2*width_b)]} :
                                    {{(chainout_input_b) {1'b0}}, datab_reg[(3*width_b) - 1:(2*width_b)]});

    assign chainout_new_datab_int[(3*int_width_b) -1:(2*int_width_b)] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                                        (((number_of_multipliers >= 3) && (width_result > width_a + width_b + 8) && (width_b < 18)) ? 
                                                                        chainout_new_datab_temp3[int_width_b -1:0]:
                                                                        {int_width_b{1'b0}}) : {int_width_b{1'b0}};

    assign new_datab_int[(4 * int_width_b) - 1: (4 * int_width_b) - width_b] = (number_of_multipliers >= 4) ? 
                                                                                datab_reg[(4 * width_b) - 1:(3 * width_b)] : {width_b{1'b0}};

    assign chainout_new_datab_temp4 = ((sign_b_int == 1) ?
                                    {{(chainout_input_b) {datab_reg[(4*width_b) - 1]}}, datab_reg[(4*width_b) - 1:(3*width_b)]} :
                                    {{(chainout_input_b) {1'b0}}, datab_reg[(4*width_b) - 1:(3*width_b)]});

    assign chainout_new_datab_int[(4*int_width_b) -1:(3*int_width_b)] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                                        (((number_of_multipliers >= 4) && (width_result > width_a + width_b + 8) && (width_b < 18)) ? 
                                                                        chainout_new_datab_temp4[int_width_b -1:0]:
                                                                        {int_width_b{1'b0}}) : {int_width_b{1'b0}};

    assign dataa_int[number_of_multipliers * int_width_a-1:0] = (((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO") &&
                                                                (multiplier01_rounding == "NO") && (multiplier23_rounding == "NO") &&
                                                                (output_rounding == "NO") && (output_saturation == "NO") &&
                                                                (chainout_rounding == "NO") && (chainout_saturation == "NO") && (chainout_adder == "NO") && (input_source_b0 != "LOOPBACK"))? 
                                                                dataa[number_of_multipliers * width_a - 1:0]:
                                                                ((width_a < 18) ? 
                                                                (((chainout_adder == "YES") && (width_result > width_a + width_b + 8)) ?
                                                                chainout_new_dataa_int[number_of_multipliers * int_width_a-1:0] :
                                                                new_dataa_int[number_of_multipliers * int_width_a-1:0]) : dataa[number_of_multipliers * width_a - 1:0])); 
   
    assign datab_int[number_of_multipliers * int_width_b-1:0] = (((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO") &&
                                                                (multiplier01_rounding == "NO") && (multiplier23_rounding == "NO") &&
                                                                (output_rounding == "NO") && (output_saturation == "NO") &&
                                                                (chainout_rounding == "NO") && (chainout_saturation == "NO") && (chainout_adder == "NO") && (input_source_b0 != "LOOPBACK"))? 
                                                                datab[number_of_multipliers * width_b - 1:0]:
                                                                ((width_b < 18)? 
                                                                (((chainout_adder == "YES") && (width_result > width_a + width_b + 8)) ?
                                                                chainout_new_datab_int[number_of_multipliers * int_width_b-1:0] :
                                                                new_datab_int[number_of_multipliers * int_width_b - 1:0]) : datab[number_of_multipliers * width_b - 1:0])); 
	
	assign datac_int[number_of_multipliers * int_width_c-1:0] = ((stratixv_block == 1 && (preadder_mode == "INPUT"))? datac[number_of_multipliers * int_width_c - 1:0]: 0);
    
    assign addnsub1_round_pre = addnsub1_round;
    assign addnsub3_round_pre = addnsub3_round;
    assign mult01_round_pre = mult01_round;
    assign mult01_saturate_pre = mult01_saturation;
    assign mult23_round_pre = mult23_round;
    assign mult23_saturate_pre = mult23_saturation;

    // ---------------------------------------------------------
    // This block updates the output port for each multiplier's 
    // saturation port only if port_mult0_is_saturated is set to used
    // ---------------------------------------------------------


    assign mult0_is_saturated = (port_mult0_is_saturated == "UNUSED")? 1'bz:
                                (port_mult0_is_saturated == "USED")? mult_is_saturate_vec[0]: 1'bz;

    assign mult1_is_saturated = (port_mult1_is_saturated == "UNUSED")? 1'bz:
                                (port_mult1_is_saturated == "USED")? mult_is_saturate_vec[1]: 1'bz;

    assign mult2_is_saturated = (port_mult2_is_saturated == "UNUSED")? 1'bz:
                                (port_mult2_is_saturated == "USED")? mult_is_saturate_vec[2]: 1'bz;

    assign mult3_is_saturated = (port_mult3_is_saturated == "UNUSED")? 1'bz:
                                (port_mult3_is_saturated == "USED")? mult_is_saturate_vec[3]: 1'bz;

    assign sourcea_wire[number_of_multipliers - 1 : 0] = sourcea[number_of_multipliers - 1 : 0];
    
    assign sourceb_wire[number_of_multipliers - 1 : 0] = sourceb[number_of_multipliers - 1 : 0]; 


    // ---------------------------------------------------------
    // This block updates the internal clock signals accordingly
    // every time the global clock signal changes state
    // ---------------------------------------------------------

    assign input_reg_a0_wire_clk =  (input_register_a0 == "CLOCK0")? clock0:
                                    (input_register_a0 == "UNREGISTERED")? 1'b0:
                                    (input_register_a0 == "CLOCK1")? clock1:
                                    (input_register_a0 == "CLOCK2")? clock2:
                                    (input_register_a0 == "CLOCK3")? clock3: 1'b0;


    assign input_reg_a1_wire_clk =  (input_register_a1 == "CLOCK0")? clock0:
                                    (input_register_a1 == "UNREGISTERED")? 1'b0:
                                    (input_register_a1 == "CLOCK1")? clock1:
                                    (input_register_a1 == "CLOCK2")? clock2:
                                    (input_register_a1 == "CLOCK3")? clock3: 1'b0;


    assign input_reg_a2_wire_clk =  (input_register_a2 == "CLOCK0")? clock0:
                                    (input_register_a2 == "UNREGISTERED")? 1'b0:
                                    (input_register_a2 == "CLOCK1")? clock1:
                                    (input_register_a2 == "CLOCK2")? clock2:
                                    (input_register_a2 == "CLOCK3")? clock3: 1'b0;



    assign input_reg_a3_wire_clk =  (input_register_a3 == "CLOCK0")? clock0:
                                    (input_register_a3 == "UNREGISTERED")? 1'b0:
                                    (input_register_a3 == "CLOCK1")? clock1:
                                    (input_register_a3 == "CLOCK2")? clock2:
                                    (input_register_a3 == "CLOCK3")? clock3: 1'b0;


    assign input_reg_b0_wire_clk =  (input_register_b0 == "CLOCK0")? clock0:
                                    (input_register_b0 == "UNREGISTERED")? 1'b0:
                                    (input_register_b0 == "CLOCK1")? clock1:
                                    (input_register_b0 == "CLOCK2")? clock2:
                                    (input_register_b0 == "CLOCK3")? clock3: 1'b0;
                                 

    assign input_reg_b1_wire_clk =  (input_register_b1 == "CLOCK0")? clock0:
                                    (input_register_b1 == "UNREGISTERED")? 1'b0:
                                    (input_register_b1 == "CLOCK1")? clock1:
                                    (input_register_b1 == "CLOCK2")? clock2:
                                    (input_register_b1 == "CLOCK3")? clock3: 1'b0;
                                   

    assign input_reg_b2_wire_clk =  (input_register_b2 == "CLOCK0")? clock0:
                                    (input_register_b2 == "UNREGISTERED")? 1'b0:
                                    (input_register_b2 == "CLOCK1")? clock1:
                                    (input_register_b2 == "CLOCK2")? clock2:
                                    (input_register_b2 == "CLOCK3")? clock3: 1'b0;


    assign input_reg_b3_wire_clk =  (input_register_b3 == "CLOCK0")? clock0:
                                    (input_register_b3 == "UNREGISTERED")? 1'b0:
                                    (input_register_b3 == "CLOCK1")? clock1:
                                    (input_register_b3 == "CLOCK2")? clock2:
                                    (input_register_b3 == "CLOCK3")? clock3: 1'b0;
                                   
	assign input_reg_c0_wire_clk =  (input_register_c0 == "CLOCK0")? clock0:
                                    (input_register_c0 == "UNREGISTERED")? 1'b0:
                                    (input_register_c0 == "CLOCK1")? clock1:
                                    (input_register_c0 == "CLOCK2")? clock2: 1'b0;
                                 

    assign input_reg_c1_wire_clk =  (input_register_c1 == "CLOCK0")? clock0:
                                    (input_register_c1 == "UNREGISTERED")? 1'b0:
                                    (input_register_c1 == "CLOCK1")? clock1:
                                    (input_register_c1 == "CLOCK2")? clock2: 1'b0;
                                   

    assign input_reg_c2_wire_clk =  (input_register_c2 == "CLOCK0")? clock0:
                                    (input_register_c2 == "UNREGISTERED")? 1'b0:
                                    (input_register_c2 == "CLOCK1")? clock1:
                                    (input_register_c2 == "CLOCK2")? clock2: 1'b0;


    assign input_reg_c3_wire_clk =  (input_register_c3 == "CLOCK0")? clock0:
                                    (input_register_c3 == "UNREGISTERED")? 1'b0:
                                    (input_register_c3 == "CLOCK1")? clock1:
                                    (input_register_c3 == "CLOCK2")? clock2: 1'b0;	                            

    assign addsub1_reg_wire_clk =   (addnsub_multiplier_register1 == "CLOCK0")? clock0:
                                    (addnsub_multiplier_register1 == "UNREGISTERED")? 1'b0: 
                                    (addnsub_multiplier_register1 == "CLOCK1")? clock1:
                                    (addnsub_multiplier_register1 == "CLOCK2")? clock2:
                                    (addnsub_multiplier_register1 == "CLOCK3")? clock3: 1'b0;
                                    

    assign addsub1_pipe_wire_clk =  (addnsub_multiplier_pipeline_register1 == "CLOCK0")? clock0:
                                    (addnsub_multiplier_pipeline_register1 == "UNREGISTERED")? 1'b0: 
                                    (addnsub_multiplier_pipeline_register1 == "CLOCK1")? clock1:
                                    (addnsub_multiplier_pipeline_register1 == "CLOCK2")? clock2:
                                    (addnsub_multiplier_pipeline_register1 == "CLOCK3")? clock3: 1'b0;
                              
                                    

    assign addsub3_reg_wire_clk =   (addnsub_multiplier_register3 == "CLOCK0")? clock0:
                                    (addnsub_multiplier_register3 == "UNREGISTERED")? 1'b0: 
                                    (addnsub_multiplier_register3 == "CLOCK1")? clock1:
                                    (addnsub_multiplier_register3 == "CLOCK2")? clock2:
                                    (addnsub_multiplier_register3 == "CLOCK3")? clock3: 1'b0;
                                  
                        

    assign addsub3_pipe_wire_clk =  (addnsub_multiplier_pipeline_register3 == "CLOCK0")? clock0:
                                    (addnsub_multiplier_pipeline_register3 == "UNREGISTERED")? 1'b0: 
                                    (addnsub_multiplier_pipeline_register3 == "CLOCK1")? clock1:
                                    (addnsub_multiplier_pipeline_register3 == "CLOCK2")? clock2:
                                    (addnsub_multiplier_pipeline_register3 == "CLOCK3")? clock3: 1'b0;
                                   
                                   


    assign sign_reg_a_wire_clk =    (signed_register_a == "CLOCK0")? clock0:
                                    (signed_register_a == "UNREGISTERED")? 1'b0:
                                    (signed_register_a == "CLOCK1")? clock1:
                                    (signed_register_a == "CLOCK2")? clock2:
                                    (signed_register_a == "CLOCK3")? clock3: 1'b0;
                                  


    assign sign_pipe_a_wire_clk =   (signed_pipeline_register_a == "CLOCK0")? clock0:
                                    (signed_pipeline_register_a == "UNREGISTERED")? 1'b0: 
                                    (signed_pipeline_register_a == "CLOCK1")? clock1:
                                    (signed_pipeline_register_a == "CLOCK2")? clock2:
                                    (signed_pipeline_register_a == "CLOCK3")? clock3: 1'b0;
                                  
                                

    assign sign_reg_b_wire_clk =    (signed_register_b == "CLOCK0")? clock0:
                                    (signed_register_b == "UNREGISTERED")? 1'b0:
                                    (signed_register_b == "CLOCK1")? clock1:
                                    (signed_register_b == "CLOCK2")? clock2:
                                    (signed_register_b == "CLOCK3")? clock3: 1'b0;
                                  
                                

    assign sign_pipe_b_wire_clk =   (signed_pipeline_register_b == "CLOCK0")? clock0:
                                    (signed_pipeline_register_b == "UNREGISTERED")? 1'b0: 
                                    (signed_pipeline_register_b == "CLOCK1")? clock1:
                                    (signed_pipeline_register_b == "CLOCK2")? clock2:
                                    (signed_pipeline_register_b == "CLOCK3")? clock3: 1'b0;
                              


    assign multiplier_reg0_wire_clk =   (multiplier_register0 == "CLOCK0")? clock0:
                                        (multiplier_register0 == "UNREGISTERED")? 1'b0:
                                        (multiplier_register0 == "CLOCK1")? clock1:
                                        (multiplier_register0 == "CLOCK2")? clock2:
                                        (multiplier_register0 == "CLOCK3")? clock3: 1'b0;
                                      


    assign multiplier_reg1_wire_clk =   (multiplier_register1 == "CLOCK0")? clock0:
                                        (multiplier_register1 == "UNREGISTERED")? 1'b0:
                                        (multiplier_register1 == "CLOCK1")? clock1:
                                        (multiplier_register1 == "CLOCK2")? clock2:
                                        (multiplier_register1 == "CLOCK3")? clock3: 1'b0;
                                   

    assign multiplier_reg2_wire_clk =   (multiplier_register2 == "CLOCK0")? clock0:
                                        (multiplier_register2 == "UNREGISTERED")? 1'b0:
                                        (multiplier_register2 == "CLOCK1")? clock1:
                                        (multiplier_register2 == "CLOCK2")? clock2:
                                        (multiplier_register2 == "CLOCK3")? clock3: 1'b0;



    assign multiplier_reg3_wire_clk =   (multiplier_register3 == "CLOCK0")? clock0:
                                        (multiplier_register3 == "UNREGISTERED")? 1'b0:
                                        (multiplier_register3 == "CLOCK1")? clock1:
                                        (multiplier_register3 == "CLOCK2")? clock2:
                                        (multiplier_register3 == "CLOCK3")? clock3: 1'b0;



    assign output_reg_wire_clk =    (output_register == "CLOCK0")? clock0:
                                    (output_register == "UNREGISTERED")? 1'b0: 
                                    (output_register == "CLOCK1")? clock1:
                                    (output_register == "CLOCK2")? clock2:
                                    (output_register == "CLOCK3")? clock3: 1'b0;
                                 

    assign addnsub1_round_wire_clk =    (addnsub1_round_register == "CLOCK0")? clock0:
                                        (addnsub1_round_register == "UNREGISTERED")? 1'b0: 
                                        (addnsub1_round_register == "CLOCK1")? clock1:
                                        (addnsub1_round_register == "CLOCK2")? clock2:
                                        (addnsub1_round_register == "CLOCK3")? clock3: 1'b0;
                                     
                                     
    assign addnsub1_round_pipe_wire_clk =   (addnsub1_round_pipeline_register == "CLOCK0")? clock0:
                                            (addnsub1_round_pipeline_register == "UNREGISTERED")? 1'b0: 
                                            (addnsub1_round_pipeline_register == "CLOCK1")? clock1:
                                            (addnsub1_round_pipeline_register == "CLOCK2")? clock2:
                                            (addnsub1_round_pipeline_register == "CLOCK3")? clock3: 1'b0;
                                          

    assign addnsub3_round_wire_clk =    (addnsub3_round_register == "CLOCK0")? clock0:
                                        (addnsub3_round_register == "UNREGISTERED")? 1'b0: 
                                        (addnsub3_round_register == "CLOCK1")? clock1:
                                        (addnsub3_round_register == "CLOCK2")? clock2:
                                        (addnsub3_round_register == "CLOCK3")? clock3: 1'b0;
                                     
    assign addnsub3_round_pipe_wire_clk =   (addnsub3_round_pipeline_register == "CLOCK0")? clock0:
                                            (addnsub3_round_pipeline_register == "UNREGISTERED")? 1'b0: 
                                            (addnsub3_round_pipeline_register == "CLOCK1")? clock1:
                                            (addnsub3_round_pipeline_register == "CLOCK2")? clock2:
                                            (addnsub3_round_pipeline_register == "CLOCK3")? clock3: 1'b0;
                                          
    assign mult01_round_wire_clk =  (mult01_round_register == "CLOCK0")? clock0:
                                    (mult01_round_register == "UNREGISTERED")? 1'b0: 
                                    (mult01_round_register == "CLOCK1")? clock1:
                                    (mult01_round_register == "CLOCK2")? clock2:
                                    (mult01_round_register == "CLOCK3")? clock3: 1'b0;
                                   
                                   
    assign mult01_saturate_wire_clk =   (mult01_saturation_register == "CLOCK0")? clock0:
                                        (mult01_saturation_register == "UNREGISTERED")? 1'b0: 
                                        (mult01_saturation_register == "CLOCK1")? clock1:
                                        (mult01_saturation_register == "CLOCK2")? clock2:
                                        (mult01_saturation_register == "CLOCK3")? clock3: 1'b0;
                                      
                                   
    assign mult23_round_wire_clk =  (mult23_round_register == "CLOCK0")? clock0:
                                    (mult23_round_register == "UNREGISTERED")? 1'b0: 
                                    (mult23_round_register == "CLOCK1")? clock1:
                                    (mult23_round_register == "CLOCK2")? clock2:
                                    (mult23_round_register == "CLOCK3")? clock3: 1'b0;
                                   
    assign mult23_saturate_wire_clk =   (mult23_saturation_register == "CLOCK0")? clock0:
                                        (mult23_saturation_register == "UNREGISTERED")? 1'b0: 
                                        (mult23_saturation_register == "CLOCK1")? clock1:
                                        (mult23_saturation_register == "CLOCK2")? clock2:
                                        (mult23_saturation_register == "CLOCK3")? clock3: 1'b0;

    assign outround_reg_wire_clk =  (output_round_register == "CLOCK0") ? clock0:
                                    (output_round_register == "UNREGISTERED") ? 1'b0:
                                    (output_round_register == "CLOCK1") ? clock1:
                                    (output_round_register == "CLOCK2") ? clock2:
                                    (output_round_register == "CLOCK3") ? clock3 : 1'b0;
                                    
    assign outround_pipe_wire_clk = (output_round_pipeline_register == "CLOCK0") ? clock0:
                                    (output_round_pipeline_register == "UNREGISTERED") ? 1'b0:
                                    (output_round_pipeline_register == "CLOCK1") ? clock1:
                                    (output_round_pipeline_register == "CLOCK2") ? clock2:
                                    (output_round_pipeline_register == "CLOCK3") ? clock3 : 1'b0;

    assign chainout_round_reg_wire_clk =    (chainout_round_register == "CLOCK0") ? clock0:
                                            (chainout_round_register == "UNREGISTERED") ? 1'b0:
                                            (chainout_round_register == "CLOCK1") ? clock1:
                                            (chainout_round_register == "CLOCK2") ? clock2:
                                            (chainout_round_register == "CLOCK3") ? clock3 : 1'b0;

    assign chainout_round_pipe_wire_clk =   (chainout_round_pipeline_register == "CLOCK0") ? clock0:
                                            (chainout_round_pipeline_register == "UNREGISTERED") ? 1'b0:
                                            (chainout_round_pipeline_register == "CLOCK1") ? clock1:
                                            (chainout_round_pipeline_register == "CLOCK2") ? clock2:
                                            (chainout_round_pipeline_register == "CLOCK3") ? clock3 : 1'b0;

    assign chainout_round_out_reg_wire_clk =    (chainout_round_output_register == "CLOCK0") ? clock0:
                                                (chainout_round_output_register == "UNREGISTERED") ? 1'b0:
                                                (chainout_round_output_register == "CLOCK1") ? clock1:
                                                (chainout_round_output_register == "CLOCK2") ? clock2:
                                                (chainout_round_output_register == "CLOCK3") ? clock3 : 1'b0;

    assign outsat_reg_wire_clk =    (output_saturate_register == "CLOCK0") ? clock0:
                                    (output_saturate_register == "UNREGISTERED") ? 1'b0:
                                    (output_saturate_register == "CLOCK1") ? clock1:
                                    (output_saturate_register == "CLOCK2") ? clock2:
                                    (output_saturate_register == "CLOCK3") ? clock3 : 1'b0;
                                    
    assign outsat_pipe_wire_clk =   (output_saturate_pipeline_register == "CLOCK0") ? clock0:
                                    (output_saturate_pipeline_register == "UNREGISTERED") ? 1'b0:
                                    (output_saturate_pipeline_register == "CLOCK1") ? clock1:
                                    (output_saturate_pipeline_register == "CLOCK2") ? clock2:
                                    (output_saturate_pipeline_register == "CLOCK3") ? clock3 : 1'b0;

    assign chainout_sat_reg_wire_clk =      (chainout_saturate_register == "CLOCK0") ? clock0:
                                            (chainout_saturate_register == "UNREGISTERED") ? 1'b0:
                                            (chainout_saturate_register == "CLOCK1") ? clock1:
                                            (chainout_saturate_register == "CLOCK2") ? clock2:
                                            (chainout_saturate_register == "CLOCK3") ? clock3 : 1'b0;

    assign chainout_sat_pipe_wire_clk =     (chainout_saturate_pipeline_register == "CLOCK0") ? clock0:
                                            (chainout_saturate_pipeline_register == "UNREGISTERED") ? 1'b0:
                                            (chainout_saturate_pipeline_register == "CLOCK1") ? clock1:
                                            (chainout_saturate_pipeline_register == "CLOCK2") ? clock2:
                                            (chainout_saturate_pipeline_register == "CLOCK3") ? clock3 : 1'b0;

    assign chainout_sat_out_reg_wire_clk =      (chainout_saturate_output_register == "CLOCK0") ? clock0:
                                                (chainout_saturate_output_register == "UNREGISTERED") ? 1'b0:
                                                (chainout_saturate_output_register == "CLOCK1") ? clock1:
                                                (chainout_saturate_output_register == "CLOCK2") ? clock2:
                                                (chainout_saturate_output_register == "CLOCK3") ? clock3 : 1'b0;

    assign scanouta_reg_wire_clk =  (scanouta_register == "CLOCK0") ? clock0:
                                    (scanouta_register == "UNREGISTERED") ? 1'b0:
                                    (scanouta_register == "CLOCK1") ? clock1:
                                    (scanouta_register == "CLOCK2") ? clock2:
                                    (scanouta_register == "CLOCK3") ? clock3 : 1'b0;

    assign chainout_reg_wire_clk =  (chainout_register == "CLOCK0") ? clock0:
                                    (chainout_register == "UNREGISTERED") ? 1'b0:
                                    (chainout_register == "CLOCK1") ? clock1:
                                    (chainout_register == "CLOCK2") ? clock2:
                                    (chainout_register == "CLOCK3") ? clock3 : 1'b0;

    assign zerochainout_reg_wire_clk =  (zero_chainout_output_register == "CLOCK0") ? clock0:
                                        (zero_chainout_output_register == "UNREGISTERED") ? 1'b0:
                                        (zero_chainout_output_register == "CLOCK1") ? clock1:
                                        (zero_chainout_output_register == "CLOCK2") ? clock2:
                                        (zero_chainout_output_register == "CLOCK3") ? clock3 : 1'b0;

    assign rotate_reg_wire_clk =    (rotate_register == "CLOCK0") ? clock0:
                                    (rotate_register == "UNREGISTERED") ? 1'b0:
                                    (rotate_register == "CLOCK1") ? clock1:
                                    (rotate_register == "CLOCK2") ? clock2:
                                    (rotate_register == "CLOCK3") ? clock3 : 1'b0;

    assign rotate_pipe_wire_clk =   (rotate_pipeline_register == "CLOCK0") ? clock0:
                                    (rotate_pipeline_register == "UNREGISTERED") ? 1'b0:
                                    (rotate_pipeline_register == "CLOCK1") ? clock1:
                                    (rotate_pipeline_register == "CLOCK2") ? clock2:
                                    (rotate_pipeline_register == "CLOCK3") ? clock3 : 1'b0;

    assign rotate_out_reg_wire_clk =    (rotate_output_register == "CLOCK0") ? clock0:
                                        (rotate_output_register == "UNREGISTERED") ? 1'b0:
                                        (rotate_output_register == "CLOCK1") ? clock1:
                                        (rotate_output_register == "CLOCK2") ? clock2:
                                        (rotate_output_register == "CLOCK3") ? clock3 : 1'b0;

    assign shiftr_reg_wire_clk =    (shift_right_register == "CLOCK0") ? clock0:
                                    (shift_right_register == "UNREGISTERED") ? 1'b0:
                                    (shift_right_register == "CLOCK1") ? clock1:
                                    (shift_right_register == "CLOCK2") ? clock2:
                                    (shift_right_register == "CLOCK3") ? clock3 : 1'b0;

    assign shiftr_pipe_wire_clk =   (shift_right_pipeline_register == "CLOCK0") ? clock0:
                                    (shift_right_pipeline_register == "UNREGISTERED") ? 1'b0:
                                    (shift_right_pipeline_register == "CLOCK1") ? clock1:
                                    (shift_right_pipeline_register == "CLOCK2") ? clock2:
                                    (shift_right_pipeline_register == "CLOCK3") ? clock3 : 1'b0;
                                    
    assign shiftr_out_reg_wire_clk =    (shift_right_output_register == "CLOCK0") ? clock0:
                                        (shift_right_output_register == "UNREGISTERED") ? 1'b0:
                                        (shift_right_output_register == "CLOCK1") ? clock1:
                                        (shift_right_output_register == "CLOCK2") ? clock2:
                                        (shift_right_output_register == "CLOCK3") ? clock3 : 1'b0;

    assign zeroloopback_reg_wire_clk =  (zero_loopback_register == "CLOCK0") ? clock0 :
                                        (zero_loopback_register == "UNREGISTERED") ? 1'b0:
                                        (zero_loopback_register == "CLOCK1") ? clock1 :
                                        (zero_loopback_register == "CLOCK2") ? clock2 :
                                        (zero_loopback_register == "CLOCK3") ? clock3 : 1'b0;

    assign zeroloopback_pipe_wire_clk = (zero_loopback_pipeline_register == "CLOCK0") ? clock0 :
                                        (zero_loopback_pipeline_register == "UNREGISTERED") ? 1'b0:
                                        (zero_loopback_pipeline_register == "CLOCK1") ? clock1 :
                                        (zero_loopback_pipeline_register == "CLOCK2") ? clock2 :
                                        (zero_loopback_pipeline_register == "CLOCK3") ? clock3 : 1'b0;

    assign zeroloopback_out_wire_clk =  (zero_loopback_output_register == "CLOCK0") ? clock0 :
                                        (zero_loopback_output_register == "UNREGISTERED") ? 1'b0:
                                        (zero_loopback_output_register == "CLOCK1") ? clock1 :
                                        (zero_loopback_output_register == "CLOCK2") ? clock2 :
                                        (zero_loopback_output_register == "CLOCK3") ? clock3 : 1'b0;

    assign accumsload_reg_wire_clk =    (accum_sload_register == "CLOCK0") ? clock0 :
                                        (accum_sload_register == "UNREGISTERED") ? 1'b0:
                                        (accum_sload_register == "CLOCK1") ? clock1 :
                                        (accum_sload_register == "CLOCK2") ? clock2 :
                                        (accum_sload_register == "CLOCK3") ? clock3 : 1'b0;

    assign accumsload_pipe_wire_clk =   (accum_sload_pipeline_register == "CLOCK0") ? clock0 :
                                        (accum_sload_pipeline_register == "UNREGISTERED") ? 1'b0:
                                        (accum_sload_pipeline_register == "CLOCK1") ? clock1 :
                                        (accum_sload_pipeline_register == "CLOCK2") ? clock2 :
                                        (accum_sload_pipeline_register == "CLOCK3") ? clock3 : 1'b0;
                                    
	assign coeffsela_reg_wire_clk =  (coefsel0_register == "CLOCK0") ? clock0 :
                                     (coefsel0_register == "UNREGISTERED") ? 1'b0:
                                     (coefsel0_register == "CLOCK1") ? clock1 :
                                     (coefsel0_register == "CLOCK2") ? clock2 : 1'b0;                                                                           
                                     
	assign coeffselb_reg_wire_clk =  (coefsel1_register == "CLOCK0") ? clock0 :
                                     (coefsel1_register == "UNREGISTERED") ? 1'b0:
                                     (coefsel1_register == "CLOCK1") ? clock1 :
                                     (coefsel1_register == "CLOCK2") ? clock2 : 1'b0;                                                                                                                
                                     
	assign coeffselc_reg_wire_clk =  (coefsel2_register == "CLOCK0") ? clock0 :
                                     (coefsel2_register == "UNREGISTERED") ? 1'b0:
                                     (coefsel2_register == "CLOCK1") ? clock1 :
                                     (coefsel2_register == "CLOCK2") ? clock2 : 1'b0;                                                                           
                                     
	assign coeffseld_reg_wire_clk =  (coefsel3_register == "CLOCK0") ? clock0 :
                                     (coefsel3_register == "UNREGISTERED") ? 1'b0:
                                     (coefsel3_register == "CLOCK1") ? clock1 :
                                     (coefsel3_register == "CLOCK2") ? clock2 : 1'b0;                                                                                                                                                     

	assign systolic1_reg_wire_clk =  (systolic_delay1 == "CLOCK0") ? clock0 :
                                     (systolic_delay1 == "UNREGISTERED") ? 1'b0:
                                     (systolic_delay1 == "CLOCK1") ? clock1 :
                                     (systolic_delay1 == "CLOCK2") ? clock2 : 1'b0;                                                                                                                                                                                          

	assign systolic3_reg_wire_clk =  (systolic_delay3 == "CLOCK0") ? clock0 :
                                     (systolic_delay3 == "UNREGISTERED") ? 1'b0:
                                     (systolic_delay3 == "CLOCK1") ? clock1 :
                                     (systolic_delay3 == "CLOCK2") ? clock2 : 1'b0;                                                                                                                                                                                                                               
                                     
    // ----------------------------------------------------------------
    // This block updates the internal clock enable signals accordingly
    // every time the global clock enable signal changes state
    // ----------------------------------------------------------------
  
    
    assign input_reg_a0_wire_en =   (input_register_a0 == "CLOCK0")? ena0:
                                    (input_register_a0 == "UNREGISTERED")? 1'b1: 
                                    (input_register_a0 == "CLOCK1")? ena1:
                                    (input_register_a0 == "CLOCK2")? ena2:
                                    (input_register_a0 == "CLOCK3")? ena3: 1'b1;
                                   


    assign input_reg_a1_wire_en =   (input_register_a1 == "CLOCK0")? ena0:
                                    (input_register_a1 == "UNREGISTERED")? 1'b1: 
                                    (input_register_a1 == "CLOCK1")? ena1:
                                    (input_register_a1 == "CLOCK2")? ena2:
                                    (input_register_a1 == "CLOCK3")? ena3: 1'b1;


    assign input_reg_a2_wire_en =   (input_register_a2 == "CLOCK0")? ena0:
                                    (input_register_a2 == "UNREGISTERED")? 1'b1: 
                                    (input_register_a2 == "CLOCK1")? ena1:
                                    (input_register_a2 == "CLOCK2")? ena2:
                                    (input_register_a2 == "CLOCK3")? ena3: 1'b1;


    assign input_reg_a3_wire_en =   (input_register_a3 == "CLOCK0")? ena0:
                                    (input_register_a3 == "UNREGISTERED")? 1'b1: 
                                    (input_register_a3 == "CLOCK1")? ena1:
                                    (input_register_a3 == "CLOCK2")? ena2:
                                    (input_register_a3 == "CLOCK3")? ena3: 1'b1;


    assign input_reg_b0_wire_en =   (input_register_b0 == "CLOCK0")? ena0:
                                    (input_register_b0 == "UNREGISTERED")? 1'b1: 
                                    (input_register_b0 == "CLOCK1")? ena1:
                                    (input_register_b0 == "CLOCK2")? ena2:
                                    (input_register_b0 == "CLOCK3")? ena3: 1'b1;
                                    


    assign input_reg_b1_wire_en =   (input_register_b1 == "CLOCK0")? ena0:
                                    (input_register_b1 == "UNREGISTERED")? 1'b1: 
                                    (input_register_b1 == "CLOCK1")? ena1:
                                    (input_register_b1 == "CLOCK2")? ena2:
                                    (input_register_b1 == "CLOCK3")? ena3: 1'b1;


    assign input_reg_b2_wire_en =   (input_register_b2 == "CLOCK0")? ena0:
                                    (input_register_b2 == "UNREGISTERED")? 1'b1: 
                                    (input_register_b2 == "CLOCK1")? ena1:
                                    (input_register_b2 == "CLOCK2")? ena2:
                                    (input_register_b2 == "CLOCK3")? ena3: 1'b1;

    assign input_reg_b3_wire_en =   (input_register_b3 == "CLOCK0")? ena0:
                                    (input_register_b3 == "UNREGISTERED")? 1'b1: 
                                    (input_register_b3 == "CLOCK1")? ena1:
                                    (input_register_b3 == "CLOCK2")? ena2:
                                    (input_register_b3 == "CLOCK3")? ena3: 1'b1;

	assign input_reg_c0_wire_en =   (input_register_c0 == "CLOCK0")? ena0:
                                    (input_register_c0 == "UNREGISTERED")? 1'b1: 
                                    (input_register_c0 == "CLOCK1")? ena1:
                                    (input_register_c0 == "CLOCK2")? ena2: 1'b1;                            

    assign input_reg_c1_wire_en =   (input_register_c1 == "CLOCK0")? ena0:
                                    (input_register_c1 == "UNREGISTERED")? 1'b1: 
                                    (input_register_c1 == "CLOCK1")? ena1:
                                    (input_register_c1 == "CLOCK2")? ena2: 1'b1;

    assign input_reg_c2_wire_en =   (input_register_c2 == "CLOCK0")? ena0:
                                    (input_register_c2 == "UNREGISTERED")? 1'b1: 
                                    (input_register_c2 == "CLOCK1")? ena1:
                                    (input_register_c2 == "CLOCK2")? ena2: 1'b1;

    assign input_reg_c3_wire_en =   (input_register_c3 == "CLOCK0")? ena0:
                                    (input_register_c3 == "UNREGISTERED")? 1'b1: 
                                    (input_register_c3 == "CLOCK1")? ena1:
                                    (input_register_c3 == "CLOCK2")? ena2: 1'b1;                                    

    assign addsub1_reg_wire_en =    (addnsub_multiplier_register1 == "CLOCK0")? ena0:
                                    (addnsub_multiplier_register1 == "UNREGISTERED")? 1'b1: 
                                    (addnsub_multiplier_register1 == "CLOCK1")? ena1:
                                    (addnsub_multiplier_register1 == "CLOCK2")? ena2:
                                    (addnsub_multiplier_register1 == "CLOCK3")? ena3: 1'b1;
                                    


    assign addsub1_pipe_wire_en =   (addnsub_multiplier_pipeline_register1 == "CLOCK0")? ena0:
                                    (addnsub_multiplier_pipeline_register1 == "UNREGISTERED")? 1'b1: 
                                    (addnsub_multiplier_pipeline_register1 == "CLOCK1")? ena1:
                                    (addnsub_multiplier_pipeline_register1 == "CLOCK2")? ena2:
                                    (addnsub_multiplier_pipeline_register1 == "CLOCK3")? ena3: 1'b1;


    assign addsub3_reg_wire_en =    (addnsub_multiplier_register3 == "CLOCK0")? ena0:
                                    (addnsub_multiplier_register3 == "UNREGISTERED")? 1'b1: 
                                    (addnsub_multiplier_register3 == "CLOCK1")? ena1:
                                    (addnsub_multiplier_register3 == "CLOCK2")? ena2:
                                    (addnsub_multiplier_register3 == "CLOCK3")? ena3: 1'b1;
                                    


    assign addsub3_pipe_wire_en =   (addnsub_multiplier_pipeline_register3 == "CLOCK0")? ena0:
                                    (addnsub_multiplier_pipeline_register3 == "UNREGISTERED")? 1'b1: 
                                    (addnsub_multiplier_pipeline_register3 == "CLOCK1")? ena1:
                                    (addnsub_multiplier_pipeline_register3 == "CLOCK2")? ena2:
                                    (addnsub_multiplier_pipeline_register3 == "CLOCK3")? ena3: 1'b1;



    assign sign_reg_a_wire_en =     (signed_register_a == "CLOCK0")? ena0:
                                    (signed_register_a == "UNREGISTERED")? 1'b1: 
                                    (signed_register_a == "CLOCK1")? ena1:
                                    (signed_register_a == "CLOCK2")? ena2:
                                    (signed_register_a == "CLOCK3")? ena3: 1'b1;
                                    


    assign sign_pipe_a_wire_en =    (signed_pipeline_register_a == "CLOCK0")? ena0:
                                    (signed_pipeline_register_a == "UNREGISTERED")? 1'b1: 
                                    (signed_pipeline_register_a == "CLOCK1")? ena1:
                                    (signed_pipeline_register_a == "CLOCK2")? ena2:
                                    (signed_pipeline_register_a == "CLOCK3")? ena3: 1'b1;
                                  


    assign sign_reg_b_wire_en =     (signed_register_b == "CLOCK0")? ena0:
                                    (signed_register_b == "UNREGISTERED")? 1'b1: 
                                    (signed_register_b == "CLOCK1")? ena1:
                                    (signed_register_b == "CLOCK2")? ena2:
                                    (signed_register_b == "CLOCK3")? ena3: 1'b1;
                                  


    assign sign_pipe_b_wire_en =    (signed_pipeline_register_b == "CLOCK0")? ena0:
                                    (signed_pipeline_register_b == "UNREGISTERED")? 1'b1: 
                                    (signed_pipeline_register_b == "CLOCK1")? ena1:
                                    (signed_pipeline_register_b == "CLOCK2")? ena2:
                                    (signed_pipeline_register_b == "CLOCK3")? ena3: 1'b1;
                                  


    assign multiplier_reg0_wire_en =    (multiplier_register0 == "CLOCK0")? ena0:
                                        (multiplier_register0 == "UNREGISTERED")? 1'b1: 
                                        (multiplier_register0 == "CLOCK1")? ena1:
                                        (multiplier_register0 == "CLOCK2")? ena2:
                                        (multiplier_register0 == "CLOCK3")? ena3: 1'b1;
                                      


    assign multiplier_reg1_wire_en =    (multiplier_register1 == "CLOCK0")? ena0:
                                        (multiplier_register1 == "UNREGISTERED")? 1'b1: 
                                        (multiplier_register1 == "CLOCK1")? ena1:
                                        (multiplier_register1 == "CLOCK2")? ena2:
                                        (multiplier_register1 == "CLOCK3")? ena3: 1'b1;


    assign multiplier_reg2_wire_en =    (multiplier_register2 == "CLOCK0")? ena0:
                                        (multiplier_register2 == "UNREGISTERED")? 1'b1: 
                                        (multiplier_register2 == "CLOCK1")? ena1:
                                        (multiplier_register2 == "CLOCK2")? ena2:
                                        (multiplier_register2 == "CLOCK3")? ena3: 1'b1;



    assign multiplier_reg3_wire_en =    (multiplier_register3 == "CLOCK0")? ena0:
                                        (multiplier_register3 == "UNREGISTERED")? 1'b1: 
                                        (multiplier_register3 == "CLOCK1")? ena1:
                                        (multiplier_register3 == "CLOCK2")? ena2:
                                        (multiplier_register3 == "CLOCK3")? ena3: 1'b1;



    assign output_reg_wire_en =     (output_register == "CLOCK0")? ena0:
                                    (output_register == "UNREGISTERED")? 1'b1: 
                                    (output_register == "CLOCK1")? ena1:
                                    (output_register == "CLOCK2")? ena2:
                                    (output_register == "CLOCK3")? ena3: 1'b1;
                                 

    assign addnsub1_round_wire_en =     (addnsub1_round_register == "CLOCK0")? ena0:
                                        (addnsub1_round_register == "UNREGISTERED")? 1'b1: 
                                        (addnsub1_round_register == "CLOCK1")? ena1:
                                        (addnsub1_round_register == "CLOCK2")? ena2:
                                        (addnsub1_round_register == "CLOCK3")? ena3: 1'b1;
                                    
                                     
    assign addnsub1_round_pipe_wire_en =    (addnsub1_round_pipeline_register == "CLOCK0")? ena0:
                                            (addnsub1_round_pipeline_register == "UNREGISTERED")? 1'b1: 
                                            (addnsub1_round_pipeline_register == "CLOCK1")? ena1:
                                            (addnsub1_round_pipeline_register == "CLOCK2")? ena2:
                                            (addnsub1_round_pipeline_register == "CLOCK3")? ena3: 1'b1;
                                         

    assign addnsub3_round_wire_en = (addnsub3_round_register == "CLOCK0")? ena0:
                                    (addnsub3_round_register == "UNREGISTERED")? 1'b1: 
                                    (addnsub3_round_register == "CLOCK1")? ena1:
                                    (addnsub3_round_register == "CLOCK2")? ena2:
                                    (addnsub3_round_register == "CLOCK3")? ena3: 1'b1;
                                    
                                     
    assign addnsub3_round_pipe_wire_en =    (addnsub3_round_pipeline_register == "CLOCK0")? ena0:
                                            (addnsub3_round_pipeline_register == "UNREGISTERED")? 1'b1:
                                            (addnsub3_round_pipeline_register == "CLOCK1")? ena1:
                                            (addnsub3_round_pipeline_register == "CLOCK2")? ena2:
                                            (addnsub3_round_pipeline_register == "CLOCK3")? ena3: 1'b1;
                                        
                                          
    assign mult01_round_wire_en =   (mult01_round_register == "CLOCK0")? ena0:
                                    (mult01_round_register == "UNREGISTERED")? 1'b1: 
                                    (mult01_round_register == "CLOCK1")? ena1:
                                    (mult01_round_register == "CLOCK2")? ena2:
                                    (mult01_round_register == "CLOCK3")? ena3: 1'b1;
                                  
                                   
    assign mult01_saturate_wire_en =    (mult01_saturation_register == "CLOCK0")? ena0:
                                        (mult01_saturation_register == "UNREGISTERED")? 1'b1: 
                                        (mult01_saturation_register == "CLOCK1")? ena1:
                                        (mult01_saturation_register == "CLOCK2")? ena2:
                                        (mult01_saturation_register == "CLOCK3")? ena3: 1'b1;
                                     
                                   
    assign mult23_round_wire_en =   (mult23_round_register == "CLOCK0")? ena0:
                                    (mult23_round_register == "UNREGISTERED")? 1'b1: 
                                    (mult23_round_register == "CLOCK1")? ena1:
                                    (mult23_round_register == "CLOCK2")? ena2:
                                    (mult23_round_register == "CLOCK3")? ena3: 1'b1;
                                  
                                   
    assign mult23_saturate_wire_en =    (mult23_saturation_register == "CLOCK0")? ena0:
                                        (mult23_saturation_register == "UNREGISTERED")? 1'b1:       
                                        (mult23_saturation_register == "CLOCK1")? ena1:
                                        (mult23_saturation_register == "CLOCK2")? ena2:
                                        (mult23_saturation_register == "CLOCK3")? ena3: 1'b1;
                                              

    assign outround_reg_wire_en =  (output_round_register == "CLOCK0") ? ena0:
                                    (output_round_register == "UNREGISTERED") ? 1'b1:
                                    (output_round_register == "CLOCK1") ? ena1:
                                    (output_round_register == "CLOCK2") ? ena2:
                                    (output_round_register == "CLOCK3") ? ena3 : 1'b1;
                                    
    assign outround_pipe_wire_en = (output_round_pipeline_register == "CLOCK0") ? ena0:
                                    (output_round_pipeline_register == "UNREGISTERED") ? 1'b1:
                                    (output_round_pipeline_register == "CLOCK1") ? ena1:
                                    (output_round_pipeline_register == "CLOCK2") ? ena2:
                                    (output_round_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

    assign chainout_round_reg_wire_en =    (chainout_round_register == "CLOCK0") ? ena0:
                                            (chainout_round_register == "UNREGISTERED") ? 1'b1:
                                            (chainout_round_register == "CLOCK1") ? ena1:
                                            (chainout_round_register == "CLOCK2") ? ena2:
                                            (chainout_round_register == "CLOCK3") ? ena3 : 1'b1;

    assign chainout_round_pipe_wire_en =   (chainout_round_pipeline_register == "CLOCK0") ? ena0:
                                            (chainout_round_pipeline_register == "UNREGISTERED") ? 1'b1:
                                            (chainout_round_pipeline_register == "CLOCK1") ? ena1:
                                            (chainout_round_pipeline_register == "CLOCK2") ? ena2:
                                            (chainout_round_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

    assign chainout_round_out_reg_wire_en =    (chainout_round_output_register == "CLOCK0") ? ena0:
                                                (chainout_round_output_register == "UNREGISTERED") ? 1'b1:
                                                (chainout_round_output_register == "CLOCK1") ? ena1:
                                                (chainout_round_output_register == "CLOCK2") ? ena2:
                                                (chainout_round_output_register == "CLOCK3") ? ena3 : 1'b1;

    assign outsat_reg_wire_en =    (output_saturate_register == "CLOCK0") ? ena0:
                                    (output_saturate_register == "UNREGISTERED") ? 1'b1:
                                    (output_saturate_register == "CLOCK1") ? ena1:
                                    (output_saturate_register == "CLOCK2") ? ena2:
                                    (output_saturate_register == "CLOCK3") ? ena3 : 1'b1;
                                    
    assign outsat_pipe_wire_en =   (output_saturate_pipeline_register == "CLOCK0") ? ena0:
                                    (output_saturate_pipeline_register == "UNREGISTERED") ? 1'b1:
                                    (output_saturate_pipeline_register == "CLOCK1") ? ena1:
                                    (output_saturate_pipeline_register == "CLOCK2") ? ena2:
                                    (output_saturate_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

    assign chainout_sat_reg_wire_en =      (chainout_saturate_register == "CLOCK0") ? ena0:
                                            (chainout_saturate_register == "UNREGISTERED") ? 1'b1:
                                            (chainout_saturate_register == "CLOCK1") ? ena1:
                                            (chainout_saturate_register == "CLOCK2") ? ena2:
                                            (chainout_saturate_register == "CLOCK3") ? ena3 : 1'b1;

    assign chainout_sat_pipe_wire_en =     (chainout_saturate_pipeline_register == "CLOCK0") ? ena0:
                                            (chainout_saturate_pipeline_register == "UNREGISTERED") ? 1'b1:
                                            (chainout_saturate_pipeline_register == "CLOCK1") ? ena1:
                                            (chainout_saturate_pipeline_register == "CLOCK2") ? ena2:
                                            (chainout_saturate_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

    assign chainout_sat_out_reg_wire_en =      (chainout_saturate_output_register == "CLOCK0") ? ena0:
                                                (chainout_saturate_output_register == "UNREGISTERED") ? 1'b1:
                                                (chainout_saturate_output_register == "CLOCK1") ? ena1:
                                                (chainout_saturate_output_register == "CLOCK2") ? ena2:
                                                (chainout_saturate_output_register == "CLOCK3") ? ena3 : 1'b1;

    assign scanouta_reg_wire_en =   (scanouta_register == "CLOCK0") ? ena0:
                                    (scanouta_register == "UNREGISTERED") ? 1'b1:
                                    (scanouta_register == "CLOCK1") ? ena1:
                                    (scanouta_register == "CLOCK2") ? ena2:
                                    (scanouta_register == "CLOCK3") ? ena3 : 1'b1;

    assign chainout_reg_wire_en  =  (chainout_register == "CLOCK0") ? ena0:
                                    (chainout_register == "UNREGISTERED") ? 1'b1:
                                    (chainout_register == "CLOCK1") ? ena1:
                                    (chainout_register == "CLOCK2") ? ena2:
                                    (chainout_register == "CLOCK3") ? ena3 : 1'b1;

    assign zerochainout_reg_wire_en =  (zero_chainout_output_register == "CLOCK0") ? ena0:
                                        (zero_chainout_output_register == "UNREGISTERED") ? 1'b1:
                                        (zero_chainout_output_register == "CLOCK1") ? ena1:
                                        (zero_chainout_output_register == "CLOCK2") ? ena2:
                                        (zero_chainout_output_register == "CLOCK3") ? ena3 : 1'b1;

    assign rotate_reg_wire_en =     (rotate_register == "CLOCK0") ? ena0:
                                    (rotate_register == "UNREGISTERED") ? 1'b1:
                                    (rotate_register == "CLOCK1") ? ena1:
                                    (rotate_register == "CLOCK2") ? ena2:
                                    (rotate_register == "CLOCK3") ? ena3 : 1'b1;

    assign rotate_pipe_wire_en =    (rotate_pipeline_register == "CLOCK0") ? ena0:
                                    (rotate_pipeline_register == "UNREGISTERED") ? 1'b1:
                                    (rotate_pipeline_register == "CLOCK1") ? ena1:
                                    (rotate_pipeline_register == "CLOCK2") ? ena2:
                                    (rotate_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

    assign rotate_out_reg_wire_en =     (rotate_output_register == "CLOCK0") ? ena0:
                                        (rotate_output_register == "UNREGISTERED") ? 1'b1:
                                        (rotate_output_register == "CLOCK1") ? ena1:
                                        (rotate_output_register == "CLOCK2") ? ena2:
                                        (rotate_output_register == "CLOCK3") ? ena3 : 1'b1;

    assign shiftr_reg_wire_en =     (shift_right_register == "CLOCK0") ? ena0:
                                    (shift_right_register == "UNREGISTERED") ? 1'b1:
                                    (shift_right_register == "CLOCK1") ? ena1:
                                    (shift_right_register == "CLOCK2") ? ena2:
                                    (shift_right_register == "CLOCK3") ? ena3 : 1'b1;

    assign shiftr_pipe_wire_en =    (shift_right_pipeline_register == "CLOCK0") ? ena0:
                                    (shift_right_pipeline_register == "UNREGISTERED") ? 1'b1:
                                    (shift_right_pipeline_register == "CLOCK1") ? ena1:
                                    (shift_right_pipeline_register == "CLOCK2") ? ena2:
                                    (shift_right_pipeline_register == "CLOCK3") ? ena3 : 1'b1;
                                    
    assign shiftr_out_reg_wire_en =     (shift_right_output_register == "CLOCK0") ? ena0:
                                        (shift_right_output_register == "UNREGISTERED") ? 1'b1:
                                        (shift_right_output_register == "CLOCK1") ? ena1:
                                        (shift_right_output_register == "CLOCK2") ? ena2:
                                        (shift_right_output_register == "CLOCK3") ? ena3 : 1'b1;

    assign zeroloopback_reg_wire_en =  (zero_loopback_register == "CLOCK0") ? ena0 :
                                        (zero_loopback_register == "UNREGISTERED") ? 1'b1:
                                        (zero_loopback_register == "CLOCK1") ? ena1 :
                                        (zero_loopback_register == "CLOCK2") ? ena2 :
                                        (zero_loopback_register == "CLOCK3") ? ena3 : 1'b1;

    assign zeroloopback_pipe_wire_en = (zero_loopback_pipeline_register == "CLOCK0") ? ena0 :
                                        (zero_loopback_pipeline_register == "UNREGISTERED") ? 1'b1:
                                        (zero_loopback_pipeline_register == "CLOCK1") ? ena1 :
                                        (zero_loopback_pipeline_register == "CLOCK2") ? ena2 :
                                        (zero_loopback_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

    assign zeroloopback_out_wire_en =  (zero_loopback_output_register == "CLOCK0") ? ena0 :
                                        (zero_loopback_output_register == "UNREGISTERED") ? 1'b1:
                                        (zero_loopback_output_register == "CLOCK1") ? ena1 :
                                        (zero_loopback_output_register == "CLOCK2") ? ena2 :
                                        (zero_loopback_output_register == "CLOCK3") ? ena3 : 1'b1;

    assign accumsload_reg_wire_en =    (accum_sload_register == "CLOCK0") ? ena0 :
                                        (accum_sload_register == "UNREGISTERED") ? 1'b1:
                                        (accum_sload_register == "CLOCK1") ? ena1 :
                                        (accum_sload_register == "CLOCK2") ? ena2 :
                                        (accum_sload_register == "CLOCK3") ? ena3 : 1'b1;

    assign accumsload_pipe_wire_en =   (accum_sload_pipeline_register == "CLOCK0") ? ena0 :
                                        (accum_sload_pipeline_register == "UNREGISTERED") ? 1'b1:
                                        (accum_sload_pipeline_register == "CLOCK1") ? ena1 :
                                        (accum_sload_pipeline_register == "CLOCK2") ? ena2 :
                                        (accum_sload_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

	assign coeffsela_reg_wire_en =  (coefsel0_register == "CLOCK0") ? ena0:
                                    (coefsel0_register == "UNREGISTERED") ? 1'b1:
                                    (coefsel0_register == "CLOCK1") ? ena1:
                                    (coefsel0_register == "CLOCK2") ? ena2: 1'b1;                                                                            
                                    
	assign coeffselb_reg_wire_en =  (coefsel1_register == "CLOCK0") ? ena0:
                                    (coefsel1_register == "UNREGISTERED") ? 1'b1:
                                    (coefsel1_register == "CLOCK1") ? ena1:
                                    (coefsel1_register == "CLOCK2") ? ena2: 1'b1;                                                                            
                                    
	assign coeffselc_reg_wire_en =  (coefsel2_register == "CLOCK0") ? ena0:
                                    (coefsel2_register == "UNREGISTERED") ? 1'b1:
                                    (coefsel2_register == "CLOCK1") ? ena1:
                                    (coefsel2_register == "CLOCK2") ? ena2: 1'b1;                                                                            
                                    
	assign coeffseld_reg_wire_en =  (coefsel3_register == "CLOCK0") ? ena0:
                                    (coefsel3_register == "UNREGISTERED") ? 1'b1:
                                    (coefsel3_register == "CLOCK1") ? ena1:
                                    (coefsel3_register == "CLOCK2") ? ena2: 1'b1;                                                                                                                                                                                        

	assign systolic1_reg_wire_en =  (systolic_delay1 == "CLOCK0") ? ena0:
                                    (systolic_delay1 == "UNREGISTERED") ? 1'b1:
                                    (systolic_delay1 == "CLOCK1") ? ena1:
                                    (systolic_delay1 == "CLOCK2") ? ena2: 1'b1;                                                                                                                                                                                        
                                    
	assign systolic3_reg_wire_en =  (systolic_delay3 == "CLOCK0") ? ena0:
                                    (systolic_delay3 == "UNREGISTERED") ? 1'b1:
                                    (systolic_delay3 == "CLOCK1") ? ena1:
                                    (systolic_delay3 == "CLOCK2") ? ena2: 1'b1;                                                                                                                                                                                                                            
                                    
                                                                                                            
    // ---------------------------------------------------------
    // This block updates the internal clear signals accordingly
    // every time the global clear signal changes state
    // ---------------------------------------------------------

    assign input_reg_a0_wire_clr =  (input_aclr_a0 == "ACLR3")? aclr3: 
                                    (input_aclr_a0 == "UNREGISTERED")? 1'b0: 
                                    (input_aclr_a0 == "ACLR0")? aclr0:
                                    (input_aclr_a0 == "ACLR1")? aclr1:
                                    (input_aclr_a0 == "ACLR2")? aclr2: 1'b0;
                                    


    assign input_reg_a1_wire_clr =  (input_aclr_a1 == "ACLR3")? aclr3: 
                                    (input_aclr_a1 == "UNREGISTERED")? 1'b0: 
                                    (input_aclr_a1 == "ACLR0")? aclr0:
                                    (input_aclr_a1 == "ACLR1")? aclr1:
                                    (input_aclr_a1 == "ACLR2")? aclr2: 1'b0;


    assign input_reg_a2_wire_clr =  (input_aclr_a2 == "ACLR3")? aclr3: 
                                    (input_aclr_a2 == "UNREGISTERED")? 1'b0: 
                                    (input_aclr_a2 == "ACLR0")? aclr0:
                                    (input_aclr_a2 == "ACLR1")? aclr1:
                                    (input_aclr_a2 == "ACLR2")? aclr2: 1'b0;



    assign input_reg_a3_wire_clr =  (input_aclr_a3 == "ACLR3")? aclr3: 
                                    (input_aclr_a3 == "UNREGISTERED")? 1'b0: 
                                    (input_aclr_a3 == "ACLR0")? aclr0:
                                    (input_aclr_a3 == "ACLR1")? aclr1:
                                    (input_aclr_a3 == "ACLR2")? aclr2: 1'b0;


    assign input_reg_b0_wire_clr =  (input_aclr_b0 == "ACLR3")? aclr3: 
                                    (input_aclr_b0 == "UNREGISTERED")? 1'b0: 
                                    (input_aclr_b0 == "ACLR0")? aclr0:
                                    (input_aclr_b0 == "ACLR1")? aclr1:
                                    (input_aclr_b0 == "ACLR2")? aclr2: 1'b0;


    assign input_reg_b1_wire_clr =  (input_aclr_b1 == "ACLR3")? aclr3: 
                                    (input_aclr_b1 == "UNREGISTERED")? 1'b0: 
                                    (input_aclr_b1 == "ACLR0")? aclr0:
                                    (input_aclr_b1 == "ACLR1")? aclr1:
                                    (input_aclr_b1 == "ACLR2")? aclr2: 1'b0;


    assign input_reg_b2_wire_clr =  (input_aclr_b2 == "ACLR3")? aclr3: 
                                    (input_aclr_b2 == "UNREGISTERED")? 1'b0: 
                                    (input_aclr_b2 == "ACLR0")? aclr0:
                                    (input_aclr_b2 == "ACLR1")? aclr1:
                                    (input_aclr_b2 == "ACLR2")? aclr2: 1'b0;



    assign input_reg_b3_wire_clr =  (input_aclr_b3 == "ACLR3")? aclr3: 
                                    (input_aclr_b3 == "UNREGISTERED")? 1'b0: 
                                    (input_aclr_b3 == "ACLR0")? aclr0:
                                    (input_aclr_b3 == "ACLR1")? aclr1:
                                    (input_aclr_b3 == "ACLR2")? aclr2: 1'b0;

	assign input_reg_c0_wire_clr =  (input_aclr_c0 == "UNREGISTERED")? 1'b0: 
                                    (input_aclr_c0 == "ACLR0")? aclr0:
                                    (input_aclr_c0 == "ACLR1")? aclr1: 1'b0;

    assign input_reg_c1_wire_clr =  (input_aclr_c1 == "UNREGISTERED")? 1'b0: 
                                    (input_aclr_c1 == "ACLR0")? aclr0:
                                    (input_aclr_c1 == "ACLR1")? aclr1: 1'b0;

    assign input_reg_c2_wire_clr =  (input_aclr_c2 == "UNREGISTERED")? 1'b0: 
                                    (input_aclr_c2 == "ACLR0")? aclr0:
                                    (input_aclr_c2 == "ACLR1")? aclr1: 1'b0;

    assign input_reg_c3_wire_clr =  (input_aclr_c3 == "UNREGISTERED")? 1'b0: 
                                    (input_aclr_c3 == "ACLR0")? aclr0:
                                    (input_aclr_c3 == "ACLR1")? aclr1: 1'b0;


    assign addsub1_reg_wire_clr =   (addnsub_multiplier_aclr1 == "ACLR3")? aclr3:
                                    (addnsub_multiplier_aclr1 == "UNREGISTERED")? 1'b0: 
                                    (addnsub_multiplier_aclr1 == "ACLR0")? aclr0:
                                    (addnsub_multiplier_aclr1 == "ACLR1")? aclr1:
                                    (addnsub_multiplier_aclr1 == "ACLR2")? aclr2: 1'b0;
                                  


    assign addsub1_pipe_wire_clr =  (addnsub_multiplier_pipeline_aclr1 == "ACLR3")? aclr3:
                                    (addnsub_multiplier_pipeline_aclr1 == "UNREGISTERED")? 1'b0: 
                                    (addnsub_multiplier_pipeline_aclr1 == "ACLR0")? aclr0:
                                    (addnsub_multiplier_pipeline_aclr1 == "ACLR1")? aclr1:
                                    (addnsub_multiplier_pipeline_aclr1 == "ACLR2")? aclr2: 1'b0;
                                   



    assign addsub3_reg_wire_clr =   (addnsub_multiplier_aclr3 == "ACLR3")? aclr3:
                                    (addnsub_multiplier_aclr3 == "UNREGISTERED")? 1'b0: 
                                    (addnsub_multiplier_aclr3 == "ACLR0")? aclr0:
                                    (addnsub_multiplier_aclr3 == "ACLR1")? aclr1:
                                    (addnsub_multiplier_aclr3 == "ACLR2")? aclr2: 1'b0;
                                  


    assign addsub3_pipe_wire_clr =  (addnsub_multiplier_pipeline_aclr3 == "ACLR3")? aclr3:
                                    (addnsub_multiplier_pipeline_aclr3 == "UNREGISTERED")? 1'b0: 
                                    (addnsub_multiplier_pipeline_aclr3 == "ACLR0")? aclr0:
                                    (addnsub_multiplier_pipeline_aclr3 == "ACLR1")? aclr1:
                                    (addnsub_multiplier_pipeline_aclr3 == "ACLR2")? aclr2: 1'b0;
                                   



    assign sign_reg_a_wire_clr =    (signed_aclr_a == "ACLR3")? aclr3:
                                    (signed_aclr_a == "UNREGISTERED")? 1'b0: 
                                    (signed_aclr_a == "ACLR0")? aclr0:
                                    (signed_aclr_a == "ACLR1")? aclr1:
                                    (signed_aclr_a == "ACLR2")? aclr2: 1'b0;
                                  


    assign sign_pipe_a_wire_clr =   (signed_pipeline_aclr_a == "ACLR3")? aclr3:
                                    (signed_pipeline_aclr_a == "UNREGISTERED")? 1'b0: 
                                    (signed_pipeline_aclr_a == "ACLR0")? aclr0:
                                    (signed_pipeline_aclr_a == "ACLR1")? aclr1:
                                    (signed_pipeline_aclr_a == "ACLR2")? aclr2: 1'b0;
                                  


    assign sign_reg_b_wire_clr =    (signed_aclr_b == "ACLR3")? aclr3:
                                    (signed_aclr_b == "UNREGISTERED")? 1'b0: 
                                    (signed_aclr_b == "ACLR0")? aclr0:
                                    (signed_aclr_b == "ACLR1")? aclr1:
                                    (signed_aclr_b == "ACLR2")? aclr2: 1'b0;
                                  


    assign sign_pipe_b_wire_clr =   (signed_pipeline_aclr_b == "ACLR3")? aclr3:
                                    (signed_pipeline_aclr_b == "UNREGISTERED")? 1'b0: 
                                    (signed_pipeline_aclr_b == "ACLR0")? aclr0:
                                    (signed_pipeline_aclr_b == "ACLR1")? aclr1:
                                    (signed_pipeline_aclr_b == "ACLR2")? aclr2: 1'b0;
                                  



    assign multiplier_reg0_wire_clr =   (multiplier_aclr0 == "ACLR3")? aclr3:
                                        (multiplier_aclr0 == "UNREGISTERED")? 1'b0: 
                                        (multiplier_aclr0 == "ACLR0")? aclr0:
                                        (multiplier_aclr0 == "ACLR1")? aclr1:
                                        (multiplier_aclr0 == "ACLR2")? aclr2: 1'b0;
                                      


    assign multiplier_reg1_wire_clr =   (multiplier_aclr1 == "ACLR3")? aclr3:
                                        (multiplier_aclr1 == "UNREGISTERED")? 1'b0: 
                                        (multiplier_aclr1 == "ACLR0")? aclr0:
                                        (multiplier_aclr1 == "ACLR1")? aclr1:
                                        (multiplier_aclr1 == "ACLR2")? aclr2: 1'b0;
                                      


    assign multiplier_reg2_wire_clr =   (multiplier_aclr2 == "ACLR3")? aclr3:
                                        (multiplier_aclr2 == "UNREGISTERED")? 1'b0: 
                                        (multiplier_aclr2 == "ACLR0")? aclr0:
                                        (multiplier_aclr2 == "ACLR1")? aclr1:
                                        (multiplier_aclr2 == "ACLR2")? aclr2: 1'b0;
                                      



    assign multiplier_reg3_wire_clr =   (multiplier_aclr3 == "ACLR3")? aclr3:
                                        (multiplier_aclr3 == "UNREGISTERED")? 1'b0: 
                                        (multiplier_aclr3 == "ACLR0")? aclr0:
                                        (multiplier_aclr3 == "ACLR1")? aclr1:
                                        (multiplier_aclr3 == "ACLR2")? aclr2: 1'b0;
                                      



    assign output_reg_wire_clr =    (output_aclr == "ACLR3")? aclr3:
                                    (output_aclr == "UNREGISTERED")? 1'b0: 
                                    (output_aclr == "ACLR0")? aclr0:
                                    (output_aclr == "ACLR1")? aclr1:
                                    (output_aclr == "ACLR2")? aclr2: 1'b0;
                                 
                                 

    assign addnsub1_round_wire_clr =    (addnsub1_round_aclr == "ACLR3")? aclr3:
                                        (addnsub1_round_register == "UNREGISTERED")? 1'b0: 
                                        (addnsub1_round_aclr == "ACLR0")? aclr0:
                                        (addnsub1_round_aclr == "ACLR1")? aclr1:
                                        (addnsub1_round_aclr == "ACLR2")? aclr2: 1'b0;
                                     
                                     
                                     
    assign addnsub1_round_pipe_wire_clr =   (addnsub1_round_pipeline_aclr == "ACLR3")? aclr3:
                                            (addnsub1_round_pipeline_register == "UNREGISTERED")? 1'b0: 
                                            (addnsub1_round_pipeline_aclr == "ACLR0")? aclr0:
                                            (addnsub1_round_pipeline_aclr == "ACLR1")? aclr1:
                                            (addnsub1_round_pipeline_aclr == "ACLR2")? aclr2: 1'b0;
                                          
                                            

    assign addnsub3_round_wire_clr =    (addnsub3_round_aclr == "ACLR3")? aclr3:
                                        (addnsub3_round_register == "UNREGISTERED")? 1'b0: 
                                        (addnsub3_round_aclr == "ACLR0")? aclr0:
                                        (addnsub3_round_aclr == "ACLR1")? aclr1:
                                        (addnsub3_round_aclr == "ACLR2")? aclr2: 1'b0;
                                     
                                     
                                     
    assign addnsub3_round_pipe_wire_clr =   (addnsub3_round_pipeline_aclr == "ACLR3")? aclr3:
                                            (addnsub3_round_pipeline_register == "UNREGISTERED")? 1'b0: 
                                            (addnsub3_round_pipeline_aclr == "ACLR0")? aclr0:
                                            (addnsub3_round_pipeline_aclr == "ACLR1")? aclr1:
                                            (addnsub3_round_pipeline_aclr == "ACLR2")? aclr2: 1'b0;
                                          
                                          
                                          
    assign mult01_round_wire_clr =  (mult01_round_aclr == "ACLR3")? aclr3:
                                    (mult01_round_register == "UNREGISTERED")? 1'b0: 
                                    (mult01_round_aclr == "ACLR0")? aclr0:
                                    (mult01_round_aclr == "ACLR1")? aclr1:
                                    (mult01_round_aclr == "ACLR2")? aclr2: 1'b0;
                                   
                                   
                                   
    assign mult01_saturate_wire_clr =   (mult01_saturation_aclr == "ACLR3")? aclr3:
                                        (mult01_saturation_register == "UNREGISTERED")? 1'b0: 
                                        (mult01_saturation_aclr == "ACLR0")? aclr0:
                                        (mult01_saturation_aclr == "ACLR1")? aclr1:
                                        (mult01_saturation_aclr == "ACLR2")? aclr2: 1'b0;
                                      
                                                                        
                                   
    assign mult23_round_wire_clr =  (mult23_round_aclr == "ACLR3")? aclr3:
                                    (mult23_round_register == "UNREGISTERED")? 1'b0: 
                                    (mult23_round_aclr == "ACLR0")? aclr0:
                                    (mult23_round_aclr == "ACLR1")? aclr1:
                                    (mult23_round_aclr == "ACLR2")? aclr2: 1'b0;
                                  
                                       
                                   
    assign mult23_saturate_wire_clr =   (mult23_saturation_aclr == "ACLR3")? aclr3:
                                        (mult23_saturation_register == "UNREGISTERED")? 1'b0: 
                                        (mult23_saturation_aclr == "ACLR0")? aclr0:
                                        (mult23_saturation_aclr == "ACLR1")? aclr1:
                                        (mult23_saturation_aclr == "ACLR2")? aclr2: 1'b0;
                                      
    assign outround_reg_wire_clr =  (output_round_aclr == "ACLR0") ? aclr0:
                                    (output_round_aclr == "NONE") ? 1'b0:
                                    (output_round_aclr == "ACLR1") ? aclr1:
                                    (output_round_aclr == "ACLR2") ? aclr2:
                                    (output_round_aclr == "ACLR3") ? aclr3 : 1'b0;
                                    
    assign outround_pipe_wire_clr = (output_round_pipeline_aclr == "ACLR0") ? aclr0:
                                    (output_round_pipeline_aclr == "NONE") ? 1'b0:
                                    (output_round_pipeline_aclr == "ACLR1") ? aclr1:
                                    (output_round_pipeline_aclr == "ACLR2") ? aclr2:
                                    (output_round_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign chainout_round_reg_wire_clr =    (chainout_round_aclr == "ACLR0") ? aclr0:
                                            (chainout_round_aclr == "NONE") ? 1'b0:
                                            (chainout_round_aclr == "ACLR1") ? aclr1:
                                            (chainout_round_aclr == "ACLR2") ? aclr2:
                                            (chainout_round_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign chainout_round_pipe_wire_clr =   (chainout_round_pipeline_aclr == "ACLR0") ? aclr0:
                                            (chainout_round_pipeline_aclr == "NONE") ? 1'b0:
                                            (chainout_round_pipeline_aclr == "ACLR1") ? aclr1:
                                            (chainout_round_pipeline_aclr == "ACLR2") ? aclr2:
                                            (chainout_round_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign chainout_round_out_reg_wire_clr =    (chainout_round_output_aclr == "ACLR0") ? aclr0:
                                                (chainout_round_output_aclr == "NONE") ? 1'b0:
                                                (chainout_round_output_aclr == "ACLR1") ? aclr1:
                                                (chainout_round_output_aclr == "ACLR2") ? aclr2:
                                                (chainout_round_output_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign outsat_reg_wire_clr =  (output_saturate_aclr == "ACLR0") ? aclr0:
                                    (output_saturate_aclr == "NONE") ? 1'b0:
                                    (output_saturate_aclr == "ACLR1") ? aclr1:
                                    (output_saturate_aclr == "ACLR2") ? aclr2:
                                    (output_saturate_aclr == "ACLR3") ? aclr3 : 1'b0;
                                    
    assign outsat_pipe_wire_clr = (output_saturate_pipeline_aclr == "ACLR0") ? aclr0:
                                    (output_saturate_pipeline_aclr == "NONE") ? 1'b0:
                                    (output_saturate_pipeline_aclr == "ACLR1") ? aclr1:
                                    (output_saturate_pipeline_aclr == "ACLR2") ? aclr2:
                                    (output_saturate_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign chainout_sat_reg_wire_clr =    (chainout_saturate_aclr == "ACLR0") ? aclr0:
                                            (chainout_saturate_aclr == "NONE") ? 1'b0:
                                            (chainout_saturate_aclr == "ACLR1") ? aclr1:
                                            (chainout_saturate_aclr == "ACLR2") ? aclr2:
                                            (chainout_saturate_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign chainout_sat_pipe_wire_clr =   (chainout_saturate_pipeline_aclr == "ACLR0") ? aclr0:
                                            (chainout_saturate_pipeline_aclr == "NONE") ? 1'b0:
                                            (chainout_saturate_pipeline_aclr == "ACLR1") ? aclr1:
                                            (chainout_saturate_pipeline_aclr == "ACLR2") ? aclr2:
                                            (chainout_saturate_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign chainout_sat_out_reg_wire_clr =    (chainout_saturate_output_aclr == "ACLR0") ? aclr0:
                                                (chainout_saturate_output_aclr == "NONE") ? 1'b0:
                                                (chainout_saturate_output_aclr == "ACLR1") ? aclr1:
                                                (chainout_saturate_output_aclr == "ACLR2") ? aclr2:
                                                (chainout_saturate_output_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign scanouta_reg_wire_clr =  (scanouta_aclr == "ACLR0") ? aclr0:
                                    (scanouta_aclr == "NONE") ? 1'b0:
                                    (scanouta_aclr == "ACLR1") ? aclr1:
                                    (scanouta_aclr == "ACLR2") ? aclr2:
                                    (scanouta_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign chainout_reg_wire_clr =  (chainout_aclr == "ACLR0") ? aclr0:
                                    (chainout_aclr == "NONE") ? 1'b0:
                                    (chainout_aclr == "ACLR1") ? aclr1:
                                    (chainout_aclr == "ACLR2") ? aclr2:
                                    (chainout_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign zerochainout_reg_wire_clr =  (zero_chainout_output_register == "ACLR0") ? aclr0:
                                        (zero_chainout_output_register == "NONE") ? 1'b0:
                                        (zero_chainout_output_register == "ACLR1") ? aclr1:
                                        (zero_chainout_output_register == "ACLR2") ? aclr2:
                                        (zero_chainout_output_register == "ACLR3") ? aclr3 : 1'b0;

    assign rotate_reg_wire_clr =    (rotate_aclr == "ACLR0") ? aclr0:
                                    (rotate_aclr == "NONE") ? 1'b0:
                                    (rotate_aclr == "ACLR1") ? aclr1:
                                    (rotate_aclr == "ACLR2") ? aclr2:
                                    (rotate_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign rotate_pipe_wire_clr =   (rotate_pipeline_aclr == "ACLR0") ? aclr0:
                                    (rotate_pipeline_aclr == "NONE") ? 1'b0:
                                    (rotate_pipeline_aclr == "ACLR1") ? aclr1:
                                    (rotate_pipeline_aclr == "ACLR2") ? aclr2:
                                    (rotate_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign rotate_out_reg_wire_clr =    (rotate_output_aclr == "ACLR0") ? aclr0:
                                        (rotate_output_aclr == "NONE") ? 1'b0:
                                        (rotate_output_aclr == "ACLR1") ? aclr1:
                                        (rotate_output_aclr == "ACLR2") ? aclr2:
                                        (rotate_output_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign shiftr_reg_wire_clr =    (shift_right_aclr == "ACLR0") ? aclr0:
                                    (shift_right_aclr == "NONE") ? 1'b0:
                                    (shift_right_aclr == "ACLR1") ? aclr1:
                                    (shift_right_aclr == "ACLR2") ? aclr2:
                                    (shift_right_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign shiftr_pipe_wire_clr =   (shift_right_pipeline_aclr == "ACLR0") ? aclr0:
                                    (shift_right_pipeline_aclr == "NONE") ? 1'b0:
                                    (shift_right_pipeline_aclr == "ACLR1") ? aclr1:
                                    (shift_right_pipeline_aclr == "ACLR2") ? aclr2:
                                    (shift_right_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;
                                    
    assign shiftr_out_reg_wire_clr =    (shift_right_output_aclr == "ACLR0") ? aclr0:
                                        (shift_right_output_aclr == "NONE") ? 1'b0:
                                        (shift_right_output_aclr == "ACLR1") ? aclr1:
                                        (shift_right_output_aclr == "ACLR2") ? aclr2:
                                        (shift_right_output_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign zeroloopback_reg_wire_clr =  (zero_loopback_aclr == "ACLR0") ? aclr0 :
                                        (zero_loopback_aclr == "NONE") ? 1'b0:
                                        (zero_loopback_aclr == "ACLR1") ? aclr1 :
                                        (zero_loopback_aclr == "ACLR2") ? aclr2 :
                                        (zero_loopback_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign zeroloopback_pipe_wire_clr = (zero_loopback_pipeline_aclr == "ACLR0") ? aclr0 :
                                        (zero_loopback_pipeline_aclr == "NONE") ? 1'b0:
                                        (zero_loopback_pipeline_aclr == "ACLR1") ? aclr1 :
                                        (zero_loopback_pipeline_aclr == "ACLR2") ? aclr2 :
                                        (zero_loopback_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign zeroloopback_out_wire_clr =  (zero_loopback_output_aclr == "ACLR0") ? aclr0 :
                                        (zero_loopback_output_aclr == "NONE") ? 1'b0:
                                        (zero_loopback_output_aclr == "ACLR1") ? aclr1 :
                                        (zero_loopback_output_aclr == "ACLR2") ? aclr2 :
                                        (zero_loopback_output_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign accumsload_reg_wire_clr =    (accum_sload_aclr == "ACLR0") ? aclr0 :
                                        (accum_sload_aclr == "NONE") ? 1'b0:
                                        (accum_sload_aclr == "ACLR1") ? aclr1 :
                                        (accum_sload_aclr == "ACLR2") ? aclr2 :
                                        (accum_sload_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign accumsload_pipe_wire_clr =   (accum_sload_pipeline_aclr == "ACLR0") ? aclr0 :
                                        (accum_sload_pipeline_aclr == "NONE") ? 1'b0:
                                        (accum_sload_pipeline_aclr == "ACLR1") ? aclr1 :
                                        (accum_sload_pipeline_aclr == "ACLR2") ? aclr2 :
                                        (accum_sload_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;
                                   
	assign coeffsela_reg_wire_clr =  (coefsel0_aclr == "ACLR0") ? aclr0 :
                                     (coefsel0_aclr == "NONE") ? 1'b0:
                                     (coefsel0_aclr == "ACLR1") ? aclr1 : 1'b0;                                                                             
                                     
	assign coeffselb_reg_wire_clr =  (coefsel1_aclr == "ACLR0") ? aclr0 :
                                     (coefsel1_aclr == "NONE") ? 1'b0:
                                     (coefsel1_aclr == "ACLR1") ? aclr1 : 1'b0;                                                                             
                                     
	assign coeffselc_reg_wire_clr =  (coefsel2_aclr == "ACLR0") ? aclr0 :
                                     (coefsel2_aclr == "NONE") ? 1'b0:
                                     (coefsel2_aclr == "ACLR1") ? aclr1 : 1'b0;  
                                     
	assign coeffseld_reg_wire_clr =  (coefsel3_aclr == "ACLR0") ? aclr0 :
                                     (coefsel3_aclr == "NONE") ? 1'b0:
                                     (coefsel3_aclr == "ACLR1") ? aclr1 : 1'b0;                                                                                                                                                        
                                     
	assign systolic1_reg_wire_clr =  (systolic_aclr1 == "ACLR0") ? aclr0 :
                                     (systolic_aclr1 == "NONE") ? 1'b0:
                                     (systolic_aclr1 == "ACLR1") ? aclr1 : 1'b0;                                                                                                                                                                                             
                                     
	assign systolic3_reg_wire_clr =  (systolic_aclr3 == "ACLR0") ? aclr0 :
                                     (systolic_aclr3 == "NONE") ? 1'b0:
                                     (systolic_aclr3 == "ACLR1") ? aclr1 : 1'b0;                                                                                                                                                                                                                                  

    // -------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_a[int_width_a-1:0])
    // Signal Registered : mult_a_pre[int_width_a-1:0]
    //
    // Register is controlled by posedge input_reg_a0_wire_clk
    // Register has a clock enable input_reg_a0_wire_en
    // Register has an asynchronous clear signal, input_reg_a0_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_a0 is unregistered and mult_a_pre[int_width_a-1:0] changes value
    // -------------------------------------------------------------------------------------
    assign mult_a_wire[int_width_a-1:0] =   (input_register_a0 == "UNREGISTERED")?
                                            mult_a_pre[int_width_a-1:0]: mult_a_reg[int_width_a-1:0];
    always @(posedge input_reg_a0_wire_clk or posedge input_reg_a0_wire_clr)
    begin
            if (input_reg_a0_wire_clr == 1)
                mult_a_reg[int_width_a-1:0] <= 0;
            else if ((input_reg_a0_wire_clk === 1'b1) && (input_reg_a0_wire_en == 1))
                mult_a_reg[int_width_a-1:0] <= mult_a_pre[int_width_a-1:0];
    end


    // -----------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_a[(2*int_width_a)-1:int_width_a])
    // Signal Registered : mult_a_pre[(2*int_width_a)-1:int_width_a]
    //
    // Register is controlled by posedge input_reg_a1_wire_clk
    // Register has a clock enable input_reg_a1_wire_en
    // Register has an asynchronous clear signal, input_reg_a1_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_a1 is unregistered and mult_a_pre[(2*int_width_a)-1:int_width_a] changes value
    // -----------------------------------------------------------------------------------------------

    assign  mult_a_wire[(2*int_width_a)-1:int_width_a] = (input_register_a1 == "UNREGISTERED")?
                                    mult_a_pre[(2*int_width_a)-1:int_width_a]: mult_a_reg[(2*int_width_a)-1:int_width_a];

    always @(posedge input_reg_a1_wire_clk or posedge input_reg_a1_wire_clr)

    begin
            if (input_reg_a1_wire_clr == 1)
                mult_a_reg[(2*int_width_a)-1:int_width_a] <= 0;
            else if ((input_reg_a1_wire_clk == 1) && (input_reg_a1_wire_en == 1))
                mult_a_reg[(2*int_width_a)-1:int_width_a] <= mult_a_pre[(2*int_width_a)-1:int_width_a];
    end


    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_a[(3*int_width_a)-1:2*int_width_a])
    // Signal Registered : mult_a_pre[(3*int_width_a)-1:2*int_width_a]
    //
    // Register is controlled by posedge input_reg_a2_wire_clk
    // Register has a clock enable input_reg_a2_wire_en
    // Register has an asynchronous clear signal, input_reg_a2_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_a2 is unregistered and mult_a_pre[(3*int_width_a)-1:2*int_width_a] changes value
    // -------------------------------------------------------------------------------------------------
    assign  mult_a_wire[(3*int_width_a)-1 : 2*int_width_a ] = (input_register_a2 == "UNREGISTERED")? 
                            mult_a_pre[(3*int_width_a)-1 : 2*int_width_a]: mult_a_reg[(3*int_width_a)-1 : 2*int_width_a ];


    always @(posedge input_reg_a2_wire_clk or posedge input_reg_a2_wire_clr)
    begin
            if (input_reg_a2_wire_clr == 1)
                mult_a_reg[(3*int_width_a)-1 : 2*int_width_a ] <= 0;
            else if ((input_reg_a2_wire_clk == 1) && (input_reg_a2_wire_en == 1))
                mult_a_reg[(3*int_width_a)-1 : 2*int_width_a ] <= mult_a_pre[(3*int_width_a)-1 : 2*int_width_a];
    end


    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_a[(4*int_width_a)-1:3*int_width_a])
    // Signal Registered : mult_a_pre[(4*int_width_a)-1:3*int_width_a]
    //
    // Register is controlled by posedge input_reg_a3_wire_clk
    // Register has a clock enable input_reg_a3_wire_en
    // Register has an asynchronous clear signal, input_reg_a3_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_a3 is unregistered and mult_a_pre[(4*int_width_a)-1:3*int_width_a] changes value
    // -------------------------------------------------------------------------------------------------
    assign  mult_a_wire[(4*int_width_a)-1 : 3*int_width_a ] = (input_register_a3 == "UNREGISTERED")?
                                mult_a_pre[(4*int_width_a)-1:3*int_width_a]: mult_a_reg[(4*int_width_a)-1:3*int_width_a];

    always @(posedge input_reg_a3_wire_clk or posedge input_reg_a3_wire_clr)
    begin
            if (input_reg_a3_wire_clr == 1)
                mult_a_reg[(4*int_width_a)-1 : 3*int_width_a ] <= 0;
            else if ((input_reg_a3_wire_clk == 1) && (input_reg_a3_wire_en == 1))
                mult_a_reg[(4*int_width_a)-1 : 3*int_width_a ] <= mult_a_pre[(4*int_width_a)-1:3*int_width_a];

    end

 
    // -------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_b[int_width_b-1:0])
    // Signal Registered : mult_b_pre[int_width_b-1:0]
    //
    // Register is controlled by posedge input_reg_b0_wire_clk
    // Register has a clock enable input_reg_b0_wire_en
    // Register has an asynchronous clear signal, input_reg_b0_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_b0 is unregistered and mult_b_pre[int_width_b-1:0] changes value
    // -------------------------------------------------------------------------------------

    assign mult_b_wire[int_width_b-1:0] = (input_register_b0 == "UNREGISTERED")?
                                            mult_b_pre[int_width_b-1:0]: mult_b_reg[int_width_b-1:0];

    always @(posedge input_reg_b0_wire_clk or posedge input_reg_b0_wire_clr)
    begin
            if (input_reg_b0_wire_clr == 1)
                mult_b_reg[int_width_b-1:0] <= 0;
            else if ((input_reg_b0_wire_clk == 1) && (input_reg_b0_wire_en == 1))
                mult_b_reg[int_width_b-1:0] <= mult_b_pre[int_width_b-1:0];
    end


    // -----------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_b[(2*int_width_b)-1:int_width_b])
    // Signal Registered : mult_b_pre[(2*int_width_b)-1:int_width_b]
    //
    // Register is controlled by posedge input_reg_a1_wire_clk
    // Register has a clock enable input_reg_b1_wire_en
    // Register has an asynchronous clear signal, input_reg_b1_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_b1 is unregistered and mult_b_pre[(2*int_width_b)-1:int_width_b] changes value
    // -----------------------------------------------------------------------------------------------
    assign mult_b_wire[(2*int_width_b)-1:int_width_b] = (input_register_b1 == "UNREGISTERED")? 
                                    mult_b_pre[(2*int_width_b)-1:int_width_b]: mult_b_reg[(2*int_width_b)-1:int_width_b];


    
    always @(posedge input_reg_b1_wire_clk or posedge input_reg_b1_wire_clr)
    begin
            if (input_reg_b1_wire_clr == 1)
                mult_b_reg[(2*int_width_b)-1:int_width_b] <= 0;
            else if ((input_reg_b1_wire_clk == 1) && (input_reg_b1_wire_en == 1))
                mult_b_reg[(2*int_width_b)-1:int_width_b] <= mult_b_pre[(2*int_width_b)-1:int_width_b];

    end


    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_b[(3*int_width_b)-1:2*int_width_b])
    // Signal Registered : mult_b_pre[(3*int_width_b)-1:2*int_width_b]
    //
    // Register is controlled by posedge input_reg_b2_wire_clk
    // Register has a clock enable input_reg_b2_wire_en
    // Register has an asynchronous clear signal, input_reg_b2_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_b2 is unregistered and mult_b_pre[(3*int_width_b)-1:2*int_width_b] changes value
    // -------------------------------------------------------------------------------------------------
    assign mult_b_wire[(3*int_width_b)-1:2*int_width_b] = (input_register_b2 == "UNREGISTERED")? 
                                mult_b_pre[(3*int_width_b)-1:2*int_width_b]: mult_b_reg[(3*int_width_b)-1:2*int_width_b];

    
    always @(posedge input_reg_b2_wire_clk or posedge input_reg_b2_wire_clr)
    begin
            if (input_reg_b2_wire_clr == 1)
                mult_b_reg[(3*int_width_b)-1:2*int_width_b] <= 0;
            else if ((input_reg_b2_wire_clk == 1) && (input_reg_b2_wire_en == 1))
                mult_b_reg[(3*int_width_b)-1:2*int_width_b] <= mult_b_pre[(3*int_width_b)-1:2*int_width_b];

    end


    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_b[(4*int_width_b)-1:3*int_width_b])
    // Signal Registered : mult_b_pre[(4*int_width_b)-1:3*int_width_b]
    //
    // Register is controlled by posedge input_reg_b3_wire_clk
    // Register has a clock enable input_reg_b3_wire_en
    // Register has an asynchronous clear signal, input_reg_b3_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_b3 is unregistered and mult_b_pre[(4*int_width_b)-1:3*int_width_b] changes value
    // -------------------------------------------------------------------------------------------------
    assign mult_b_wire[(4*int_width_b)-1:3*int_width_b] = (input_register_b3 == "UNREGISTERED")? 
                                mult_b_pre[(4*int_width_b)-1:3*int_width_b]: mult_b_reg[(4*int_width_b)-1:3*int_width_b];


    always @(posedge input_reg_b3_wire_clk or posedge input_reg_b3_wire_clr)
    begin
            if (input_reg_b3_wire_clr == 1)
                mult_b_reg[(4*int_width_b)-1 : 3*int_width_b ] <= 0;
            else if ((input_reg_b3_wire_clk == 1) && (input_reg_b3_wire_en == 1))
                mult_b_reg[(4*int_width_b)-1:3*int_width_b] <= mult_b_pre[(4*int_width_b)-1:3*int_width_b];

    end
	
    // -------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_c[int_width_c-1:0])
    // Signal Registered : mult_c_pre[int_width_c-1:0]
    //
    // Register is controlled by posedge input_reg_c0_wire_clk
    // Register has a clock enable input_reg_c0_wire_en
    // Register has an asynchronous clear signal, input_reg_c0_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_c0 is unregistered and mult_c_pre[int_width_c-1:0] changes value
    // -------------------------------------------------------------------------------------

    assign mult_c_wire[int_width_c-1:0] = (input_register_c0 == "UNREGISTERED")?
                                            mult_c_pre[int_width_c-1:0]: mult_c_reg[int_width_c-1:0];

    always @(posedge input_reg_c0_wire_clk or posedge input_reg_c0_wire_clr)
    begin
            if (input_reg_c0_wire_clr == 1)
                mult_c_reg[int_width_c-1:0] <= 0;
            else if ((input_reg_c0_wire_clk == 1) && (input_reg_c0_wire_en == 1))
                mult_c_reg[int_width_c-1:0] <= mult_c_pre[int_width_c-1:0];
    end
    
    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult01_round_wire)
    // Signal Registered : mult01_round_pre
    //
    // Register is controlled by posedge mult01_round_wire_clk
    // Register has a clock enable mult01_round_wire_en
    // Register has an asynchronous clear signal, mult01_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        mult01_round_register is unregistered and mult01_round changes value
    // -------------------------------------------------------------------------------------------------
    assign mult01_round_wire = (mult01_round_register == "UNREGISTERED")? 
                                mult01_round_pre : mult01_round_reg;

    always @(posedge mult01_round_wire_clk or posedge mult01_round_wire_clr)
    begin
            if (mult01_round_wire_clr == 1)
                mult01_round_reg <= 0;
            else if ((mult01_round_wire_clk == 1) && (mult01_round_wire_en == 1))
                mult01_round_reg <= mult01_round_pre;

    end
    
    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult01_saturate_wire)
    // Signal Registered : mult01_saturation_pre
    //
    // Register is controlled by posedge mult01_saturate_wire_clk
    // Register has a clock enable mult01_saturate_wire_en
    // Register has an asynchronous clear signal, mult01_saturate_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        mult01_saturation_register is unregistered and mult01_saturate_pre changes value
    // -------------------------------------------------------------------------------------------------
    assign mult01_saturate_wire = (mult01_saturation_register == "UNREGISTERED")? 
                                    mult01_saturate_pre : mult01_saturate_reg;

    always @(posedge mult01_saturate_wire_clk or posedge mult01_saturate_wire_clr)
    begin
            if (mult01_saturate_wire_clr == 1)
                mult01_saturate_reg <= 0;
            else if ((mult01_saturate_wire_clk == 1) && (mult01_saturate_wire_en == 1))
                mult01_saturate_reg <= mult01_saturate_pre;

    end

    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult23_round_wire)
    // Signal Registered : mult23_round_pre
    //
    // Register is controlled by posedge mult23_round_wire_clk
    // Register has a clock enable mult23_round_wire_en
    // Register has an asynchronous clear signal, mult23_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        mult23_round_register is unregistered and mult23_round_pre changes value
    // -------------------------------------------------------------------------------------------------
    assign mult23_round_wire = (mult23_round_register == "UNREGISTERED")? 
                                mult23_round_pre : mult23_round_reg;

    always @(posedge mult23_round_wire_clk or posedge mult23_round_wire_clr)
    begin
            if (mult23_round_wire_clr == 1)
                mult23_round_reg <= 0;
            else if ((mult23_round_wire_clk == 1) && (mult23_round_wire_en == 1))
                mult23_round_reg <= mult23_round_pre;

    end
   
    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult23_saturate_wire)
    // Signal Registered : mult23_round_pre
    //
    // Register is controlled by posedge mult23_saturate_wire_clk
    // Register has a clock enable mult23_saturate_wire_en
    // Register has an asynchronous clear signal, mult23_saturate_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        mult23_saturation_register is unregistered and mult23_saturation_pre changes value
    // -------------------------------------------------------------------------------------------------
    assign mult23_saturate_wire =   (mult23_saturation_register == "UNREGISTERED")? 
                                    mult23_saturate_pre : mult23_saturate_reg;

    always @(posedge mult23_saturate_wire_clk or posedge mult23_saturate_wire_clr)
    begin
            if (mult23_saturate_wire_clr == 1)
                mult23_saturate_reg <= 0;
            else if ((mult23_saturate_wire_clk == 1) && (mult23_saturate_wire_en == 1))
                mult23_saturate_reg <= mult23_saturate_pre;

    end
    
    // ---------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addnsub1_round_wire)
    // Signal Registered : addnsub1_round_pre
    //
    // Register is controlled by posedge addnsub1_round_wire_clk
    // Register has a clock enable addnsub1_round_wire_en
    // Register has an asynchronous clear signal, addnsub1_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub1_round_register is unregistered and addnsub1_round_pre changes value
    // ---------------------------------------------------------------------------------
    assign addnsub1_round_wire =    (addnsub1_round_register=="UNREGISTERED")? 
                                    addnsub1_round_pre : addnsub1_round_reg;
    
    always @(posedge addnsub1_round_wire_clk or posedge addnsub1_round_wire_clr)
    begin
            if (addnsub1_round_wire_clr == 1)
                addnsub1_round_reg <= 0;
            else if ((addnsub1_round_wire_clk == 1) && (addnsub1_round_wire_en == 1))
                addnsub1_round_reg <= addnsub1_round_pre;
    end
    
    // ---------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addnsub1_round_pipe_wire)
    // Signal Registered : addnsub1_round_wire
    //
    // Register is controlled by posedge addnsub1_round_pipe_wire_clk
    // Register has a clock enable addnsub1_round_pipe_wire_en
    // Register has an asynchronous clear signal, addnsub1_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub1_round_pipeline_register is unregistered and addnsub1_round_wire changes value
    // ---------------------------------------------------------------------------------
    assign addnsub1_round_pipe_wire = (addnsub1_round_pipeline_register=="UNREGISTERED")? 
                                        addnsub1_round_wire : addnsub1_round_pipe_reg;
   
    always @(posedge addnsub1_round_pipe_wire_clk or posedge addnsub1_round_pipe_wire_clr)
    begin
            if (addnsub1_round_pipe_wire_clr == 1)
                addnsub1_round_pipe_reg <= 0;
            else if ((addnsub1_round_pipe_wire_clk == 1) && (addnsub1_round_pipe_wire_en == 1))
                addnsub1_round_pipe_reg <= addnsub1_round_wire;
    end
    
    // ---------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addnsub3_round_wire)
    // Signal Registered : addnsub3_round_pre
    //
    // Register is controlled by posedge addnsub3_round_wire_clk
    // Register has a clock enable addnsub3_round_wire_en
    // Register has an asynchronous clear signal, addnsub3_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub3_round_register is unregistered and addnsub3_round_pre changes value
    // ---------------------------------------------------------------------------------
    assign addnsub3_round_wire = (addnsub3_round_register=="UNREGISTERED")? 
                                    addnsub3_round_pre : addnsub3_round_reg;
    
    always @(posedge addnsub3_round_wire_clk or posedge addnsub3_round_wire_clr)
    begin
            if (addnsub3_round_wire_clr == 1)
                addnsub3_round_reg <= 0;
            else if ((addnsub3_round_wire_clk == 1) && (addnsub3_round_wire_en == 1))
                addnsub3_round_reg <= addnsub3_round_pre;
    end
    
    // ---------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addnsub3_round_pipe_wire)
    // Signal Registered : addnsub3_round_wire
    //
    // Register is controlled by posedge addnsub3_round_pipe_wire_clk
    // Register has a clock enable addnsub3_round_pipe_wire_en
    // Register has an asynchronous clear signal, addnsub3_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub3_round_pipeline_register is unregistered and addnsub3_round_wire changes value
    // ---------------------------------------------------------------------------------
    assign addnsub3_round_pipe_wire = (addnsub3_round_pipeline_register=="UNREGISTERED")? 
                                        addnsub3_round_wire : addnsub3_round_pipe_reg;
   
    always @(posedge addnsub3_round_pipe_wire_clk or posedge addnsub3_round_pipe_wire_clr)
    begin
            if (addnsub3_round_pipe_wire_clr == 1)
                addnsub3_round_pipe_reg <= 0;
            else if ((addnsub3_round_pipe_wire_clk == 1) && (addnsub3_round_pipe_wire_en == 1))
                addnsub3_round_pipe_reg <= addnsub3_round_wire;
    end
    
   
    // ---------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addsub1_reg)
    // Signal Registered : addsub1_int
    //
    // Register is controlled by posedge addsub1_reg_wire_clk
    // Register has a clock enable addsub1_reg_wire_en
    // Register has an asynchronous clear signal, addsub1_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub_multiplier_register1 is unregistered and addsub1_int changes value
    // ---------------------------------------------------------------------------------
    assign addsub1_wire = (addnsub_multiplier_register1=="UNREGISTERED")? addsub1_int : addsub1_reg;
    
    always @(posedge addsub1_reg_wire_clk or posedge addsub1_reg_wire_clr)
    begin
            if ((addsub1_reg_wire_clr == 1) && (addsub1_clr == 1))
                addsub1_reg <= 0;
            else if ((addsub1_reg_wire_clk == 1) && (addsub1_reg_wire_en == 1))
                addsub1_reg <= addsub1_int;
    end


    // -------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addsub1_pipe)
    // Signal Registered : addsub1_reg
    //
    // Register is controlled by posedge addsub1_pipe_wire_clk
    // Register has a clock enable addsub1_pipe_wire_en
    // Register has an asynchronous clear signal, addsub1_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub_multiplier_pipeline_register1 is unregistered and addsub1_reg changes value
    // ------------------------------------------------------------------------------------------

    assign addsub1_pipe_wire = (addnsub_multiplier_pipeline_register1 == "UNREGISTERED")? 
                                addsub1_wire : addsub1_pipe_reg;
    always @(posedge addsub1_pipe_wire_clk or posedge addsub1_pipe_wire_clr)
    begin
            if ((addsub1_pipe_wire_clr == 1) && (addsub1_clr == 1))
                addsub1_pipe_reg <= 0;
            else if ((addsub1_pipe_wire_clk == 1) && (addsub1_pipe_wire_en == 1))
                addsub1_pipe_reg <= addsub1_wire;        
    end


    // ---------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addsub3_reg)
    // Signal Registered : addsub3_int
    //
    // Register is controlled by posedge addsub3_reg_wire_clk
    // Register has a clock enable addsub3_reg_wire_en
    // Register has an asynchronous clear signal, addsub3_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub_multiplier_register3 is unregistered and addsub3_int changes value
    // ---------------------------------------------------------------------------------
    assign addsub3_wire = (addnsub_multiplier_register3=="UNREGISTERED")? 
                                addsub3_int : addsub3_reg;

    
    always @(posedge addsub3_reg_wire_clk or posedge addsub3_reg_wire_clr)
    begin
            if ((addsub3_reg_wire_clr == 1) && (addsub3_clr == 1))
                addsub3_reg <= 0;
            else if ((addsub3_reg_wire_clk == 1) && (addsub3_reg_wire_en == 1))
                addsub3_reg <= addsub3_int;
    end


    // -------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addsub3_pipe)
    // Signal Registered : addsub3_reg
    //
    // Register is controlled by posedge addsub3_pipe_wire_clk
    // Register has a clock enable addsub3_pipe_wire_en
    // Register has an asynchronous clear signal, addsub3_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub_multiplier_pipeline_register3 is unregistered and addsub3_reg changes value
    // ------------------------------------------------------------------------------------------
    assign addsub3_pipe_wire = (addnsub_multiplier_pipeline_register3 == "UNREGISTERED")? 
                                addsub3_wire  : addsub3_pipe_reg;

    always @(posedge addsub3_pipe_wire_clk or posedge addsub3_pipe_wire_clr)
    begin
            if ((addsub3_pipe_wire_clr == 1) && (addsub3_clr == 1))
                addsub3_pipe_reg <= 0;
            else if ((addsub3_pipe_wire_clk == 1) && (addsub3_pipe_wire_en == 1))
                addsub3_pipe_reg <= addsub3_wire;
    end


    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_a_reg)
    // Signal Registered : sign_a_int
    //
    // Register is controlled by posedge sign_reg_a_wire_clk
    // Register has a clock enable sign_reg_a_wire_en
    // Register has an asynchronous clear signal, sign_reg_a_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        signed_register_a is unregistered and sign_a_int changes value
    // ----------------------------------------------------------------------------

    assign ena_aclr_signa_wire = ((port_signa == "PORT_USED") || ((port_signa == "PORT_CONNECTIVITY") && ((representation_a == "UNUSED") || (signa !==1'bz )))) ? 1'b1 : 1'b0;
    assign sign_a_wire = (signed_register_a == "UNREGISTERED")? sign_a_int : sign_a_reg;
    always @(posedge sign_reg_a_wire_clk or posedge sign_reg_a_wire_clr)
    begin
            if ((sign_reg_a_wire_clr == 1) && (ena_aclr_signa_wire == 1'b1))
                sign_a_reg <= 0;
            else if ((sign_reg_a_wire_clk == 1) && (sign_reg_a_wire_en == 1))
                sign_a_reg <= sign_a_int;
    end


    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_a_pipe)
    // Signal Registered : sign_a_reg
    //
    // Register is controlled by posedge sign_pipe_a_wire_clk
    // Register has a clock enable sign_pipe_a_wire_en
    // Register has an asynchronous clear signal, sign_pipe_a_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        signed_pipeline_register_a is unregistered and sign_a_reg changes value
    // ------------------------------------------------------------------------------

    assign sign_a_pipe_wire = (signed_pipeline_register_a == "UNREGISTERED")? sign_a_wire : sign_a_pipe_reg;
    always @(posedge sign_pipe_a_wire_clk or posedge sign_pipe_a_wire_clr)
    begin
            if ((sign_pipe_a_wire_clr == 1) && (ena_aclr_signa_wire == 1'b1))
                sign_a_pipe_reg <= 0;
            else if ((sign_pipe_a_wire_clk == 1) && (sign_pipe_a_wire_en == 1))
                sign_a_pipe_reg <= sign_a_wire;
    end


    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_b_reg)
    // Signal Registered : sign_b_int
    //
    // Register is controlled by posedge sign_reg_b_wire_clk
    // Register has a clock enable sign_reg_b_wire_en
    // Register has an asynchronous clear signal, sign_reg_b_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        signed_register_b is unregistered and sign_b_int changes value
    // ----------------------------------------------------------------------------
    assign ena_aclr_signb_wire = ((port_signb == "PORT_USED") || ((port_signb == "PORT_CONNECTIVITY") && ((representation_b == "UNUSED") || (signb !==1'bz )))) ? 1'b1 : 1'b0;
    assign sign_b_wire = (signed_register_b == "UNREGISTERED")? sign_b_int : sign_b_reg;

    always @(posedge sign_reg_b_wire_clk or posedge sign_reg_b_wire_clr)
    begin
            if ((sign_reg_b_wire_clr == 1) && (ena_aclr_signb_wire == 1'b1))
                sign_b_reg <= 0;
            else if ((sign_reg_b_wire_clk == 1) && (sign_reg_b_wire_en == 1))
                sign_b_reg <= sign_b_int;

    end


    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_b_pipe)
    // Signal Registered : sign_b_reg
    //
    // Register is controlled by posedge sign_pipe_b_wire_clk
    // Register has a clock enable sign_pipe_b_wire_en
    // Register has an asynchronous clear signal, sign_pipe_b_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        signed_pipeline_register_b is unregistered and sign_b_reg changes value
    // ------------------------------------------------------------------------------
    assign sign_b_pipe_wire = (signed_pipeline_register_b == "UNREGISTERED")? sign_b_wire : sign_b_pipe_reg;
    always @(posedge sign_pipe_b_wire_clk or posedge sign_pipe_b_wire_clr)

    begin
            if ((sign_pipe_b_wire_clr == 1) && (ena_aclr_signb_wire == 1'b1))
                sign_b_pipe_reg <= 0;
            else if ((sign_pipe_b_wire_clk == 1) && (sign_pipe_b_wire_en == 1))
                sign_b_pipe_reg <= sign_b_wire;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set outround_reg/wire)
    // Signal Registered : outround_int
    //
    // Register is controlled by posedge outround_reg_wire_clk
    // Register has a clock enable outround_reg_wire_en
    // Register has an asynchronous clear signal, outround_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        output_round_register is unregistered and outround_int changes value
    // ------------------------------------------------------------------------------
    assign outround_wire = (output_round_register == "UNREGISTERED")? outround_int : outround_reg;
    always @(posedge outround_reg_wire_clk or posedge outround_reg_wire_clr)

    begin
            if (outround_reg_wire_clr == 1)
                outround_reg <= 0;
            else if ((outround_reg_wire_clk == 1) && (outround_reg_wire_en == 1))
                outround_reg <= outround_int;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set outround_pipe_wire)
    // Signal Registered : outround_wire
    //
    // Register is controlled by posedge outround_pipe_wire_clk
    // Register has a clock enable outround_pipe_wire_en
    // Register has an asynchronous clear signal, outround_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        output_round_pipeline_register is unregistered and outround_wire changes value
    // ------------------------------------------------------------------------------
    assign outround_pipe_wire = (output_round_pipeline_register == "UNREGISTERED")? outround_wire : outround_pipe_reg;
    always @(posedge outround_pipe_wire_clk or posedge outround_pipe_wire_clr)

    begin
            if (outround_pipe_wire_clr == 1)
                outround_pipe_reg <= 0;
            else if ((outround_pipe_wire_clk == 1) && (outround_pipe_wire_en == 1))
                outround_pipe_reg <= outround_wire;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set chainout_round_reg/wire)
    // Signal Registered : chainout_round_int
    //
    // Register is controlled by posedge chainout_round_reg_wire_clk
    // Register has a clock enable chainout_round_reg_wire_en
    // Register has an asynchronous clear signal, chainout_round_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        chainout_round_register is unregistered and chainout_round_int changes value
    // ------------------------------------------------------------------------------
    assign chainout_round_wire = (chainout_round_register == "UNREGISTERED")? chainout_round_int : chainout_round_reg;
    always @(posedge chainout_round_reg_wire_clk or posedge chainout_round_reg_wire_clr)

    begin
            if (chainout_round_reg_wire_clr == 1)
                chainout_round_reg <= 0;
            else if ((chainout_round_reg_wire_clk == 1) && (chainout_round_reg_wire_en == 1))
                chainout_round_reg <= chainout_round_int;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set chainout_round_pipe_reg/wire)
    // Signal Registered : chainout_round_wire
    //
    // Register is controlled by posedge chainout_round_pipe_wire_clk
    // Register has a clock enable chainout_round_pipe_wire_en
    // Register has an asynchronous clear signal, chainout_round_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        chainout_round_pipeline_register is unregistered and chainout_round_wire changes value
    // ------------------------------------------------------------------------------
    assign chainout_round_pipe_wire = (chainout_round_pipeline_register == "UNREGISTERED")? chainout_round_wire : chainout_round_pipe_reg;
    always @(posedge chainout_round_pipe_wire_clk or posedge chainout_round_pipe_wire_clr)

    begin
            if (chainout_round_pipe_wire_clr == 1)
                chainout_round_pipe_reg <= 0;
            else if ((chainout_round_pipe_wire_clk == 1) && (chainout_round_pipe_wire_en == 1))
                chainout_round_pipe_reg <= chainout_round_wire;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set chainout_round_out_reg/wire)
    // Signal Registered : chainout_round_pipe_wire
    //
    // Register is controlled by posedge chainout_round_out_reg_wire_clk
    // Register has a clock enable chainout_round_out_reg_wire_en
    // Register has an asynchronous clear signal, chainout_round_out_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        chainout_round_output_register is unregistered and chainout_round_pipe_wire changes value
    // ------------------------------------------------------------------------------
    assign chainout_round_out_wire = (chainout_round_output_register == "UNREGISTERED")? chainout_round_pipe_wire : chainout_round_out_reg;
    always @(posedge chainout_round_out_reg_wire_clk or posedge chainout_round_out_reg_wire_clr)

    begin
            if (chainout_round_out_reg_wire_clr == 1)
                chainout_round_out_reg <= 0;
            else if ((chainout_round_out_reg_wire_clk == 1) && (chainout_round_out_reg_wire_en == 1))
                chainout_round_out_reg <= chainout_round_pipe_wire;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set outsat_reg/wire)
    // Signal Registered : outsat_int
    //
    // Register is controlled by posedge outsat_reg_wire_clk
    // Register has a clock enable outsat_reg_wire_en
    // Register has an asynchronous clear signal, outsat_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        output_saturate_register is unregistered and outsat_int changes value
    // ------------------------------------------------------------------------------
    assign outsat_wire = (output_saturate_register == "UNREGISTERED")? outsat_int : outsat_reg;
    always @(posedge outsat_reg_wire_clk or posedge outsat_reg_wire_clr)

    begin
            if (outsat_reg_wire_clr == 1)
                outsat_reg <= 0;
            else if ((outsat_reg_wire_clk == 1) && (outsat_reg_wire_en == 1))
                outsat_reg <= outsat_int;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set outsat_pipe_wire)
    // Signal Registered : outsat_wire
    //
    // Register is controlled by posedge outsat_pipe_wire_clk
    // Register has a clock enable outsat_pipe_wire_en
    // Register has an asynchronous clear signal, outsat_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        output_saturate_pipeline_register is unregistered and outsat_wire changes value
    // ------------------------------------------------------------------------------
    assign outsat_pipe_wire = (output_saturate_pipeline_register == "UNREGISTERED")? outsat_wire : outsat_pipe_reg;
    always @(posedge outsat_pipe_wire_clk or posedge outsat_pipe_wire_clr)

    begin
            if (outsat_pipe_wire_clr == 1)
                outsat_pipe_reg <= 0;
            else if ((outsat_pipe_wire_clk == 1) && (outsat_pipe_wire_en == 1))
                outsat_pipe_reg <= outsat_wire;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set chainout_sat_reg/wire)
    // Signal Registered : chainout_sat_int
    //
    // Register is controlled by posedge chainout_sat_reg_wire_clk
    // Register has a clock enable chainout_sat_reg_wire_en
    // Register has an asynchronous clear signal, chainout_sat_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        chainout_saturate_register is unregistered and chainout_sat_int changes value
    // ------------------------------------------------------------------------------
    assign chainout_sat_wire = (chainout_saturate_register == "UNREGISTERED")? chainout_sat_int : chainout_sat_reg;
    always @(posedge chainout_sat_reg_wire_clk or posedge chainout_sat_reg_wire_clr)

    begin
            if (chainout_sat_reg_wire_clr == 1)
                chainout_sat_reg <= 0;
            else if ((chainout_sat_reg_wire_clk == 1) && (chainout_sat_reg_wire_en == 1))
                chainout_sat_reg <= chainout_sat_int;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set chainout_sat_pipe_reg/wire)
    // Signal Registered : chainout_sat_wire
    //
    // Register is controlled by posedge chainout_sat_pipe_wire_clk
    // Register has a clock enable chainout_sat_pipe_wire_en
    // Register has an asynchronous clear signal, chainout_sat_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        chainout_saturate_pipeline_register is unregistered and chainout_sat_wire changes value
    // ------------------------------------------------------------------------------
    assign chainout_sat_pipe_wire = (chainout_saturate_pipeline_register == "UNREGISTERED")? chainout_sat_wire : chainout_sat_pipe_reg;
    always @(posedge chainout_sat_pipe_wire_clk or posedge chainout_sat_pipe_wire_clr)

    begin
            if (chainout_sat_pipe_wire_clr == 1)
                chainout_sat_pipe_reg <= 0;
            else if ((chainout_sat_pipe_wire_clk == 1) && (chainout_sat_pipe_wire_en == 1))
                chainout_sat_pipe_reg <= chainout_sat_wire;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set chainout_sat_out_reg/wire)
    // Signal Registered : chainout_sat_pipe_wire
    //
    // Register is controlled by posedge chainout_sat_out_reg_wire_clk
    // Register has a clock enable chainout_sat_out_reg_wire_en
    // Register has an asynchronous clear signal, chainout_sat_out_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        chainout_saturate_output_register is unregistered and chainout_sat_pipe_wire changes value
    // ------------------------------------------------------------------------------
    assign chainout_sat_out_wire = (chainout_saturate_output_register == "UNREGISTERED")? chainout_sat_pipe_wire : chainout_sat_out_reg;
    always @(posedge chainout_sat_out_reg_wire_clk or posedge chainout_sat_out_reg_wire_clr)

    begin
            if (chainout_sat_out_reg_wire_clr == 1)
                chainout_sat_out_reg <= 0;
            else if ((chainout_sat_out_reg_wire_clk == 1) && (chainout_sat_out_reg_wire_en == 1))
                chainout_sat_out_reg <= chainout_sat_pipe_wire;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set scanouta_reg/wire)
    // Signal Registered : mult_a_wire
    //
    // Register is controlled by posedge scanouta_reg_wire_clk
    // Register has a clock enable scanouta_reg_wire_en
    // Register has an asynchronous clear signal, scanouta_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        scanouta_register is unregistered and mult_a_wire changes value
    // ------------------------------------------------------------------------------
    
    assign scanouta_wire[int_width_a -1 : 0] =  (scanouta_register == "UNREGISTERED")?        
                                                (chainout_adder == "YES" && (width_result > width_a + width_b + 8))?
                                                mult_a_wire[(number_of_multipliers * int_width_a) - 1 -  (int_width_a - width_a) : ((number_of_multipliers-1) * int_width_a)]: 
                                                mult_a_wire[(number_of_multipliers * int_width_a) - 1 : ((number_of_multipliers-1) * int_width_a) + (int_width_a - width_a)]: 
                                                scanouta_reg;             
                                                
    always @(posedge scanouta_reg_wire_clk or posedge scanouta_reg_wire_clr)

    begin
            if (scanouta_reg_wire_clr == 1)
                scanouta_reg[int_width_a -1 : 0] <= 0;
            else if ((scanouta_reg_wire_clk == 1) && (scanouta_reg_wire_en == 1))
                if(chainout_adder == "YES" && (width_result > width_a + width_b + 8))
                    scanouta_reg[int_width_a - 1 : 0] <= mult_a_wire[(number_of_multipliers * int_width_a) - 1 -  (int_width_a - width_a) : ((number_of_multipliers-1) * int_width_a)];
                else
                scanouta_reg[int_width_a -1 : 0] <= mult_a_wire[(number_of_multipliers * int_width_a) - 1 : ((number_of_multipliers-1) * int_width_a) + (int_width_a - width_a)];  
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set zerochainout_reg/wire)
    // Signal Registered : zero_chainout_int
    //
    // Register is controlled by posedge zerochainout_reg_wire_clk
    // Register has a clock enable zerochainout_reg_wire_en
    // Register has an asynchronous clear signal, zerochainout_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        zero_chainout_output_register is unregistered and zero_chainout_int changes value
    // ------------------------------------------------------------------------------
    assign zerochainout_wire = (zero_chainout_output_register == "UNREGISTERED")? zerochainout_int
                                : zerochainout_reg;
    always @(posedge zerochainout_reg_wire_clk or posedge zerochainout_reg_wire_clr)

    begin
            if (zerochainout_reg_wire_clr == 1)
                zerochainout_reg <= 0;
            else if ((zerochainout_reg_wire_clk == 1) && (zerochainout_reg_wire_en == 1))
                zerochainout_reg <= zerochainout_int;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set rotate_reg/wire)
    // Signal Registered : rotate_int
    //
    // Register is controlled by posedge rotate_reg_wire_clk
    // Register has a clock enable rotate_reg_wire_en
    // Register has an asynchronous clear signal, rotate_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        rotate_register is unregistered and rotate_int changes value
    // ------------------------------------------------------------------------------
    assign rotate_wire = (rotate_register == "UNREGISTERED")? rotate_int
                                : rotate_reg;
    always @(posedge rotate_reg_wire_clk or posedge rotate_reg_wire_clr)

    begin
            if (rotate_reg_wire_clr == 1)
                rotate_reg <= 0;
            else if ((rotate_reg_wire_clk == 1) && (rotate_reg_wire_en == 1))
                rotate_reg <= rotate_int;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set rotate_pipe_reg/wire)
    // Signal Registered : rotate_wire
    //
    // Register is controlled by posedge rotate_pipe_wire_clk
    // Register has a clock enable rotate_pipe_wire_en
    // Register has an asynchronous clear signal, rotate_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        rotate_pipeline_register is unregistered and rotate_wire changes value
    // ------------------------------------------------------------------------------
    assign rotate_pipe_wire = (rotate_pipeline_register == "UNREGISTERED")? rotate_wire
                                : rotate_pipe_reg;
    always @(posedge rotate_pipe_wire_clk or posedge rotate_pipe_wire_clr)

    begin
            if (rotate_pipe_wire_clr == 1)
                rotate_pipe_reg <= 0;
            else if ((rotate_pipe_wire_clk == 1) && (rotate_pipe_wire_en == 1))
                rotate_pipe_reg <= rotate_wire;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set rotate_out_reg/wire)
    // Signal Registered : rotate_pipe_wire
    //
    // Register is controlled by posedge rotate_out_reg_wire_clk
    // Register has a clock enable rotate_out_reg_wire_en
    // Register has an asynchronous clear signal, rotate_out_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        rotate_output_register is unregistered and rotate_pipe_wire changes value
    // ------------------------------------------------------------------------------
    assign rotate_out_wire = (rotate_output_register == "UNREGISTERED")? rotate_pipe_wire
                                : rotate_out_reg;
    always @(posedge rotate_out_reg_wire_clk or posedge rotate_out_reg_wire_clr)

    begin
            if (rotate_out_reg_wire_clr == 1)
                rotate_out_reg <= 0;
            else if ((rotate_out_reg_wire_clk == 1) && (rotate_out_reg_wire_en == 1))
                rotate_out_reg <= rotate_pipe_wire;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set shiftr_reg/wire)
    // Signal Registered : shiftr_int
    //
    // Register is controlled by posedge shiftr_reg_wire_clk
    // Register has a clock enable shiftr_reg_wire_en
    // Register has an asynchronous clear signal, shiftr_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        shift_right_register is unregistered and shiftr_int changes value
    // ------------------------------------------------------------------------------
    assign shiftr_wire = (shift_right_register == "UNREGISTERED")? shiftr_int
                                : shiftr_reg;
    always @(posedge shiftr_reg_wire_clk or posedge shiftr_reg_wire_clr)

    begin
            if (shiftr_reg_wire_clr == 1)
                shiftr_reg <= 0;
            else if ((shiftr_reg_wire_clk == 1) && (shiftr_reg_wire_en == 1))
                shiftr_reg <= shiftr_int;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set shiftr_pipe_reg/wire)
    // Signal Registered : shiftr_wire
    //
    // Register is controlled by posedge shiftr_pipe_wire_clk
    // Register has a clock enable shiftr_pipe_wire_en
    // Register has an asynchronous clear signal, shiftr_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        shift_right_pipeline_register is unregistered and shiftr_wire changes value
    // ------------------------------------------------------------------------------
    assign shiftr_pipe_wire = (shift_right_pipeline_register == "UNREGISTERED")? shiftr_wire
                                : shiftr_pipe_reg;
    always @(posedge shiftr_pipe_wire_clk or posedge shiftr_pipe_wire_clr)

    begin
            if (shiftr_pipe_wire_clr == 1)
                shiftr_pipe_reg <= 0;
            else if ((shiftr_pipe_wire_clk == 1) && (shiftr_pipe_wire_en == 1))
                shiftr_pipe_reg <= shiftr_wire;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set shiftr_out_reg/wire)
    // Signal Registered : shiftr_pipe_wire
    //
    // Register is controlled by posedge shiftr_out_reg_wire_clk
    // Register has a clock enable shiftr_out_reg_wire_en
    // Register has an asynchronous clear signal, shiftr_out_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        shift_right_output_register is unregistered and shiftr_pipe_wire changes value
    // ------------------------------------------------------------------------------
    assign shiftr_out_wire = (shift_right_output_register == "UNREGISTERED")? shiftr_pipe_wire
                                : shiftr_out_reg;
    always @(posedge shiftr_out_reg_wire_clk or posedge shiftr_out_reg_wire_clr)

    begin
            if (shiftr_out_reg_wire_clr == 1)
                shiftr_out_reg <= 0;
            else if ((shiftr_out_reg_wire_clk == 1) && (shiftr_out_reg_wire_en == 1))
                shiftr_out_reg <= shiftr_pipe_wire;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set zeroloopback_reg/wire)
    // Signal Registered : zeroloopback_int
    //
    // Register is controlled by posedge zeroloopback_reg_wire_clk
    // Register has a clock enable zeroloopback_reg_wire_en
    // Register has an asynchronous clear signal, zeroloopback_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        zero_loopback_register is unregistered and zeroloopback_int changes value
    // ------------------------------------------------------------------------------
    assign zeroloopback_wire = (zero_loopback_register == "UNREGISTERED")? zeroloopback_int
                                : zeroloopback_reg;
    always @(posedge zeroloopback_reg_wire_clk or posedge zeroloopback_reg_wire_clr)
    begin
            if (zeroloopback_reg_wire_clr == 1)
                zeroloopback_reg <= 0;
            else if ((zeroloopback_reg_wire_clk == 1) && (zeroloopback_reg_wire_en == 1))
                zeroloopback_reg <= zeroloopback_int;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set zeroloopback_pipe_reg/wire)
    // Signal Registered : zeroloopback_wire
    //
    // Register is controlled by posedge zeroloopback_pipe_wire_clk
    // Register has a clock enable zeroloopback_pipe_wire_en
    // Register has an asynchronous clear signal, zeroloopback_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        zero_loopback_pipeline_register is unregistered and zeroloopback_wire changes value
    // ------------------------------------------------------------------------------
    assign zeroloopback_pipe_wire = (zero_loopback_pipeline_register == "UNREGISTERED")? zeroloopback_wire
                                : zeroloopback_pipe_reg;
    always @(posedge zeroloopback_pipe_wire_clk or posedge zeroloopback_pipe_wire_clr)
    begin
            if (zeroloopback_pipe_wire_clr == 1)
                zeroloopback_pipe_reg <= 0;
            else if ((zeroloopback_pipe_wire_clk == 1) && (zeroloopback_pipe_wire_en == 1))
                zeroloopback_pipe_reg <= zeroloopback_wire;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set zeroloopback_out_reg/wire)
    // Signal Registered : zeroloopback_pipe_wire
    //
    // Register is controlled by posedge zeroloopback_out_wire_clk
    // Register has a clock enable zeroloopback_out_wire_en
    // Register has an asynchronous clear signal, zeroloopback_out_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        zero_loopback_output_register is unregistered and zeroloopback_pipe_wire changes value
    // ------------------------------------------------------------------------------
    assign zeroloopback_out_wire = (zero_loopback_output_register == "UNREGISTERED")? zeroloopback_pipe_wire
                                : zeroloopback_out_reg;
    always @(posedge zeroloopback_out_wire_clk or posedge zeroloopback_out_wire_clr)
    begin
            if (zeroloopback_out_wire_clr == 1)
                zeroloopback_out_reg <= 0;
            else if ((zeroloopback_out_wire_clk == 1) && (zeroloopback_out_wire_en == 1))
                zeroloopback_out_reg <= zeroloopback_pipe_wire;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set accumsload_reg/wire)
    // Signal Registered : accumsload_int
    //
    // Register is controlled by posedge accumsload_reg_wire_clk
    // Register has a clock enable accumsload_reg_wire_en
    // Register has an asynchronous clear signal, accumsload_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_sload_register is unregistered and accumsload_int changes value
    // ------------------------------------------------------------------------------
    assign accumsload_wire = (accum_sload_register == "UNREGISTERED")? accumsload_int
                                : accumsload_reg;
    always @(posedge accumsload_reg_wire_clk or posedge accumsload_reg_wire_clr)
    begin
            if (accumsload_reg_wire_clr == 1)
                accumsload_reg <= 0;
            else if ((accumsload_reg_wire_clk == 1) && (accumsload_reg_wire_en == 1))
                accumsload_reg <= accumsload_int;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set accumsload_pipe_reg/wire)
    // Signal Registered : accumsload_wire
    //
    // Register is controlled by posedge accumsload_pipe_wire_clk
    // Register has a clock enable accumsload_pipe_wire_en
    // Register has an asynchronous clear signal, accumsload_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_sload_pipeline_register is unregistered and accumsload_wire changes value
    // ------------------------------------------------------------------------------
    assign accumsload_pipe_wire = (accum_sload_pipeline_register == "UNREGISTERED")? accumsload_wire
                                : accumsload_pipe_reg;
    always @(posedge accumsload_pipe_wire_clk or posedge accumsload_pipe_wire_clr)
    begin
            if (accumsload_pipe_wire_clr == 1)
                accumsload_pipe_reg <= 0;
            else if ((accumsload_pipe_wire_clk == 1) && (accumsload_pipe_wire_en == 1))
                accumsload_pipe_reg <= accumsload_wire;
    end
    
    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set coeffsela_reg/wire)
    // Signal Registered : coeffsel_a_int
    //
    // Register is controlled by posedge coeffsela_reg_wire_clk
    // Register has a clock enable coeffsela_reg_wire_en
    // Register has an asynchronous clear signal, coeffsela_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        coefsel0_register is unregistered and coeffsel_a_int changes value
    // ------------------------------------------------------------------------------
    assign coeffsel_a_wire = (coefsel0_register == "UNREGISTERED")? coeffsel_a_int
                                : coeffsel_a_reg;
    always @(posedge coeffsela_reg_wire_clk or posedge coeffsela_reg_wire_clr)
    begin
            if (coeffsela_reg_wire_clr == 1)
                coeffsel_a_reg <= 0;
            else if ((coeffsela_reg_wire_clk == 1) && (coeffsela_reg_wire_en == 1))
                coeffsel_a_reg <= coeffsel_a_int;
    end
    
    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set coeffselb_reg/wire)
    // Signal Registered : coeffsel_b_int
    //
    // Register is controlled by posedge coeffselb_reg_wire_clk
    // Register has a clock enable coeffselb_reg_wire_en
    // Register has an asynchronous clear signal, coeffselb_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        coefsel1_register is unregistered and coeffsel_b_int changes value
    // ------------------------------------------------------------------------------
    assign coeffsel_b_wire = (coefsel1_register == "UNREGISTERED")? coeffsel_b_int
                                : coeffsel_b_reg;
    always @(posedge coeffselb_reg_wire_clk or posedge coeffselb_reg_wire_clr)
    begin
            if (coeffselb_reg_wire_clr == 1)
                coeffsel_b_reg <= 0;
            else if ((coeffselb_reg_wire_clk == 1) && (coeffselb_reg_wire_en == 1))
                coeffsel_b_reg <= coeffsel_b_int;
    end
    
    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set coeffselc_reg/wire)
    // Signal Registered : coeffsel_c_int
    //
    // Register is controlled by posedge coeffselc_reg_wire_clk
    // Register has a clock enable coeffselc_reg_wire_en
    // Register has an asynchronous clear signal, coeffselc_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        coefsel2_register is unregistered and coeffsel_c_int changes value
    // ------------------------------------------------------------------------------
    assign coeffsel_c_wire = (coefsel2_register == "UNREGISTERED")? coeffsel_c_int
                                : coeffsel_c_reg;
    always @(posedge coeffselc_reg_wire_clk or posedge coeffselc_reg_wire_clr)
    begin
            if (coeffselc_reg_wire_clr == 1)
                coeffsel_c_reg <= 0;
            else if ((coeffselc_reg_wire_clk == 1) && (coeffselc_reg_wire_en == 1))
                coeffsel_c_reg <= coeffsel_c_int;
    end
    
    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set coeffseld_reg/wire)
    // Signal Registered : coeffsel_d_int
    //
    // Register is controlled by posedge coeffseld_reg_wire_clk
    // Register has a clock enable coeffseld_reg_wire_en
    // Register has an asynchronous clear signal, coeffseld_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        coefsel3_register is unregistered and coeffsel_d_int changes value
    // ------------------------------------------------------------------------------
    assign coeffsel_d_wire = (coefsel3_register == "UNREGISTERED")? coeffsel_d_int
                                : coeffsel_d_reg;
    always @(posedge coeffseld_reg_wire_clk or posedge coeffseld_reg_wire_clr)
    begin
            if (coeffseld_reg_wire_clr == 1)
                coeffsel_d_reg <= 0;
            else if ((coeffseld_reg_wire_clk == 1) && (coeffseld_reg_wire_en == 1))
                coeffsel_d_reg <= coeffsel_d_int;
    end
    
    //This will perform the Preadder mode in StratixV
    // --------------------------------------------------------
    // This block basically calls the task do_preadder_sub/add() to set 
    // the value of preadder_res_0[2*int_width_result - 1:0]
    // sign_a_reg or sign_b_reg will trigger the task call.
    // --------------------------------------------------------
    assign preadder_res_wire[(int_width_preadder - 1) :0] = preadder0_result[(int_width_preadder  - 1) :0];

    always @(preadder_res_0)
    begin
	preadder0_result  <= preadder_res_0; 
    end
   
    always @(mult_a_wire[(int_width_a *1) -1 : (int_width_a*0)] or mult_b_wire[(int_width_b  *1) -1 : (int_width_b *0)] or
            sign_a_wire )
    begin
    	if(stratixv_block && (preadder_mode == "COEF" || preadder_mode == "INPUT" || preadder_mode == "SQUARE" ))
    	begin
			if(preadder_direction_0 == "ADD")
		        preadder_res_0 = do_preadder_add (0, sign_a_wire, sign_a_wire);
			else
				preadder_res_0 = do_preadder_sub (0, sign_a_wire, sign_a_wire);	
		end
    end
    
    // --------------------------------------------------------
    // This block basically calls the task do_preadder_sub/add() to set 
    // the value of preadder_res_1[2*int_width_result - 1:0]
    // sign_a_reg or sign_b_reg will trigger the task call.
    // --------------------------------------------------------
    assign preadder_res_wire[(((int_width_preadder) *2) - 1) : (int_width_preadder)] = preadder1_result[(int_width_preadder - 1) :0];

    always @(preadder_res_1)
    begin
	preadder1_result  <= preadder_res_1; 
    end
   
    always @(mult_a_wire[(int_width_a *2) -1 : (int_width_a*1)] or mult_b_wire[(int_width_b  *2) -1 : (int_width_b *1)] or
            sign_a_wire )
    begin
    	if(stratixv_block && (preadder_mode == "COEF" || preadder_mode == "INPUT" || preadder_mode == "SQUARE" ))
    	begin
			if(preadder_direction_1 == "ADD")
		        preadder_res_1 = do_preadder_add (1, sign_a_wire, sign_a_wire);
			else
				preadder_res_1 = do_preadder_sub (1, sign_a_wire, sign_a_wire);	
		end
    end
    
    // --------------------------------------------------------
    // This block basically calls the task do_preadder_sub/add() to set 
    // the value of preadder_res_2[2*int_width_result - 1:0]
    // sign_a_reg or sign_b_reg will trigger the task call.
    // --------------------------------------------------------
    assign preadder_res_wire[((int_width_preadder) *3) -1 : (2*(int_width_preadder))] = preadder2_result[(int_width_preadder - 1) :0];

    always @(preadder_res_2)
    begin
	preadder2_result  <= preadder_res_2; 
    end
   
    always @(mult_a_wire[(int_width_a *3) -1 : (int_width_a*2)] or mult_b_wire[(int_width_b  *3) -1 : (int_width_b *2)] or
            sign_a_wire )
    begin
    	if(stratixv_block && (preadder_mode == "COEF" || preadder_mode == "INPUT" || preadder_mode == "SQUARE" ))
    	begin
			if(preadder_direction_2 == "ADD")
		        preadder_res_2 = do_preadder_add (2, sign_a_wire, sign_a_wire);
			else
				preadder_res_2 = do_preadder_sub (2, sign_a_wire, sign_a_wire);	
		end
    end
    
    // --------------------------------------------------------
    // This block basically calls the task do_preadder_sub/add() to set 
    // the value of preadder_res_3[2*int_width_result - 1:0]
    // sign_a_reg or sign_b_reg will trigger the task call.
    // --------------------------------------------------------
    assign preadder_res_wire[((int_width_preadder) *4) -1 : 3*(int_width_preadder)] = preadder3_result[(int_width_preadder - 1) :0];

    always @(preadder_res_3)
    begin
	preadder3_result  <= preadder_res_3; 
    end
   
    always @(mult_a_wire[(int_width_a *4) -1 : (int_width_a*3)] or mult_b_wire[(int_width_b  *4) -1 : (int_width_b *3)] or
            sign_a_wire)
    begin
    	if(stratixv_block && (preadder_mode == "COEF" || preadder_mode == "INPUT" || preadder_mode == "SQUARE" ))
    	begin
			if(preadder_direction_3 == "ADD")
		        preadder_res_3 = do_preadder_add (3, sign_a_wire, sign_a_wire);
			else
				preadder_res_3 = do_preadder_sub (3, sign_a_wire, sign_a_wire);
		end
    end
    
  
    // --------------------------------------------------------
    // This block basically calls the task do_multiply() to set 
    // the value of mult_res_0[(int_width_a + int_width_b) -1 :0]
    //
    // If multiplier_register0 is registered, the call of the task 
    // will be triggered by a posedge multiplier_reg0_wire_clk. 
    // It also has an asynchronous clear signal multiplier_reg0_wire_clr
    //
    // If multiplier_register0 is unregistered, a change of value 
    // in either mult_a[int_width_a-1:0], mult_b[int_width_a-1:0], 
    // sign_a_reg or sign_b_reg will trigger the task call.
    // --------------------------------------------------------
    assign mult_res_wire[(int_width_a + int_width_b - 1) :0] =  ((multiplier_register0 == "UNREGISTERED") || (stratixiii_block == 1) || (stratixv_block == 1))?
                                                                mult0_result[(int_width_a + int_width_b - 1) :0] : 
                                                                mult_res_reg[(int_width_a + int_width_b - 1) :0];

    assign mult_saturate_overflow_vec[0] =  (multiplier_register0 == "UNREGISTERED")?
                                            mult0_saturate_overflow : mult_saturate_overflow_reg[0];
                                                 

    // This always block is to perform the rounding and saturation operations (StratixII only)
    always @(mult_res_0 or mult01_round_wire or mult01_saturate_wire)
    begin
        if (stratixii_block) 
        begin
            // -------------------------------------------------------
            // Stratix II Rounding support 
            // This block basically carries out the rounding for the 
            // mult_res_0. The equation to get the mult0_round_out is
            // obtained from the Stratix II Mac FFD which is below:
            // round_adder_constant = (1 << (wfraction - wfraction_round - 1))
            // roundout[] = datain[] + round_adder_constant
            // For Stratix II rounding, we round up the bits to 15 bits
            // or in another word wfraction_round = 15.
            // --------------------------------------------------------
        
            if ((multiplier01_rounding == "YES") ||
                ((multiplier01_rounding == "VARIABLE") && (mult01_round_wire == 1)))
            begin
                mult0_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_0[(int_width_a + int_width_b) -1 :0] + ( 1 << (`MULT_ROUND_BITS - 1));
            end
            else
            begin
                mult0_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_0[(int_width_a + int_width_b) -1 :0];
            end
            
            mult0_round_out[((int_width_a + int_width_b) + 2) : (int_width_a + int_width_b)] = {2{1'b0}};

            // -------------------------------------------------------
            // Stratix II Saturation support
            // This carries out the saturation for mult0_round_out.
            // The equation to get the saturated result is obtained 
            // from Stratix II MAC FFD which is below:
            // satoverflow = 1 if sign bit is different
            // satvalue[wtotal-1 : wfraction] = roundout[wtotal-1]
            // satvalue[wfraction-1 : 0] = !roundout[wtotal-1]
            // -------------------------------------------------------

            if ((multiplier01_saturation == "YES") || 
                (( multiplier01_saturation == "VARIABLE") && (mult01_saturate_wire == 1)))
            begin
                
                mult0_saturate_overflow_stat = (~mult0_round_out[int_width_a + int_width_b - 1]) && mult0_round_out[int_width_a + int_width_b - 2];
                
                if (mult0_saturate_overflow_stat == 0)
                begin
                    mult0_saturate_out = mult0_round_out;
                    mult0_saturate_overflow = mult0_round_out[0];
                end
                else
                begin
                    
                    // We are doing Q2.31 saturation
                    for (num_bit_mult0 = (int_width_a + int_width_b - 1); num_bit_mult0 >= (int_width_a + int_width_b - 2); num_bit_mult0 = num_bit_mult0 - 1)
                    begin
                        mult0_saturate_out[num_bit_mult0] = mult0_round_out[int_width_a + int_width_b - 1];
                    end

                    for (num_bit_mult0 = sat_ini_value; num_bit_mult0 >= 3; num_bit_mult0 = num_bit_mult0 - 1)
                    begin
                        mult0_saturate_out[num_bit_mult0] = ~mult0_round_out[int_width_a + int_width_b - 1];
                    end
                    
                    mult0_saturate_out[2 : 0] = mult0_round_out[2:0];
                    
                    mult0_saturate_overflow = mult0_saturate_overflow_stat;
                end
            end
            else
            begin
                mult0_saturate_out = mult0_round_out;
                mult0_saturate_overflow = 1'b0;
            end
        
            if ((multiplier01_rounding == "YES") ||
                ((multiplier01_rounding  == "VARIABLE") && (mult01_round_wire == 1)))
            begin

                for (num_bit_mult0 = (`MULT_ROUND_BITS - 1); num_bit_mult0 >= 0; num_bit_mult0 = num_bit_mult0 - 1)
                begin
                    mult0_saturate_out[num_bit_mult0] = 1'b0;
                end
            
            end
        end
    end

    always @(mult0_saturate_out or mult_res_0 or systolic_register1)
    begin
        if (stratixii_block) 
        begin
            mult0_result <= mult0_saturate_out[(int_width_a + int_width_b) -1 :0];
        end
        else if(stratixv_block)
        begin
        	if(systolic_delay1 == output_register)
        		mult0_result  <= systolic_register1;
        	else
        		mult0_result  <= mult_res_0;
        end
        else
        begin
            mult0_result  <= mult_res_0; 
        end
        
    end
	
    assign systolic_register1 = (systolic_delay1 == "UNREGISTERED")? mult_res_0
                                : mult_res_reg_0;
    always @(posedge systolic1_reg_wire_clk or posedge systolic1_reg_wire_clr)
    begin
        if (stratixv_block == 1)
        begin
            if (systolic1_reg_wire_clr == 1) 
            begin 
                mult_res_reg_0[(int_width_a + int_width_b) -1 :0] <= 0;
            end
            else if ((systolic1_reg_wire_clk == 1) && (systolic1_reg_wire_en == 1))
            begin
                mult_res_reg_0[(int_width_a + int_width_b - 1) : 0] <= mult_res_0;
            end
        end
	end
	
	assign chainin_register1 = (systolic_delay1 == "UNREGISTERED")? 0
                                : chainin_reg;
    always @(posedge systolic1_reg_wire_clk or posedge systolic1_reg_wire_clr)
    begin
        if (stratixv_block == 1)
        begin
            if (systolic1_reg_wire_clr == 1) 
            begin 
                chainin_reg[(width_chainin) -1 :0] <= 0;
            end
            else if ((systolic1_reg_wire_clk == 1) && (systolic1_reg_wire_en == 1))
            begin
                chainin_reg[(width_chainin - 1) : 0] <= chainin_int;
            end
        end
	end
   
    // this block simulates the pipeline register after the multiplier (for non-StratixIII families)
    // and the pipeline register after the 1st level adder (for Stratix III)
    always @(posedge multiplier_reg0_wire_clk or posedge multiplier_reg0_wire_clr)
    begin
        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            if (multiplier_reg0_wire_clr == 1) 
            begin 
                mult_res_reg[(int_width_a + int_width_b) -1 :0] <= 0;
                mult_saturate_overflow_reg[0] <= 0;
            end
            else if ((multiplier_reg0_wire_clk == 1) && (multiplier_reg0_wire_en == 1))
            begin
                if (stratixii_block == 0)
                    mult_res_reg[(int_width_a + int_width_b) - 1 : 0] <= mult_res_0[(int_width_a + int_width_b) -1 :0];
                else 
                begin
                    mult_res_reg[(int_width_a + int_width_b - 1) : 0] <= mult0_result;
                    mult_saturate_overflow_reg[0] <= mult0_saturate_overflow;
                end
            end
        end
        else  // Stratix III - multiplier_reg refers to the register after the 1st adder
        begin
            if (multiplier_reg0_wire_clr == 1)
            begin
                adder1_reg[2*int_width_result - 1 : 0] <= 0;
                unsigned_sub1_overflow_mult_reg <= 0;
            end
            else if ((multiplier_reg0_wire_clk == 1) && (multiplier_reg0_wire_en == 1))
            begin
                adder1_reg[2*int_width_result - 1: 0] <= adder1_sum[2*int_width_result - 1 : 0];
                unsigned_sub1_overflow_mult_reg <= unsigned_sub1_overflow;
            end
        end
    end



    always @(mult_a_wire[(int_width_a *1) -1 : (int_width_a*0)] or mult_b_wire[(int_width_b  *1) -1 : (int_width_b *0)] or mult_c_wire[int_width_c-1:0] or
            preadder_res_wire[int_width_preadder - 1:0] or sign_a_wire or sign_b_wire)
    begin
    	if(stratixv_block)
    	begin
    		preadder_sum1a = 0;
    		preadder_sum2a = 0;
			if(preadder_mode == "CONSTANT")
			begin
				preadder_sum1a = mult_a_wire >> (0 * int_width_a);
				preadder_sum2a = coeffsel_a_pre;
			end
			else if(preadder_mode == "COEF")
			begin
				preadder_sum1a = preadder_res_wire[int_width_preadder - 1:0];
				preadder_sum2a = coeffsel_a_pre;
			end
			else if(preadder_mode == "INPUT")
			begin
				preadder_sum1a = preadder_res_wire[int_width_preadder - 1:0];
				preadder_sum2a = mult_c_wire;
			end
			else if(preadder_mode == "SQUARE")
			begin
				preadder_sum1a = preadder_res_wire[int_width_preadder - 1:0];
				preadder_sum2a = preadder_res_wire[int_width_preadder - 1:0];
			end
			else
			begin 
				preadder_sum1a = mult_a_wire >> (0 * width_a);
				preadder_sum2a = mult_b_wire >> (0 * width_b);
			end	
	    	mult_res_0 = do_multiply_stratixv(0, sign_a_wire, sign_b_wire);
	    end
    	else
	        mult_res_0 = do_multiply (0, sign_a_wire, sign_b_wire);
    end
  
    // ------------------------------------------------------------------------
    // This block basically calls the task do_multiply() to set the value of 
    // mult_res_1[(int_width_a + int_width_b) -1 :0]
    //
    // If multiplier_register1 is registered, the call of the task 
    // will be triggered by a posedge multiplier_reg1_wire_clk. 
    // It also has an asynchronous clear signal multiplier_reg1_wire_clr
    //
    // If multiplier_register1 is unregistered, a change of value 
    // in either mult_a[(2*int_width_a)-1:int_width_a], mult_b[(2*int_width_a)-1:int_width_a], 
    // sign_a_reg or sign_b_reg will trigger the task call.
    // -----------------------------------------------------------------------

    assign mult_res_wire[(((int_width_a + int_width_b) *2) - 1) : (int_width_a + int_width_b)] =  ((multiplier_register1 == "UNREGISTERED") || (stratixiii_block == 1) || (stratixv_block == 1))?
                                                                    mult1_result[(int_width_a + int_width_b - 1) : 0]:
                                                            mult_res_reg[((int_width_a + int_width_b) *2) - 1: (int_width_a + int_width_b)];

    assign mult_saturate_overflow_vec[1] =  (multiplier_register1 == "UNREGISTERED")?
                                            mult1_saturate_overflow : mult_saturate_overflow_reg[1];
   

    // This always block is to perform the rounding and saturation operations (StratixII only)
    always @(mult_res_1 or mult01_round_wire or mult01_saturate_wire)
    begin
        if (stratixii_block) 
        begin
            // -------------------------------------------------------
            // Stratix II Rounding support 
            // This block basically carries out the rounding for the 
            // mult_res_1. The equation to get the mult1_round_out is
            // obtained from the Stratix II Mac FFD which is below:
            // round_adder_constant = (1 << (wfraction - wfraction_round - 1))
            // roundout[] = datain[] + round_adder_constant
            // For Stratix II rounding, we round up the bits to 15 bits
            // or in another word wfraction_round = 15.
            // --------------------------------------------------------
        
            if ((multiplier01_rounding == "YES") ||
                ((multiplier01_rounding == "VARIABLE") && (mult01_round_wire == 1)))
            begin
                mult1_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_1[(int_width_a + int_width_b) -1 :0] + ( 1 << (`MULT_ROUND_BITS - 1));
            end
            else
            begin
                mult1_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_1[(int_width_a + int_width_b) -1 :0];
            end
            
            mult1_round_out[((int_width_a + int_width_b) + 2) : (int_width_a + int_width_b)] = {2{1'b0}};


            // -------------------------------------------------------
            // Stratix II Saturation support
            // This carries out the saturation for mult1_round_out.
            // The equation to get the saturated result is obtained 
            // from Stratix II MAC FFD which is below:
            // satoverflow = 1 if sign bit is different
            // satvalue[wtotal-1 : wfraction] = roundout[wtotal-1]
            // satvalue[wfraction-1 : 0] = !roundout[wtotal-1]
            // -------------------------------------------------------


            if ((multiplier01_saturation == "YES") || 
                (( multiplier01_saturation == "VARIABLE") && (mult01_saturate_wire == 1)))
            begin
                mult1_saturate_overflow_stat = (~mult1_round_out[int_width_a + int_width_b - 1]) && mult1_round_out[int_width_a + int_width_b - 2];

                if (mult1_saturate_overflow_stat == 0)
                begin
                    mult1_saturate_out = mult1_round_out;
                    mult1_saturate_overflow = mult1_round_out[0];
                end
                else
                begin
                    // We are doing Q2.31 saturation. Thus we would insert additional bit 
                    // for the LSB
                    for (num_bit_mult1 = (int_width_a + int_width_b - 1); num_bit_mult1 >= (int_width_a + int_width_b - 2); num_bit_mult1 = num_bit_mult1 - 1)
                    begin
                        mult1_saturate_out[num_bit_mult1] = mult1_round_out[int_width_a + int_width_b - 1];
                    end

                    for (num_bit_mult1 = sat_ini_value; num_bit_mult1 >= 3; num_bit_mult1 = num_bit_mult1 - 1)
                    begin
                        mult1_saturate_out[num_bit_mult1] = ~mult1_round_out[int_width_a + int_width_b - 1];
                    end
                    
                    mult1_saturate_out[2:0] = mult1_round_out[2:0];
                    mult1_saturate_overflow = mult1_saturate_overflow_stat;
                end
            end
            else
            begin
                mult1_saturate_out = mult1_round_out;
                mult1_saturate_overflow = 1'b0;
            end
        
            if ((multiplier01_rounding == "YES") ||
                ((multiplier01_rounding  == "VARIABLE") && (mult01_round_wire == 1)))
            begin

                for (num_bit_mult1 = (`MULT_ROUND_BITS - 1); num_bit_mult1 >= 0; num_bit_mult1 = num_bit_mult1 - 1)
                begin
                    mult1_saturate_out[num_bit_mult1] = 1'b0;
                end
            
            end
        end
    end
    
    always @(mult1_saturate_out or mult_res_1)
    begin
        if (stratixii_block) 
        begin
            mult1_result <= mult1_saturate_out[(int_width_a + int_width_b) -1 :0];
        end
        else
        begin
            mult1_result  <= mult_res_1; 
        end
    end

    // simulate the register after the multiplier for non-Stratix III families
    // does not apply to the Stratix III family
    always @(posedge multiplier_reg1_wire_clk or posedge multiplier_reg1_wire_clr)
    begin
        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            if (multiplier_reg1_wire_clr == 1)
            begin
                mult_res_reg[((int_width_a + int_width_b) *2) -1 : (int_width_a + int_width_b)] <= 0;
                mult_saturate_overflow_reg[1] <= 0;
            end
            else if ((multiplier_reg1_wire_clk == 1) && (multiplier_reg1_wire_en == 1))
                if (stratixii_block == 0)
                    mult_res_reg[((int_width_a + int_width_b) *2) -1 : (int_width_a + int_width_b)] <= 
                                            mult_res_1[(int_width_a + int_width_b) -1 :0];
                else 
                begin
                    mult_res_reg[((int_width_a + int_width_b) *2) -1 : (int_width_a + int_width_b)] <=  mult1_result;
                    mult_saturate_overflow_reg[1] <= mult1_saturate_overflow;
                end
        end
    end


    always @(mult_a_wire[(int_width_a *2) -1 : (int_width_a*1)] or mult_b_wire[(int_width_b  *2) -1 : (int_width_b *1)] or 
            preadder_res_wire[(((int_width_preadder) *2) - 1) : (int_width_preadder)] or sign_a_wire or sign_b_wire)
    begin
    	if(stratixv_block)
    	begin
    		preadder_sum1a = 0;
    		preadder_sum2a = 0;
			if(preadder_mode == "CONSTANT" )
			begin
				preadder_sum1a = mult_a_wire >> (1 * int_width_a);
				preadder_sum2a = coeffsel_b_pre;
			end
			else if(preadder_mode == "COEF")
			begin
				preadder_sum1a = preadder_res_wire[(((int_width_preadder) *2) - 1) : (int_width_preadder)];
				preadder_sum2a = coeffsel_b_pre;
			end
			else if(preadder_mode == "SQUARE")
			begin
				preadder_sum1a = preadder_res_wire[(((int_width_preadder) *2) - 1) : (int_width_preadder)];
				preadder_sum2a = preadder_res_wire[(((int_width_preadder) *2) - 1) : (int_width_preadder)];
			end
			else
			begin 
				preadder_sum1a = mult_a_wire >> (1 * int_width_a);
				preadder_sum2a = mult_b_wire >> (1 * int_width_b);
			end	
	    	mult_res_1 = do_multiply_stratixv(1, sign_a_wire, sign_b_wire);
	    end
        else if(input_source_b0 == "LOOPBACK")
            mult_res_1 = do_multiply_loopback (1, sign_a_wire, sign_b_wire);
        else
            mult_res_1 = do_multiply (1, sign_a_wire, sign_b_wire);      
    end


    // ----------------------------------------------------------------------------
    // This block basically calls the task do_multiply() to set the value of 
    // mult_res_2[(int_width_a + int_width_b) -1 :0]
    // 
    // If multiplier_register2 is registered, the call of the task 
    // will be triggered by a posedge multiplier_reg2_wire_clk. 
    // It also has an asynchronous clear signal multiplier_reg2_wire_clr
    //
    // If multiplier_register2 is unregistered, a change of value 
    // in either mult_a[(3*int_width_a)-1:2*int_width_a], mult_b[(3*int_width_a)-1:2*int_width_a], 
    // sign_a_reg or sign_b_reg will trigger the task call.
    // ---------------------------------------------------------------------------

    assign mult_res_wire[((int_width_a + int_width_b) *3) -1 : (2*(int_width_a + int_width_b))] =  ((multiplier_register2 == "UNREGISTERED") || (stratixiii_block == 1) || (stratixv_block == 1))?
                                                                                            mult2_result[(int_width_a + int_width_b) -1 :0] : 
                                                        mult_res_reg[((int_width_a + int_width_b) *3) -1 : (2*(int_width_a + int_width_b))];

    assign mult_saturate_overflow_vec[2] =  (multiplier_register2 == "UNREGISTERED")?
                                            mult2_saturate_overflow : mult_saturate_overflow_reg[2];

    // This always block is to perform the rounding and saturation operations (StratixII only)
    always @(mult_res_2 or mult23_round_wire or mult23_saturate_wire)
    begin
        if (stratixii_block) 
        begin
            // -------------------------------------------------------
            // Stratix II Rounding support 
            // This block basically carries out the rounding for the 
            // mult_res_2. The equation to get the mult2_round_out is
            // obtained from the Stratix II Mac FFD which is below:
            // round_adder_constant = (1 << (wfraction - wfraction_round - 1))
            // roundout[] = datain[] + round_adder_constant
            // For Stratix II rounding, we round up the bits to 15 bits
            // or in another word wfraction_round = 15.
            // --------------------------------------------------------
        
            if ((multiplier23_rounding == "YES") ||
                ((multiplier23_rounding == "VARIABLE") && (mult23_round_wire == 1)))
            begin
                mult2_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_2[(int_width_a + int_width_b) -1 :0] + ( 1 << (`MULT_ROUND_BITS - 1));
            end
            else
            begin
                mult2_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_2[(int_width_a + int_width_b) -1 :0];
            end
            
            mult2_round_out[((int_width_a + int_width_b) + 2) : (int_width_a + int_width_b)] = {2{1'b0}};

            // -------------------------------------------------------
            // Stratix II Saturation support
            // This carries out the saturation for mult2_round_out.
            // The equation to get the saturated result is obtained 
            // from Stratix II MAC FFD which is below:
            // satoverflow = 1 if sign bit is different
            // satvalue[wtotal-1 : wfraction] = roundout[wtotal-1]
            // satvalue[wfraction-1 : 0] = !roundout[wtotal-1]
            // -------------------------------------------------------


            if ((multiplier23_saturation == "YES") || 
                (( multiplier23_saturation == "VARIABLE") && (mult23_saturate_wire == 1)))
            begin
                mult2_saturate_overflow_stat = (~mult2_round_out[int_width_a + int_width_b - 1]) && mult2_round_out[int_width_a + int_width_b - 2];
            
                if (mult2_saturate_overflow_stat == 0)
                begin
                    mult2_saturate_out = mult2_round_out;
                    mult2_saturate_overflow = mult2_round_out[0];
                end
                else
                begin
                    // We are doing Q2.31 saturation. Thus we would insert additional bit 
                    // for the LSB
                    for (num_bit_mult2 = (int_width_a + int_width_b - 1); num_bit_mult2 >= (int_width_a + int_width_b - 2); num_bit_mult2 = num_bit_mult2 - 1)
                    begin
                        mult2_saturate_out[num_bit_mult2] = mult2_round_out[int_width_a + int_width_b - 1];
                    end

                    for (num_bit_mult2 = sat_ini_value; num_bit_mult2 >= 3; num_bit_mult2 = num_bit_mult2 - 1)
                    begin
                        mult2_saturate_out[num_bit_mult2] = ~mult2_round_out[int_width_a + int_width_b - 1];
                    end
                    
                    mult2_saturate_out[2:0] = mult2_round_out[2:0];
                    mult2_saturate_overflow = mult2_saturate_overflow_stat;
                end
            end
            else
            begin
                mult2_saturate_out = mult2_round_out;
                mult2_saturate_overflow = 1'b0;
            end
        
            if ((multiplier23_rounding == "YES") ||
                ((multiplier23_rounding  == "VARIABLE") && (mult23_round_wire == 1)))
            begin

                for (num_bit_mult2 = (`MULT_ROUND_BITS - 1); num_bit_mult2 >= 0; num_bit_mult2 = num_bit_mult2 - 1)
                begin
                    mult2_saturate_out[num_bit_mult2] = 1'b0;
                end
            
            end
        end
    end

    always @(mult2_saturate_out or mult_res_2 or systolic_register3)
    begin
        if (stratixii_block) 
        begin
            mult2_result <= mult2_saturate_out[(int_width_a + int_width_b) -1 :0];
        end
        else if(stratixv_block)
        begin
        	if(systolic_delay1 == output_register)
        		mult2_result  <= systolic_register3;
        	else
                mult2_result  <= mult_res_2;
        end
        else
        begin
            mult2_result  <= mult_res_2; 
        end
    end
	
    assign systolic_register3 = (systolic_delay3 == "UNREGISTERED")? mult_res_2
                                : mult_res_reg_2;
    always @(posedge systolic3_reg_wire_clk or posedge systolic3_reg_wire_clr)
    begin
        if (stratixv_block == 1)
        begin
            if (systolic3_reg_wire_clr == 1) 
            begin 
                mult_res_reg_2[(int_width_a + int_width_b) -1 :0] <= 0;
            end
            else if ((systolic3_reg_wire_clk == 1) && (systolic3_reg_wire_en == 1))
            begin
                mult_res_reg_2[(int_width_a + int_width_b - 1) : 0] <= mult_res_2;
            end
        end
	end
	
    // simulate the register after the multiplier (for non-Stratix III families)
    // and simulate the register after the 1st adder for Stratix III family
    always @(posedge multiplier_reg2_wire_clk or posedge multiplier_reg2_wire_clr)
    begin
        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            if (multiplier_reg2_wire_clr == 1)
            begin
                mult_res_reg[((int_width_a + int_width_b) *3) -1 : (2*(int_width_a + int_width_b))] <= 0;
                mult_saturate_overflow_reg[2] <= 0;
            end
            else if ((multiplier_reg2_wire_clk == 1) && (multiplier_reg2_wire_en == 1))
                if (stratixii_block == 0)
                    mult_res_reg[((int_width_a + int_width_b) *3) -1 : (2*(int_width_a + int_width_b))] <= 
                            mult_res_2[(int_width_a + int_width_b) -1 :0];
                else 
                begin
                    mult_res_reg[((int_width_a + int_width_b) *3) -1 : (2*(int_width_a + int_width_b))] <=  mult2_result;
                    mult_saturate_overflow_reg[2] <= mult2_saturate_overflow;
                end
        end
        else  // Stratix III - multiplier_reg here refers to the register after the 1st adder
        begin
            if (multiplier_reg2_wire_clr == 1)
            begin
                adder3_reg[2*int_width_result - 1 : 0] <= 0;
                unsigned_sub3_overflow_mult_reg <= 0;
            end
            else if ((multiplier_reg2_wire_clk == 1) && (multiplier_reg2_wire_en == 1))
            begin
                adder3_reg[2*int_width_result - 1: 0] <= adder3_sum[2*int_width_result - 1 : 0];
                unsigned_sub3_overflow_mult_reg <= unsigned_sub3_overflow;
            end
        end
    end

    always @(mult_a_wire[(int_width_a *3) -1 : (int_width_a*2)] or mult_b_wire[(int_width_b  *3) -1 : (int_width_b *2)] or
            preadder_res_wire[((int_width_preadder) *3) -1 : (2*(int_width_preadder))] or sign_a_wire or sign_b_wire)
    begin
    	if(stratixv_block)
    	begin
    		preadder_sum1a = 0;
    		preadder_sum2a = 0;
			if(preadder_mode == "CONSTANT")
			begin
				preadder_sum1a = mult_a_wire >> (2 * int_width_a);
				preadder_sum2a = coeffsel_c_pre;
			end
			else if(preadder_mode == "COEF")
			begin
				preadder_sum1a = preadder_res_wire[((int_width_preadder) *3) -1 : (2*(int_width_preadder))];
				preadder_sum2a = coeffsel_c_pre;
			end
			else if(preadder_mode == "SQUARE")
			begin
				preadder_sum1a = preadder_res_wire[((int_width_preadder) *3) -1 : (2*(int_width_preadder))];
				preadder_sum2a = preadder_res_wire[((int_width_preadder) *3) -1 : (2*(int_width_preadder))];
			end
			else
			begin 
				preadder_sum1a = mult_a_wire >> (2 * int_width_a);
				preadder_sum2a = mult_b_wire >> (2 * int_width_b);
			end	
    		mult_res_2 = do_multiply_stratixv (2, sign_a_wire, sign_b_wire);
    	end
    	else
        	mult_res_2 = do_multiply (2, sign_a_wire, sign_b_wire);
    end




    // ----------------------------------------------------------------------------
    // This block basically calls the task do_multiply() to set the value of 
    // mult_res_3[(int_width_a + int_width_b) -1 :0]
    //
    // If multiplier_register3 is registered, the call of the task 
    // will be triggered by a posedge multiplier_reg3_wire_clk. 
    // It also has an asynchronous clear signal multiplier_reg3_wire_clr
    //
    // If multiplier_register3 is unregistered, a change of value 
    // in either mult_a[(4*int_width_a)-1:3*int_width_a], mult_b[(4*int_width_a)-1:3*int_width_a], 
    // sign_a_reg or sign_b_reg will trigger the task call.
    // ---------------------------------------------------------------------------

    assign mult_res_wire[((int_width_a + int_width_b) *4) -1 : 3*(int_width_a + int_width_b)] = ((multiplier_register3 == "UNREGISTERED") || (stratixiii_block == 1) || (stratixv_block == 1))?
                                                                        mult3_result[(int_width_a + int_width_b) -1 :0] :
                                                                        mult_res_reg[((int_width_a + int_width_b) *4) -1 : 3*(int_width_a + int_width_b)];

    assign mult_saturate_overflow_vec[3] =  (multiplier_register3 == "UNREGISTERED")?
                                            mult3_saturate_overflow : mult_saturate_overflow_reg[3];
   
    // This always block is to perform the rounding and saturation operations (StratixII only)
    always @(mult_res_3 or mult23_round_wire or mult23_saturate_wire)
    begin
        if (stratixii_block) 
        begin
            // -------------------------------------------------------
            // Stratix II Rounding support 
            // This block basically carries out the rounding for the 
            // mult_res_3. The equation to get the mult3_round_out is
            // obtained from the Stratix II Mac FFD which is below:
            // round_adder_constant = (1 << (wfraction - wfraction_round - 1))
            // roundout[] = datain[] + round_adder_constant
            // For Stratix II rounding, we round up the bits to 15 bits
            // or in another word wfraction_round = 15.
            // --------------------------------------------------------
        
            if ((multiplier23_rounding == "YES") ||
                ((multiplier23_rounding == "VARIABLE") && (mult23_round_wire == 1)))
            begin
                mult3_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_3[(int_width_a + int_width_b) -1 :0] + ( 1 << (`MULT_ROUND_BITS - 1));
            end
            else
            begin
                mult3_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_3[(int_width_a + int_width_b) -1 :0];
            end
            
            mult3_round_out[((int_width_a + int_width_b) + 2) : (int_width_a + int_width_b)] = {2{1'b0}};

            // -------------------------------------------------------
            // Stratix II Saturation support
            // This carries out the saturation for mult3_round_out.
            // The equation to get the saturated result is obtained 
            // from Stratix II MAC FFD which is below:
            // satoverflow = 1 if sign bit is different
            // satvalue[wtotal-1 : wfraction] = roundout[wtotal-1]
            // satvalue[wfraction-1 : 0] = !roundout[wtotal-1]
            // -------------------------------------------------------


            if ((multiplier23_saturation == "YES") || 
                (( multiplier23_saturation == "VARIABLE") && (mult23_saturate_wire == 1)))
            begin
                mult3_saturate_overflow_stat = (~mult3_round_out[int_width_a + int_width_b - 1]) && mult3_round_out[int_width_a + int_width_b - 2];

                if (mult3_saturate_overflow_stat == 0)
                begin
                    mult3_saturate_out = mult3_round_out;
                    mult3_saturate_overflow = mult3_round_out[0];
                end
                else
                begin
                    // We are doing Q2.31 saturation. Thus we would make sure the 3 LSB bits isn't reset
                    for (num_bit_mult3 = (int_width_a + int_width_b -1); num_bit_mult3 >= (int_width_a + int_width_b - 2); num_bit_mult3 = num_bit_mult3 - 1)
                    begin
                        mult3_saturate_out[num_bit_mult3] = mult3_round_out[int_width_a + int_width_b - 1];
                    end

                    for (num_bit_mult3 = sat_ini_value; num_bit_mult3 >= 3; num_bit_mult3 = num_bit_mult3 - 1)
                    begin
                        mult3_saturate_out[num_bit_mult3] = ~mult3_round_out[int_width_a + int_width_b - 1];
                    end
                    
                    mult3_saturate_out[2:0] = mult3_round_out[2:0];
                    mult3_saturate_overflow = mult3_saturate_overflow_stat;
                end
            end
            else
            begin
                mult3_saturate_out = mult3_round_out;
                mult3_saturate_overflow = 1'b0;
            end
        
            if ((multiplier23_rounding == "YES") ||
                ((multiplier23_rounding  == "VARIABLE") && (mult23_round_wire == 1)))
            begin

                for (num_bit_mult3 = (`MULT_ROUND_BITS - 1); num_bit_mult3 >= 0; num_bit_mult3 = num_bit_mult3 - 1)
                begin
                    mult3_saturate_out[num_bit_mult3] = 1'b0;
                end
            
            end
        end
    end

    always @(mult3_saturate_out or mult_res_3)
    begin
        if (stratixii_block) 
        begin
            mult3_result <= mult3_saturate_out[(int_width_a + int_width_b) -1 :0];
        end
        else
        begin
            mult3_result <= mult_res_3;
        end
    end

    // simulate the register after the multiplier for non-Stratix III families
    // does not apply to the Stratix III family
    always @(posedge multiplier_reg3_wire_clk or posedge multiplier_reg3_wire_clr)
    begin
        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            if (multiplier_reg3_wire_clr == 1)
            begin
                mult_res_reg[((int_width_a + int_width_b) *4) -1 : (3*(int_width_a + int_width_b))] <= 0;
                mult_saturate_overflow_reg[3] <= 0;
            end
            else if ((multiplier_reg3_wire_clk == 1) && (multiplier_reg3_wire_en == 1))
                if (stratixii_block == 0)
                    mult_res_reg[((int_width_a + int_width_b) *4) -1 : (3*(int_width_a + int_width_b))] <= 
                            mult_res_3[(int_width_a + int_width_b) -1 :0];
                else 
                begin
                    mult_res_reg[((int_width_a + int_width_b) *4) -1: 3*(int_width_a + int_width_b)] <=  mult3_result;
                    mult_saturate_overflow_reg[3] <= mult3_saturate_overflow;
                end
        end
    end


    

    always @(mult_a_wire[(int_width_a *4) -1 : (int_width_a*3)] or mult_b_wire[(int_width_b  *4) -1 : (int_width_b *3)] or
            preadder_res_wire[((int_width_preadder) *4) -1 : 3*(int_width_preadder)] or sign_a_wire or sign_b_wire)
    begin
    	if(stratixv_block)
    	begin
    		preadder_sum1a = 0;
    		preadder_sum2a = 0;
			if(preadder_mode == "CONSTANT")
			begin
				preadder_sum1a = mult_a_wire >> (3 * int_width_a);
				preadder_sum2a = coeffsel_d_pre;
			end
			else if(preadder_mode == "COEF")
			begin
				preadder_sum1a = preadder_res_wire[((int_width_preadder) *4) -1 : 3*(int_width_preadder)];
				preadder_sum2a = coeffsel_d_pre;
			end
			else if(preadder_mode == "SQUARE")
			begin
				preadder_sum1a = preadder_res_wire[((int_width_preadder) *4) -1 : 3*(int_width_preadder)];
				preadder_sum2a = preadder_res_wire[((int_width_preadder) *4) -1 : 3*(int_width_preadder)];
			end
			else
			begin 
				preadder_sum1a = mult_a_wire >> (3 * int_width_a);
				preadder_sum2a = mult_b_wire >> (3 * int_width_b);
			end	
    		mult_res_3 = do_multiply_stratixv (3, sign_a_wire, sign_b_wire);
    	end
    	else
        	mult_res_3 = do_multiply (3, sign_a_wire, sign_b_wire);
    end
    
    //------------------------------
    // Assign statements for coefficient storage
    //------------------------------
    assign coeffsel_a_pre = (coeffsel_a_wire == 0)? coef0_0 :
    						(coeffsel_a_wire == 1)? coef0_1 :
    						(coeffsel_a_wire == 2)? coef0_2 :
    						(coeffsel_a_wire == 3)? coef0_3 :
    						(coeffsel_a_wire == 4)? coef0_4 :
    						(coeffsel_a_wire == 5)? coef0_5 :
    						(coeffsel_a_wire == 6)? coef0_6 : coef0_7 ;
    						
	assign coeffsel_b_pre = (coeffsel_b_wire == 0)? coef1_0 :
    						(coeffsel_b_wire == 1)? coef1_1 :
    						(coeffsel_b_wire == 2)? coef1_2 :
    						(coeffsel_b_wire == 3)? coef1_3 :
    						(coeffsel_b_wire == 4)? coef1_4 :
    						(coeffsel_b_wire == 5)? coef1_5 :
    						(coeffsel_b_wire == 6)? coef1_6 : coef1_7 ;
    						
	assign coeffsel_c_pre = (coeffsel_c_wire == 0)? coef2_0 :
    						(coeffsel_c_wire == 1)? coef2_1 :
    						(coeffsel_c_wire == 2)? coef2_2 :
    						(coeffsel_c_wire == 3)? coef2_3 :
    						(coeffsel_c_wire == 4)? coef2_4 :
    						(coeffsel_c_wire == 5)? coef2_5 :
    						(coeffsel_c_wire == 6)? coef2_6 : coef2_7 ;
    						
	assign coeffsel_d_pre = (coeffsel_d_wire == 0)? coef3_0 :
    						(coeffsel_d_wire == 1)? coef3_1 :
    						(coeffsel_d_wire == 2)? coef3_2 :
    						(coeffsel_d_wire == 3)? coef3_3 :
    						(coeffsel_d_wire == 4)? coef3_4 :
    						(coeffsel_d_wire == 5)? coef3_5 :
    						(coeffsel_d_wire == 6)? coef3_6 : coef3_7 ;    						    						    						
    //------------------------------
    // Continuous assign statements
    //------------------------------

    // Clock in all the A input registers
    assign i_scanina = (stratixii_block == 0)? 
                            dataa_int[int_width_a-1:0] : scanina_z;
                                            
    assign mult_a_pre[int_width_a-1:0] =    (stratixv_block == 1)? dataa_int[width_a-1:0]:
                                            (input_source_a0 == "DATAA")? dataa_int[int_width_a-1:0] :
                                            (input_source_a0 == "SCANA")? i_scanina :
                                            (sourcea_wire[0] == 1)? scanina_z : dataa_int[int_width_a-1:0];

    assign mult_a_pre[(2*int_width_a)-1:int_width_a] =  (stratixv_block == 1)? dataa_int[(2*width_a)-1:width_a] : 
                                                        (input_source_a1 == "DATAA")?dataa_int[(2*int_width_a)-1:int_width_a] : 
                                                        (input_source_a1 == "SCANA")? mult_a_wire[int_width_a-1:0] :
                                                        (sourcea_wire[1] == 1)? mult_a_wire[int_width_a-1:0] : dataa_int[(2*int_width_a)-1:int_width_a];

    assign mult_a_pre[(3*int_width_a)-1:2*int_width_a] =    (stratixv_block == 1)? dataa_int[(3*width_a)-1:2*width_a]: 
                                                            (input_source_a2 == "DATAA") ?dataa_int[(3*int_width_a)-1:2*int_width_a]: 
                                                            (input_source_a2 == "SCANA")? mult_a_wire[(2*int_width_a)-1:int_width_a] :
                                                            (sourcea_wire[2] == 1)? mult_a_wire[(2*int_width_a)-1:int_width_a] : dataa_int[(3*int_width_a)-1:2*int_width_a];

    assign mult_a_pre[(4*int_width_a)-1:3*int_width_a] =    (stratixv_block == 1)? dataa_int[(4*width_a)-1:3*width_a] : 
                                                            (input_source_a3 == "DATAA") ?dataa_int[(4*int_width_a)-1:3*int_width_a] : 
                                                            (input_source_a3 == "SCANA")? mult_a_wire[(3*int_width_a)-1:2*int_width_a] :
                                                            (sourcea_wire[3] == 1)? mult_a_wire[(3*int_width_a)-1:2*int_width_a] : dataa_int[(4*int_width_a)-1:3*int_width_a];

    assign scanouta = (stratixiii_block == 0) ?
                        mult_a_wire[(number_of_multipliers * int_width_a) - 1 : ((number_of_multipliers-1) * int_width_a) + (int_width_a - width_a)]
                        : scanouta_wire[int_width_a - 1: 0];

    assign scanoutb = (chainout_adder == "YES" && (width_result > width_a + width_b + 8))? 
                        mult_b_wire[(number_of_multipliers * int_width_b) - 1  - (int_width_b - width_b) : ((number_of_multipliers-1) * int_width_b)]:
                        mult_b_wire[(number_of_multipliers * int_width_b) - 1 : ((number_of_multipliers-1) * int_width_b) + (int_width_b - width_b)];

    // Clock in all the B input registers
    assign i_scaninb = (stratixii_block == 0)?
                        datab_int[int_width_b-1:0] : scaninb_z;

    assign loopback_wire_temp = {{int_width_b{1'b0}}, loopback_wire[`LOOPBACK_WIRE_WIDTH : width_a]};

    assign mult_b_pre_temp = (input_source_b0 == "LOOPBACK") ? loopback_wire_temp[int_width_b - 1 : 0] : datab_int[int_width_b-1:0];
    
    assign mult_b_pre[int_width_b-1:0] =    (stratixv_block == 1)? datab_int[width_b-1:0]:
                                            (input_source_b0 == "DATAB")? datab_int[int_width_b-1:0] :
                                            (input_source_b0 == "SCANB")? ((mult0_source_scanin_en == 1'b0)? i_scaninb : datab_int[int_width_b-1:0]) :
                                            (sourceb_wire[0] == 1)? scaninb_z : 
                                            mult_b_pre_temp[int_width_b-1:0];
	
    assign mult_b_pre[(2*int_width_b)-1:int_width_b] =  (stratixv_block == 1)? datab_int[(2*width_b)-1 : width_b ]:
                                                        (input_source_b1 == "DATAB") ? 
                                                        ((input_source_b0 == "LOOPBACK") ? datab_int[int_width_b -1 :0] :
                                                        datab_int[(2*int_width_b)-1 : int_width_b ]): 
                                                        (input_source_b1 == "SCANB")? 
                                                        (stratixiii_block == 1 || stratixv_block == 1) ? mult_b_wire[int_width_b -1 : 0] : 
                                                        ((mult1_source_scanin_en == 1'b0)? mult_b_wire[int_width_b -1 : 0] : datab_int[(2*int_width_b)-1 : int_width_b ]) :
                                                        (sourceb_wire[1] == 1)? mult_b_wire[int_width_b -1 : 0] : 
                                                        datab_int[(2*int_width_b)-1 : int_width_b ];

    assign mult_b_pre[(3*int_width_b)-1:2*int_width_b] =    (stratixv_block == 1)?datab_int[(3*width_b)-1:2*width_b]:
                                                            (input_source_b2 == "DATAB") ? 
                                                            ((input_source_b0 == "LOOPBACK") ? datab_int[(2*int_width_b)-1: int_width_b]:
                                                            datab_int[(3*int_width_b)-1:2*int_width_b]) : 
                                                            (input_source_b2 == "SCANB")? 
                                                            (stratixiii_block == 1 || stratixv_block == 1) ?  mult_b_wire[(2*int_width_b)-1:int_width_b] :
                                                            ((mult2_source_scanin_en == 1'b0)? mult_b_wire[(2*int_width_b)-1:int_width_b] : datab_int[(3*int_width_b)-1:2*int_width_b]) :
                                                            (sourceb_wire[2] == 1)? mult_b_wire[(2*int_width_b)-1:int_width_b] :
                                                            datab_int[(3*int_width_b)-1:2*int_width_b];

    assign mult_b_pre[(4*int_width_b)-1:3*int_width_b] =    (stratixv_block == 1)?datab_int[(4*width_b)-1:3*width_b]:
                                                            (input_source_b3 == "DATAB") ? 
                                                            ((input_source_b0 == "LOOPBACK") ? datab_int[(3*int_width_b) - 1: 2*int_width_b] :
                                                            datab_int[(4*int_width_b)-1:3*int_width_b]) : 
                                                            (input_source_b3 == "SCANB")? 
                                                            (stratixiii_block == 1 || stratixv_block == 1) ? mult_b_wire[(3*int_width_b)-1:2*int_width_b] :
                                                            ((mult3_source_scanin_en == 1'b0)? mult_b_wire[(3*int_width_b)-1:2*int_width_b] : datab_int[(4*int_width_b)-1:3*int_width_b]):
                                                            (sourceb_wire[3] == 1)? mult_b_wire[(3*int_width_b)-1:2*int_width_b] :
                                                            datab_int[(4*int_width_b)-1:3*int_width_b];
                                                            
    assign mult_c_pre[int_width_c-1:0] =    (stratixv_block == 1 && (preadder_mode =="INPUT"))? datac_int[int_width_c-1:0]: 0;
                                                                      

    // clock in all the control signals
    assign addsub1_int =    ((port_addnsub1 == "PORT_CONNECTIVITY")?
                            ((multiplier1_direction != "UNUSED") && (addnsub1 ===1'bz) ? (multiplier1_direction == "ADD" ? 1'b1 : 1'b0) : addnsub1_z) :
                            ((port_addnsub1 == "PORT_USED")? addnsub1_z :
                            (port_addnsub1 == "PORT_UNUSED")? (multiplier1_direction == "ADD" ? 1'b1 : 1'b0) : addnsub1_z));

    assign addsub3_int =    ((port_addnsub3 == "PORT_CONNECTIVITY")?
                            ((multiplier3_direction != "UNUSED") && (addnsub3 ===1'bz) ? (multiplier3_direction == "ADD" ? 1'b1 : 1'b0) : addnsub3_z) :
                            ((port_addnsub3 == "PORT_USED")? addnsub3_z :
                            (port_addnsub3 == "PORT_UNUSED")?  (multiplier3_direction == "ADD" ? 1'b1 : 1'b0) : addnsub3_z));

    assign sign_a_int = ((port_signa == "PORT_CONNECTIVITY")?
                        ((representation_a != "UNUSED") && (signa ===1'bz) ? (representation_a == "SIGNED" ? 1'b1 : 1'b0) : signa_z) :
                        (port_signa == "PORT_USED")? signa_z :
                        (port_signa == "PORT_UNUSED")? (representation_a == "SIGNED" ? 1'b1 : 1'b0) : signa_z);

    assign sign_b_int = ((port_signb == "PORT_CONNECTIVITY")?
                        ((representation_b != "UNUSED") && (signb ===1'bz) ? (representation_b == "SIGNED" ? 1'b1 : 1'b0) : signb_z) :
                        (port_signb == "PORT_USED")? signb_z :
                        (port_signb == "PORT_UNUSED")? (representation_b == "SIGNED" ? 1'b1 : 1'b0) : signb_z);

    assign outround_int = ((output_rounding == "VARIABLE") ? (output_round)
                            : ((output_rounding == "YES") ? 1'b1 : 1'b0));
    
    assign chainout_round_int = ((chainout_rounding == "VARIABLE") ? chainout_round : ((chainout_rounding == "YES") ? 1'b1 : 1'b0));

    assign outsat_int = ((output_saturation == "VARIABLE") ? output_saturate : ((output_saturation == "YES") ? 1'b1 : 1'b0));
    
    assign chainout_sat_int = ((chainout_saturation == "VARIABLE") ? chainout_saturate : ((chainout_saturation == "YES") ? 1'b1 : 1'b0));
    
    assign zerochainout_int = (chainout_adder == "YES")? zero_chainout : 1'b0;
    
    assign rotate_int = (shift_mode == "VARIABLE") ? rotate : 1'b0;
    
    assign shiftr_int = (shift_mode == "VARIABLE") ? shift_right : 1'b0;
    
    assign zeroloopback_int = (input_source_b0 == "LOOPBACK") ? zero_loopback : 1'b0;
    
    assign accumsload_int = (stratixv_block == 1)? accum_sload :
    						(accumulator == "YES") ? 
                            (((output_rounding == "VARIABLE") && (chainout_adder == "NO")) ? output_round : accum_sload)
                            : 1'b0;
                            
    assign chainin_int = chainin;
    
    assign coeffsel_a_int =  (stratixv_block == 1) ?coefsel0: 3'bx;
    
    assign coeffsel_b_int =  (stratixv_block == 1) ?coefsel1: 3'bx;
    
    assign coeffsel_c_int =  (stratixv_block == 1) ?coefsel2: 3'bx;
    
    assign coeffsel_d_int =  (stratixv_block == 1) ?coefsel3: 3'bx;
    
    // -----------------------------------------------------------------
    // This is the main block that performs the addition and subtraction
    // -----------------------------------------------------------------
    
    // need to do MSB extension for cases where the result width is > width_a + width_b
    // for Stratix III family only
    assign result_stxiii_temp = ((width_result - 1 + int_mult_diff_bit) > int_width_result)? ((sign_a_pipe_wire|sign_b_pipe_wire)?
                            {{(result_pad){temp_sum_reg[2*int_width_result - 1]}}, temp_sum_reg[int_width_result + 1:int_mult_diff_bit]}:
                            {{(result_pad){1'b0}}, temp_sum_reg[int_width_result + 1:int_mult_diff_bit]}):
                            temp_sum_reg[width_result - 1 + int_mult_diff_bit:int_mult_diff_bit];

    assign result_stxiii_temp2 = ((width_result - 1 + int_mult_diff_bit) > int_width_result)? ((sign_a_pipe_wire|sign_b_pipe_wire)?
                            {{(result_pad){temp_sum_reg[2*int_width_result - 1]}}, temp_sum_reg[int_width_result:int_mult_diff_bit]}:
                            {{(result_pad){1'b0}}, temp_sum_reg[int_width_result:int_mult_diff_bit]}):
                            temp_sum_reg[width_result - 1 + int_mult_diff_bit:int_mult_diff_bit];
                            
    assign result_stxiii_temp3 = ((width_result - 1 + int_mult_diff_bit) > int_width_result)? ((sign_a_pipe_wire|sign_b_pipe_wire)?
                            {{(result_pad){round_sat_blk_res[2*int_width_result - 1]}}, round_sat_blk_res[int_width_result:int_mult_diff_bit]}:
                            {{(result_pad){1'b0}}, round_sat_blk_res[int_width_result :int_mult_diff_bit]}):
                            round_sat_blk_res[width_result - 1 + int_mult_diff_bit : int_mult_diff_bit];
                            
    assign result_stxiii =  (stratixiii_block == 1 || stratixv_block == 1) ?
                            ((shift_mode != "NO") ? shift_rot_result[`SHIFT_MODE_WIDTH:0] :
                            (chainout_adder == "YES") ? chainout_final_out[width_result - 1 + int_mult_diff_bit: int_mult_diff_bit] :
                            ((((width_a < 36 && width_b < 36) || ((width_a >= 36 || width_b >= 36) && extra_latency == 0)) && output_register == "UNREGISTERED")?  
                            ((input_source_b0 == "LOOPBACK") ? loopback_out_wire[int_width_result - 1 : 0] :                
                            result_stxiii_temp3[width_result - 1 : 0]) :
                            (extra_latency != 0 && output_register == "UNREGISTERED" && (width_a > 36 || width_b > 36))?
                            result_stxiii_temp2[width_result - 1 : 0] :
                            (input_source_b0 == "LOOPBACK") ? loopback_out_wire[int_width_result - 1 : 0] :                                       
                            result_stxiii_temp[width_result - 1 : 0])) : {(width_result){1'b0}};
                            
                            
    assign result_stxiii_ext = (stratixiii_block == 1 || stratixv_block == 1) ?
                                (((chainout_adder == "YES") || (accumulator == "YES") || (input_source_b0 == "LOOPBACK")) ?
                                result_stxiii :
                                ((number_of_multipliers == 1) && (width_result > width_a + width_b)) ?
                                (((representation_a == "UNSIGNED") && (representation_b == "UNSIGNED") && (unsigned_sub1_overflow_wire == 0 && unsigned_sub3_overflow_wire == 0)) ?
                                {{(result_stxiii_pad){1'b0}}, result_stxiii[result_msb_stxiii : 0]} :
                                {{(result_stxiii_pad){result_stxiii[result_msb_stxiii]}}, result_stxiii[result_msb_stxiii : 0]}) :
                                (((number_of_multipliers == 2) || (input_source_b0 == "LOOPBACK")) && (width_result > width_a + width_b + 1)) ?
                                ((((representation_a == "UNSIGNED") && (representation_b == "UNSIGNED")) && (unsigned_sub1_overflow_wire == 0 && unsigned_sub3_overflow_wire == 0)) ?
                                {{(result_stxiii_pad){1'b0}}, result_stxiii[result_msb_stxiii : 0]} :
                                {{(result_stxiii_pad){result_stxiii[result_msb_stxiii]}}, result_stxiii[result_msb_stxiii : 0]}):
                                ((number_of_multipliers > 2) && (width_result > width_a + width_b + 2)) ?
                                ((((representation_a == "UNSIGNED") && (representation_b == "UNSIGNED")) && (unsigned_sub1_overflow_wire == 0 && unsigned_sub3_overflow_wire == 0)) ?
                                {{(result_stxiii_pad){1'b0}}, result_stxiii[result_msb_stxiii : 0]} :
                                {{(result_stxiii_pad){result_stxiii[result_msb_stxiii]}}, result_stxiii[result_msb_stxiii : 0]}) :
                                result_stxiii) : {width_result {1'b0}};
    
    assign result_ext = (output_register == "UNREGISTERED")?
                        temp_sum[width_result - 1 :0]: temp_sum_reg[width_result - 1 : 0];
                                                                    
                               
    assign result_stxii_ext_temp = ((width_result - 1 + int_mult_diff_bit) > int_width_result)? ((sign_a_pipe_wire|sign_b_pipe_wire)?
                            {{(result_pad){temp_sum[int_width_result]}}, temp_sum[int_width_result - 1:int_mult_diff_bit]}: 
                            {{(result_pad){1'b0}}, temp_sum[int_width_result - 1 :int_mult_diff_bit]}):    
                            temp_sum[width_result - 1 + int_mult_diff_bit : int_mult_diff_bit];
                         
    assign result_stxii_ext_temp2 = ((width_result - 1 + int_mult_diff_bit) > int_width_result)? ((sign_a_pipe_wire|sign_b_pipe_wire)?
                            {{(result_pad){temp_sum_reg[int_width_result]}}, temp_sum_reg[int_width_result - 1:int_mult_diff_bit]}: 
                            {{(result_pad){1'b0}}, temp_sum_reg[int_width_result - 1:int_mult_diff_bit]}): 
                            temp_sum_reg[width_result - 1 + int_mult_diff_bit:int_mult_diff_bit];
                                                      
    assign result_stxii_ext = (stratixii_block == 0)? result_ext:
                            ( adder3_rounding != "NO" | multiplier01_rounding != "NO" | multiplier23_rounding != "NO" | output_rounding != "NO"| adder1_rounding != "NO" )?
                            (output_register == "UNREGISTERED")?
                            result_stxii_ext_temp[width_result - 1 : 0] :
                            result_stxii_ext_temp2[width_result - 1 : 0] : result_ext;
                                                  
    assign result = (stratixv_block == 1 ) ? result_stxiii:
                    (stratixiii_block == 1) ?  result_stxiii_ext :
                    (width_result > (width_a + width_b))? result_stxii_ext : 
                    (output_register == "UNREGISTERED")? 
                    temp_sum[width_result - 1 + int_mult_diff_bit : int_mult_diff_bit]: 
                    temp_sum_reg[width_result - 1 + int_mult_diff_bit:int_mult_diff_bit]; 

    assign mult_is_saturate_vec =   (output_register == "UNREGISTERED")?
                                    mult_saturate_overflow_vec: mult_saturate_overflow_pipe_reg;                                      
    
    always@(posedge input_reg_a0_wire_clk or posedge multiplier_reg0_wire_clk)      
    begin
    if(stratixiii_block == 1)
        if (extra_latency !=0 && output_register == "UNREGISTERED" && (width_a > 36 || width_b > 36))
        begin
            if ((multiplier_register0 != "UNREGISTERED") || (input_register_a0 !="UNREGISTERED")) 
                if (((multiplier_reg0_wire_clk  == 1) && (multiplier_reg0_wire_en == 1)) ||  ((input_reg_a0_wire_clk === 1'b1) && (input_reg_a0_wire_en == 1)))
                begin
                    result_pipe [head_result] <= round_sat_blk_res[2*int_width_result - 1 :0];
                    overflow_stat_pipe_reg [head_result] <= overflow_status;
                    unsigned_sub1_overflow_pipe_reg [head_result] <= unsigned_sub1_overflow_mult_reg;
                    unsigned_sub3_overflow_pipe_reg [head_result] <= unsigned_sub1_overflow_mult_reg;
                    head_result <= (head_result +1) % (extra_latency);
                end
        end
    end
                              
    always @(posedge output_reg_wire_clk or posedge output_reg_wire_clr)
    begin
        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            if (output_reg_wire_clr == 1)
            begin
                temp_sum_reg <= {(2*int_width_result){1'b0}};
                
                for ( num_stor = extra_latency; num_stor >= 0; num_stor = num_stor - 1 )
                begin
                    result_pipe[num_stor] <= {int_width_result{1'b0}};
                end
                
                mult_saturate_overflow_pipe_reg <= {4{1'b0}};
                
                head_result <= 0;
            end
            else if ((output_reg_wire_clk ==1) && (output_reg_wire_en ==1))
            begin
                
                if (extra_latency == 0)
                begin
                    temp_sum_reg[int_width_result :0] <= temp_sum[int_width_result-1 :0];
                    temp_sum_reg[2*int_width_result - 1 :int_width_result] <= {(2*int_width_result - int_width_result){temp_sum[int_width_result]}};
                end
                else
                begin
                    result_pipe [head_result] <= temp_sum[2*int_width_result-1 :0];
                    head_result <= (head_result +1) % (extra_latency + 1);
                end
                mult_saturate_overflow_pipe_reg <= mult_saturate_overflow_vec;
            end
        end
        else // Stratix III
        begin
            if (chainout_adder == "NO" && shift_mode == "NO") // if chainout and shift block is not used, this will be the output stage
            begin
                if (output_reg_wire_clr == 1)
                begin
                    temp_sum_reg <= {(2*int_width_result){1'b0}};
                    overflow_stat_reg <= 1'b0;
                    unsigned_sub1_overflow_reg <= 1'b0;
                    unsigned_sub3_overflow_reg <= 1'b0;
                    for ( num_stor = extra_latency; num_stor >= 0; num_stor = num_stor - 1 )
                    begin
                        result_pipe[num_stor] <= {int_width_result{1'b0}};
                        result_pipe1[num_stor] <= {int_width_result{1'b0}};
                        overflow_stat_pipe_reg <= 1'b0;
                        unsigned_sub1_overflow_pipe_reg <= 1'b0;
                        unsigned_sub3_overflow_pipe_reg <= 1'b0;
                    end
                    head_result <= 0;
                    
                    if (accumulator == "YES") 
                        acc_feedback_reg <= {2*int_width_result{1'b0}};
                        
                    if (input_source_b0 == "LOOPBACK")
                        loopback_wire_reg <= {int_width_result {1'b0}};
                        
                end               
                                  
                else if ((output_reg_wire_clk ==1) && (output_reg_wire_en ==1))
                begin
                    if (extra_latency == 0)
                    begin
                        temp_sum_reg[2*int_width_result - 1 :0] <= round_sat_blk_res[2*int_width_result - 1 :0];
                        loopback_wire_reg <= round_sat_blk_res[int_width_result + (int_width_b - width_b) - 1 : int_width_b - width_b];
                        overflow_stat_reg <= overflow_status;
                        if(multiplier_register0 != "UNREGISTERED")
                            unsigned_sub1_overflow_reg <= unsigned_sub1_overflow_mult_reg;
                        else
                            unsigned_sub1_overflow_reg <= unsigned_sub1_overflow;
                        if(multiplier_register2 != "UNREGISTERED")
                            unsigned_sub3_overflow_reg <= unsigned_sub3_overflow_mult_reg;
                        else
                            unsigned_sub3_overflow_reg <= unsigned_sub3_overflow;
                            
                        if(stratixv_block)   
                        begin
                            if (accumulator == "YES") //|| accum_wire == 1)
                            begin
                    	        acc_feedback_reg <= round_sat_in_result[2*int_width_result-1 : 0];
                            end
                        end
                         
                    end
                    else
                    begin
                        result_pipe [head_result] <= round_sat_blk_res[2*int_width_result - 1 :0];
                        result_pipe1 [head_result] <= round_sat_blk_res[int_width_result + (int_width_b - width_b) - 1 : int_width_b - width_b];
                        overflow_stat_pipe_reg [head_result] <= overflow_status;
                        if(multiplier_register0 != "UNREGISTERED")
                            unsigned_sub1_overflow_pipe_reg [head_result] <= unsigned_sub1_overflow_mult_reg;
                        else
                            unsigned_sub1_overflow_pipe_reg [head_result] <= unsigned_sub1_overflow;
                        
                        if(multiplier_register2 != "UNREGISTERED") 
                            unsigned_sub3_overflow_pipe_reg [head_result] <= unsigned_sub3_overflow_mult_reg;
                        else   
                            unsigned_sub3_overflow_pipe_reg [head_result] <= unsigned_sub3_overflow;
                        
                        head_result <= (head_result +1) % (extra_latency + 1);
                    end
                    if (accumulator == "YES") //|| accum_wire == 1)
                    begin
                    	acc_feedback_reg <= round_sat_blk_res[2*int_width_result-1 : 0];
                    end
                    
                    loopback_wire_reg <= round_sat_blk_res[int_width_result + (int_width_b - width_b) - 1 : int_width_b - width_b];

                end
            end
            else  // chainout/shift block is used, this is the 2nd stage, chainout/shift block will be the final stage
            begin
                if (output_reg_wire_clr == 1)
                begin
                    chout_shftrot_reg <= {(int_width_result + 1) {1'b0}};
                    if (accumulator == "YES")
                        acc_feedback_reg <= {2*int_width_result{1'b0}};

                end
                else if ((output_reg_wire_clk == 1) && (output_reg_wire_en == 1))
                begin
                    chout_shftrot_reg[(int_width_result - 1) : 0] <= round_sat_blk_res[(int_width_result - 1) : 0];
                    if (accumulator == "YES")
                    begin
                        acc_feedback_reg <= round_sat_blk_res[2*int_width_result-1 : 0];
                    end
                end
                
                if (output_reg_wire_clr == 1 )
                begin
                    temp_sum_reg <= {(2*int_width_result){1'b0}};
                    overflow_stat_reg <= 1'b0;
                    unsigned_sub1_overflow_reg <= 1'b0;
                    unsigned_sub3_overflow_reg <= 1'b0;
                    for ( num_stor = extra_latency; num_stor >= 0; num_stor = num_stor - 1 )
                    begin
                        result_pipe[num_stor] <= {int_width_result{1'b0}};
                        overflow_stat_pipe_reg <= 1'b0;
                        unsigned_sub1_overflow_pipe_reg <= 1'b0;
                        unsigned_sub3_overflow_pipe_reg <= 1'b0;
                    end
                    head_result <= 0;
                    
                    if (accumulator == "YES" )
                        acc_feedback_reg <= {2*int_width_result{1'b0}};
                        
                    if (input_source_b0 == "LOOPBACK")
                        loopback_wire_reg <= {int_width_result {1'b0}};                 
                end               
                else if ((output_reg_wire_clk ==1) && (output_reg_wire_en ==1))
                begin
                    if (extra_latency == 0)
                    begin
                        temp_sum_reg[2*int_width_result - 1 :0] <= round_sat_blk_res[2*int_width_result - 1 :0];
                        overflow_stat_reg <= overflow_status;
                        if(multiplier_register0 != "UNREGISTERED")
                            unsigned_sub1_overflow_reg <= unsigned_sub1_overflow_mult_reg;
                        else
                            unsigned_sub1_overflow_reg <= unsigned_sub1_overflow;
                            
                        if(multiplier_register2 != "UNREGISTERED")
                        unsigned_sub3_overflow_reg <= unsigned_sub3_overflow_mult_reg;
                        else
                            unsigned_sub3_overflow_reg <= unsigned_sub3_overflow;
                    end
                    else
                    begin
                        result_pipe [head_result] <= round_sat_blk_res[2*int_width_result - 1 :0];
                        overflow_stat_pipe_reg [head_result] <= overflow_status;
                        if(multiplier_register0 != "UNREGISTERED")
                            unsigned_sub1_overflow_pipe_reg <= unsigned_sub1_overflow_mult_reg;
                        else
                            unsigned_sub1_overflow_pipe_reg <= unsigned_sub1_overflow;

                        if(multiplier_register2 != "UNREGISTERED")
                            unsigned_sub3_overflow_pipe_reg <= unsigned_sub1_overflow_mult_reg;
                        else
                            unsigned_sub3_overflow_pipe_reg <= unsigned_sub1_overflow;
                        
                        head_result <= (head_result +1) % (extra_latency + 1);
                    end
                end
                
            end
        end
    end

    assign head_result_wire = head_result[31:0];
    
    always @(head_result_wire or result_pipe[head_result_wire])
    begin
        if (extra_latency != 0)
            temp_sum_reg[2*int_width_result - 1 :0] <= result_pipe[head_result_wire];
    end
    
    always @(head_result_wire or result_pipe1[head_result_wire])
    begin
        if (extra_latency != 0)
            loopback_wire_latency <= result_pipe1[head_result_wire];
    end
    
    always @(head_result_wire or overflow_stat_pipe_reg[head_result_wire])
    begin
        if (extra_latency != 0)
            overflow_stat_reg <= overflow_stat_pipe_reg[head_result_wire];
    end

    always @(head_result_wire or accum_overflow_stat_pipe_reg[head_result_wire])
    begin
        if (extra_latency != 0)
            accum_overflow_reg <= accum_overflow_stat_pipe_reg[head_result_wire];
    end
    
    always @(head_result_wire or unsigned_sub1_overflow_pipe_reg[head_result_wire])
    begin
        if (extra_latency != 0)
            unsigned_sub1_overflow_reg <= unsigned_sub1_overflow_pipe_reg[head_result_wire];
    end

    always @(head_result_wire or unsigned_sub3_overflow_pipe_reg[head_result_wire])
    begin
        if (extra_latency != 0)
            unsigned_sub3_overflow_reg <= unsigned_sub3_overflow_pipe_reg;
    end


    always @(mult_res_wire [4 * (int_width_a + int_width_b) -1:0] or
            addsub1_pipe_wire or  addsub3_pipe_wire or
            sign_a_pipe_wire  or  sign_b_pipe_wire or addnsub1_round_pipe_wire or
            addnsub3_round_pipe_wire or sign_a_wire or sign_b_wire)
    begin
        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            temp_sum =0;
            for (num_mult = 0; num_mult < number_of_multipliers; num_mult = num_mult +1)
            begin

                mult_res_temp = mult_res_wire >> (num_mult * (int_width_a + int_width_b));
                mult_res_ext = ((int_width_result > (int_width_a + int_width_b))?
                                {{(mult_res_pad)
                                {mult_res_temp [int_width_a + int_width_b - 1] & 
                                (sign_a_pipe_wire | sign_b_pipe_wire)}}, mult_res_temp}:mult_res_temp);
                
                if (num_mult == 0)
                    temp_sum = do_add1_level1(0, sign_a_wire, sign_b_wire);
                
                else if (num_mult == 1)
                begin
                    if (addsub1_pipe_wire)
                        temp_sum = do_add1_level1(0, sign_a_wire, sign_b_wire);
                    else
                        temp_sum = do_sub1_level1(0, sign_a_wire, sign_b_wire);
                                            
                    if (stratixii_block == 1)
                    begin
                        // -------------------------------------------------------
                        // Stratix II Rounding support 
                        // This block basically carries out the rounding for the 
                        // temp_sum. The equation to get the roundout for adder1 and
                        // adder3 is obtained from the Stratix II Mac FFD which is below:
                        // round_adder_constant = (1 << (wfraction - wfraction_round - 1))
                        // roundout[] = datain[] + round_adder_constant
                        // For Stratix II rounding, we round up the bits to 15 bits
                        // or in another word wfraction_round = 15.
                        // --------------------------------------------------------
        
                        if ((adder1_rounding == "YES") ||
                            ((adder1_rounding == "VARIABLE") && (addnsub1_round_pipe_wire == 1)))
                        begin
                            adder1_round_out = temp_sum + ( 1 << (`ADDER_ROUND_BITS - 1));

                            for (j = (`ADDER_ROUND_BITS - 1); j >= 0; j = j - 1)
                            begin
                                adder1_round_out[j] = 1'b0;
                            end

                        end
                        else
                        begin
                            adder1_round_out = temp_sum;
                        end
        
                            adder1_result = adder1_round_out;
                    end

                    if (stratixii_block)
                    begin
                        temp_sum = adder1_result;
                    end
                    
                end
                
                else if (num_mult == 2)
                begin
                    if (stratixii_block == 1)
                    begin
                        adder2_result = mult_res_ext; 
                        temp_sum = adder2_result;
                    end
                    else
                        temp_sum = do_add1_level1(0, sign_a_wire, sign_b_wire);
                end 
                else if (num_mult == 3 || ((number_of_multipliers == 3) && ((adder3_rounding == "YES") ||
                ((adder3_rounding == "VARIABLE") && (addnsub3_round_pipe_wire == 1)))))
                begin
                    if (addsub3_pipe_wire && num_mult == 3)
                        temp_sum = do_add1_level1(0, sign_a_wire, sign_b_wire);
                    else
                        temp_sum = do_sub1_level1(0, sign_a_wire, sign_b_wire);  
                    
                    if (stratixii_block == 1)
                    begin
                        // StratixII rounding support
                        // Please see the description for rounding support in adder1

                        if ((adder3_rounding == "YES") ||
                            ((adder3_rounding == "VARIABLE") && (addnsub3_round_pipe_wire == 1)))
                        begin
                             
                            adder3_round_out = temp_sum + ( 1 << (`ADDER_ROUND_BITS - 1));

                            for (j = (`ADDER_ROUND_BITS - 1); j >= 0; j = j - 1)
                                begin
                                adder3_round_out[j] = 1'b0;
                                end
 
                        end
                        else
                        begin
                            adder3_round_out = temp_sum;
                            end

                            adder3_result = adder3_round_out;
                    end

                    if (stratixii_block)
                    begin
                        temp_sum = adder1_result + adder3_result;
                        if ((addsub3_pipe_wire == 0) && (sign_a_wire == 0) && (sign_b_wire == 0))
                        begin
                            for (j = int_width_a + int_width_b + 2; j < int_width_result; j = j +1)
                            begin
                                temp_sum[j] = 0;
                            end
                            temp_sum [int_width_a + int_width_b + 1:0] = temp_sum [int_width_a + int_width_b + 1:0];
                        end
                    end
                end
            end
            
            if ((number_of_multipliers == 3 || number_of_multipliers == 2) && (stratixii_block == 1))
            begin
                temp_sum = adder1_result;
                mult_res_ext = adder2_result;
                temp_sum = (number_of_multipliers == 3)? do_add1_level1(0, sign_a_wire, sign_b_wire) : adder1_result;  
                if ((addsub1_pipe_wire == 0) && (sign_a_wire == 0) && (sign_b_wire == 0))
                begin
                    if (number_of_multipliers == 3)
                    begin
                        for (j = int_width_a + int_width_b + 2; j < int_width_result; j = j +1)
                        begin
                            temp_sum[j] = 0;
                        end
                    end
                    else 
                    begin
                        for (j = int_width_a + int_width_b + 1; j < int_width_result; j = j +1) 
                        begin
                            temp_sum[j] = 0;
                        end
                    end
                end
            end
        end     
    end

    // this block simulates the 1st level adder in Stratix III
    always @(mult_res_wire [4 * (int_width_a + int_width_b) -1:0] or sign_a_wire or sign_b_wire)
    begin
        if (stratixiii_block || stratixv_block)
        begin
            adder1_sum = 0;
            adder3_sum = 0;
            for (num_mult = 0; num_mult < number_of_multipliers; num_mult = num_mult +1)
            begin

                mult_res_temp = mult_res_wire >> (num_mult * (int_width_a + int_width_b));
                mult_res_ext = ((int_width_result > (int_width_a + int_width_b))?
                                {{(mult_res_pad)
                                {mult_res_temp [int_width_a + int_width_b - 1] & 
                                (sign_a_wire | sign_b_wire)}}, mult_res_temp}:mult_res_temp);

                if (num_mult == 0)
                begin
                    adder1_sum = mult_res_ext;
                    if((sign_a_wire == 0) && (sign_b_wire == 0))
                        adder1_sum = {{(2*int_width_result - int_width_a - int_width_b){1'b0}}, adder1_sum[int_width_a + int_width_b - 1:0]};
                    else
                        adder1_sum = {{(2*int_width_result - int_width_a - int_width_b){adder1_sum[int_width_a + int_width_b - 1]}}, adder1_sum[int_width_a + int_width_b - 1:0]};
                end
                else if (num_mult == 1)
                begin
                    if (multiplier1_direction == "ADD")
                        adder1_sum = do_add1_level1 (0, sign_a_wire, sign_b_wire);  
                    else
                        adder1_sum = do_sub1_level1  (0, sign_a_wire, sign_b_wire);  
                end
                else if (num_mult == 2)
                begin
                    adder3_sum = mult_res_ext;
                    if((sign_a_wire == 0) && (sign_b_wire == 0))
                        adder3_sum = {{(2*int_width_result - int_width_a - int_width_b){1'b0}}, adder3_sum[int_width_a + int_width_b - 1:0]};
                    else
                        adder3_sum = {{(2*int_width_result - int_width_a - int_width_b){adder3_sum[int_width_a + int_width_b - 1]}}, adder3_sum[int_width_a + int_width_b - 1:0]};
                end
                else if (num_mult == 3)
                begin
                    if (multiplier3_direction == "ADD")
                        adder3_sum = do_add3_level1 (0, sign_a_wire, sign_b_wire);  
                    else 
                        adder3_sum = do_sub3_level1  (0, sign_a_wire, sign_b_wire); 
                end
            end        
        end     
    end

    // figure out which signal feeds into the 2nd adder/accumulator for Stratix III
    assign adder1_res_wire = (multiplier_register0 == "UNREGISTERED")? adder1_sum: adder1_reg;
    assign adder3_res_wire = (multiplier_register2 == "UNREGISTERED")? adder3_sum: adder3_reg;
    assign unsigned_sub1_overflow_wire = (output_register == "UNREGISTERED")? (multiplier_register0 != "UNREGISTERED")?
                                                        unsigned_sub1_overflow_mult_reg : unsigned_sub1_overflow 
                                                        : unsigned_sub1_overflow_reg;
    assign unsigned_sub3_overflow_wire = (output_register == "UNREGISTERED")? (multiplier_register2 != "UNREGISTERED")?
                                                        unsigned_sub3_overflow_mult_reg : unsigned_sub3_overflow
                                                        : unsigned_sub3_overflow_reg;
    assign acc_feedback[(2*int_width_result - 1) : 0] = (accumulator == "YES") ? 
                                                        ((output_register == "UNREGISTERED") ? (round_sat_blk_res[2*int_width_result - 1 : 0] & ({2*int_width_result{~accumsload_pipe_wire}})) :
                                                        ((stratixv_block)?(acc_feedback_reg[2*int_width_result - 1 : 0] & ({2*int_width_result{~accumsload_wire}})):(acc_feedback_reg[2*int_width_result - 1 : 0] & ({2*int_width_result{~accumsload_pipe_wire}})))) :
                                                        0;
                                                        
	assign load_const_value = ((loadconst_value > 63) ||(loadconst_value < 0) ) ?   0: (1 << loadconst_value);
    
    assign accumsload_sel = (accumsload_wire) ? load_const_value : acc_feedback ;   
    
    assign adder1_systolic_register0 = (systolic_delay3 == "UNREGISTERED")? adder1_res_wire
                                : adder1_res_reg_0;
    always @(posedge systolic3_reg_wire_clk or posedge systolic3_reg_wire_clr)
    begin
        if (stratixv_block == 1)
        begin
            if (systolic3_reg_wire_clr == 1) 
            begin 
                adder1_res_reg_0[2*int_width_result - 1: 0] <= 0;
            end
            else if ((systolic3_reg_wire_clk == 1) && (systolic3_reg_wire_en == 1))
            begin
                adder1_res_reg_0[2*int_width_result - 1: 0] <= adder1_res_wire;
            end
        end
	end       
	
	assign adder1_systolic_register1 = (systolic_delay3 == "UNREGISTERED")? adder1_res_wire
                                : adder1_res_reg_1;
    always @(posedge output_reg_wire_clk or posedge output_reg_wire_clr)
    begin
        if (stratixv_block == 1)
        begin
            if (output_reg_wire_clr == 1) 
            begin 
                adder1_res_reg_1[2*int_width_result - 1: 0] <= 0;
            end
            else if ((output_reg_wire_clk == 1) && (output_reg_wire_en == 1))
            begin
                adder1_res_reg_1[2*int_width_result - 1: 0] <= adder1_systolic_register0;
            end
        end
	end  	                                               
    
	assign adder1_systolic = (number_of_multipliers == 2)? adder1_res_wire : adder1_systolic_register1;
	
    // 2nd stage adder/accumulator in Stratix III
    always @(adder1_res_wire[int_width_result - 1 : 0] or adder3_res_wire[int_width_result - 1 : 0] or sign_a_wire or sign_b_wire or accumsload_sel or adder1_systolic or
                acc_feedback[2*int_width_result - 1 : 0] or adder1_res_wire or adder3_res_wire or mult_res_0 or mult_res_1 or mult_res_2 or mult_res_3)
    begin
        if (stratixiii_block || stratixv_block)
        begin                              
            adder1_res_ext = adder1_res_wire;
            adder3_res_ext = adder3_res_wire;
            
            if (stratixv_block)
            begin
                if(accumsload_wire)
                begin
            	    round_sat_in_result = adder1_systolic + adder3_res_ext + accumsload_sel;
            	end
            	else
            	begin
            	    if(accumulator == "YES")
            	        round_sat_in_result = adder1_systolic + adder3_res_ext + accumsload_sel;
            	    else
            	        round_sat_in_result = adder1_systolic + adder3_res_ext ;
            	end
            end
            else if (accumulator == "NO")
            begin
                round_sat_in_result =  adder1_res_wire + adder3_res_ext;          
            end
            else if ((accumulator == "YES") && (accum_direction == "ADD"))
            begin
                round_sat_in_result = acc_feedback + adder1_res_wire + adder3_res_ext;
            end
            else  // minus mode
            begin
                round_sat_in_result = acc_feedback - adder1_res_wire - adder3_res_ext;
            end
        end
    end
 
    always @(adder1_res_wire[int_width_result - 1 : 0] or adder3_res_wire[int_width_result - 1 : 0] or sign_a_pipe_wire or sign_b_pipe_wire or
                acc_feedback[2*int_width_result - 1 : 0] or adder1_res_ext or adder3_res_ext)
    begin
        if(accum_width < 2*int_width_result - 1)
            for(i = accum_width; i >= 0; i = i - 1)
                acc_feedback_temp[i] = acc_feedback[i];
        else
        begin
            for(i = 2*int_width_result - 1; i >= 0; i = i - 1)
                acc_feedback_temp[i] = acc_feedback[i];
            
            for(i = accum_width - 1; i >= 2*int_width_result; i = i - 1)
                acc_feedback_temp[i] = acc_feedback[2*int_width_result - 1];
        end
        
        if(accum_width + int_mult_diff_bit < 2*int_width_result - 1)
            for(i = accum_width + int_mult_diff_bit; i >= 0; i = i - 1)
            begin 
                adder1_res_ext[i] = adder1_res_wire[i];
                adder3_res_temp[i] = adder3_res_wire[i];
            end
        else
        begin
            for(i = 2*int_width_result - 1; i >= 0; i = i - 1)
            begin
                adder1_res_ext[i] = adder1_res_wire[i];
                adder3_res_temp[i] = adder3_res_wire[i];
            end
            
            for(i = accum_width + int_mult_diff_bit - 1; i >= 2*int_width_result; i = i - 1)
            begin
                if(sign_a_pipe_wire == 1'b1 || sign_b_pipe_wire == 1'b1)
                begin
                    adder1_res_ext[i] = adder1_res_wire[2*int_width_result - 1];
                    adder3_res_temp[i] = adder3_res_wire[2*int_width_result - 1];
                end
                else 
                begin
                    adder1_res_ext[i] = 0;
                    adder3_res_temp[i] = 0;
                end
            end
        end
        
        
        if(sign_a_pipe_wire == 1'b1 || sign_b_pipe_wire == 1'b1)
        begin              
            if(acc_feedback_temp[accum_width - 1 + int_mult_diff_bit] == 1'b1)
                acc_feedback_temp[accum_width + int_mult_diff_bit ] = 1'b1;
            else
                acc_feedback_temp[accum_width + int_mult_diff_bit ] = 1'b0;            
        end
        else 
        begin
            acc_feedback_temp[accum_width + int_mult_diff_bit ] = 1'b0;       
        end     
        
        if(accum_direction == "ADD")
            accum_res_temp[accum_width + int_mult_diff_bit : 0] = adder1_res_ext[accum_width - 1 + int_mult_diff_bit : 0]  + adder3_res_temp[accum_width - 1 + int_mult_diff_bit : 0] ;    
        else
            accum_res_temp = acc_feedback_temp[accum_width - 1 + int_mult_diff_bit : 0]  - adder1_res_ext[accum_width - 1 + int_mult_diff_bit : 0] ;   
        
        if(sign_a_pipe_wire == 1'b1 || sign_b_pipe_wire == 1'b1)
        begin
            if(accum_res_temp[accum_width - 1 + int_mult_diff_bit] == 1'b1)
                accum_res_temp[accum_width + int_mult_diff_bit ] = 1'b1; 
            else
                accum_res_temp[accum_width + int_mult_diff_bit ] = 1'b0; 
            
            if(adder3_res_temp[accum_width - 1 + int_mult_diff_bit] == 1'b1)
                adder3_res_temp[accum_width + int_mult_diff_bit ] = 1'b1; 
            else
                adder3_res_temp[accum_width + int_mult_diff_bit ] = 1'b0; 
        end
        /*else 
        begin
            accum_res_temp[accum_width + int_mult_diff_bit ] = 1'b0; 
        end*/     
        
        if(accum_direction == "ADD")
            accum_res = acc_feedback_temp[accum_width + int_mult_diff_bit  : 0] + accum_res_temp[accum_width + int_mult_diff_bit : 0 ];
        else
            accum_res = accum_res_temp[accum_width + int_mult_diff_bit  : 0] - adder3_res_temp[accum_width + int_mult_diff_bit : 0 ];  
            
        or_sign_wire = 1'b0;
        and_sign_wire = 1'b0;
            
        if(extra_sign_bit_width >= 1)
        begin
            and_sign_wire = 1'b1;

            for(i = accum_width -lsb_position - 1; i >= accum_width -lsb_position - extra_sign_bit_width; i = i - 1)
            begin
                if(accum_res[i] == 1'b1)
                    or_sign_wire = 1'b1;

                if(accum_res[i] == 1'b0)
                    and_sign_wire = 1'b0;
            end
        end
        
        if(port_signa == "PORT_USED" || port_signb == "PORT_USED")
        begin
            if(sign_a_pipe_wire == 1'b1 || sign_b_pipe_wire == 1'b1)
            begin
            //signed data
                if(accum_res[44] != accum_res[43])
                    accum_overflow_int = 1'b1;
                else
                    accum_overflow_int = 1'b0;
            end
            else
            begin
            // unsigned data
                if(accum_direction == "ADD")    // addition
                begin
                    if(accum_res[44] == 1'b1)
                        accum_overflow_int = 1'b1;
                    else
                        accum_overflow_int = 1'b0;
                end
                else    // subtraction
                begin
                    if(accum_res[44] == 1'b0)
                        accum_overflow_int = 1'b0;
                    else
                        accum_overflow_int = 1'b0;
                end
            end

            // dynamic sign input

            if(accum_res[bit_position] == 1'b1)
                msb = 1'b1;
            else
                msb = 1'b0;

            if(extra_sign_bit_width >= 1)
            begin
                if((and_sign_wire == 1'b1) && ((!(sign_a_pipe_wire == 1'b1 || sign_b_pipe_wire == 1'b1)) || ((sign_a_pipe_wire == 1'b1 || sign_b_pipe_wire == 1'b1) && (msb == 1'b1))))
                    and_sign_wire = 1'b1;
                else
                    and_sign_wire = 1'b0;

                if ((sign_a_pipe_wire == 1'b1 || sign_b_pipe_wire == 1'b1) && (msb == 1'b1))
                    or_sign_wire = 1'b1;
            end

            //operation XOR
            if ((or_sign_wire != and_sign_wire) || accum_overflow_int == 1'b1)
                accum_overflow = 1'b1;
            else
                accum_overflow = 1'b0;
        end
        else if(representation_a == "SIGNED" || representation_b == "SIGNED")
        begin
        //signed data
            if (accum_res[44] != accum_res[43])
                accum_overflow_int = 1'b1;
            else
                accum_overflow_int = 1'b0;

        //operation XOR
            if ((or_sign_wire != and_sign_wire) || accum_overflow_int == 1'b1)
                accum_overflow = 1'b1;
            else
                accum_overflow = 1'b0;
        end
        else
        begin
        // unsigned data
            if(accum_direction == "ADD")
            begin
            // addition
                if (accum_res[44] == 1'b1)
                    accum_overflow_int = 1'b1;
                else
                    accum_overflow_int = 1'b0;
            end
            else
            begin
            // subtraction
                if (accum_res[44] == 1'b0)
                    accum_overflow_int = 1'b1;
                else
                    accum_overflow_int = 1'b0;
            end

            if(or_sign_wire == 1'b1 || accum_overflow_int == 1'b1)
                accum_overflow = 1'b1;
            else
                accum_overflow = 1'b0;
        end
    end
                    
    always @(posedge output_reg_wire_clk or posedge output_reg_wire_clr)
    begin
        if (stratixiii_block == 1 || stratixv_block == 1)
        begin
            if (output_reg_wire_clr == 1)
            begin
                for ( num_stor = extra_latency; num_stor >= 0; num_stor = num_stor - 1 )
                begin
                    accum_overflow_stat_pipe_reg <= 1'b0;
                    accum_overflow_reg <= 1'b0;
                end
                head_result <= 0;    
            end
            else if ((output_reg_wire_clk ==1) && (output_reg_wire_en ==1))
            begin
                if (extra_latency == 0)
                begin
                    accum_overflow_reg <= accum_overflow;
                end
                else
                begin
                    accum_overflow_stat_pipe_reg [head_result] <= accum_overflow;
                    head_result <= (head_result +1) % (extra_latency + 1);
                end    
            end
        end
    end      
                    
    // model the saturation and rounding block in Stratix III
    // the rounding block feeds into the saturation block
    always @(round_sat_in_result[int_width_result : 0] or outround_pipe_wire or outsat_pipe_wire or sign_a_int or sign_b_int or adder3_res_ext or adder1_res_ext or acc_feedback or round_sat_in_result)
    begin
        if (stratixiii_block || stratixv_block)
        begin
            round_happen = 0;
            // Rounding part
            if (output_rounding == "NO")
            begin
                round_block_result = round_sat_in_result;
            end
            else
            begin
                if (((output_rounding == "VARIABLE") && (outround_pipe_wire == 1)) || (output_rounding == "YES"))
                begin
                    if (round_sat_in_result[round_position - 1] == 1'b1) // guard bit
                    begin
                        if (output_round_type == "NEAREST_INTEGER") // round to nearest integer
                        begin
                            round_block_result = round_sat_in_result + (1 << (round_position));
                        end 
                        else
                        begin // round to nearest even
                            stick_bits_or = 0;
                            for (rnd_bit_cnt = (round_position - 2); rnd_bit_cnt >= 0; rnd_bit_cnt = rnd_bit_cnt - 1)
                            begin
                                stick_bits_or = (stick_bits_or | round_sat_in_result[rnd_bit_cnt]);
                            end
                            // if any sticky bits = 1, then do the rounding
                            if (stick_bits_or == 1'b1)
                            begin
                                round_block_result = round_sat_in_result + (1 << (round_position));
                            end
                            else // all sticky bits are 0, look at the LSB to determine rounding
                            begin
                                if (round_sat_in_result[round_position] == 1'b1) // LSB is 1, odd number, so round
                                begin
                                    round_block_result = round_sat_in_result + ( 1 << (round_position));
                                end
                                else
                                    round_block_result = round_sat_in_result;
                            end
                        end
                    end
                    else // guard bit is 0, don't round
                        round_block_result = round_sat_in_result;

                    // if unsigned number comes into the rounding & saturation block, X the entire output since unsigned numbers
                    // are invalid
                    if ((sign_a_int == 0) && (sign_b_int == 0) &&
                        (((port_signa == "PORT_USED") && (port_signb == "PORT_USED" )) || 
                        ((representation_a != "UNUSED") && (representation_b != "UNUSED"))))
                    begin
                        for (sat_all_bit_cnt = 0; sat_all_bit_cnt <= int_width_result; sat_all_bit_cnt = sat_all_bit_cnt + 1)
                        begin
                            round_block_result[sat_all_bit_cnt] = 1'bx;
                        end
                    end
                    
                    // force the LSBs beyond the rounding position to "X"
                    if(accumulator == "NO" && input_source_b0 != "LOOPBACK")
                    begin
                        for (rnd_bit_cnt = (round_position - 1); rnd_bit_cnt >= 0; rnd_bit_cnt = rnd_bit_cnt - 1)
                        begin
                            round_block_result[rnd_bit_cnt] = 1'bx;
                        end
                    end
                    
                    round_happen = 1;
                end
                else
                    round_block_result = round_sat_in_result;
            end            
                      
            // prevent the previous overflow_status being taken into consideration when determining the overflow
            if ((overflow_status == 1'b1) && (port_output_is_overflow == "PORT_UNSUED"))
                overflow_status_bit_pos = int_width_a + int_width_b - 1;
            else if ((overflow_status == 1'b0) && (port_output_is_overflow == "PORT_UNUSED") && (chainout_adder == "NO"))
                overflow_status_bit_pos = int_width_result + int_mult_diff_bit - 1;
            else
                overflow_status_bit_pos = int_width_result + 1;
            
            
            // Saturation part
            if (output_saturation == "NO")
                sat_block_result = round_block_result;
            else
            begin
                overflow_status = 0;
                if (((output_saturation == "VARIABLE") && (outsat_pipe_wire == 1)) || (output_saturation == "YES"))
                begin
                    overflow_status = 0;
                    if (round_block_result[2*int_width_result - 1] == 1'b0) // carry bit is 0 - positive number
                    begin
                        for (sat_bit_cnt = (int_width_result); sat_bit_cnt >= (saturation_position); sat_bit_cnt = sat_bit_cnt - 1)
                        begin                            
                            if (sat_bit_cnt != overflow_status_bit_pos)
                            begin
                                overflow_status = overflow_status | round_block_result[sat_bit_cnt];
                            end
                        end
                    end
                    
                    else // carry bit is 1 - negative number
                    begin
                        for (sat_bit_cnt = (int_width_result); sat_bit_cnt >= (saturation_position); sat_bit_cnt = sat_bit_cnt - 1)
                        begin
                            if (sat_bit_cnt != overflow_status_bit_pos)
                            begin 
                                overflow_status = overflow_status | (~round_block_result[sat_bit_cnt]);
                            end
                        end
                        
                        if ((output_saturate_type == "SYMMETRIC") && (overflow_status == 1'b0)) 
                        begin
                            overflow_status = 1'b1;
                            if (round_happen == 1) 
                                for (sat_bit_cnt = (saturation_position - 1); sat_bit_cnt >= (round_position); sat_bit_cnt = sat_bit_cnt - 1)
                                begin
                                    overflow_status = overflow_status & (~(round_block_result [sat_bit_cnt]));
                                end
                            else
                                for (sat_bit_cnt = (saturation_position - 1); sat_bit_cnt >= 0 ; sat_bit_cnt = sat_bit_cnt - 1)
                            begin
                                    overflow_status = overflow_status & (~(round_block_result [sat_bit_cnt]));
                            end    
                        end
                    end
                        
                    if (overflow_status == 1'b1)
                    begin
                        if (round_block_result[2*int_width_result - 1] == 1'b0) // positive number
                        begin
                            if (port_output_is_overflow == "PORT_UNUSED") // set the overflow status to the MSB of the results
                                sat_block_result[int_width_a + int_width_b - 1] = overflow_status;
                            else if (accumulator == "NO") 
                                sat_block_result[int_width_a + int_width_b - 1] = 1'bx;

                            for (sat_bit_cnt = (int_width_a + int_width_b); sat_bit_cnt >= (saturation_position); sat_bit_cnt = sat_bit_cnt - 1)
                            begin
                                sat_block_result[sat_bit_cnt] = 1'b0;  // set the leading bits on the left of the saturation position to 0
                            end 
                            
                            // if rounding is used, the LSBs after the rounding position should be "X-ed", from above
                            if ((round_happen == 1))
                            begin
                                for (sat_bit_cnt = (saturation_position - 1); sat_bit_cnt >= round_position; sat_bit_cnt = sat_bit_cnt - 1)
                                begin
                                    sat_block_result[sat_bit_cnt] = 1'b1; // set the trailing bits on the right of the saturation position to 1
                                end
                            end
                            else // rounding not used
                            begin
                                for (sat_bit_cnt = (saturation_position - 1); sat_bit_cnt >= 0; sat_bit_cnt = sat_bit_cnt - 1)
                                begin
                                    sat_block_result[sat_bit_cnt] = 1'b1; // set the trailing bits on the right of the saturation position to 1
                                end
                            end
                            sat_block_result = {{(2*int_width_result - int_width_a - int_width_b){1'b0}}, sat_block_result[int_width_a + int_width_b : 0]};                                                                                                                 
                        end                          
                        else // negative number
                        begin
                            if (port_output_is_overflow == "PORT_UNUSED") // set the overflow status to the MSB of the results
                                sat_block_result[int_width_a + int_width_b - 1] = overflow_status;
                            else if (accumulator == "NO") 
                                sat_block_result[int_width_a + int_width_b - 1] = 1'bx;

                            for (sat_bit_cnt = (int_width_a + int_width_b); sat_bit_cnt >= saturation_position; sat_bit_cnt = sat_bit_cnt - 1)
                            begin
                                sat_block_result[sat_bit_cnt] = 1'b1; // set the sign bits to 1
                            end
                            
                            // if rounding is used, the LSBs after the rounding position should be "X-ed", from above
                            if ((output_rounding != "NO") && (output_saturate_type == "SYMMETRIC"))
                            begin
                                for (sat_bit_cnt = (saturation_position - 1); sat_bit_cnt >= round_position; sat_bit_cnt = sat_bit_cnt - 1)
                                begin
                                    sat_block_result[sat_bit_cnt] = 1'b0; // set all bits to 0
                                end
                                
                                if (accumulator == "NO")
                                    for (sat_bit_cnt = (round_position - 1); sat_bit_cnt >= 0; sat_bit_cnt = sat_bit_cnt - 1)
                                    begin
                                        sat_block_result[sat_bit_cnt] = 1'bx;
                                    end
                                else
                                    for (sat_bit_cnt = (round_position - 1); sat_bit_cnt >= 0; sat_bit_cnt = sat_bit_cnt - 1)
                                    begin
                                        sat_block_result[sat_bit_cnt] = 1'b0;
                                end
                            end
                            else
                            begin
                                for (sat_bit_cnt = (saturation_position - 1); sat_bit_cnt >= 0; sat_bit_cnt = sat_bit_cnt - 1)
                                begin
                                    sat_block_result[sat_bit_cnt] = 1'b0; // set all bits to 0
                                end
                            end
                            
                            if ((output_rounding != "NO") && (output_saturate_type == "SYMMETRIC"))
                                sat_block_result[round_position] = 1'b1;
                            else if (output_saturate_type == "SYMMETRIC")
                                sat_block_result[int_mult_diff_bit] = 1'b1;                      
                            
                            sat_block_result = {{(2*int_width_result - int_width_a - int_width_b){1'b1}}, sat_block_result[int_width_a + int_width_b : 0]}; 
       
                        end
                    end
                    else
                    begin
                        sat_block_result = round_block_result;
                        
                        if (port_output_is_overflow == "PORT_UNUSED" && chainout_adder == "NO" && (output_saturation == "VARIABLE") && (outsat_pipe_wire == 1)) // set the overflow status to the MSB of the results
                            sat_block_result[int_width_result + int_mult_diff_bit - 1] = overflow_status;
                            
                        if (sat_block_result[sat_msb] == 1'b1) // negative number - checking for a special case
                        begin
                            if (output_saturate_type == "SYMMETRIC")
                            begin
                                sat_bits_or = 0;
                                
                                for (sat_bit_cnt = (int_width_a + int_width_b - 2); sat_bit_cnt >= round_position; sat_bit_cnt = sat_bit_cnt - 1)
                                begin
                                    sat_bits_or = sat_bits_or | sat_block_result[sat_bit_cnt];
                                end

                            end
                        end
                    end

                    // if unsigned number comes into the rounding & saturation block, X the entire output since unsigned numbers
                    // are invalid
                    if ((sign_a_int == 0) && (sign_b_int == 0) &&
                        (((port_signa == "PORT_USED") && (port_signb == "PORT_USED" )) || 
                        ((representation_a != "UNUSED") && (representation_b != "UNUSED"))))
                    begin
                        for (sat_all_bit_cnt = 0; sat_all_bit_cnt <= int_width_result; sat_all_bit_cnt = sat_all_bit_cnt + 1)
                        begin
                            sat_block_result[sat_all_bit_cnt] = 1'bx;
                        end
                    end
                end
                else if ((output_saturation == "VARIABLE") && (outsat_pipe_wire == 0))
                begin 
                    sat_block_result = round_block_result;
                    overflow_status = 0;
                end
                else
                    sat_block_result = round_block_result;
            end
        end
    end
    
    always @(sat_block_result)
    begin
        round_sat_blk_res <= sat_block_result;
    end

    assign overflow = (accumulator !="NO" && output_saturation =="NO")?
                                (output_register == "UNREGISTERED")? 
                                accum_overflow : accum_overflow_reg :
                                (output_register == "UNREGISTERED")? overflow_status : overflow_stat_reg;
    
    // model the chainout mode of Stratix III
    assign chainout_adder_in_wire[int_width_result - 1 : 0] =   (chainout_adder == "YES") ? 
                                                                ((output_register == "UNREGISTERED") ? 
                                                                    round_sat_blk_res[int_width_result - 1 : 0] : chout_shftrot_reg[int_width_result - 1 : 0]) : 0;

    assign chainout_add_result[int_width_result : 0] = (chainout_adder == "YES") ? ((chainout_adder_in_wire[int_width_result - 1 : 0] + chainin_int[width_chainin-1 : 0])) : 0;

    // model the chainout saturation and chainout rounding block in Stratix III
    // the rounding block feeds into the saturation block
    always @(chainout_add_result[int_width_result : 0] or chainout_round_out_wire or chainout_sat_out_wire or sign_a_int or sign_b_int)
    begin
        if (stratixiii_block || stratixv_block)
        begin
            cho_round_happen = 0;
            // Rounding part
            if (chainout_rounding == "NO")
                chainout_round_block_result = chainout_add_result;
            else
            begin
                if (((chainout_rounding == "VARIABLE") && (chainout_round_out_wire == 1)) || (chainout_rounding == "YES"))
                begin
                    overflow_checking = chainout_add_result[int_width_result - 1];
                    if (chainout_add_result[chainout_round_position - 1] == 1'b1) // guard bit
                    begin
                        if (output_round_type == "NEAREST_INTEGER") // round to nearest integer
                        begin
                            round_checking = 1'b1;
                            chainout_round_block_result = chainout_add_result + (1 << (chainout_round_position));
                        end 
                        else
                        begin // round to nearest even
                            cho_stick_bits_or = 0;
                            for (cho_rnd_bit_cnt = (chainout_round_position - 2); cho_rnd_bit_cnt >= 0; cho_rnd_bit_cnt = cho_rnd_bit_cnt - 1)
                            begin
                                cho_stick_bits_or = (cho_stick_bits_or | chainout_add_result[cho_rnd_bit_cnt]);
                            end
                            round_checking = cho_stick_bits_or;
                            // if any sticky bits = 1, then do the rounding
                            if (cho_stick_bits_or == 1'b1)
                            begin
                                chainout_round_block_result = chainout_add_result + (1 << (chainout_round_position));
                            end
                            else // all sticky bits are 0, look at the LSB to determine rounding
                            begin
                                if (chainout_add_result[chainout_round_position] == 1'b1) // LSB is 1, odd number, so round
                                begin
                                    chainout_round_block_result = chainout_add_result + ( 1 << (chainout_round_position));
                                end
                                else
                                    chainout_round_block_result = chainout_add_result;
                            end
                        end
                    end
                    else // guard bit is 0, don't round
                        chainout_round_block_result = chainout_add_result;
  
                    // if unsigned number comes into the rounding & saturation block, X the entire output since unsigned numbers
                    // are invalid
                    if ((sign_a_int == 0) && (sign_b_int == 0) &&
                        (((port_signa == "PORT_USED") && (port_signb == "PORT_USED" )) || 
                        ((representation_a != "UNUSED") && (representation_b != "UNUSED"))))
                    begin
                        for (cho_sat_all_bit_cnt = 0; cho_sat_all_bit_cnt <= int_width_result; cho_sat_all_bit_cnt = cho_sat_all_bit_cnt + 1)
                        begin
                            chainout_round_block_result[cho_sat_all_bit_cnt] = 1'bx;
                        end
                    end
                    
                    // force the LSBs beyond the rounding position to "X"
                    if(accumulator == "NO")
                        for (cho_rnd_bit_cnt = (chainout_round_position - 1); cho_rnd_bit_cnt >= 0; cho_rnd_bit_cnt = cho_rnd_bit_cnt - 1)
                        begin
                            chainout_round_block_result[cho_rnd_bit_cnt] = 1'bx;
                        end
                    else
                        for (cho_rnd_bit_cnt = (chainout_round_position - 1); cho_rnd_bit_cnt >= 0; cho_rnd_bit_cnt = cho_rnd_bit_cnt - 1)
                        begin
                            chainout_round_block_result[cho_rnd_bit_cnt] = 1'b1;
                        end
    
                    cho_round_happen = 1;
                end
                else
                    chainout_round_block_result = chainout_add_result;
            end
            
            // Saturation part
            if (chainout_saturation == "NO")
                chainout_sat_block_result = chainout_round_block_result;
            else
            begin
            chainout_overflow_status = 0;
                if (((chainout_saturation == "VARIABLE") && (chainout_sat_out_wire == 1)) || (chainout_saturation == "YES"))
                begin
                    if((((chainout_rounding == "VARIABLE") && (chainout_round_out_wire == 1)) || (chainout_rounding == "YES")) && round_checking == 1'b1 && width_saturate_sign == 1 && width_result == `RESULT_WIDTH)
                        if(chainout_round_block_result[int_width_result - 1] != overflow_checking)
                            chainout_overflow_status = 1'b1;
                        else
                            chainout_overflow_status = 1'b0;
                    else if (chainout_round_block_result[chainout_sat_msb] == 1'b0) // carry bit is 0 - positive number
                    begin
                            for (cho_sat_bit_cnt = int_width_result - 1; cho_sat_bit_cnt >= (chainout_saturation_position); cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                        begin
                            chainout_overflow_status = chainout_overflow_status | chainout_round_block_result[cho_sat_bit_cnt];
                        end
                    end
                    else // carry bit is 1 - negative number
                    begin
                            for (cho_sat_bit_cnt = int_width_result - 1; cho_sat_bit_cnt >= (chainout_saturation_position); cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                        begin
                            chainout_overflow_status = chainout_overflow_status | (~chainout_round_block_result[cho_sat_bit_cnt]);
                        end
                        
                        if ((output_saturate_type == "SYMMETRIC") && (chainout_overflow_status == 1'b0)) 
                        begin
                            chainout_overflow_status = 1'b1;
                            if (cho_round_happen)
                            begin 
                                for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= (chainout_round_position); cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_overflow_status = chainout_overflow_status & (~(chainout_round_block_result [cho_sat_bit_cnt]));
                                end
                            end
                            else
                        begin
                                for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= 0 ; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                            begin
                                    chainout_overflow_status = chainout_overflow_status & (~(chainout_round_block_result [cho_sat_bit_cnt]));
                                end
                            end
                        end    
                    end
                        
                    if (chainout_overflow_status == 1'b1)
                    begin
                        if((((chainout_rounding == "VARIABLE") && (chainout_round_out_wire == 1)) || (chainout_rounding == "YES")) && round_checking == 1'b1 && width_saturate_sign == 1 && width_result == `RESULT_WIDTH)
                        begin
                            if (chainout_round_block_result[chainout_sat_msb] == 1'b1) // positive number
                        begin
                            if (port_chainout_sat_is_overflow == "PORT_UNUSED") // set the overflow status to the MSB of the results
                                    chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;
                                else
                                chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;

                                for (cho_sat_bit_cnt = (int_width_result - 1); cho_sat_bit_cnt >= (chainout_saturation_position); cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;  // set the leading bits on the left of the saturation position to 0
                                end
                            
                                // if rounding is used, the LSBs after the rounding position should be "X-ed", from above
                                if ((cho_round_happen))
                                begin 
                                    for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                    begin
                                        chainout_sat_block_result[cho_sat_bit_cnt] = 1'b1; // set the trailing bits on the right of the saturation position to 1
                                    end
                                end
                                else
                                begin
                                    for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                    begin
                                        chainout_sat_block_result[cho_sat_bit_cnt] = 1'b1; // set the trailing bits on the right of the saturation position to 1
                                    end
                                end
                            end
                            else // negative number
                            begin
                                if (port_chainout_sat_is_overflow == "PORT_UNUSED") // set the overflow status to the MSB of the results
                                chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;
                            else
                                    chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;

                                for (cho_sat_bit_cnt = (int_width_result - 2); cho_sat_bit_cnt >= chainout_saturation_position; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_sat_block_result[cho_sat_bit_cnt] = 1'b1; // set the sign bits to 1
                                end
                            
                                // if rounding is used, the LSBs after the rounding position should be "X-ed", from above
                                if ((chainout_rounding != "NO") && (output_saturate_type == "SYMMETRIC"))
                                begin
                                    for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= chainout_round_position; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                    begin
                                        chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;
                                    end
                                
                                    if(accumulator == "NO")
                                        for (cho_sat_bit_cnt = (chainout_round_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                        begin
                                            chainout_sat_block_result[cho_sat_bit_cnt] = 1'bx;
                                        end
                                    else
                                        for (cho_sat_bit_cnt = (chainout_round_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                        begin
                                            chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;
                                        end
                                    
                                end
                                else
                                begin
                                    for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                    begin
                                        chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;
                                    end
                                end

                                if ((chainout_rounding != "NO") && (output_saturate_type == "SYMMETRIC"))
                                    chainout_sat_block_result[chainout_round_position] = 1'b1;
                                else if (output_saturate_type == "SYMMETRIC")
                                    chainout_sat_block_result[int_mult_diff_bit] = 1'b1;
                            end
                        end
                        else
                        begin
                        if (chainout_round_block_result[chainout_sat_msb] == 1'b0) // positive number
                        begin
                            if (port_chainout_sat_is_overflow == "PORT_UNUSED") // set the overflow status to the MSB of the results
                                chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;
                            else
                                chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;

                                for (cho_sat_bit_cnt = (int_width_result - 1); cho_sat_bit_cnt >= (chainout_saturation_position); cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                            begin
                                chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;  // set the leading bits on the left of the saturation position to 0
                            end
                            
                            // if rounding is used, the LSBs after the rounding position should be "X-ed", from above
                            if ((cho_round_happen))
                            begin 
                                for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_sat_block_result[cho_sat_bit_cnt] = 1'b1; // set the trailing bits on the right of the saturation position to 1
                                end
                            end
                            else
                            begin
                                for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_sat_block_result[cho_sat_bit_cnt] = 1'b1; // set the trailing bits on the right of the saturation position to 1
                                end
                            end
                        end
                        else // negative number
                        begin
                            if (port_chainout_sat_is_overflow == "PORT_UNUSED") // set the overflow status to the MSB of the results
                                chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;
                            else
                                chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;

                            for (cho_sat_bit_cnt = (int_width_result - 2); cho_sat_bit_cnt >= chainout_saturation_position; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                            begin
                                chainout_sat_block_result[cho_sat_bit_cnt] = 1'b1; // set the sign bits to 1
                            end
                            
                            // if rounding is used, the LSBs after the rounding position should be "X-ed", from above
                            if ((cho_round_happen) || (output_saturate_type == "SYMMETRIC"))
                            begin
                                for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= chainout_round_position; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;
                                end
                                
                                for (cho_sat_bit_cnt = (chainout_round_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;
                                end
                            end
                            else
                            begin
                                for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;
                                end
                            end

                            if ((chainout_rounding != "NO") && (output_saturate_type == "SYMMETRIC"))
                                chainout_sat_block_result[chainout_round_position] = 1'b1;
                            else if (output_saturate_type == "SYMMETRIC")
                                chainout_sat_block_result[int_mult_diff_bit] = 1'b1;
                        end
                    end
                    end
                    else
                    begin
                        chainout_sat_block_result = chainout_round_block_result;                      
                        if (chainout_sat_block_result[chainout_sat_msb] == 1'b1) // negative number - checking for a special case
                        begin
                            if (output_saturate_type == "SYMMETRIC")
                            begin
                                cho_sat_bits_or = 0;
                                
                                for (cho_sat_bit_cnt = (int_width_result - 2); cho_sat_bit_cnt >= chainout_round_position; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    cho_sat_bits_or = cho_sat_bits_or | chainout_sat_block_result[cho_sat_bit_cnt];
                                end

                                if ((cho_sat_bits_or == 1'b0) && (chainout_sat_block_result[int_width_result - 1] == 1'b1)) // this means all bits are 0
                                begin
                                    chainout_sat_block_result[chainout_round_position] = 1'b1;
                                end
                            end
                        end
                    end
                    // if unsigned number comes into the rounding & saturation block, X the entire output since unsigned numbers
                    // are invalid
                    if ((sign_a_int == 0) && (sign_b_int == 0) &&
                        (((port_signa == "PORT_USED") && (port_signb == "PORT_USED" )) || 
                        ((representation_a != "UNUSED") && (representation_b != "UNUSED"))))
                    begin
                        for (cho_sat_all_bit_cnt = 0; cho_sat_all_bit_cnt <= int_width_result; cho_sat_all_bit_cnt = cho_sat_all_bit_cnt + 1)
                        begin
                            chainout_sat_block_result[cho_sat_all_bit_cnt] = 1'bx;
                        end
                    end
                end
                else
                    chainout_sat_block_result = chainout_round_block_result;
            end
        end
    end

    always @(chainout_sat_block_result)
    begin
        chainout_rnd_sat_blk_res <= chainout_sat_block_result;
    end

    assign chainout_sat_overflow = (chainout_register == "UNREGISTERED")? chainout_overflow_status : chainout_overflow_stat_reg;

    // model the chainout stage in Stratix III
    always @(posedge chainout_reg_wire_clk or posedge chainout_reg_wire_clr)
    begin
        if (chainout_reg_wire_clr == 1)
        begin
            chainout_output_reg <= {int_width_result{1'b0}};
            chainout_overflow_stat_reg <= 1'b0;
        end
        else if ((chainout_reg_wire_clk == 1) && (chainout_reg_wire_en == 1))
        begin
            chainout_output_reg <= chainout_rnd_sat_blk_res;
            chainout_overflow_stat_reg <= chainout_overflow_status;
        end
    end

    assign chainout_output_wire[int_width_result:0] = (chainout_register == "UNREGISTERED") ? 
                                                        chainout_rnd_sat_blk_res[int_width_result-1:0] : chainout_output_reg[int_width_result-1:0];

    always @(zerochainout_wire or chainout_output_wire[int_width_result:0])
    begin
        chainout_final_out <= chainout_output_wire & {(int_width_result){~zerochainout_wire}};
    end
    
    // model the shift & rotate block in Stratix III
    assign shift_rot_blk_in_wire[int_width_result - 1: 0] = (shift_mode != "NO") ? ((output_register == "UNREGISTERED") ? 
                                                            round_sat_blk_res[int_width_result - 1 : 0] : chout_shftrot_reg[int_width_result - 1: 0]) : 0;
                                                            

    always @(shift_rot_blk_in_wire[int_width_result - 1:0] or shiftr_out_wire or rotate_out_wire)
    begin
        if (stratixiii_block )
        begin
            // left shifting
            if ((shift_mode == "LEFT") || ((shift_mode == "VARIABLE") && (shiftr_out_wire == 0) && (rotate_out_wire == 0)))
            begin
                shift_rot_result <= shift_rot_blk_in_wire[shift_partition - 1:0];
            end
            // right shifting
            else if ((shift_mode == "RIGHT") || ((shift_mode == "VARIABLE") && (shiftr_out_wire == 1) && (rotate_out_wire == 0)))
            begin
                shift_rot_result <= shift_rot_blk_in_wire[shift_msb : shift_partition];
            end
            // rotate mode
            else if ((shift_mode == "ROTATION") || ((shift_mode == "VARIABLE") && (shiftr_out_wire == 0) && (rotate_out_wire == 1)))
            begin
                shift_rot_result <= (shift_rot_blk_in_wire[shift_msb : shift_partition] | shift_rot_blk_in_wire[shift_partition - 1:0]);
            end
        end
    end

    // loopback path
    assign loopback_out_wire[int_width_result - 1:0] = (output_register == "UNREGISTERED") ? 
                                round_sat_blk_res[int_width_result + (int_width_b - width_b) - 1 : int_width_b - width_b] : 
                                (extra_latency == 0)? loopback_wire_reg[int_width_result - 1 : 0] : loopback_wire_latency[int_width_result - 1 : 0];
 
    assign loopback_out_wire_feedback [int_width_result - 1:0] = (output_register == "UNREGISTERED") ? 
                                round_sat_blk_res[int_width_result + (int_width_b - width_b) - 1 : int_width_b - width_b] : loopback_wire_reg[int_width_result - 1 : 0];
 
    always @(loopback_out_wire_feedback[int_width_result - 1:0] or zeroloopback_out_wire)
    begin
        loopback_wire[int_width_result -1:0] <= {(int_width_result){~zeroloopback_out_wire}} & loopback_out_wire_feedback[int_width_result - 1:0];
    end

endmodule  // end of ALTMULT_ADD


//START_MODULE_NAME-------------------------------------------------------------
//
// Module Name     :   altfp_mult
//
// Description     :   Parameterized floating point multiplier megafunction.
//                     This module implements IEEE-754 Compliant Floating Poing
//                     Multiplier.It supports Single Precision, Single Extended
//                     Precision and Double Precision floating point
//                     multiplication.
//
// Limitation      :   Fixed clock latency with 4 clock cycle delay.
//
// Results expected:   result of multiplication and the result's status bits
//
//END_MODULE_NAME---------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

module altfp_mult (
    clock,      // Clock input to the multiplier.(Required)
    clk_en,     // Clock enable for the multiplier.
    aclr,       // Asynchronous clear for the multiplier.
    dataa,      // Data input to the multiplier.(Required)
    datab,      // Data input to the multiplier.(Required)
    result,     // Multiplier output port.(Required)
    overflow,   // Overflow port for the multiplier.
    underflow,  // Underflow port for the multiplier.
    zero,       // Zero port for the multiplier.
    denormal,   // Denormal port for the multiplier.
    indefinite, // Indefinite port for the multiplier.
    nan         // Nan port for the multiplier.
);

// GLOBAL PARAMETER DECLARATION
    // Specifies the value of the exponent, Minimum = 8, Maximum = 31
    parameter width_exp = 8;
    // Specifies the value of the mantissa, Minimum = 23, Maximum = 52
    parameter width_man = 23;
    // Specifies whether to use dedicated multiplier circuitry.
    parameter dedicated_multiplier_circuitry = "AUTO";
    parameter reduced_functionality = "NO";
    parameter pipeline = 5;
    parameter denormal_support = "YES";
    parameter exception_handling = "YES";
    parameter lpm_hint = "UNUSED";
    parameter lpm_type = "altfp_mult";

// LOCAL_PARAMETERS_BEGIN

    //clock latency
    parameter LATENCY = pipeline -1;
    // Sum of mantissa's width and exponent's width
    parameter WIDTH_MAN_EXP = width_exp + width_man;

// LOCAL_PARAMETERS_END

// INPUT PORT DECLARATION
    input [WIDTH_MAN_EXP : 0] dataa;
    input [WIDTH_MAN_EXP : 0] datab;
    input clock;
    input clk_en;
    input aclr;

// OUTPUT PORT DECLARATION
    output [WIDTH_MAN_EXP : 0] result;
    output overflow;
    output underflow;
    output zero;
    output denormal;
    output indefinite;
    output nan;

// INTERNAL REGISTERS DECLARATION
    reg[width_man : 0] mant_dataa;
    reg[width_man : 0] mant_datab;
    reg[(2 * width_man) + 1 : 0] mant_result;
    reg cout;
    reg zero_mant_dataa;
    reg zero_mant_datab;
    reg zero_dataa;
    reg zero_datab;
    reg inf_dataa;
    reg inf_datab;
    reg nan_dataa;
    reg nan_datab;
    reg den_dataa;
    reg den_datab;
    reg no_multiply;
    reg mant_result_msb;
    reg no_rounding;
    reg sticky_bit;
    reg round_bit;
    reg guard_bit;
    reg carry;
    reg[WIDTH_MAN_EXP : 0] result_pipe[LATENCY : 0];
    reg[LATENCY : 0] overflow_pipe;
    reg[LATENCY : 0] underflow_pipe;
    reg[LATENCY : 0] zero_pipe;
    reg[LATENCY : 0] denormal_pipe;
    reg[LATENCY : 0] indefinite_pipe;
    reg[LATENCY : 0] nan_pipe;
    reg[WIDTH_MAN_EXP : 0] temp_result;
    reg overflow_bit;
    reg underflow_bit;
    reg zero_bit;
    reg denormal_bit;
    reg indefinite_bit;
    reg nan_bit;

// INTERNAL TRI DECLARATION
    tri1 clk_en;
    tri0 aclr;

// LOCAL INTEGER DECLARATION
    integer exp_dataa;
    integer exp_datab;
    integer exp_result;

    // loop counter
    integer i0;
    integer i1;
    integer i2;
    integer i3;
    integer i4;
    integer i5;

// TASK DECLARATION

    // Add up two bits to get the result(<mantissa of datab> + <temporary result
    // of mantissa's multiplication>)
    //Also output the carry bit.
    task add_bits;
        // Value to be added to the temporary result of mantissa's multiplication.
        input  [width_man : 0] val1;
        // temporary result of mantissa's multiplication.
        inout  [(2 * width_man) + 1 : 0] temp_mant_result;
        output cout; // carry out bit

        reg co; // temporary storage to store the carry out bit

        integer i0_tmp;

        begin
            co = 1'b0;
            for(i0 = 0; i0 <= width_man; i0 = i0 + 1)
            begin
            i0_tmp = i0 + width_man + 1;

                // if the carry out bit from the previous bit addition is 1'b0
                if (co == 1'b0)
                begin
                    if (val1[i0] != temp_mant_result[i0_tmp])
                    begin
                        temp_mant_result[i0_tmp] = 1'b1;
                    end
                    else
                    begin
                        co = val1[i0] & temp_mant_result[i0_tmp];
                        temp_mant_result[i0_tmp] = 1'b0;
                    end
                end
                else // if (co == 1'b1)
                begin
                    co = val1[i0] | temp_mant_result[i0_tmp];
                    if (val1[i0] != temp_mant_result[i0_tmp])
                    begin
                        temp_mant_result[i0_tmp] = 1'b0;
                    end
                    else
                    begin
                        temp_mant_result[i0_tmp] = 1'b1;
                    end
                end
            end // end of for loop
            cout = co;
        end
    endtask // add_bits

// FUNCTON DECLARATION

    // Check whether the all the bits from index <index1> to <index2> is 1'b1
    // Return 1'b1 if true, otherwise return 1'b0
    function bit_all_0;
        input [(2 * width_man) + 1: 0] val;
        input index1;
        integer index1;
        input index2;
        integer index2;

        reg all_0;  //temporary storage to indicate whether all the currently
                    // checked bits are 1'b0
        begin
            begin : LOOP_1
                all_0 = 1'b1;
                for (i1 = index1; i1 <= index2; i1 = i1 + 1)
                begin
                    if ((val[i1]) == 1'b1)
                    begin
                        all_0 = 1'b0;
                        disable LOOP_1;  //break the loop to stop checking
                    end
                end
            end
            bit_all_0 = all_0;
        end
    endfunction // bit_all_0

    // Calculate the exponential value (<base_number> power of <exponent_number>)
    function integer exponential_value;
        input base_number;
        input exponent_number;
        integer base_number;
        integer exponent_number;
        integer value; // temporary storage to store the exponential value

        begin
            value = 1;
            for (i2 = 0; i2 < exponent_number; i2 = i2 + 1)
            begin
                value = base_number * value;
            end
            exponential_value = value;
        end
    endfunction // exponential_value

// INITIAL CONSTRUCT BLOCK
    initial
    begin : INITIALIZATION
        for(i3 = LATENCY; i3 >= 0; i3 = i3 - 1)
        begin
            result_pipe[i3] = 0;
            overflow_pipe[i3] = 1'b0;
            underflow_pipe[i3] = 1'b0;
            zero_pipe[i3] = 1'b0;
            denormal_pipe[i3] = 1'b0;
            indefinite_pipe[i3] = 1'b0;
            nan_pipe[i3] = 1'b0;
        end

        // Check for illegal mode setting
        if (WIDTH_MAN_EXP >= 64)
        begin
            $display("ERROR: The sum of width_exp(%d) and width_man(%d) must be less 64!", width_exp, width_man);
            $finish;
        end
        if (width_exp < 8)
        begin
            $display("ERROR: width_exp(%d) must be at least 8!", width_exp);
            $finish;
        end
        if (width_man < 23)
        begin
            $display("ERROR: width_man(%d) must be at least 23!", width_man);
            $finish;
        end
        if (~((width_exp >= 11) || ((width_exp == 8) && (width_man == 23))))
        begin
            $display("ERROR: Found width_exp(%d) inside the range of Single Precision. width_exp must be 8 and width_man must be 23 for Single Presicion!", width_exp);
            $finish;
        end
        if (~((width_man >= 31) || ((width_exp == 8) && (width_man == 23))))
        begin
            $display("ERROR: Found width_man(%d) inside the range of Single Precision. width_exp must be 8 and width_man must be 23 for Single Presicion!", width_man);
            $finish;
        end
        if (width_exp >= width_man)
        begin
            $display("ERROR: width_exp(%d) must be less than width_man(%d)!", width_exp, width_man);
            $finish;
        end
        if ((pipeline != 5) && (pipeline != 6) && (pipeline != 10) && (pipeline != 11))
        begin
            $display("ERROR: The legal value for PIPELINE is 5, 6, 10 or 11!");
            $finish;
        end

        if ((reduced_functionality != "NO") && (reduced_functionality != "YES"))
        begin
            $display("ERROR: reduced_functionality value must be \"YES\" or \"NO\"!");
            $finish;
        end

        if ((denormal_support != "NO") && (denormal_support != "YES"))
        begin
            $display("ERROR: denormal_support value must be \"YES\" or \"NO\"!");
            $finish;
        end
        
        if (reduced_functionality != "NO")
        begin
            $display("Info: The Clearbox support is available for reduced functionality Floating Point Multiplier.");
        end
    end // INITIALIZATION

// ALWAYS CONSTRUCT BLOCK

    // multiplication
    always @(dataa or datab)
    begin : MULTIPLY_FP
        temp_result = {(WIDTH_MAN_EXP + 1){1'b0}};
        overflow_bit = 1'b0;
        underflow_bit = 1'b0;
        zero_bit = 1'b0;
        denormal_bit = 1'b0;
        indefinite_bit = 1'b0;
        nan_bit = 1'b0;            
        mant_result = {((2 * width_man) + 2){1'b0}};
        exp_dataa = 0;
        exp_datab = 0;
        // Set the exponential value
        exp_dataa = dataa[width_exp + width_man -1:width_man];
        exp_datab = datab[width_exp + width_man -1:width_man];

        zero_mant_dataa = 1'b1;
        // Check whether the mantissa for dataa is zero
        begin : LOOP_3
            for (i4 = 0; i4 <= width_man - 1; i4 = i4 + 1)
            begin
                if ((dataa[i4]) == 1'b1)
                begin
                    zero_mant_dataa = 1'b0;
                    disable LOOP_3;
                end
            end
        end // LOOP_3
        zero_mant_datab = 1'b1;
        // Check whether the mantissa for datab is zero
        begin : LOOP_4
            for (i4 = 0; i4 <= width_man -1; i4 = i4 + 1)
            begin
                if ((datab[i4]) == 1'b1)
                begin
                    zero_mant_datab = 1'b0;
                    disable LOOP_4;
                end
            end
        end // LOOP_4
        zero_dataa = 1'b0;
        den_dataa = 1'b0;
        inf_dataa = 1'b0;
        nan_dataa = 1'b0;
        // Check whether dataa is special input
        if (exp_dataa == 0)
        begin
            if ((zero_mant_dataa == 1'b1)
                || (reduced_functionality != "NO"))
            begin
                zero_dataa = 1'b1;  // dataa is zero
            end
            else
            begin
                if (denormal_support == "YES")
                    den_dataa = 1'b1; // dataa is denormalized
                else
                    zero_dataa = 1'b1; // dataa is zero
            end
        end
        else if (exp_dataa == (exponential_value(2, width_exp) - 1))
        begin
            if (zero_mant_dataa == 1'b1)
            begin
                inf_dataa = 1'b1;  // dataa is infinity
            end
            else
            begin
                nan_dataa = 1'b1; // dataa is Nan
            end
        end
        zero_datab = 1'b0;
        den_datab = 1'b0;
        inf_datab = 1'b0;
        nan_datab = 1'b0;
        // Check whether datab is special input
        if (exp_datab == 0)
        begin
            if ((zero_mant_datab == 1'b1)
                || (reduced_functionality != "NO"))
            begin
                zero_datab = 1'b1; // datab is zero
            end
            else
            begin
                if (denormal_support == "YES")
                    den_datab = 1'b1; // datab is denormalized
                else
                    zero_datab = 1'b1; // datab is zero
            end
        end
        else if (exp_datab == (exponential_value(2, width_exp) - 1))
        begin
            if (zero_mant_datab == 1'b1)
            begin
                inf_datab = 1'b1; // datab is infinity
            end
            else
            begin
                nan_datab = 1'b1; // datab is Nan
            end
        end
        no_multiply = 1'b0;
        // Set status flag if special input exists
        if (nan_dataa || nan_datab || (inf_dataa && zero_datab) ||
            (inf_datab && zero_dataa))
        begin
            nan_bit = 1'b1; // NaN
            for (i4 = width_man - 1; i4 <= WIDTH_MAN_EXP - 1; i4 = i4 + 1)
            begin
                temp_result[i4] = 1'b1;
            end
            no_multiply = 1'b1; // no multiplication is needed.
        end
        else if (zero_dataa)
        begin
            zero_bit = 1'b1; // Zero
            temp_result[WIDTH_MAN_EXP : 0] = 0;
            no_multiply = 1'b1;
        end
        else if (zero_datab)
        begin
            zero_bit = 1'b1; // Zero
            temp_result[WIDTH_MAN_EXP : 0] = 0;
            no_multiply = 1'b1;
        end
        else if (inf_dataa)
        begin
            overflow_bit = 1'b1; // Overflow
            temp_result[WIDTH_MAN_EXP : 0] = dataa;
            no_multiply = 1'b1;
        end
        else if (inf_datab)
        begin
            overflow_bit = 1'b1; // Overflow
            temp_result[WIDTH_MAN_EXP : 0] = datab;
            no_multiply = 1'b1;
        end
        // if multiplication needed
        if (no_multiply == 1'b0)
        begin
            // Perform exponent operation
            exp_result = exp_dataa + exp_datab - (exponential_value(2, width_exp -1) -1);
            // First operand for multiplication
            mant_dataa[width_man : 0] = {1'b1, dataa[width_man -1 : 0]};
            // Second operand for multiplication
            mant_datab[width_man : 0] = {1'b1, datab[width_man -1 : 0]};
            // Multiply the mantissas using add and shift algorithm
            for (i4 = 0; i4 <= width_man; i4 = i4 + 1)
            begin
                cout = 1'b0;
                if ((mant_dataa[i4]) == 1'b1)
                begin
                    add_bits(mant_datab, mant_result, cout);
                end
                mant_result = mant_result >> 1;
                mant_result[2*width_man + 1] = cout;
            end
            sticky_bit = 1'b0;
            mant_result_msb = mant_result[2*width_man + 1];
            // Normalize the Result
            if (mant_result_msb == 1'b1)
            begin
                sticky_bit = mant_result[0]; // Needed for rounding operation.
                mant_result = mant_result >> 1;
                exp_result = exp_result + 1;
            end
            round_bit = mant_result[width_man - 1];
            guard_bit = mant_result[width_man];
            no_rounding = 1'b0;
            // Check whether should perform rounding or not
            if (round_bit == 1'b0)
            begin
                no_rounding = 1'b1; // No rounding is needed
            end
            else
            begin
                if (reduced_functionality == "NO")
                begin
                    for(i4 = 0; i4 <= width_man - 2; i4 = i4 + 1)
                    begin
                        sticky_bit = sticky_bit | mant_result[i4];
                    end
                end
                else
                begin
                    sticky_bit = (mant_result[width_man - 2] &
                                    mant_result_msb);
                end
                if ((sticky_bit == 1'b0) && (guard_bit == 1'b0))
                begin
                    no_rounding = 1'b1;
                end
            end
            // Perform rounding
            if (no_rounding == 1'b0)
            begin
                carry = 1'b1;
                for(i4 = width_man; i4 <= 2 * width_man + 1; i4 = i4 + 1)
                begin
                    if (carry == 1'b1)
                    begin
                        if (mant_result[i4] == 1'b0)
                        begin
                            mant_result[i4] = 1'b1;
                            carry = 1'b0;
                        end
                        else
                        begin
                            mant_result[i4] = 1'b0;
                        end
                    end
                end
                // If the mantissa of the result is 10.00.. after rounding, right shift the 
                // mantissa of the result by 1 bit and increase the exponent of the result by 1.
                if (mant_result[(2 * width_man) + 1] == 1'b1)
                begin
                    mant_result = mant_result >> 1;
                    exp_result = exp_result + 1;
                end
            end
            // Normalize the Result
            if ((!bit_all_0(mant_result, 0, (2 * width_man) + 1)) &&
                (mant_result[2 * width_man] == 1'b0))
            begin
                while ((mant_result[2 * width_man] == 1'b0) &&
                        (exp_result != 0))
                begin
                    mant_result = mant_result << 1;
                    exp_result = exp_result - 1;
                end
            end
            else if ((exp_result < 0) && (exp_result >= -(2*width_man)))
            begin
                while(exp_result != 0)
                begin
                    mant_result = mant_result >> 1;
                    exp_result = exp_result + 1;
                end
            end
            // Set status flag "indefinite" if normal * denormal
            // (ignore other status port since we dont care the output
            if (den_dataa || den_datab)
            begin
                indefinite_bit = 1'b1; // Indefinite
            end
            else if (exp_result >= (exponential_value(2, width_exp) -1))
            begin
                overflow_bit = 1'b1; // Overflow
            end
            else if (exp_result < 0)
            begin
                underflow_bit = 1'b1; // Underflow
                zero_bit = 1'b1; // Zero
            end
            else if (exp_result == 0)
            begin
                underflow_bit = 1'b1; // Underflow

                if (bit_all_0(mant_result, width_man + 1, 2 * width_man))
                begin
                    zero_bit = 1'b1; // Zero
                end
                else
                begin
                    denormal_bit = 1'b1; // Denormal
                end
            end
            // Get result's mantissa
            if (exp_result < 0) // Result underflow
            begin
                for(i4 = 0; i4 <= width_man - 1; i4 = i4 + 1)
                begin
                    temp_result[i4] = 1'b0;
                end
            end
            else if (exp_result == 0) // Denormalized result
            begin
                if ((reduced_functionality == "NO") && (denormal_support == "YES"))
                begin
                    temp_result[width_man - 1 : 0] = mant_result[2 * width_man : width_man + 1];
                end
                else
                begin
                    temp_result[width_man - 1 : 0] = 0;
                    zero_bit = 1'b1;
                end
            end
            // Result overflow
            else if (exp_result >= exponential_value(2, width_exp) -1)
            begin
                temp_result[width_man - 1 : 0] = {width_man{1'b0}};
            end
            else // Normalized result
            begin
                temp_result[width_man - 1 : 0] = mant_result[(2 * width_man - 1) : width_man];
            end
            // Get result's exponent
            if (exp_result == 0)
            begin
                for(i4 = width_man; i4 <= WIDTH_MAN_EXP - 1; i4 = i4 + 1)
                begin
                    temp_result[i4] = 1'b0;
                end
            end
            else if (exp_result >= (exponential_value(2, width_exp) -1))
            begin
                for(i4 = width_man; i4 <= WIDTH_MAN_EXP - 1; i4 = i4 + 1)
                begin
                    temp_result[i4] = 1'b1;
                end
            end
            else
            begin
                // Convert integer to binary bits
                for(i4 = width_man; i4 <= WIDTH_MAN_EXP - 1; i4 = i4 + 1)
                begin
                    if ((exp_result % 2) == 1)
                    begin
                        temp_result[i4] = 1'b1;
                    end
                    else
                    begin
                        temp_result[i4] = 1'b0;
                    end
                    exp_result = exp_result / 2;
                end
            end
        end // end of if (no_multiply == 1'b0)
        // Get result's sign bit
        temp_result[WIDTH_MAN_EXP] = dataa[WIDTH_MAN_EXP] ^ datab[WIDTH_MAN_EXP];
        
    end // MULTIPLY_FP

    // Pipelining registers.
    always @(posedge clock or posedge aclr)
    begin : PIPELINE_REGS
        if (aclr == 1'b1)
        begin
            for (i5 = LATENCY; i5 >= 0; i5 = i5 - 1)
            begin
                result_pipe[i5] <= {WIDTH_MAN_EXP{1'b0}};
                overflow_pipe[i5] <= 1'b0;
                underflow_pipe[i5] <= 1'b0;
                zero_pipe[i5] <= 1'b1;
                denormal_pipe[i5] <= 1'b0;
                indefinite_pipe[i5] <= 1'b0;
                nan_pipe[i5] <= 1'b0;
            end
            // clear all the output ports to 1'b0
        end
        else if (clk_en == 1'b1)
        begin
            result_pipe[0] <= temp_result;
            overflow_pipe[0] <= overflow_bit;
            underflow_pipe[0] <= underflow_bit;
            zero_pipe[0] <= zero_bit;
            denormal_pipe[0] <= denormal_bit;
            indefinite_pipe[0] <= indefinite_bit;
            nan_pipe[0] <= nan_bit;

            // Create latency for the output result
            for(i5=LATENCY; i5 >= 1; i5 = i5 - 1)
            begin
                result_pipe[i5] <= result_pipe[i5 - 1];
                overflow_pipe[i5] <= overflow_pipe[i5 - 1];
                underflow_pipe[i5] <= underflow_pipe[i5 - 1];
                zero_pipe[i5] <= zero_pipe[i5 - 1];
                denormal_pipe[i5] <= denormal_pipe[i5 - 1];
                indefinite_pipe[i5] <= indefinite_pipe[i5 - 1];
                nan_pipe[i5] <= nan_pipe[i5 - 1];
            end
        end
    end // PIPELINE_REGS

assign result = result_pipe[LATENCY];
assign overflow = overflow_pipe[LATENCY];
assign underflow = ((reduced_functionality == "YES") || (denormal_support == "YES")) ? underflow_pipe[LATENCY] : 1'b0;
assign zero = (reduced_functionality == "NO") ? zero_pipe[LATENCY] : 1'b0;
assign denormal = ((reduced_functionality == "NO") && (denormal_support == "YES")) ? denormal_pipe[LATENCY] : 1'b0;
assign indefinite = ((reduced_functionality == "NO") && (denormal_support == "YES")) ? indefinite_pipe[LATENCY] : 1'b0;
assign nan = nan_pipe[LATENCY];

endmodule //altfp_mult

// END OF MODULE

//START_MODULE_NAME-------------------------------------------------------------
//
// Module Name     :   altsqrt
//
// Description     :   Parameterized integer square root megafunction.
//                     This module computes q[] and remainder so that
//                      q[]^2 + remainder[] == radical[] (remainder <= 2 * q[])
//                     It can support the sequential mode(pipeline > 0) or
//                     combinational mode (pipeline = 0).
//
// Limitation      :   The radical is assumed to be unsigned integer.
//
// Results expected:   Square root of the radical and the remainder.
//
//END_MODULE_NAME---------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

module altsqrt (
    radical,  // Input port for the radical
    clk,      // Clock port
    ena,      // Clock enable port
    aclr,     // Asynchronous clear port
    q,        // Output port for returning the square root of the radical.
    remainder // Output port for returning the remainder of the square root.
);

// GLOBAL PARAMETER DECLARATION
    parameter q_port_width = 1; // The width of the q port
    parameter r_port_width = 1; // The width of the remainder port
    parameter width = 1;        // The width of the radical
    parameter pipeline = 0;     // The latency for the output
    parameter lpm_hint= "UNUSED";
    parameter lpm_type = "altsqrt";

// INPUT PORT DECLARATION
    input [width - 1 : 0] radical;
    input clk;
    input ena;
    input aclr;

// OUTPUT PORT DECLARATION
    output [q_port_width - 1 : 0] q;
    output [r_port_width - 1 : 0] remainder;

// INTERNAL REGISTERS DECLARATION
    reg[q_port_width - 1 : 0] q_temp;
    reg[q_port_width - 1 : 0] q_pipeline[(pipeline +1) : 0];
    reg[r_port_width - 1 : 0] r_temp;
    reg[r_port_width - 1 : 0] remainder_pipeline[(pipeline +1) : 0];

// INTERNAL TRI DECLARATION
    tri1 clk;
    tri1 ena;
    tri0 aclr;

// LOCAL INTEGER DECLARATION
    integer value1;
    integer value2;
    integer index;
    integer q_index;
    integer q_value_temp;
    integer r_value_temp;
    integer i;
    integer i1;
    integer pipe_ptr;


// INITIAL CONSTRUCT BLOCK
    initial
    begin : INITIALIZE
        // Check for illegal mode
        if(width < 1)
        begin
            $display("width (%d) must be greater than 0.(ERROR)", width);
            $finish;
        end
        pipe_ptr = 0;
        
        for (i = 0; i < (pipeline + 1); i = i + 1)
        begin
            q_pipeline[i] <= 0;
            remainder_pipeline[i] <= 0;
        end
    end // INITIALIZE

// ALWAYS CONSTRUCT BLOCK

    // Perform square root calculation.
    // In general, below are the steps to calculate the square root and the
    // remainder.
    //
    // Start of with q = 0 and remainder= 0
    // For every iteration, do the same thing:
    // 1) Shift in the next 2 bits of the radical into the remainder
    //    Eg. if the radical is b"101100". For the first iteration,
    //      the remainder will be equal to b"10".
    // 2) Compare it to the 4* q + 1
    // 3) if the remainder is greater than or equal to 4*q + 1
    //        remainder = remainder - (4*q + 1)
    //        q = 2*q + 1
    //    otherwise
    //        q = 2*q
    always @(radical)
    begin : SQUARE_ROOT
        // Reset variables
        value1 = 0;
        value2 = 0;
        q_index = (width - 1) / 2;
        q_value_temp = 0;
        r_value_temp = 0;
        q_temp = {q_port_width{1'b0}};
        r_temp = {r_port_width{1'b0}};

        // If the number of the bits of the radical is an odd number,
        // Then for the first iteration, only the 1st bit will be shifted
        // into the remainder.
        // Eg. if the radical is b"11111", then the remainder is b"01".
        if((width % 2) == 1)
        begin
            index = width + 1;
            value1 = 0;
            value2 = (radical[index - 2] === 1'b1) ? 1'b1 : 1'b0;
        end
        else if (width > 1)
        begin
        // Otherwise, for the first iteration, the first two bits will be shifted
        // into the remainder.
        // Eg. if the radical is b"101111", then the remainder is b"10".
            index = width;
            value1 = (radical[index - 1] === 1'b1) ? 1'b1 : 1'b0;
            value2 = (radical[index - 2] === 1'b1) ? 1'b1 : 1'b0;
        end

        // For every iteration
        for(index = index - 2; index >= 0; index = index - 2)
        begin
            // Get the remainder value by shifting in the next 2 bits
            // of the radical into the remainder
            r_value_temp =  (r_value_temp * 4) + (2 * value1) + value2;

            // if remainder >= (4*q + 1)
            if (r_value_temp >= ((4 * q_value_temp)  + 1))
            begin
                // remainder = remainder - (4*q + 1)
                r_value_temp = r_value_temp - (4 * q_value_temp)  - 1;
                // q = 2*q + 1
                q_value_temp = (2 * q_value_temp) + 1;
                // set the q[q_index] = 1
                q_temp[q_index] = 1'b1;
            end
            else  // if remainder < (4*q + 1)
            begin
                // q = 2*q
                q_value_temp = 2 * q_value_temp;
                // set the q[q_index] = 0
                q_temp[q_index] = 1'b0;
            end

            // if not the last iteration, get the next 2 bits of the radical
            if(index >= 2)
            begin
                value1 = (radical[index - 1] === 1'b1)? 1: 0;
                value2 = (radical[index - 2] === 1'b1)? 1: 0;
            end

            // Reduce the current index of q by 1
            q_index = q_index - 1;

        end

        // Get the binary bits of the remainder by converting integer to
        // binary bits
        r_temp = r_value_temp;
    end

    // store the result to a pipeline(to create the latency)
    always @(posedge clk or posedge aclr)
    begin
        if (aclr) // clear the pipeline for result to 0
        begin
            for (i1 = 0; i1 < (pipeline + 1); i1 = i1 + 1)
            begin
                q_pipeline[i1] <= 0;
                remainder_pipeline[i1] <= 0;
            end
        end
        else if (ena == 1)
        begin          
            remainder_pipeline[pipe_ptr] <= r_temp;
            q_pipeline[pipe_ptr] <= q_temp;

            if (pipeline > 1)
                pipe_ptr <= (pipe_ptr + 1) % pipeline;
        end
    end

// CONTINOUS ASSIGNMENT
    assign q = (pipeline > 0) ? q_pipeline[pipe_ptr] : q_temp;
    assign remainder = (pipeline > 0) ? remainder_pipeline[pipe_ptr] : r_temp;
    
endmodule //altsqrt
// END OF MODULE

// START MODULE NAME -----------------------------------------------------------
//
// Module Name      : ALTCLKLOCK
//
// Description      : Phase-Locked Loop (PLL) behavioral model. Supports basic
//                    PLL features such as multiplication and division of input
//                    clock frequency and phase shift.
//
// Limitations      : Model supports NORMAL operation mode only. External
//                    feedback mode and zero-delay-buffer mode are not simulated.
//
// Expected results : Up to 4 clock outputs (clock0, clock1, clock2, clock_ext).
//                    locked output indicates when PLL locks.
//
//END MODULE NAME --------------------------------------------------------------

`timescale 1 ps / 1 ps

// MODULE DECLARATION
module altclklock (
    inclock,     // input reference clock
    inclocken,   // PLL enable signal
    fbin,        // feedback input for the PLL
    clock0,      // output clock 0
    clock1,      // output clock 1
    clock2,      // output clock 2
    clock_ext,   // external output clock
    locked       // PLL lock signal
);

// GLOBAL PARAMETER DECLARATION
parameter inclock_period = 10000;  // units in ps
parameter inclock_settings = "UNUSED";
parameter valid_lock_cycles = 5;
parameter invalid_lock_cycles = 5;
parameter valid_lock_multiplier = 5;
parameter invalid_lock_multiplier = 5;
parameter operation_mode = "NORMAL";
parameter clock0_boost = 1;
parameter clock0_divide = 1;
parameter clock0_settings = "UNUSED";
parameter clock0_time_delay = "0";
parameter clock1_boost = 1;
parameter clock1_divide = 1;
parameter clock1_settings = "UNUSED";
parameter clock1_time_delay = "0";
parameter clock2_boost = 1;
parameter clock2_divide = 1;
parameter clock2_settings = "UNUSED";
parameter clock2_time_delay = "0";
parameter clock_ext_boost = 1;
parameter clock_ext_divide = 1;
parameter clock_ext_settings = "UNUSED";
parameter clock_ext_time_delay = "0";
parameter outclock_phase_shift = 0;  // units in ps
parameter intended_device_family = "Stratix";
parameter lpm_type = "altclklock";
parameter lpm_hint = "UNUSED";

// INPUT PORT DECLARATION
input inclock;
input inclocken;
input fbin;

// OUTPUT PORT DECLARATION
output clock0;
output clock1;
output clock2;
output clock_ext;
output locked;

// INTERNAL VARIABLE/REGISTER DECLARATION
reg clock0;
reg clock1;
reg clock2;
reg clock_ext;

reg start_outclk;
reg clk0_tmp;
reg clk1_tmp;
reg clk2_tmp;
reg extclk_tmp;
reg pll_lock;
reg clk_last_value;
reg violation;
reg clk_check;
reg [1:0] next_clk_check;

reg init;
    
real pll_last_rising_edge;
real pll_last_falling_edge;
real actual_clk_cycle;
real expected_clk_cycle;
real pll_duty_cycle;
real inclk_period;
real expected_next_clk_edge;
integer pll_rising_edge_count;
integer stop_lock_count;
integer start_lock_count;
integer clk_per_tolerance;

time clk0_phase_delay;
time clk1_phase_delay;
time clk2_phase_delay;
time extclk_phase_delay;

ALTERA_DEVICE_FAMILIES dev ();

// variables for clock synchronizing
time last_synchronizing_rising_edge_for_clk0;
time last_synchronizing_rising_edge_for_clk1;
time last_synchronizing_rising_edge_for_clk2;
time last_synchronizing_rising_edge_for_extclk;
time clk0_synchronizing_period;
time clk1_synchronizing_period;
time clk2_synchronizing_period;
time extclk_synchronizing_period;
integer input_cycles_per_clk0;
integer input_cycles_per_clk1;
integer input_cycles_per_clk2;
integer input_cycles_per_extclk;
integer clk0_cycles_per_sync_period;
integer clk1_cycles_per_sync_period;
integer clk2_cycles_per_sync_period;
integer extclk_cycles_per_sync_period;
integer input_cycle_count_to_sync0;
integer input_cycle_count_to_sync1;
integer input_cycle_count_to_sync2;
integer input_cycle_count_to_sync_extclk;

// variables for shedule_clk0-2, clk_ext
reg schedule_clk0;
reg schedule_clk1;
reg schedule_clk2;
reg schedule_extclk;
reg output_value0;
reg output_value1;
reg output_value2;
reg output_value_ext;
time sched_time0;
time sched_time1;
time sched_time2;
time sched_time_ext;
integer rem0;
integer rem1;
integer rem2;
integer rem_ext;
integer tmp_rem0;
integer tmp_rem1;
integer tmp_rem2;
integer tmp_rem_ext;
integer clk_cnt0;
integer clk_cnt1;
integer clk_cnt2;
integer clk_cnt_ext;
integer cyc0;
integer cyc1;
integer cyc2;
integer cyc_ext;
integer inc0;
integer inc1;
integer inc2;
integer inc_ext;
integer cycle_to_adjust0;
integer cycle_to_adjust1;
integer cycle_to_adjust2;
integer cycle_to_adjust_ext;
time tmp_per0;
time tmp_per1;
time tmp_per2;
time tmp_per_ext;
time ori_per0;
time ori_per1;
time ori_per2;
time ori_per_ext;
time high_time0;
time high_time1;
time high_time2;
time high_time_ext;
time low_time0;
time low_time1;
time low_time2;
time low_time_ext;

// Default inclocken and fbin ports to 1 if unused
tri1 inclocken_int;
tri1 fbin_int;

assign inclocken_int = inclocken;
assign fbin_int = fbin;

//
// function time_delay - converts time_delay in string format to integer, and
// add result to outclock_phase_shift
//
function time time_delay;
input [8*16:1] s;

reg [8*16:1] reg_s;
reg [8:1] digit;
reg [8:1] tmp;
integer m;
integer outclock_phase_shift_adj;
integer sign;

begin
    // initialize variables
    sign = 1;
    outclock_phase_shift_adj = 0;
    reg_s = s;

    for (m = 1; m <= 16; m = m + 1)
    begin
        tmp = reg_s[128:121];
        digit = tmp & 8'b00001111;
        reg_s = reg_s << 8;
        // Accumulate ascii digits 0-9 only.
        if ((tmp >= 48) && (tmp <= 57))
            outclock_phase_shift_adj = outclock_phase_shift_adj * 10 + digit;
        if (tmp == 45)
            sign = -1;  // Found a '-' character, i.e. number is negative.
    end

    // add outclock_phase_shift to time delay
    outclock_phase_shift_adj = (sign*outclock_phase_shift_adj) + outclock_phase_shift;

    // adjust phase shift so that its value is between 0 and 1 full
    // inclock_period
    while (outclock_phase_shift_adj < 0)
        outclock_phase_shift_adj = outclock_phase_shift_adj + inclock_period;
    while (outclock_phase_shift_adj >= inclock_period)
        outclock_phase_shift_adj = outclock_phase_shift_adj - inclock_period;

    // assign result
    time_delay = outclock_phase_shift_adj;
end
endfunction

// INITIAL BLOCK
initial
begin

    // check for invalid parameters
    if (inclock_period <= 0)
    begin
        $display("ERROR: The period of the input clock (inclock_period) must be greater than 0");
        $stop;
    end

    if ((clock0_boost <= 0) || (clock0_divide <= 0)
        || (clock1_boost <= 0) || (clock1_divide <= 0)
        || (clock2_boost <= 0) || (clock2_divide <= 0)
        || (clock_ext_boost <= 0) || (clock_ext_divide <= 0))
    begin
        if ((clock0_boost <= 0) || (clock0_divide <= 0))
        begin
            $display("ERROR: The multiplication and division factors for clock0 must be greater than 0.");
        end

        if ((clock1_boost <= 0) || (clock1_divide <= 0))
        begin
            $display("ERROR: The multiplication and division factors for clock1 must be greater than 0.");
        end

        if ((clock2_boost <= 0) || (clock2_divide <= 0))
        begin
            $display("ERROR: The multiplication and division factors for clock2 must be greater than 0.");
        end

        if ((clock_ext_boost <= 0) || (clock_ext_divide <= 0))
        begin
            $display("ERROR: The multiplication and division factors for clock_ext must be greater than 0.");
        end
        $stop;
    end

    if (!dev.FEATURE_FAMILY_STRATIX(intended_device_family))
    begin
        $display("WARNING: Device family specified by the intended_device_family parameter, %s, may not be supported by altclklock", intended_device_family);
        $display ("Time: %0t  Instance: %m", $time);
    end

    stop_lock_count = 0;
    violation = 0;

    // clock synchronizing variables
    last_synchronizing_rising_edge_for_clk0 = 0;
    last_synchronizing_rising_edge_for_clk1 = 0;
    last_synchronizing_rising_edge_for_clk2 = 0;
    last_synchronizing_rising_edge_for_extclk = 0;
    clk0_synchronizing_period = 0;
    clk1_synchronizing_period = 0;
    clk2_synchronizing_period = 0;
    extclk_synchronizing_period = 0;
    input_cycles_per_clk0 = clock0_divide;
    input_cycles_per_clk1 = clock1_divide;
    input_cycles_per_clk2 = clock2_divide;
    input_cycles_per_extclk = clock_ext_divide;
    clk0_cycles_per_sync_period = clock0_boost;
    clk1_cycles_per_sync_period = clock1_boost;
    clk2_cycles_per_sync_period = clock2_boost;
    extclk_cycles_per_sync_period = clock_ext_boost;
    input_cycle_count_to_sync0 = 0;
    input_cycle_count_to_sync1 = 0;
    input_cycle_count_to_sync2 = 0;
    input_cycle_count_to_sync_extclk = 0;
    inc0 = 1;
    inc1 = 1;
    inc2 = 1;
    inc_ext = 1;
    cycle_to_adjust0 = 0;
    cycle_to_adjust1 = 0;
    cycle_to_adjust2 = 0;
    cycle_to_adjust_ext = 0;

    if ((clock0_boost % clock0_divide) == 0)
    begin
        clk0_cycles_per_sync_period = clock0_boost / clock0_divide;
        input_cycles_per_clk0 = 1;
    end

    if ((clock1_boost % clock1_divide) == 0)
    begin
        clk1_cycles_per_sync_period = clock1_boost / clock1_divide;
        input_cycles_per_clk1 = 1;
    end

    if ((clock2_boost % clock2_divide) == 0)
    begin
        clk2_cycles_per_sync_period = clock2_boost / clock2_divide;
        input_cycles_per_clk2 = 1;
    end

    if ((clock_ext_boost % clock_ext_divide) == 0)
    begin
        extclk_cycles_per_sync_period = clock_ext_boost / clock_ext_divide;
        input_cycles_per_extclk = 1;
    end

    // convert time delays from string to integer
    clk0_phase_delay = time_delay(clock0_time_delay);
    clk1_phase_delay = time_delay(clock1_time_delay);
    clk2_phase_delay = time_delay(clock2_time_delay);
    extclk_phase_delay = time_delay(clock_ext_time_delay);

    // 10% tolerance of input clock period variation
    clk_per_tolerance = 0.1 * inclock_period;
end

always @(next_clk_check)
begin
    if (next_clk_check == 1)
    begin
        if ((clk_check === 1'b1) || (clk_check === 1'b0))
            #((inclk_period+clk_per_tolerance)/2) clk_check = ~clk_check;
        else
            #((inclk_period+clk_per_tolerance)/2) clk_check = 1'b1;
    end
    else if (next_clk_check == 2)
    begin
        if ((clk_check === 1'b1) || (clk_check === 1'b0))
            #(expected_next_clk_edge - $realtime) clk_check = ~clk_check;
        else
            #(expected_next_clk_edge - $realtime) clk_check = 1'b1;
    end
    next_clk_check = 0;
end

always @(inclock or inclocken_int or clk_check)
begin

    if(init !== 1'b1)
    begin
        start_lock_count = 0;
        pll_rising_edge_count = 0;
        pll_last_rising_edge = 0;
        pll_last_falling_edge = 0;
        pll_lock = 0;
        init = 1'b1;
    end

    if (inclocken_int == 1'b0)
    begin
        pll_lock = 0;
        pll_rising_edge_count = 0;
    end
    else if ((inclock == 1'b1) && (clk_last_value !== inclock))
    begin
        if (pll_lock === 1)
            next_clk_check = 1;

        if (pll_rising_edge_count == 0)   // this is first rising edge
        begin
            inclk_period = inclock_period;
            pll_duty_cycle = inclk_period/2;
            start_outclk = 0;
        end
        else if (pll_rising_edge_count == 1) // this is second rising edge
        begin
            expected_clk_cycle = inclk_period;
            actual_clk_cycle = $realtime - pll_last_rising_edge;
            if (actual_clk_cycle < (expected_clk_cycle - clk_per_tolerance) ||
                actual_clk_cycle > (expected_clk_cycle + clk_per_tolerance))
            begin
                $display($realtime, "ps Warning: Inclock_Period Violation");
                $display ("Instance: %m");
                violation = 1;
                if (locked == 1'b1)
                begin
                    stop_lock_count = stop_lock_count + 1;
                    if ((locked == 1'b1) && (stop_lock_count == invalid_lock_cycles))
                    begin
                        pll_lock = 0;
                        $display ($realtime, "ps Warning: altclklock out of lock.");
                        $display ("Instance: %m");
                        start_lock_count = 1;

                        stop_lock_count = 0;
                        clk0_tmp = 1'bx;
                        clk1_tmp = 1'bx;
                        clk2_tmp = 1'bx;
                        extclk_tmp = 1'bx;
                    end
                end
                else begin
                    start_lock_count = 1;
                end
            end
            else
            begin
                if (($realtime - pll_last_falling_edge) < (pll_duty_cycle - clk_per_tolerance/2) ||
                    ($realtime - pll_last_falling_edge) > (pll_duty_cycle + clk_per_tolerance/2))
                begin
                    $display($realtime, "ps Warning: Duty Cycle Violation");
                    $display ("Instance: %m");
                    violation = 1;
                end
                else
                    violation = 0;
            end
        end
        else if (($realtime - pll_last_rising_edge) < (expected_clk_cycle - clk_per_tolerance) ||
                ($realtime - pll_last_rising_edge) > (expected_clk_cycle + clk_per_tolerance))
        begin
            $display($realtime, "ps Warning: Cycle Violation");
            $display ("Instance: %m");
            violation = 1;
            if (locked == 1'b1)
            begin
                stop_lock_count = stop_lock_count + 1;
                if (stop_lock_count == invalid_lock_cycles)
                begin
                    pll_lock = 0;
                    $display ($realtime, "ps Warning: altclklock out of lock.");
                    $display ("Instance: %m");
                    
                    start_lock_count = 1;

                    stop_lock_count = 0;
                    clk0_tmp = 1'bx;
                    clk1_tmp = 1'bx;
                    clk2_tmp = 1'bx;
                    extclk_tmp = 1'bx;
                end
            end
            else
            begin
                start_lock_count = 1;
            end
        end
        else
        begin
            violation = 0;
            actual_clk_cycle = $realtime - pll_last_rising_edge;
        end
        pll_last_rising_edge = $realtime;
        pll_rising_edge_count = pll_rising_edge_count + 1;
        if (!violation)
        begin
            if (pll_lock == 1'b1)
            begin
                input_cycle_count_to_sync0 = input_cycle_count_to_sync0 + 1;
                if (input_cycle_count_to_sync0 == input_cycles_per_clk0)
                begin
                    clk0_synchronizing_period = $realtime - last_synchronizing_rising_edge_for_clk0;
                    last_synchronizing_rising_edge_for_clk0 = $realtime;
                    schedule_clk0 = 1;
                    input_cycle_count_to_sync0 = 0;
                end
                input_cycle_count_to_sync1 = input_cycle_count_to_sync1 + 1;
                if (input_cycle_count_to_sync1 == input_cycles_per_clk1)
                begin
                    clk1_synchronizing_period = $realtime - last_synchronizing_rising_edge_for_clk1;
                    last_synchronizing_rising_edge_for_clk1 = $realtime;
                    schedule_clk1 = 1;
                    input_cycle_count_to_sync1 = 0;
                end
                input_cycle_count_to_sync2 = input_cycle_count_to_sync2 + 1;
                if (input_cycle_count_to_sync2 == input_cycles_per_clk2)
                begin
                    clk2_synchronizing_period = $realtime - last_synchronizing_rising_edge_for_clk2;
                    last_synchronizing_rising_edge_for_clk2 = $realtime;
                    schedule_clk2 = 1;
                    input_cycle_count_to_sync2 = 0;
                end
                input_cycle_count_to_sync_extclk = input_cycle_count_to_sync_extclk + 1;
                if (input_cycle_count_to_sync_extclk == input_cycles_per_extclk)
                begin
                    extclk_synchronizing_period = $realtime - last_synchronizing_rising_edge_for_extclk;
                    last_synchronizing_rising_edge_for_extclk = $realtime;
                    schedule_extclk = 1;
                    input_cycle_count_to_sync_extclk = 0;
                end
            end
            else
            begin
                start_lock_count = start_lock_count + 1;
                if (start_lock_count >= valid_lock_cycles)
                begin
                    pll_lock = 1;
                    input_cycle_count_to_sync0 = 0;
                    input_cycle_count_to_sync1 = 0;
                    input_cycle_count_to_sync2 = 0;
                    input_cycle_count_to_sync_extclk = 0;
                    clk0_synchronizing_period = actual_clk_cycle * input_cycles_per_clk0;
                    clk1_synchronizing_period = actual_clk_cycle * input_cycles_per_clk1;
                    clk2_synchronizing_period = actual_clk_cycle * input_cycles_per_clk2;
                    extclk_synchronizing_period = actual_clk_cycle * input_cycles_per_extclk;
                    last_synchronizing_rising_edge_for_clk0 = $realtime;
                    last_synchronizing_rising_edge_for_clk1 = $realtime;
                    last_synchronizing_rising_edge_for_clk2 = $realtime;
                    last_synchronizing_rising_edge_for_extclk = $realtime;
                    schedule_clk0 = 1;
                    schedule_clk1 = 1;
                    schedule_clk2 = 1;
                    schedule_extclk = 1;
                end
            end
        end
        else
            start_lock_count = 1;
    end
    else if ((inclock == 1'b0) && (clk_last_value !== inclock))
    begin
        if (pll_lock == 1)
        begin
            next_clk_check = 1;
            if (($realtime - pll_last_rising_edge) < (pll_duty_cycle - clk_per_tolerance/2) ||
                ($realtime - pll_last_rising_edge) > (pll_duty_cycle + clk_per_tolerance/2))
            begin
                $display($realtime, "ps Warning: Duty Cycle Violation");
                $display ("Instance: %m");
                violation = 1;
                if (locked == 1'b1)
                begin
                    stop_lock_count = stop_lock_count + 1;
                    if (stop_lock_count == invalid_lock_cycles)
                    begin
                        pll_lock = 0;
                        $display ($realtime, "ps Warning: altclklock out of lock.");
                        $display ("Instance: %m");
                        
                        start_lock_count = 1;

                        stop_lock_count = 0;
                        clk0_tmp = 1'bx;
                        clk1_tmp = 1'bx;
                        clk2_tmp = 1'bx;
                        extclk_tmp = 1'bx;
                    end
                end
            end
            else
                violation = 0;
        end
        else
            start_lock_count = start_lock_count + 1;
        pll_last_falling_edge = $realtime;
    end
    else if (pll_lock == 1)
    begin
    if (inclock == 1'b1)
        expected_next_clk_edge = pll_last_rising_edge + (inclk_period+clk_per_tolerance)/2;
    else if (inclock == 'b0)
        expected_next_clk_edge = pll_last_falling_edge + (inclk_period+clk_per_tolerance)/2;
    else
        expected_next_clk_edge = 0;
        violation = 0;
        if ($realtime < expected_next_clk_edge)
            next_clk_check = 2;
        else if ($realtime == expected_next_clk_edge)
            next_clk_check = 1;
        else
        begin
            $display($realtime, "ps Warning: Inclock_Period Violation");
            $display ("Instance: %m");
            violation = 1;

            if (locked == 1'b1)
            begin
                stop_lock_count = stop_lock_count + 1;
                expected_next_clk_edge = $realtime + (inclk_period/2);
                if (stop_lock_count == invalid_lock_cycles)
                begin
                    pll_lock = 0;
                    $display ($realtime, "ps Warning: altclklock out of lock.");
                    $display ("Instance: %m");

                    start_lock_count = 1;

                    stop_lock_count = 0;
                    clk0_tmp = 1'bx;
                    clk1_tmp = 1'bx;
                    clk2_tmp = 1'bx;
                    extclk_tmp = 1'bx;
                end
                else
                    next_clk_check = 2;
            end
        end
    end
    clk_last_value = inclock;
end

// clock0 output
always @(posedge schedule_clk0)
begin
    // initialise variables
    inc0 = 1;
    cycle_to_adjust0 = 0;
    output_value0 = 1'b1;
    sched_time0 = 0;
    rem0 = clk0_synchronizing_period % clk0_cycles_per_sync_period;
    ori_per0 = clk0_synchronizing_period / clk0_cycles_per_sync_period;

    // schedule <clk0_cycles_per_sync_period> number of clock0 cycles in this
    // loop - in order to synchronize the output clock always to the input clock
    // to get rid of clock drift for cases where the input clock period is
    // not evenly divisible
    for (clk_cnt0 = 1; clk_cnt0 <= clk0_cycles_per_sync_period;
        clk_cnt0 = clk_cnt0 + 1)
    begin
        tmp_per0 = ori_per0;
        if ((rem0 != 0) && (inc0 <= rem0))
        begin
            tmp_rem0 = (clk0_cycles_per_sync_period * inc0) % rem0;
            cycle_to_adjust0 = (clk0_cycles_per_sync_period * inc0) / rem0;
            if (tmp_rem0 != 0)
                cycle_to_adjust0 = cycle_to_adjust0 + 1;
        end

        // if this cycle is the one to adjust the output clock period, then
        // increment the period by 1 unit
        if (cycle_to_adjust0 == clk_cnt0)
        begin
            tmp_per0 = tmp_per0 + 1;
            inc0 = inc0 + 1;
        end

        // adjust the high and low cycle period
        high_time0 = tmp_per0 / 2;
        if ((tmp_per0 % 2) != 0)
            high_time0 = high_time0 + 1;

        low_time0 = tmp_per0 - high_time0;

        // schedule the high and low cycle of 1 output clock period
        for (cyc0 = 0; cyc0 <= 1; cyc0 = cyc0 + 1)
        begin
            // Avoid glitch in vcs when high_time0 and low_time0 is 0
            // (due to clk0_synchronizing_period is 0)
            if (clk0_synchronizing_period != 0)
                clk0_tmp = #(sched_time0) output_value0;
            else
                clk0_tmp = #(sched_time0) 1'b0;
            output_value0 = ~output_value0;
            if (output_value0 == 1'b0)
            begin
                sched_time0 = high_time0;
            end
            else if (output_value0 == 1'b1)
            begin
                sched_time0 = low_time0;
            end
        end
    end

    // drop the schedule_clk0 to 0 so that the "always@(inclock)" block can
    // trigger this block again when the correct time comes
    schedule_clk0 = #1 1'b0;
end

always @(clk0_tmp)
begin
    if (clk0_phase_delay == 0)
        clock0 <= clk0_tmp;
    else
        clock0 <= #(clk0_phase_delay) clk0_tmp;
end

// clock1 output
always @(posedge schedule_clk1)
begin
    // initialize variables
    inc1 = 1;
    cycle_to_adjust1 = 0;
    output_value1 = 1'b1;
    sched_time1 = 0;
    rem1 = clk1_synchronizing_period % clk1_cycles_per_sync_period;
    ori_per1 = clk1_synchronizing_period / clk1_cycles_per_sync_period;

    // schedule <clk1_cycles_per_sync_period> number of clock1 cycles in this
    // loop - in order to synchronize the output clock always to the input clock,
    // to get rid of clock drift for cases where the input clock period is
    // not evenly divisible
    for (clk_cnt1 = 1; clk_cnt1 <= clk1_cycles_per_sync_period;
        clk_cnt1 = clk_cnt1 + 1)
    begin
        tmp_per1 = ori_per1;
        if ((rem1 != 0) && (inc1 <= rem1))
        begin
            tmp_rem1 = (clk1_cycles_per_sync_period * inc1) % rem1;
            cycle_to_adjust1 = (clk1_cycles_per_sync_period * inc1) / rem1;
            if (tmp_rem1 != 0)
                cycle_to_adjust1 = cycle_to_adjust1 + 1;
        end

        // if this cycle is the one to adjust the output clock period, then
        // increment the period by 1 unit
        if (cycle_to_adjust1 == clk_cnt1)
        begin
            tmp_per1 = tmp_per1 + 1;
            inc1 = inc1 + 1;
        end

        // adjust the high and low cycle period
        high_time1 = tmp_per1 / 2;
        if ((tmp_per1 % 2) != 0)
            high_time1 = high_time1 + 1;

        low_time1 = tmp_per1 - high_time1;

        // schedule the high and low cycle of 1 output clock period
        for (cyc1 = 0; cyc1 <= 1; cyc1 = cyc1 + 1)
        begin
            // Avoid glitch in vcs when high_time1 and low_time1 is 0
            // (due to clk1_synchronizing_period is 0)
            if (clk1_synchronizing_period != 0)
                clk1_tmp = #(sched_time1) output_value1;
            else
                clk1_tmp = #(sched_time1) 1'b0;
            output_value1 = ~output_value1;
            if (output_value1 == 1'b0)
                sched_time1 = high_time1;
            else if (output_value1 == 1'b1)
                sched_time1 = low_time1;
        end
    end
    // drop the schedule_clk1 to 0 so that the "always@(inclock)" block can
    // trigger this block again when the correct time comes
    schedule_clk1 = #1 1'b0;
end

always @(clk1_tmp)
begin
    if (clk1_phase_delay == 0)
        clock1 <= clk1_tmp;
    else
        clock1 <= #(clk1_phase_delay) clk1_tmp;
end

// clock2 output
always @(posedge schedule_clk2)
begin
    if (dev.FEATURE_FAMILY_STRATIX(intended_device_family))
    begin
        // initialize variables
        inc2 = 1;
        cycle_to_adjust2 = 0;
        output_value2 = 1'b1;
        sched_time2 = 0;
        rem2 = clk2_synchronizing_period % clk2_cycles_per_sync_period;
        ori_per2 = clk2_synchronizing_period / clk2_cycles_per_sync_period;

        // schedule <clk2_cycles_per_sync_period> number of clock2 cycles in this
        // loop - in order to synchronize the output clock always to the input clock,
        // to get rid of clock drift for cases where the input clock period is
        // not evenly divisible
        for (clk_cnt2 = 1; clk_cnt2 <= clk2_cycles_per_sync_period;
            clk_cnt2 = clk_cnt2 + 1)
        begin
            tmp_per2 = ori_per2;
            if ((rem2 != 0) && (inc2 <= rem2))
            begin
                tmp_rem2 = (clk2_cycles_per_sync_period * inc2) % rem2;
                cycle_to_adjust2 = (clk2_cycles_per_sync_period * inc2) / rem2;
                if (tmp_rem2 != 0)
                    cycle_to_adjust2 = cycle_to_adjust2 + 1;
            end

            // if this cycle is the one to adjust the output clock period, then
            // increment the period by 1 unit
            if (cycle_to_adjust2 == clk_cnt2)
            begin
                tmp_per2 = tmp_per2 + 1;
                inc2 = inc2 + 1;
            end

            // adjust the high and low cycle period
            high_time2 = tmp_per2 / 2;
            if ((tmp_per2 % 2) != 0)
                high_time2 = high_time2 + 1;

            low_time2 = tmp_per2 - high_time2;

            // schedule the high and low cycle of 1 output clock period
            for (cyc2 = 0; cyc2 <= 1; cyc2 = cyc2 + 1)
            begin
                // Avoid glitch in vcs when high_time2 and low_time2 is 0
                // (due to clk2_synchronizing_period is 0)
                if (clk2_synchronizing_period != 0)
                    clk2_tmp = #(sched_time2) output_value2;
                else
                    clk2_tmp = #(sched_time2) 1'b0;
                output_value2 = ~output_value2;
                if (output_value2 == 1'b0)
                    sched_time2 = high_time2;
                else if (output_value2 == 1'b1)
                    sched_time2 = low_time2;
            end
        end
        // drop the schedule_clk2 to 0 so that the "always@(inclock)" block can
        // trigger this block again when the correct time comes
        schedule_clk2 = #1 1'b0;
    end
end

always @(clk2_tmp)
begin
    if (clk2_phase_delay == 0)
        clock2 <= clk2_tmp;
    else
        clock2 <= #(clk2_phase_delay) clk2_tmp;
end

// clock_ext output
always @(posedge schedule_extclk)
begin
    if (dev.FEATURE_FAMILY_STRATIX(intended_device_family))
    begin
        // initialize variables
        inc_ext = 1;
        cycle_to_adjust_ext = 0;
        output_value_ext = 1'b1;
        sched_time_ext = 0;
        rem_ext = extclk_synchronizing_period % extclk_cycles_per_sync_period;
        ori_per_ext = extclk_synchronizing_period/extclk_cycles_per_sync_period;

        // schedule <extclk_cycles_per_sync_period> number of clock_ext cycles in this
        // loop - in order to synchronize the output clock always to the input clock,
        // to get rid of clock drift for cases where the input clock period is
        // not evenly divisible
        for (clk_cnt_ext = 1; clk_cnt_ext <= extclk_cycles_per_sync_period;
            clk_cnt_ext = clk_cnt_ext + 1)
        begin
            tmp_per_ext = ori_per_ext;
            if ((rem_ext != 0) && (inc_ext <= rem_ext))
            begin
                tmp_rem_ext = (extclk_cycles_per_sync_period * inc_ext) % rem_ext;
                cycle_to_adjust_ext = (extclk_cycles_per_sync_period * inc_ext) / rem_ext;
                if (tmp_rem_ext != 0)
                    cycle_to_adjust_ext = cycle_to_adjust_ext + 1;
            end

            // if this cycle is the one to adjust the output clock period, then
            // increment the period by 1 unit
            if (cycle_to_adjust_ext == clk_cnt_ext)
            begin
                tmp_per_ext = tmp_per_ext + 1;
                inc_ext = inc_ext + 1;
            end

            // adjust the high and low cycle period
            high_time_ext = tmp_per_ext/2;
            if ((tmp_per_ext % 2) != 0)
                high_time_ext = high_time_ext + 1;

            low_time_ext = tmp_per_ext - high_time_ext;

            // schedule the high and low cycle of 1 output clock period
            for (cyc_ext = 0; cyc_ext <= 1; cyc_ext = cyc_ext + 1)
            begin
                // Avoid glitch in vcs when high_time_ext and low_time_ext is 0
                // (due to extclk_synchronizing_period is 0)
                if (extclk_synchronizing_period != 0)
                    extclk_tmp = #(sched_time_ext) output_value_ext;
                else
                    extclk_tmp = #(sched_time_ext) 1'b0;
                output_value_ext = ~output_value_ext;
                if (output_value_ext == 1'b0)
                    sched_time_ext = high_time_ext;
                else if (output_value_ext == 1'b1)
                    sched_time_ext = low_time_ext;
            end
        end
        // drop the schedule_extclk to 0 so that the "always@(inclock)" block
        // can trigger this block again when the correct time comes
        schedule_extclk = #1 1'b0;
    end
end

always @(extclk_tmp)
begin
    if (extclk_phase_delay == 0)
        clock_ext <= extclk_tmp;
    else
        clock_ext <= #(extclk_phase_delay) extclk_tmp;
end

// ACCELERATE OUTPUTS
buf (locked, pll_lock);

endmodule // altclklock
// END OF MODULE ALTCLKLOCK


// START MODULE NAME -----------------------------------------------------------
//
// Module Name      : ALTDDIO_IN
//
// Description      : Double Data Rate (DDR) input behavioural model. Receives
//                    data on both edges of the reference clock.
//
// Limitations      : Not available for MAX device families.
//
// Expected results : Data sampled from the datain port at the rising edge of
//                    the reference clock (dataout_h) and at the falling edge of
//                    the reference clock (dataout_l).
//
//END MODULE NAME --------------------------------------------------------------

`timescale 1 ps / 1 ps

// MODULE DECLARATION
module altddio_in (
    datain,    // required port, DDR input data
    inclock,   // required port, input reference clock to sample data by
    inclocken, // enable data clock
    aset,      // asynchronous set
    aclr,      // asynchronous clear
    sset,      // synchronous set
    sclr,      // synchronous clear
    dataout_h, // data sampled at the rising edge of inclock
    dataout_l  // data sampled at the falling edge of inclock
);

// GLOBAL PARAMETER DECLARATION
parameter width = 1;  // required parameter
parameter power_up_high = "OFF";
parameter invert_input_clocks = "OFF";
parameter intended_device_family = "Stratix";
parameter lpm_type = "altddio_in";
parameter lpm_hint = "UNUSED";

// INPUT PORT DECLARATION
input [width-1:0] datain;
input inclock;
input inclocken;
input aset;
input aclr;
input sset;
input sclr;

// OUTPUT PORT DECLARATION
output [width-1:0] dataout_h;
output [width-1:0] dataout_l;

// REGISTER AND VARIABLE DECLARATION
reg [width-1:0] dataout_h_tmp;
reg [width-1:0] dataout_l_tmp;
reg [width-1:0] datain_latched;
reg is_stratix;
reg is_maxii;
reg is_stratixiii;
reg is_inverted_output_ddio;

ALTERA_DEVICE_FAMILIES dev ();

// pulldown/pullup
tri0 aset; // default aset to 0
tri0 aclr; // default aclr to 0
tri0 sset; // default sset to 0
tri0 sclr; // default sclr to 0
tri1 inclocken; // default inclocken to 1

// INITIAL BLOCK
initial
begin
    is_stratixiii = dev.FEATURE_FAMILY_STRATIXIII(intended_device_family);
    is_stratix = dev.FEATURE_FAMILY_STRATIX(intended_device_family);
    is_maxii = dev.FEATURE_FAMILY_MAXII(intended_device_family);
    is_inverted_output_ddio = dev.FEATURE_FAMILY_HAS_INVERTED_OUTPUT_DDIO(intended_device_family);
    // Begin of parameter checking
    if (width <= 0)
    begin
        $display("ERROR: The width parameter must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (dev.IS_VALID_FAMILY(intended_device_family) == 0)
    begin
        $display ("Error! Unknown INTENDED_DEVICE_FAMILY=%s.", intended_device_family);
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (!(is_stratix &&
        !(is_maxii)))
    begin
        $display("ERROR: Megafunction altddio_in is not supported in %s.", intended_device_family);
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end
    // End of parameter checking

    // if power_up_high parameter is turned on, registers power up
    // to '1', otherwise '0'
    dataout_h_tmp = (power_up_high == "ON") ? {width{1'b1}} : {width{1'b0}};
    dataout_l_tmp = (power_up_high == "ON") ? {width{1'b1}} : {width{1'b0}};
    datain_latched = (power_up_high == "ON") ? {width{1'b1}} : {width{1'b0}};   
end

// input reference clock, sample data
always @ (posedge inclock or posedge aclr or posedge aset)
begin
    if (aclr)
    begin
        dataout_h_tmp <= {width{1'b0}};
        dataout_l_tmp <= {width{1'b0}};
    end
    else if (aset)
    begin
        dataout_h_tmp <= {width{1'b1}};
        dataout_l_tmp <= {width{1'b1}};
    end
    // if not being set or cleared
    else if (inclocken == 1'b1)
    begin
        if (invert_input_clocks == "ON")
        begin
            if (sclr)
                datain_latched <= {width{1'b0}};
            else if (sset)
                datain_latched <= {width{1'b1}};
            else
                datain_latched <= datain;
        end
        else
        begin
            if (is_stratixiii)
            begin
                if (sclr)
                begin
                    dataout_h_tmp <= {width{1'b0}};
                    dataout_l_tmp <= {width{1'b0}};
                end
                else if (sset)
                begin
                    dataout_h_tmp <= {width{1'b1}};
                    dataout_l_tmp <= {width{1'b1}};
                end
                else
                begin
                    dataout_h_tmp <= datain;
                    dataout_l_tmp <= datain_latched;
                end
            end
            else
            begin
                if (sclr)
                begin
                    dataout_h_tmp <= {width{1'b0}};
                end
                else if (sset)
                begin
                    dataout_h_tmp <= {width{1'b1}};
                end
                else
                begin
                    dataout_h_tmp <= datain;
                end
                dataout_l_tmp <= datain_latched;
            end
        end
    end
end

always @ (negedge inclock or posedge aclr or posedge aset)
begin
    if (aclr)
    begin
        datain_latched <= {width{1'b0}};
    end
    else if (aset)
    begin
        datain_latched <= {width{1'b1}};
    end
    // if not being set or cleared
    else
    begin
        if ((is_stratix &&
        !(is_maxii)))
        begin
            if (inclocken == 1'b1)
            begin
                if (invert_input_clocks == "ON")
                begin
                    if (is_stratixiii)
                    begin
                        if (sclr)
                        begin
                            dataout_h_tmp <= {width{1'b0}};
                            dataout_l_tmp <= {width{1'b0}};
                        end
                        else if (sset)
                        begin
                            dataout_h_tmp <= {width{1'b1}};
                            dataout_l_tmp <= {width{1'b1}};
                        end
                        else
                        begin
                            dataout_h_tmp <= datain;
                            dataout_l_tmp <= datain_latched;
                        end
                    end
                    else
                    begin
                        if (sclr)
                        begin
                            dataout_h_tmp <= {width{1'b0}};
                        end
                        else if (sset)
                        begin
                            dataout_h_tmp <= {width{1'b1}};
                        end
                        else
                        begin
                            dataout_h_tmp <= datain;
                        end
                        dataout_l_tmp <= datain_latched;
                    end
                end
                else
                begin
                    if (sclr)
                    begin
                        datain_latched <= {width{1'b0}};
                    end
                    else if (sset)
                    begin
                        datain_latched <= {width{1'b1}};
                    end
                    else
                    begin
                        datain_latched <= datain;
                    end
                end
            end 
        end
        else
        begin
            if (invert_input_clocks == "ON")
            begin
                dataout_h_tmp <= datain;
                dataout_l_tmp <= datain_latched;
            end
            else
                datain_latched <= datain;
        end
    end
end

// assign registers to output ports
assign dataout_l = dataout_l_tmp;
assign dataout_h = dataout_h_tmp;

endmodule // altddio_in
// END MODULE ALTDDIO_IN

// START MODULE NAME -----------------------------------------------------------
//
// Module Name      : ALTDDIO_OUT
//
// Description      : Double Data Rate (DDR) output behavioural model.
//                    Transmits data on both edges of the reference clock.
//
// Limitations      : Not available for MAX device families.                    
//
// Expected results : Double data rate output on dataout.
//
//END MODULE NAME --------------------------------------------------------------

`timescale 1 ps / 1 ps

// MODULE DECLARATION
module altddio_out (
    datain_h,   // required port, data input for the rising edge of outclock
    datain_l,   // required port, data input for the falling edge of outclock
    outclock,   // required port, input reference clock to output data by
    outclocken, // clock enable signal for outclock
    aset,       // asynchronous set
    aclr,       // asynchronous clear
    sset,       // synchronous set
    sclr,       // synchronous clear
    oe,         // output enable for dataout
    dataout,    // DDR data output,
    oe_out      // DDR OE output,
);

// GLOBAL PARAMETER DECLARATION
parameter width = 1; // required parameter
parameter power_up_high = "OFF";
parameter oe_reg = "UNUSED";
parameter extend_oe_disable = "UNUSED";
parameter intended_device_family = "Stratix";
parameter invert_output = "OFF";
parameter lpm_type = "altddio_out";
parameter lpm_hint = "UNUSED";

// INPUT PORT DECLARATION
input [width-1:0] datain_h;
input [width-1:0] datain_l;
input outclock;
input outclocken;
input aset;
input aclr;
input sset;
input sclr;
input oe;

// OUTPUT PORT DECLARATION
output [width-1:0] dataout;
output [width-1:0] oe_out;

// REGISTER, NET AND VARIABLE DECLARATION
wire stratix_oe;
wire output_enable;
reg  oe_rgd;
reg  oe_reg_ext;
reg  [width-1:0] dataout;
reg  [width-1:0] dataout_h;
reg  [width-1:0] dataout_l;
reg  [width-1:0] dataout_tmp;
reg is_stratix;
reg is_maxii;
reg is_stratixiii;
reg is_inverted_output_ddio;

ALTERA_DEVICE_FAMILIES dev ();

// pulldown/pullup
tri0 aset; // default aset to 0
tri0 aclr; // default aclr to 0
tri0 sset; // default sset to 0
tri0 sclr; // default sclr to 0
tri1 outclocken; // default outclocken to 1
tri1 oe;   // default oe to 1

// INITIAL BLOCK
initial
begin
    is_stratixiii = dev.FEATURE_FAMILY_STRATIXIII(intended_device_family);
    is_stratix = dev.FEATURE_FAMILY_STRATIX(intended_device_family);
    is_maxii = dev.FEATURE_FAMILY_MAXII(intended_device_family);
    is_inverted_output_ddio = dev.FEATURE_FAMILY_HAS_INVERTED_OUTPUT_DDIO(intended_device_family);
    
    // Begin of parameter checking
    if (width <= 0)
    begin
        $display("ERROR: The width parameter must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (dev.IS_VALID_FAMILY(intended_device_family) == 0)
    begin
        $display ("Error! Unknown INTENDED_DEVICE_FAMILY=%s.", intended_device_family);
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (!(is_stratix &&
        !(is_maxii)))
    begin
        $display("ERROR: Megafunction altddio_out is not supported in %s.", intended_device_family);
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end
    // End of parameter checking

    // if power_up_high parameter is turned on, registers power up to '1'
    // else to '0'
    dataout_h = (power_up_high == "ON") ? {width{1'b1}} : {width{1'b0}};
    dataout_l = (power_up_high == "ON") ? {width{1'b1}} : {width{1'b0}};
    dataout_tmp = (power_up_high == "ON") ? {width{1'b1}} : {width{1'b0}};

    if (power_up_high == "ON")
    begin
        oe_rgd = 1'b1;
        oe_reg_ext = 1'b1;
    end
    else
    begin
        oe_rgd = 1'b0;
        oe_reg_ext = 1'b0;
    end
end


// input reference clock
always @ (posedge outclock or posedge aclr or posedge aset)
begin
    if (aclr)
    begin
        dataout_h <= {width{1'b0}};
        dataout_l <= {width{1'b0}};
        dataout_tmp <= {width{1'b0}};

        oe_rgd <= 1'b0;
    end
    else if (aset)
    begin
        dataout_h <= {width{1'b1}};
        dataout_l <= {width{1'b1}};
        dataout_tmp <= {width{1'b1}};

        oe_rgd <= 1'b1;
    end
    // if clock is enabled
    else if (outclocken == 1'b1)
    begin
        if (sclr)
        begin
            dataout_h <= {width{1'b0}};
            dataout_l <= {width{1'b0}};
            dataout_tmp <= {width{1'b0}};
            oe_reg_ext <= 1'b0;
            oe_rgd <= 1'b0;
        end
        else if (sset)
        begin
            dataout_h <= {width{1'b1}};
            dataout_l <= {width{1'b1}};
            dataout_tmp <= {width{1'b1}};
            oe_reg_ext <= 1'b1;
            oe_rgd <= 1'b1;
        end
        else
        begin
            dataout_h <= datain_h;
            dataout_l <= datain_l;
            dataout_tmp <= datain_h;

            // register the output enable signal
            oe_rgd <= oe;
        end
    end
    else
        dataout_tmp <= dataout_h;

end

// input reference clock
always @ (negedge outclock or posedge aclr or posedge aset)
begin
    if (aclr)
    begin
        oe_reg_ext <= 1'b0;
    end
    else if (aset)
    begin
        oe_reg_ext <= 1'b1;
    end
    else
    begin
        // if clock is enabled
        if (outclocken == 1'b1)
        begin
            // additional register for output enable signal
            oe_reg_ext <= oe_rgd;
        end

        dataout_tmp <= dataout_l;
    end
end

// data output
always @(dataout_tmp or output_enable)
begin
    // if output is enabled
    if (output_enable == 1'b1)
    begin
        if (is_inverted_output_ddio &&
            (invert_output == "ON"))
            dataout = ~dataout_tmp;
        else
            dataout = dataout_tmp;
    end    
    else // output is disabled
        dataout = {width{1'bZ}};
end

// output enable signal
assign output_enable = ((is_stratix &&
                        !(is_maxii)))
                        ? stratix_oe
                        : oe;

assign stratix_oe = (extend_oe_disable == "ON")
                    ? (oe_reg_ext & oe_rgd)
                    : ((oe_reg == "REGISTERED") && (extend_oe_disable != "ON"))
                    ? oe_rgd
                    : oe;

assign oe_out = {width{output_enable}};

endmodule // altddio_out
// END MODULE ALTDDIO_OUT

// START MODULE NAME -----------------------------------------------------------
//
// Module Name      : ALTDDIO_BIDIR
//
// Description      : Double Data Rate (DDR) bi-directional behavioural model.
//                    Transmits and receives data on both edges of the reference
//                    clock.
//
// Limitations      : Not available for MAX device families.
//
// Expected results : Data output sampled from padio port on rising edge of
//                    inclock signal (dataout_h) and falling edge of inclock
//                    signal (dataout_l). Combinatorial output fed by padio
//                    directly (combout).
//
//END MODULE NAME --------------------------------------------------------------

`timescale 1 ps / 1 ps

// MODULE DECLARATION
module altddio_bidir (
    datain_h,   // required port, input data to be output of padio port at the
                // rising edge of outclock
    datain_l,   // required port, input data to be output of padio port at the
                // falling edge of outclock
    inclock,    // required port, input reference clock to sample data by
    inclocken,  // inclock enable
    outclock,   // required port, input reference clock to register data output
    outclocken, // outclock enable
    aset,       // asynchronour set
    aclr,       // asynchronous clear
    sset,       // ssynchronour set
    sclr,       // ssynchronous clear
    oe,         // output enable for padio port
    dataout_h,  // data sampled from the padio port at the rising edge of inclock
    dataout_l,  // data sampled from the padio port at the falling edge of
                // inclock
    combout,    // combinatorial output directly fed by padio
    oe_out,     // DDR OE output
    dqsundelayedout, // undelayed DQS signal to the PLD core
    padio     // bidirectional DDR port
);

// GLOBAL PARAMETER DECLARATION
parameter width = 1; // required parameter
parameter power_up_high = "OFF";
parameter oe_reg = "UNUSED";
parameter extend_oe_disable = "UNUSED";
parameter implement_input_in_lcell = "UNUSED";
parameter invert_output = "OFF";
parameter intended_device_family = "Stratix";
parameter lpm_type = "altddio_bidir";
parameter lpm_hint = "UNUSED";

// INPUT PORT DECLARATION
input [width-1:0] datain_h;
input [width-1:0] datain_l;
input inclock;
input inclocken;
input outclock;
input outclocken;
input aset;
input aclr;
input sset;
input sclr;
input oe;

// OUTPUT PORT DECLARATION
output [width-1:0] dataout_h;
output [width-1:0] dataout_l;
output [width-1:0] combout;
output [width-1:0] oe_out;
output [width-1:0] dqsundelayedout;
// BIDIRECTIONAL PORT DECLARATION
inout  [width-1:0] padio;

// pulldown/pullup
tri0 inclock;
tri0 aset;
tri0 aclr;
tri0 sset;
tri0 sclr;
tri1 outclocken;
tri1 inclocken;
tri1 oe;

// INITIAL BLOCK
initial
begin
    // Begin of parameter checking
    if (width <= 0)
    begin
        $display("ERROR: The width parameter must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end
    // End of parameter checking
end

// COMPONENT INSTANTIATION
// ALTDDIO_IN
altddio_in u1 (
    .datain(padio),
    .inclock(inclock),
    .inclocken(inclocken),
    .aset(aset),
    .aclr(aclr),
    .sset(sset),
    .sclr(sclr),
    .dataout_h(dataout_h),
    .dataout_l(dataout_l)
);
defparam    u1.width = width,
            u1.intended_device_family = intended_device_family,
            u1.power_up_high = power_up_high;

// ALTDDIO_OUT
altddio_out u2 (
    .datain_h(datain_h),
    .datain_l(datain_l),
    .outclock(outclock),
    .oe(oe),
    .outclocken(outclocken),
    .aset(aset),
    .aclr(aclr),
    .sset(sset),
    .sclr(sclr),
    .dataout(padio),
    .oe_out(oe_out)
);
defparam    u2.width = width,
            u2.power_up_high = power_up_high,
            u2.intended_device_family = intended_device_family,
            u2.oe_reg = oe_reg,
            u2.extend_oe_disable = extend_oe_disable,
            u2.invert_output = invert_output;

// padio feeds combout port directly
assign combout = padio;
assign dqsundelayedout = padio;
endmodule // altddio_bidir
// END MODULE ALTDDIO_BIDIR

//--------------------------------------------------------------------------
// Module Name      : altdpram
//
// Description      : Parameterized Dual Port RAM megafunction
//
// Limitation       : This megafunction is provided only for backward
//                    compatibility in Cyclone, Stratix, and Stratix GX
//                    designs.
//
// Results expected : RAM having dual ports (separate Read and Write)
//                    behaviour
//
//--------------------------------------------------------------------------
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module altdpram (wren, data, wraddress, inclock, inclocken, rden, rdaddress,
                wraddressstall, rdaddressstall, byteena,
                outclock, outclocken, aclr, q);

// PARAMETER DECLARATION
    parameter width = 1;
    parameter widthad = 1;
    parameter numwords = 0;
    parameter lpm_file = "UNUSED";
    parameter lpm_hint = "USE_EAB=ON";
    parameter use_eab = "ON";
    parameter lpm_type = "altdpram";
    parameter indata_reg = "INCLOCK";
    parameter indata_aclr = "ON";
    parameter wraddress_reg = "INCLOCK";
    parameter wraddress_aclr = "ON";
    parameter wrcontrol_reg = "INCLOCK";
    parameter wrcontrol_aclr = "ON";
    parameter rdaddress_reg = "OUTCLOCK";
    parameter rdaddress_aclr = "ON";
    parameter rdcontrol_reg = "OUTCLOCK";
    parameter rdcontrol_aclr = "ON";
    parameter outdata_reg = "UNREGISTERED";
    parameter outdata_aclr = "ON";
    parameter maximum_depth = 2048;
    parameter intended_device_family = "Stratix";
    parameter ram_block_type = "AUTO";
    parameter width_byteena = 1;
    parameter byte_size = 0;
    parameter read_during_write_mode_mixed_ports = "DONT_CARE";

// LOCAL_PARAMETERS_BEGIN

    parameter i_byte_size = ((byte_size == 0) && (width_byteena != 0)) ? 
                            ((((width / width_byteena) == 5) || (width / width_byteena == 10) || (width / width_byteena == 8) || (width / width_byteena == 9)) ? width / width_byteena : 5 )
                            : byte_size;
    parameter is_lutram = ((ram_block_type == "LUTRAM") || (ram_block_type == "MLAB"))? 1 : 0;
    parameter i_width_byteena = ((width_byteena == 0) && (i_byte_size != 0)) ? width / byte_size : width_byteena;
    parameter i_read_during_write = ((rdaddress_reg == "INCLOCK") && (wrcontrol_reg == "INCLOCK") && (outdata_reg == "INCLOCK")) ?
                                    read_during_write_mode_mixed_ports : "NEW_DATA";
    parameter write_at_low_clock = ((wrcontrol_reg == "INCLOCK") &&
                                    (((lpm_hint == "USE_EAB=ON") && (use_eab != "OFF")) || 
                                    (use_eab == "ON") || 
                                    (is_lutram == 1))) ?
                                    1 : 0;

// LOCAL_PARAMETERS_END

// INPUT PORT DECLARATION
    input  wren;                 // Write enable input
    input  [width-1:0] data;     // Data input to the memory
    input  [widthad-1:0] wraddress; // Write address input to the memory
    input  inclock;              // Input or write clock
    input  inclocken;            // Clock enable for inclock
    input  rden;                 // Read enable input. Disable reading when low
    input  [widthad-1:0] rdaddress; // Write address input to the memory
    input  outclock;             // Output or read clock
    input  outclocken;           // Clock enable for outclock
    input  aclr;                 // Asynchronous clear input
    input  wraddressstall;              // Address stall input for write port
    input  rdaddressstall;              // Address stall input for read port
    input  [i_width_byteena-1:0] byteena; // Byteena mask input

// OUTPUT PORT DECLARATION
    output [width-1:0] q;        // Data output from the memory

// INTERNAL SIGNAL/REGISTER DECLARATION
    reg [width-1:0] mem_data [0:(1<<widthad)-1];
    reg [8*256:1] ram_initf;
    reg [width-1:0] data_write_at_high;
    reg [width-1:0] data_write_at_low;
    reg [widthad-1:0] wraddress_at_high;
    reg [widthad-1:0] wraddress_at_low;
    reg [width-1:0] mem_output;
    reg [width-1:0] mem_output_at_outclock;
    reg [width-1:0] mem_output_at_inclock;
    reg [widthad-1:0] rdaddress_at_inclock;
    reg [widthad-1:0] rdaddress_at_inclock_low;
    reg [widthad-1:0] rdaddress_at_outclock;
    reg wren_at_high;
    reg wren_at_low;
    reg rden_at_inclock;
    reg rden_at_outclock;
    reg [width-1:0] i_byteena_mask;
    reg [width-1:0] i_byteena_mask_at_low;
    reg [width-1:0] i_byteena_mask_out;
    reg [width-1:0] i_byteena_mask_x;
    reg [width-1:0] i_lutram_output_reg_inclk;
    reg [width-1:0] i_lutram_output_reg_outclk;
    reg [width-1:0] i_old_data;
    reg rden_low_output_0;
    reg first_clk_rising_edge;
    reg is_stxiii_style_ram;
    reg is_stxv_style_ram;

// INTERNAL WIRE DECLARATION
    wire aclr_on_wraddress;
    wire aclr_on_wrcontrol;
    wire aclr_on_rdaddress;
    wire aclr_on_rdcontrol;
    wire aclr_on_indata;
    wire aclr_on_outdata;
    wire [width-1:0] data_tmp;
    wire [width-1:0] previous_read_data;
    wire [width-1:0] new_read_data;
    wire [widthad-1:0] wraddress_tmp;
    wire [widthad-1:0] rdaddress_tmp;
    wire wren_tmp;
    wire rden_tmp;
    wire [width-1:0] byteena_tmp;
    wire [width-1:0] i_lutram_output;
    wire [width-1:0] i_lutram_output_unreg;

// INTERNAL TRI DECLARATION
    tri1 inclock;
    tri1 inclocken;
    tri1 outclock;
    tri1 outclocken;
    tri1 rden;
    tri0 aclr;
    tri0 wraddressstall;
    tri0 rdaddressstall;
    tri1 [i_width_byteena-1:0] i_byteena;

// LOCAL INTEGER DECLARATION
    integer i;
    integer i_numwords;
    integer iter_byteena;

// COMPONENT INSTANTIATIONS
    ALTERA_DEVICE_FAMILIES dev ();
    ALTERA_MF_MEMORY_INITIALIZATION mem ();

// INITIAL CONSTRUCT BLOCK
    initial
    begin

        // Check for invalid parameters
        if (width <= 0)
        begin
            $display("Error! width parameter must be greater than 0.");
            $display ("Time: %0t  Instance: %m", $time);
            $stop;
        end
        if (widthad <= 0)
        begin
            $display("Error! widthad parameter must be greater than 0.");
            $display ("Time: %0t  Instance: %m", $time);
            $stop;
        end

        is_stxiii_style_ram = dev.FEATURE_FAMILY_STRATIXIII(intended_device_family);
        is_stxv_style_ram = dev.FEATURE_FAMILY_STRATIXV(intended_device_family);

        if ((indata_aclr == "ON") && ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)))
        begin
            $display("Warning: %s device family does not support aclr on input data. Aclr on this port will be ignored.", intended_device_family);
            $display ("Time: %0t  Instance: %m", $time);
        end

        if ((wraddress_aclr == "ON") && ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)))
        begin
            $display("Warning: %s device family does not support aclr on write address. Aclr on this port will be ignored.", intended_device_family);
            $display ("Time: %0t  Instance: %m", $time);
        end

        if ((wrcontrol_aclr == "ON") && ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)))
        begin
            $display("Warning: %s device family does not support aclr on write control. Aclr on this port will be ignored.", intended_device_family);
            $display ("Time: %0t  Instance: %m", $time);
        end
        if ((rdcontrol_aclr == "ON") && ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)))
        begin
            $display("Warning: %s device family does not have read control (rden). Parameter rdcontrol_aclr will be ignored.", intended_device_family);
            $display ("Time: %0t  Instance: %m", $time);
        end
        
        if ((rdaddress_aclr == "ON") && ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)) && (read_during_write_mode_mixed_ports == "OLD_DATA"))
        begin
            $display("Warning: rdaddress_aclr cannot be turned on when it is %s with read_during_write_mode_mixed_ports = OLD_DATA", intended_device_family);
            $display ("Time: %0t  Instance: %m", $time);
        end

        if (((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)) && (wrcontrol_reg != "INCLOCK"))
        begin
            $display("Warning: wrcontrol_reg can only be INCLOCK for %s device family", intended_device_family);
            $display ("Time: %0t  Instance: %m", $time);
        end
        
        if (((((width / width_byteena) == 5) || (width / width_byteena == 10) || (width / width_byteena == 8) || (width / width_byteena == 9)) && (byte_size == 0)) && ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)))
        begin
            $display("Warning : byte_size (width / width_byteena) should be in 5,8,9 or 10. It will be default to 5.");
            $display ("Time: %0t  Instance: %m", $time);
        end

        // Initialize mem_data
        i_numwords = (numwords) ? numwords : 1<<widthad;
        if (lpm_file == "UNUSED")
            for (i=0; i<i_numwords; i=i+1)
                mem_data[i] = 0;
        else
        begin
`ifdef NO_PLI
            $readmemh(lpm_file, mem_data);
`else
    `ifdef USE_RIF
            $readmemh(lpm_file, mem_data);
    `else
            mem.convert_to_ver_file(lpm_file, width, ram_initf);
            $readmemh(ram_initf, mem_data);
    `endif            
`endif
        end

        // Power-up conditions
        mem_output = 0;
        mem_output_at_outclock = 0;
        mem_output_at_inclock = 0;
        data_write_at_high = 0;
        data_write_at_low = 0;
        rdaddress_at_inclock = 0;
        rdaddress_at_inclock_low = 0;
        rdaddress_at_outclock = 0;
        rden_at_outclock = 1;
        rden_at_inclock = 1;
        i_byteena_mask = {width{1'b1}};
        i_byteena_mask_at_low = {width{1'b1}};
        i_byteena_mask_x = {width{1'bx}};
        wren_at_low = 0;
        wren_at_high = 0;
        i_lutram_output_reg_inclk = 0;
        i_lutram_output_reg_outclk = 0;
        wraddress_at_low = 0;
        wraddress_at_high = 0;
        i_old_data = 0;
        
        rden_low_output_0 = 0;
        first_clk_rising_edge = 1;
    end


// ALWAYS CONSTRUCT BLOCKS

    // Set up logics that respond to the postive edge of inclock
    // some logics may be affected by Asynchronous Clear
    always @(posedge inclock)
    begin
        if ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1))
        begin
                if (inclocken == 1)
                begin
                    data_write_at_high <= data;
                    wren_at_high <= wren;

                    if (wraddressstall == 0)
                            wraddress_at_high <= wraddress;
                end
        end
        else
        begin
                if ((aclr == 1) && (indata_aclr == "ON") && (indata_reg != "UNREGISTERED") )
                    data_write_at_high <= 0;
                else if (inclocken == 1)
                    data_write_at_high <= data;

                if ((aclr == 1) && (wraddress_aclr == "ON") && (wraddress_reg != "UNREGISTERED") )
                    wraddress_at_high <= 0;
                else if ((inclocken == 1) && (wraddressstall == 0))
                    wraddress_at_high <= wraddress;

                if ((aclr == 1) && (wrcontrol_aclr == "ON") && (wrcontrol_reg != "UNREGISTERED")  )
                    wren_at_high <= 0;
                else if (inclocken == 1)
                    wren_at_high <= wren;
        end

        if (aclr_on_rdaddress)
            rdaddress_at_inclock <= 0;
        else if ((inclocken == 1) && (rdaddressstall == 0))
            rdaddress_at_inclock <= rdaddress;

        if ((aclr == 1) && (rdcontrol_aclr == "ON") && (rdcontrol_reg != "UNREGISTERED") )
            rden_at_inclock <= 0;
        else if (inclocken == 1)
            rden_at_inclock <= rden;

        if ((aclr == 1) && (outdata_aclr == "ON") && (outdata_reg == "INCLOCK") )
            mem_output_at_inclock <= 0;
        else if (inclocken == 1)
        begin
            mem_output_at_inclock <= mem_output;
        end

        if (inclocken == 1)
        begin
            if (i_width_byteena == 1)
            begin
                i_byteena_mask <= {width{i_byteena[0]}};
                i_byteena_mask_out <= (i_byteena[0]) ? {width{1'b0}} : {width{1'bx}};
                i_byteena_mask_x <= ((i_byteena[0]) || (i_byteena[0] == 1'b0)) ? {width{1'bx}} : {width{1'b0}};
            end
            else
            begin
                for (iter_byteena = 0; iter_byteena < width; iter_byteena = iter_byteena + 1)
                begin
                    i_byteena_mask[iter_byteena] <= i_byteena[iter_byteena/i_byte_size];
                    i_byteena_mask_out[iter_byteena] <= (i_byteena[iter_byteena/i_byte_size])? 1'b0 : 1'bx;
                    i_byteena_mask_x[iter_byteena] <= ((i_byteena[iter_byteena/i_byte_size]) || (i_byteena[iter_byteena/i_byte_size] == 1'b0)) ? 1'bx : 1'b0;
                end
            end
            
        end

        if ((aclr == 1) && (outdata_aclr == "ON") && (outdata_reg == "INCLOCK") )
            i_lutram_output_reg_inclk <= 0;
        else
            if (inclocken == 1)
            begin
                if ((wren_tmp == 1) && (wraddress_tmp == rdaddress_tmp))
                begin
                    if (i_read_during_write == "NEW_DATA") 
                        i_lutram_output_reg_inclk <=  (i_read_during_write == "NEW_DATA") ? mem_data[rdaddress_tmp] :
                                        ((rdaddress_tmp == wraddress_tmp) && wren_tmp) ?
                                        mem_data[rdaddress_tmp] ^ i_byteena_mask_x : mem_data[rdaddress_tmp];
                    else if (i_read_during_write == "OLD_DATA")
                        i_lutram_output_reg_inclk <= i_old_data;
                    else
                        i_lutram_output_reg_inclk <= {width{1'bx}};
                end
                else if ((!first_clk_rising_edge) || (i_read_during_write != "OLD_DATA"))
                    i_lutram_output_reg_inclk <= mem_data[rdaddress_tmp];
            
                first_clk_rising_edge <= 0;
            end
    end

    // Set up logics that respond to the negative edge of inclock
    // some logics may be affected by Asynchronous Clear
    always @(negedge inclock)
    begin
        if ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1))
        begin
                if (inclocken == 1)
                begin
                    data_write_at_low <= data_write_at_high;
                    wraddress_at_low <= wraddress_at_high;
                    wren_at_low <= wren_at_high;
                end

        end
        else
        begin
                if ((aclr == 1) && (indata_aclr == "ON")  && (indata_reg != "UNREGISTERED")  )
                    data_write_at_low <= 0;
                else if (inclocken == 1)
                    data_write_at_low <= data_write_at_high;

                if ((aclr == 1) && (wraddress_aclr == "ON") && (wraddress_reg != "UNREGISTERED")  )
                    wraddress_at_low <= 0;
                else if (inclocken == 1)
                    wraddress_at_low <= wraddress_at_high;

                if ((aclr == 1) && (wrcontrol_aclr == "ON") && (wrcontrol_reg != "UNREGISTERED")  )
                    wren_at_low <= 0;
                else if (inclocken == 1)
                    wren_at_low <= wren_at_high;

        end

        if (inclocken == 1)
            begin
            i_byteena_mask_at_low <= i_byteena_mask;
        end
        
        if (inclocken == 1)
            rdaddress_at_inclock_low <= rdaddress_at_inclock;


    end

    // Set up logics that respond to the positive edge of outclock
    // some logics may be affected by Asynchronous Clear
    always @(posedge outclock)
    begin
        if (aclr_on_rdaddress)
            rdaddress_at_outclock <= 0;
        else if ((outclocken == 1) && (rdaddressstall == 0))
            rdaddress_at_outclock <= rdaddress;

        if ((aclr == 1) && (rdcontrol_aclr == "ON") && (rdcontrol_reg != "UNREGISTERED") )
            rden_at_outclock <= 0;
        else if (outclocken == 1)
            rden_at_outclock <= rden;

        if ((aclr == 1) && (outdata_aclr == "ON") && (outdata_reg == "OUTCLOCK") )
        begin
            mem_output_at_outclock <= 0;
            i_lutram_output_reg_outclk <= 0;
        end
        else if (outclocken == 1)
        begin
            mem_output_at_outclock <= mem_output;
            i_lutram_output_reg_outclk <= mem_data[rdaddress_tmp];
        end
            
    end

    // Asynchronous Logic
    // Update memory with the latest data
    always @(data_tmp or wraddress_tmp or wren_tmp or byteena_tmp)
    begin
        if (wren_tmp == 1)
        begin
            if ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1))
            begin
                i_old_data <= mem_data[wraddress_tmp];
                mem_data[wraddress_tmp] <= ((data_tmp & byteena_tmp) | (mem_data[wraddress_tmp] & ~byteena_tmp));
            end
            else
                mem_data[wraddress_tmp] <= data_tmp;
        end
    end

    always @(new_read_data)
    begin
        mem_output <= new_read_data;
    end

// CONTINUOUS ASSIGNMENT

    assign i_byteena = byteena;

    // The following circuits will select for appropriate connections based on
    // the given parameter values

    assign aclr_on_wraddress = ((wraddress_aclr == "ON") ?
                                aclr : 1'b0);

    assign aclr_on_wrcontrol = ((wrcontrol_aclr == "ON") ?
                                aclr : 1'b0);

    assign aclr_on_rdaddress = (((rdaddress_aclr == "ON") && (rdaddress_reg != "UNREGISTERED") &&
                                !(((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)) && (read_during_write_mode_mixed_ports == "OLD_DATA"))) ?
                                aclr : 1'b0);

    assign aclr_on_rdcontrol = (((rdcontrol_aclr == "ON") && (is_stxv_style_ram != 1) && (is_stxiii_style_ram != 1)) ?
                                aclr : 1'b0);

    assign aclr_on_indata = ((indata_aclr == "ON") ?
                                aclr : 1'b0);

    assign aclr_on_outdata = ((outdata_aclr == "ON") ?
                                aclr : 1'b0);

    assign data_tmp = ((indata_reg == "INCLOCK") ?
                            (write_at_low_clock ?
                            ((aclr_on_indata == 1) ?
                            {width{1'b0}} : data_write_at_low)
                            : ((aclr_on_indata == 1) ?
                            {width{1'b0}} : data_write_at_high))
                            : data);

    assign wraddress_tmp = ((wraddress_reg == "INCLOCK") ?
                            (write_at_low_clock ?
                            ((aclr_on_wraddress == 1) ?
                            {widthad{1'b0}} : wraddress_at_low)
                            : ((aclr_on_wraddress == 1) ?
                            {widthad{1'b0}} : wraddress_at_high))
                            : wraddress);

    assign wren_tmp = ((wrcontrol_reg == "INCLOCK") ?
                        (write_at_low_clock ?
                        ((aclr_on_wrcontrol == 1) ?
                        1'b0 : wren_at_low)
                        : ((aclr_on_wrcontrol == 1) ? 
                        1'b0 : wren_at_high))
                        : wren);

    assign rdaddress_tmp = ((rdaddress_reg == "INCLOCK") ?
                            ((((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)) && (i_read_during_write == "OLD_DATA")) ?
                            rdaddress_at_inclock_low : 
                            ((aclr_on_rdaddress == 1) ?
                            {widthad{1'b0}} : rdaddress_at_inclock))
                            : ((rdaddress_reg == "OUTCLOCK") ?
                            ((aclr_on_rdaddress == 1) ? {widthad{1'b0}} : rdaddress_at_outclock)
                            : rdaddress));

    assign rden_tmp =  ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)) ?
                        1'b1 : ((rdcontrol_reg == "INCLOCK") ?
                        ((aclr_on_rdcontrol == 1) ?
                        1'b0 : rden_at_inclock)
                        : ((rdcontrol_reg == "OUTCLOCK") ?
                        ((aclr_on_rdcontrol == 1) ? 1'b0 : rden_at_outclock)
                        : rden));

    assign byteena_tmp = i_byteena_mask_at_low;

    assign previous_read_data = mem_output;

    assign new_read_data = ((rden_tmp == 1) ?
                                mem_data[rdaddress_tmp]
                                : ((rden_low_output_0) ?
                                {width{1'b0}} : previous_read_data));

    assign i_lutram_output_unreg = mem_data[rdaddress_tmp];
    
    assign i_lutram_output = ((outdata_reg == "INCLOCK")) ? 
                                i_lutram_output_reg_inclk : 
                                ((outdata_reg == "OUTCLOCK") ? i_lutram_output_reg_outclk : i_lutram_output_unreg);
    
    assign q = (aclr_on_outdata == 1) ? {width{1'b0}} :
                ((is_stxv_style_ram) || (is_stxiii_style_ram == 1)) ?  i_lutram_output : 
                ((outdata_reg == "OUTCLOCK") ? mem_output_at_outclock : ((outdata_reg == "INCLOCK") ?
                mem_output_at_inclock : mem_output));

endmodule // altdpram

// START_MODULE_NAME------------------------------------------------------------
//
// Module Name     : ALTSYNCRAM
//
// Description     : Synchronous ram model for Stratix series family
//
// Limitation      :
//
// END_MODULE_NAME--------------------------------------------------------------

`timescale 1 ps / 1 ps

// BEGINNING OF MODULE

// MODULE DECLARATION

module altsyncram   (
                    wren_a,
                    wren_b,
                    rden_a,
                    rden_b,
                    data_a,
                    data_b,
                    address_a,
                    address_b,
                    clock0,
                    clock1,
                    clocken0,
                    clocken1,
                    clocken2,
                    clocken3,
                    aclr0,
                    aclr1,
                    byteena_a,
                    byteena_b,
                    addressstall_a,
                    addressstall_b,
                    q_a,
                    q_b,
                    eccstatus
                    );

// GLOBAL PARAMETER DECLARATION

    // PORT A PARAMETERS
    parameter width_a          = 1;
    parameter widthad_a        = 1;
    parameter numwords_a       = 0;
    parameter outdata_reg_a    = "UNREGISTERED";
    parameter address_aclr_a   = "NONE";
    parameter outdata_aclr_a   = "NONE";
    parameter indata_aclr_a    = "NONE";
    parameter wrcontrol_aclr_a = "NONE";
    parameter byteena_aclr_a   = "NONE";
    parameter width_byteena_a  = 1;

    // PORT B PARAMETERS
    parameter width_b                   = 1;
    parameter widthad_b                 = 1;
    parameter numwords_b                = 0;
    parameter rdcontrol_reg_b           = "CLOCK1";
    parameter address_reg_b             = "CLOCK1";
    parameter outdata_reg_b             = "UNREGISTERED";
    parameter outdata_aclr_b            = "NONE";
    parameter rdcontrol_aclr_b          = "NONE";
    parameter indata_reg_b              = "CLOCK1";
    parameter wrcontrol_wraddress_reg_b = "CLOCK1";
    parameter byteena_reg_b             = "CLOCK1";
    parameter indata_aclr_b             = "NONE";
    parameter wrcontrol_aclr_b          = "NONE";
    parameter address_aclr_b            = "NONE";
    parameter byteena_aclr_b            = "NONE";
    parameter width_byteena_b           = 1;

    // STRATIX II RELATED PARAMETERS
    parameter clock_enable_input_a  = "NORMAL";
    parameter clock_enable_output_a = "NORMAL";
    parameter clock_enable_input_b  = "NORMAL";
    parameter clock_enable_output_b = "NORMAL";

    parameter clock_enable_core_a = "USE_INPUT_CLKEN";
    parameter clock_enable_core_b = "USE_INPUT_CLKEN";
    parameter read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ";
    parameter read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ";

    // ECC STATUS RELATED PARAMETERS
    parameter enable_ecc = "FALSE";
    parameter width_eccstatus = 3;

    // GLOBAL PARAMETERS
    parameter operation_mode                     = "BIDIR_DUAL_PORT";
    parameter byte_size                          = 0;
    parameter read_during_write_mode_mixed_ports = "DONT_CARE";
    parameter ram_block_type                     = "AUTO";
    parameter init_file                          = "UNUSED";
    parameter init_file_layout                   = "UNUSED";
    parameter maximum_depth                      = 0;
    parameter intended_device_family             = "Stratix";

    parameter lpm_hint                           = "UNUSED";
    parameter lpm_type                           = "altsyncram";

    parameter implement_in_les                 = "OFF";
    
    parameter power_up_uninitialized            = "FALSE";
    
// SIMULATION_ONLY_PARAMETERS_BEGIN

    parameter sim_show_memory_data_in_port_b_layout  = "OFF";

// SIMULATION_ONLY_PARAMETERS_END
    
// LOCAL_PARAMETERS_BEGIN
    
    parameter is_lutram = ((ram_block_type == "LUTRAM") || (ram_block_type == "MLAB"))? 1 : 0;
    
    parameter is_bidir_and_wrcontrol_addb_clk0 =    (((operation_mode == "BIDIR_DUAL_PORT") && (address_reg_b == "CLOCK0"))? 
                                                    1 : 0);

    parameter is_bidir_and_wrcontrol_addb_clk1 =    (((operation_mode == "BIDIR_DUAL_PORT") && (address_reg_b == "CLOCK1"))? 
                                                    1 : 0);

    parameter check_simultaneous_read_write =   (((operation_mode == "BIDIR_DUAL_PORT") || (operation_mode == "DUAL_PORT")) && 
                                                ((ram_block_type == "M-RAM") || 
                                                    (ram_block_type == "MEGARAM") || 
                                                    ((ram_block_type == "AUTO") && (read_during_write_mode_mixed_ports == "DONT_CARE")) ||
                                                    ((is_lutram == 1) && ((read_during_write_mode_mixed_ports != "OLD_DATA") || (outdata_reg_b == "UNREGISTERED")))))? 1 : 0;

    parameter dual_port_addreg_b_clk0 = (((operation_mode == "DUAL_PORT") && (address_reg_b == "CLOCK0"))? 1: 0);

    parameter dual_port_addreg_b_clk1 = (((operation_mode == "DUAL_PORT") && (address_reg_b == "CLOCK1"))? 1: 0);

    parameter i_byte_size_tmp = (width_byteena_a > 1)? width_a / width_byteena_a : 8;
    
    parameter i_lutram_read = (((is_lutram == 1) && (read_during_write_mode_port_a == "DONT_CARE")) ||
                                ((is_lutram == 1) && (outdata_reg_a == "UNREGISTERED") && (operation_mode == "SINGLE_PORT")))? 1 : 0;

    parameter enable_mem_data_b_reading =  (sim_show_memory_data_in_port_b_layout == "ON") && ((operation_mode == "BIDIR_DUAL_PORT") || (operation_mode == "DUAL_PORT")) ? 1 : 0;

   parameter family_stratixv = ((intended_device_family == "Stratix V") || (intended_device_family == "STRATIX V") || (intended_device_family == "stratix v") || (intended_device_family == "StratixV") || (intended_device_family == "STRATIXV") || (intended_device_family == "stratixv") || (intended_device_family == "Stratix V (GS)") || (intended_device_family == "STRATIX V (GS)") || (intended_device_family == "stratix v (gs)") || (intended_device_family == "StratixV(GS)") || (intended_device_family == "STRATIXV(GS)") || (intended_device_family == "stratixv(gs)") || (intended_device_family == "Stratix V (GX)") || (intended_device_family == "STRATIX V (GX)") || (intended_device_family == "stratix v (gx)") || (intended_device_family == "StratixV(GX)") || (intended_device_family == "STRATIXV(GX)") || (intended_device_family == "stratixv(gx)") || (intended_device_family == "Stratix V (GS/GX)") || (intended_device_family == "STRATIX V (GS/GX)") || (intended_device_family == "stratix v (gs/gx)") || (intended_device_family == "StratixV(GS/GX)") || (intended_device_family == "STRATIXV(GS/GX)") || (intended_device_family == "stratixv(gs/gx)") || (intended_device_family == "Stratix V (GX/GS)") || (intended_device_family == "STRATIX V (GX/GS)") || (intended_device_family == "stratix v (gx/gs)") || (intended_device_family == "StratixV(GX/GS)") || (intended_device_family == "STRATIXV(GX/GS)") || (intended_device_family == "stratixv(gx/gs)")) ? 1 : 0;
    
   parameter family_hardcopyiv = ((intended_device_family == "HardCopy IV") || (intended_device_family == "HARDCOPY IV") || (intended_device_family == "hardcopy iv") || (intended_device_family == "HardCopyIV") || (intended_device_family == "HARDCOPYIV") || (intended_device_family == "hardcopyiv") || (intended_device_family == "HardCopy IV (GX)") || (intended_device_family == "HARDCOPY IV (GX)") || (intended_device_family == "hardcopy iv (gx)") || (intended_device_family == "HardCopy IV (E)") || (intended_device_family == "HARDCOPY IV (E)") || (intended_device_family == "hardcopy iv (e)") || (intended_device_family == "HardCopyIV(GX)") || (intended_device_family == "HARDCOPYIV(GX)") || (intended_device_family == "hardcopyiv(gx)") || (intended_device_family == "HardCopyIV(E)") || (intended_device_family == "HARDCOPYIV(E)") || (intended_device_family == "hardcopyiv(e)") || (intended_device_family == "HCXIV") || (intended_device_family == "hcxiv") || (intended_device_family == "HardCopy IV (GX/E)") || (intended_device_family == "HARDCOPY IV (GX/E)") || (intended_device_family == "hardcopy iv (gx/e)") || (intended_device_family == "HardCopy IV (E/GX)") || (intended_device_family == "HARDCOPY IV (E/GX)") || (intended_device_family == "hardcopy iv (e/gx)") || (intended_device_family == "HardCopyIV(GX/E)") || (intended_device_family == "HARDCOPYIV(GX/E)") || (intended_device_family == "hardcopyiv(gx/e)") || (intended_device_family == "HardCopyIV(E/GX)") || (intended_device_family == "HARDCOPYIV(E/GX)") || (intended_device_family == "hardcopyiv(e/gx)")) ? 1 : 0 ;
   
   parameter family_hardcopyiii = ((intended_device_family == "HardCopy III") || (intended_device_family == "HARDCOPY III") || (intended_device_family == "hardcopy iii") || (intended_device_family == "HardCopyIII") || (intended_device_family == "HARDCOPYIII") || (intended_device_family == "hardcopyiii") || (intended_device_family == "HCX") || (intended_device_family == "hcx")) ? 1 : 0;
   
   parameter family_hardcopyii = ((intended_device_family == "HardCopy II") || (intended_device_family == "HARDCOPY II") || (intended_device_family == "hardcopy ii") || (intended_device_family == "HardCopyII") || (intended_device_family == "HARDCOPYII") || (intended_device_family == "hardcopyii") || (intended_device_family == "Fusion") || (intended_device_family == "FUSION") || (intended_device_family == "fusion")) ? 1 : 0 ;
   
   parameter family_arriaiigz = ((intended_device_family == "Arria II GZ") || (intended_device_family == "ARRIA II GZ") || (intended_device_family == "arria ii gz") || (intended_device_family == "ArriaII GZ") || (intended_device_family == "ARRIAII GZ") || (intended_device_family == "arriaii gz") || (intended_device_family == "Arria IIGZ") || (intended_device_family == "ARRIA IIGZ") || (intended_device_family == "arria iigz") || (intended_device_family == "ArriaIIGZ") || (intended_device_family == "ARRIAIIGZ") || (intended_device_family == "arriaii gz")) ? 1 : 0 ;

   parameter family_arriaiigx = ((intended_device_family == "Arria II GX") || (intended_device_family == "ARRIA II GX") || (intended_device_family == "arria ii gx") || (intended_device_family == "ArriaIIGX") || (intended_device_family == "ARRIAIIGX") || (intended_device_family == "arriaiigx") || (intended_device_family == "Arria IIGX") || (intended_device_family == "ARRIA IIGX") || (intended_device_family == "arria iigx") || (intended_device_family == "ArriaII GX") || (intended_device_family == "ARRIAII GX") || (intended_device_family == "arriaii gx") || (intended_device_family == "Arria II") || (intended_device_family == "ARRIA II") || (intended_device_family == "arria ii") || (intended_device_family == "ArriaII") || (intended_device_family == "ARRIAII") || (intended_device_family == "arriaii") || (intended_device_family == "Arria II (GX/E)") || (intended_device_family == "ARRIA II (GX/E)") || (intended_device_family == "arria ii (gx/e)") || (intended_device_family == "ArriaII(GX/E)") || (intended_device_family == "ARRIAII(GX/E)") || (intended_device_family == "arriaii(gx/e)") || (intended_device_family == "PIRANHA") || (intended_device_family == "piranha")) ? 1 : 0 ;

   parameter family_stratixiii = ((intended_device_family == "Stratix III") || (intended_device_family == "STRATIX III") || (intended_device_family == "stratix iii") || (intended_device_family == "StratixIII") || (intended_device_family == "STRATIXIII") || (intended_device_family == "stratixiii") || (intended_device_family == "Titan") || (intended_device_family == "TITAN") || (intended_device_family == "titan") || (intended_device_family == "SIII") || (intended_device_family == "siii") || (intended_device_family == "Stratix IV") || (intended_device_family == "STRATIX IV") || (intended_device_family == "stratix iv") || (intended_device_family == "TGX") || (intended_device_family == "tgx") || (intended_device_family == "StratixIV") || (intended_device_family == "STRATIXIV") || (intended_device_family == "stratixiv") || (intended_device_family == "Stratix IV (GT)") || (intended_device_family == "STRATIX IV (GT)") || (intended_device_family == "stratix iv (gt)") || (intended_device_family == "Stratix IV (GX)") || (intended_device_family == "STRATIX IV (GX)") || (intended_device_family == "stratix iv (gx)") || (intended_device_family == "Stratix IV (E)") || (intended_device_family == "STRATIX IV (E)") || (intended_device_family == "stratix iv (e)") || (intended_device_family == "StratixIV(GT)") || (intended_device_family == "STRATIXIV(GT)") || (intended_device_family == "stratixiv(gt)") || (intended_device_family == "StratixIV(GX)") || (intended_device_family == "STRATIXIV(GX)") || (intended_device_family == "stratixiv(gx)") || (intended_device_family == "StratixIV(E)") || (intended_device_family == "STRATIXIV(E)") || (intended_device_family == "stratixiv(e)") || (intended_device_family == "StratixIIIGX") || (intended_device_family == "STRATIXIIIGX") || (intended_device_family == "stratixiiigx") || (intended_device_family == "Stratix IV (GT/GX/E)") || (intended_device_family == "STRATIX IV (GT/GX/E)") || (intended_device_family == "stratix iv (gt/gx/e)") || (intended_device_family == "Stratix IV (GT/E/GX)") || (intended_device_family == "STRATIX IV (GT/E/GX)") || (intended_device_family == "stratix iv (gt/e/gx)") || (intended_device_family == "Stratix IV (E/GT/GX)") || (intended_device_family == "STRATIX IV (E/GT/GX)") || (intended_device_family == "stratix iv (e/gt/gx)") || (intended_device_family == "Stratix IV (E/GX/GT)") || (intended_device_family == "STRATIX IV (E/GX/GT)") || (intended_device_family == "stratix iv (e/gx/gt)") || (intended_device_family == "StratixIV(GT/GX/E)") || (intended_device_family == "STRATIXIV(GT/GX/E)") || (intended_device_family == "stratixiv(gt/gx/e)") || (intended_device_family == "StratixIV(GT/E/GX)") || (intended_device_family == "STRATIXIV(GT/E/GX)") || (intended_device_family == "stratixiv(gt/e/gx)") || (intended_device_family == "StratixIV(E/GX/GT)") || (intended_device_family == "STRATIXIV(E/GX/GT)") || (intended_device_family == "stratixiv(e/gx/gt)") || (intended_device_family == "StratixIV(E/GT/GX)") || (intended_device_family == "STRATIXIV(E/GT/GX)") || (intended_device_family == "stratixiv(e/gt/gx)") || (intended_device_family == "Stratix IV (GX/E)") || (intended_device_family == "STRATIX IV (GX/E)") || (intended_device_family == "stratix iv (gx/e)") || (intended_device_family == "StratixIV(GX/E)") || (intended_device_family == "STRATIXIV(GX/E)") || (intended_device_family == "stratixiv(gx/e)") || (family_arriaiigx == 1) || (family_hardcopyiv == 1) || (family_hardcopyiii == 1) || (family_stratixv == 1) || (family_arriaiigz == 1)) ? 1 : 0 ;
   
   parameter family_cycloneiii = ((intended_device_family == "Cyclone III") || (intended_device_family == "CYCLONE III") || (intended_device_family == "cyclone iii") || (intended_device_family == "CycloneIII") || (intended_device_family == "CYCLONEIII") || (intended_device_family == "cycloneiii") || (intended_device_family == "Barracuda") || (intended_device_family == "BARRACUDA") || (intended_device_family == "barracuda") || (intended_device_family == "Cuda") || (intended_device_family == "CUDA") || (intended_device_family == "cuda") || (intended_device_family == "CIII") || (intended_device_family == "ciii") || (intended_device_family == "Cyclone III LS") || (intended_device_family == "CYCLONE III LS") || (intended_device_family == "cyclone iii ls") || (intended_device_family == "CycloneIIILS") || (intended_device_family == "CYCLONEIIILS") || (intended_device_family == "cycloneiiils") || (intended_device_family == "Cyclone III LPS") || (intended_device_family == "CYCLONE III LPS") || (intended_device_family == "cyclone iii lps") || (intended_device_family == "Cyclone LPS") || (intended_device_family == "CYCLONE LPS") || (intended_device_family == "cyclone lps") || (intended_device_family == "CycloneLPS") || (intended_device_family == "CYCLONELPS") || (intended_device_family == "cyclonelps") || (intended_device_family == "Tarpon") || (intended_device_family == "TARPON") || (intended_device_family == "tarpon") || (intended_device_family == "Cyclone IIIE") || (intended_device_family == "CYCLONE IIIE") || (intended_device_family == "cyclone iiie") || (intended_device_family == "Cyclone IV GX") || (intended_device_family == "CYCLONE IV GX") || (intended_device_family == "cyclone iv gx") || (intended_device_family == "Cyclone IVGX") || (intended_device_family == "CYCLONE IVGX") || (intended_device_family == "cyclone ivgx") || (intended_device_family == "CycloneIV GX") || (intended_device_family == "CYCLONEIV GX") || (intended_device_family == "cycloneiv gx") || (intended_device_family == "CycloneIVGX") || (intended_device_family == "CYCLONEIVGX") || (intended_device_family == "cycloneivgx") || (intended_device_family == "Cyclone IV") || (intended_device_family == "CYCLONE IV") || (intended_device_family == "cyclone iv") || (intended_device_family == "CycloneIV") || (intended_device_family == "CYCLONEIV") || (intended_device_family == "cycloneiv") || (intended_device_family == "Cyclone IV (GX)") || (intended_device_family == "CYCLONE IV (GX)") || (intended_device_family == "cyclone iv (gx)") || (intended_device_family == "CycloneIV(GX)") || (intended_device_family == "CYCLONEIV(GX)") || (intended_device_family == "cycloneiv(gx)") || (intended_device_family == "Cyclone III GX") || (intended_device_family == "CYCLONE III GX") || (intended_device_family == "cyclone iii gx") || (intended_device_family == "CycloneIII GX") || (intended_device_family == "CYCLONEIII GX") || (intended_device_family == "cycloneiii gx") || (intended_device_family == "Cyclone IIIGX") || (intended_device_family == "CYCLONE IIIGX") || (intended_device_family == "cyclone iiigx") || (intended_device_family == "CycloneIIIGX") || (intended_device_family == "CYCLONEIIIGX") || (intended_device_family == "cycloneiiigx") || (intended_device_family == "Cyclone III GL") || (intended_device_family == "CYCLONE III GL") || (intended_device_family == "cyclone iii gl") || (intended_device_family == "CycloneIII GL") || (intended_device_family == "CYCLONEIII GL") || (intended_device_family == "cycloneiii gl") || (intended_device_family == "Cyclone IIIGL") || (intended_device_family == "CYCLONE IIIGL") || (intended_device_family == "cyclone iiigl") || (intended_device_family == "CycloneIIIGL") || (intended_device_family == "CYCLONEIIIGL") || (intended_device_family == "cycloneiiigl") || (intended_device_family == "Stingray") || (intended_device_family == "STINGRAY") || (intended_device_family == "stingray") || (intended_device_family == "Cyclone IV E") || (intended_device_family == "CYCLONE IV E") || (intended_device_family == "cyclone iv e") || (intended_device_family == "CycloneIV E") || (intended_device_family == "CYCLONEIV E") || (intended_device_family == "cycloneiv e") || (intended_device_family == "Cyclone IVE") || (intended_device_family == "CYCLONE IVE") || (intended_device_family == "cyclone ive") || (intended_device_family == "CycloneIVE") || (intended_device_family == "CYCLONEIVE") || (intended_device_family == "cycloneive")) ? 1 : 0 ;

   parameter family_cyclone = ((intended_device_family == "Cyclone") || (intended_device_family == "CYCLONE") || (intended_device_family == "cyclone") || (intended_device_family == "ACEX2K") || (intended_device_family == "acex2k") || (intended_device_family == "ACEX 2K") || (intended_device_family == "acex 2k") || (intended_device_family == "Tornado") || (intended_device_family == "TORNADO") || (intended_device_family == "tornado")) ? 1 : 0 ;
   
   parameter family_base_cycloneii = ((intended_device_family == "Cyclone II") || (intended_device_family == "CYCLONE II") || (intended_device_family == "cyclone ii") || (intended_device_family == "Cycloneii") || (intended_device_family == "CYCLONEII") || (intended_device_family == "cycloneii") || (intended_device_family == "Magellan") || (intended_device_family == "MAGELLAN") || (intended_device_family == "magellan")) ? 1 : 0 ;
   
   parameter family_cycloneii = ((family_base_cycloneii == 1) || (family_cycloneiii == 1)) ? 1 : 0 ;
   
   parameter family_base_stratix = ((intended_device_family == "Stratix") || (intended_device_family == "STRATIX") || (intended_device_family == "stratix") || (intended_device_family == "Yeager") || (intended_device_family == "YEAGER") || (intended_device_family == "yeager") || (intended_device_family == "Stratix GX") || (intended_device_family == "STRATIX GX") || (intended_device_family == "stratix gx") || (intended_device_family == "Stratix-GX") || (intended_device_family == "STRATIX-GX") || (intended_device_family == "stratix-gx") || (intended_device_family == "StratixGX") || (intended_device_family == "STRATIXGX") || (intended_device_family == "stratixgx") || (intended_device_family == "Aurora") || (intended_device_family == "AURORA") || (intended_device_family == "aurora")) ? 1 : 0 ;
   
   parameter family_base_stratixii = ((intended_device_family == "Stratix II") || (intended_device_family == "STRATIX II") || (intended_device_family == "stratix ii") || (intended_device_family == "StratixII") || (intended_device_family == "STRATIXII") || (intended_device_family == "stratixii") || (intended_device_family == "Armstrong") || (intended_device_family == "ARMSTRONG") || (intended_device_family == "armstrong") || (intended_device_family == "Stratix II GX") || (intended_device_family == "STRATIX II GX") || (intended_device_family == "stratix ii gx") || (intended_device_family == "StratixIIGX") || (intended_device_family == "STRATIXIIGX") || (intended_device_family == "stratixiigx") || (intended_device_family == "Arria GX") || (intended_device_family == "ARRIA GX") || (intended_device_family == "arria gx") || (intended_device_family == "ArriaGX") || (intended_device_family == "ARRIAGX") || (intended_device_family == "arriagx") || (intended_device_family == "Stratix II GX Lite") || (intended_device_family == "STRATIX II GX LITE") || (intended_device_family == "stratix ii gx lite") || (intended_device_family == "StratixIIGXLite") || (intended_device_family == "STRATIXIIGXLITE") || (intended_device_family == "stratixiigxlite") || (family_hardcopyii == 1)) ? 1 : 0 ;
   
   parameter family_has_lutram = ((family_stratixiii == 1) || (family_stratixv == 1)) ? 1 : 0 ;
   parameter family_has_stratixv_style_ram = (family_stratixv == 1) ? 1 : 0 ;
   parameter family_has_stratixiii_style_ram = ((family_stratixiii == 1) || (family_cycloneiii == 1)) ? 1 : 0;

   parameter family_has_m512 = (((intended_device_family == "StratixHC") || (family_base_stratix == 1) || (family_base_stratixii == 1)) && (family_hardcopyii == 0)) ? 1 : 0;
   
   parameter family_has_megaram = (((intended_device_family == "StratixHC") || (family_base_stratix == 1) || (family_base_stratixii == 1) || (family_stratixiii == 1)) && (family_arriaiigx == 0) && (family_stratixv == 0)) ? 1 : 0 ;

   parameter family_has_stratixi_style_ram = ((intended_device_family == "StratixHC") || (family_base_stratix == 1) || (family_cyclone == 1)) ? 1 : 0;
   
   parameter is_write_on_positive_edge = (((ram_block_type == "M-RAM") || (ram_block_type == "MEGARAM")) || (ram_block_type == "M9K") || (ram_block_type == "M20K") || (ram_block_type == "M144K") || ((family_has_stratixv_style_ram == 1) && (is_lutram == 1)) || (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) && (ram_block_type == "AUTO"))) ? 1 : 0; 

   parameter lutram_single_port_fast_read = ((is_lutram == 1) && ((read_during_write_mode_port_a == "DONT_CARE") || (outdata_reg_a == "UNREGISTERED")) && (operation_mode == "SINGLE_PORT")) ? 1 : 0;
            
   parameter lutram_dual_port_fast_read = ((is_lutram == 1) && ((read_during_write_mode_mixed_ports == "NEW_DATA") || (read_during_write_mode_mixed_ports == "DONT_CARE") || ((read_during_write_mode_mixed_ports == "OLD_DATA") && (outdata_reg_b == "UNREGISTERED")))) ? 1 : 0;
            
   parameter s3_address_aclr_a =  ((family_stratixv || family_stratixiii) && (is_lutram != 1) && (outdata_reg_a != "CLOCK0") && (outdata_reg_a != "CLOCK1")) ? 1 : 0;

   parameter s3_address_aclr_b =  ((family_stratixv || family_stratixiii) && (is_lutram != 1) && (outdata_reg_b != "CLOCK0") && (outdata_reg_b != "CLOCK1")) ? 1 : 0;

   parameter i_address_aclr_family_a = ((((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) && (operation_mode != "ROM")) || (family_base_stratixii == 1 || family_base_cycloneii == 1)) ? 1 : 0;
    
   parameter i_address_aclr_family_b = ((((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) && (operation_mode != "DUAL_PORT")) || ((is_lutram == 1) && (operation_mode == "DUAL_PORT") && (read_during_write_mode_mixed_ports == "OLD_DATA")) || (family_base_stratixii == 1 || family_base_cycloneii == 1)) ? 1 : 0;

// LOCAL_PARAMETERS_END

// INPUT PORT DECLARATION

    input  wren_a; // Port A write/read enable input
    input  wren_b; // Port B write enable input
    input  rden_a; // Port A read enable input
    input  rden_b; // Port B read enable input
    input  [width_a-1:0] data_a; // Port A data input
    input  [width_b-1:0] data_b; // Port B data input
    input  [widthad_a-1:0] address_a; // Port A address input
    input  [widthad_b-1:0] address_b; // Port B address input

    // clock inputs on both ports and here are their usage
    // Port A -- 1. all input registers must be clocked by clock0.
    //           2. output register can be clocked by either clock0, clock1 or none.
    // Port B -- 1. all input registered must be clocked by either clock0 or clock1.
    //           2. output register can be clocked by either clock0, clock1 or none.
    input  clock0;
    input  clock1;

    // clock enable inputs and here are their usage
    // clocken0 -- can only be used for enabling clock0.
    // clocken1 -- can only be used for enabling clock1.
    // clocken2 -- as an alternative for enabling clock0.
    // clocken3 -- as an alternative for enabling clock1.
    input  clocken0;
    input  clocken1;
    input  clocken2;
    input  clocken3;

    // clear inputs on both ports and here are their usage
    // Port A -- 1. all input registers can only be cleared by clear0 or none.
    //           2. output register can be cleared by either clear0, clear1 or none.
    // Port B -- 1. all input registers can be cleared by clear0, clear1 or none.
    //           2. output register can be cleared by either clear0, clear1 or none.
    input  aclr0;
    input  aclr1;

    input [width_byteena_a-1:0] byteena_a; // Port A byte enable input
    input [width_byteena_b-1:0] byteena_b; // Port B byte enable input

    // Stratix II related ports
    input addressstall_a;
    input addressstall_b;



// OUTPUT PORT DECLARATION

    output [width_a-1:0] q_a; // Port A output
    output [width_b-1:0] q_b; // Port B output

    output [width_eccstatus-1:0] eccstatus;   // ECC status flags

// INTERNAL REGISTERS DECLARATION

    reg [width_a-1:0] mem_data [0:(1<<widthad_a)-1];
    reg [width_b-1:0] mem_data_b [0:(1<<widthad_b)-1];
    reg [width_a-1:0] i_data_reg_a;
    reg [width_a-1:0] temp_wa;
    reg [width_a-1:0] temp_wa2;
    reg [width_a-1:0] temp_wa2b;
    reg [width_a-1:0] init_temp;
    reg [width_b-1:0] i_data_reg_b;
    reg [width_b-1:0] temp_wb;
    reg [width_b-1:0] temp_wb2;
    reg temp;
    reg [width_a-1:0] i_q_reg_a;
    reg [width_a-1:0] i_q_tmp_a;
    reg [width_a-1:0] i_q_tmp2_a;
    reg [width_b-1:0] i_q_reg_b;
    reg [width_b-1:0] i_q_tmp_b;
    reg [width_b-1:0] i_q_tmp2_b;
    reg [width_b-1:0] i_q_output_latch;
    reg [width_a-1:0] i_byteena_mask_reg_a;
    reg [width_b-1:0] i_byteena_mask_reg_b;
    reg [widthad_a-1:0] i_address_reg_a;
    reg [widthad_b-1:0] i_address_reg_b;

    reg [widthad_a-1:0] i_original_address_a;
    
    reg [width_a-1:0] i_byteena_mask_reg_a_tmp;
    reg [width_b-1:0] i_byteena_mask_reg_b_tmp;
    reg [width_a-1:0] i_byteena_mask_reg_a_out;
    reg [width_b-1:0] i_byteena_mask_reg_b_out;
    reg [width_a-1:0] i_byteena_mask_reg_a_x;
    reg [width_b-1:0] i_byteena_mask_reg_b_x;
    reg [width_a-1:0] i_byteena_mask_reg_a_out_b;
    reg [width_b-1:0] i_byteena_mask_reg_b_out_a;


    reg [8*256:1] ram_initf;
    reg i_wren_reg_a;
    reg i_wren_reg_b;
    reg i_rden_reg_a;
    reg i_rden_reg_b;
    reg i_read_flag_a;
    reg i_read_flag_b;
    reg i_write_flag_a;
    reg i_write_flag_b;
    reg good_to_go_a;
    reg good_to_go_b;
    reg [31:0] file_desc;
    reg init_file_b_port;
    reg i_nmram_write_a;
    reg i_nmram_write_b;

    reg [width_a - 1: 0] wa_mult_x;
    reg [width_a - 1: 0] wa_mult_x_ii;
    reg [width_a - 1: 0] wa_mult_x_iii;
    reg [widthad_a + width_a - 1:0] add_reg_a_mult_wa;
    reg [widthad_b + width_b -1:0] add_reg_b_mult_wb;
    reg [widthad_a + width_a - 1:0] add_reg_a_mult_wa_pl_wa;
    reg [widthad_b + width_b -1:0] add_reg_b_mult_wb_pl_wb;

    reg same_clock_pulse0;
    reg same_clock_pulse1;
    
    reg [width_b - 1 : 0] i_original_data_b;
    reg [width_a - 1 : 0] i_original_data_a;
    
    reg i_address_aclr_a_flag;
    reg i_address_aclr_a_prev;
    reg i_address_aclr_b_flag;
    reg i_address_aclr_b_prev;
    reg i_outdata_aclr_a_prev;
    reg i_outdata_aclr_b_prev;
    reg i_force_reread_a;
    reg i_force_reread_a1;
    reg i_force_reread_b;
    reg i_force_reread_b1;
    reg i_force_reread_a_signal;
    reg i_force_reread_b_signal;

// INTERNAL PARAMETER
    reg [9*8:0] cread_during_write_mode_mixed_ports;
    reg [7*8:0] i_ram_block_type;
    integer i_byte_size;
    
    wire i_good_to_write_a;
    wire i_good_to_write_b;
    reg i_good_to_write_a2;
    reg i_good_to_write_b2;

    reg i_core_clocken_a_reg;
    reg i_core_clocken0_b_reg;
    reg i_core_clocken1_b_reg;

// INTERNAL WIRE DECLARATIONS

    wire i_indata_aclr_a;
    wire i_address_aclr_a;
    wire i_wrcontrol_aclr_a;
    wire i_indata_aclr_b;
    wire i_address_aclr_b;
    wire i_wrcontrol_aclr_b;
    wire i_outdata_aclr_a;
    wire i_outdata_aclr_b;
    wire i_rdcontrol_aclr_b;
    wire i_byteena_aclr_a;
    wire i_byteena_aclr_b;
    wire i_outdata_clken_a;
    wire i_outdata_clken_b;
    wire i_clocken0;
    wire i_clocken1_b;
    wire i_clocken0_b;
    wire i_core_clocken_a;
    wire i_core_clocken_b;
    wire i_core_clocken0_b;
    wire i_core_clocken1_b;

// INTERNAL TRI DECLARATION

    tri0 wren_a;
    tri0 wren_b;
    tri1 rden_a;
    tri1 rden_b;
    tri1 clock0;
    tri1 clocken0;
    tri1 clocken1;
    tri1 clocken2;
    tri1 clocken3;
    tri0 aclr0;
    tri0 aclr1;
    tri0 addressstall_a;
    tri0 addressstall_b;
    tri1 [width_byteena_a-1:0] i_byteena_a;
    tri1 [width_byteena_b-1:0] i_byteena_b;


// LOCAL INTEGER DECLARATION

    integer i_numwords_a;
    integer i_numwords_b;
    integer i_aclr_flag_a;
    integer i_aclr_flag_b;
    integer i_q_tmp2_a_idx;

    // for loop iterators
    integer init_i;
    integer i;
    integer i2;
    integer i3;
    integer i4;
    integer i5;
    integer j;
    integer j2;
    integer j3;
    integer k;
    integer k2;
    integer k3;
    integer k4;
    
    // For temporary calculation
    integer i_div_wa;
    integer i_div_wb;
    integer j_plus_i2;
    integer j2_plus_i5;
    integer j3_plus_i5;
    integer j_plus_i2_div_a;
    integer j2_plus_i5_div_a;
    integer j3_plus_i5_div_a;
    integer j3_plus_i5_div_b;
    integer i_byteena_count;
    integer port_a_bit_count_low;
    integer port_a_bit_count_high;
    integer port_b_bit_count_low;
    integer port_b_bit_count_high;

    time i_data_write_time_a;

    // ------------------------
    // COMPONENT INSTANTIATIONS
    // ------------------------
    ALTERA_DEVICE_FAMILIES dev ();
    ALTERA_MF_MEMORY_INITIALIZATION mem ();

// INITIAL CONSTRUCT BLOCK

    initial
    begin


        i_numwords_a = (numwords_a != 0) ? numwords_a : (1 << widthad_a);
        i_numwords_b = (numwords_b != 0) ? numwords_b : (1 << widthad_b);
        
        if (family_has_stratixv_style_ram == 1)
        begin
            if (((is_lutram == 1) && (family_stratixv == 1)) ||
                    (ram_block_type == "M20K"))
                i_ram_block_type = ram_block_type;
            else
                i_ram_block_type = "AUTO";
        end
        else if (family_has_stratixiii_style_ram == 1)
        begin
            if ((ram_block_type == "M-RAM") || (ram_block_type == "MEGARAM"))
                i_ram_block_type = "M144K";
            else if ((((ram_block_type == "M144K") || (is_lutram == 1)) && (family_stratixiii == 1)) ||
                    (ram_block_type == "M9K"))
                i_ram_block_type = ram_block_type;
            else
                i_ram_block_type = "AUTO";
        end
        else
        begin
            if ((ram_block_type != "AUTO") &&
                (ram_block_type != "M-RAM") && (ram_block_type != "MEGARAM") &&
                (ram_block_type != "M512") &&
                (ram_block_type != "M4K"))
                i_ram_block_type = "AUTO";
            else
                i_ram_block_type = ram_block_type;
        end
	
        if ((family_cyclone == 1) || (family_cycloneii == 1))
            cread_during_write_mode_mixed_ports = "OLD_DATA";
        else if (read_during_write_mode_mixed_ports == "UNUSED")
            cread_during_write_mode_mixed_ports = "DONT_CARE";
        else
            cread_during_write_mode_mixed_ports = read_during_write_mode_mixed_ports;
            
        i_byte_size = (byte_size > 0) ? byte_size
                        : ((((family_has_stratixi_style_ram == 1) || family_cycloneiii == 1) && (i_byte_size_tmp != 8) && (i_byte_size_tmp != 9)) ||
                            (((family_base_stratixii == 1) || (family_base_cycloneii == 1)) && (i_byte_size_tmp != 1) && (i_byte_size_tmp != 2) && (i_byte_size_tmp != 4) && (i_byte_size_tmp != 8) && (i_byte_size_tmp != 9)) ||
                            (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) && (i_byte_size_tmp != 5) && (i_byte_size_tmp !=10) && (i_byte_size_tmp != 8) && (i_byte_size_tmp != 9))) ?
                            8 : i_byte_size_tmp;
            
        // Parameter Checking
        if ((operation_mode != "BIDIR_DUAL_PORT") && (operation_mode != "SINGLE_PORT") &&
            (operation_mode != "DUAL_PORT") && (operation_mode != "ROM"))
        begin
            $display("Error: Not a valid operation mode.");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((family_stratixv == 1) &&
            (ram_block_type != "M20K") && (is_lutram != 1) && (ram_block_type != "AUTO"))
        begin
            $display("Warning: RAM_BLOCK_TYPE HAS AN INVALID VALUE. IT CAN ONLY BE M20K, LUTRAM OR AUTO for %s device family. This parameter will take AUTO as its value", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end
        
        if ((family_stratixv != 1) && (family_stratixiii == 1) &&
            (ram_block_type != "M9K") && (ram_block_type != "M144K") && (is_lutram != 1) &&
            (ram_block_type != "AUTO") && (((ram_block_type == "M-RAM") || (ram_block_type == "MEGARAM")) != 1))
        begin
            $display("Warning: RAM_BLOCK_TYPE HAS AN INVALID VALUE. IT CAN ONLY BE M9K, M144K, LUTRAM OR AUTO for %s device family. This parameter will take AUTO as its value", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end
        
        if (i_ram_block_type != ram_block_type)
        begin
            $display("Warning: RAM block type is assumed as %s", i_ram_block_type);
            $display("Time: %0t  Instance: %m", $time);
        end


        if ((cread_during_write_mode_mixed_ports != "DONT_CARE") &&
            (cread_during_write_mode_mixed_ports != "OLD_DATA") && 
            (cread_during_write_mode_mixed_ports != "NEW_DATA"))
        begin
            $display("Error: Invalid value for read_during_write_mode_mixed_ports parameter. It has to be OLD_DATA or DONT_CARE or NEW_DATA");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if ((cread_during_write_mode_mixed_ports != read_during_write_mode_mixed_ports) && ((operation_mode != "SINGLE_PORT") && (operation_mode != "ROM")))
        begin
            $display("Warning: read_during_write_mode_mixed_ports is assumed as %s", cread_during_write_mode_mixed_ports);
            $display("Time: %0t  Instance: %m", $time);
        end
        
        if ((is_lutram != 1) && (cread_during_write_mode_mixed_ports == "NEW_DATA"))
        begin
            $display("Warning: read_during_write_mode_mixed_ports cannot be set to NEW_DATA for non-LUTRAM ram block type. This will cause incorrect simulation result.");
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((i_ram_block_type == "M-RAM") || (i_ram_block_type == "MEGARAM")) && init_file != "UNUSED")
        begin
            $display("Error: M-RAM block type doesn't support the use of an initialization file");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((i_byte_size != 8) && (i_byte_size != 9) && (family_has_stratixi_style_ram == 1))
        begin
            $display("Error: byte_size HAS TO BE EITHER 8 or 9");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((i_byte_size != 8) && (i_byte_size != 9) && (i_byte_size != 1) &&
            (i_byte_size != 2) && (i_byte_size != 4) && 
            ((family_base_stratixii == 1) || (family_base_cycloneii == 1)))
        begin
            $display("Error: byte_size has to be either 1, 2, 4, 8 or 9 for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((i_byte_size != 5) && (i_byte_size != 8) && (i_byte_size != 9) && (i_byte_size != 10) &&
            ((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)))
        begin
            $display("Error: byte_size has to be either 5,8,9 or 10 for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (width_a <= 0)
        begin
            $display("Error: Invalid value for WIDTH_A parameter");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((width_b <= 0) &&
            ((operation_mode != "SINGLE_PORT") || (operation_mode != "ROM")))
        begin
            $display("Error: Invalid value for WIDTH_B parameter");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (widthad_a <= 0)
        begin
            $display("Error: Invalid value for WIDTHAD_A parameter");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((width_b <= 0) &&
            ((operation_mode != "SINGLE_PORT") || (operation_mode != "ROM")))
        begin
            $display("Error: Invalid value for WIDTHAD_B parameter");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((operation_mode == "ROM") &&
            ((i_ram_block_type == "M-RAM") || (i_ram_block_type == "MEGARAM")))
        begin
            $display("Error: ROM mode does not support RAM_BLOCK_TYPE = M-RAM");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (((wrcontrol_aclr_a != "NONE") && (wrcontrol_aclr_a != "UNUSED")) && (i_ram_block_type == "M512") && (operation_mode == "SINGLE_PORT"))
        begin
            $display("Error: Wren_a cannot have clear in single port mode for M512 block");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((operation_mode == "DUAL_PORT") && (i_numwords_a * width_a != i_numwords_b * width_b))
        begin
            $display("Error: Total number of bits of port A and port B should be the same for dual port mode");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (((rdcontrol_aclr_b != "NONE") && (rdcontrol_aclr_b != "UNUSED")) && (i_ram_block_type == "M512") && (operation_mode == "DUAL_PORT"))
        begin
            $display("Error: rden_b cannot have clear in simple dual port mode for M512 block");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((operation_mode == "BIDIR_DUAL_PORT") && (i_numwords_a * width_a != i_numwords_b * width_b))
        begin
            $display("Error: Total number of bits of port A and port B should be the same for bidir dual port mode");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((operation_mode == "BIDIR_DUAL_PORT") && (i_ram_block_type == "M512"))
        begin
            $display("Error: M512 block type doesn't support bidir dual mode");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (((i_ram_block_type == "M-RAM") || (i_ram_block_type == "MEGARAM")) &&
            (cread_during_write_mode_mixed_ports == "OLD_DATA"))
        begin
            $display("Error: M-RAM doesn't support OLD_DATA value for READ_DURING_WRITE_MODE_MIXED_PORTS parameter");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((family_has_stratixi_style_ram == 1) &&
            (clock_enable_input_a == "BYPASS"))
        begin
            $display("Error: BYPASS value for CLOCK_ENABLE_INPUT_A is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((family_has_stratixi_style_ram == 1) &&
            (clock_enable_output_a == "BYPASS"))
        begin
            $display("Error: BYPASS value for CLOCK_ENABLE_OUTPUT_A is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((family_has_stratixi_style_ram == 1) &&
            (clock_enable_input_b == "BYPASS"))
        begin
            $display("Error: BYPASS value for CLOCK_ENABLE_INPUT_B is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((family_has_stratixi_style_ram == 1) &&
            (clock_enable_output_b == "BYPASS"))
        begin
            $display("Error: BYPASS value for CLOCK_ENABLE_OUTPUT_B is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((implement_in_les != "OFF") && (implement_in_les != "ON"))
        begin
            $display("Error: Illegal value for implement_in_les parameter");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if (((family_has_m512) == 0) && (i_ram_block_type == "M512"))
        begin
            $display("Error: M512 value for RAM_BLOCK_TYPE parameter is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if (((family_has_megaram) == 0) && 
            ((i_ram_block_type == "M-RAM") || (i_ram_block_type == "MEGARAM")))
        begin
            $display("Error: MEGARAM value for RAM_BLOCK_TYPE parameter is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if (((init_file == "UNUSED") || (init_file == "")) &&
            (operation_mode == "ROM"))
        begin
            $display("Error! Altsyncram needs data file for memory initialization in ROM mode.");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (((family_base_stratixii == 1) || (family_base_cycloneii == 1)) &&
            (((indata_aclr_a != "UNUSED") && (indata_aclr_a != "NONE")) ||
            ((wrcontrol_aclr_a != "UNUSED") && (wrcontrol_aclr_a != "NONE")) ||
            ((byteena_aclr_a  != "UNUSED") && (byteena_aclr_a != "NONE")) ||
            ((address_aclr_a != "UNUSED") && (address_aclr_a != "NONE") && (operation_mode != "ROM")) ||
            ((indata_aclr_b != "UNUSED") && (indata_aclr_b != "NONE")) ||
            ((rdcontrol_aclr_b != "UNUSED") && (rdcontrol_aclr_b != "NONE")) ||
            ((wrcontrol_aclr_b != "UNUSED") && (wrcontrol_aclr_b != "NONE")) ||
            ((byteena_aclr_b != "UNUSED") && (byteena_aclr_b != "NONE")) ||
            ((address_aclr_b != "UNUSED") && (address_aclr_b != "NONE") && (operation_mode != "DUAL_PORT"))))
        begin
            $display("Warning: %s device family does not support aclr signal on input ports. The aclr to input ports will be ignored.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) &&
            (((indata_aclr_a != "UNUSED") && (indata_aclr_a != "NONE")) ||
            ((wrcontrol_aclr_a != "UNUSED") && (wrcontrol_aclr_a != "NONE")) ||
            ((byteena_aclr_a  != "UNUSED") && (byteena_aclr_a != "NONE")) ||
            ((address_aclr_a != "UNUSED") && (address_aclr_a != "NONE") && (operation_mode != "ROM")) ||
            ((indata_aclr_b != "UNUSED") && (indata_aclr_b != "NONE")) ||
            ((rdcontrol_aclr_b != "UNUSED") && (rdcontrol_aclr_b != "NONE")) ||
            ((wrcontrol_aclr_b != "UNUSED") && (wrcontrol_aclr_b != "NONE")) ||
            ((byteena_aclr_b != "UNUSED") && (byteena_aclr_b != "NONE")) ||
            ((address_aclr_b != "UNUSED") && (address_aclr_b != "NONE") && (operation_mode != "DUAL_PORT"))))
        begin
            $display("Warning: %s device family does not support aclr signal on input ports. The aclr to input ports will be ignored.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((family_has_stratixv_style_ram != 1) && (family_has_stratixiii_style_ram != 1))
            && (read_during_write_mode_port_a != "NEW_DATA_NO_NBE_READ"))
        begin
            $display("Warning: %s value for read_during_write_mode_port_a is not supported in %s device family, it might cause incorrect behavioural simulation result", read_during_write_mode_port_a, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((family_has_stratixv_style_ram != 1) && (family_has_stratixiii_style_ram != 1))
            && (read_during_write_mode_port_b != "NEW_DATA_NO_NBE_READ"))
        begin
            $display("Warning: %s value for read_during_write_mode_port_b is not supported in %s device family, it might cause incorrect behavioural simulation result", read_during_write_mode_port_b, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end
// SPR 249576: Enable don't care as RDW setting in MegaFunctions - eliminates checking for ram_block_type = "AUTO"
        if (!((is_lutram == 1) || ((i_ram_block_type == "AUTO") && (family_has_lutram == 1)) || 
            ((i_ram_block_type != "AUTO") && ((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)))) && 
            (operation_mode != "SINGLE_PORT") && (read_during_write_mode_port_a == "DONT_CARE"))
        begin
            $display("Error: %s value for read_during_write_mode_port_a is not supported in %s device family for %s ram block type in %s operation_mode", 
                read_during_write_mode_port_a, intended_device_family, i_ram_block_type, operation_mode);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if ((is_lutram != 1) && (i_ram_block_type != "AUTO") && 
            (read_during_write_mode_mixed_ports == "NEW_DATA"))
        begin
            $display("Error: %s value for read_during_write_mode_mixed_ports is not supported in %s RAM block type", read_during_write_mode_mixed_ports, i_ram_block_type);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if ((operation_mode == "DUAL_PORT") && (outdata_reg_b != "CLOCK0") && (is_lutram == 1) && (read_during_write_mode_mixed_ports == "OLD_DATA"))
        begin
            $display("Warning: Value for read_during_write_mode_mixed_ports of instance is not honoured in DUAL PORT operation mode when output registers are not clocked by clock0 for LUTRAM.");
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) 
            && ((indata_aclr_a != "NONE") && (indata_aclr_a != "UNUSED")))
        begin
            $display("Warning: %s value for indata_aclr_a is not supported in %s device family. The aclr to data_a registers will be ignored.", indata_aclr_a, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) 
            && ((wrcontrol_aclr_a != "NONE") && (wrcontrol_aclr_a != "UNUSED")))
        begin
            $display("Warning: %s value for wrcontrol_aclr_a is not supported in %s device family. The aclr to write control registers of port A will be ignored.", wrcontrol_aclr_a, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) 
            && ((byteena_aclr_a != "NONE") && (byteena_aclr_a != "UNUSED")))
        begin
            $display("Warning: %s value for byteena_aclr_a is not supported in %s device family. The aclr to byteena_a registers will be ignored.", byteena_aclr_a, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) 
            && ((address_aclr_a != "NONE") && (address_aclr_a != "UNUSED")) && (operation_mode != "ROM"))
        begin
            $display("Warning: %s value for address_aclr_a is not supported for write port in %s device family. The aclr to address_a registers will be ignored.", byteena_aclr_a, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) 
            && ((indata_aclr_b != "NONE") && (indata_aclr_b != "UNUSED")))
        begin
            $display("Warning: %s value for indata_aclr_b is not supported in %s device family. The aclr to data_b registers will be ignored.", indata_aclr_b, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) 
            && ((rdcontrol_aclr_b != "NONE") && (rdcontrol_aclr_b != "UNUSED")))
        begin
            $display("Warning: %s value for rdcontrol_aclr_b is not supported in %s device family. The aclr to read control registers will be ignored.", rdcontrol_aclr_b, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) 
            && ((wrcontrol_aclr_b != "NONE") && (wrcontrol_aclr_b != "UNUSED")))
        begin
            $display("Warning: %s value for wrcontrol_aclr_b is not supported in %s device family. The aclr to write control registers will be ignored.", wrcontrol_aclr_b, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) 
            && ((byteena_aclr_b != "NONE") && (byteena_aclr_b != "UNUSED")))
        begin
            $display("Warning: %s value for byteena_aclr_b is not supported in %s device family. The aclr to byteena_a register will be ignored.", byteena_aclr_b, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end
        
        if (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) 
            && ((address_aclr_b != "NONE") && (address_aclr_b != "UNUSED")) && (operation_mode == "BIDIR_DUAL_PORT"))
        begin
            $display("Warning: %s value for address_aclr_b is not supported for write port in %s device family. The aclr to address_b registers will be ignored.", address_aclr_b, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end
    
        if ((is_lutram == 1) && (read_during_write_mode_mixed_ports == "OLD_DATA")
            && ((address_aclr_b != "NONE") && (address_aclr_b != "UNUSED")) && (operation_mode == "DUAL_PORT"))
        begin
            $display("Warning : aclr signal for address_b is ignored for RAM block type %s when read_during_write_mode_mixed_ports is set to OLD_DATA", ram_block_type);
            $display("Time: %0t  Instance: %m", $time);
        end

        if ((((family_has_stratixv_style_ram != 1) && (family_has_stratixiii_style_ram != 1)))
            && ((clock_enable_core_a != clock_enable_input_a) && (clock_enable_core_a != "USE_INPUT_CLKEN")))
        begin
            $display("Warning: clock_enable_core_a value must be USE_INPUT_CLKEN or same as clock_enable_input_a in %s device family. It will be set to clock_enable_input_a value.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if ((((family_has_stratixv_style_ram != 1) && (family_has_stratixiii_style_ram != 1)))
            && ((clock_enable_core_b != clock_enable_input_b) && (clock_enable_core_b != "USE_INPUT_CLKEN")))
        begin
            $display("Warning: clock_enable_core_b must be USE_INPUT_CLKEN or same as clock_enable_input_b in %s device family. It will be set to clock_enable_input_b value.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
        end

        if (((family_has_stratixv_style_ram != 1) && (family_has_stratixiii_style_ram != 1))
            && (clock_enable_input_a == "ALTERNATE"))
        begin
            $display("Error: %s value for clock_enable_input_a is not supported in %s device family.", clock_enable_input_a, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if (((family_has_stratixv_style_ram != 1) && (family_has_stratixiii_style_ram != 1))
            && (clock_enable_input_b == "ALTERNATE"))
        begin
            $display("Error: %s value for clock_enable_input_b is not supported in %s device family.", clock_enable_input_b, intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end

        if ((i_ram_block_type != "M20K") && (i_ram_block_type != "M144K") && ((enable_ecc != "FALSE") && (enable_ecc != "NONE")) && (operation_mode != "DUAL_PORT"))
        begin
            $display("Warning: %s value for enable_ecc is not supported in %s ram block type for %s device family in %s operation mode", enable_ecc, i_ram_block_type, intended_device_family, operation_mode);
            $display("Time: %0t  Instance: %m", $time);
        end
        
        if (((i_ram_block_type == "M20K") || (i_ram_block_type == "M144K")) && (enable_ecc == "TRUE") && (read_during_write_mode_mixed_ports == "OLD_DATA"))
        begin
            $display("Error : ECC is not supported for read-before-write mode.");
            $display("Time: %0t  Instance: %m", $time);
            $finish;
        end
        
        if (operation_mode != "DUAL_PORT")
        begin
            if ((outdata_reg_a != "CLOCK0") && (outdata_reg_a != "CLOCK1") && (outdata_reg_a != "UNUSED")  && (outdata_reg_a != "UNREGISTERED"))
            begin
                $display("Error: %s value for outdata_reg_a is not supported.", outdata_reg_a);
                $display("Time: %0t  Instance: %m", $time);
                $finish;
            end
        end

        if ((operation_mode == "BIDIR_DUAL_PORT") || (operation_mode == "DUAL_PORT"))
        begin
            if ((address_reg_b != "CLOCK0") && (address_reg_b != "CLOCK1") && (address_reg_b != "UNUSED"))
            begin
                $display("Error: %s value for address_reg_b is not supported.", address_reg_b);
                $display("Time: %0t  Instance: %m", $time);
                $finish;
            end
    
            if ((outdata_reg_b != "CLOCK0") && (outdata_reg_b != "CLOCK1") && (outdata_reg_b != "UNUSED") && (outdata_reg_b != "UNREGISTERED"))
            begin
                $display("Error: %s value for outdata_reg_b is not supported.", outdata_reg_b);
                $display("Time: %0t  Instance: %m", $time);
                $finish;
            end

            if ((rdcontrol_reg_b != "CLOCK0") && (rdcontrol_reg_b != "CLOCK1") && (rdcontrol_reg_b != "UNUSED") && (operation_mode == "DUAL_PORT"))
            begin
                $display("Error: %s value for rdcontrol_reg_b is not supported.", rdcontrol_reg_b);
                $display("Time: %0t  Instance: %m", $time);
                $finish;
            end
    
            if ((indata_reg_b != "CLOCK0") && (indata_reg_b != "CLOCK1") && (indata_reg_b != "UNUSED") && (operation_mode == "BIDIR_DUAL_PORT"))
            begin
                $display("Error: %s value for indata_reg_b is not supported.", indata_reg_b);
                $display("Time: %0t  Instance: %m", $time);
                $finish;
            end
    
            if ((wrcontrol_wraddress_reg_b != "CLOCK0") && (wrcontrol_wraddress_reg_b != "CLOCK1") && (wrcontrol_wraddress_reg_b != "UNUSED") && (operation_mode == "BIDIR_DUAL_PORT"))
            begin
                $display("Error: %s value for wrcontrol_wraddress_reg_b is not supported.", wrcontrol_wraddress_reg_b);
                $display("Time: %0t  Instance: %m", $time);
                $finish;
            end
    
            if ((byteena_reg_b != "CLOCK0") && (byteena_reg_b != "CLOCK1") && (byteena_reg_b != "UNUSED") && (operation_mode == "BIDIR_DUAL_PORT"))
            begin
                $display("Error: %s value for byteena_reg_b is not supported.", byteena_reg_b);
                $display("Time: %0t  Instance: %m", $time);
                $finish;
            end
        end

        // *****************************************
        // legal operations for all operation modes:
        //      |  PORT A  |  PORT B  |
        //      |  RD  WR  |  RD  WR  |
        // BDP  |  x   x   |  x   x   |
        // DP   |      x   |  x       |
        // SP   |  x   x   |          |
        // ROM  |  x       |          |
        // *****************************************


        // Initialize mem_data

        if ((init_file == "UNUSED") || (init_file == ""))
        begin
            if (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) && (family_hardcopyiii == 0) && (family_hardcopyiv == 0) && (power_up_uninitialized != "TRUE"))
            begin
                wa_mult_x = {width_a{1'b0}};
                for (i = 0; i < (1 << widthad_a); i = i + 1)
                    mem_data[i] = wa_mult_x;
                    
                if (enable_mem_data_b_reading)
                begin
                    for (i = 0; i < (1 << widthad_b); i = i + 1)
                        mem_data_b[i] = {width_b{1'b0}};
                end

            end
            else if (((i_ram_block_type == "M-RAM") ||
                (i_ram_block_type == "MEGARAM") ||
                ((i_ram_block_type == "AUTO") && (cread_during_write_mode_mixed_ports == "DONT_CARE")) ||
                (family_hardcopyii == 1) || 
                (family_hardcopyiii == 1) || 
                (family_hardcopyiv == 1) || 
                (power_up_uninitialized == "TRUE") ) && (implement_in_les == "OFF"))
            begin
                wa_mult_x = {width_a{1'bx}};
                for (i = 0; i < (1 << widthad_a); i = i + 1)
                    mem_data[i] = wa_mult_x;

                if (enable_mem_data_b_reading)
                begin
                    for (i = 0; i < (1 << widthad_b); i = i + 1)
                    mem_data_b[i] = {width_b{1'bx}};
                end
            end
            else
            begin
                wa_mult_x = {width_a{1'b0}};
                for (i = 0; i < (1 << widthad_a); i = i + 1)
                    mem_data[i] = wa_mult_x;
                    
                if (enable_mem_data_b_reading)
                begin
                    for (i = 0; i < (1 << widthad_b); i = i + 1)
                    mem_data_b[i] = {width_b{1'b0}};
                end
            end
        end

        else  // Memory initialization file is used
        begin

            wa_mult_x = {width_a{1'b0}};
            for (i = 0; i < (1 << widthad_a); i = i + 1)
                mem_data[i] = wa_mult_x;
                
            for (i = 0; i < (1 << widthad_b); i = i + 1)
                mem_data_b[i] = {width_b{1'b0}};

            init_file_b_port = 0;

            if ((init_file_layout != "PORT_A") &&
                (init_file_layout != "PORT_B"))
            begin
                if (operation_mode == "DUAL_PORT")
                    init_file_b_port = 1;
                else
                    init_file_b_port = 0;
            end
            else
            begin
                if (init_file_layout == "PORT_A")
                    init_file_b_port = 0;
                else if (init_file_layout == "PORT_B")
                    init_file_b_port = 1;
            end

            if (init_file_b_port)
            begin
                `ifdef NO_PLI
                    $readmemh(init_file, mem_data_b);
                `else
                    `ifdef USE_RIF
                        $readmemh(init_file, mem_data_b);
                    `else
                        mem.convert_to_ver_file(init_file, width_b, ram_initf);
                        $readmemh(ram_initf, mem_data_b);
                    `endif 
                `endif

                for (i = 0; i < (i_numwords_b * width_b); i = i + 1)
                begin
                    temp_wb = mem_data_b[i / width_b];
                    i_div_wa = i / width_a;
                    temp_wa = mem_data[i_div_wa];
                    temp_wa[i % width_a] = temp_wb[i % width_b];
                    mem_data[i_div_wa] = temp_wa;
                end
            end
            else
            begin
                `ifdef NO_PLI
                    $readmemh(init_file, mem_data);
                `else
                    `ifdef USE_RIF
                        $readmemh(init_file, mem_data);
                    `else
                        mem.convert_to_ver_file(init_file, width_a, ram_initf);
                        $readmemh(ram_initf, mem_data);
                    `endif
                `endif
                
                if (enable_mem_data_b_reading)
                begin                
                    for (i = 0; i < (i_numwords_a * width_a); i = i + 1)
                    begin
                        temp_wa = mem_data[i / width_a];
                        i_div_wb = i / width_b;
                        temp_wb = mem_data_b[i_div_wb];
                        temp_wb[i % width_b] = temp_wa[i % width_a];
                        mem_data_b[i_div_wb] = temp_wb;
                    end
                end
            end
        end
        i_nmram_write_a = 0;
        i_nmram_write_b = 0;

        i_aclr_flag_a = 0;
        i_aclr_flag_b = 0;

        i_outdata_aclr_a_prev = 0;
        i_outdata_aclr_b_prev = 0;
        i_address_aclr_a_prev = 0;
        i_address_aclr_b_prev = 0;
        
        i_force_reread_a = 0;
        i_force_reread_a1 = 0;
        i_force_reread_b = 0;
        i_force_reread_b1 = 0;
        i_force_reread_a_signal = 0;
        i_force_reread_b_signal = 0;
        
        // Initialize internal registers/signals
        i_data_reg_a = 0;
        i_data_reg_b = 0;
        i_address_reg_a = 0;
        i_address_reg_b = 0;
        i_original_address_a = 0;
        i_wren_reg_a = 0;
        i_wren_reg_b = 0;
        i_read_flag_a = 0;
        i_read_flag_b = 0;
        i_write_flag_a = 0;
        i_write_flag_b = 0;
        i_byteena_mask_reg_a = {width_a{1'b1}};
        i_byteena_mask_reg_b = {width_b{1'b1}};
        i_byteena_mask_reg_a_x = 0;
        i_byteena_mask_reg_b_x = 0;
        i_byteena_mask_reg_a_out = {width_a{1'b1}};
        i_byteena_mask_reg_b_out = {width_b{1'b1}};
        i_original_data_b = 0;
        i_original_data_a = 0;
        i_data_write_time_a = 0;
        i_core_clocken_a_reg = 0;
        i_core_clocken0_b_reg = 0;
        i_core_clocken1_b_reg = 0;

        if ((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1))
        begin
            i_rden_reg_a = 0;
            i_rden_reg_b = 0;
        end
        else
        begin
            i_rden_reg_a = 1;
            i_rden_reg_b = 1;
        end
        


        if (((i_ram_block_type == "M-RAM") ||
                (i_ram_block_type == "MEGARAM") ||
                ((i_ram_block_type == "AUTO") && (cread_during_write_mode_mixed_ports == "DONT_CARE"))) && 
                (family_has_stratixv_style_ram != 1) && (family_has_stratixiii_style_ram != 1))
        begin
            i_q_tmp_a = {width_a{1'bx}};
            i_q_tmp_b = {width_b{1'bx}};
            i_q_tmp2_a = {width_a{1'bx}};
            i_q_tmp2_b = {width_b{1'bx}};
            i_q_reg_a = {width_a{1'bx}};
            i_q_reg_b = {width_b{1'bx}};
        end
        else
        begin
            if (is_lutram == 1) 
            begin
                i_q_tmp_a = mem_data[0];
                i_q_tmp2_a = mem_data[0];

                for (init_i = 0; init_i < width_b; init_i = init_i + 1)
                begin
                    init_temp = mem_data[init_i / width_a];
                    i_q_tmp_b[init_i] = init_temp[init_i % width_a];
                    i_q_tmp2_b[init_i] = init_temp[init_i % width_a];
                end

                i_q_reg_a = 0;
                i_q_reg_b = 0;
                i_q_output_latch = 0;
            end
            else
            begin
                i_q_tmp_a = 0;
                i_q_tmp_b = 0;
                i_q_tmp2_a = 0;
                i_q_tmp2_b = 0;
                i_q_reg_a = 0;
                i_q_reg_b = 0;
            end
        end

        good_to_go_a = 0;
        good_to_go_b = 0;

        same_clock_pulse0 = 1'b0;
        same_clock_pulse1 = 1'b0;

        i_byteena_count = 0;
        
        if (((family_hardcopyii == 1)) &&
            (ram_block_type == "M4K") && (operation_mode != "SINGLE_PORT"))
        begin
            i_good_to_write_a2 = 0;
            i_good_to_write_b2 = 0;
        end
        else
        begin
            i_good_to_write_a2 = 1;
            i_good_to_write_b2 = 1;
        end

    end


// SIGNAL ASSIGNMENT

    // Clock enable signal assignment

    // port a clock enable assignments:
    assign i_outdata_clken_a              = (clock_enable_output_a == "BYPASS") ?
                                            1'b1 : ((clock_enable_output_a == "ALTERNATE") && (outdata_reg_a == "CLOCK1")) ?
                                            clocken3 : ((clock_enable_output_a == "ALTERNATE") && (outdata_reg_a == "CLOCK0")) ?
                                            clocken2 : (outdata_reg_a == "CLOCK1") ?
                                            clocken1 : (outdata_reg_a == "CLOCK0") ?
                                            clocken0 : 1'b1;
    // port b clock enable assignments:
    assign i_outdata_clken_b              = (clock_enable_output_b == "BYPASS") ?
                                            1'b1 : ((clock_enable_output_b == "ALTERNATE") && (outdata_reg_b == "CLOCK1")) ?
                                            clocken3 : ((clock_enable_output_b == "ALTERNATE") && (outdata_reg_b == "CLOCK0")) ?
                                            clocken2 : (outdata_reg_b == "CLOCK1") ?
                                            clocken1 : (outdata_reg_b == "CLOCK0") ?
                                            clocken0 : 1'b1;


    assign i_clocken0                     = (clock_enable_input_a == "BYPASS") ?
                                            1'b1 : (clock_enable_input_a == "NORMAL") ?
                                            clocken0 : clocken2;

    assign i_clocken0_b                   = (clock_enable_input_b == "BYPASS") ?
                                            1'b1 : (clock_enable_input_b == "NORMAL") ?
                                            clocken0 : clocken2;

    assign i_clocken1_b                   = (clock_enable_input_b == "BYPASS") ?
                                            1'b1 : (clock_enable_input_b == "NORMAL") ?
                                            clocken1 : clocken3;

    assign i_core_clocken_a              = (((family_has_stratixv_style_ram != 1) && (family_has_stratixiii_style_ram != 1))) ?
                                            i_clocken0 : ((clock_enable_core_a == "BYPASS") ?
                                            1'b1 : ((clock_enable_core_a == "USE_INPUT_CLKEN") ?
                                            i_clocken0 : ((clock_enable_core_a == "NORMAL") ?
                                            clocken0 : clocken2)));
    
    assign i_core_clocken0_b              = (((family_has_stratixv_style_ram != 1) && (family_has_stratixiii_style_ram != 1))) ?
                                            i_clocken0_b : ((clock_enable_core_b == "BYPASS") ?
                                            1'b1 : ((clock_enable_core_b == "USE_INPUT_CLKEN") ?
                                            i_clocken0_b : ((clock_enable_core_b == "NORMAL") ?
                                            clocken0 : clocken2)));

    assign i_core_clocken1_b              = (((family_has_stratixv_style_ram != 1) && (family_has_stratixiii_style_ram != 1))) ?
                                            i_clocken1_b : ((clock_enable_core_b == "BYPASS") ?
                                            1'b1 : ((clock_enable_core_b == "USE_INPUT_CLKEN") ?
                                            i_clocken1_b : ((clock_enable_core_b == "NORMAL") ?
                                            clocken1 : clocken3)));

    assign i_core_clocken_b               = (address_reg_b == "CLOCK0") ?
                                            i_core_clocken0_b : i_core_clocken1_b;

    // Async clear signal assignment

    // port a clear assigments:

    assign i_indata_aclr_a    = (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) ||
                                (family_base_stratixii == 1 || family_base_cycloneii == 1)) ? 
                                1'b0 : ((indata_aclr_a == "CLEAR0") ? aclr0 : 1'b0);
    assign i_address_aclr_a   = (address_aclr_a == "CLEAR0") ? aclr0 : 1'b0;
    assign i_wrcontrol_aclr_a = (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) || 
                                (family_base_stratixii == 1 || family_base_cycloneii == 1))?
                                1'b0 : ((wrcontrol_aclr_a == "CLEAR0") ? aclr0 : 1'b0);
    assign i_byteena_aclr_a   = (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) ||
                                (family_base_stratixii == 1 || family_base_cycloneii == 1)) ?
                                1'b0 : ((byteena_aclr_a == "CLEAR0") ?
                                aclr0 : ((byteena_aclr_a == "CLEAR1") ?
                                aclr1 : 1'b0));
    assign i_outdata_aclr_a   = (outdata_aclr_a == "CLEAR0") ?
                                aclr0 : ((outdata_aclr_a == "CLEAR1") ?
                                aclr1 : 1'b0);
    // port b clear assignments:
    assign i_indata_aclr_b    = (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) ||
                                (family_base_stratixii == 1 || family_base_cycloneii == 1))?
                                1'b0 : ((indata_aclr_b == "CLEAR0") ?
                                aclr0 : ((indata_aclr_b == "CLEAR1") ?
                                aclr1 : 1'b0));
    assign i_address_aclr_b   = (address_aclr_b == "CLEAR0") ?
                                aclr0 : ((address_aclr_b == "CLEAR1") ?
                                aclr1 : 1'b0);
    assign i_wrcontrol_aclr_b = (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) ||
                                (family_base_stratixii == 1 || family_base_cycloneii == 1))?
                                1'b0 : ((wrcontrol_aclr_b == "CLEAR0") ?
                                aclr0 : ((wrcontrol_aclr_b == "CLEAR1") ?
                                aclr1 : 1'b0));
    assign i_rdcontrol_aclr_b = (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) ||
                                (family_base_stratixii == 1 || family_base_cycloneii == 1)) ?
                                1'b0 : ((rdcontrol_aclr_b == "CLEAR0") ?
                                aclr0 : ((rdcontrol_aclr_b == "CLEAR1") ?
                                aclr1 : 1'b0));
    assign i_byteena_aclr_b   = (((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)) ||
                                (family_base_stratixii == 1 || family_base_cycloneii == 1)) ?
                                1'b0 : ((byteena_aclr_b == "CLEAR0") ?
                                aclr0 : ((byteena_aclr_b == "CLEAR1") ?
                                aclr1 : 1'b0));
    assign i_outdata_aclr_b   = (outdata_aclr_b == "CLEAR0") ?
                                aclr0 : ((outdata_aclr_b == "CLEAR1") ?
                                aclr1 : 1'b0);

    assign i_byteena_a = byteena_a;
    assign i_byteena_b = byteena_b;
    
    
    // Ready to write setting
    
    assign i_good_to_write_a = (((is_bidir_and_wrcontrol_addb_clk0 == 1) || (dual_port_addreg_b_clk0 == 1)) && (i_core_clocken0_b) && (~clock0)) ?
                                    1'b1 : (((is_bidir_and_wrcontrol_addb_clk1 == 1) || (dual_port_addreg_b_clk1 == 1)) && (i_core_clocken1_b) && (~clock1)) ?
                                    1'b1 : i_good_to_write_a2;
                                    
    assign i_good_to_write_b = ((i_core_clocken0_b) && (~clock0)) ? 1'b1 : i_good_to_write_b2;
    
    always @(i_good_to_write_a)
    begin
        i_good_to_write_a2 = i_good_to_write_a;
    end
    
    always @(i_good_to_write_b)
    begin
        i_good_to_write_b2 = i_good_to_write_b;
    end
    
     
    // Port A inputs registered : indata, address, byeteena, wren
    // Aclr status flags get updated here for M-RAM ram_block_type

    always @(posedge clock0)
    begin
    
        if (i_force_reread_a)
        begin
            i_force_reread_a_signal <= ~ i_force_reread_a_signal;
            i_force_reread_a <= 0;
        end
        
        if (i_force_reread_b && ((is_bidir_and_wrcontrol_addb_clk0 == 1) || (dual_port_addreg_b_clk0 == 1)))
        begin
            i_force_reread_b_signal <= ~ i_force_reread_b_signal;
            i_force_reread_b <= 0;
        end

        if (clock1)
            same_clock_pulse0 <= 1'b1;
        else
            same_clock_pulse0 <= 1'b0;

        if (i_address_aclr_a && (i_address_aclr_family_a == 0))
            i_address_reg_a <= 0;

        i_core_clocken_a_reg <= i_core_clocken_a;
        i_core_clocken0_b_reg <= i_core_clocken0_b;

        if (i_core_clocken_a)
        begin

            if (i_force_reread_a1)
            begin
                i_force_reread_a_signal <= ~ i_force_reread_a_signal;
                i_force_reread_a1 <= 0;
            end
            i_read_flag_a <= ~ i_read_flag_a;
            if (i_force_reread_b1 && ((is_bidir_and_wrcontrol_addb_clk0 == 1) || (dual_port_addreg_b_clk0 == 1)))
            begin
                i_force_reread_b_signal <= ~ i_force_reread_b_signal;
                i_force_reread_b1 <= 0;
            end
            if (is_write_on_positive_edge == 1)
            begin
                if (i_wren_reg_a || wren_a)
                begin
                    i_write_flag_a <= ~ i_write_flag_a;
                end
                if (operation_mode != "ROM")
                    i_nmram_write_a <= 1'b0;
            end
            else
            begin
                if (operation_mode != "ROM")
                    i_nmram_write_a <= 1'b1;
            end

            if (((family_stratixv == 1) || (family_stratixiii == 1)) && (is_lutram != 1))
            begin
                good_to_go_a <= 1;
                
                i_rden_reg_a <= rden_a;

                if (i_wrcontrol_aclr_a)
                    i_wren_reg_a <= 0;
                else
                begin
                    i_wren_reg_a <= wren_a;
                end
            end
        end
        else
            i_nmram_write_a <= 1'b0;

        if (i_core_clocken_b)    
            i_address_aclr_b_flag <= 0;

        if (is_lutram)
        begin
            if (i_wrcontrol_aclr_a)
                i_wren_reg_a <= 0;
            else if (i_core_clocken_a)
            begin
                i_wren_reg_a <= wren_a;
            end
        end

        if ((clock_enable_input_a == "BYPASS") ||
            ((clock_enable_input_a == "NORMAL") && clocken0) ||
            ((clock_enable_input_a == "ALTERNATE") && clocken2))
        begin

            // Port A inputs
            
            if (i_indata_aclr_a)
                i_data_reg_a <= 0;
            else
                i_data_reg_a <= data_a;

            if (i_address_aclr_a && (i_address_aclr_family_a == 0))
                i_address_reg_a <= 0;
            else if (!addressstall_a)
                i_address_reg_a <= address_a;

            if (i_byteena_aclr_a)
            begin
                i_byteena_mask_reg_a <= {width_a{1'b1}};
                i_byteena_mask_reg_a_out <= 0;
                i_byteena_mask_reg_a_x <= 0;
                i_byteena_mask_reg_a_out_b <= {width_a{1'bx}};
            end
            else
            begin
               
                if (width_byteena_a == 1)
                begin
                    i_byteena_mask_reg_a <= {width_a{i_byteena_a[0]}};
                    i_byteena_mask_reg_a_out <= (i_byteena_a[0])? {width_a{1'b0}} : {width_a{1'bx}};
                    i_byteena_mask_reg_a_out_b <= (i_byteena_a[0])? {width_a{1'bx}} : {width_a{1'b0}};
                    i_byteena_mask_reg_a_x <= ((i_byteena_a[0]) || (i_byteena_a[0] == 1'b0))? {width_a{1'b0}} : {width_a{1'bx}};
                end
                else
                    for (k = 0; k < width_a; k = k+1)
                    begin
                        i_byteena_mask_reg_a[k] <= i_byteena_a[k/i_byte_size];
                        i_byteena_mask_reg_a_out_b[k] <= (i_byteena_a[k/i_byte_size])? 1'bx: 1'b0;
                        i_byteena_mask_reg_a_out[k] <= (i_byteena_a[k/i_byte_size])? 1'b0: 1'bx;
                        i_byteena_mask_reg_a_x[k] <= ((i_byteena_a[k/i_byte_size]) || (i_byteena_a[k/i_byte_size] == 1'b0))? 1'b0: 1'bx;
                    end
               
            end

            if (((family_stratixv == 0) && (family_stratixiii == 0)) || 
                (is_lutram == 1))
            begin
                good_to_go_a <= 1;
            
                i_rden_reg_a <= rden_a;
                
                if (i_wrcontrol_aclr_a)
                    i_wren_reg_a <= 0;
                else
                begin
                    i_wren_reg_a <= wren_a;
                end
            end

        end
        
        
        if (i_indata_aclr_a)
            i_data_reg_a <= 0;

        if (i_address_aclr_a && (i_address_aclr_family_a == 0))
            i_address_reg_a <= 0;

        if (i_byteena_aclr_a)
        begin
            i_byteena_mask_reg_a <= {width_a{1'b1}};
            i_byteena_mask_reg_a_out <= 0;
            i_byteena_mask_reg_a_x <= 0;
            i_byteena_mask_reg_a_out_b <= {width_a{1'bx}};
        end
        
        
        // Port B

        if (is_bidir_and_wrcontrol_addb_clk0)
        begin

            if (i_core_clocken0_b)
            begin
                if ((family_stratixv == 1) || (family_stratixiii == 1))
                begin
                    good_to_go_b <= 1;
                    
                    i_rden_reg_b <= rden_b;
    
                    if (i_wrcontrol_aclr_b)
                        i_wren_reg_b <= 0;
                    else
                    begin
                        i_wren_reg_b <= wren_b;
                    end
                end
                
                i_read_flag_b <= ~i_read_flag_b;
                    
                if (is_write_on_positive_edge == 1)
                begin
                    if (i_wren_reg_b || wren_b)
                    begin
                        i_write_flag_b <= ~ i_write_flag_b;
                    end
                    i_nmram_write_b <= 1'b0;
                end
                else
                    i_nmram_write_b <= 1'b1;
            
            end
            else
                i_nmram_write_b <= 1'b0;
                
                
            if ((clock_enable_input_b == "BYPASS") ||
                ((clock_enable_input_b == "NORMAL") && clocken0) ||
                ((clock_enable_input_b == "ALTERNATE") && clocken2))
            begin

                // Port B inputs

                if (i_indata_aclr_b)
                    i_data_reg_b <= 0;
                else
                    i_data_reg_b <= data_b;
        

                if ((family_stratixv == 0) && (family_stratixiii == 0))
                begin
                    good_to_go_b <= 1;
                
                    i_rden_reg_b <= rden_b;
    
                    if (i_wrcontrol_aclr_b)
                        i_wren_reg_b <= 0;
                    else
                    begin
                        i_wren_reg_b <= wren_b;
                    end
                end

                if (i_address_aclr_b && (i_address_aclr_family_b == 0))
                    i_address_reg_b <= 0;
                else if (!addressstall_b)
                    i_address_reg_b <= address_b;

                if (i_byteena_aclr_b)
                begin
                    i_byteena_mask_reg_b <= {width_b{1'b1}};
                    i_byteena_mask_reg_b_out <= 0;
                    i_byteena_mask_reg_b_x <= 0;
                    i_byteena_mask_reg_b_out_a <= {width_b{1'bx}};
                end
                else
                begin
                   
                    if (width_byteena_b == 1)
                    begin
                        i_byteena_mask_reg_b <= {width_b{i_byteena_b[0]}};
                        i_byteena_mask_reg_b_out_a <= (i_byteena_b[0])? {width_b{1'bx}} : {width_b{1'b0}};
                        i_byteena_mask_reg_b_out <= (i_byteena_b[0])? {width_b{1'b0}} : {width_b{1'bx}};
                        i_byteena_mask_reg_b_x <= ((i_byteena_b[0]) || (i_byteena_b[0] == 1'b0))? {width_b{1'b0}} : {width_b{1'bx}};
                    end
                    else
                        for (k2 = 0; k2 < width_b; k2 = k2 + 1)
                        begin
                            i_byteena_mask_reg_b[k2] <= i_byteena_b[k2/i_byte_size];
                            i_byteena_mask_reg_b_out_a[k2] <= (i_byteena_b[k2/i_byte_size])? 1'bx : 1'b0;
                            i_byteena_mask_reg_b_out[k2] <= (i_byteena_b[k2/i_byte_size])? 1'b0 : 1'bx;
                            i_byteena_mask_reg_b_x[k2] <= ((i_byteena_b[k2/i_byte_size]) || (i_byteena_b[k2/i_byte_size] == 1'b0))? 1'b0 : 1'bx;
                        end
                    
                end

            end
            
            
            if (i_indata_aclr_b)
                i_data_reg_b <= 0;

            if (i_wrcontrol_aclr_b)
                i_wren_reg_b <= 0;

            if (i_address_aclr_b && (i_address_aclr_family_b == 0))
                i_address_reg_b <= 0;

            if (i_byteena_aclr_b)
            begin
                i_byteena_mask_reg_b <= {width_b{1'b1}};
                i_byteena_mask_reg_b_out <= 0;
                i_byteena_mask_reg_b_x <= 0;
                i_byteena_mask_reg_b_out_a <= {width_b{1'bx}};
            end
        end
            
        if (dual_port_addreg_b_clk0)
        begin
            if (i_address_aclr_b && (i_address_aclr_family_b == 0))
                i_address_reg_b <= 0;

            if (i_core_clocken0_b)
            begin
                if (((family_stratixv == 1) || (family_stratixiii == 1)) && !is_lutram)
                begin
                    good_to_go_b <= 1;
                    
                    if (i_rdcontrol_aclr_b)
                        i_rden_reg_b <= 1'b1;
                    else
                        i_rden_reg_b <= rden_b;
                end
                
                i_read_flag_b <= ~ i_read_flag_b;
            end
            
            if ((clock_enable_input_b == "BYPASS") ||
                ((clock_enable_input_b == "NORMAL") && clocken0) ||
                ((clock_enable_input_b == "ALTERNATE") && clocken2))
            begin
                if (((family_stratixv == 0) && (family_stratixiii == 0)) || is_lutram)
                begin
                    good_to_go_b <= 1;
                
                    if (i_rdcontrol_aclr_b)
                        i_rden_reg_b <= 1'b1;
                    else
                        i_rden_reg_b <= rden_b;
                end

                if (i_address_aclr_b && (i_address_aclr_family_b == 0))
                    i_address_reg_b <= 0;
                else if (!addressstall_b)
                    i_address_reg_b <= address_b;

            end
            
            
            if (i_rdcontrol_aclr_b)
                i_rden_reg_b <= 1'b1;

            if (i_address_aclr_b && (i_address_aclr_family_b == 0))
                i_address_reg_b <= 0;

        end

    end


    always @(negedge clock0)
    begin
       
        if (clock1)
            same_clock_pulse0 <= 1'b0;

        if (is_write_on_positive_edge == 0)
        begin
            if (i_nmram_write_a == 1'b1)
            begin
                i_write_flag_a <= ~ i_write_flag_a;
                
                if (is_lutram)
                    i_read_flag_a <= ~i_read_flag_a;
            end 

            
            if (is_bidir_and_wrcontrol_addb_clk0)
            begin
                if (i_nmram_write_b == 1'b1)
                    i_write_flag_b <= ~ i_write_flag_b;
            end
        end

        if (i_core_clocken0_b && (lutram_dual_port_fast_read == 1) && (dual_port_addreg_b_clk0 == 1))
        begin
            i_read_flag_b <= ~i_read_flag_b;
        end

    end



    always @(posedge clock1)
    begin
        i_core_clocken1_b_reg <= i_core_clocken1_b;

        if (i_force_reread_b && ((is_bidir_and_wrcontrol_addb_clk1 == 1) || (dual_port_addreg_b_clk1 == 1)))
        begin
            i_force_reread_b_signal <= ~ i_force_reread_b_signal;
            i_force_reread_b <= 0;
        end
        
        if (clock0)
            same_clock_pulse1 <= 1'b1;
        else
            same_clock_pulse1 <= 1'b0;

        if (i_core_clocken_b)    
            i_address_aclr_b_flag <= 0;

        if (is_bidir_and_wrcontrol_addb_clk1)
        begin

            if (i_core_clocken1_b)
            begin
                i_read_flag_b <= ~i_read_flag_b;
    
                if ((family_stratixv == 1) || (family_stratixiii == 1))
                begin
                    good_to_go_b <= 1;
                    
                    i_rden_reg_b <= rden_b;
    
                    if (i_wrcontrol_aclr_b)
                        i_wren_reg_b <= 0;
                    else
                    begin
                        i_wren_reg_b <= wren_b;
                    end
                end
                
                if (is_write_on_positive_edge == 1)
                begin
                    if (i_wren_reg_b || wren_b)
                    begin
                        i_write_flag_b <= ~ i_write_flag_b;
                    end
                    i_nmram_write_b <= 1'b0;
                end
                else
                    i_nmram_write_b <= 1'b1;
            end
            else
                i_nmram_write_b <= 1'b0;
                
        
            if ((clock_enable_input_b == "BYPASS") ||
                ((clock_enable_input_b == "NORMAL") && clocken1) ||
                ((clock_enable_input_b == "ALTERNATE") && clocken3))
            begin
                
                // Port B inputs
                
                if (address_reg_b == "CLOCK1")
                begin
                    if (i_indata_aclr_b)
                        i_data_reg_b <= 0;
                    else
                        i_data_reg_b <= data_b;
                end

                if ((family_stratixv == 0) && (family_stratixiii == 0))
                begin
                    good_to_go_b <= 1;
    
                    i_rden_reg_b <= rden_b;
    
                    if (i_wrcontrol_aclr_b)
                        i_wren_reg_b <= 0;
                    else
                    begin
                        i_wren_reg_b <= wren_b;
                    end
                end

                if (i_address_aclr_b && (i_address_aclr_family_b == 0))
                    i_address_reg_b <= 0;
                else if (!addressstall_b)
                    i_address_reg_b <= address_b;

                if (i_byteena_aclr_b)
                begin
                    i_byteena_mask_reg_b <= {width_b{1'b1}};
                    i_byteena_mask_reg_b_out <= 0;
                    i_byteena_mask_reg_b_x <= 0;
                    i_byteena_mask_reg_b_out_a <= {width_b{1'bx}};
                end
                else
                begin
                    if (width_byteena_b == 1)
                    begin
                        i_byteena_mask_reg_b <= {width_b{i_byteena_b[0]}};
                        i_byteena_mask_reg_b_out_a <= (i_byteena_b[0])? {width_b{1'bx}} : {width_b{1'b0}};
                        i_byteena_mask_reg_b_out <= (i_byteena_b[0])? {width_b{1'b0}} : {width_b{1'bx}};
                        i_byteena_mask_reg_b_x <= ((i_byteena_b[0]) || (i_byteena_b[0] == 1'b0))? {width_b{1'b0}} : {width_b{1'bx}};
                    end
                    else
                        for (k2 = 0; k2 < width_b; k2 = k2 + 1)
                        begin
                            i_byteena_mask_reg_b[k2] <= i_byteena_b[k2/i_byte_size];
                            i_byteena_mask_reg_b_out_a[k2] <= (i_byteena_b[k2/i_byte_size])? 1'bx : 1'b0;
                            i_byteena_mask_reg_b_out[k2] <= (i_byteena_b[k2/i_byte_size])? 1'b0 : 1'bx;
                            i_byteena_mask_reg_b_x[k2] <= ((i_byteena_b[k2/i_byte_size]) || (i_byteena_b[k2/i_byte_size] == 1'b0))? 1'b0 : 1'bx;
                        end
                
                end

            end
            
            
            if (i_indata_aclr_b)
                i_data_reg_b <= 0;

            if (i_wrcontrol_aclr_b)
                i_wren_reg_b <= 0;

            if (i_address_aclr_b && (i_address_aclr_family_b == 0))
                i_address_reg_b <= 0;

            if (i_byteena_aclr_b)
            begin
                i_byteena_mask_reg_b <= {width_b{1'b1}};
                i_byteena_mask_reg_b_out <= 0;
                i_byteena_mask_reg_b_x <= 0;
                i_byteena_mask_reg_b_out_a <= {width_b{1'bx}};
            end
        end

        if (dual_port_addreg_b_clk1)
        begin
            if (i_address_aclr_b && (i_address_aclr_family_b == 0))
                i_address_reg_b <= 0;

            if (i_core_clocken1_b)
            begin
                if (i_force_reread_b1)
                begin
                    i_force_reread_b_signal <= ~ i_force_reread_b_signal;
                    i_force_reread_b1 <= 0;
                end
                if (((family_stratixv == 1) || (family_stratixiii == 1)) && !is_lutram)
                begin
                    good_to_go_b <= 1;
                    
                    if (i_rdcontrol_aclr_b)
                    begin
                        i_rden_reg_b <= 1'b1;
                    end
                    else
                    begin
                        i_rden_reg_b <= rden_b;
                    end
                end

                i_read_flag_b <= ~i_read_flag_b;
            end
            
            if ((clock_enable_input_b == "BYPASS") ||
                ((clock_enable_input_b == "NORMAL") && clocken1) ||
                ((clock_enable_input_b == "ALTERNATE") && clocken3))
            begin
                if (((family_stratixv == 0) && (family_stratixiii == 0)) || is_lutram)
                begin
                    good_to_go_b <= 1;
                
                    if (i_rdcontrol_aclr_b)
                    begin
                        i_rden_reg_b <= 1'b1;
                    end
                    else
                    begin
                        i_rden_reg_b <= rden_b;
                    end
                end
    
                if (i_address_aclr_b && (i_address_aclr_family_b == 0))
                    i_address_reg_b <= 0;
                else if (!addressstall_b)
                    i_address_reg_b <= address_b;

            end
            
            
            if (i_rdcontrol_aclr_b)
                i_rden_reg_b <= 1'b1;

            if (i_address_aclr_b && (i_address_aclr_family_b == 0))
                i_address_reg_b <= 0;
                
        end

    end

    always @(negedge clock1)
    begin
       
        if (clock0)
            same_clock_pulse1 <= 1'b0;
            
        if (is_write_on_positive_edge == 0)
        begin
           
            if (is_bidir_and_wrcontrol_addb_clk1)
            begin
                if (i_nmram_write_b == 1'b1)
                    i_write_flag_b <= ~ i_write_flag_b;
            end
        end

        if (i_core_clocken1_b && (lutram_dual_port_fast_read == 1) && (dual_port_addreg_b_clk1 ==1))
        begin
            i_read_flag_b <= ~i_read_flag_b;
        end

    end
    
    always @(posedge i_address_aclr_b)
    begin
        if ((is_lutram == 1) && (operation_mode == "DUAL_PORT") && (i_address_aclr_family_b == 0))
            i_read_flag_b <= ~i_read_flag_b;
    end

    always @(posedge i_address_aclr_a)
    begin
        if ((is_lutram == 1) && (operation_mode == "ROM") && (i_address_aclr_family_a == 0))
            i_read_flag_a <= ~i_read_flag_a;
    end
    
    always @(posedge i_outdata_aclr_a)
    begin
        if (((family_stratixv == 1) || (family_cycloneiii == 1)) && 
            ((outdata_reg_a != "CLOCK0") && (outdata_reg_a != "CLOCK1")))
            i_read_flag_a <= ~i_read_flag_a;
    end

    always @(posedge i_outdata_aclr_b)
    begin
        if (((family_stratixv == 1) || (family_cycloneiii == 1)) && 
            ((outdata_reg_b != "CLOCK0") && (outdata_reg_b != "CLOCK1")))
            i_read_flag_b <= ~i_read_flag_b;
    end
    
    // Port A writting -------------------------------------------------------------

    always @(posedge i_write_flag_a or negedge i_write_flag_a)
    begin
        if ((operation_mode == "BIDIR_DUAL_PORT") ||
            (operation_mode == "DUAL_PORT") ||
            (operation_mode == "SINGLE_PORT"))
        begin

            if ((i_wren_reg_a) && (i_good_to_write_a))
            begin
                i_aclr_flag_a = 0;

                if (i_indata_aclr_a)
                begin
                    if (i_data_reg_a != 0)
                    begin
                        mem_data[i_address_reg_a] = {width_a{1'bx}};

                        if (enable_mem_data_b_reading)
                        begin
                            j3 = i_address_reg_a * width_a;
                            for (i5 = 0; i5 < width_a; i5 = i5+1)
                            begin
                                    j3_plus_i5 = j3 + i5;
                                    temp_wb = mem_data_b[j3_plus_i5 / width_b];
                                    temp_wb[j3_plus_i5 % width_b] = {1'bx};
                                    mem_data_b[j3_plus_i5 / width_b] = temp_wb;
                            end
                        end
                        i_aclr_flag_a = 1;
                    end
                end
                else if (i_byteena_aclr_a)
                begin
                    if (i_byteena_mask_reg_a != {width_a{1'b1}})
                    begin
                        mem_data[i_address_reg_a] = {width_a{1'bx}};
                        
                        if (enable_mem_data_b_reading)
                        begin
                            j3 = i_address_reg_a * width_a;
                            for (i5 = 0; i5 < width_a; i5 = i5+1)
                            begin
                                    j3_plus_i5 = j3 + i5;
                                    temp_wb = mem_data_b[j3_plus_i5 / width_b];
                                    temp_wb[j3_plus_i5 % width_b] = {1'bx};
                                    mem_data_b[j3_plus_i5 / width_b] = temp_wb;
                            end
                        end
                        i_aclr_flag_a = 1;
                    end
                end
                else if (i_address_aclr_a && (i_address_aclr_family_a == 0))
                begin
                    if (i_address_reg_a != 0)
                    begin
                        wa_mult_x_ii = {width_a{1'bx}};
                        for (i4 = 0; i4 < i_numwords_a; i4 = i4 + 1)
                            mem_data[i4] = wa_mult_x_ii;
                            
                        if (enable_mem_data_b_reading)
                        begin
                            for (i4 = 0; i4 < i_numwords_b; i4 = i4 + 1)
                                mem_data_b[i4] = {width_b{1'bx}};
                        end

                        i_aclr_flag_a = 1;
                    end
                end

                if (i_aclr_flag_a == 0)
                begin
                    i_original_data_a = mem_data[i_address_reg_a];
                    i_original_address_a = i_address_reg_a;
                    i_data_write_time_a = $time;
                    temp_wa = mem_data[i_address_reg_a];
                    
                    port_a_bit_count_low = i_address_reg_a * width_a;
                    port_b_bit_count_low = i_address_reg_b * width_b;
                    port_b_bit_count_high = port_b_bit_count_low + width_b;
                    
                    for (i5 = 0; i5 < width_a; i5 = i5 + 1)
                    begin
                        i_byteena_count = port_a_bit_count_low % width_b;

                        if ((port_a_bit_count_low >= port_b_bit_count_low) && (port_a_bit_count_low < port_b_bit_count_high) &&
                            ((i_core_clocken0_b_reg && (is_bidir_and_wrcontrol_addb_clk0 == 1)) || (i_core_clocken1_b_reg && (is_bidir_and_wrcontrol_addb_clk1 == 1))) && 
                            (i_wren_reg_b) && ((same_clock_pulse0 && same_clock_pulse1) || (address_reg_b == "CLOCK0")) &&
                            (i_byteena_mask_reg_b[i_byteena_count]) && (i_byteena_mask_reg_a[i5]))
                            temp_wa[i5] = {1'bx};
                        else if (i_byteena_mask_reg_a[i5])
                            temp_wa[i5] = i_data_reg_a[i5];

                        if (enable_mem_data_b_reading)
                        begin
                            temp_wb = mem_data_b[port_a_bit_count_low / width_b];
                            temp_wb[port_a_bit_count_low % width_b] = temp_wa[i5];
                            mem_data_b[port_a_bit_count_low / width_b] = temp_wb;
                        end

                        port_a_bit_count_low = port_a_bit_count_low + 1;
                    end

                    mem_data[i_address_reg_a] = temp_wa;

                    if (((cread_during_write_mode_mixed_ports == "OLD_DATA") && (is_write_on_positive_edge == 1) && (address_reg_b == "CLOCK0")) ||
                        ((lutram_dual_port_fast_read == 1) && (operation_mode == "DUAL_PORT")))
                        i_read_flag_b = ~i_read_flag_b;
                        
                    if ((read_during_write_mode_port_a == "OLD_DATA") ||
                        ((is_lutram == 1) && (read_during_write_mode_port_a == "DONT_CARE")))
                        i_read_flag_a = ~i_read_flag_a;
                end

            end
        end
    end    // Port A writting ----------------------------------------------------


    // Port B writting -----------------------------------------------------------

    always @(posedge i_write_flag_b or negedge i_write_flag_b)
    begin
        if (operation_mode == "BIDIR_DUAL_PORT")
        begin

            if ((i_wren_reg_b) && (i_good_to_write_b))
            begin
            
                i_aclr_flag_b = 0;

                // RAM content is following width_a
                // if Port B is of different width, need to make some adjustments

                if (i_indata_aclr_b)
                begin
                    if (i_data_reg_b != 0)
                    begin
                        if (enable_mem_data_b_reading)
                            mem_data_b[i_address_reg_b] = {width_b{1'bx}};
                       
                        if (width_a == width_b)
                            mem_data[i_address_reg_b] = {width_b{1'bx}};
                        else
                        begin
                            j = i_address_reg_b * width_b;
                            for (i2 = 0; i2 < width_b; i2 = i2+1)
                            begin
                                    j_plus_i2 = j + i2;
                                    temp_wa = mem_data[j_plus_i2 / width_a];
                                    temp_wa[j_plus_i2 % width_a] = {1'bx};
                                    mem_data[j_plus_i2 / width_a] = temp_wa;
                            end
                        end
                        i_aclr_flag_b = 1;
                    end
                end
                else if (i_byteena_aclr_b)
                begin
                    if (i_byteena_mask_reg_b != {width_b{1'b1}})
                    begin
                        if (enable_mem_data_b_reading)
                            mem_data_b[i_address_reg_b] = {width_b{1'bx}};
                        
                        if (width_a == width_b)
                            mem_data[i_address_reg_b] = {width_b{1'bx}};
                        else
                        begin
                            j = i_address_reg_b * width_b;
                            for (i2 = 0; i2 < width_b; i2 = i2+1)
                            begin
                                j_plus_i2 = j + i2;
                                j_plus_i2_div_a = j_plus_i2 / width_a;
                                temp_wa = mem_data[j_plus_i2_div_a];
                                temp_wa[j_plus_i2 % width_a] = {1'bx};
                                mem_data[j_plus_i2_div_a] = temp_wa;
                            end
                        end
                        i_aclr_flag_b = 1;
                    end
                end
                else if (i_address_aclr_b && (i_address_aclr_family_b == 0))
                begin
                    if (i_address_reg_b != 0)
                    begin
                        
                        if (enable_mem_data_b_reading)
                        begin
                            for (i2 = 0; i2 < i_numwords_b; i2 = i2 + 1)
                            begin
                                mem_data_b[i2] = {width_b{1'bx}};
                            end
                        end
                        
                        wa_mult_x_iii = {width_a{1'bx}};
                        for (i2 = 0; i2 < i_numwords_a; i2 = i2 + 1)
                        begin
                            mem_data[i2] = wa_mult_x_iii;
                        end
                        i_aclr_flag_b = 1;
                    end
                end

                if (i_aclr_flag_b == 0)
                begin
                        port_b_bit_count_low = i_address_reg_b * width_b;
                        port_a_bit_count_low = i_address_reg_a * width_a;
                        port_a_bit_count_high = port_a_bit_count_low + width_a;
                        
                        for (i2 = 0; i2 < width_b; i2 = i2 + 1)
                        begin
                            port_b_bit_count_high = port_b_bit_count_low + i2;
                            temp_wa = mem_data[port_b_bit_count_high / width_a];
                            i_original_data_b[i2] = temp_wa[port_b_bit_count_high % width_a];
                            
                            if ((port_b_bit_count_high >= port_a_bit_count_low) && (port_b_bit_count_high < port_a_bit_count_high) &&
                                ((same_clock_pulse0 && same_clock_pulse1) || (address_reg_b == "CLOCK0")) &&
                                (i_core_clocken_a_reg) && (i_wren_reg_a) &&
                                (i_byteena_mask_reg_a[port_b_bit_count_high % width_a]) && (i_byteena_mask_reg_b[i2]))
                                temp_wa[port_b_bit_count_high % width_a] = {1'bx};
                            else if (i_byteena_mask_reg_b[i2])
                                temp_wa[port_b_bit_count_high % width_a] = i_data_reg_b[i2];
                            
                            mem_data[port_b_bit_count_high / width_a] = temp_wa;
                            temp_wb[i2] = temp_wa[port_b_bit_count_high % width_a];
                        end

                        if (enable_mem_data_b_reading)
                            mem_data_b[i_address_reg_b] = temp_wb;

                    if ((read_during_write_mode_port_b == "OLD_DATA") && (is_write_on_positive_edge == 1))
                        i_read_flag_b = ~i_read_flag_b;
                        
                    if ((cread_during_write_mode_mixed_ports == "OLD_DATA")&& (address_reg_b == "CLOCK0") && (is_write_on_positive_edge == 1))
                        i_read_flag_a = ~i_read_flag_a;

                end

            end
            
        end
    end


    // Port A reading

    always @(i_read_flag_a)
    begin
        if ((operation_mode == "BIDIR_DUAL_PORT") ||
            (operation_mode == "SINGLE_PORT") ||
            (operation_mode == "ROM"))
        begin
            if (~good_to_go_a && (is_lutram == 0))
            begin

                if (((i_ram_block_type == "M-RAM") || (i_ram_block_type == "MEGARAM") ||
                        ((i_ram_block_type == "AUTO") && (cread_during_write_mode_mixed_ports == "DONT_CARE"))) && 
                    (operation_mode != "ROM") &&
                    ((family_has_stratixv_style_ram == 0) && (family_has_stratixiii_style_ram == 0)))
                    i_q_tmp2_a = {width_a{1'bx}};
                else
                    i_q_tmp2_a = 0;
            end
            else
            begin
                if (i_rden_reg_a)
                begin
                    // read from RAM content or flow through for write cycle
                    if (i_wren_reg_a)
                    begin
                        if (i_core_clocken_a)
                        begin
                            if (read_during_write_mode_port_a == "NEW_DATA_NO_NBE_READ")
                                if (is_lutram && clock0)
                                    i_q_tmp2_a = mem_data[i_address_reg_a];
                                else
                                    i_q_tmp2_a = ((i_data_reg_a & i_byteena_mask_reg_a) |
                                                ({width_a{1'bx}} & ~i_byteena_mask_reg_a));
                            else if (read_during_write_mode_port_a == "NEW_DATA_WITH_NBE_READ")
                                if (is_lutram && clock0)
                                    i_q_tmp2_a = mem_data[i_address_reg_a];
                                else
                                    i_q_tmp2_a = (i_data_reg_a & i_byteena_mask_reg_a) | (mem_data[i_address_reg_a] & ~i_byteena_mask_reg_a) ^ i_byteena_mask_reg_a_x;
                            else if (read_during_write_mode_port_a == "OLD_DATA")
                                i_q_tmp2_a = i_original_data_a;
                            else
                                if ((lutram_single_port_fast_read == 0) && (i_ram_block_type != "AUTO"))
                                begin
                                    if ((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1))
                                        i_q_tmp2_a = {width_a{1'bx}};
                                    else
                                        i_q_tmp2_a = i_original_data_a;
                                end
                                else
                                    if (is_lutram)
                                        i_q_tmp2_a = mem_data[i_address_reg_a]; 
                                    else
                                        i_q_tmp2_a = i_data_reg_a ^ i_byteena_mask_reg_a_out;
                        end
                        else
                            i_q_tmp2_a = mem_data[i_address_reg_a];
                    end
                    else
                        i_q_tmp2_a = mem_data[i_address_reg_a];

                    if (is_write_on_positive_edge == 1)
                    begin

                        if (is_bidir_and_wrcontrol_addb_clk0 || (same_clock_pulse0 && same_clock_pulse1))
                        begin
                            // B write, A read
                        if ((i_wren_reg_b & ~i_wren_reg_a) & 
                            ((((is_bidir_and_wrcontrol_addb_clk0 & i_clocken0_b) || 
                            (is_bidir_and_wrcontrol_addb_clk1 & i_clocken1_b)) && ((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1))) ||
                            (((is_bidir_and_wrcontrol_addb_clk0 & i_core_clocken0_b) || 
                            (is_bidir_and_wrcontrol_addb_clk1 & i_core_clocken1_b)) && ((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)))))
                            begin
                                add_reg_a_mult_wa = i_address_reg_a * width_a;
                                add_reg_b_mult_wb = i_address_reg_b * width_b;
                                add_reg_a_mult_wa_pl_wa = add_reg_a_mult_wa + width_a;
                                add_reg_b_mult_wb_pl_wb = add_reg_b_mult_wb + width_b;

                                if (
                                    ((add_reg_a_mult_wa >=
                                        add_reg_b_mult_wb) &&
                                    (add_reg_a_mult_wa <=
                                        (add_reg_b_mult_wb_pl_wb - 1)))
                                        ||
                                    (((add_reg_a_mult_wa_pl_wa - 1) >=
                                        add_reg_b_mult_wb) &&
                                    ((add_reg_a_mult_wa_pl_wa - 1) <=
                                        (add_reg_b_mult_wb_pl_wb - 1)))
                                        ||
                                    ((add_reg_b_mult_wb >=
                                        add_reg_a_mult_wa) &&
                                    (add_reg_b_mult_wb <=
                                        (add_reg_a_mult_wa_pl_wa - 1)))
                                        ||
                                    (((add_reg_b_mult_wb_pl_wb - 1) >=
                                        add_reg_a_mult_wa) &&
                                    ((add_reg_b_mult_wb_pl_wb - 1) <=
                                        (add_reg_a_mult_wa_pl_wa - 1)))
                                    )
                                        for (i3 = add_reg_a_mult_wa;
                                                i3 < add_reg_a_mult_wa_pl_wa;
                                                i3 = i3 + 1)
                                        begin
                                            if ((i3 >= add_reg_b_mult_wb) &&
                                                (i3 <= (add_reg_b_mult_wb_pl_wb - 1)))
                                            begin
                                            
                                                if (read_during_write_mode_mixed_ports == "OLD_DATA")
                                                begin
                                                    i_byteena_count = i3 - add_reg_b_mult_wb;
                                                    i_q_tmp2_a_idx = (i3 - add_reg_a_mult_wa);
                                                    i_q_tmp2_a[i_q_tmp2_a_idx] = i_original_data_b[i_byteena_count];
                                                end
                                                else
                                                begin
                                                    i_byteena_count = i3 - add_reg_b_mult_wb;
                                                    i_q_tmp2_a_idx = (i3 - add_reg_a_mult_wa);
                                                    i_q_tmp2_a[i_q_tmp2_a_idx] = i_q_tmp2_a[i_q_tmp2_a_idx] ^ i_byteena_mask_reg_b_out_a[i_byteena_count];
                                                end
                                                
                                            end
                                        end
                            end
                        end
                    end
                end
                
                if ((is_lutram == 1) && i_address_aclr_a && (i_address_aclr_family_a == 0) && (operation_mode == "ROM"))
                    i_q_tmp2_a = mem_data[0];
                
                if (((family_stratixv == 1) || (family_cycloneiii == 1)) && 
                    (is_lutram != 1) &&
                    (i_outdata_aclr_a) &&
                    (outdata_reg_a != "CLOCK0") && (outdata_reg_a != "CLOCK1"))
                    i_q_tmp2_a = {width_a{1'b0}};
            end // end good_to_go_a
        end
    end


    // assigning the correct output values for i_q_tmp_a (non-registered output)
    always @(i_q_tmp2_a or i_wren_reg_a or i_data_reg_a or i_address_aclr_a or
             i_address_reg_a or i_byteena_mask_reg_a_out or i_numwords_a or i_outdata_aclr_a or i_force_reread_a_signal or i_original_data_a)
    begin
        if (i_address_reg_a >= i_numwords_a)
        begin
            if (i_wren_reg_a && i_core_clocken_a)
                i_q_tmp_a <= i_q_tmp2_a;
            else
                i_q_tmp_a <= {width_a{1'bx}};
            if (i_rden_reg_a == 1)
            begin
                $display("Warning : Address pointed at port A is out of bound!");
                $display("Time: %0t  Instance: %m", $time);
            end
        end
        else 
            begin
                if (i_outdata_aclr_a_prev && ~ i_outdata_aclr_a && 
                    (family_has_stratixv_style_ram != 1) && (family_has_stratixiii_style_ram == 1) &&
                    (is_lutram != 1))
                begin
                    i_outdata_aclr_a_prev = i_outdata_aclr_a;
                    i_force_reread_a <= 1;
                end
                else if (~i_address_aclr_a_prev && i_address_aclr_a && (i_address_aclr_family_a == 0) && s3_address_aclr_a)
                begin
                    if (i_rden_reg_a)
                        i_q_tmp_a <= {width_a{1'bx}};
                    i_force_reread_a1 <= 1;
                end
                else if ((i_force_reread_a1 == 0) && !(i_address_aclr_a_prev && ~i_address_aclr_a && (i_address_aclr_family_a == 0) && s3_address_aclr_a))
                begin
                    i_q_tmp_a <= i_q_tmp2_a;
                end
            end
            if ((i_outdata_aclr_a) && (s3_address_aclr_a))
            begin
                i_q_tmp_a <= {width_a{1'b0}};
                i_outdata_aclr_a_prev <= i_outdata_aclr_a;
            end
            i_address_aclr_a_prev <= i_address_aclr_a;
    end


    // Port A outdata output registered
    generate if (outdata_reg_a == "CLOCK1")
    begin
        always @(posedge clock1 or posedge i_outdata_aclr_a)
        begin
            if (i_outdata_aclr_a)
                i_q_reg_a <= 0;
            else if (i_outdata_clken_a)
            begin           
                i_q_reg_a <= i_q_tmp_a;
                if (i_core_clocken_a)
                i_address_aclr_a_flag <= 0;
            end
            else if (i_core_clocken_a)
                i_address_aclr_a_flag <= 0;
        end
    end
    else if (outdata_reg_a == "CLOCK0")
    begin
        always @(posedge clock0 or posedge i_outdata_aclr_a)
        begin
            if (i_outdata_aclr_a)
                i_q_reg_a <= 0;
            else if (i_outdata_clken_a)
            begin           
                if ((i_address_aclr_a_flag == 1) &&
                    (family_stratixv || family_stratixiii) && (is_lutram != 1))
                    i_q_reg_a <= 'bx;
                else
                    i_q_reg_a <= i_q_tmp_a;
                if (i_core_clocken_a)
                i_address_aclr_a_flag <= 0;
            end
            else if (i_core_clocken_a)
                i_address_aclr_a_flag <= 0;
        end
    end
    else 
    begin
        always @(posedge i_outdata_aclr_a)
        begin
            if (i_outdata_aclr_a)
                i_q_reg_a <= 0;
        end
    end
    endgenerate

    // Latch for address aclr till outclock enabled
    always @(posedge i_address_aclr_a or posedge i_outdata_aclr_a)
    begin
        if (i_outdata_aclr_a)
            i_address_aclr_a_flag <= 0;
        else
            if (i_rden_reg_a && (i_address_aclr_family_a == 0))
                i_address_aclr_a_flag <= 1;
    end

    // Port A : assigning the correct output values for q_a
    assign q_a = (operation_mode == "DUAL_PORT") ?
                    {width_a{1'b0}} : (((outdata_reg_a == "CLOCK0") ||
                            (outdata_reg_a == "CLOCK1")) ?
                    i_q_reg_a : i_q_tmp_a);


    // Port B reading
    always @(i_read_flag_b)
    begin
        if ((operation_mode == "BIDIR_DUAL_PORT") ||
            (operation_mode == "DUAL_PORT"))
        begin
            if (~good_to_go_b && (is_lutram == 0))
            begin
                
                if ((check_simultaneous_read_write == 1) &&
                    ((family_has_stratixv_style_ram == 0) && (family_has_stratixiii_style_ram == 0)) &&
                    (family_cycloneii == 0))
                    i_q_tmp2_b = {width_b{1'bx}};
                else
                    i_q_tmp2_b = 0;
            end
            else
            begin
                if (i_rden_reg_b)
                begin
                    //If width_a is equal to b, no address calculation is needed
                    if (width_a == width_b)
                    begin

                        // read from memory or flow through for write cycle
                        if (i_wren_reg_b && (((is_bidir_and_wrcontrol_addb_clk0 == 1) && i_core_clocken0_b) || 
                            ((is_bidir_and_wrcontrol_addb_clk1 == 1) && i_core_clocken1_b)))
                        begin
                            if (read_during_write_mode_port_b == "NEW_DATA_NO_NBE_READ")
                                temp_wb = ((i_data_reg_b & i_byteena_mask_reg_b) |
                                            ({width_b{1'bx}} & ~i_byteena_mask_reg_b));
                            else if (read_during_write_mode_port_b == "NEW_DATA_WITH_NBE_READ")
                                temp_wb = (i_data_reg_b & i_byteena_mask_reg_b) | (mem_data[i_address_reg_b] & ~i_byteena_mask_reg_b) ^ i_byteena_mask_reg_b_x;
                            else if (read_during_write_mode_port_b == "OLD_DATA")
                                temp_wb = i_original_data_b; 
                            else 
                                temp_wb = {width_b{1'bx}};
                        end
                        else if ((i_data_write_time_a == $time) && (operation_mode == "DUAL_PORT")  &&
                            ((family_has_stratixv_style_ram == 0) && (family_has_stratixiii_style_ram == 0)))
                        begin
                            // if A write to the same Ram address B is reading from
                            if ((i_address_reg_b == i_address_reg_a) && (i_original_address_a == i_address_reg_a))
                            begin
                                if (address_reg_b != "CLOCK0")
                                    temp_wb = mem_data[i_address_reg_b] ^ i_byteena_mask_reg_a_out_b;
                                else if (cread_during_write_mode_mixed_ports == "OLD_DATA")
                                begin
                                    if (mem_data[i_address_reg_b] === ((i_data_reg_a & i_byteena_mask_reg_a) | (mem_data[i_address_reg_a] & ~i_byteena_mask_reg_a) ^ i_byteena_mask_reg_a_x))
                                        temp_wb = i_original_data_a;
                                    else
                                        temp_wb = mem_data[i_address_reg_b];
                                end
                                else if (cread_during_write_mode_mixed_ports == "DONT_CARE")
                                    temp_wb = mem_data[i_address_reg_b] ^ i_byteena_mask_reg_a_out_b;
                                else
                                    temp_wb = mem_data[i_address_reg_b];
                            end
                            else
                                temp_wb = mem_data[i_address_reg_b];              
                        end
                        else
                            temp_wb = mem_data[i_address_reg_b];

                        if (is_write_on_positive_edge == 1)
                        begin
                            if ((dual_port_addreg_b_clk0 == 1) ||
                                (is_bidir_and_wrcontrol_addb_clk0 == 1) || (same_clock_pulse0 && same_clock_pulse1))
                            begin
                                // A write, B read
                                if ((i_wren_reg_a & ~i_wren_reg_b) && 
                                    ((i_clocken0 && ((family_has_stratixv_style_ram == 0) && (family_has_stratixiii_style_ram == 0))) ||
                                    (i_core_clocken_a && ((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)))))
                                begin
                                    // if A write to the same Ram address B is reading from
                                    if (i_address_reg_b == i_address_reg_a)
                                    begin
                                        if (lutram_dual_port_fast_read == 1)
                                            temp_wb = (i_data_reg_a & i_byteena_mask_reg_a) | (i_q_tmp2_a & ~i_byteena_mask_reg_a) ^ i_byteena_mask_reg_a_x;
                                        else
                                            if (cread_during_write_mode_mixed_ports == "OLD_DATA")
                                                if ((mem_data[i_address_reg_b] === ((i_data_reg_a & i_byteena_mask_reg_a) | (mem_data[i_address_reg_a] & ~i_byteena_mask_reg_a) ^ i_byteena_mask_reg_a_x))
                                                    && (i_data_write_time_a == $time))
                                                    temp_wb = i_original_data_a;
                                                else
                                                    temp_wb = mem_data[i_address_reg_b];
                                            else
                                                temp_wb = mem_data[i_address_reg_b] ^ i_byteena_mask_reg_a_out_b;
                                    end
                                end
                            end
                        end
                    end
                    else
                    begin
                        j2 = i_address_reg_b * width_b;

                        for (i5=0; i5<width_b; i5=i5+1)
                        begin
                            j2_plus_i5 = j2 + i5;
                            temp_wa2b = mem_data[j2_plus_i5 / width_a];
                            temp_wb[i5] = temp_wa2b[j2_plus_i5 % width_a];
                        end
                        
                        if (i_wren_reg_b && ((is_bidir_and_wrcontrol_addb_clk0 && i_core_clocken0_b) || 
                            (is_bidir_and_wrcontrol_addb_clk1 && i_core_clocken1_b)))
                        begin
                            if (read_during_write_mode_port_b == "NEW_DATA_NO_NBE_READ")
                                temp_wb = i_data_reg_b ^ i_byteena_mask_reg_b_out;
                            else if (read_during_write_mode_port_b == "NEW_DATA_WITH_NBE_READ")
                                temp_wb = (i_data_reg_b & i_byteena_mask_reg_b) | (temp_wb & ~i_byteena_mask_reg_b) ^ i_byteena_mask_reg_b_x;
                            else if (read_during_write_mode_port_b == "OLD_DATA")
                                temp_wb = i_original_data_b;
                            else 
                                temp_wb = {width_b{1'bx}};
                        end
                        else if ((i_data_write_time_a == $time) &&  (operation_mode == "DUAL_PORT") &&
                            ((family_has_stratixv_style_ram == 0) && (family_has_stratixiii_style_ram == 0)))
                        begin
                            for (i5=0; i5<width_b; i5=i5+1)
                            begin
                                j2_plus_i5 = j2 + i5;
                                j2_plus_i5_div_a = j2_plus_i5 / width_a;

                                // if A write to the same Ram address B is reading from
                                if ((j2_plus_i5_div_a == i_address_reg_a) && (i_original_address_a == i_address_reg_a))
                                begin
                                    if (address_reg_b != "CLOCK0")
                                    begin
                                        temp_wa2b = mem_data[j2_plus_i5_div_a];
                                        temp_wa2b = temp_wa2b ^ i_byteena_mask_reg_a_out_b;
                                    end
                                    else if (cread_during_write_mode_mixed_ports == "OLD_DATA")
                                        temp_wa2b = i_original_data_a;
                                    else if (cread_during_write_mode_mixed_ports == "DONT_CARE")
                                    begin
                                        temp_wa2b = mem_data[j2_plus_i5_div_a];
                                        temp_wa2b = temp_wa2b ^ i_byteena_mask_reg_a_out_b;
                                    end
                                    else
                                        temp_wa2b = mem_data[j2_plus_i5_div_a];
                                end
                                else
                                    temp_wa2b = mem_data[j2_plus_i5_div_a];
              
                                temp_wb[i5] = temp_wa2b[j2_plus_i5 % width_a];
                            end
                        end

                        if (is_write_on_positive_edge == 1)
                        begin
                            if (((address_reg_b == "CLOCK0") & dual_port_addreg_b_clk0) ||
                                ((wrcontrol_wraddress_reg_b == "CLOCK0") & is_bidir_and_wrcontrol_addb_clk0) || (same_clock_pulse0 && same_clock_pulse1))
                            begin
                                // A write, B read
                                if ((i_wren_reg_a & ~i_wren_reg_b) && 
                                    ((i_clocken0 && ((family_has_stratixv_style_ram == 0) && (family_has_stratixiii_style_ram == 0))) ||
                                    (i_core_clocken_a && ((family_has_stratixv_style_ram == 1) || (family_has_stratixiii_style_ram == 1)))))
                                begin
                                
                                    for (i5=0; i5<width_b; i5=i5+1)
                                    begin
                                        j2_plus_i5 = j2 + i5;
                                        j2_plus_i5_div_a = j2_plus_i5 / width_a;
                                        
                                        // if A write to the same Ram address B is reading from
                                        if (j2_plus_i5_div_a == i_address_reg_a)
                                        begin
                                            if (lutram_single_port_fast_read == 1)
                                                temp_wa2b = (i_data_reg_a & i_byteena_mask_reg_a) | (i_q_tmp2_a & ~i_byteena_mask_reg_a) ^ i_byteena_mask_reg_a_x;
                                            else
                                            begin
                                                if ((cread_during_write_mode_mixed_ports == "OLD_DATA") && (i_data_write_time_a == $time))
                                                    temp_wa2b = i_original_data_a;
                                                else
                                                begin
                                                    temp_wa2b = mem_data[j2_plus_i5_div_a];
                                                    temp_wa2b = temp_wa2b ^ i_byteena_mask_reg_a_out_b;
                                                end
                                            end
                                                
                                            temp_wb[i5] = temp_wa2b[j2_plus_i5 % width_a];
                                        end
                                            
                                    end
                                end
                            end
                        end
                    end 
                    //end of width_a != width_b
                    
                    i_q_tmp2_b = temp_wb;

                end
                
                if ((is_lutram == 1) && i_address_aclr_b && (i_address_aclr_family_b == 0) && (operation_mode == "DUAL_PORT"))
                begin
                    for (init_i = 0; init_i < width_b; init_i = init_i + 1)
                    begin
                        init_temp = mem_data[init_i / width_a];
                        i_q_tmp_b[init_i] = init_temp[init_i % width_a];
                        i_q_tmp2_b[init_i] = init_temp[init_i % width_a];
                    end
                end
                else if ((is_lutram == 1) && (operation_mode == "DUAL_PORT"))
                begin
                    j2 = i_address_reg_b * width_b;

                    for (i5=0; i5<width_b; i5=i5+1)
                    begin
                        j2_plus_i5 = j2 + i5;
                        temp_wa2b = mem_data[j2_plus_i5 / width_a];
                        i_q_tmp2_b[i5] = temp_wa2b[j2_plus_i5 % width_a];
                    end
                end
                
                if ((i_outdata_aclr_b) && 
                    ((family_stratixv == 1) || (family_cycloneiii == 1)) &&
                    (is_lutram != 1) &&
                    (outdata_reg_b != "CLOCK0") && (outdata_reg_b != "CLOCK1"))
                    i_q_tmp2_b = {width_b{1'b0}};
            end
        end
    end


    // assigning the correct output values for i_q_tmp_b (non-registered output)
    always @(i_q_tmp2_b or i_wren_reg_b or i_data_reg_b or i_address_aclr_b or
                 i_address_reg_b or i_byteena_mask_reg_b_out or i_rden_reg_b or
                 i_numwords_b or i_outdata_aclr_b or i_force_reread_b_signal)
    begin
        if (i_address_reg_b >= i_numwords_b)
        begin
            if (i_wren_reg_b && ((i_core_clocken0_b && (is_bidir_and_wrcontrol_addb_clk0 == 1)) || (i_core_clocken1_b && (is_bidir_and_wrcontrol_addb_clk1 == 1))))
                i_q_tmp_b <= i_q_tmp2_b;
            else
                i_q_tmp_b <= {width_b{1'bx}};
            if (i_rden_reg_b == 1)
            begin
                $display("Warning : Address pointed at port B is out of bound!");
                $display("Time: %0t  Instance: %m", $time);
            end
        end
        else
            if (operation_mode == "BIDIR_DUAL_PORT")
            begin
            
                if (i_outdata_aclr_b_prev && ~ i_outdata_aclr_b && (family_has_stratixv_style_ram != 1) && (family_has_stratixiii_style_ram == 1) && (is_lutram != 1))
                begin
                    i_outdata_aclr_b_prev <= i_outdata_aclr_b;
                    i_force_reread_b <= 1;
                end
                else
                begin
                    i_q_tmp_b <= i_q_tmp2_b;
                end
            end
            else if (operation_mode == "DUAL_PORT")
            begin
                if (i_outdata_aclr_b_prev && ~ i_outdata_aclr_b && (family_has_stratixv_style_ram != 1) && (family_has_stratixiii_style_ram == 1) && (is_lutram != 1))
                begin
                    i_outdata_aclr_b_prev <= i_outdata_aclr_b;
                    i_force_reread_b <= 1;
                end
                else if (~i_address_aclr_b_prev && i_address_aclr_b && (i_address_aclr_family_b == 0) && s3_address_aclr_b)
                begin
                    if (i_rden_reg_b)
                        i_q_tmp_b <= {width_b{1'bx}};
                        i_force_reread_b1 <= 1;
                end
                else if ((i_force_reread_b1 == 0) && !(i_address_aclr_b_prev && ~i_address_aclr_b && (i_address_aclr_family_b == 0) && s3_address_aclr_b))
                begin
                    i_q_tmp_b <= i_q_tmp2_b;
                end
            end
        
        if ((i_outdata_aclr_b) && (s3_address_aclr_b))
        begin
            i_q_tmp_b <= {width_b{1'b0}};
            i_outdata_aclr_b_prev <= i_outdata_aclr_b;
        end
        i_address_aclr_b_prev <= i_address_aclr_b;
    end

    // output latch for lutram (only used when read_during_write_mode_mixed_ports == "OLD_DATA")
    generate if (outdata_reg_b == "CLOCK1")
    begin
        always @(negedge clock1)
        begin
            if (i_core_clocken_a)
                i_q_output_latch <= i_q_tmp2_b;
        end
    end
    else if (outdata_reg_b == "CLOCK0")
    begin
        always @(negedge clock0)
        begin
            if (i_core_clocken_a)
                i_q_output_latch <= i_q_tmp2_b;
        end
    end
    endgenerate

    // Port B outdata output registered
    generate if (outdata_reg_b == "CLOCK1")
    begin
        always @(posedge clock1 or posedge i_outdata_aclr_b)
        begin
            if (i_outdata_aclr_b)
                i_q_reg_b <= 0;
            else if (i_outdata_clken_b)
            begin
                if ((i_address_aclr_b_flag == 1) && (family_stratixv || family_stratixiii) &&
                    (is_lutram != 1))
                    i_q_reg_b <= 'bx;
                else
                i_q_reg_b <= i_q_tmp_b;
            end
        end
    end
    else if (outdata_reg_b == "CLOCK0")
    begin
        always @(posedge clock0 or posedge i_outdata_aclr_b)
        begin
            if (i_outdata_aclr_b)
                i_q_reg_b <= 0;
            else if (i_outdata_clken_b)
            begin
                if ((is_lutram == 1) && (cread_during_write_mode_mixed_ports == "OLD_DATA"))
                    i_q_reg_b <= i_q_output_latch;
                else
                begin           
                    if ((i_address_aclr_b_flag == 1) && (family_stratixv || family_stratixiii) &&
                        (is_lutram != 1))
                        i_q_reg_b <= 'bx;
                    else
                    i_q_reg_b <= i_q_tmp_b;
                end
            end
        end
    end
    else 
    begin
        always @(posedge i_outdata_aclr_b)
        begin
            if (i_outdata_aclr_b)
                i_q_reg_b <= 0;
        end
    end
    endgenerate

    // Latch for address aclr till outclock enabled
    always @(posedge i_address_aclr_b or posedge i_outdata_aclr_b)
        if (i_outdata_aclr_b)
            i_address_aclr_b_flag <= 0;
        else
        begin
            if (i_rden_reg_b)
                i_address_aclr_b_flag <= 1;
        end

    // Port B : assigning the correct output values for q_b
    assign q_b = ((operation_mode == "SINGLE_PORT") ||
                    (operation_mode == "ROM")) ?
                        {width_b{1'b0}} : (((outdata_reg_b == "CLOCK0") ||
                            (outdata_reg_b == "CLOCK1")) ?
                        i_q_reg_b : i_q_tmp_b);


    // ECC status
    assign eccstatus = {width_eccstatus{1'b0}};

endmodule // ALTSYNCRAM

// END OF MODULE

//-----------------------------------------------------------------------------+
// Module Name      : alt3pram
//
// Description      : Triple-Port RAM megafunction. This megafunction implements
//                    RAM with 1 write port and 2 read ports.
//
// Limitation       : This megafunction is provided only for backward 
//                    compatibility in Stratix designs; instead, Altera® 
//                    recommends using the altsyncram megafunction.
//
//                    In MAX 3000, and MAX 7000 devices, 
//                    or if the USE_EAB paramter is set to "OFF", uses one 
//                    logic cell (LCs) per memory bit.
//
//
// Results expected : The alt3pram function represents asynchronous memory 
//                    or memory with synchronous inputs and/or outputs.
//                    (note: ^ below indicates posedge)
//
//                    [ Synchronous Write to Memory (all inputs registered) ]
//                    inclock    inclocken    wren    Function   
//                      X           L           L     No change. 
//                     not ^        H           H     No change. 
//                      ^           L           X     No change. 
//                      ^           H           H     The memory location 
//                                                    pointed to by wraddress[] 
//                                                    is loaded with data[]. 
//
//                    [ Synchronous Read from Memory ] 
//                    inclock  inclocken  rden_a/rden_b  Function  
//                       X         L            L        No change. 
//                     not ^       H            H        No change. 
//                       ^         L            X        No change. 
//                       ^         H            H        The q_a[]/q_b[]port 
//                                                       outputs the contents of 
//                                                       the memory location. 
//
//                   [ Asynchronous Memory Operations ]
//                   wren     Function  
//                    L       No change. 
//                    H       The memory location pointed to by wraddress[] is 
//                            loaded with data[] and controlled by wren.
//                            The output q_a[] is asynchronous and reflects 
//                            the memory location pointed to by rdaddress_a[]. 
//
//-----------------------------------------------------------------------------+

`timescale 1 ps / 1 ps

module alt3pram (wren, data, wraddress, inclock, inclocken, 
                rden_a, rden_b, rdaddress_a, rdaddress_b, 
                outclock, outclocken, aclr, qa, qb);

    // ---------------------
    // PARAMETER DECLARATION
    // ---------------------

    parameter width            = 1;             // data[], qa[] and qb[]
    parameter widthad          = 1;             // rdaddress_a,rdaddress_b,wraddress
    parameter numwords         = 0;             // words stored in memory
    parameter lpm_file         = "UNUSED";      // name of hex file
    parameter lpm_hint         = "USE_EAB=ON";  // non-LPM parameters (Altera)
    parameter indata_reg       = "UNREGISTERED";// clock used by data[] port
    parameter indata_aclr      = "ON";         // aclr affects data[]? 
    parameter write_reg        = "UNREGISTERED";// clock used by wraddress & wren
    parameter write_aclr       = "ON";         // aclr affects wraddress?
    parameter rdaddress_reg_a  = "UNREGISTERED";// clock used by readdress_a
    parameter rdaddress_aclr_a = "ON";         // aclr affects rdaddress_a?
    parameter rdcontrol_reg_a  = "UNREGISTERED";// clock used by rden_a
    parameter rdcontrol_aclr_a = "ON";         // aclr affects rden_a?
    parameter rdaddress_reg_b  = "UNREGISTERED";// clock used by readdress_b
    parameter rdaddress_aclr_b = "ON";         // aclr affects rdaddress_b?
    parameter rdcontrol_reg_b  = "UNREGISTERED";// clock used by rden_b
    parameter rdcontrol_aclr_b = "ON";         // aclr affects rden_b?
    parameter outdata_reg_a    = "UNREGISTERED";// clock used by qa[]
    parameter outdata_aclr_a   = "ON";         // aclr affects qa[]?
    parameter outdata_reg_b    = "UNREGISTERED";// clock used by qb[]
    parameter outdata_aclr_b   = "ON";         // aclr affects qb[]?
    parameter intended_device_family = "Stratix";
    parameter ram_block_type   = "AUTO";        // ram block type to be used
    parameter maximum_depth    = 0;             // maximum segmented value of the RAM
    parameter lpm_type               = "alt3pram";

    // -------------
    // the following behaviour come in effect when RAM is implemented in EAB/ESB

    // This is the flag to indicate if the memory is constructed using EAB/ESB:
    //     A write request requires both rising and falling edge of the clock 
    //     to complete. First the data will be clocked in (registered) at the 
    //     rising edge and will not be written into the ESB/EAB memory until 
    //     the falling edge appears on the the write clock.
    //     No such restriction if the memory is constructed using LCs.
    reg write_at_low_clock; // initialize at initial block 

                                    
    // The read ports will not hold any value (zero) if rden is low. This 
    //     behavior only apply to memory constructed using EAB/ESB, but not LCs.
    reg rden_low_output_0;
                                    
    // ----------------
    // PORT DECLARATION
    // ----------------
   
    // data input ports
    input [width-1:0]      data;

    // control signals
    input [widthad-1:0]    wraddress;
    input [widthad-1:0]    rdaddress_a;
    input [widthad-1:0]    rdaddress_b;

    input                  wren;
    input                  rden_a;
    input                  rden_b;

    // clock ports
    input                  inclock;
    input                  outclock;

    // clock enable ports
    input                  inclocken;
    input                  outclocken;

    // clear ports
    input                  aclr;

    // OUTPUT PORTS
    output [width-1:0]     qa;
    output [width-1:0]     qb;

    // ---------------
    // REG DECLARATION
    // ---------------
    reg  [width-1:0]       mem_data [(1<<widthad)-1:0];
    wire [width-1:0]       i_data_reg;
    wire [width-1:0]       i_data_tmp;
    reg  [width-1:0]       i_qa_reg;
    reg  [width-1:0]       i_qa_tmp;
    reg  [width-1:0]       i_qb_reg;
    reg  [width-1:0]       i_qb_tmp;

    wire [width-1:0]       i_qa_stratix;  // qa signal for Stratix families
    wire [width-1:0]       i_qb_stratix;  // qa signal for Stratix families

    reg  [width-1:0]       i_data_hi;
    reg  [width-1:0]       i_data_lo;

    wire [widthad-1:0]     i_wraddress_reg;
    wire [widthad-1:0]     i_wraddress_tmp;

    reg  [widthad-1:0]     i_wraddress_hi;
    reg  [widthad-1:0]     i_wraddress_lo;
    
    reg  [widthad-1:0]     i_rdaddress_reg_a;
    reg  [widthad-1:0]     i_rdaddress_reg_a_dly;
    wire [widthad-1:0]     i_rdaddress_tmp_a;

    reg  [widthad-1:0]     i_rdaddress_reg_b;
    reg  [widthad-1:0]     i_rdaddress_reg_b_dly;
    wire [widthad-1:0]     i_rdaddress_tmp_b;

    wire                   i_wren_reg;
    wire                   i_wren_tmp;
    reg                    i_rden_reg_a;
    wire                   i_rden_tmp_a;
    reg                    i_rden_reg_b;
    wire                   i_rden_tmp_b;

    reg                    i_wren_hi;
    reg                    i_wren_lo;

    reg [8*256:1]          ram_initf;       // max RAM size 8*256=2048

    wire                   i_stratix_inclock;  // inclock signal for Stratix families
    wire                   i_stratix_outclock; // inclock signal for Stratix families

    wire                   i_non_stratix_inclock;  // inclock signal for non-Stratix families
    wire                   i_non_stratix_outclock; // inclock signal for non-Stratix families
    
    reg                    feature_family_stratix;

    // -------------------
    // INTEGER DECLARATION
    // -------------------
    integer                i;
    integer                i_numwords;
    integer                new_data;
    integer                tmp_new_data;
    

    // --------------------------------
    // Tri-State and Buffer DECLARATION
    // --------------------------------
    tri0                   inclock;
    tri1                   inclocken;
    tri0                   outclock;
    tri1                   outclocken;
    tri0                   wren;
    tri1                   rden_a;
    tri1                   rden_b;
    tri0                   aclr;
               
    // ------------------------
    // COMPONENT INSTANTIATIONS
    // ------------------------
    ALTERA_DEVICE_FAMILIES dev ();
    ALTERA_MF_MEMORY_INITIALIZATION mem ();
    ALTERA_MF_HINT_EVALUATION eva();

    // The alt3pram for Stratix/Stratix II/ Stratix GX and Cyclone device families
    // are basically consists of 2 instances of altsyncram with write port of each
    // instance been tied together.

    altsyncram u0 (
                    .wren_a(wren),
                    .wren_b(),
                    .rden_a(),
                    .rden_b(rden_a),
                    .data_a(data),
                    .data_b(),
                    .address_a(wraddress),
                    .address_b(rdaddress_a),
                    .clock0(i_stratix_inclock),
                    .clock1(i_stratix_outclock),
                    .clocken0(inclocken),
                    .clocken1(outclocken),
                    .clocken2(),
                    .clocken3(),
                    .aclr0(aclr),
                    .aclr1(),
                    .byteena_a(),
                    .byteena_b(),
                    .addressstall_a(),
                    .addressstall_b(),
                    .q_a(),
                    .q_b(i_qa_stratix),
                    .eccstatus());

    defparam
        u0.width_a          = width,
        u0.widthad_a        = widthad,
        u0.numwords_a       = (numwords == 0) ? (1<<widthad) : numwords,
        u0.address_aclr_a   = (write_aclr == "ON") ? "CLEAR0" : "NONE",
        u0.indata_aclr_a    = (indata_aclr == "ON") ? "CLEAR0" : "NONE",
        u0.wrcontrol_aclr_a   = (write_aclr == "ON") ? "CLEAR0" : "NONE",

        u0.width_b                   = width,
        u0.widthad_b                 = widthad,
        u0.numwords_b                =  (numwords == 0) ? (1<<widthad) : numwords,
        u0.rdcontrol_reg_b           =  (rdcontrol_reg_a == "INCLOCK")  ? "CLOCK0" :
                                        (rdcontrol_reg_a == "OUTCLOCK") ? "CLOCK1" :
                                        "UNUSED",
        u0.address_reg_b             =  (rdaddress_reg_a == "INCLOCK")  ? "CLOCK0" :
                                        (rdaddress_reg_a == "OUTCLOCK") ? "CLOCK1" :
                                        "UNUSED",
        u0.outdata_reg_b             =  (outdata_reg_a == "INCLOCK")  ? "CLOCK0" :
                                        (outdata_reg_a == "OUTCLOCK") ? "CLOCK1" :
                                        "UNREGISTERED",
        u0.outdata_aclr_b            =  (outdata_aclr_a == "ON") ? "CLEAR0" : "NONE",
        u0.rdcontrol_aclr_b          =  (rdcontrol_aclr_a == "ON") ? "CLEAR0" : "NONE",
        u0.address_aclr_b            =  (rdaddress_aclr_a == "ON") ? "CLEAR0" : "NONE",
        u0.operation_mode                     = "DUAL_PORT",
        u0.read_during_write_mode_mixed_ports = (ram_block_type == "AUTO") ?    "OLD_DATA" :
                                                                                "DONT_CARE",
        u0.ram_block_type                     = ram_block_type,
        u0.init_file                          = lpm_file,
        u0.init_file_layout                   = "PORT_B",
        u0.maximum_depth                      = maximum_depth,
        u0.intended_device_family             = intended_device_family;

    altsyncram u1 (
                    .wren_a(wren),
                    .wren_b(),
                    .rden_a(),
                    .rden_b(rden_b),
                    .data_a(data),
                    .data_b(),
                    .address_a(wraddress),
                    .address_b(rdaddress_b),
                    .clock0(i_stratix_inclock),
                    .clock1(i_stratix_outclock),
                    .clocken0(inclocken),
                    .clocken1(outclocken),
                    .clocken2(),
                    .clocken3(),
                    .aclr0(aclr),
                    .aclr1(),
                    .byteena_a(),
                    .byteena_b(),
                    .addressstall_a(),
                    .addressstall_b(),
                    .q_a(),
                    .q_b(i_qb_stratix),
                    .eccstatus());

    defparam
        u1.width_a          = width,
        u1.widthad_a        = widthad,
        u1.numwords_a       = (numwords == 0) ? (1<<widthad) : numwords,
        u1.address_aclr_a   = (write_aclr == "ON") ? "CLEAR0" : "NONE",
        u1.indata_aclr_a    = (indata_aclr == "ON") ? "CLEAR0" : "NONE",
        u1.wrcontrol_aclr_a   = (write_aclr == "ON") ? "CLEAR0" : "NONE",

        u1.width_b                   = width,
        u1.widthad_b                 = widthad,
        u1.numwords_b                =  (numwords == 0) ? (1<<widthad) : numwords,
        u1.rdcontrol_reg_b           = (rdcontrol_reg_b == "INCLOCK")  ? "CLOCK0" :
                                        (rdcontrol_reg_b == "OUTCLOCK") ? "CLOCK1" :
                                        "UNUSED",
        u1.address_reg_b             = (rdaddress_reg_b == "INCLOCK")  ? "CLOCK0" :
                                        (rdaddress_reg_b == "OUTCLOCK") ? "CLOCK1" :
                                        "UNUSED",
        u1.outdata_reg_b             = (outdata_reg_b == "INCLOCK")  ? "CLOCK0" :
                                        (outdata_reg_b == "OUTCLOCK") ? "CLOCK1" :
                                        "UNREGISTERED",
        u1.outdata_aclr_b            = (outdata_aclr_b == "ON") ? "CLEAR0" : "NONE",
        u1.rdcontrol_aclr_b          = (rdcontrol_aclr_b == "ON") ? "CLEAR0" : "NONE",
        u1.address_aclr_b            = (rdaddress_aclr_b == "ON") ? "CLEAR0" : "NONE",

        u1.operation_mode                     = "DUAL_PORT",
        u1.read_during_write_mode_mixed_ports = (ram_block_type == "AUTO") ? "OLD_DATA" :
                                                                            "DONT_CARE",
        u1.ram_block_type                     = ram_block_type,
        u1.init_file                          = lpm_file,
        u1.init_file_layout                   = "PORT_B",
        u1.maximum_depth                      = maximum_depth,
        u1.intended_device_family             = intended_device_family;

    // -----------------------------------------------------------
    // Initialization block for all internal signals and registers
    // -----------------------------------------------------------
    initial
    begin
        feature_family_stratix = dev.FEATURE_FAMILY_STRATIX(intended_device_family);

        // Check for invalid parameters
        
        write_at_low_clock = ((write_reg == "INCLOCK") &&
                                    (eva.GET_PARAMETER_VALUE(lpm_hint, "USE_EAB") == "ON")) ? 1 : 0;
                                    
        if (width <= 0)
        begin
            $display("Error: width parameter must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if (widthad <= 0)
        begin
            $display("Error: widthad parameter must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        // Initialize mem_data to '0' if no RAM init file is specified
        i_numwords = (numwords) ? numwords : 1<<widthad;
        if (lpm_file == "UNUSED")
            if (write_reg == "UNREGISTERED")
                for (i=0; i<i_numwords; i=i+1)
                    mem_data[i] = {width{1'bx}};
            else
                for (i=0; i<i_numwords; i=i+1)
                    mem_data[i] = 0;
        else
        begin
`ifdef NO_PLI
            $readmemh(lpm_file, mem_data);
`else
    `ifdef USE_RIF
            $readmemh(lpm_file, mem_data);
    `else
            mem.convert_to_ver_file(lpm_file, width, ram_initf);
            $readmemh(ram_initf, mem_data);
    `endif 
`endif
        end

        // Initialize registers
        i_data_hi          = 0;
        i_data_lo          = 0;
        i_rdaddress_reg_a  = 0;
        i_rdaddress_reg_b  = 0;
        i_rdaddress_reg_a_dly = 0;
        i_rdaddress_reg_b_dly = 0;
        i_qa_reg           = 0;
        i_qb_reg           = 0;

        // Initialize integer
        new_data = 0;
        tmp_new_data = 0;
        
        rden_low_output_0 = 0;

    end

    // ------------------------
    // ALWAYS CONSTRUCT BLOCK
    // ------------------------
    
    // The following always blocks are used to implement the alt3pram behavior for
    // device families other than Stratix/Stratix II/Stratix GX and Cyclone.

    //=========
    // Clocks
    //=========

    // At posedge of the write clock:
    // All input ports values (data, address and control) are 
    // clocked in from physical ports to internal variables
    //     Write Cycle: i_*_hi
    //     Read  Cycle: i_*_reg
    always @(posedge i_non_stratix_inclock)
    begin
        if (indata_reg == "INCLOCK")
        begin
            if ((aclr == 1) && (indata_aclr == "ON"))
                i_data_hi <= 0;
            else if (inclocken == 1)
                i_data_hi <= data;
        end

        if (write_reg == "INCLOCK")
        begin
            if ((aclr == 1) && (write_aclr == "ON"))
            begin
                i_wraddress_hi <= 0;
                i_wren_hi <= 0;
            end
            else if (inclocken == 1)
            begin       
                i_wraddress_hi <= wraddress;
                i_wren_hi <= wren;
            end
        end

        if (rdaddress_reg_a == "INCLOCK")
        begin
            if ((aclr == 1) && (rdaddress_aclr_a == "ON"))
                i_rdaddress_reg_a <= 0;
            else if (inclocken == 1)
                i_rdaddress_reg_a <= rdaddress_a;
        end

        if (rdcontrol_reg_a == "INCLOCK")
        begin
            if ((aclr == 1) && (rdcontrol_aclr_a == "ON"))
                i_rden_reg_a <= 0;
            else if (inclocken == 1)
                i_rden_reg_a <= rden_a;
        end

        if (rdaddress_reg_b == "INCLOCK")
        begin
            if ((aclr == 1) && (rdaddress_aclr_b == "ON"))
                i_rdaddress_reg_b <= 0;
            else if (inclocken == 1)
                i_rdaddress_reg_b <= rdaddress_b;
        end

        if (rdcontrol_reg_b == "INCLOCK")
        begin
            if ((aclr == 1) && (rdcontrol_aclr_b == "ON"))
                i_rden_reg_b <= 0;
            else if (inclocken == 1)
                i_rden_reg_b <= rden_b;
        end
    end  // End of always block: @(posedge inclock)


    // At negedge of the write clock:
    // Write Cycle: since internally data only completed written on memory
    //              at the falling edge of write clock, the "write" related 
    //              data, address and controls need to be shift to another 
    //              varibles (i_*_hi -> i_*_lo) during falling edge.
    always @(negedge i_non_stratix_inclock)
    begin
        if (indata_reg == "INCLOCK")
        begin
            if ((aclr == 1) && (indata_aclr == "ON"))
                i_data_lo <= 0;
            else
                i_data_lo <= i_data_hi;
        end

        if (write_reg == "INCLOCK")
        begin
            if ((aclr == 1) && (write_aclr == "ON"))
            begin
                i_wraddress_lo <= 0;
                i_wren_lo <= 0;
            end
            else
            begin
                i_wraddress_lo <= i_wraddress_hi;
                i_wren_lo <= i_wren_hi;
            end
        end
    end  // End of always block: @(negedge inclock)


    // At posedge of read clock: 
    // Read Cycle: This block is valid only if the operating mode is
    //             in "Seperate Clock Mode". All read data, address 
    //             and control are clocked out from internal vars 
    //             (i_*_reg) to output port.
    always @(posedge i_non_stratix_outclock)
    begin
        if (outdata_reg_a == "OUTCLOCK")
        begin
            if ((aclr == 1) && (outdata_aclr_a == "ON"))
                i_qa_reg <= 0;
            else if (outclocken == 1)
                i_qa_reg <= i_qa_tmp;
        end

        if (outdata_reg_b == "OUTCLOCK")
        begin
            if ((aclr == 1) && (outdata_aclr_b == "ON"))
                i_qb_reg <= 0;
            else if (outclocken == 1)
                i_qb_reg <= i_qb_tmp;
        end

        if (rdaddress_reg_a == "OUTCLOCK")
        begin
            if ((aclr == 1) && (rdaddress_aclr_a == "ON"))
                i_rdaddress_reg_a <= 0;
            else if (outclocken == 1)
                i_rdaddress_reg_a <= rdaddress_a;
        end

        if (rdcontrol_reg_a == "OUTCLOCK")
        begin
            if ((aclr == 1) && (rdcontrol_aclr_a == "ON"))
                i_rden_reg_a <= 0;
            else if (outclocken == 1)
                i_rden_reg_a <= rden_a;
        end

        if (rdaddress_reg_b == "OUTCLOCK")
        begin
            if ((aclr == 1) && (rdaddress_aclr_b == "ON"))
                i_rdaddress_reg_b <= 0;
            else if (outclocken == 1)
                i_rdaddress_reg_b <= rdaddress_b;
        end

        if (rdcontrol_reg_b == "OUTCLOCK")
        begin
            if ((aclr == 1) && (rdcontrol_aclr_b == "ON"))
                i_rden_reg_b <= 0;
            else if (outclocken == 1)
                i_rden_reg_b <= rden_b;
        end
    end  // End of always block: @(posedge outclock)

    always @(i_rdaddress_reg_a)
    begin
        i_rdaddress_reg_a_dly <= i_rdaddress_reg_a;
    end

    always @(i_rdaddress_reg_b)
    begin
        i_rdaddress_reg_b_dly <= i_rdaddress_reg_b;
    end

    //=========
    // Memory
    //=========

    always @(i_data_tmp or i_wren_tmp or i_wraddress_tmp)
    begin
        new_data <= 1;
    end

    always @(posedge new_data or negedge new_data)
    begin
        if (new_data == 1)
    begin
        //
        // This is where data is being write to the internal memory: mem_data[]
        //
            if (i_wren_tmp == 1)
            begin
                mem_data[i_wraddress_tmp] <= i_data_tmp;
            end
        
        tmp_new_data <= ~tmp_new_data;  
            
        end        
    end

    always @(tmp_new_data)
    begin
    
        new_data <= 0;
    end

        // Triple-Port Ram (alt3pram) has one write port and two read ports (a and b)
        // Below is the operation to read data from internal memory (mem_data[])
        // to the output port (i_qa_tmp or i_qb_tmp)
        // Note: i_q*_tmp will serve as the var directly link to the physical 
        //       output port q* if alt3pram is operate in "Shared Clock Mode", 
        //       else data read from i_q*_tmp will need to be latched to i_q*_reg
        //       through outclock before it is fed to the output port q* (qa or qb).

    always @(posedge new_data or negedge new_data or 
            posedge i_rden_tmp_a or negedge i_rden_tmp_a or 
            i_rdaddress_tmp_a) 
    begin

        if (i_rden_tmp_a == 1)
            i_qa_tmp <= mem_data[i_rdaddress_tmp_a];
        else if (rden_low_output_0 == 1)
            i_qa_tmp <= 0;

    end

    always @(posedge new_data or negedge new_data or 
            posedge i_rden_tmp_b or negedge i_rden_tmp_b or 
            i_rdaddress_tmp_b)
    begin

        if (i_rden_tmp_b == 1)
            i_qb_tmp <= mem_data[i_rdaddress_tmp_b];
        else if (rden_low_output_0 == 1)
            i_qb_tmp <= 0;

    end


    //=======
    // Sync
    //=======

    assign  i_wraddress_reg   = ((aclr == 1) && (write_aclr == "ON")) ?
                                    {widthad{1'b0}} : (write_at_low_clock ? 
                                        i_wraddress_lo : i_wraddress_hi);

    assign  i_wren_reg        = ((aclr == 1) && (write_aclr == "ON")) ?
                                    1'b0 : ((write_at_low_clock) ? 
                                        i_wren_lo : i_wren_hi);

    assign  i_data_reg        = ((aclr == 1) && (indata_aclr == "ON")) ?
                                    {width{1'b0}} : ((write_at_low_clock) ? 
                                        i_data_lo : i_data_hi);

    assign  i_wraddress_tmp   = ((aclr == 1) && (write_aclr == "ON")) ?
                                    {widthad{1'b0}} : ((write_reg == "INCLOCK") ? 
                                        i_wraddress_reg : wraddress);
    
    assign  i_rdaddress_tmp_a = ((aclr == 1) && (rdaddress_aclr_a == "ON")) ?
                                    {widthad{1'b0}} : (((rdaddress_reg_a == "INCLOCK") || 
                                        (rdaddress_reg_a == "OUTCLOCK")) ?
                                        i_rdaddress_reg_a_dly : rdaddress_a);

    assign  i_rdaddress_tmp_b = ((aclr == 1) && (rdaddress_aclr_b == "ON")) ?
                                    {widthad{1'b0}} : (((rdaddress_reg_b == "INCLOCK") || 
                                        (rdaddress_reg_b == "OUTCLOCK")) ?
                                        i_rdaddress_reg_b_dly : rdaddress_b);

    assign  i_wren_tmp        = ((aclr == 1) && (write_aclr == "ON")) ?
                                    1'b0 : ((write_reg == "INCLOCK") ?
                                        i_wren_reg : wren);

    assign  i_rden_tmp_a      = ((aclr == 1) && (rdcontrol_aclr_a == "ON")) ?
                                    1'b0 : (((rdcontrol_reg_a == "INCLOCK") || 
                                        (rdcontrol_reg_a == "OUTCLOCK")) ?
                                        i_rden_reg_a : rden_a);

    assign  i_rden_tmp_b      = ((aclr == 1) && (rdcontrol_aclr_b == "ON")) ?
                                    1'b0 : (((rdcontrol_reg_b == "INCLOCK") || 
                                        (rdcontrol_reg_b == "OUTCLOCK")) ?
                                        i_rden_reg_b : rden_b);

    assign  i_data_tmp        = ((aclr == 1) && (indata_aclr == "ON")) ?
                                    {width{1'b0}} : ((indata_reg == "INCLOCK") ?
                                        i_data_reg : data);
    
    assign  qa                = (feature_family_stratix == 1) ?
                                i_qa_stratix :
                                (((aclr == 1) && (outdata_aclr_a == "ON")) ?
                                    {widthad{1'b0}} : ((outdata_reg_a == "OUTCLOCK") ?
                                        i_qa_reg : i_qa_tmp));

    assign  qb                = (feature_family_stratix == 1) ?
                                i_qb_stratix :
                                (((aclr == 1) && (outdata_aclr_b == "ON")) ?
                                    {widthad{1'b0}} : ((outdata_reg_b == "OUTCLOCK") ?
                                        i_qb_reg : i_qb_tmp));

    assign   i_non_stratix_inclock    = (feature_family_stratix == 0) ?
                                inclock : 1'b0;

    assign   i_non_stratix_outclock   = (feature_family_stratix == 0) ?
                                outclock : 1'b0;

    assign   i_stratix_inclock = (feature_family_stratix == 1) ?
                                inclock : 1'b0;

    assign   i_stratix_outclock = (feature_family_stratix == 1) ?
                                outclock : 1'b0;


endmodule // end of ALT3PRAM

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  parallel_add
//
// Description     :  Parameterized parallel adder megafunction. The data input 
//                    is a concatenated group of input words.  The size
//                    parameter indicates the number of 'width'-bit words.
//
//                    Each word is added together to generate the result output.
//                    Each word is left shifted according to the shift
//                    parameter.  The shift amount is multiplied by the word
//                    index, with the least significant word being word 0.
//                    The shift for word I is (shift * I).
//                   
//                    The most significant word can be subtracted from the total
//                    by setting the msw_subtract parameter to 1.
//                    If the result width is less than is required to show the
//                    full result, the result output can be aligned to the MSB
//                    or the LSB of the internal result.  When aligning to the
//                    MSB, the internally calculated best_result_width is used
//                    to find the true MSB.
//                    The input data can be signed or unsigned, and the output
//                    can be pipelined.
//
// Limitations     :  Minimum data width is 1, and at least 2 words are required.
//
// Results expected:  result - The sum of all inputs.
//
//END_MODULE_NAME--------------------------------------------------------------

`timescale 1 ps / 1 ps

module parallel_add (
    data,
    clock,
    aclr,
    clken,
    result);
    
    parameter width = 4;        // Required
    parameter size = 2;         // Required
    parameter widthr = 4;       // Required
    parameter shift = 0;
    parameter msw_subtract = "NO";  // or "YES"
    parameter representation = "UNSIGNED";
    parameter pipeline = 0;
    parameter result_alignment = "LSB"; // or "MSB"
    parameter lpm_type = "parallel_add";
    parameter lpm_hint = "UNUSED";

    // Maximum precision required for internal calculations.
    // This is a pessimistic estimate, but it is guaranteed to be sufficient.
    // The +30 is there only to simplify the test generator, which occasionally asks
    // for output widths far in excess of what is needed.  The excess is always less than 30.
    `define max_precision (width+size+shift*(size-1)+30)    // Result will not overflow this size
    
    // INPUT PORT DECLARATION
    input [width*size-1:0] data;  // Required port
    input clock;                // Required port
    input aclr;                 // Default = 0
    input clken;                // Default = 1

    // OUTPUT PORT DECLARATION
    output [widthr-1:0] result;  //Required port

    // INTERNAL REGISTER DECLARATION
    reg imsb_align;
    reg [width-1:0] idata_word;
    reg [`max_precision-1:0] idata_extended;
    reg [`max_precision-1:0] tmp_result;
    reg [widthr-1:0] resultpipe [(pipeline +1):0];

    // INTERNAL TRI DECLARATION
    tri1 clken_int;

    // INTERNAL WIRE DECLARATION
    wire [widthr-1:0] aligned_result;
    wire [`max_precision-1:0] msb_aligned_result;

    // LOCAL INTEGER DECLARATION
    integer ni;
    integer best_result_width;
    integer pipe_ptr;
    
    // Note: The recommended value for WIDTHR parameter,
    //       the width of addition result, for full
    //       precision is:
    //                                                          --
    //                     ((2^WIDTH)-1) * (2^(SIZE*SHIFT)-1)
    // WIDTHR = CEIL(LOG2(-----------------------------------))
    //                                (2^SHIFT)-1
    //
    // Use CALC_PADD_WIDTHR(WIDTH, SIZE, SHIFT):
    // DEFINE CALC_PADD_WIDTHR(w, z, s) = (s == 0) ? CEIL(LOG2(z*((2^w)-1))) : 
    //                                                  CEIL(LOG2(((2^w)-1) * (2^(z*s)-1) / ((2^s)-1)));
    function integer ceil_log2;
        input [`max_precision-1:0] input_num;
        integer i;
        reg [`max_precision-1:0] try_result;
        begin
            i = 0;
            try_result = 1;
            while ((try_result << i) < input_num && i < `max_precision)
                i = i + 1;
            ceil_log2 = i;
        end
    endfunction

    // INITIALIZATION
    initial
    begin
        if (widthr > `max_precision)
            $display ("Error! WIDTHR must not exceed WIDTH+SIZE+SHIFT*(SIZE-1).");
        if (size < 2)
            $display ("Error! SIZE must be greater than 1.");

        if (shift == 0)
        begin
            best_result_width = width;
            if (size > 1)
                best_result_width = best_result_width + ceil_log2(size);
        end
        else
            best_result_width = ceil_log2( ((1<<width)-1) * ((1 << (size*shift))-1)
                                            / ((1 << shift)-1));
        
        imsb_align = (result_alignment == "MSB" && widthr < best_result_width) ? 1 : 0;
                
        // Clear the pipeline array
        for (ni=0; ni< pipeline +1; ni=ni+1)
            resultpipe[ni] = 0;
        pipe_ptr = 0;
    end

    // MODEL
    always @(data)
    begin
        tmp_result = 0;
        // Loop over each input data word, and add to the total
        for (ni=0; ni<size; ni=ni+1)
        begin
            // Get input word to add to total
            idata_word = (data >> (ni * width));
            
            // If signed and negative, pad MSB with ones to sign extend the input data
            if ((representation != "UNSIGNED") && (idata_word[width-1] == 1'b1))
                idata_extended = ({{(`max_precision-width-2){1'b1}}, idata_word} << (shift*ni));
            else
                idata_extended = (idata_word << (shift*ni));    // zero padding is automatic
            
            // Add to total
            if ((msw_subtract == "YES") && (ni == (size-1)))
                tmp_result = tmp_result - idata_extended;
            else
                tmp_result = tmp_result + idata_extended;
        end        
    end

    // Pipeline model
    always @(posedge clock or posedge aclr)
    begin
        if (aclr == 1'b1)
        begin
            // Clear the pipeline array
            for (ni=0; ni< (pipeline +1); ni=ni+1)
                resultpipe[ni] <= 0;
            pipe_ptr <= 0;
        end
        else if (clken_int == 1'b1)
        begin
            resultpipe[pipe_ptr] <= aligned_result;
            if (pipeline > 1)
                pipe_ptr <= (pipe_ptr + 1) % pipeline;
        end
    end

    // Check if output needs MSB alignment
    assign msb_aligned_result = (tmp_result >> (best_result_width-widthr));
    assign aligned_result = (imsb_align == 1)
                            ? msb_aligned_result[widthr-1:0]
                            : tmp_result[widthr-1:0];
    assign clken_int = clken;
    assign result = (pipeline > 0) ? resultpipe[pipe_ptr] : aligned_result;
endmodule  // end of PARALLEL_ADD
// END OF MODULE
//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  scfifo
//
// Description     :  Single Clock FIFO
//
// Limitation      :  
//
// Results expected:
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module scfifo ( data, 
                clock, 
                wrreq, 
                rdreq, 
                aclr, 
                sclr,
                q, 
                usedw, 
                full, 
                empty, 
                almost_full, 
                almost_empty);

// GLOBAL PARAMETER DECLARATION
    parameter lpm_width               = 1;
    parameter lpm_widthu              = 1;
    parameter lpm_numwords            = 2;
    parameter lpm_showahead           = "OFF";
    parameter lpm_type                = "scfifo";
    parameter lpm_hint                = "USE_EAB=ON";
    parameter intended_device_family  = "Stratix";
    parameter underflow_checking      = "ON";
    parameter overflow_checking       = "ON";
    parameter allow_rwcycle_when_full = "OFF";
    parameter use_eab                 = "ON";
    parameter add_ram_output_register = "OFF";
    parameter almost_full_value       = 0;
    parameter almost_empty_value      = 0;
    parameter maximum_depth           = 0;    

// LOCAL_PARAMETERS_BEGIN

    parameter showahead_area          = ((lpm_showahead == "ON")  && (add_ram_output_register == "OFF"));
    parameter showahead_speed         = ((lpm_showahead == "ON")  && (add_ram_output_register == "ON"));
    parameter legacy_speed            = ((lpm_showahead == "OFF") && (add_ram_output_register == "ON"));

// LOCAL_PARAMETERS_END

// INPUT PORT DECLARATION
    input  [lpm_width-1:0] data;
    input  clock;
    input  wrreq;
    input  rdreq;
    input  aclr;
    input  sclr;

// OUTPUT PORT DECLARATION
    output [lpm_width-1:0] q;
    output [lpm_widthu-1:0] usedw;
    output full;
    output empty;
    output almost_full;
    output almost_empty;

// INTERNAL REGISTERS DECLARATION
    reg [lpm_width-1:0] mem_data [(1<<lpm_widthu):0];
    reg [lpm_widthu-1:0] count_id;
    reg [lpm_widthu-1:0] read_id;
    reg [lpm_widthu-1:0] write_id;
    
    wire valid_rreq;
    reg valid_wreq;
    reg write_flag;
    reg full_flag;
    reg empty_flag;
    reg almost_full_flag;
    reg almost_empty_flag;
    reg [lpm_width-1:0] tmp_q;
    reg stratix_family;
    reg set_q_to_x;
    reg set_q_to_x_by_empty;

    reg [lpm_widthu-1:0] write_latency1; 
    reg [lpm_widthu-1:0] write_latency2; 
    reg [lpm_widthu-1:0] write_latency3; 
    integer wrt_count;
        
    reg empty_latency1; 
    reg empty_latency2; 
    
    reg [(1<<lpm_widthu)-1:0] data_ready;
    reg [(1<<lpm_widthu)-1:0] data_shown;
    
// INTERNAL TRI DECLARATION
    tri0 aclr;

// LOCAL INTEGER DECLARATION
    integer i;

// COMPONENT INSTANTIATIONS
    ALTERA_DEVICE_FAMILIES dev ();

// INITIAL CONSTRUCT BLOCK
    initial
    begin

        stratix_family = (dev.FEATURE_FAMILY_STRATIX(intended_device_family));    
        if (lpm_width <= 0)
        begin
            $display ("Error! LPM_WIDTH must be greater than 0.");
            $display ("Time: %0t  Instance: %m", $time);
        end
        if ((lpm_widthu !=1) && (lpm_numwords > (1 << lpm_widthu)))
        begin
            $display ("Error! LPM_NUMWORDS must equal to the ceiling of log2(LPM_WIDTHU).");
            $display ("Time: %0t  Instance: %m", $time);
        end
        if (dev.IS_VALID_FAMILY(intended_device_family) == 0)
        begin
            $display ("Error! Unknown INTENDED_DEVICE_FAMILY=%s.", intended_device_family);
            $display ("Time: %0t  Instance: %m", $time);
        end
        if((add_ram_output_register != "ON") && (add_ram_output_register != "OFF"))
        begin
            $display ("Error! add_ram_output_register must be ON or OFF.");          
            $display ("Time: %0t  Instance: %m", $time);
        end         
        for (i = 0; i < (1<<lpm_widthu); i = i + 1)
        begin
            if (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family))
                mem_data[i] <= {lpm_width{1'b0}};
            else if (dev.FEATURE_FAMILY_STRATIX(intended_device_family))
            begin
                if ((add_ram_output_register == "ON") || (use_eab == "OFF"))
                    mem_data[i] <= {lpm_width{1'b0}};
                else
                    mem_data[i] <= {lpm_width{1'bx}};
            end
            else
                mem_data[i] <= {lpm_width{1'b0}};
        end

        if (dev.FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM(intended_device_family))
            tmp_q <= {lpm_width{1'b0}};
        else if (dev.FEATURE_FAMILY_STRATIX(intended_device_family))
        begin
            if ((add_ram_output_register == "ON") || (use_eab == "OFF"))
                tmp_q <= {lpm_width{1'b0}};
            else    
                tmp_q <= {lpm_width{1'bx}};
        end
        else
            tmp_q <= {lpm_width{1'b0}};
            
        write_flag <= 1'b0;
        count_id <= 0;
        read_id <= 0;
        write_id <= 0;
        full_flag <= 1'b0;
        empty_flag <= 1'b1;
        empty_latency1 <= 1'b1; 
        empty_latency2 <= 1'b1;                 
        set_q_to_x <= 1'b0;
        set_q_to_x_by_empty <= 1'b0;
        wrt_count <= 0;        

        if (almost_full_value == 0)
            almost_full_flag <= 1'b1;
        else
            almost_full_flag <= 1'b0;

        if (almost_empty_value == 0)
            almost_empty_flag <= 1'b0;
        else
            almost_empty_flag <= 1'b1;
    end

    assign valid_rreq = (underflow_checking == "OFF")? rdreq : (rdreq && ~empty_flag);

    always @(wrreq or rdreq or full_flag)
    begin
        if (overflow_checking == "OFF")
            valid_wreq = wrreq;
        else if (allow_rwcycle_when_full == "ON")
                valid_wreq = wrreq && (!full_flag || rdreq);
        else
            valid_wreq = wrreq && !full_flag;
    end

    always @(posedge clock or posedge aclr)
    begin        
        if (aclr)
        begin
            if (add_ram_output_register == "ON")
                tmp_q <= {lpm_width{1'b0}};
            else if ((lpm_showahead == "ON") && (use_eab == "ON"))
            begin
                tmp_q <= {lpm_width{1'bX}};
            end
            else
            begin
                if (!stratix_family)
                begin
                    tmp_q <= {lpm_width{1'b0}};
                end
                else
                    tmp_q <= {lpm_width{1'bX}};
            end

            read_id <= 0;
            count_id <= 0;
            full_flag <= 1'b0;
            empty_flag <= 1'b1;
            empty_latency1 <= 1'b1; 
            empty_latency2 <= 1'b1;
            set_q_to_x <= 1'b0;
            set_q_to_x_by_empty <= 1'b0;
            wrt_count <= 0;
            
            if (almost_full_value > 0)
                almost_full_flag <= 1'b0;
            if (almost_empty_value > 0)
                almost_empty_flag <= 1'b1;

            write_id <= 0;
            
            if ((use_eab == "ON") && (stratix_family) && ((showahead_speed) || (showahead_area) || (legacy_speed)))
            begin
                write_latency1 <= 1'bx;
                write_latency2 <= 1'bx;
                data_shown <= {lpm_width{1'b0}};
                if (add_ram_output_register == "ON")
                    tmp_q <= {lpm_width{1'b0}};
                else
                    tmp_q <= {lpm_width{1'bX}};
            end            
        end
        else
        begin
            if (sclr)
            begin
                if (add_ram_output_register == "ON")
                    tmp_q <= {lpm_width{1'b0}};
                else
                    tmp_q <= {lpm_width{1'bX}};

                read_id <= 0;
                count_id <= 0;
                full_flag <= 1'b0;
                empty_flag <= 1'b1;
                empty_latency1 <= 1'b1; 
                empty_latency2 <= 1'b1;
                set_q_to_x <= 1'b0;
                set_q_to_x_by_empty <= 1'b0;
                wrt_count <= 0;

                if (almost_full_value > 0)
                    almost_full_flag <= 1'b0;
                if (almost_empty_value > 0)
                    almost_empty_flag <= 1'b1;

                if (!stratix_family)
                begin
                    if (valid_wreq)
                    begin
                        write_flag <= 1'b1;
                    end
                    else
                        write_id <= 0;
                end
                else
                begin
                    write_id <= 0;
                end

                if ((use_eab == "ON") && (stratix_family) && ((showahead_speed) || (showahead_area) || (legacy_speed)))
                begin
                    write_latency1 <= 1'bx;
                    write_latency2 <= 1'bx;
                    data_shown <= {lpm_width{1'b0}};                    
                    if (add_ram_output_register == "ON")
                        tmp_q <= {lpm_width{1'b0}};
                    else
                        tmp_q <= {lpm_width{1'bX}};
                end            
            end
            else 
            begin
                //READ operation    
                if (valid_rreq)
                begin
                    if (!(set_q_to_x || set_q_to_x_by_empty))
                    begin  
                        if (!valid_wreq)
                            wrt_count <= wrt_count - 1;

                        if (!valid_wreq)
                        begin
                            full_flag <= 1'b0;

                            if (count_id <= 0)
                                count_id <= {lpm_widthu{1'b1}};
                            else
                                count_id <= count_id - 1;
                        end                

                        if ((use_eab == "ON") && stratix_family && (showahead_speed || showahead_area || legacy_speed))
                        begin
                            if ((wrt_count == 1 && valid_rreq && !valid_wreq) || ((wrt_count == 1 ) && valid_wreq && valid_rreq))
                            begin
                                empty_flag <= 1'b1;
                            end
                            else
                            begin
                                if (showahead_speed)
                                begin
                                    if (data_shown[write_latency2] == 1'b0)
                                    begin
                                        empty_flag <= 1'b1;
                                    end
                                end
                                else if (showahead_area || legacy_speed)
                                begin
                                    if (data_shown[write_latency1] == 1'b0)
                                    begin
                                        empty_flag <= 1'b1;
                                    end
                                end
                            end
                        end
                        else
                        begin
                            if (!valid_wreq)
                            begin
                                if ((count_id == 1) && !(full_flag))
                                    empty_flag <= 1'b1;
                            end
                        end

                        if (empty_flag)
                        begin
                            if (underflow_checking == "ON")
                            begin
                                if ((use_eab == "OFF") || (!stratix_family))
                                    tmp_q <= {lpm_width{1'b0}};
                            end
                            else
                            begin
                                set_q_to_x_by_empty <= 1'b1;
                                $display ("Warning : Underflow occurred! Fifo output is unknown until the next reset is asserted.");
                                $display ("Time: %0t  Instance: %m", $time);
                            end
                        end
                        else if (read_id >= ((1<<lpm_widthu) - 1))
                        begin
                            if (lpm_showahead == "ON")
                            begin
                                if ((use_eab == "ON") && stratix_family && (showahead_speed || showahead_area))                        
                                begin
                                    if (showahead_speed)
                                    begin
                                        if ((write_latency2 == 0) || (data_ready[0] == 1'b1))
                                        begin
                                            if (data_shown[0] == 1'b1)
                                            begin
                                                tmp_q <= mem_data[0];
                                                data_shown[0] <= 1'b0;
                                                data_ready[0] <= 1'b0;
                                            end
                                        end
                                    end
                                    else
                                    begin
                                        if ((count_id == 1) && !(full_flag))
                                        begin
                                            if (underflow_checking == "ON")
                                            begin
                                                if ((use_eab == "OFF") || (!stratix_family))
                                                    tmp_q <= {lpm_width{1'b0}};
                                            end
                                            else
                                                tmp_q <= {lpm_width{1'bX}};
                                        end
                                        else if ((write_latency1 == 0) || (data_ready[0] == 1'b1))
                                        begin
                                            if (data_shown[0] == 1'b1)
                                            begin
                                                tmp_q <= mem_data[0];
                                                data_shown[0] <= 1'b0;
                                                data_ready[0] <= 1'b0;
                                            end
                                        end                            
                                    end
                                end
                                else
                                begin
                                    if ((count_id == 1) && !(full_flag))
                                    begin
                                        if (valid_wreq)
                                            tmp_q <= data;
                                        else
                                            if (underflow_checking == "ON")
                                            begin
                                                if ((use_eab == "OFF") || (!stratix_family))
                                                    tmp_q <= {lpm_width{1'b0}};
                                            end
                                            else
                                                tmp_q <= {lpm_width{1'bX}};
                                    end 
                                    else
                                        tmp_q <= mem_data[0];
                                end
                            end
                            else
                            begin
                                if ((use_eab == "ON") && stratix_family && legacy_speed)
                                begin
                                    if ((write_latency1 == read_id) || (data_ready[read_id] == 1'b1))
                                    begin
                                        if (data_shown[read_id] == 1'b1)
                                        begin
                                            tmp_q <= mem_data[read_id];
                                            data_shown[read_id] <= 1'b0;
                                            data_ready[read_id] <= 1'b0;
                                        end
                                    end
                                    else
                                    begin
                                        tmp_q <= {lpm_width{1'bX}};
                                    end                                  
                                end
                                else
                                    tmp_q <= mem_data[read_id];
                            end

                            read_id <= 0;
                        end // end if (read_id >= ((1<<lpm_widthu) - 1))
                        else
                        begin
                            if (lpm_showahead == "ON")
                            begin
                                if ((use_eab == "ON") && stratix_family && (showahead_speed || showahead_area))
                                begin
                                    if (showahead_speed)
                                    begin
                                        if ((write_latency2 == read_id+1) || (data_ready[read_id+1] == 1'b1))
                                        begin
                                            if (data_shown[read_id+1] == 1'b1)
                                            begin
                                                tmp_q <= mem_data[read_id + 1];
                                                data_shown[read_id+1] <= 1'b0;
                                                data_ready[read_id+1] <= 1'b0;
                                            end
                                        end
                                    end
                                    else
                                    begin
                                        if ((count_id == 1) && !(full_flag))
                                        begin
                                            if (underflow_checking == "ON")
                                            begin
                                                if ((use_eab == "OFF") || (!stratix_family))
                                                    tmp_q <= {lpm_width{1'b0}};
                                            end
                                            else
                                                tmp_q <= {lpm_width{1'bX}};
                                        end
                                        else if ((write_latency1 == read_id+1) || (data_ready[read_id+1] == 1'b1))
                                        begin
                                            if (data_shown[read_id+1] == 1'b1)
                                            begin
                                                tmp_q <= mem_data[read_id + 1];
                                                data_shown[read_id+1] <= 1'b0;
                                                data_ready[read_id+1] <= 1'b0;
                                            end
                                        end
                                    end
                                end
                                else
                                begin
                                    if ((count_id == 1) && !(full_flag))
                                    begin
                                        if ((use_eab == "OFF") && stratix_family)
                                        begin
                                            if (valid_wreq)
                                            begin
                                                tmp_q <= data;
                                            end
                                            else
                                            begin
                                                if (underflow_checking == "ON")
                                                begin
                                                    if ((use_eab == "OFF") || (!stratix_family))
                                                        tmp_q <= {lpm_width{1'b0}};
                                                end
                                                else
                                                    tmp_q <= {lpm_width{1'bX}};
                                            end
                                        end
                                        else
                                        begin
                                            tmp_q <= {lpm_width{1'bX}};
                                        end
                                    end
                                    else
                                        tmp_q <= mem_data[read_id + 1];
                                end
                            end
                            else
                            begin
                                if ((use_eab == "ON") && stratix_family && legacy_speed)
                                begin
                                    if ((write_latency1 == read_id) || (data_ready[read_id] == 1'b1))
                                    begin
                                        if (data_shown[read_id] == 1'b1)
                                        begin
                                            tmp_q <= mem_data[read_id];
                                            data_shown[read_id] <= 1'b0;
                                            data_ready[read_id] <= 1'b0;
                                        end
                                    end
                                    else
                                    begin
                                        tmp_q <= {lpm_width{1'bX}};
                                    end                                
                                end
                                else
                                    tmp_q <= mem_data[read_id];
                            end

                            read_id <= read_id + 1;            
                        end
                    end
                end

                // WRITE operation
                if (valid_wreq)
                begin
                    if (!(set_q_to_x || set_q_to_x_by_empty))
                    begin
                        if (full_flag && (overflow_checking == "OFF"))
                        begin
                            set_q_to_x <= 1'b1;
                            $display ("Warning : Overflow occurred! Fifo output is unknown until the next reset is asserted.");
                            $display ("Time: %0t  Instance: %m", $time);
                        end
                        else
                        begin
                            mem_data[write_id] <= data;
                            write_flag <= 1'b1;
    
                            if (!((use_eab == "ON") && stratix_family && (showahead_speed || showahead_area || legacy_speed)))
                            begin
                                empty_flag <= 1'b0;
                            end
                            else
                            begin
                                empty_latency1 <= 1'b0;
                            end
    
                            if (!valid_rreq)                
                                wrt_count <= wrt_count + 1;
    
                            if (!valid_rreq)
                            begin
                                if (count_id >= (1 << lpm_widthu) - 1)
                                    count_id <= 0;
                                else
                                    count_id <= count_id + 1;               
                            end
                            else
                            begin
                                if (allow_rwcycle_when_full == "OFF")
                                    full_flag <= 1'b0;
                            end
    
                            if (!(stratix_family) || (stratix_family && !(showahead_speed || showahead_area || legacy_speed)))
                            begin                
                                if (!valid_rreq)
                                    if ((count_id == lpm_numwords - 1) && (empty_flag == 1'b0))
                                        full_flag <= 1'b1;
                            end
                            else
                            begin   
                                if (!valid_rreq)
                                    if (count_id == lpm_numwords - 1)
                                        full_flag <= 1'b1;
                            end
    
                            if (lpm_showahead == "ON")
                            begin
                                if ((use_eab == "ON") && stratix_family && (showahead_speed || showahead_area))
                                begin
                                    write_latency1 <= write_id;                    
                                    data_shown[write_id] <= 1'b1;
                                    data_ready[write_id] <= 1'bx;
                                end
                                else
                                begin 
                                    if ((use_eab == "OFF") && stratix_family && (count_id == 0) && (!full_flag))
                                    begin
                                        tmp_q <= data;
                                    end
                                    else
                                    begin
                                        if ((!empty_flag) && (!valid_rreq))
                                        begin
                                            tmp_q <= mem_data[read_id];
                                        end
                                    end
                                end
                            end
                            else
                            begin
                                if ((use_eab == "ON") && stratix_family && legacy_speed) 
                                begin
                                    write_latency1 <= write_id;                    
                                    data_shown[write_id] <= 1'b1;
                                    data_ready[write_id] <= 1'bx;
                                end
                            end
                        end
                    end   
                end    

                if (almost_full_value == 0)
                    almost_full_flag <= 1'b1;
                else if (lpm_numwords > almost_full_value)
                begin
                    if (almost_full_flag)
                    begin
                        if ((count_id == almost_full_value) && !wrreq && rdreq)
                            almost_full_flag <= 1'b0;
                    end
                    else
                    begin
                        if ((almost_full_value == 1) && (count_id == 0) && wrreq)
                            almost_full_flag <= 1'b1;
                        else if ((almost_full_value > 1) && (count_id == almost_full_value - 1)
                                && wrreq && !rdreq)
                            almost_full_flag <= 1'b1;
                    end
                end

                if (almost_empty_value == 0)
                    almost_empty_flag <= 1'b0;
                else if (lpm_numwords > almost_empty_value)
                begin
                    if (almost_empty_flag)
                    begin
                        if ((almost_empty_value == 1) && (count_id == 0) && wrreq)
                            almost_empty_flag <= 1'b0;
                        else if ((almost_empty_value > 1) && (count_id == almost_empty_value - 1)
                                && wrreq && !rdreq)
                            almost_empty_flag <= 1'b0;
                    end
                    else
                    begin
                        if ((count_id == almost_empty_value) && !wrreq && rdreq)
                            almost_empty_flag <= 1'b1;
                    end
                end
            end

            if ((use_eab == "ON") && stratix_family)
            begin
                if (showahead_speed)
                begin
                    write_latency2 <= write_latency1;
                    write_latency3 <= write_latency2;
                    if (write_latency3 !== write_latency2)
                        data_ready[write_latency2] <= 1'b1;
                                    
                    empty_latency2 <= empty_latency1;

                    if (data_shown[write_latency2]==1'b1)
                    begin
                        if ((read_id == write_latency2) || aclr || sclr)
                        begin
                            if (!(aclr === 1'b1) && !(sclr === 1'b1))                        
                            begin
                                if (write_latency2 !== 1'bx)
                                begin
                                    tmp_q <= mem_data[write_latency2];
                                    data_shown[write_latency2] <= 1'b0;
                                    data_ready[write_latency2] <= 1'b0;
    
                                    if (!valid_rreq)
                                        empty_flag <= empty_latency2;
                                end
                            end
                        end
                    end
                end
                else if (showahead_area)
                begin
                    write_latency2 <= write_latency1;
                    if (write_latency2 !== write_latency1)
                        data_ready[write_latency1] <= 1'b1;

                    if (data_shown[write_latency1]==1'b1)
                    begin
                        if ((read_id == write_latency1) || aclr || sclr)
                        begin
                            if (!(aclr === 1'b1) && !(sclr === 1'b1))
                            begin
                                if (write_latency1 !== 1'bx)
                                begin
                                    tmp_q <= mem_data[write_latency1];
                                    data_shown[write_latency1] <= 1'b0;
                                    data_ready[write_latency1] <= 1'b0;

                                    if (!valid_rreq)
                                    begin
                                        empty_flag <= empty_latency1;
                                    end
                                end
                            end
                        end
                    end                            
                end
                else
                begin
                    if (legacy_speed)
                    begin
                        write_latency2 <= write_latency1;
                        if (write_latency2 !== write_latency1)
                            data_ready[write_latency1] <= 1'b1;

                            empty_flag <= empty_latency1;

                        if ((wrt_count == 1 && !valid_wreq && valid_rreq) || aclr || sclr)
                        begin
                            empty_flag <= 1'b1;
                            empty_latency1 <= 1'b1;
                        end
                        else
                        begin
                            if ((wrt_count == 1) && valid_wreq && valid_rreq)
                            begin
                                empty_flag <= 1'b1;
                            end
                        end
                    end
                end
            end
        end
    end

    always @(negedge clock)
    begin
        if (write_flag)
        begin
            write_flag <= 1'b0;

            if (sclr || aclr || (write_id >= ((1 << lpm_widthu) - 1)))
                write_id <= 0;
            else
                write_id <= write_id + 1;
        end

        if (!(stratix_family))
        begin
            if (!empty)
            begin
                if ((lpm_showahead == "ON") && ($time > 0))
                    tmp_q <= mem_data[read_id];
            end
        end
    end

    always @(full_flag)
    begin
        if (lpm_numwords == almost_full_value)
            if (full_flag)
                almost_full_flag = 1'b1;
            else
                almost_full_flag = 1'b0;

        if (lpm_numwords == almost_empty_value)
            if (full_flag)
                almost_empty_flag = 1'b0;
            else
                almost_empty_flag = 1'b1;
    end

// CONTINOUS ASSIGNMENT   
    assign q = (set_q_to_x || set_q_to_x_by_empty)? {lpm_width{1'bX}} : tmp_q;
    assign full = (set_q_to_x || set_q_to_x_by_empty)? 1'bX : full_flag;
    assign empty = (set_q_to_x || set_q_to_x_by_empty)? 1'bX : empty_flag;
    assign usedw = (set_q_to_x || set_q_to_x_by_empty)? {lpm_widthu{1'bX}} : count_id;
    assign almost_full = (set_q_to_x || set_q_to_x_by_empty)? 1'bX : almost_full_flag;
    assign almost_empty = (set_q_to_x || set_q_to_x_by_empty)? 1'bX : almost_empty_flag;

endmodule // scfifo
// END OF MODULE
    
//--------------------------------------------------------------------------
// Module Name      : altshift_taps
//
// Description      : Parameterized shift register with taps megafunction.
//                    Implements a RAM-based shift register for efficient
//                    creation of very large shift registers
//
// Limitation       : This megafunction is provided only for backward
//                    compatibility in Cyclone, Stratix, and Stratix GX
//                    designs.
//
// Results expected : Produce output from the end of the shift register
//                    and from the regularly spaced taps along the
//                    shift register.
//
//--------------------------------------------------------------------------
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module altshift_taps (shiftin, clock, clken, aclr, shiftout, taps);

// PARAMETER DECLARATION
    parameter number_of_taps = 4;   // Specifies the number of regularly spaced
                                    //  taps along the shift register
    parameter tap_distance = 3;     // Specifies the distance between the
                                    //  regularly spaced taps in clock cycles
                                    //  This number translates to the number of
                                    //  memory words that will be needed
    parameter width = 8;            // Specifies the width of the input pattern
    parameter power_up_state = "CLEARED";
    parameter lpm_type = "altshift_taps";
    parameter intended_device_family = "Stratix";
    parameter lpm_hint = "UNUSED";

// SIMULATION_ONLY_PARAMETERS_BEGIN

    // Following parameters are used as constant
    parameter RAM_WIDTH = width * number_of_taps;
    parameter TOTAL_TAP_DISTANCE = number_of_taps * tap_distance;

// SIMULATION_ONLY_PARAMETERS_END

// INPUT PORT DECLARATION
    input [width-1:0] shiftin;      // Data input to the shifter
    input clock;                    // Positive-edge triggered clock
    input clken;                    // Clock enable for the clock port
    input aclr;                     // Asynchronous clear port

// OUTPUT PORT DECLARATION
    output [width-1:0] shiftout;    // Output from the end of the shift
                                    //  register
    output [RAM_WIDTH-1:0] taps;    // Output from the regularly spaced taps
                                    //  along the shift register

// INTERNAL REGISTERS DECLARATION
    reg [width-1:0] shiftout;
    reg [RAM_WIDTH-1:0] taps;
    reg [width-1:0] shiftout_tmp;
    reg [RAM_WIDTH-1:0] taps_tmp;
    reg [width-1:0] contents [0:TOTAL_TAP_DISTANCE-1];

// LOCAL INTEGER DECLARATION
    integer head;     // pointer to memory
    integer i;        // for loop index
    integer j;        // for loop index
    integer k;        // for loop index
    integer place;

// TRI STATE DECLARATION
    tri1 clken;
    tri0 aclr;

// INITIAL CONSTRUCT BLOCK
    initial
    begin
        head = 0;
        if (power_up_state == "CLEARED") 
        begin
            shiftout = 0;
            shiftout_tmp = 0;
            for (i = 0; i < TOTAL_TAP_DISTANCE; i = i + 1)
            begin
                contents [i] = 0;
            end
            for (j = 0; j < RAM_WIDTH; j = j + 1)
            begin
                taps [j] = 0;
                taps_tmp [j] = 0;
            end
        end
    end

// ALWAYS CONSTRUCT BLOCK
    always @(posedge clock or posedge aclr)
    begin
        if (aclr == 1'b1)
        begin
            for (k=0; k < TOTAL_TAP_DISTANCE; k=k+1)
                contents[k] = 0;

            head = 0;
            shiftout_tmp = 0;
            taps_tmp = 0;        
        end
        else
        begin
            if (clken == 1'b1)
            begin
                contents[head] = shiftin;
                head = (head + 1) % TOTAL_TAP_DISTANCE;
                shiftout_tmp = contents[head];
            
                taps_tmp = 0;
            
                for (k=0; k < number_of_taps; k=k+1)
                begin
                    place = (((number_of_taps - k - 1) * tap_distance) + head ) %
                            TOTAL_TAP_DISTANCE;
                    taps_tmp = taps_tmp | (contents[place] << (k * width));
                end
            end
        end
    end

    always @(shiftout_tmp)
    begin
        shiftout <= shiftout_tmp;
    end

    always @(taps_tmp)
    begin
        taps <= taps_tmp;
    end

endmodule // altshift_taps

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  a_graycounter
//
// Description     :  Gray counter with Count-enable, Up/Down, aclr and sclr
//
// Limitation      :  Sync sigal priority: clk_en (higher),sclr,cnt_en (lower)
//
// Results expected:  q is graycounter output and qbin is normal counter
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module a_graycounter (clock, cnt_en, clk_en, updown, aclr, sclr,
                        q, qbin);
// GLOBAL PARAMETER DECLARATION
    parameter width  = 3;
    parameter pvalue = 0;
    parameter lpm_hint = "UNUSED";
    parameter lpm_type = "a_graycounter";

// INPUT PORT DECLARATION
    input  clock;
    input  cnt_en;
    input  clk_en;
    input  updown;
    input  aclr;
    input  sclr;
            
// OUTPUT PORT DECLARATION
    output [width-1:0] q;
    output [width-1:0] qbin;
          
// INTERNAL REGISTERS DECLARATION
    reg [width-1:0] cnt;

// INTERNAL TRI DECLARATION
    tri1 clk_en;
    tri1 cnt_en;
    tri1 updown;
    tri0 aclr;
    tri0 sclr;

// LOCAL INTEGER DECLARATION

// COMPONENT INSTANTIATIONS

// INITIAL CONSTRUCT BLOCK
    initial
    begin
        if (width <= 0)
            $display ("Error! WIDTH of a_greycounter must be greater than 0.");
            $display ("Time: %0t  Instance: %m", $time);
        cnt = pvalue;             
    end

// ALWAYS CONSTRUCT BLOCK
    always @(posedge aclr or posedge clock)
    begin                     
        if (aclr)
            cnt <= pvalue;
        else
        begin
            if (clk_en)
            begin
                if (sclr)
                    cnt <= pvalue;
                else if (cnt_en)
                begin
                    if (updown == 1)
                        cnt <= cnt + 1;
                    else
                        cnt <= cnt - 1;
                end
            end
        end
    end

// CONTINOUS ASSIGNMENT
    assign qbin = cnt;
    assign q    = cnt ^ (cnt >>1);

endmodule // a_graycounter
// END OF MODULE


//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  altsquare
//
// Description     :  Parameterized integer square megafunction. 
//                    The input data can be signed or unsigned, and the output
//                    can be pipelined.
//
// Limitations     :  Minimum data width is 1.
//
// Results expected:  result - The square of input data.
//
//END_MODULE_NAME--------------------------------------------------------------

`timescale 1 ps / 1 ps

module altsquare (
    data,
    clock,
    ena,
    aclr,
    result
);

// GLOBAL PARAMETER DECLARATION
    parameter data_width = 1;
    parameter result_width = 1;
    parameter pipeline = 0;
    parameter representation = "UNSIGNED";
    parameter result_alignment = "LSB";
    parameter lpm_hint = "UNUSED";
    parameter lpm_type = "altsquare";

    // INPUT PORT DECLARATION
    input [data_width - 1 : 0] data;
    input clock;
    input ena;
    input aclr;
    
    // OUTPUT PORT DECLARATION
    output [result_width - 1 : 0] result;

    // INTERNAL REGISTER DECLARATION
    reg [result_width - 1 : 0]stage_values[pipeline+1 : 0];
    reg [data_width - 1 : 0] pos_data_value;
    reg [(2*data_width) - 1 : 0] temp_value;
    // LOCAL INTEGER DECLARATION
    integer i;

    // INTERNAL WIRE DECLARATION
    wire i_clock;
    wire i_aclr;
    wire i_clken;
// INTERNAL TRI DECLARATION
    tri0 aclr;
    tri1 clock;
    tri1 clken;

    buf (i_clock, clock);
    buf (i_aclr, aclr);
    buf (i_clken, ena);


    // INITIAL CONSTRUCT BLOCK
    initial
    begin : INITIALIZE
        if(data_width < 1)
        begin 
            $display("data_width (%d) must be greater than 0.(ERROR)\n", data_width);
            $display ("Time: %0t  Instance: %m", $time);
            $finish;
        end
        if(result_width < 1)
        begin
            $display("result_width (%d) must be greater than 0.(ERROR)\n", result_width);
            $display ("Time: %0t  Instance: %m", $time);
            $finish;
        end
    end // INITIALIZE

    // ALWAYS CONSTRUCT BLOCK
    always @(data or i_aclr)
    begin
        if (i_aclr) // clear the pipeline
            for (i = 0; i <= pipeline; i = i + 1)
                stage_values[i] = 'b0;
        else
        begin
            if ((representation == "SIGNED") && (data[data_width - 1] == 1))
                pos_data_value = (~data) + 1;
            else
                pos_data_value = data;

            if ( (result_width < (2 * data_width)) && (result_alignment == "MSB") )
            begin
                temp_value = pos_data_value * pos_data_value;
                stage_values[pipeline] = temp_value[(2*data_width)-1 : (2*data_width)-result_width];
            end
            else
                stage_values[pipeline] = pos_data_value * pos_data_value;
        end
    end

    // Pipeline model
    always @(posedge i_clock)
    begin
        if (!i_aclr && i_clken == 1)
        begin
            for(i = 0; i < pipeline+1; i = i + 1)
                if(i < pipeline)
                    stage_values[i] <= stage_values[i + 1];
        end
    end

    // CONTINOUS ASSIGNMENT
    assign result = stage_values[0];
endmodule // altsquare
// END OF MODULE


// START_FILE_HEADER ----------------------------------------------------------
//
// Filename    : altera_std_synchronizer.v
//
// Description : Contains the simulation model for the altera_std_synchronizer
//
// Owner       : Paul Scheidt
//
// Copyright (C) Altera Corporation 2008, All Rights Reserved
//
// END_FILE_HEADER ------------------------------------------------------------

// START_MODULE_NAME-----------------------------------------------------------
//
// Module Name : altera_std_synchronizer
//
// Description : Single bit clock domain crossing synchronizer. 
//               Composed of two or more flip flops connected in series.
//               Random metastable condition is simulated when the 
//               __ALTERA_STD__METASTABLE_SIM macro is defined.
//               Use +define+__ALTERA_STD__METASTABLE_SIM argument 
//               on the Verilog simulator compiler command line to 
//               enable this mode. In addition, dfine the macro
//               __ALTERA_STD__METASTABLE_SIM_VERBOSE to get console output 
//               with every metastable event generated in the synchronizer.
//
// Copyright (C) Altera Corporation 2009, All Rights Reserved
// END_MODULE_NAME-------------------------------------------------------------

`timescale 1ns / 1ns

module altera_std_synchronizer (
                                clk, 
                                reset_n, 
                                din, 
                                dout
                                );

    // GLOBAL PARAMETER DECLARATION
    parameter depth = 3; // This value must be >= 2 !
     
  
    // INPUT PORT DECLARATION 
    input   clk;
    input   reset_n;    
    input   din;

    // OUTPUT PORT DECLARATION 
    output  dout;

    // QuartusII synthesis directives:
    //     1. Preserve all registers ie. do not touch them.
    //     2. Do not merge other flip-flops with synchronizer flip-flops.
    // QuartusII TimeQuest directives:
    //     1. Identify all flip-flops in this module as members of the synchronizer 
    //        to enable automatic metastability MTBF analysis.
    //     2. Cut all timing paths terminating on data input pin of the first flop din_s1.

    (* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON; -name SDC_STATEMENT \"set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]\" "} *) reg din_s1;

    (* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg [depth-2:0] dreg;    

    //synthesis translate_off
    initial begin
        if (depth <2) begin
            $display("%m: Error: synchronizer length: %0d less than 2.", depth);
        end
    end

    // the first synchronizer register is either a simple D flop for synthesis
    // and non-metastable simulation or a D flop with a method to inject random
    // metastable events resulting in random delay of [0,1] cycles

   
`ifdef __ALTERA_STD__METASTABLE_SIM

    reg[31:0]  RANDOM_SEED = 123456;      
    wire  next_din_s1;
    wire  dout;
    reg   din_last;
    reg   random;
    event metastable_event; // hook for debug monitoring

    initial begin
        $display("%m: Info: Metastable event injection simulation mode enabled");
    end
   
    always @(posedge clk) begin
        if (reset_n == 0)
            random <= $random(RANDOM_SEED);
        else
            random <= $random;
    end

    assign next_din_s1 = (din_last ^ din) ? random : din;   

    always @(posedge clk or negedge reset_n) begin
        if (reset_n == 0) 
            din_last <= 1'b0;
        else
            din_last <= din;
    end

    always @(posedge clk or negedge reset_n) begin
        if (reset_n == 0) 
            din_s1 <= 1'b0;
        else
            din_s1 <= next_din_s1;
    end
   
`else 

    //synthesis translate_on   

    always @(posedge clk or negedge reset_n) begin
        if (reset_n == 0) 
            din_s1 <= 1'b0;
        else
            din_s1 <= din;
    end

    //synthesis translate_off      

`endif


`ifdef __ALTERA_STD__METASTABLE_SIM_VERBOSE
    always @(*) begin
        if (reset_n && (din_last != din) && (random != din)) begin
            $display("%m: Verbose Info: metastable event @ time %t", $time);
            ->metastable_event;
        end
    end      
`endif

    //synthesis translate_on

    // the remaining synchronizer registers form a simple shift register
    // of length depth-1

    generate
        if (depth < 3) begin
            always @(posedge clk or negedge reset_n) begin
                if (reset_n == 0) 
                    dreg <= {depth-1{1'b0}};      
                else
                    dreg <= din_s1;
            end     
        end else begin
            always @(posedge clk or negedge reset_n) begin
                if (reset_n == 0) 
                    dreg <= {depth-1{1'b0}};
                else
                    dreg <= {dreg[depth-3:0], din_s1};
            end
        end
    endgenerate

    assign dout = dreg[depth-2];
   
endmodule  // altera_std_synchronizer
// END OF MODULE
                        

// START_FILE_HEADER ----------------------------------------------------------
//
// Filename    : altera_std_synchronizer_bundle.v
//
// Description : Contains the simulation model for the altera_std_synchronizer_bundle
//
// Owner       :
//
// Copyright (C) Altera Corporation 2008, All Rights Reserved
//
// END_FILE_HEADER ------------------------------------------------------------

// START_MODULE_NAME-----------------------------------------------------------
//
// Module Name : altera_std_synchronizer_bundle
//
// Description : Bundle of bit synchronizers. 
//               WARNING: only use this to synchronize a bundle of 
//               *independent* single bit signals or a Gray encoded 
//               bus of signals. Also remember that pulses entering 
//               the synchronizer will be swallowed upon a metastable
//               condition if the pulse width is shorter than twice
//               the synchronizing clock period.
//
// END_MODULE_NAME-------------------------------------------------------------

module altera_std_synchronizer_bundle  (
                                        clk,
                                        reset_n,
                                        din,
                                        dout
                                        );
    // GLOBAL PARAMETER DECLARATION
    parameter width = 1;
    parameter depth = 3;   
   
    // INPUT PORT DECLARATION
    input clk;
    input reset_n;
    input [width-1:0] din;

    // OUTPUT PORT DECLARATION
    output [width-1:0] dout;
   
    generate
        genvar i;
        for (i=0; i<width; i=i+1)
        begin : sync
            altera_std_synchronizer #(.depth(depth))
                                    u  (
                                        .clk(clk), 
                                        .reset_n(reset_n), 
                                        .din(din[i]), 
                                        .dout(dout[i])
                                        );
        end
    endgenerate
   
endmodule // altera_std_synchronizer_bundle
// END OF MODULE

module  alt_cal
        ( 
        busy,
        cal_error,
        clock,
        dprio_addr,
        dprio_busy,
        dprio_datain,
        dprio_dataout,
        dprio_rden,
        dprio_wren,
        quad_addr,
        remap_addr,
        reset,
        retain_addr,
        start,
        transceiver_init,
        testbuses) /* synthesis synthesis_clearbox=1 */;

        parameter number_of_channels = 1;
        parameter channel_address_width = 1;
        parameter sim_model_mode = "TRUE";
        parameter lpm_type = "alt_cal";
        parameter lpm_hint = "UNUSED";

        output   busy;
        output   [(number_of_channels-1):0]  cal_error;
        input   clock;
        output   [15:0]  dprio_addr;
        input   dprio_busy;
        input   [15:0]  dprio_datain;
        output   [15:0]  dprio_dataout;
        output   dprio_rden;
        output   dprio_wren;
        output   [8:0]  quad_addr;
        input   [11:0]  remap_addr;
        input   reset;
        output   [0:0]  retain_addr;
        input   start;
        input   transceiver_init;
        input   [(4*number_of_channels)-1:0]  testbuses;

        (* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON;POWER_UP_LEVEL=LOW"} *)
        reg     [0:0]   p0addr_sim;
        (* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON;POWER_UP_LEVEL=LOW"} *)
        reg     [3:0]   sim_counter_reg;
        wire    [3:0]   wire_next_scount_num_dataa;
        wire    [3:0]   wire_next_scount_num_datab;
        wire    [3:0]   wire_next_scount_num_result;
        wire  [0:0]  busy_sim;
        wire  [0:0]  sim_activator;
        wire  [0:0]  sim_counter_and;
        wire  [3:0]  sim_counter_next;
        wire  [0:0]  sim_counter_or;

        // synopsys translate_off
        initial
                p0addr_sim[0:0] = 0;
        // synopsys translate_on
        always @ ( posedge clock)
                p0addr_sim[0:0] <= 1'b1;
        // synopsys translate_off
        initial
                sim_counter_reg = 0;
        // synopsys translate_on
        always @ ( posedge clock)
                sim_counter_reg <= ({4{((~ reset) & sim_activator)}} & (({4{(p0addr_sim | ((~ sim_counter_and) & sim_counter_or))}} & sim_counter_next) | ({4{sim_counter_and}} & sim_counter_reg)));
        assign
                wire_next_scount_num_result = wire_next_scount_num_dataa + wire_next_scount_num_datab;
        assign
                wire_next_scount_num_dataa = sim_counter_reg,
                wire_next_scount_num_datab = 4'b0001;
        assign
                busy = busy_sim,
                busy_sim = (~reset & p0addr_sim & (~ sim_counter_and)),
                cal_error = 1'b0,
                dprio_addr = {16{1'b0}},
                dprio_dataout = {16{1'b0}},
                dprio_rden = 1'b0,
                dprio_wren = 1'b0,
                quad_addr = {9{1'b0}},
                retain_addr = 1'b0,
                sim_activator = p0addr_sim,
                sim_counter_and = (((sim_counter_reg[0] & sim_counter_reg[1]) & sim_counter_reg[2]) & sim_counter_reg[3]),
                sim_counter_next = wire_next_scount_num_result,
                sim_counter_or = (((sim_counter_reg[0] | sim_counter_reg[1]) | sim_counter_reg[2]) | sim_counter_reg[3]);
endmodule //alt_cal
//VALID FILE



module  alt_cal_mm
        ( 
        busy,
        cal_error,
        clock,
        dprio_addr,
        dprio_busy,
        dprio_datain,
        dprio_dataout,
        dprio_rden,
        dprio_wren,
        quad_addr,
        remap_addr,
        reset,
        retain_addr,
        start,
        transceiver_init,
        testbuses) /* synthesis synthesis_clearbox=1 */;

        parameter number_of_channels = 1;
        parameter channel_address_width = 1;
        parameter sim_model_mode = "TRUE";
        parameter lpm_type = "alt_cal_mm";
        parameter lpm_hint = "UNUSED";

	// Internal parameters
	parameter idle			= 5'd0;
	parameter ch_wait		= 5'd1;
	parameter testbus_set		= 5'd2;
	parameter offsets_pden_rd	= 5'd3;
	parameter offsets_pden_wr	= 5'd4;
	parameter cal_pd_wr		= 5'd5;
	parameter cal_rx_rd		= 5'd6;
	parameter cal_rx_wr		= 5'd7;
	parameter dprio_wait		= 5'd8;
	parameter sample_tb		= 5'd9;
	parameter test_input		= 5'd10;
	parameter ch_adv		= 5'd12;
	parameter dprio_read		= 5'd14;
	parameter dprio_write		= 5'd15;
	parameter kick_start_rd 	= 5'd13;
	parameter kick_start_wr 	= 5'd16;
	parameter kick_pause 		= 5'd17;
	parameter kick_delay_oc		= 5'd18;
	parameter sample_length		= 8'd0;



        output   busy;
        output   [(number_of_channels-1):0]  cal_error;
        input   clock;
        output   [15:0]  dprio_addr;
        input   dprio_busy;
        input   [15:0]  dprio_datain;
        output   [15:0]  dprio_dataout;
        output   dprio_rden;
        output   dprio_wren;
        output   [8:0]  quad_addr;
        input   [11:0]  remap_addr;
        input   reset;
        output   [0:0]  retain_addr;
        input   start;
        input   transceiver_init;
        input   [(4*number_of_channels)-1:0]  testbuses;

        (* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON;POWER_UP_LEVEL=LOW"} *)
        reg     [0:0]   p0addr_sim;
        (* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON;POWER_UP_LEVEL=LOW"} *)
        reg     [3:0]   sim_counter_reg;
        wire    [3:0]   wire_next_scount_num_dataa;
        wire    [3:0]   wire_next_scount_num_datab;
        wire    [3:0]   wire_next_scount_num_result;
        wire  [0:0]  busy_sim;
        wire  [0:0]  sim_activator;
        wire  [0:0]  sim_counter_and;
        wire  [3:0]  sim_counter_next;
        wire  [0:0]  sim_counter_or;

        // synopsys translate_off
        initial
                p0addr_sim[0:0] = 0;
        // synopsys translate_on
        always @ ( posedge clock)
                p0addr_sim[0:0] <= 1'b1;
        // synopsys translate_off
        initial
                sim_counter_reg = 0;
        // synopsys translate_on
        always @ ( posedge clock)
                sim_counter_reg <= ({4{((~ reset) & sim_activator)}} & (({4{(p0addr_sim | ((~ sim_counter_and) & sim_counter_or))}} & sim_counter_next) | ({4{sim_counter_and}} & sim_counter_reg)));
        assign
                wire_next_scount_num_result = wire_next_scount_num_dataa + wire_next_scount_num_datab;
        assign
                wire_next_scount_num_dataa = sim_counter_reg,
                wire_next_scount_num_datab = 4'b0001;
        assign
                busy = busy_sim,
                busy_sim = (p0addr_sim & (~ sim_counter_and)),
                cal_error = 1'b0,
                dprio_addr = {16{1'b0}},
                dprio_dataout = {16{1'b0}},
                dprio_rden = 1'b0,
                dprio_wren = 1'b0,
                quad_addr = {9{1'b0}},
                retain_addr = 1'b0,
                sim_activator = p0addr_sim,
                sim_counter_and = (((sim_counter_reg[0] & sim_counter_reg[1]) & sim_counter_reg[2]) & sim_counter_reg[3]),
                sim_counter_next = wire_next_scount_num_result,
                sim_counter_or = (((sim_counter_reg[0] | sim_counter_reg[1]) | sim_counter_reg[2]) | sim_counter_reg[3]);
endmodule //alt_cal
//VALID FILE



module  alt_cal_c3gxb
        ( 
        busy,
        cal_error,
        clock,
        dprio_addr,
        dprio_busy,
        dprio_datain,
        dprio_dataout,
        dprio_rden,
        dprio_wren,
        quad_addr,
        remap_addr,
        reset,
        retain_addr,
        start,
        testbuses) /* synthesis synthesis_clearbox=1 */;

        parameter number_of_channels = 1;
        parameter channel_address_width = 1;
        parameter sim_model_mode = "TRUE";
        parameter lpm_type = "alt_cal_c3gxb";
        parameter lpm_hint = "UNUSED";

        output   busy;
        output   [(number_of_channels-1):0]  cal_error;
        input   clock;
        output   [15:0]  dprio_addr;
        input   dprio_busy;
        input   [15:0]  dprio_datain;
        output   [15:0]  dprio_dataout;
        output   dprio_rden;
        output   dprio_wren;
        output   [8:0]  quad_addr;
        input   [11:0]  remap_addr;
        input   reset;
        output   [0:0]  retain_addr;
        input   start;
        input   [(number_of_channels)-1:0]  testbuses;

        (* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON;POWER_UP_LEVEL=LOW"} *)
        reg     [0:0]   p0addr_sim;
        (* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON;POWER_UP_LEVEL=LOW"} *)
        reg     [3:0]   sim_counter_reg;
        wire    [3:0]   wire_next_scount_num_dataa;
        wire    [3:0]   wire_next_scount_num_datab;
        wire    [3:0]   wire_next_scount_num_result;
        wire  [0:0]  busy_sim;
        wire  [0:0]  sim_activator;
        wire  [0:0]  sim_counter_and;
        wire  [3:0]  sim_counter_next;
        wire  [0:0]  sim_counter_or;

        // synopsys translate_off
        initial
                p0addr_sim[0:0] = 0;
        // synopsys translate_on
        always @ ( posedge clock)
                p0addr_sim[0:0] <= 1'b1;
        // synopsys translate_off
        initial
                sim_counter_reg = 0;
        // synopsys translate_on
        always @ ( posedge clock)
                sim_counter_reg <= ({4{((~ reset) & sim_activator)}} & (({4{(p0addr_sim | ((~ sim_counter_and) & sim_counter_or))}} & sim_counter_next) | ({4{sim_counter_and}} & sim_counter_reg)));
        assign
                wire_next_scount_num_result = wire_next_scount_num_dataa + wire_next_scount_num_datab;
        assign
                wire_next_scount_num_dataa = sim_counter_reg,
                wire_next_scount_num_datab = 4'b0001;
        assign
                busy = busy_sim,
                busy_sim = (p0addr_sim & (~ sim_counter_and)),
                cal_error = 1'b0,
                dprio_addr = {16{1'b0}},
                dprio_dataout = {16{1'b0}},
                dprio_rden = 1'b0,
                dprio_wren = 1'b0,
                quad_addr = {9{1'b0}},
                retain_addr = 1'b0,
                sim_activator = p0addr_sim,
                sim_counter_and = (((sim_counter_reg[0] & sim_counter_reg[1]) & sim_counter_reg[2]) & sim_counter_reg[3]),
                sim_counter_next = wire_next_scount_num_result,
                sim_counter_or = (((sim_counter_reg[0] | sim_counter_reg[1]) | sim_counter_reg[2]) | sim_counter_reg[3]);
endmodule
//VALID FILE


//-------------------------------------------------------------------
// Filename    : alt_aeq_s4.v
//
// Description : Simulation model for Stratix IV ADCE
//
// Limitation  : Currently, only apllies for Stratix IV 
//
// Copyright (c) Altera Corporation 1997-2009
// All rights reserved
//
//-------------------------------------------------------------------
module alt_aeq_s4
#(
  parameter show_errors = "NO",  // "YES" = show errors; anything else = do not show errors
  parameter radce_hflck = 15'h0000, // settings for RADCE_HFLCK CRAM settings - get values from ICD
  parameter radce_lflck = 15'h0000, // settings for RADCE_LFLCK CRAM settings - get values from ICD
  parameter use_hw_conv_det = 1'b0, // use hardware convergence detect macro if set to 1'b1 - else, default to soft ip.

  parameter number_of_channels = 5,
  parameter channel_address_width = 3,
  parameter lpm_type = "alt_aeq_s4",
  parameter lpm_hint = "UNUSED"
)
(
  input                             reconfig_clk,
  input                             aclr,
  input                             calibrate, // 'start'
  input                             shutdown, // shut down (put channel(s) in standby)
  input                             all_channels,
  input [channel_address_width-1:0] logical_channel_address,
  input                      [11:0] remap_address,
  output                      [8:0] quad_address,
  input    [number_of_channels-1:0] adce_done,
  output                            busy,
  output reg [number_of_channels-1:0] adce_standby, // put channels into standby - to RX PMA
  input                             adce_continuous,
  output                            adce_cal_busy,

// multiplexed signals for interfacing with DPRIO
  input                             dprio_busy,
  input [15:0]                      dprio_in,
  output                            dprio_wren,
  output                            dprio_rden,
  output [15:0]                     dprio_addr, // increase to 16 bits
  output [15:0]                     dprio_data,

  output [3:0]                      eqout,
  output                            timeout,
  input [7*number_of_channels-1:0]  testbuses,
  output [4*number_of_channels-1:0] testbus_sels,
  
// SHOW_ERRORS option
  output [number_of_channels-1:0]   conv_error,
  output [number_of_channels-1:0]   error
// end SHOW_ERRORS option
 );

//********************************************************************************
// DECLARATIONS
//********************************************************************************
  
  reg [7:0] busy_counter; // 256 cycles

  assign 
    dprio_addr = {16{1'b0}},
    dprio_data = {16{1'b0}},
    dprio_rden = 1'b0,
    dprio_wren = 1'b0,
    quad_address =  {9{1'b0}},
    busy = |busy_counter,
    adce_cal_busy = |busy_counter[7:4], // only for the first half of the timer
    eqout = {4{1'b0}},
    error = {number_of_channels{1'b0}},
    conv_error = {number_of_channels{1'b0}},
    timeout    = 1'b0,
    testbus_sels = {4*number_of_channels{1'b0}};
    
  always @ (posedge reconfig_clk) begin
    if (aclr) begin
      busy_counter <= 8'h0;
      adce_standby[logical_channel_address] <= 1'b0;
    end else if (calibrate) begin
      busy_counter <= 8'hff;
      adce_standby <= {number_of_channels{1'b0}};
    end else if (shutdown) begin
      busy_counter <= 8'hf;
      adce_standby[logical_channel_address] <= 1'b1;
    end else if (busy) begin // if not 0, keep decrementing
      busy_counter <= busy_counter - 1'b1;
    end
  end
  

endmodule



//-------------------------------------------------------------------
// Filename    : alt_eyemon.v
//
// Description : Simulation model for Stratix IV Eye Monitor (EyeQ)
//
// Limitation  : Currently, only apllies for Stratix IV 
//
// Copyright (c) Altera Corporation 1997-2009
// All rights reserved
//
//-------------------------------------------------------------------
module alt_eyemon 
#(
  parameter channel_address_width = 3,
  parameter lpm_type = "alt_eyemon",
  parameter lpm_hint = "UNUSED",

  parameter avmm_slave_addr_width = 16, // tbd
  parameter avmm_slave_rdata_width = 16,
  parameter avmm_slave_wdata_width = 16,

  parameter avmm_master_addr_width = 16,
  parameter avmm_master_rdata_width = 16,
  parameter avmm_master_wdata_width = 16,

  parameter dprio_addr_width = 16,
  parameter dprio_data_width = 16,
  parameter ireg_chaddr_width = channel_address_width,
  parameter ireg_wdaddr_width = 2, // width of 2 - only need to address 4 registers
  parameter ireg_data_width   = 16,
  
  parameter ST_IDLE  = 2'd0,
  parameter ST_WRITE = 2'd1,
  parameter ST_READ  = 2'd2
)
(
  input                               i_resetn,
  input                               i_avmm_clk,

  // avalon slave ports
  input  [avmm_slave_addr_width-1:0]  i_avmm_saddress,
  input                               i_avmm_sread,
  input                               i_avmm_swrite,
  input  [avmm_slave_wdata_width-1:0] i_avmm_swritedata,
  output [avmm_slave_rdata_width-1:0] o_avmm_sreaddata,
  output reg                              o_avmm_swaitrequest,

  input        i_remap_phase,
  input [11:0] i_remap_address, // from address_pres_reg
  output [8:0] o_quad_address, // output to altgx_reconfig
  output       o_reconfig_busy,

  // alt_dprio interface
  input                         i_dprio_busy,
  input  [dprio_data_width-1:0] i_dprio_in,
  output                        o_dprio_wren,
  output                        o_dprio_rden,
  output [dprio_addr_width-1:0] o_dprio_addr,
  output [dprio_data_width-1:0] o_dprio_data
);

//********************************************************************************
// DECLARATIONS
//********************************************************************************
  reg [1:0]  state, state0q;
  reg        reg_read, reg_write;
  reg [5:0] busy_counter;

// register file regs
  reg [ireg_chaddr_width-1:0] reg_chaddress, reg_chaddress0q;
  reg [ireg_data_width-1:0] reg_data, reg_data0q;
  reg [ireg_data_width-1:0] reg_ctrlstatus, reg_ctrlstatus0q;
  reg [ireg_wdaddr_width-1:0] reg_wdaddress, reg_wdaddress0q;

  reg [6:0] dprio_reg [(1 << channel_address_width)-1:0];
  reg [6:0] dprio_reg0q [(1 << channel_address_width)-1:0]; // make this scale with the channel width - 6 bits for phase step, one for enable

  wire invalid_channel_address, invalid_word_address;
  integer i;

// synopsys translate_off
initial begin
  state            = 'b0;
  state0q          = 'b0;
  busy_counter     = 'b0;
  reg_chaddress0q  = 'b0;
  reg_data0q       = 'b0;
  reg_ctrlstatus0q = 'b0;
  reg_wdaddress0q  = 'b0;
  reg_chaddress    = 'b0;
  reg_data         = 'b0;
  reg_ctrlstatus   = 'b0;
  reg_wdaddress    = 'b0;
end
// synopsys translate_on  

  assign 
    o_dprio_wren = 1'b0,
    o_dprio_rden = 1'b0,
    o_dprio_addr = {dprio_addr_width{1'b0}},
    o_dprio_data = {dprio_data_width{1'b0}},
    o_quad_address = 9'b0,
    o_reconfig_busy = reg_ctrlstatus0q[15];



//********************************************************************************
// Sequential Logic - Avalon Slave
//********************************************************************************
  // state flops
  always @ (posedge i_avmm_clk) begin
    if (~i_resetn) begin
      state0q <= ST_IDLE;
    end else begin
      state0q <= state;
    end
  end
  

  always @ (posedge i_avmm_clk) begin
    if (~i_resetn) begin
      busy_counter <= 6'h0;
    end else if ((reg_ctrlstatus[0] && ~reg_ctrlstatus0q[0]) && ~reg_ctrlstatus[1]) begin // write op (takes longer to simulate read-modify-write)
      busy_counter <= 6'h3f;
    end else if ((reg_ctrlstatus[0] && ~reg_ctrlstatus0q[0]) && reg_ctrlstatus[1]) begin // read op
      busy_counter <= 6'h1f;
    end else if (|busy_counter) begin // if not 0, keep decrementing
      busy_counter <= busy_counter - 1'b1;
    end
  end

//********************************************************************************
// Combinational Logic - Avalon Slave
//********************************************************************************

  always @ (*) begin
    // avoid latches
    o_avmm_swaitrequest = 1'b0;
    reg_write = 1'b0;
    reg_read = 1'b0;
   
    case (state0q) 
      ST_WRITE: begin
        // check busy and discard the write data if we are busy
        o_avmm_swaitrequest = 1'b0;
//        if (reg_ctrlstatus0q[15]) begin // don't commit the write if we are busy
        state = ST_IDLE; // single cycle write - always return to idle
      end
      ST_READ: begin
        o_avmm_swaitrequest = 1'b0;
        reg_read = 1'b1;
        state = ST_IDLE; // single cycle read - always return to idle
      end
      default: begin //ST_IDLE: begin
        // effectively priority encoded - if read and write both asserted (error condition), reads will take precedence
        // this ensures non-destructive behaviour
        if (i_avmm_sread) begin 
          o_avmm_swaitrequest = 1'b1;
          reg_read = 1'b1;
          state = ST_READ;
        end else if (i_avmm_swrite) begin
          o_avmm_swaitrequest = 1'b1;
          if (reg_ctrlstatus0q[15]) begin // don't commit the write if we are busy
            reg_write = 1'b0;
          end else begin
            reg_write = 1'b1;
          end
          state = ST_WRITE;
        end else begin
          o_avmm_swaitrequest = 1'b0;
          state = ST_IDLE;
        end
      end
    endcase
  end



//********************************************************************************
// Sequential Logic - Register File
//********************************************************************************
  // register file
  always @ (posedge i_avmm_clk) begin
    if (~i_resetn) begin
      reg_chaddress0q  <= 'b0;
      reg_data0q       <= 'b0;
      reg_ctrlstatus0q <= 'b0;
      reg_wdaddress0q  <= 'b0;
      for (i = 0; i < (1 << channel_address_width); i = i + 1) begin
        dprio_reg0q[i] <= 7'b0;
      end
    end else begin
      reg_chaddress0q  <= reg_chaddress;
      reg_data0q       <= reg_data;
      reg_ctrlstatus0q <= reg_ctrlstatus;
      reg_wdaddress0q  <= reg_wdaddress;
      for (i = 0; i < (1 << channel_address_width); i = i + 1) begin
        dprio_reg0q[i] <= dprio_reg[i];
      end
    end
  end

//********************************************************************************
// Combinational Logic - Register File
//********************************************************************************
  // read mux
  assign o_avmm_sreaddata = reg_read ? (({ireg_data_width{(i_avmm_saddress == 'h0)}} & reg_ctrlstatus0q) |
                                        ({ireg_data_width{(i_avmm_saddress == 'h1)}} & reg_chaddress0q)  |
                                        ({ireg_data_width{(i_avmm_saddress == 'h2)}} & reg_wdaddress0q)  |
                                        ({ireg_data_width{(i_avmm_saddress == 'h3)}} & reg_data0q)) : {ireg_data_width{1'b0}};

  assign invalid_channel_address = (i_remap_address == 12'hfff);
  assign invalid_word_address    = (reg_wdaddress0q > 'h1);

  always @ (*) begin
    reg_chaddress    = reg_chaddress0q;
    reg_data         = reg_data0q;
    reg_ctrlstatus   = reg_ctrlstatus0q;
    reg_wdaddress    = reg_wdaddress0q;
    for (i = 0; i < (1 << channel_address_width); i = i + 1) begin
      dprio_reg0q[i] <= dprio_reg[i];
    end


  // handle busy condition - if mdone is raised, we clear reg_busy bit
    if (busy_counter == 'b1) begin // counter is 1 - simulate the 1 cycle done pulse
      reg_ctrlstatus[15] = 1'b0; // set busy to 0
      reg_ctrlstatus[0]  = 1'b0; // clear the 'start' bit as well
      if (reg_ctrlstatus0q[1]) begin// read operation
        if (reg_wdaddress0q == 'b0) begin
          reg_data[0] = dprio_reg0q[reg_chaddress0q][0];
          reg_data[15:1] = 15'b0;
        end else if (reg_wdaddress0q == 'b1) begin
          reg_data[5:0] = dprio_reg0q[reg_chaddress0q][6:1];
          reg_data[15:6] = 10'b0;
        end
      end
    end

  // write select for register file 
    if (reg_write) begin
      if (i_avmm_saddress == 'h0) begin
        reg_ctrlstatus[1] = i_avmm_swritedata[1];
        if (i_avmm_swritedata[0]) begin // writing to the start command bit
          if (invalid_channel_address || invalid_word_address) begin // invalid channel address
            reg_ctrlstatus[15] = 1'b0; // not busy - don't start the operation due to invalid address
            reg_ctrlstatus[14] = invalid_word_address;
            reg_ctrlstatus[13] = invalid_channel_address;
          end else begin // no error condition, start the operation, auto-clear any existing errors
            if (~i_avmm_swritedata[1]) begin // write operation
              if (reg_wdaddress0q == 'd0) begin
                dprio_reg[reg_chaddress0q][0] = reg_data0q[0];
              end else if (reg_wdaddress0q == 'd1) begin
                dprio_reg[reg_chaddress0q][6:1] = reg_data0q[5:0];
              end
            end
            reg_ctrlstatus[0]  = 1'b1; // start bit asserted
            reg_ctrlstatus[15] = 1'b1; // assert busy
            reg_ctrlstatus[14] = 1'b0; // clear errors
            reg_ctrlstatus[13] = 1'b0; // clear errors
          end
        end else begin
          reg_ctrlstatus[15] = 1'b0; // do not assert busy
          reg_ctrlstatus[14] = i_avmm_swritedata[14] ? 1'b0 : reg_ctrlstatus0q[14]; // clear error
          reg_ctrlstatus[13] = i_avmm_swritedata[13] ? 1'b0 : reg_ctrlstatus0q[13]; // clear error        
        end
      end else if (i_avmm_saddress == 'h1) begin
        reg_chaddress = i_avmm_swritedata;
      end else if (i_avmm_saddress == 'h2) begin
        reg_wdaddress = i_avmm_swritedata[ireg_wdaddr_width-1:0];
      end else if (i_avmm_saddress == 'h3) begin
        reg_data = i_avmm_swritedata[ireg_data_width-1:0];
      end
      
      // do nothing if not a valid address
    end
  end

endmodule

//-------------------------------------------------------------------
// Filename    : alt_dfe.v
//
// Description : Simulation model for Stratix IV DFE
//
// Limitation  : Currently, only apllies for Stratix IV 
//
// Copyright (c) Altera Corporation 1997-2009
// All rights reserved
//
//-------------------------------------------------------------------
module alt_dfe 
#(
  parameter channel_address_width = 3,
  parameter lpm_type = "alt_dfe",
  parameter lpm_hint = "UNUSED",

  parameter avmm_slave_addr_width = 16, // tbd
  parameter avmm_slave_rdata_width = 16,
  parameter avmm_slave_wdata_width = 16,

  parameter avmm_master_addr_width = 16,
  parameter avmm_master_rdata_width = 16,
  parameter avmm_master_wdata_width = 16,

  parameter dprio_addr_width = 16,
  parameter dprio_data_width = 16,
  parameter ireg_chaddr_width = channel_address_width,
  parameter ireg_wdaddr_width = 2, // width of 2 - only need to address 4 registers
  parameter ireg_data_width   = 16,
  
  parameter ST_IDLE  = 2'd0,
  parameter ST_WRITE = 2'd1,
  parameter ST_READ  = 2'd2
)
(
  input                               i_resetn,
  input                               i_avmm_clk,

  // avalon slave ports
  input  [avmm_slave_addr_width-1:0]  i_avmm_saddress,
  input                               i_avmm_sread,
  input                               i_avmm_swrite,
  input  [avmm_slave_wdata_width-1:0] i_avmm_swritedata,
  output [avmm_slave_rdata_width-1:0] o_avmm_sreaddata,
  output reg                              o_avmm_swaitrequest,

  input [11:0] i_remap_address, // from address_pres_reg
  output [8:0] o_quad_address, // output to altgx_reconfig
  output       o_reconfig_busy,

  // alt_dprio interface
  input                         i_dprio_busy,
  input  [dprio_data_width-1:0] i_dprio_in,
  output                        o_dprio_wren,
  output                        o_dprio_rden,
  output [dprio_addr_width-1:0] o_dprio_addr,
  output [dprio_data_width-1:0] o_dprio_data
);

//********************************************************************************
// DECLARATIONS
//********************************************************************************
  reg [1:0]  state, state0q;
  reg        reg_read, reg_write;
  reg [5:0] busy_counter;

// register file regs
  reg [ireg_chaddr_width-1:0] reg_chaddress, reg_chaddress0q;
  reg [ireg_data_width-1:0] reg_data, reg_data0q;
  reg [ireg_data_width-1:0] reg_ctrlstatus, reg_ctrlstatus0q;
  reg [ireg_wdaddr_width-1:0] reg_wdaddress, reg_wdaddress0q;

  reg [12:0] dprio_reg [(1 << channel_address_width)-1:0];
  reg [12:0] dprio_reg0q [(1 << channel_address_width)-1:0]; // make this scale with the channel width - 6 bits for phase step, one for enable

  wire invalid_channel_address, invalid_word_address;
  integer i;

// synopsys translate_off
initial begin
  state            = 'b0;
  state0q          = 'b0;
  busy_counter     = 'b0;
  reg_chaddress0q  = 'b0;
  reg_data0q       = 'b0;
  reg_ctrlstatus0q = 'b0;
  reg_wdaddress0q  = 'b0;
  reg_chaddress    = 'b0;
  reg_data         = 'b0;
  reg_ctrlstatus   = 'b0;
  reg_wdaddress    = 'b0;
end
// synopsys translate_on  

  assign 
    o_dprio_wren = 1'b0,
    o_dprio_rden = 1'b0,
    o_dprio_addr = {dprio_addr_width{1'b0}},
    o_dprio_data = {dprio_data_width{1'b0}},
    o_quad_address = 9'b0,
    o_reconfig_busy = reg_ctrlstatus0q[15];



//********************************************************************************
// Sequential Logic - Avalon Slave
//********************************************************************************
  // state flops
  always @ (posedge i_avmm_clk) begin
    if (~i_resetn) begin
      state0q <= ST_IDLE;
    end else begin
      state0q <= state;
    end
  end
  

  always @ (posedge i_avmm_clk) begin
    if (~i_resetn) begin
      busy_counter <= 6'h0;
    end else if ((reg_ctrlstatus[0] && ~reg_ctrlstatus0q[0]) && ~reg_ctrlstatus[1]) begin // write op (takes longer to simulate read-modify-write)
      busy_counter <= 6'h3f;
    end else if ((reg_ctrlstatus[0] && ~reg_ctrlstatus0q[0]) && reg_ctrlstatus[1]) begin // read op
      busy_counter <= 6'h1f;
    end else if (|busy_counter) begin // if not 0, keep decrementing
      busy_counter <= busy_counter - 1'b1;
    end
  end

//********************************************************************************
// Combinational Logic - Avalon Slave
//********************************************************************************

  always @ (*) begin
    // avoid latches
    o_avmm_swaitrequest = 1'b0;
    reg_write = 1'b0;
    reg_read = 1'b0;
   
    case (state0q) 
      ST_WRITE: begin
        // check busy and discard the write data if we are busy
        o_avmm_swaitrequest = 1'b0;
//        if (reg_ctrlstatus0q[15]) begin // don't commit the write if we are busy
        state = ST_IDLE; // single cycle write - always return to idle
      end
      ST_READ: begin
        o_avmm_swaitrequest = 1'b0;
        reg_read = 1'b1;
        state = ST_IDLE; // single cycle read - always return to idle
      end
      default: begin //ST_IDLE: begin
        // effectively priority encoded - if read and write both asserted (error condition), reads will take precedence
        // this ensures non-destructive behaviour
        if (i_avmm_sread) begin 
          o_avmm_swaitrequest = 1'b1;
          reg_read = 1'b1;
          state = ST_READ;
        end else if (i_avmm_swrite) begin
          o_avmm_swaitrequest = 1'b1;
          if (reg_ctrlstatus0q[15]) begin // don't commit the write if we are busy
            reg_write = 1'b0;
          end else begin
            reg_write = 1'b1;
          end
          state = ST_WRITE;
        end else begin
          o_avmm_swaitrequest = 1'b0;
          state = ST_IDLE;
        end
      end
    endcase
  end



//********************************************************************************
// Sequential Logic - Register File
//********************************************************************************
  // register file
  always @ (posedge i_avmm_clk) begin
    if (~i_resetn) begin
      reg_chaddress0q  <= 'b0;
      reg_data0q       <= 'b0;
      reg_ctrlstatus0q <= 'b0;
      reg_wdaddress0q  <= 'b0;
      for (i = 0; i < (1 << channel_address_width); i = i + 1) begin
        dprio_reg0q[i] <= 13'b0;
      end
    end else begin
      reg_chaddress0q  <= reg_chaddress;
      reg_data0q       <= reg_data;
      reg_ctrlstatus0q <= reg_ctrlstatus;
      reg_wdaddress0q  <= reg_wdaddress;
      for (i = 0; i < (1 << channel_address_width); i = i + 1) begin
        dprio_reg0q[i] <= dprio_reg[i];
      end
    end
  end

//********************************************************************************
// Combinational Logic - Register File
//********************************************************************************
  // read mux
  assign o_avmm_sreaddata = reg_read ? (({ireg_data_width{(i_avmm_saddress == 'h0)}} & reg_ctrlstatus0q) |
                                        ({ireg_data_width{(i_avmm_saddress == 'h1)}} & reg_chaddress0q)  |
                                        ({ireg_data_width{(i_avmm_saddress == 'h2)}} & reg_wdaddress0q)  |
                                        ({ireg_data_width{(i_avmm_saddress == 'h3)}} & reg_data0q)) : {ireg_data_width{1'b0}};

  assign invalid_channel_address = (i_remap_address == 12'hfff);
  assign invalid_word_address    = (reg_wdaddress0q > 'h2);

  always @ (*) begin
    reg_chaddress    = reg_chaddress0q;
    reg_data         = reg_data0q;
    reg_ctrlstatus   = reg_ctrlstatus0q;
    reg_wdaddress    = reg_wdaddress0q;
    for (i = 0; i < (1 << channel_address_width); i = i + 1) begin
      dprio_reg0q[i] <= dprio_reg[i];
    end


  // handle busy condition - if mdone is raised, we clear reg_busy bit
    if (busy_counter == 'b1) begin // counter is 1 - simulate the 1 cycle done pulse
      reg_ctrlstatus[15] = 1'b0; // set busy to 0
      reg_ctrlstatus[0]  = 1'b0; // clear the 'start' bit as well
      if (reg_ctrlstatus0q[1]) begin// read operation
        if (reg_wdaddress0q == 'b0) begin
          reg_data[2:0] = dprio_reg0q[reg_chaddress0q][2:0];
          reg_data[15:3] = 15'b0;
        end else if (reg_wdaddress0q == 'b1) begin
          reg_data[3:0] = dprio_reg0q[reg_chaddress0q][6:3];
          reg_data[15:4] = 11'b0;
        end else if (reg_wdaddress0q == 'd2) begin
          reg_data[5:0] = dprio_reg0q[reg_chaddress0q][12:7];
          reg_data[15:6] = 10'b0;
        end
      end
    end

  // write select for register file 
    if (reg_write) begin
      if (i_avmm_saddress == 'h0) begin
        reg_ctrlstatus[1] = i_avmm_swritedata[1];
        if (i_avmm_swritedata[0]) begin // writing to the start command bit
          if (invalid_channel_address || invalid_word_address) begin // invalid channel address
            reg_ctrlstatus[15] = 1'b0; // not busy - don't start the operation due to invalid address
            reg_ctrlstatus[14] = invalid_word_address;
            reg_ctrlstatus[13] = invalid_channel_address;
          end else begin // no error condition, start the operation, auto-clear any existing errors
            if (~i_avmm_swritedata[1]) begin // write operation
              if (reg_wdaddress0q == 'd0) begin
                dprio_reg[reg_chaddress0q][2:0] = reg_data0q[2:0];
              end else if (reg_wdaddress0q == 'd1) begin
                dprio_reg[reg_chaddress0q][6:3] = reg_data0q[3:0];
              end else if (reg_wdaddress0q == 'd2) begin
                dprio_reg[reg_chaddress0q][12:7] = reg_data0q[5:0];
              end
            end
            reg_ctrlstatus[0]  = 1'b1; // start bit asserted
            reg_ctrlstatus[15] = 1'b1; // assert busy
            reg_ctrlstatus[14] = 1'b0; // clear errors
            reg_ctrlstatus[13] = 1'b0; // clear errors
          end
        end else begin
          reg_ctrlstatus[15] = 1'b0; // do not assert busy
          reg_ctrlstatus[14] = i_avmm_swritedata[14] ? 1'b0 : reg_ctrlstatus0q[14]; // clear error
          reg_ctrlstatus[13] = i_avmm_swritedata[13] ? 1'b0 : reg_ctrlstatus0q[13]; // clear error        
        end
      end else if (i_avmm_saddress == 'h1) begin
        reg_chaddress = i_avmm_swritedata;
      end else if (i_avmm_saddress == 'h2) begin
        reg_wdaddress = i_avmm_swritedata[ireg_wdaddr_width-1:0];
      end else if (i_avmm_saddress == 'h3) begin
        reg_data = i_avmm_swritedata[ireg_data_width-1:0];
      end
      
      // do nothing if not a valid address
    end
  end

endmodule


// VIRTUAL JTAG MODULE CONSTANTS

// the default bit length for time and value
`define DEFAULT_BIT_LENGTH 32

// the bit length for type
`define TYPE_BIT_LENGTH 4

// the bit length for delay time
`define TIME_BIT_LENGTH 64

// the number of selection bits + width of hub instructions(3)
`define NUM_SELECTION_BITS 4

// the states for the parser state machine
`define STARTSTATE    3'b000
`define LENGTHSTATE   3'b001
`define VALUESTATE    3'b011
`define TYPESTATE     3'b111
`define TIMESTATE     3'b101

`define V_DR_SCAN_TYPE 4'b0010
`define V_IR_SCAN_TYPE 4'b0001

// specify time scale
`define CLK_PERIOD 100000

`define DELAY_RESOLUTION 10000

// the states for the tap controller state machine
`define TLR_ST  5'b00000
`define RTI_ST  5'b00001
`define DRS_ST  5'b00011
`define CDR_ST  5'b00111
`define SDR_ST  5'b01111
`define E1DR_ST 5'b01011
`define PDR_ST  5'b01101
`define E2DR_ST 5'b01000
`define UDR_ST  5'b01001
`define IRS_ST  5'b01100
`define CIR_ST  5'b01010
`define SIR_ST  5'b00101
`define E1IR_ST 5'b00100
`define PIR_ST  5'b00010
`define E2IR_ST 5'b00110
`define UIR_ST  5'b01110
`define INIT_ST 5'b10000

// usr1 instruction for tap controller
`define JTAG_USR1_INSTR 10'b0000001110



//START_MODULE_NAME------------------------------------------------------------
// Module Name         : signal_gen
//
// Description         : Simulates customizable actions on a JTAG input
//
// Limitation          : Zero is not a valid length and causes simulation to halt with
// an error message.
// Values with more bits than specified length will be truncated.
// Length for IR scans are ignored. They however should be factored in when
// calculating SLD_NODE_TOTAl_LENGTH.                  
//
// Results expected    :
//
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module signal_gen (tck,tms,tdi,jtag_usr1,tdo);

    
    // GLOBAL PARAMETER DECLARATION
    parameter sld_node_ir_width = 1;
    parameter sld_node_n_scan = 0;
    parameter sld_node_total_length = 0;
    parameter sld_node_sim_action = "()";

    // INPUT PORTS
    input     jtag_usr1;
    input     tdo;
    
    // OUTPUT PORTS
    output    tck;
    output    tms;
    output    tdi;
    
    // CONSTANT DECLARATIONS
`define DECODED_SCANS_LENGTH (sld_node_total_length + ((sld_node_n_scan * `DEFAULT_BIT_LENGTH) * 2) + (sld_node_n_scan * `TYPE_BIT_LENGTH) - 1)
`define DEFAULT_SCAN_LENGTH (sld_node_n_scan * `DEFAULT_BIT_LENGTH)
`define TYPE_SCAN_LENGTH (sld_node_n_scan * `TYPE_BIT_LENGTH) - 1
    
    // INTEGER DECLARATION
    integer   char_idx;       // character_loop index
    integer   value_idx;      // decoding value index
    integer   value_idx_old;  // previous decoding value index   
    integer   value_idx_cur;  // reading/outputing value index   
    integer   length_idx;     // decoding length index
    integer   length_idx_old; // previous decoding length index
    integer   length_idx_cur; // reading/outputing length index
    integer   last_length_idx;// decoding previous length index
    integer   type_idx;       // decoding type index
    integer   type_idx_old;   // previous decoding type index
    integer   type_idx_cur;   // reading/outputing type index
    integer   time_idx;       // decoding time index
    integer   time_idx_old;   // previous decoding time index
    integer   time_idx_cur;   // reading/outputing time index

    // REGISTERS         
    reg [ `DEFAULT_SCAN_LENGTH - 1 : 0 ]    scan_length;
    // register for the 32-bit length values
    reg [ sld_node_total_length  - 1 : 0 ]  scan_values;
    // register for values   
    reg [ `TYPE_SCAN_LENGTH : 0 ]           scan_type;
    // register for 4-bit type 
    reg [ `DEFAULT_SCAN_LENGTH - 1 : 0 ]    scan_time;
    // register to hold time values
    reg [15 : 0]                            two_character; 
    // two ascii characters. Used in decoding
    reg [2 : 0]                             c_state;
    // the current state register 
    reg [3 : 0]                             hex_value;
    // temporary value to hold hex value of ascii character
    reg [31 : 0]                             last_length;
    // register to hold the previous length value read
    reg                                     tms_reg;
    // register to hold tms value before its clocked
    reg                                     tdi_reg;
    // register to hold tdi vale before its clocked
    
    // OUTPUT REGISTERS
    reg    tms;
    reg    tck;
    reg    tdi;

    // input registers
    
    // LOCAL TIME DECLARATION
    
    // FUNCTION DECLARATION
    
    // hexToBits - takes in a hexadecimal character and 
    // returns the 4-bit value of the character.
    // Returns 0 if character is not a hexadeciaml character    
    function [3 : 0]  hexToBits;
        input [7 : 0] character;
        begin
            case ( character )
                "0" : hexToBits = 4'b0000;
                "1" : hexToBits = 4'b0001;
                "2" : hexToBits = 4'b0010;
                "3" : hexToBits = 4'b0011;
                "4" : hexToBits = 4'b0100;
                "5" : hexToBits = 4'b0101;
                "6" : hexToBits = 4'b0110;                    
                "7" : hexToBits = 4'b0111;
                "8" : hexToBits = 4'b1000;
                "9" : hexToBits = 4'b1001;
                "A" : hexToBits = 4'b1010;
                "a" : hexToBits = 4'b1010;
                "B" : hexToBits = 4'b1011;
                "b" : hexToBits = 4'b1011;
                "C" : hexToBits = 4'b1100;
                "c" : hexToBits = 4'b1100;          
                "D" : hexToBits = 4'b1101;
                "d" : hexToBits = 4'b1101;
                "E" : hexToBits = 4'b1110;
                "e" : hexToBits = 4'b1110;
                "F" : hexToBits = 4'b1111;
                "f" : hexToBits = 4'b1111;          
                default :
                    begin 
                        hexToBits = 4'b0000;
                        $display("%s is not a hexadecimal value",character);
                    end
            endcase        
        end
    endfunction
    
    // TASK DECLARATIONS
    
    // clocks tck 
    task clock_tck;
        input in_tms;
        input in_tdi;    
        begin : clock_tck_tsk
            #(`CLK_PERIOD/2) tck <= ~tck;
            tms <= in_tms;
            tdi <= in_tdi;        
            #(`CLK_PERIOD/2) tck <= ~tck;
        end // clock_tck_tsk
    endtask // clock_tck
    
    // move tap controller from dr/ir shift state to ir/dr update state    
    task goto_update_state;
        begin : goto_update_state_tsk
            // get into e1(i/d)r state 
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into u(i/d)r state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);        
        end // goto_update_state_tsk
    endtask // goto_update_state
    
    // resets the jtag TAP controller by holding tms high 
    // for 6 tck cycles
    task reset_jtag;    
        integer idx;    
        begin
            for (idx = 0; idx < 6; idx= idx + 1)
                begin
                    tms_reg = 1'b1;          
                    clock_tck(tms_reg,tdi_reg);
                end
            // get into rti state
            tms_reg = 1'b0;        
            clock_tck(tms_reg,tdi_reg);
            jtag_ir_usr1;        
        end
    endtask // reset_jtag
    
    // sends a jtag_usr0 intsruction
    task jtag_ir_usr0;
        integer i;    
        begin : jtag_ir_usr0_tsk
            // get into drs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into irs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into cir state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // get into sir state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // shift in data i.e usr0 instruction
            // usr1 = 0x0E = 0b00 0000 1100
            for ( i = 0; i < 2; i = i + 1)
                begin :ir_usr0_loop1          
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_usr0_loop1
            for ( i = 0; i < 2; i = i + 1)
                begin :ir_usr0_loop2          
                    tdi_reg = 1'b1;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_usr0_loop2
            // done with 1100
            for ( i = 0; i < 6; i = i + 1)
                begin :ir_usr0_loop3
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_usr0_loop3
            // done  with 00 0000
            // get into e1ir state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);        
            // get into uir state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);        
        end // jtag_ir_usr0_tsk
    endtask // jtag_ir_usr0

    // sends a jtag_usr1 intsruction
    task jtag_ir_usr1;
        integer i;    
        begin : jtag_ir_usr1_tsk
            // get into drs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into irs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into cir state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // get into sir state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // shift in data i.e usr1 instruction
            // usr1 = 0x0E = 0b00 0000 1110
            tdi_reg = 1'b0;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            for ( i = 0; i < 3; i = i + 1)
                begin :ir_usr1_loop1          
                    tdi_reg = 1'b1;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_usr1_loop1
            // done with 1110
            for ( i = 0; i < 5; i = i + 1)
                begin :ir_usr1_loop2
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_sur1_loop2
            tdi_reg = 1'b0;
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // done  with 00 0000
            // now in e1ir state
            // get into uir state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
        end // jtag_ir_usr1_tsk
    endtask // jtag_ir_usr1
    
    // sends a force_ir_capture instruction to the node
    task send_force_ir_capture;
        integer i;    
        begin : send_force_ir_capture_tsk
            goto_dr_shift_state;
            // start shifting in the instruction
            tdi_reg = 1'b1;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            tdi_reg = 1'b1;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            tdi_reg = 1'b0;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // done with 011
            tdi_reg = 1'b0;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // done with select bit
            // fill up with zeros up to ir_width
            for ( i = 0; i < sld_node_ir_width - 4; i = i + 1 )
                begin
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end
            goto_update_state;        
        end // send_force_ir_capture_tsk    
    endtask // send_forse_ir_capture
    
    // puts the JTAG tap controller in DR shift state
    task goto_dr_shift_state;
        begin : goto_dr_shift_state_tsk
            // get into drs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into cdr state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // get into sdr state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);        
        end // goto_dr_shift_state_tsk    
    endtask // goto_dr_shift_state
    
    // performs a virtual_ir_scan
    task v_ir_scan;
        input [`DEFAULT_BIT_LENGTH - 1 : 0] length;    
        integer i;    
        begin : v_ir_scan_tsk
            // if we are not in usr1 then go to usr1 state
            if (jtag_usr1 == 1'b0)      
                begin
                    jtag_ir_usr1;
                end
            // send force_ir_capture
            send_force_ir_capture;
            // shift in the ir value
            goto_dr_shift_state;
            value_idx_cur = value_idx_cur - length;        
            for ( i = 0; i < length; i = i + 1)
                begin
                    tms_reg = 1'b0;
                    tdi_reg = scan_values[value_idx_cur + i];        
                    clock_tck(tms_reg,tdi_reg);
                end
            // pad with zeros if necessary
            for(i = length; i < sld_node_ir_width; i = i + 1)
                begin : zero_padding
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);          
                end //zero_padding
            tdi_reg = 1'b1;
            goto_update_state;
        end // v_ir_scan_tsk 
    endtask // v_ir_scan

    // performs a virtual dr scan
    task v_dr_scan;
        input [`DEFAULT_BIT_LENGTH - 1 : 0] length;    
        integer                             i;    
        begin : v_dr_scan_tsk
            // if we are in usr1 then go to usr0 state
            if (jtag_usr1 == 1'b1)      
                begin
                    jtag_ir_usr0;
                end
            // shift in the dr value
            goto_dr_shift_state;
            value_idx_cur = value_idx_cur - length;        
            for ( i = 0; i < length - 1; i = i + 1)
                begin
                    tms_reg = 1'b0;
                    tdi_reg = scan_values[value_idx_cur + i];
                    clock_tck(tms_reg,tdi_reg);
                end
            // last bit is clocked together with state transition
            tdi_reg = scan_values[value_idx_cur + i];        
            goto_update_state;
        end // v_dr_scan_tsk
    endtask // v_dr_scan
    
    initial 
        begin : sim_model      
            // initialize output registers
            tck = 1'b1;
            tms = 1'b0;
            tdi = 1'b0;      
            // initialize variables
            tms_reg = 1'b0;
            tdi_reg = 1'b0;      
            two_character = 'b0;
            last_length_idx = 0;      
            value_idx = 0;      
            value_idx_old = 0;      
            length_idx = 0;      
            length_idx_old = 0;
            type_idx = 0;
            type_idx_old = 0;
            time_idx = 0;
            time_idx_old = 0;      
            scan_length = 'b0;
            scan_values = 'b0;
            scan_type = 'b0;
            scan_time = 'b0;      
            last_length = 'b0;
            hex_value = 'b0;
            c_state = `STARTSTATE;      
            // initialize current indices
            value_idx_cur = sld_node_total_length;
            type_idx_cur = `TYPE_SCAN_LENGTH;
            time_idx_cur = `DEFAULT_SCAN_LENGTH;
            length_idx_cur = `DEFAULT_SCAN_LENGTH;      
            for(char_idx = 0;two_character != "((";char_idx = char_idx + 8)
                begin : character_loop
                    // convert two characters to equivalent 16-bit value
                    two_character[0]  = sld_node_sim_action[char_idx];
                    two_character[1]  = sld_node_sim_action[char_idx+1];
                    two_character[2]  = sld_node_sim_action[char_idx+2];
                    two_character[3]  = sld_node_sim_action[char_idx+3];
                    two_character[4]  = sld_node_sim_action[char_idx+4];
                    two_character[5]  = sld_node_sim_action[char_idx+5];
                    two_character[6]  = sld_node_sim_action[char_idx+6];
                    two_character[7]  = sld_node_sim_action[char_idx+7];
                    two_character[8]  = sld_node_sim_action[char_idx+8];
                    two_character[9]  = sld_node_sim_action[char_idx+9];
                    two_character[10] = sld_node_sim_action[char_idx+10];
                    two_character[11] = sld_node_sim_action[char_idx+11];
                    two_character[12] = sld_node_sim_action[char_idx+12];
                    two_character[13] = sld_node_sim_action[char_idx+13];
                    two_character[14] = sld_node_sim_action[char_idx+14];
                    two_character[15] = sld_node_sim_action[char_idx+15];        
                    // use state machine to decode
                    case (c_state)
                        `STARTSTATE :
                            begin 
                                if (two_character[15 : 8] != ")")
                                    begin 
                                        c_state = `LENGTHSTATE;
                                    end
                            end 
                        `LENGTHSTATE :
                            begin
                                if (two_character[7 : 0] == ",")
                                    begin
                                        length_idx = length_idx_old + 32;              
                                        length_idx_old = length_idx;              
                                        c_state = `VALUESTATE;
                                    end
                                else
                                    begin
                                        hex_value = hexToBits(two_character[7:0]);
                                        scan_length [ length_idx] = hex_value[0];
                                        scan_length [ length_idx + 1] = hex_value[1];
                                        scan_length [ length_idx + 2] = hex_value[2];
                                        scan_length [ length_idx + 3] = hex_value[3];              
                                        last_length [ last_length_idx] = hex_value[0];
                                        last_length [ last_length_idx + 1] = hex_value[1];
                                        last_length [ last_length_idx + 2] = hex_value[2];
                                        last_length [ last_length_idx + 3] = hex_value[3];              
                                        length_idx = length_idx + 4;
                                        last_length_idx = last_length_idx + 4;              
                                    end
                            end
                        `VALUESTATE :
                            begin
                                if (two_character[7 : 0] == ",")
                                    begin
                                        value_idx = value_idx_old + last_length;
                                        value_idx_old = value_idx;              
                                        last_length = 'b0; // reset the last length value
                                        last_length_idx = 0; // reset index for length                
                                        c_state = `TYPESTATE;  
                                    end
                                else
                                    begin
                                        hex_value = hexToBits(two_character[7:0]);
                                        scan_values [ value_idx] = hex_value[0];
                                        scan_values [ value_idx + 1] = hex_value[1];
                                        scan_values [ value_idx + 2] = hex_value[2];
                                        scan_values [ value_idx + 3] = hex_value[3];              
                                        value_idx = value_idx + 4;              
                                    end
                            end
                        `TYPESTATE :
                            begin
                                if (two_character[7 : 0] == ",")
                                    begin
                                        type_idx = type_idx + 4;              
                                        c_state = `TIMESTATE;              
                                    end
                                else
                                    begin
                                        hex_value = hexToBits(two_character[7:0]);
                                        scan_type [ type_idx] = hex_value[0];
                                        scan_type [ type_idx + 1] = hex_value[1];
                                        scan_type [ type_idx + 2] = hex_value[2];
                                        scan_type [ type_idx + 3] = hex_value[3];
                                    end
                            end
                        `TIMESTATE :
                            begin 
                                if (two_character[7 : 0] == "(")
                                    begin
                                        time_idx = time_idx_old + 32;
                                        time_idx_old = time_idx;              
                                        c_state = `STARTSTATE;
                                    end
                                else
                                    begin
                                        hex_value = hexToBits(two_character[7:0]);
                                        scan_time [ time_idx] = hex_value[0];
                                        scan_time [ time_idx + 1] = hex_value[1];
                                        scan_time [ time_idx + 2] = hex_value[2];
                                        scan_time [ time_idx + 3] = hex_value[3];
                                        time_idx = time_idx + 4;              
                                    end
                            end
                        default :
                            c_state = `STARTSTATE;          
                    endcase
                end // block: character_loop             
            # (`CLK_PERIOD/2);
            begin : execute
                integer write_scan_idx;    
                integer tempLength_idx;          
                reg [`TYPE_BIT_LENGTH - 1 : 0] tempType;        
                reg [`DEFAULT_BIT_LENGTH - 1 : 0 ] tempLength;                    
                reg [`DEFAULT_BIT_LENGTH - 1 : 0 ] tempTime;
                reg [`TIME_BIT_LENGTH - 1 : 0 ] delayTime;                    
                reset_jtag;
                for (write_scan_idx = 0; write_scan_idx < sld_node_n_scan; write_scan_idx = write_scan_idx + 1)
                    begin : all_scans_loop
                        tempType[3] = scan_type[type_idx_cur];
                        tempType[2] = scan_type[type_idx_cur - 1];
                        tempType[1] = scan_type[type_idx_cur - 2];
                        tempType[0] = scan_type[type_idx_cur - 3];
                        time_idx_cur = time_idx_cur - `DEFAULT_BIT_LENGTH;            
                        length_idx_cur = length_idx_cur - `DEFAULT_BIT_LENGTH;
                        for (tempLength_idx = 0; tempLength_idx < `DEFAULT_BIT_LENGTH; tempLength_idx = tempLength_idx + 1)
                            begin : get_scan_time
                                tempTime[tempLength_idx] = scan_time[time_idx_cur + tempLength_idx];                
                            end // get_scan_time
                            delayTime =(`DELAY_RESOLUTION * `CLK_PERIOD * tempTime);
                            # delayTime;            
                        if (tempType == `V_IR_SCAN_TYPE)
                            begin
                                for (tempLength_idx = 0; tempLength_idx < `DEFAULT_BIT_LENGTH; tempLength_idx = tempLength_idx + 1)
                                    begin : ir_get_length
                                        tempLength[tempLength_idx] = scan_length[length_idx_cur + tempLength_idx];                
                                    end // ir_get_length
                                v_ir_scan(tempLength);
                            end 
                        else
                            begin
                                if (tempType == `V_DR_SCAN_TYPE)
                                    begin                
                                        for (tempLength_idx = 0; tempLength_idx < `DEFAULT_BIT_LENGTH; tempLength_idx = tempLength_idx + 1)
                                            begin : dr_get_length
                                                tempLength[tempLength_idx] = scan_length[length_idx_cur + tempLength_idx];                
                                            end // dr_get_length
                                        v_dr_scan(tempLength);
                                    end
                                else
                                    begin
                                        $display("Invalid scan type");
                                    end
                            end
                        type_idx_cur = type_idx_cur - 4;
                    end // all_scans_loop            
                //get into tlr state
                for (tempLength_idx = 0; tempLength_idx < 6; tempLength_idx= tempLength_idx + 1)
                    begin
                        tms_reg = 1'b1;          
                        clock_tck(tms_reg,tdi_reg);
                    end
            end //execute      
        end // block: sim_model     
endmodule // signal_gen

// END OF MODULE



//START_MODULE_NAME------------------------------------------------------------
// Module Name         : jtag_tap_controller
//
// Description         : Behavioral model of JTAG tap controller with state signals
//
// Limitation          :  Can only decode USER1 and USER0 instructions
//
// Results expected    :
//
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module jtag_tap_controller (tck,tms,tdi,jtag_tdo,tdo,jtag_tck,jtag_tms,jtag_tdi,
                            jtag_state_tlr,jtag_state_rti,jtag_state_drs,jtag_state_cdr,
                            jtag_state_sdr,jtag_state_e1dr,jtag_state_pdr,jtag_state_e2dr,
                            jtag_state_udr,jtag_state_irs,jtag_state_cir,jtag_state_sir,
                            jtag_state_e1ir,jtag_state_pir,jtag_state_e2ir,jtag_state_uir,
                            jtag_usr1);


    // GLOBAL PARAMETER DECLARATION
    parameter ir_register_width = 16;

    // INPUT PORTS
    input     tck;  // tck signal from signal_gen
    input     tms;  // tms signal from signal_gen
    input     tdi;  // tdi signal from signal_gen
    input     jtag_tdo; // tdo signal from hub

    // OUTPUT PORTS
    output    tdo;  // tdo signal to signal_gen
    output    jtag_tck;  // tck signal from jtag
    output    jtag_tms;  // tms signal from jtag
    output    jtag_tdi;  // tdi signal from jtag
    output    jtag_state_tlr;   // tlr state
    output    jtag_state_rti;   // rti state
    output    jtag_state_drs;   // select dr scan state    
    output    jtag_state_cdr;   // capture dr state
    output    jtag_state_sdr;   // shift dr state    
    output    jtag_state_e1dr;  // exit1 dr state
    output    jtag_state_pdr;   // pause dr state
    output    jtag_state_e2dr;  // exit2 dr state 
    output    jtag_state_udr;   // update dr state
    output    jtag_state_irs;   // select ir scan state
    output    jtag_state_cir;   // capture ir state
    output    jtag_state_sir;   // shift ir state
    output    jtag_state_e1ir;  // exit1 ir state
    output    jtag_state_pir;   // pause ir state
    output    jtag_state_e2ir;  // exit2 ir state    
    output    jtag_state_uir;   // update ir state
    output    jtag_usr1;        // jtag has usr1 instruction

    // INTERNAL REGISTERS

    reg       tdo_reg;
    // temporary tdo output register
    reg       tdo_rom_reg;
    // temporary register used to generate 0101... during SIR_ST
    reg       jtag_usr1_reg;
    // temporary jtag_usr1 register
    reg       jtag_reset_i;
    // internal reset
    reg [ 4 : 0 ] cState;
    // register for current state
    reg [ 4 : 0 ] nState;
    // register for the next state signal
    reg [ ir_register_width - 1 : 0] ir_srl;
    // the ir shift register
    reg [ ir_register_width - 1 : 0] ir_srl_hold;
    // the ir shift register
    
    // INTERNAL WIRES
    wire [ 4 : 0 ] cState_tmp;
    wire [ ir_register_width - 1 : 0] ir_srl_tmp;


    // OUTPUT REGISTERS
    reg   jtag_state_tlr;   // tlr state
    reg   jtag_state_rti;   // rti state
    reg   jtag_state_drs;   // select dr scan state    
    reg   jtag_state_cdr;   // capture dr state
    reg   jtag_state_sdr;   // shift dr state    
    reg   jtag_state_e1dr;  // exit1 dr state
    reg   jtag_state_pdr;   // pause dr state
    reg   jtag_state_e2dr;  // exit2 dr state 
    reg   jtag_state_udr;   // update dr state
    reg   jtag_state_irs;   // select ir scan state
    reg   jtag_state_cir;   // capture ir state
    reg   jtag_state_sir;   // shift ir state
    reg   jtag_state_e1ir;  // exit1 ir state
    reg   jtag_state_pir;   // pause ir state
    reg   jtag_state_e2ir;  // exit2 ir state    
    reg   jtag_state_uir;   // update ir state
    

    // INITIAL STATEMENTS    
    initial
        begin
            // initialize state registers
            cState = `INIT_ST;
            nState = `TLR_ST;      
        end 

    // State Register block
    always @ (posedge tck or posedge jtag_reset_i)
        begin : stateReg
            if (jtag_reset_i)
                begin
                    cState <= `TLR_ST;
                    ir_srl <= 'b0;
                    tdo_reg <= 1'b0;
                    tdo_rom_reg <= 1'b0;
                    jtag_usr1_reg <= 1'b0;        
                end
            else
                begin
                    // in capture ir, set-up tdo_rom_reg
                    // to generate 010101...
                    if(cState_tmp == `CIR_ST)
                        begin                    
                            tdo_rom_reg <= 1'b0;
                        end
                    else
                        begin
                            // write to shift register else pipe
                            if (cState_tmp == `SIR_ST)
                                begin
                                    tdo_rom_reg <= ~tdo_rom_reg;
                                    tdo_reg <= tdo_rom_reg;              
                                    ir_srl <= ir_srl_tmp >> 1;
                                    ir_srl[ir_register_width - 1] <= tdi;
                                end
                            else
                                begin
                                    tdo_reg <= jtag_tdo;
                                end
                        end
                    // check if in usr1 state
                    if (cState_tmp == `UIR_ST)
                        begin
                            if (ir_srl_hold == `JTAG_USR1_INSTR)
                                begin
                                    jtag_usr1_reg <= 1'b1;                
                                end
                            else
                                begin
                                    jtag_usr1_reg <= 1'b0;
                                end              
                        end
                    cState <= nState;
                end
        end // stateReg               

    // hold register
    always @ (negedge tck or posedge jtag_reset_i)
        begin : holdReg
            if (jtag_reset_i)
                begin
                    ir_srl_hold <= 'b0;        
                end
            else
                begin
                    if (cState == `E1IR_ST)
                        begin
                            ir_srl_hold <= ir_srl;
                        end
                end
        end // holdReg               

    // next state logic
    always @(cState or tms)
        begin : stateTrans
            nState = cState;
            case (cState)
                `TLR_ST :
                    begin
                        if (tms == 1'b0)
                            begin
                                nState = `RTI_ST;
                                jtag_reset_i = 1'b0;
                            end
                        else
                            begin
                                jtag_reset_i = 1'b1;            
                            end
                    end
                `RTI_ST :
                    begin
                        if (tms)
                            begin
                                nState = `DRS_ST;
                            end          
                    end
                `DRS_ST :
                    begin
                        if (tms)
                            begin
                                nState = `IRS_ST;
                            end
                        else
                            begin
                                nState = `CDR_ST;
                            end
                    end
                `CDR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E1DR_ST;
                            end
                        else
                            begin
                                nState = `SDR_ST;
                            end
                    end
                `SDR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E1DR_ST;
                            end
                    end
                `E1DR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `UDR_ST;
                            end
                        else
                            begin
                                nState = `PDR_ST;
                            end
                    end
                `PDR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E2DR_ST;
                            end
                    end
                `E2DR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `UDR_ST;
                            end
                        else
                            begin
                                nState = `SDR_ST;
                            end
                    end
                `UDR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `DRS_ST;
                            end
                        else
                            begin
                                nState = `RTI_ST;
                            end
                    end          
                `IRS_ST :
                    begin
                        if (tms)
                            begin
                                nState = `TLR_ST;
                            end
                        else
                            begin
                                nState = `CIR_ST;
                            end
                    end
                `CIR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E1IR_ST;
                            end
                        else
                            begin
                                nState = `SIR_ST;
                            end
                    end
                `SIR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E1IR_ST;
                            end
                    end
                `E1IR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `UIR_ST;
                            end
                        else
                            begin
                                nState = `PIR_ST;
                            end
                    end
                `PIR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E2IR_ST;
                            end
                    end
                `E2IR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `UIR_ST;
                            end
                        else
                            begin
                                nState = `SIR_ST;
                            end
                    end
                `UIR_ST : 
                    begin
                        if (tms)
                            begin
                                nState = `DRS_ST;
                            end
                        else
                            begin
                                nState = `RTI_ST;
                            end
                    end
                `INIT_ST :
                    begin
                        nState = `TLR_ST;
                    end
                default :
                    begin
                        $display("Tap Controller State machine error");
                        $display ("Time: %0t  Instance: %m", $time);
                        nState = `TLR_ST;          
                    end
            endcase
        end // stateTrans

    // Output logic
    always @ (cState)
        begin : output_logic
            jtag_state_tlr <= 1'b0;  
            jtag_state_rti <= 1'b0;  
            jtag_state_drs <= 1'b0;  
            jtag_state_cdr <= 1'b0;  
            jtag_state_sdr <= 1'b0;  
            jtag_state_e1dr <= 1'b0; 
            jtag_state_pdr <= 1'b0;  
            jtag_state_e2dr <= 1'b0; 
            jtag_state_udr <= 1'b0;  
            jtag_state_irs <= 1'b0;  
            jtag_state_cir <= 1'b0;  
            jtag_state_sir <= 1'b0;  
            jtag_state_e1ir <= 1'b0; 
            jtag_state_pir <= 1'b0;  
            jtag_state_e2ir <= 1'b0; 
            jtag_state_uir <= 1'b0;  
            case (cState)
                `TLR_ST :
                    begin
                        jtag_state_tlr <= 1'b1;
                    end
                `RTI_ST :
                    begin
                        jtag_state_rti <= 1'b1;
                    end
                `DRS_ST :
                    begin
                        jtag_state_drs <= 1'b1;
                    end
                `CDR_ST :
                    begin
                        jtag_state_cdr <= 1'b1;
                    end
                `SDR_ST :
                    begin
                        jtag_state_sdr <= 1'b1;
                    end
                `E1DR_ST :
                    begin
                        jtag_state_e1dr <= 1'b1;
                    end
                `PDR_ST :
                    begin
                        jtag_state_pdr <= 1'b1;
                    end
                `E2DR_ST :
                    begin
                        jtag_state_e2dr <= 1'b1;
                    end
                `UDR_ST :
                    begin
                        jtag_state_udr <= 1'b1;
                    end
                `IRS_ST :
                    begin
                        jtag_state_irs <= 1'b1;
                    end
                `CIR_ST :
                    begin
                        jtag_state_cir <= 1'b1;
                    end
                `SIR_ST :
                    begin
                        jtag_state_sir <= 1'b1;
                    end
                `E1IR_ST :
                    begin
                        jtag_state_e1ir <= 1'b1;
                    end
                `PIR_ST :
                    begin
                        jtag_state_pir <= 1'b1;
                    end
                `E2IR_ST :
                    begin
                        jtag_state_e2ir <= 1'b1;
                    end
                `UIR_ST :
                    begin
                        jtag_state_uir <= 1'b1;
                    end
                default :
                    begin
                        $display("Tap Controller State machine output error");
                        $display ("Time: %0t  Instance: %m", $time);
                    end
            endcase
        end // output_logic
    // temporary values
    assign ir_srl_tmp = ir_srl;
    assign cState_tmp = cState;    

    // Pipe through signals
    assign tdo = tdo_reg;
    assign jtag_tck = tck;
    assign jtag_tdi = tdi;
    assign jtag_tms = tms;
    assign jtag_usr1 = jtag_usr1_reg;
    
endmodule
// END OF MODULE


    
//START_MODULE_NAME------------------------------------------------------------
// Module Name         : dummy_hub
//
// Description         : Acts as node and mux between the tap controller and
// user design. Generates hub signals
//
// Limitation          : Assumes only one node. Ignores user input on tdo and ir_out.
//
// Results expected    :
//
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION

module dummy_hub (jtag_tck,jtag_tdi,jtag_tms,jtag_usr1,jtag_state_tlr,jtag_state_rti,
                    jtag_state_drs,jtag_state_cdr,jtag_state_sdr,jtag_state_e1dr,
                    jtag_state_pdr,jtag_state_e2dr,jtag_state_udr,jtag_state_irs,
                    jtag_state_cir,jtag_state_sir,jtag_state_e1ir,jtag_state_pir,
                    jtag_state_e2ir,jtag_state_uir,dummy_tdo,virtual_ir_out,
                    jtag_tdo,dummy_tck,dummy_tdi,dummy_tms,dummy_state_tlr,
                    dummy_state_rti,dummy_state_drs,dummy_state_cdr,dummy_state_sdr,
                    dummy_state_e1dr,dummy_state_pdr,dummy_state_e2dr,dummy_state_udr,
                    dummy_state_irs,dummy_state_cir,dummy_state_sir,dummy_state_e1ir,
                    dummy_state_pir,dummy_state_e2ir,dummy_state_uir,virtual_state_cdr,
                    virtual_state_sdr,virtual_state_e1dr,virtual_state_pdr,virtual_state_e2dr,
                    virtual_state_udr,virtual_state_cir,virtual_state_uir,virtual_ir_in);


    // GLOBAL PARAMETER DECLARATION
    parameter sld_node_ir_width = 16;

    // INPUT PORTS
    
    input   jtag_tck;       // tck signal from tap controller
    input   jtag_tdi;       // tdi signal from tap controller
    input   jtag_tms;       // tms signal from tap controller
    input   jtag_usr1;      // usr1 signal from tap controller
    input   jtag_state_tlr; // tlr state signal from tap controller
    input   jtag_state_rti; // rti state signal from tap controller
    input   jtag_state_drs; // drs state signal from tap controller
    input   jtag_state_cdr; // cdr state signal from tap controller
    input   jtag_state_sdr; // sdr state signal from tap controller
    input   jtag_state_e1dr;// e1dr state signal from tap controller
    input   jtag_state_pdr; // pdr state signal from tap controller
    input   jtag_state_e2dr;// esdr state signal from tap controller
    input   jtag_state_udr; // udr state signal from tap controller
    input   jtag_state_irs; // irs state signal from tap controller
    input   jtag_state_cir; // cir state signals from tap controller
    input   jtag_state_sir; // sir state signal from tap controller
    input   jtag_state_e1ir;// e1ir state signal from tap controller
    input   jtag_state_pir; // pir state signals from tap controller
    input   jtag_state_e2ir;// e2ir state signal from tap controller
    input   jtag_state_uir; // uir state signal from tap controller
    input   dummy_tdo;      // tdo signal from world
    input [sld_node_ir_width - 1 : 0] virtual_ir_out; // captures parallel input from

    // OUTPUT PORTS
    output   jtag_tdo;             // tdo signal to tap controller
    output   dummy_tck;           // tck signal to world
    output   dummy_tdi;           // tdi signal to world
    output   dummy_tms;           // tms signal to world
    output   dummy_state_tlr;     // tlr state signal to world
    output   dummy_state_rti;     // rti state signal to world
    output   dummy_state_drs;     // drs state signal to world
    output   dummy_state_cdr;     // cdr state signal to world
    output   dummy_state_sdr;     // sdr state signal to world
    output   dummy_state_e1dr;    // e1dr state signal to the world
    output   dummy_state_pdr;     // pdr state signal to world
    output   dummy_state_e2dr;    // e2dr state signal to world
    output   dummy_state_udr;     // udr state signal to world
    output   dummy_state_irs;     // irs state signal to world
    output   dummy_state_cir;    // cir state signal to world
    output   dummy_state_sir;    // sir state signal to world
    output   dummy_state_e1ir;   // e1ir state signal to world
    output   dummy_state_pir;    // pir state signal to world
    output   dummy_state_e2ir;   // e2ir state signal to world
    output   dummy_state_uir;    // uir state signal to world
    output   virtual_state_cdr;  // virtual cdr state signal
    output   virtual_state_sdr;  // virtual sdr state signal
    output   virtual_state_e1dr; // virtual e1dr state signal 
    output   virtual_state_pdr;  // virtula pdr state signal 
    output   virtual_state_e2dr; // virtual e2dr state signal 
    output   virtual_state_udr;  // virtual udr state signal
    output   virtual_state_cir;  // virtual cir state signal 
    output   virtual_state_uir;  // virtual uir state signal
    output [sld_node_ir_width - 1 : 0] virtual_ir_in;      // parallel output to user design


`define SLD_NODE_IR_WIDTH_I sld_node_ir_width + `NUM_SELECTION_BITS // internal ir width    
   
    // INTERNAL REGISTERS
    reg   capture_ir;    // signals force_ir_capture instruction
    reg   jtag_tdo_reg;  // register for jtag_tdo
    reg   dummy_tdi_reg; // register for dummy_tdi
    reg   dummy_tck_reg; // register for dummy_tck.
    reg  [`SLD_NODE_IR_WIDTH_I - 1 : 0] ir_srl; // ir shift register
    wire [`SLD_NODE_IR_WIDTH_I - 1 : 0] ir_srl_tmp; // ir shift register
    reg  [`SLD_NODE_IR_WIDTH_I - 1 : 0] ir_srl_hold; //hold register for ir shift register  

    // OUTPUT REGISTERS
    reg [sld_node_ir_width - 1 : 0]     virtual_ir_in;     
    
    // INITIAL STATEMENTS 
    always @ (posedge jtag_tck or posedge jtag_state_tlr)
        begin : simulation_logic
            if (jtag_state_tlr) // asynchronous active high reset
                begin : active_hi_async_reset
                    ir_srl <= 'b0;
                    jtag_tdo_reg <= 1'b0;
                    dummy_tdi_reg <= 1'b0;        
                end  // active_hi_async_reset
            else
                begin : rising_edge_jtag_tck
                    // logic for shifting in data and piping data through        
                    // logic for muxing inputs to outputs and otherwise
                    if (jtag_usr1 && jtag_state_sdr)
                        begin : shift_in_out_usr1              
                            jtag_tdo_reg <= ir_srl_tmp[0];
                            ir_srl <= ir_srl_tmp >> 1;
                            ir_srl[`SLD_NODE_IR_WIDTH_I - 1] <= jtag_tdi;
                        end // shift_in_out_usr1
                    else
                        begin
                            if (capture_ir && jtag_state_cdr)
                                begin : capture_virtual_ir_out
                                    ir_srl[`SLD_NODE_IR_WIDTH_I - 2 : `NUM_SELECTION_BITS - 1] <= virtual_ir_out;
                                end // capture_virtual_ir_out
                            else
                                begin
                                    if (capture_ir && jtag_state_sdr)
                                        begin : shift_in_out_usr0                
                                            jtag_tdo_reg <= ir_srl_tmp[0];
                                            ir_srl <= ir_srl_tmp >> 1;
                                            ir_srl[`SLD_NODE_IR_WIDTH_I - 1] <= jtag_tdi;
                                        end // shift_in_out_usr0
                                    else
                                        begin
                                            if (jtag_state_sdr)
                                                begin : pipe_through
                                                    dummy_tdi_reg <= jtag_tdi;
                                                    jtag_tdo_reg <= dummy_tdo;
                                                end // pipe_through
                                        end
                                end
                        end                          
                end // rising_edge_jtag_tck
        end // simulation_logic

    // always block for writing to capture_ir
    // stops nlint from complaining.
    always @ (posedge jtag_tck or posedge jtag_state_tlr)
        begin : capture_ir_logic
            if (jtag_state_tlr) // asynchronous active high reset
                begin : active_hi_async_reset
                    capture_ir <= 1'b0;
                end  // active_hi_async_reset
            else
                begin : rising_edge_jtag_tck
                    // should check for 011 instruction
                    // but we know that it is the only instruction ever sent to the
                    // hub. So all we have to do is check the selection bit and udr
                    // and usr1 state
                    // logic for capture_ir signal
                    if (jtag_state_udr && (ir_srl[`SLD_NODE_IR_WIDTH_I - 1] == 1'b0))
                        begin
                            capture_ir <= jtag_usr1;
                        end
                    else
                        begin
                            if (jtag_state_e1dr)
                                begin
                                    capture_ir <= 1'b0;
                                end
                        end
                end  // rising_edge_jtag_tck
        end // capture_ir_logic
    
    // outputs -  rising edge of clock  
    always @ (posedge jtag_tck or posedge jtag_state_tlr)
        begin : parallel_ir_out
            if (jtag_state_tlr)
                begin : active_hi_async_reset
                    virtual_ir_in <= 'b0;
                end
            else
                begin : rising_edge_jtag_tck
                    virtual_ir_in <= ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 2 : `NUM_SELECTION_BITS - 1];
                end
        end
    
    // outputs -  falling edge of clock, separated for clarity
    always @ (negedge jtag_tck or posedge jtag_state_tlr)
        begin : shift_reg_hold
            if (jtag_state_tlr)
                begin : active_hi_async_reset
                    ir_srl_hold <= 'b0;
                end
            else
                begin
                    if (ir_srl[`SLD_NODE_IR_WIDTH_I - 1] && jtag_state_e1dr)
                        begin
                            ir_srl_hold <= ir_srl;
                        end
                end
        end // shift_reg_hold

    // generate tck in sync with tdi
    always @ (posedge jtag_tck or negedge jtag_tck)
        begin : gen_tck
            dummy_tck_reg <= jtag_tck;
        end // gen_tck
    // temporary signals    
    assign ir_srl_tmp = ir_srl;
    
    // Pipe through signals
    assign dummy_state_tlr    = jtag_state_tlr;
    assign dummy_state_rti    = jtag_state_rti;
    assign dummy_state_drs    = jtag_state_drs;
    assign dummy_state_cdr    = jtag_state_cdr;
    assign dummy_state_sdr    = jtag_state_sdr;
    assign dummy_state_e1dr   = jtag_state_e1dr;
    assign dummy_state_pdr    = jtag_state_pdr;
    assign dummy_state_e2dr   = jtag_state_e2dr;
    assign dummy_state_udr    = jtag_state_udr;
    assign dummy_state_irs    = jtag_state_irs;
    assign dummy_state_cir    = jtag_state_cir;
    assign dummy_state_sir    = jtag_state_sir;
    assign dummy_state_e1ir   = jtag_state_e1ir;
    assign dummy_state_pir    = jtag_state_pir;
    assign dummy_state_e2ir   = jtag_state_e2ir;
    assign dummy_state_uir    = jtag_state_uir;
    assign dummy_tms          = jtag_tms;


    // Virtual signals
    assign virtual_state_uir  = jtag_usr1 && jtag_state_udr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_cir  = jtag_usr1 && jtag_state_cdr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_udr  = (! jtag_usr1) && jtag_state_udr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_e2dr = (! jtag_usr1) && jtag_state_e2dr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_pdr  = (! jtag_usr1) && jtag_state_pdr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_e1dr = (! jtag_usr1) && jtag_state_e1dr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_sdr  = (! jtag_usr1) && jtag_state_sdr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_cdr  = (! jtag_usr1) && jtag_state_cdr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];

    // registered output
    assign jtag_tdo = jtag_tdo_reg;              
    assign dummy_tdi = dummy_tdi_reg;    
    assign dummy_tck = dummy_tck_reg;
    
endmodule
// END OF MODULE


//START_MODULE_NAME------------------------------------------------------------
// Module Name         : sld_virtual_jtag
//
// Description         : Simulation model for SLD_VIRTUAL_JTAG megafunction
//
// Limitation          : None
//
// Results expected    :
//
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps
`define IR_REGISTER_WIDTH 10;


// MODULE DECLARATION
module sld_virtual_jtag (tdo,ir_out,tck,tdi,ir_in,virtual_state_cdr,virtual_state_sdr,
                        virtual_state_e1dr,virtual_state_pdr,virtual_state_e2dr,
                        virtual_state_udr,virtual_state_cir,virtual_state_uir,
                        jtag_state_tlr,jtag_state_rti,jtag_state_sdrs,jtag_state_cdr,
                        jtag_state_sdr,jtag_state_e1dr,jtag_state_pdr,jtag_state_e2dr,
                        jtag_state_udr,jtag_state_sirs,jtag_state_cir,jtag_state_sir,
                        jtag_state_e1ir,jtag_state_pir,jtag_state_e2ir,jtag_state_uir,
                        tms);


    // GLOBAL PARAMETER DECLARATION    
    parameter lpm_type = "SLD_VIRTUAL_JTAG"; // required by coding standard
    parameter lpm_hint = "SLD_VIRTUAL_JTAG"; // required by coding standard
    parameter sld_auto_instance_index = "NO"; //Yes if auto index is desired and no otherwise
    parameter sld_instance_index = 0; // index to be used if SLD_AUTO_INDEX is no
    parameter sld_ir_width = 1; //the width of the IR register
    parameter sld_sim_n_scan = 0; // the number of scans in the simulatiom parameters
    parameter sld_sim_total_length = 0; // The total bit width of all scan values
    parameter sld_sim_action = ""; // the actions to be simulated

    // local parameter declaration
    defparam  user_input.sld_node_ir_width = sld_ir_width;
    defparam  user_input.sld_node_n_scan = sld_sim_n_scan;
    defparam  user_input.sld_node_total_length = sld_sim_total_length;
    defparam  user_input.sld_node_sim_action = sld_sim_action;
    defparam  jtag.ir_register_width = 10 ;  // compilation fails if defined constant is used
    defparam  hub.sld_node_ir_width = sld_ir_width;
    
    
    // INPUT PORTS DECLARATION
    input   tdo;  // tdo signal into megafunction
    input [sld_ir_width - 1 : 0] ir_out;// parallel ir data into megafunction

    // OUTPUT PORTS DECLARATION
    output   tck;  // tck signal from megafunction
    output   tdi;  // tdi signal from megafunction
    output   virtual_state_cdr; // cdr state signal of megafunction
    output   virtual_state_sdr; // sdr state signal of megafunction
    output   virtual_state_e1dr;//  e1dr state signal of megafunction
    output   virtual_state_pdr; // pdr state signal of megafunction
    output   virtual_state_e2dr;// e2dr state signal of megafunction
    output   virtual_state_udr; // udr state signal of megafunction
    output   virtual_state_cir; // cir state signal of megafunction
    output   virtual_state_uir; // uir state signal of megafunction
    output   jtag_state_tlr;    // Test, Logic, Reset state
    output   jtag_state_rti;    // Run, Test, Idle state 
    output   jtag_state_sdrs;   // Select DR scan state
    output   jtag_state_cdr;    // capture DR state
    output   jtag_state_sdr;    // Shift DR state 
    output   jtag_state_e1dr;   // exit 1 dr state
    output   jtag_state_pdr;    // pause dr state 
    output   jtag_state_e2dr;   // exit 2 dr state
    output   jtag_state_udr;    // update dr state 
    output   jtag_state_sirs;   // Select IR scan state
    output   jtag_state_cir;    // capture IR state
    output   jtag_state_sir;    // shift IR state 
    output   jtag_state_e1ir;   // exit 1 IR state
    output   jtag_state_pir;    // pause IR state
    output   jtag_state_e2ir;   // exit 2 IR state 
    output   jtag_state_uir;    // update IR state
    output   tms;               // tms signal
    output [sld_ir_width - 1 : 0] ir_in; // paraller ir data from megafunction    

    // connecting wires
    wire   tck_i;
    wire   tms_i;
    wire   tdi_i;
    wire   jtag_usr1_i;
    wire   tdo_i;
    wire   jtag_tdo_i;
    wire   jtag_tck_i;
    wire   jtag_tms_i;
    wire   jtag_tdi_i;
    wire   jtag_state_tlr_i;
    wire   jtag_state_rti_i;
    wire   jtag_state_drs_i;
    wire   jtag_state_cdr_i;
    wire   jtag_state_sdr_i;
    wire   jtag_state_e1dr_i;
    wire   jtag_state_pdr_i;
    wire   jtag_state_e2dr_i;
    wire   jtag_state_udr_i;
    wire   jtag_state_irs_i;
    wire   jtag_state_cir_i;
    wire   jtag_state_sir_i;
    wire   jtag_state_e1ir_i;
    wire   jtag_state_pir_i;
    wire   jtag_state_e2ir_i;
    wire   jtag_state_uir_i;
    
    
    // COMPONENT INSTANTIATIONS 
    // generates input to jtag controller
    signal_gen user_input (tck_i,tms_i,tdi_i,jtag_usr1_i,tdo_i);

    // the JTAG TAP controller
    jtag_tap_controller jtag (tck_i,tms_i,tdi_i,jtag_tdo_i,
                                tdo_i,jtag_tck_i,jtag_tms_i,jtag_tdi_i,
                                jtag_state_tlr_i,jtag_state_rti_i,
                                jtag_state_drs_i,jtag_state_cdr_i,
                                jtag_state_sdr_i,jtag_state_e1dr_i,
                                jtag_state_pdr_i,jtag_state_e2dr_i,
                                jtag_state_udr_i,jtag_state_irs_i,
                                jtag_state_cir_i,jtag_state_sir_i,
                                jtag_state_e1ir_i,jtag_state_pir_i,
                                jtag_state_e2ir_i,jtag_state_uir_i,
                                jtag_usr1_i);

    // the HUB 
    dummy_hub hub (jtag_tck_i,jtag_tdi_i,jtag_tms_i,jtag_usr1_i,
                    jtag_state_tlr_i,jtag_state_rti_i,jtag_state_drs_i,
                    jtag_state_cdr_i,jtag_state_sdr_i,jtag_state_e1dr_i,
                    jtag_state_pdr_i,jtag_state_e2dr_i,jtag_state_udr_i,
                    jtag_state_irs_i,jtag_state_cir_i,jtag_state_sir_i,
                    jtag_state_e1ir_i,jtag_state_pir_i,jtag_state_e2ir_i,
                    jtag_state_uir_i,tdo,ir_out,jtag_tdo_i,tck,tdi,tms,
                    jtag_state_tlr,jtag_state_rti,jtag_state_sdrs,jtag_state_cdr,
                    jtag_state_sdr,jtag_state_e1dr,jtag_state_pdr,jtag_state_e2dr,
                    jtag_state_udr,jtag_state_sirs,jtag_state_cir,jtag_state_sir,
                    jtag_state_e1ir,jtag_state_pir,jtag_state_e2ir,jtag_state_uir,
                    virtual_state_cdr,virtual_state_sdr,virtual_state_e1dr,
                    virtual_state_pdr,virtual_state_e2dr,virtual_state_udr,
                    virtual_state_cir,virtual_state_uir,ir_in);

endmodule
// END OF MODULE

module    sld_signaltap    (
    jtag_state_sdr,
    ir_out,
    jtag_state_cdr,
    ir_in,
    tdi,
    acq_trigger_out,
    jtag_state_uir,
    acq_trigger_in,
    trigger_out,
    storage_enable,
    acq_data_out,
    acq_data_in,
    acq_storage_qualifier_in,
    jtag_state_udr,
    tdo,
    crc,
    jtag_state_e1dr,
    raw_tck,
    usr1,
    acq_clk,
    shift,
    ena,
    clr,
    trigger_in,
    update,
    rti);

    parameter    SLD_CURRENT_RESOURCE_WIDTH    =    0;
    parameter    SLD_INVERSION_MASK    =    "0";
    parameter    SLD_POWER_UP_TRIGGER    =    0;
    parameter    SLD_ADVANCED_TRIGGER_6    =    "NONE";
    parameter    SLD_ADVANCED_TRIGGER_9    =    "NONE";
    parameter    SLD_ADVANCED_TRIGGER_7    =    "NONE";
    parameter    SLD_STORAGE_QUALIFIER_ADVANCED_CONDITION_ENTITY    =    "basic";
    parameter    SLD_STORAGE_QUALIFIER_GAP_RECORD    =    0;
    parameter    SLD_INCREMENTAL_ROUTING    =    0;
    parameter    SLD_STORAGE_QUALIFIER_PIPELINE    =    0;
    parameter    SLD_TRIGGER_IN_ENABLED    =    0;
    parameter    SLD_STATE_BITS    =    11;
    parameter    SLD_STATE_FLOW_USE_GENERATED    =    0;
    parameter    SLD_INVERSION_MASK_LENGTH    =    1;
    parameter    SLD_DATA_BITS    =    1;
    parameter    SLD_BUFFER_FULL_STOP    =    1;
    parameter    SLD_STORAGE_QUALIFIER_INVERSION_MASK_LENGTH    =    0;
    parameter    SLD_ATTRIBUTE_MEM_MODE    =    "OFF";
    parameter    SLD_STORAGE_QUALIFIER_MODE    =    "OFF";
    parameter    SLD_STATE_FLOW_MGR_ENTITY    =    "state_flow_mgr_entity.vhd";
    parameter    SLD_NODE_CRC_LOWORD    =    50132;
    parameter    SLD_ADVANCED_TRIGGER_5    =    "NONE";
    parameter    SLD_TRIGGER_BITS    =    1;
    parameter    SLD_STORAGE_QUALIFIER_BITS    =    1;
    parameter    SLD_ADVANCED_TRIGGER_10    =    "NONE";
    parameter    SLD_MEM_ADDRESS_BITS    =    7;
    parameter    SLD_ADVANCED_TRIGGER_ENTITY    =    "basic";
    parameter    SLD_ADVANCED_TRIGGER_4    =    "NONE";
    parameter    SLD_TRIGGER_LEVEL    =    10;
    parameter    SLD_ADVANCED_TRIGGER_8    =    "NONE";
    parameter    SLD_RAM_BLOCK_TYPE    =    "AUTO";
    parameter    SLD_ADVANCED_TRIGGER_2    =    "NONE";
    parameter    SLD_ADVANCED_TRIGGER_1    =    "NONE";
    parameter    SLD_DATA_BIT_CNTR_BITS    =    4;
    parameter    lpm_type    =    "sld_signaltap";
    parameter    SLD_NODE_CRC_BITS    =    32;
    parameter    SLD_SAMPLE_DEPTH    =    16;
    parameter    SLD_ENABLE_ADVANCED_TRIGGER    =    0;
    parameter    SLD_SEGMENT_SIZE    =    0;
    parameter    SLD_NODE_INFO    =    0;
    parameter    SLD_STORAGE_QUALIFIER_ENABLE_ADVANCED_CONDITION    =    0;
    parameter    SLD_NODE_CRC_HIWORD    =    41394;
    parameter    SLD_TRIGGER_LEVEL_PIPELINE    =    1;
    parameter    SLD_ADVANCED_TRIGGER_3    =    "NONE";

    parameter    ELA_STATUS_BITS    =    4;
    parameter    N_ELA_INSTRS    =    8;
    parameter    SLD_IR_BITS    =    N_ELA_INSTRS;

    input    jtag_state_sdr;
    output    [SLD_IR_BITS-1:0]    ir_out;
    input    jtag_state_cdr;
    input    [SLD_IR_BITS-1:0]    ir_in;
    input    tdi;
    output    [SLD_TRIGGER_BITS-1:0]    acq_trigger_out;
    input    jtag_state_uir;
    input    [SLD_TRIGGER_BITS-1:0]    acq_trigger_in;
    output    trigger_out;
    input    storage_enable;
    output    [SLD_DATA_BITS-1:0]    acq_data_out;
    input    [SLD_DATA_BITS-1:0]    acq_data_in;
    input    [SLD_STORAGE_QUALIFIER_BITS-1:0]    acq_storage_qualifier_in;
    input    jtag_state_udr;
    output    tdo;
    input    [SLD_NODE_CRC_BITS-1:0]    crc;
    input    jtag_state_e1dr;
    input    raw_tck;
    input    usr1;
    input    acq_clk;
    input    shift;
    input    ena;
    input    clr;
    input    trigger_in;
    input    update;
    input    rti;

endmodule //sld_signaltap

module    altstratixii_oct    (
    terminationenable,
    terminationclock,
    rdn,
    rup);

    parameter    lpm_type    =    "altstratixii_oct";


    input    terminationenable;
    input    terminationclock;
    input    rdn;
    input    rup;

endmodule //altstratixii_oct

module    altparallel_flash_loader    (
    flash_nce,
    fpga_data,
    fpga_dclk,
    fpga_nstatus,
    flash_ale,
    pfl_clk,
    fpga_nconfig,
    flash_io2,
    flash_sck,
    flash_noe,
    flash_nwe,
    pfl_watchdog_error,
    pfl_reset_watchdog,
    fpga_conf_done,
    flash_rdy,
    pfl_flash_access_granted,
    pfl_nreconfigure,
    flash_cle,
    flash_nreset,
    flash_io0,
    pfl_nreset,
    flash_data,
    flash_io1,
    flash_nadv,
    flash_clk,
    flash_io3,
    flash_io,
    flash_addr,
    pfl_flash_access_request,
    flash_ncs,
    fpga_pgm);

    parameter    EXTRA_ADDR_BYTE    =    0;
    parameter    FEATURES_CFG    =    1;
    parameter    PAGE_CLK_DIVISOR    =    1;
    parameter    BURST_MODE_SPANSION    =    0;
    parameter    ENHANCED_FLASH_PROGRAMMING    =    0;
    parameter    FLASH_ECC_CHECKBOX    =    0;
    parameter    FLASH_NRESET_COUNTER    =    1;
    parameter    PAGE_MODE    =    0;
    parameter    NRB_ADDR    =    65667072;
    parameter    BURST_MODE    =    0;
    parameter    SAFE_MODE_REVERT_ADDR    =    0;
    parameter    FIFO_SIZE    =    16;
    parameter    CONF_DATA_WIDTH    =    1;
    parameter    CONF_WAIT_TIMER_WIDTH    =    14;
    parameter    OPTION_BITS_START_ADDRESS    =    0;
    parameter    SAFE_MODE_RETRY    =    1;
    parameter    DCLK_DIVISOR    =    1;
    parameter    FLASH_TYPE    =    "CFI_FLASH";
    parameter    N_FLASH    =    1;
    parameter    TRISTATE_CHECKBOX    =    0;
    parameter    QFLASH_MFC    =    "ALTERA";
    parameter    FEATURES_PGM    =    1;
    parameter    DISABLE_CRC_CHECKBOX    =    0;
    parameter    FLASH_DATA_WIDTH    =    16;
    parameter    RSU_WATCHDOG_COUNTER    =    100000000;
    parameter    PFL_RSU_WATCHDOG_ENABLED    =    0;
    parameter    SAFE_MODE_HALT    =    0;
    parameter    ADDR_WIDTH    =    20;
    parameter    NAND_SIZE    =    67108864;
    parameter    NORMAL_MODE    =    1;
    parameter    FLASH_NRESET_CHECKBOX    =    0;
    parameter    SAFE_MODE_REVERT    =    0;
    parameter    LPM_TYPE    =    "ALTPARALLEL_FLASH_LOADER";
    parameter    AUTO_RESTART    =    "OFF";
    parameter    CLK_DIVISOR    =    1;
    parameter    BURST_MODE_INTEL    =    0;
    parameter    BURST_MODE_NUMONYX    =    0;
    parameter    DECOMPRESSOR_MODE    =    "NONE";

    parameter    PFL_QUAD_IO_FLASH_IR_BITS    =    8;
    parameter    PFL_CFI_FLASH_IR_BITS    =    5;
    parameter    PFL_NAND_FLASH_IR_BITS    =    4;
    parameter    N_FLASH_BITS    =    4;

    output    [N_FLASH-1:0]    flash_nce;
    output    [CONF_DATA_WIDTH-1:0]    fpga_data;
    output    fpga_dclk;
    input    fpga_nstatus;
    output    flash_ale;
    input    pfl_clk;
    output    fpga_nconfig;
    inout    [N_FLASH-1:0]    flash_io2;
    output    [N_FLASH-1:0]    flash_sck;
    output    flash_noe;
    output    flash_nwe;
    output    pfl_watchdog_error;
    input    pfl_reset_watchdog;
    input    fpga_conf_done;
    input    flash_rdy;
    input    pfl_flash_access_granted;
    input    pfl_nreconfigure;
    output    flash_cle;
    output    flash_nreset;
    inout    [N_FLASH-1:0]    flash_io0;
    input    pfl_nreset;
    inout    [FLASH_DATA_WIDTH-1:0]    flash_data;
    inout    [N_FLASH-1:0]    flash_io1;
    output    flash_nadv;
    output    flash_clk;
    inout    [N_FLASH-1:0]    flash_io3;
    inout    [7:0]    flash_io;
    output    [ADDR_WIDTH-1:0]    flash_addr;
    output    pfl_flash_access_request;
    output    [N_FLASH-1:0]    flash_ncs;
    input    [2:0]    fpga_pgm;

endmodule //altparallel_flash_loader

module    altserial_flash_loader    (
    data1in,
    data1out,
    data3in,
    data3out,
    data2out,
    noe,
    asmi_access_granted,
    data1oe,
    data0oe,
    sdoin,
    asmi_access_request,
    data0in,
    data2in,
    data0out,
    scein,
    data3oe,
    data2oe,
    dclkin);

    parameter    enhanced_mode    =    0;
    parameter    intended_device_family    =    "Cyclone";
    parameter    enable_shared_access    =    "OFF";
    parameter    enable_quad_spi_support    =    0;
    parameter    lpm_type    =    "ALTSERIAL_FLASH_LOADER";


    input    data1in;
    output    data1out;
    input    data3in;
    output    data3out;
    output    data2out;
    input    noe;
    input    asmi_access_granted;
    input    data1oe;
    input    data0oe;
    input    sdoin;
    output    asmi_access_request;
    input    data0in;
    input    data2in;
    output    data0out;
    input    scein;
    input    data3oe;
    input    data2oe;
    input    dclkin;

endmodule //altserial_flash_loader

module    altsource_probe    (
    jtag_state_sdr,
    source,
    ir_out,
    jtag_state_cdr,
    ir_in,
    jtag_state_tlr,
    tdi,
    jtag_state_uir,
    source_ena,
    jtag_state_cir,
    jtag_state_udr,
    tdo,
    clrn,
    jtag_state_e1dr,
    source_clk,
    raw_tck,
    usr1,
    ena,
    probe);

    parameter    lpm_hint    =    "UNUSED";
    parameter    sld_instance_index    =    0;
    parameter    source_initial_value    =    "0";
    parameter    sld_ir_width    =    4;
    parameter    probe_width    =    1;
    parameter    source_width    =    1;
    parameter    instance_id    =    "UNUSED";
    parameter    lpm_type    =    "altsource_probe";
    parameter    sld_auto_instance_index    =    "YES";
    parameter    SLD_NODE_INFO    =    4746752;
    parameter    enable_metastability    =    "NO";


    input    jtag_state_sdr;
    output    [source_width-1:0]    source;
    output    [sld_ir_width-1:0]    ir_out;
    input    jtag_state_cdr;
    input    [sld_ir_width-1:0]    ir_in;
    input    jtag_state_tlr;
    input    tdi;
    input    jtag_state_uir;
    input    source_ena;
    input    jtag_state_cir;
    input    jtag_state_udr;
    output    tdo;
    input    clrn;
    input    jtag_state_e1dr;
    input    source_clk;
    input    raw_tck;
    input    usr1;
    input    ena;
    input    [probe_width-1:0]    probe;

endmodule //altsource_probe

