//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  ALTERA_MF_HINT_EVALUATION
//
// Description     :  Common function to grep the value of altera specific parameters
//                    within the lpm_hint parameter.
//
// Limitation      :  No error checking to check whether the content of the lpm_hint
//                    is valid or not.
//
// Results expected:  If the target parameter found, return the value of the parameter.
//                    Otherwise, return empty string.
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module ALTERA_MF_HINT_EVALUATION;

// FUNCTON DECLARATION

// This function will search through the string (given string) to look for a match for the
// a given parameter(compare_param_name). It will return the value for the given parameter.
function [8*200:1] GET_PARAMETER_VALUE;
    input [8*200:1] given_string;  // string to be searched
    input [8*50:1] compare_param_name; // parameter name to be looking for in the given_string.
    integer param_value_char_count; // to indicate current character count in the param_value
    integer param_name_char_count;  // to indicate current character count in the param_name
    integer white_space_count;

    reg extract_param_value; // if 1 mean extracting parameters value from given string
    reg extract_param_name;  // if 1 mean extracting parameters name from given string
    reg param_found; // to indicate whether compare_param_name have been found in the given_string
    reg include_white_space; // if 1, include white space in the parameter value

    reg [8*200:1] reg_string; // to store the value of the given string
    reg [8*50:1] param_name;  // to store parameter name
    reg [8*20:1] param_value; // to store parameter value
    reg [8:1] tmp; // to get the value of the current byte
