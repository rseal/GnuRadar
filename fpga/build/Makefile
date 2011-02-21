TOPLEVEL=usrp_trigger.v
PART=EP1C12Q240C8
FAMILY=CYCLONE
FMAX=64MHz
REV=1
PROJECT=usrp_trigger
INC=../src
SOURCE_FILES=$(INC)/acc.v $(INC)/adc_interface.v $(INC)/atr_delay.v $(INC)/bidir_reg.v  \
		$(INC)/cic_5stage.v $(INC)/cic_msb_adjust.v $(INC)/cic_integrator.v $(INC)/cic_differentiator.v \
		$(INC)/clk_divider.v $(INC)/coeff_rom.v \
		$(INC)/cordic_12stage.v $(INC)/cordic_new_stage.v $(INC)/cordic_shift_adder.v $(INC)/ddc.v \
		$(INC)/fifo.v $(INC)/master_cntrl.v \
		$(INC)/mult.v $(INC)/phase_acc.v $(INC)/ram16_2sum.v $(INC)/ram16.v \
		$(INC)/rx_chain.v $(INC)/rx_dcoffset.v \
		$(INC)/serial_io.v $(INC)/setting_reg.v $(INC)/data_tag.v \
		$(INC)/sign_extend.v $(INC)/strobe_gen.v  

###################################################################
# Project Configuration: 
# 
# Specify the name of the design (project), the Quartus II Settings
# File (.qsf), and the list of source files used.
###################################################################

ASSIGNMENT_FILES = $(PROJECT).qpf $(PROJECT).qsf 

###################################################################
# Main Targets
#
# all: build everything
# clean: remove output files and database
###################################################################

all: smart.log $(PROJECT).asm.rpt $(PROJECT).tan.rpt 

clean:
	rm -rf *.rpt *.chg smart.log *.htm *.eqn \
	*.pin *.sof *.pof db *.summary *.smsg *~ \
	*.done greybox_tmp incremental_db simulation \
	*.rbf 

map: smart.log $(PROJECT).map.rpt
fit: smart.log $(PROJECT).fit.rpt
asm: smart.log $(PROJECT).asm.rpt
#tan: smart.log $(PROJECT).tan.rpt
smart: smart.log

###################################################################
# Executable Configuration
###################################################################

MAP_ARGS = --family=$(FAMILY)
FIT_ARGS = --part=$(PART)
ASM_ARGS =
TAN_ARGS =

###################################################################
# Target implementations
###################################################################

STAMP = echo done >

$(PROJECT).map.rpt: map.chg $(SOURCE_FILES) 
	quartus_map $(MAP_ARGS) $(PROJECT)
	$(STAMP) fit.chg

$(PROJECT).fit.rpt: fit.chg $(PROJECT).map.rpt
	quartus_fit $(FIT_ARGS) $(PROJECT)
	$(STAMP) asm.chg
	$(STAMP) tan.chg

$(PROJECT).asm.rpt: asm.chg $(PROJECT).fit.rpt
	quartus_asm $(ASM_ARGS) $(PROJECT)

$(PROJECT).tan.rpt: tan.chg $(PROJECT).fit.rpt
	quartus_tan $(TAN_ARGS) $(PROJECT) 

smart.log: $(ASSIGNMENT_FILES)
	quartus_sh --determine_smart_action $(PROJECT) > smart.log

###################################################################
# Project initialization
###################################################################

$(ASSIGNMENT_FILES):
	quartus_sh --prepare $(PROJECT)

map.chg:
	$(STAMP) map.chg
fit.chg:
	$(STAMP) fit.chg
tan.chg:
	$(STAMP) tan.chg
asm.chg:
	$(STAMP) asm.chg


