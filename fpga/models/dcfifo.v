// Copyright (C) 1991-2009 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.
module dcfifo (
	data,
	rdclk,
	wrclk,
	aclr,
	rdreq,
	wrreq,
`ifdef POST_FIT
	_unassoc_inputs_,
	_unassoc_outputs_,
`endif
	rdfull,
	wrfull,
	rdempty,
	wrempty,
	rdusedw,
	wrusedw,
	q
);

	parameter lpm_width = 1;
	parameter lpm_widthu = 1;
	parameter lpm_numwords = 1;
	parameter lpm_showahead = "OFF";
	parameter lpm_hint = "UNUSED";
	parameter underflow_checking = "ON";
	parameter overflow_checking = "ON";
	parameter delay_rdusedw = 1;
	parameter delay_wrusedw = 1;
	parameter rdsync_delaypipe = 3;
	parameter wrsync_delaypipe = 3;
	parameter use_eab = "ON";
	parameter clocks_are_synchronized = "FALSE";
	parameter lpm_type = "dcfifo";
	parameter intended_device_family = "UNUSED";
	parameter add_ram_output_register = "OFF";
`ifdef POST_FIT
	parameter _unassoc_inputs_width_ = 1;
	parameter _unassoc_outputs_width_ = 1;
`endif
	parameter add_usedw_msb_bit = "OFF";
	parameter write_aclr_synch = "OFF";
	parameter add_width = 1;

	input [lpm_width-1:0] data;
	input rdclk;
	input wrclk;
	input wrreq;
	input rdreq;
	input aclr;
	// Extra bus for connecting signals unassociated with defined ports
`ifdef POST_FIT
	input [ _unassoc_inputs_width_ - 1 : 0 ] _unassoc_inputs_;
	output [ _unassoc_outputs_width_ - 1 : 0 ] _unassoc_outputs_;
`endif
	output rdfull;
	output wrfull;
	output rdempty;
	output wrempty;
	output [lpm_widthu-1:0] rdusedw;
	output [lpm_widthu-1:0] wrusedw;
	output [lpm_width-1:0] q;

endmodule