begin
    reg_string = given_string;
    param_value_char_count = 0;
    param_name_char_count =0;
    extract_param_value = 1;
    extract_param_name = 0;
    param_found = 0;
    include_white_space = 0;
    white_space_count = 0;

    tmp = reg_string[8:1];

    // checking every bytes of the reg_string from right to left.
    while ((tmp != 0 ) && (param_found != 1))
    begin
        tmp = reg_string[8:1];

        //if tmp != ' ' or should include white space (trailing white space are ignored)
        if((tmp != 32) || (include_white_space == 1))
        begin
            if(tmp == 32)
            begin
                white_space_count = 1;
            end
            else if(tmp == 61)  // if tmp = '='
            begin
                extract_param_value = 0;
                extract_param_name =  1;  // subsequent bytes should be part of param_name
                include_white_space = 0;  // ignore the white space (if any) between param_name and '='
                white_space_count = 0;
                param_value = param_value >> (8 * (20 - param_value_char_count));
                param_value_char_count = 0;
            end
            else if (tmp == 44) // if tmp = ','
            begin
                extract_param_value = 1; // subsequent bytes should be part of param_value
                extract_param_name =  0;
                param_name = param_name >> (8 * (50 - param_name_char_count));
                param_name_char_count = 0;
                if(param_name == compare_param_name)
                    param_found = 1;  // the compare_param_name have been found in the reg_string
            end
            else
            begin
                if(extract_param_value == 1)
                begin
                    param_value_char_count = param_value_char_count + white_space_count + 1;
                    include_white_space = 1;
                    if(white_space_count > 0)
                    begin
                        param_value = {8'b100000, param_value[20*8:9]};
                        white_space_count = 0;
                    end
                    param_value = {tmp, param_value[20*8:9]};
                end
                else if(extract_param_name == 1)
                begin
                    param_name = {tmp, param_name[50*8:9]};
                    param_name_char_count = param_name_char_count + 1;
                end
            end
        end
        reg_string = reg_string >> 8;  // shift 1 byte to the right
    end

    // for the case whether param_name is the left most part of the reg_string
    if(extract_param_name == 1)
    begin
        param_name = param_name >> (8 * (50 - param_name_char_count));

        if(param_name == compare_param_name)
            param_found = 1;
    end

    if (param_found == 1)
        GET_PARAMETER_VALUE = param_value;   // return the value of the parameter been looking for
    else
        GET_PARAMETER_VALUE = "";  // return empty string if parameter not found

end
endfunction

endmodule // ALTERA_MF_HINT_EVALUATION

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  ALTERA_DEVICE_FAMILIES
//
// Description     :  Common Altera device families comparison
//
// Limitation      :
//
// Results expected:
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
module ALTERA_DEVICE_FAMILIES;

function IS_FAMILY_ACEX1K;
    input[8*20:1] device;
    reg is_acex1k;
begin
    if ((device == "ACEX1K") || (device == "acex1k") || (device == "ACEX 1K") || (device == "acex 1k"))
        is_acex1k = 1;
    else
        is_acex1k = 0;

    IS_FAMILY_ACEX1K  = is_acex1k;
end
endfunction //IS_FAMILY_ACEX1K

function IS_FAMILY_APEX20K;
    input[8*20:1] device;
    reg is_apex20k;
begin
    if ((device == "APEX20K") || (device == "apex20k") || (device == "APEX 20K") || (device == "apex 20k") || (device == "RAPHAEL") || (device == "raphael"))
        is_apex20k = 1;
    else
        is_apex20k = 0;

    IS_FAMILY_APEX20K  = is_apex20k;
end
endfunction //IS_FAMILY_APEX20K

function IS_FAMILY_APEX20KC;
    input[8*20:1] device;
    reg is_apex20kc;
begin
    if ((device == "APEX20KC") || (device == "apex20kc") || (device == "APEX 20KC") || (device == "apex 20kc"))
        is_apex20kc = 1;
    else
        is_apex20kc = 0;

    IS_FAMILY_APEX20KC  = is_apex20kc;
end
endfunction //IS_FAMILY_APEX20KC

function IS_FAMILY_APEX20KE;
    input[8*20:1] device;
    reg is_apex20ke;
begin
    if ((device == "APEX20KE") || (device == "apex20ke") || (device == "APEX 20KE") || (device == "apex 20ke"))
        is_apex20ke = 1;
    else
        is_apex20ke = 0;

    IS_FAMILY_APEX20KE  = is_apex20ke;
end
endfunction //IS_FAMILY_APEX20KE

function IS_FAMILY_APEXII;
    input[8*20:1] device;
    reg is_apexii;
begin
    if ((device == "APEX II") || (device == "apex ii") || (device == "APEXII") || (device == "apexii") || (device == "APEX 20KF") || (device == "apex 20kf") || (device == "APEX20KF") || (device == "apex20kf"))
        is_apexii = 1;
    else
        is_apexii = 0;

    IS_FAMILY_APEXII  = is_apexii;
end
endfunction //IS_FAMILY_APEXII

function IS_FAMILY_EXCALIBUR_ARM;
    input[8*20:1] device;
    reg is_excalibur_arm;
begin
    if ((device == "EXCALIBUR_ARM") || (device == "excalibur_arm") || (device == "Excalibur ARM") || (device == "EXCALIBUR ARM") || (device == "excalibur arm") || (device == "ARM-BASED EXCALIBUR") || (device == "arm-based excalibur") || (device == "ARM_BASED_EXCALIBUR") || (device == "arm_based_excalibur"))
        is_excalibur_arm = 1;
    else
        is_excalibur_arm = 0;

    IS_FAMILY_EXCALIBUR_ARM  = is_excalibur_arm;
end
endfunction //IS_FAMILY_EXCALIBUR_ARM

function IS_FAMILY_FLEX10KE;
    input[8*20:1] device;
    reg is_flex10ke;
begin
    if ((device == "FLEX10KE") || (device == "flex10ke") || (device == "FLEX 10KE") || (device == "flex 10ke"))
        is_flex10ke = 1;
    else
        is_flex10ke = 0;

    IS_FAMILY_FLEX10KE  = is_flex10ke;
end
endfunction //IS_FAMILY_FLEX10KE

function IS_FAMILY_STRATIX;
    input[8*20:1] device;
    reg is_stratix;
begin
    if ((device == "Stratix") || (device == "STRATIX") || (device == "stratix") || (device == "Yeager") || (device == "YEAGER") || (device == "yeager"))
        is_stratix = 1;
    else
        is_stratix = 0;

    IS_FAMILY_STRATIX  = is_stratix;
end
endfunction //IS_FAMILY_STRATIX

function IS_FAMILY_STRATIXGX;
    input[8*20:1] device;
    reg is_stratixgx;
begin
    if ((device == "Stratix GX") || (device == "STRATIX GX") || (device == "stratix gx") || (device == "Stratix-GX") || (device == "STRATIX-GX") || (device == "stratix-gx") || (device == "StratixGX") || (device == "STRATIXGX") || (device == "stratixgx") || (device == "Aurora") || (device == "AURORA") || (device == "aurora"))
        is_stratixgx = 1;
    else
        is_stratixgx = 0;

    IS_FAMILY_STRATIXGX  = is_stratixgx;
end
endfunction //IS_FAMILY_STRATIXGX

function IS_FAMILY_CYCLONE;
    input[8*20:1] device;
    reg is_cyclone;
begin
    if ((device == "Cyclone") || (device == "CYCLONE") || (device == "cyclone") || (device == "ACEX2K") || (device == "acex2k") || (device == "ACEX 2K") || (device == "acex 2k") || (device == "Tornado") || (device == "TORNADO") || (device == "tornado"))
        is_cyclone = 1;
    else
        is_cyclone = 0;

    IS_FAMILY_CYCLONE  = is_cyclone;
end
endfunction //IS_FAMILY_CYCLONE

function IS_FAMILY_MAXII;
    input[8*20:1] device;
    reg is_maxii;
begin
    if ((device == "MAX II") || (device == "max ii") || (device == "MAXII") || (device == "maxii") || (device == "Tsunami") || (device == "TSUNAMI") || (device == "tsunami"))
        is_maxii = 1;
    else
        is_maxii = 0;

    IS_FAMILY_MAXII  = is_maxii;
end
endfunction //IS_FAMILY_MAXII

function IS_FAMILY_HARDCOPYSTRATIX;
    input[8*20:1] device;
    reg is_hardcopystratix;
begin
    if ((device == "HardCopy Stratix") || (device == "HARDCOPY STRATIX") || (device == "hardcopy stratix") || (device == "Stratix HC") || (device == "STRATIX HC") || (device == "stratix hc") || (device == "StratixHC") || (device == "STRATIXHC") || (device == "stratixhc") || (device == "HardcopyStratix") || (device == "HARDCOPYSTRATIX") || (device == "hardcopystratix"))
        is_hardcopystratix = 1;
    else
        is_hardcopystratix = 0;

    IS_FAMILY_HARDCOPYSTRATIX  = is_hardcopystratix;
end
endfunction //IS_FAMILY_HARDCOPYSTRATIX

function IS_FAMILY_STRATIXII;
    input[8*20:1] device;
    reg is_stratixii;
begin
    if ((device == "Stratix II") || (device == "STRATIX II") || (device == "stratix ii") || (device == "StratixII") || (device == "STRATIXII") || (device == "stratixii") || (device == "Armstrong") || (device == "ARMSTRONG") || (device == "armstrong"))
        is_stratixii = 1;
    else
        is_stratixii = 0;

    IS_FAMILY_STRATIXII  = is_stratixii;
end
endfunction //IS_FAMILY_STRATIXII

function IS_FAMILY_STRATIXIIGX;
    input[8*20:1] device;
    reg is_stratixiigx;
begin
    if ((device == "Stratix II GX") || (device == "STRATIX II GX") || (device == "stratix ii gx") || (device == "StratixIIGX") || (device == "STRATIXIIGX") || (device == "stratixiigx"))
        is_stratixiigx = 1;
    else
        is_stratixiigx = 0;

    IS_FAMILY_STRATIXIIGX  = is_stratixiigx;
end
endfunction //IS_FAMILY_STRATIXIIGX

function IS_FAMILY_ARRIAGX;
    input[8*20:1] device;
    reg is_arriagx;
begin
    if ((device == "Arria GX") || (device == "ARRIA GX") || (device == "arria gx") || (device == "ArriaGX") || (device == "ARRIAGX") || (device == "arriagx") || (device == "Stratix II GX Lite") || (device == "STRATIX II GX LITE") || (device == "stratix ii gx lite") || (device == "StratixIIGXLite") || (device == "STRATIXIIGXLITE") || (device == "stratixiigxlite"))
        is_arriagx = 1;
    else
        is_arriagx = 0;

    IS_FAMILY_ARRIAGX  = is_arriagx;
end
endfunction //IS_FAMILY_ARRIAGX

function IS_FAMILY_CYCLONEII;
    input[8*20:1] device;
    reg is_cycloneii;
begin
    if ((device == "Cyclone II") || (device == "CYCLONE II") || (device == "cyclone ii") || (device == "Cycloneii") || (device == "CYCLONEII") || (device == "cycloneii") || (device == "Magellan") || (device == "MAGELLAN") || (device == "magellan"))
        is_cycloneii = 1;
    else
        is_cycloneii = 0;

    IS_FAMILY_CYCLONEII  = is_cycloneii;
end
endfunction //IS_FAMILY_CYCLONEII

function IS_FAMILY_HARDCOPYII;
    input[8*20:1] device;
    reg is_hardcopyii;
begin
    if ((device == "HardCopy II") || (device == "HARDCOPY II") || (device == "hardcopy ii") || (device == "HardCopyII") || (device == "HARDCOPYII") || (device == "hardcopyii") || (device == "Fusion") || (device == "FUSION") || (device == "fusion"))
        is_hardcopyii = 1;
    else
        is_hardcopyii = 0;

    IS_FAMILY_HARDCOPYII  = is_hardcopyii;
end
endfunction //IS_FAMILY_HARDCOPYII

function IS_FAMILY_STRATIXIII;
    input[8*20:1] device;
    reg is_stratixiii;
begin
    if ((device == "Stratix III") || (device == "STRATIX III") || (device == "stratix iii") || (device == "StratixIII") || (device == "STRATIXIII") || (device == "stratixiii") || (device == "Titan") || (device == "TITAN") || (device == "titan") || (device == "SIII") || (device == "siii"))
        is_stratixiii = 1;
    else
        is_stratixiii = 0;

    IS_FAMILY_STRATIXIII  = is_stratixiii;
end
endfunction //IS_FAMILY_STRATIXIII

function IS_FAMILY_CYCLONEIII;
    input[8*20:1] device;
    reg is_cycloneiii;
begin
    if ((device == "Cyclone III") || (device == "CYCLONE III") || (device == "cyclone iii") || (device == "CycloneIII") || (device == "CYCLONEIII") || (device == "cycloneiii") || (device == "Barracuda") || (device == "BARRACUDA") || (device == "barracuda") || (device == "Cuda") || (device == "CUDA") || (device == "cuda") || (device == "CIII") || (device == "ciii"))
        is_cycloneiii = 1;
    else
        is_cycloneiii = 0;

    IS_FAMILY_CYCLONEIII  = is_cycloneiii;
end
endfunction //IS_FAMILY_CYCLONEIII

function IS_FAMILY_STRATIXIV;
    input[8*20:1] device;
    reg is_stratixiv;
begin
    if ((device == "Stratix IV") || (device == "STRATIX IV") || (device == "stratix iv") || (device == "TGX") || (device == "tgx") || (device == "StratixIV") || (device == "STRATIXIV") || (device == "stratixiv") || (device == "StratixIIIGX") || (device == "STRATIXIIIGX") || (device == "stratixiiigx") || (device == "Stratix IV (GT/GX/E)") || (device == "STRATIX IV (GT/GX/E)") || (device == "stratix iv (gt/gx/e)") || (device == "StratixIV(GT/GX/E)") || (device == "STRATIXIV(GT/GX/E)") || (device == "stratixiv(gt/gx/e)") || (device == "Stratix IV (GX/E)") || (device == "STRATIX IV (GX/E)") || (device == "stratix iv (gx/e)") || (device == "StratixIV(GX/E)") || (device == "STRATIXIV(GX/E)") || (device == "stratixiv(gx/e)"))
        is_stratixiv = 1;
    else
        is_stratixiv = 0;

    IS_FAMILY_STRATIXIV  = is_stratixiv;
end
endfunction //IS_FAMILY_STRATIXIV

function IS_FAMILY_ARRIAIIGXGX;
    input[8*20:1] device;
    reg is_arriaiigx;
begin
    if ((device == "Arria II GX") || (device == "ARRIA II GX") || (device == "arria ii gx") || (device == "ArriaIIGX") || (device == "ARRIAIIGX") || (device == "arriaiigx") || (device == "Arria IIGX") || (device == "ARRIA IIGX") || (device == "arria iigx") || (device == "ArriaII GX") || (device == "ARRIAII GX") || (device == "arriaii gx") || (device == "Arria II") || (device == "ARRIA II") || (device == "arria ii") || (device == "ArriaII") || (device == "ARRIAII") || (device == "arriaii") || (device == "Arria II (GX/E)") || (device == "ARRIA II (GX/E)") || (device == "arria ii (gx/e)") || (device == "ArriaII(GX/E)") || (device == "ARRIAII(GX/E)") || (device == "arriaii(gx/e)") || (device == "PIRANHA") || (device == "piranha"))
        is_arriaiigx = 1;
    else
        is_arriaiigx = 0;

    IS_FAMILY_ARRIAIIGXGX  = is_arriaiigx;
end
endfunction //IS_FAMILY_ARRIAIIGXGX

function IS_FAMILY_HARDCOPYIII;
    input[8*20:1] device;
    reg is_hardcopyiii;
begin
    if ((device == "HardCopy III") || (device == "HARDCOPY III") || (device == "hardcopy iii") || (device == "HardCopyIII") || (device == "HARDCOPYIII") || (device == "hardcopyiii") || (device == "HCX") || (device == "hcx"))
        is_hardcopyiii = 1;
    else
        is_hardcopyiii = 0;

    IS_FAMILY_HARDCOPYIII  = is_hardcopyiii;
end
endfunction //IS_FAMILY_HARDCOPYIII

function IS_FAMILY_HARDCOPYIV;
    input[8*20:1] device;
    reg is_hardcopyiv;
begin
    if ((device == "HardCopy IV") || (device == "HARDCOPY IV") || (device == "hardcopy iv") || (device == "HardCopyIV") || (device == "HARDCOPYIV") || (device == "hardcopyiv") || (device == "HCXIV") || (device == "hcxiv") || (device == "HardCopy IV (GX/E)") || (device == "HARDCOPY IV (GX/E)") || (device == "hardcopy iv (gx/e)") || (device == "HardCopyIV(GX/E)") || (device == "HARDCOPYIV(GX/E)") || (device == "hardcopyiv(gx/e)"))
        is_hardcopyiv = 1;
    else
        is_hardcopyiv = 0;

    IS_FAMILY_HARDCOPYIV  = is_hardcopyiv;
end
endfunction //IS_FAMILY_HARDCOPYIV

function IS_FAMILY_CYCLONEIIILS;
    input[8*20:1] device;
    reg is_cycloneiiils;
begin
    if ((device == "Cyclone III LS") || (device == "CYCLONE III LS") || (device == "cyclone iii ls") || (device == "CycloneIIILS") || (device == "CYCLONEIIILS") || (device == "cycloneiiils") || (device == "Cyclone III LPS") || (device == "CYCLONE III LPS") || (device == "cyclone iii lps") || (device == "Cyclone LPS") || (device == "CYCLONE LPS") || (device == "cyclone lps") || (device == "CycloneLPS") || (device == "CYCLONELPS") || (device == "cyclonelps") || (device == "Tarpon") || (device == "TARPON") || (device == "tarpon") || (device == "Cyclone IIIE") || (device == "CYCLONE IIIE") || (device == "cyclone iiie"))
        is_cycloneiiils = 1;
    else
        is_cycloneiiils = 0;

    IS_FAMILY_CYCLONEIIILS  = is_cycloneiiils;
end
endfunction //IS_FAMILY_CYCLONEIIILS

function FEATURE_FAMILY_FLEX10KE;
    input[8*20:1] device;
    reg var_family_flex10ke;
begin
    if (IS_FAMILY_FLEX10KE(device) || IS_FAMILY_ACEX1K(device) )
        var_family_flex10ke = 1;
    else
        var_family_flex10ke = 0;

    FEATURE_FAMILY_FLEX10KE  = var_family_flex10ke;
end
endfunction //FEATURE_FAMILY_FLEX10KE

function FEATURE_FAMILY_APEX20K;
    input[8*20:1] device;
    reg var_family_apex20k;
begin
    if (IS_FAMILY_APEX20K(device) )
        var_family_apex20k = 1;
    else
        var_family_apex20k = 0;

    FEATURE_FAMILY_APEX20K  = var_family_apex20k;
end
endfunction //FEATURE_FAMILY_APEX20K

function FEATURE_FAMILY_APEX20KE;
    input[8*20:1] device;
    reg var_family_apex20ke;
begin
    if (IS_FAMILY_APEX20KE(device) || IS_FAMILY_EXCALIBUR_ARM(device) || IS_FAMILY_APEX20KC(device) )
        var_family_apex20ke = 1;
    else
        var_family_apex20ke = 0;

    FEATURE_FAMILY_APEX20KE  = var_family_apex20ke;
end
endfunction //FEATURE_FAMILY_APEX20KE

function FEATURE_FAMILY_APEXII;
    input[8*20:1] device;
    reg var_family_apexii;
begin
    if (IS_FAMILY_APEXII(device) || IS_FAMILY_APEXII(device) )
        var_family_apexii = 1;
    else
        var_family_apexii = 0;

    FEATURE_FAMILY_APEXII  = var_family_apexii;
end
endfunction //FEATURE_FAMILY_APEXII

function FEATURE_FAMILY_STRATIXGX;
    input[8*20:1] device;
    reg var_family_stratixgx;
begin
    if (IS_FAMILY_STRATIXGX(device) )
        var_family_stratixgx = 1;
    else
        var_family_stratixgx = 0;

    FEATURE_FAMILY_STRATIXGX  = var_family_stratixgx;
end
endfunction //FEATURE_FAMILY_STRATIXGX

function FEATURE_FAMILY_CYCLONE;
    input[8*20:1] device;
    reg var_family_cyclone;
begin
    if (IS_FAMILY_CYCLONE(device) )
        var_family_cyclone = 1;
    else
        var_family_cyclone = 0;

    FEATURE_FAMILY_CYCLONE  = var_family_cyclone;
end
endfunction //FEATURE_FAMILY_CYCLONE

function FEATURE_FAMILY_STRATIXIIGX;
    input[8*20:1] device;
    reg var_family_stratixiigx;
begin
    if (IS_FAMILY_STRATIXIIGX(device) || IS_FAMILY_ARRIAGX(device) )
        var_family_stratixiigx = 1;
    else
        var_family_stratixiigx = 0;

    FEATURE_FAMILY_STRATIXIIGX  = var_family_stratixiigx;
end
endfunction //FEATURE_FAMILY_STRATIXIIGX

function FEATURE_FAMILY_STRATIXIII;
    input[8*20:1] device;
    reg var_family_stratixiii;
begin
    if (IS_FAMILY_STRATIXIII(device) || FEATURE_FAMILY_STRATIXIV(device) || IS_FAMILY_HARDCOPYIII(device) )
        var_family_stratixiii = 1;
    else
        var_family_stratixiii = 0;

    FEATURE_FAMILY_STRATIXIII  = var_family_stratixiii;
end
endfunction //FEATURE_FAMILY_STRATIXIII

function FEATURE_FAMILY_STRATIXII;
    input[8*20:1] device;
    reg var_family_stratixii;
begin
    if (IS_FAMILY_STRATIXII(device) || IS_FAMILY_HARDCOPYII(device) || FEATURE_FAMILY_STRATIXIIGX(device) || FEATURE_FAMILY_STRATIXIII(device) )
        var_family_stratixii = 1;
    else
        var_family_stratixii = 0;

    FEATURE_FAMILY_STRATIXII  = var_family_stratixii;
end
endfunction //FEATURE_FAMILY_STRATIXII

function FEATURE_FAMILY_CYCLONEIII;
    input[8*20:1] device;
    reg var_family_cycloneiii;
begin
    if (IS_FAMILY_CYCLONEIII(device) || IS_FAMILY_CYCLONEIIILS(device) )
        var_family_cycloneiii = 1;
    else
        var_family_cycloneiii = 0;

    FEATURE_FAMILY_CYCLONEIII  = var_family_cycloneiii;
end
endfunction //FEATURE_FAMILY_CYCLONEIII

function FEATURE_FAMILY_STRATIX_HC;
    input[8*20:1] device;
    reg var_family_stratix_hc;
begin
    if (IS_FAMILY_HARDCOPYSTRATIX(device) )
        var_family_stratix_hc = 1;
    else
        var_family_stratix_hc = 0;

    FEATURE_FAMILY_STRATIX_HC  = var_family_stratix_hc;
end
endfunction //FEATURE_FAMILY_STRATIX_HC

function FEATURE_FAMILY_HARDCOPYII;
    input[8*20:1] device;
    reg var_family_hardcopyii;
begin
    if (IS_FAMILY_HARDCOPYII(device) )
        var_family_hardcopyii = 1;
    else
        var_family_hardcopyii = 0;

    FEATURE_FAMILY_HARDCOPYII  = var_family_hardcopyii;
end
endfunction //FEATURE_FAMILY_HARDCOPYII

function FEATURE_FAMILY_STRATIX;
    input[8*20:1] device;
    reg var_family_stratix;
begin
    if (IS_FAMILY_STRATIX(device) || FEATURE_FAMILY_STRATIX_HC(device) || FEATURE_FAMILY_STRATIXGX(device) || FEATURE_FAMILY_CYCLONE(device) || FEATURE_FAMILY_STRATIXII(device) || FEATURE_FAMILY_MAXII(device) || FEATURE_FAMILY_CYCLONEII(device) )
        var_family_stratix = 1;
    else
        var_family_stratix = 0;

    FEATURE_FAMILY_STRATIX  = var_family_stratix;
end
endfunction //FEATURE_FAMILY_STRATIX

function FEATURE_FAMILY_MAXII;
    input[8*20:1] device;
    reg var_family_maxii;
begin
    if (IS_FAMILY_MAXII(device) )
        var_family_maxii = 1;
    else
        var_family_maxii = 0;

    FEATURE_FAMILY_MAXII  = var_family_maxii;
end
endfunction //FEATURE_FAMILY_MAXII

function FEATURE_FAMILY_CYCLONEII;
    input[8*20:1] device;
    reg var_family_cycloneii;
begin
    if (IS_FAMILY_CYCLONEII(device) || FEATURE_FAMILY_CYCLONEIII(device) )
        var_family_cycloneii = 1;
    else
        var_family_cycloneii = 0;

    FEATURE_FAMILY_CYCLONEII  = var_family_cycloneii;
end
endfunction //FEATURE_FAMILY_CYCLONEII

function FEATURE_FAMILY_STRATIXIV;
    input[8*20:1] device;
    reg var_family_stratixiv;
begin
    if (IS_FAMILY_STRATIXIV(device) || IS_FAMILY_ARRIAIIGXGX(device) || IS_FAMILY_HARDCOPYIV(device) )
        var_family_stratixiv = 1;
    else
        var_family_stratixiv = 0;

    FEATURE_FAMILY_STRATIXIV  = var_family_stratixiv;
end
endfunction //FEATURE_FAMILY_STRATIXIV

function FEATURE_FAMILY_ARRIAIIGX;
    input[8*20:1] device;
    reg var_family_arriaiigx;
begin
    if (IS_FAMILY_ARRIAIIGXGX(device) )
        var_family_arriaiigx = 1;
    else
        var_family_arriaiigx = 0;

    FEATURE_FAMILY_ARRIAIIGX  = var_family_arriaiigx;
end
endfunction //FEATURE_FAMILY_ARRIAIIGX

function FEATURE_FAMILY_BASE_STRATIXII;
    input[8*20:1] device;
    reg var_family_base_stratixii;
begin
    if (IS_FAMILY_STRATIXII(device) || IS_FAMILY_HARDCOPYII(device) || FEATURE_FAMILY_STRATIXIIGX(device) )
        var_family_base_stratixii = 1;
    else
        var_family_base_stratixii = 0;

    FEATURE_FAMILY_BASE_STRATIXII  = var_family_base_stratixii;
end
endfunction //FEATURE_FAMILY_BASE_STRATIXII

function FEATURE_FAMILY_BASE_STRATIX;
    input[8*20:1] device;
    reg var_family_base_stratix;
begin
    if (IS_FAMILY_STRATIX(device) || IS_FAMILY_STRATIXGX(device) || IS_FAMILY_HARDCOPYSTRATIX(device) )
        var_family_base_stratix = 1;
    else
        var_family_base_stratix = 0;

    FEATURE_FAMILY_BASE_STRATIX  = var_family_base_stratix;
end
endfunction //FEATURE_FAMILY_BASE_STRATIX

function FEATURE_FAMILY_BASE_CYCLONEII;
    input[8*20:1] device;
    reg var_family_base_cycloneii;
begin
    if (IS_FAMILY_CYCLONEII(device) )
        var_family_base_cycloneii = 1;
    else
        var_family_base_cycloneii = 0;

    FEATURE_FAMILY_BASE_CYCLONEII  = var_family_base_cycloneii;
end
endfunction //FEATURE_FAMILY_BASE_CYCLONEII

function FEATURE_FAMILY_BASE_CYCLONE;
    input[8*20:1] device;
    reg var_family_base_cyclone;
begin
    if (IS_FAMILY_CYCLONE(device) )
        var_family_base_cyclone = 1;
    else
        var_family_base_cyclone = 0;

    FEATURE_FAMILY_BASE_CYCLONE  = var_family_base_cyclone;
end
endfunction //FEATURE_FAMILY_BASE_CYCLONE

function FEATURE_FAMILY_HAS_MEGARAM;
    input[8*20:1] device;
    reg var_family_has_megaram;
begin
    if (IS_FAMILY_STRATIX(device) || FEATURE_FAMILY_STRATIX_HC(device) || IS_FAMILY_STRATIXGX(device) || FEATURE_FAMILY_STRATIXII(device) && ! FEATURE_FAMILY_ARRIAIIGX(device) )
        var_family_has_megaram = 1;
    else
        var_family_has_megaram = 0;

    FEATURE_FAMILY_HAS_MEGARAM  = var_family_has_megaram;
end
endfunction //FEATURE_FAMILY_HAS_MEGARAM

function FEATURE_FAMILY_HAS_M512;
    input[8*20:1] device;
    reg var_family_has_m512;
begin
    if (IS_FAMILY_STRATIX(device) || FEATURE_FAMILY_STRATIX_HC(device) || IS_FAMILY_STRATIXGX(device) || IS_FAMILY_STRATIXII(device) || FEATURE_FAMILY_STRATIXIIGX(device) )
        var_family_has_m512 = 1;
    else
        var_family_has_m512 = 0;

    FEATURE_FAMILY_HAS_M512  = var_family_has_m512;
end
endfunction //FEATURE_FAMILY_HAS_M512

function FEATURE_FAMILY_HAS_LUTRAM;
    input[8*20:1] device;
    reg var_family_has_lutram;
begin
    if (FEATURE_FAMILY_STRATIXIII(device) )
        var_family_has_lutram = 1;
    else
        var_family_has_lutram = 0;

    FEATURE_FAMILY_HAS_LUTRAM  = var_family_has_lutram;
end
endfunction //FEATURE_FAMILY_HAS_LUTRAM

function FEATURE_FAMILY_HAS_STRATIXI_STYLE_RAM;
    input[8*20:1] device;
    reg var_family_has_stratixi_style_ram;
begin
    if (IS_FAMILY_STRATIX(device) || FEATURE_FAMILY_STRATIX_HC(device) || FEATURE_FAMILY_STRATIXGX(device) || FEATURE_FAMILY_CYCLONE(device) )
        var_family_has_stratixi_style_ram = 1;
    else
        var_family_has_stratixi_style_ram = 0;

    FEATURE_FAMILY_HAS_STRATIXI_STYLE_RAM  = var_family_has_stratixi_style_ram;
end
endfunction //FEATURE_FAMILY_HAS_STRATIXI_STYLE_RAM

function FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM;
    input[8*20:1] device;
    reg var_family_has_stratixii_style_ram;
begin
    if (FEATURE_FAMILY_STRATIXII(device) || FEATURE_FAMILY_CYCLONEII(device) )
        var_family_has_stratixii_style_ram = 1;
    else
        var_family_has_stratixii_style_ram = 0;

    FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM  = var_family_has_stratixii_style_ram;
end
endfunction //FEATURE_FAMILY_HAS_STRATIXII_STYLE_RAM

function FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM;
    input[8*20:1] device;
    reg var_family_has_stratixiii_style_ram;
begin
    if (FEATURE_FAMILY_STRATIXIII(device) || FEATURE_FAMILY_CYCLONEIII(device) )
        var_family_has_stratixiii_style_ram = 1;
    else
        var_family_has_stratixiii_style_ram = 0;

    FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM  = var_family_has_stratixiii_style_ram;
end
endfunction //FEATURE_FAMILY_HAS_STRATIXIII_STYLE_RAM

function FEATURE_FAMILY_HAS_STRATIX_STYLE_PLL;
    input[8*20:1] device;
    reg var_family_has_stratix_style_pll;
begin
    if (FEATURE_FAMILY_CYCLONE(device) || FEATURE_FAMILY_STRATIX_HC(device) || IS_FAMILY_STRATIX(device) || FEATURE_FAMILY_STRATIXGX(device) )
        var_family_has_stratix_style_pll = 1;
    else
        var_family_has_stratix_style_pll = 0;

    FEATURE_FAMILY_HAS_STRATIX_STYLE_PLL  = var_family_has_stratix_style_pll;
end
endfunction //FEATURE_FAMILY_HAS_STRATIX_STYLE_PLL

function FEATURE_FAMILY_HAS_STRATIXII_STYLE_PLL;
    input[8*20:1] device;
    reg var_family_has_stratixii_style_pll;
begin
    if (FEATURE_FAMILY_STRATIXII(device) && ! FEATURE_FAMILY_STRATIXIII(device) || FEATURE_FAMILY_CYCLONEII(device) && ! FEATURE_FAMILY_CYCLONEIII(device) )
        var_family_has_stratixii_style_pll = 1;
    else
        var_family_has_stratixii_style_pll = 0;

    FEATURE_FAMILY_HAS_STRATIXII_STYLE_PLL  = var_family_has_stratixii_style_pll;
end
endfunction //FEATURE_FAMILY_HAS_STRATIXII_STYLE_PLL

function FEATURE_FAMILY_HAS_INVERTED_OUTPUT_DDIO;
    input[8*20:1] device;
    reg var_family_has_inverted_output_ddio;
begin
    if (FEATURE_FAMILY_CYCLONEII(device) )
        var_family_has_inverted_output_ddio = 1;
    else
        var_family_has_inverted_output_ddio = 0;

    FEATURE_FAMILY_HAS_INVERTED_OUTPUT_DDIO  = var_family_has_inverted_output_ddio;
end
endfunction //FEATURE_FAMILY_HAS_INVERTED_OUTPUT_DDIO

function IS_VALID_FAMILY;
    input[8*20:1] device;
    reg is_valid;
begin
    if (((device == "ACEX1K") || (device == "acex1k") || (device == "ACEX 1K") || (device == "acex 1k"))
    || ((device == "APEX20K") || (device == "apex20k") || (device == "APEX 20K") || (device == "apex 20k") || (device == "RAPHAEL") || (device == "raphael"))
    || ((device == "APEX20KC") || (device == "apex20kc") || (device == "APEX 20KC") || (device == "apex 20kc"))
    || ((device == "APEX20KE") || (device == "apex20ke") || (device == "APEX 20KE") || (device == "apex 20ke"))
    || ((device == "APEX II") || (device == "apex ii") || (device == "APEXII") || (device == "apexii") || (device == "APEX 20KF") || (device == "apex 20kf") || (device == "APEX20KF") || (device == "apex20kf"))
    || ((device == "EXCALIBUR_ARM") || (device == "excalibur_arm") || (device == "Excalibur ARM") || (device == "EXCALIBUR ARM") || (device == "excalibur arm") || (device == "ARM-BASED EXCALIBUR") || (device == "arm-based excalibur") || (device == "ARM_BASED_EXCALIBUR") || (device == "arm_based_excalibur"))
    || ((device == "FLEX10KE") || (device == "flex10ke") || (device == "FLEX 10KE") || (device == "flex 10ke"))
    || ((device == "FLEX10K") || (device == "flex10k") || (device == "FLEX 10K") || (device == "flex 10k"))
    || ((device == "FLEX10KA") || (device == "flex10ka") || (device == "FLEX 10KA") || (device == "flex 10ka"))
    || ((device == "FLEX6000") || (device == "flex6000") || (device == "FLEX 6000") || (device == "flex 6000") || (device == "FLEX6K") || (device == "flex6k"))
    || ((device == "MAX7000B") || (device == "max7000b") || (device == "MAX 7000B") || (device == "max 7000b"))
    || ((device == "MAX7000AE") || (device == "max7000ae") || (device == "MAX 7000AE") || (device == "max 7000ae"))
    || ((device == "MAX3000A") || (device == "max3000a") || (device == "MAX 3000A") || (device == "max 3000a"))
    || ((device == "MAX7000S") || (device == "max7000s") || (device == "MAX 7000S") || (device == "max 7000s"))
    || ((device == "MAX7000A") || (device == "max7000a") || (device == "MAX 7000A") || (device == "max 7000a"))
    || ((device == "Mercury") || (device == "MERCURY") || (device == "mercury") || (device == "DALI") || (device == "dali"))
    || ((device == "Stratix") || (device == "STRATIX") || (device == "stratix") || (device == "Yeager") || (device == "YEAGER") || (device == "yeager"))
    || ((device == "Stratix GX") || (device == "STRATIX GX") || (device == "stratix gx") || (device == "Stratix-GX") || (device == "STRATIX-GX") || (device == "stratix-gx") || (device == "StratixGX") || (device == "STRATIXGX") || (device == "stratixgx") || (device == "Aurora") || (device == "AURORA") || (device == "aurora"))
    || ((device == "Cyclone") || (device == "CYCLONE") || (device == "cyclone") || (device == "ACEX2K") || (device == "acex2k") || (device == "ACEX 2K") || (device == "acex 2k") || (device == "Tornado") || (device == "TORNADO") || (device == "tornado"))
    || ((device == "MAX II") || (device == "max ii") || (device == "MAXII") || (device == "maxii") || (device == "Tsunami") || (device == "TSUNAMI") || (device == "tsunami"))
    || ((device == "HardCopy Stratix") || (device == "HARDCOPY STRATIX") || (device == "hardcopy stratix") || (device == "Stratix HC") || (device == "STRATIX HC") || (device == "stratix hc") || (device == "StratixHC") || (device == "STRATIXHC") || (device == "stratixhc") || (device == "HardcopyStratix") || (device == "HARDCOPYSTRATIX") || (device == "hardcopystratix"))
    || ((device == "Stratix II") || (device == "STRATIX II") || (device == "stratix ii") || (device == "StratixII") || (device == "STRATIXII") || (device == "stratixii") || (device == "Armstrong") || (device == "ARMSTRONG") || (device == "armstrong"))
    || ((device == "Stratix II GX") || (device == "STRATIX II GX") || (device == "stratix ii gx") || (device == "StratixIIGX") || (device == "STRATIXIIGX") || (device == "stratixiigx"))
    || ((device == "Arria GX") || (device == "ARRIA GX") || (device == "arria gx") || (device == "ArriaGX") || (device == "ARRIAGX") || (device == "arriagx") || (device == "Stratix II GX Lite") || (device == "STRATIX II GX LITE") || (device == "stratix ii gx lite") || (device == "StratixIIGXLite") || (device == "STRATIXIIGXLITE") || (device == "stratixiigxlite"))
    || ((device == "Cyclone II") || (device == "CYCLONE II") || (device == "cyclone ii") || (device == "Cycloneii") || (device == "CYCLONEII") || (device == "cycloneii") || (device == "Magellan") || (device == "MAGELLAN") || (device == "magellan"))
    || ((device == "HardCopy II") || (device == "HARDCOPY II") || (device == "hardcopy ii") || (device == "HardCopyII") || (device == "HARDCOPYII") || (device == "hardcopyii") || (device == "Fusion") || (device == "FUSION") || (device == "fusion"))
    || ((device == "Stratix III") || (device == "STRATIX III") || (device == "stratix iii") || (device == "StratixIII") || (device == "STRATIXIII") || (device == "stratixiii") || (device == "Titan") || (device == "TITAN") || (device == "titan") || (device == "SIII") || (device == "siii"))
    || ((device == "Cyclone III") || (device == "CYCLONE III") || (device == "cyclone iii") || (device == "CycloneIII") || (device == "CYCLONEIII") || (device == "cycloneiii") || (device == "Barracuda") || (device == "BARRACUDA") || (device == "barracuda") || (device == "Cuda") || (device == "CUDA") || (device == "cuda") || (device == "CIII") || (device == "ciii"))
    || ((device == "Stratix IV") || (device == "STRATIX IV") || (device == "stratix iv") || (device == "TGX") || (device == "tgx") || (device == "StratixIV") || (device == "STRATIXIV") || (device == "stratixiv") || (device == "StratixIIIGX") || (device == "STRATIXIIIGX") || (device == "stratixiiigx") || (device == "Stratix IV (GT/GX/E)") || (device == "STRATIX IV (GT/GX/E)") || (device == "stratix iv (gt/gx/e)") || (device == "StratixIV(GT/GX/E)") || (device == "STRATIXIV(GT/GX/E)") || (device == "stratixiv(gt/gx/e)") || (device == "Stratix IV (GX/E)") || (device == "STRATIX IV (GX/E)") || (device == "stratix iv (gx/e)") || (device == "StratixIV(GX/E)") || (device == "STRATIXIV(GX/E)") || (device == "stratixiv(gx/e)"))
    || ((device == "Arria II GX") || (device == "ARRIA II GX") || (device == "arria ii gx") || (device == "ArriaIIGX") || (device == "ARRIAIIGX") || (device == "arriaiigx") || (device == "Arria IIGX") || (device == "ARRIA IIGX") || (device == "arria iigx") || (device == "ArriaII GX") || (device == "ARRIAII GX") || (device == "arriaii gx") || (device == "Arria II") || (device == "ARRIA II") || (device == "arria ii") || (device == "ArriaII") || (device == "ARRIAII") || (device == "arriaii") || (device == "Arria II (GX/E)") || (device == "ARRIA II (GX/E)") || (device == "arria ii (gx/e)") || (device == "ArriaII(GX/E)") || (device == "ARRIAII(GX/E)") || (device == "arriaii(gx/e)") || (device == "PIRANHA") || (device == "piranha"))
    || ((device == "HardCopy III") || (device == "HARDCOPY III") || (device == "hardcopy iii") || (device == "HardCopyIII") || (device == "HARDCOPYIII") || (device == "hardcopyiii") || (device == "HCX") || (device == "hcx"))
    || ((device == "HardCopy IV") || (device == "HARDCOPY IV") || (device == "hardcopy iv") || (device == "HardCopyIV") || (device == "HARDCOPYIV") || (device == "hardcopyiv") || (device == "HCXIV") || (device == "hcxiv") || (device == "HardCopy IV (GX/E)") || (device == "HARDCOPY IV (GX/E)") || (device == "hardcopy iv (gx/e)") || (device == "HardCopyIV(GX/E)") || (device == "HARDCOPYIV(GX/E)") || (device == "hardcopyiv(gx/e)"))
    || ((device == "Cyclone III LS") || (device == "CYCLONE III LS") || (device == "cyclone iii ls") || (device == "CycloneIIILS") || (device == "CYCLONEIIILS") || (device == "cycloneiiils") || (device == "Cyclone III LPS") || (device == "CYCLONE III LPS") || (device == "cyclone iii lps") || (device == "Cyclone LPS") || (device == "CYCLONE LPS") || (device == "cyclone lps") || (device == "CycloneLPS") || (device == "CYCLONELPS") || (device == "cyclonelps") || (device == "Tarpon") || (device == "TARPON") || (device == "tarpon") || (device == "Cyclone IIIE") || (device == "CYCLONE IIIE") || (device == "cyclone iiie")))
        is_valid = 1;
    else
        is_valid = 0;

    IS_VALID_FAMILY = is_valid;
end
endfunction // IS_VALID_FAMILY


endmodule // ALTERA_DEVICE_FAMILIES
