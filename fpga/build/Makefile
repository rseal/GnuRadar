all: map fit asm tan

TOPLEVEL=usrp_trigger.v
PART=EP1C12Q240C8
FAMILY=CYCLONE
FMAX=64MHz
REV=usrp_trigger
PROJECT=usrp_trigger.qpf
INC=../src

SOURCE_FILES=$(INC)/acc.v $(INC)/adc_interface.v $(INC)/atr_delay.v $(INC)/bidir_reg.v  \
		$(INC)/cic_decim.v $(INC)/cic_dec_shifter.v $(INC)/clk_divider.v coeff_rom.v \
		$(INC)/cordic_stage.v $(INC)/cordic.v $(INC)/ddc.v $(INC)/dpram.v $(INC)/duc.v \
		$(INC)/ext_fifo.v $(INC)/halfband_decim.v $(INC)/io_pins.v $(INC)/master_control_multi.v \
		$(INC)/master_control.v $(INC)/mult.v $(INC)/phase_acc.v $(INC)/ram16_2port.v \
		$(INC)/ram16_2sum.v $(INC)/ram16.v $(INC)/ram32_2sum.v $(INC)/ram32.v $(INC)/ram64.v \
		$(INC)/ram.v $(INC)/rssi.v $(INC)/rx_buffer_ge.v $(INC)/rx_buffer.v $(INC)/rx_buffer.v.bak \
		$(INC)/rx_chain.v $(INC)/rx_dcoffset.v $(INC)/serial_io.v $(INC)/setting_reg.v \
		$(INC)/sign_extend.v $(INC)/strobe_gen_new.v $(INC)/strobe_gen.v 

map: $(TOP_LEVEL)
	quartus_map --source=$(TOPLEVEL) -c $(REV) \
	            --family=$(FAMILY) --enable_register_retiming=on --optimize=balanced \
		    --restructure_multiplexers=auto --state_machine_encoding=one_hot \
		    $(PROJECT)

fit: $(TOP_LEVEL)
	quartus_fit --part=$(PART) --fmax=$(FMAX) -c $(REV) --parallel=2 --read_settings_files=on $(PROJECT)

asm: $(TOP_LEVEL)
	quartus_asm --read_settings_files=on $(PROJECT)
	mv usrp_trigger.rbf ../bin

tan: $(TOP_LEVEL)
	quartus_tan --read_settings_files=on $(PROJECT)

install:
	cp ../bin/usrp_trigger.rbf /usr/local/share/usrp/rev4/
clean:
	rm -rf *.rpt *.chg smart.log *.htm *.eqn *.pin *.sof *.pof db *.smsg *.summary *~ ../src/*~ incremental_db


