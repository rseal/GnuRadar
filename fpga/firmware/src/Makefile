INC=-I../include
DEFINES = -DHAVE_USRP2
XCC=sdcc -mmcs51 --no-xinit-opt
XAS=asx8051 -plosgff

MEMOPTS = 										\
	--code-loc 0x0000 --code-size 0x1800 --xram-loc 0x1800 --xram-size 0x0800 	\
	-Wl '-b USBDESCSEG = 0xE000'

LIBDEP = delay.rel fx2utils.rel i2c.rel isr.rel timer.rel usb_common.rel

LINKOPTS = $(MEMOPTS) 

STARTUP = _startup.rel

EEPROM_BOOT_OBJS = eeprom_boot.rel eeprom_init.rel $(STARTUP)
BLINK_LEDS_OBJS = blink_leds.rel usrp_common.rel board_specific.rel spi.rel usb_descriptors.rel $(STARTUP)
CHECK_MDELAY_OBJS = check_mdelay.rel usrp_common.rel board_specific.rel spi.rel delay.rel $(STARTUP)
CHECK_UDELAY_OBJS = check_udelay.rel usrp_common.rel board_specific.rel spi.rel delay.rel $(STARTUP)

# these files are in lib in real usrp build
LIB_OBJS = fx2utils.rel i2c.rel timer.rel delay.rel isr.rel usb_common.rel usrp_main.rel

USRP_OBJS = 								\
	vectors.rel 							\
	usrp_main.rel usrp_common.rel board_specific.rel		\
	fpga_load.rel fpga_rev3.rel init_gpif.rel usrp_gpif.rel 	\
	usb_descriptors.rel spi.rel eeprom_io.rel $(STARTUP)

 all: 	usrp_main.ihx blink_leds.ihx check_mdelay.ihx check_udelay.ihx	\
	eeprom_boot.ihx			

eeprom_boot.ihx: $(EEPROM_BOOT_OBJS) $(LIBDEP)
	$(XCC) $(MEMOPTS) -o $@ $(EEPROM_BOOT_OBJS)

blink_leds.ihx: $(BLINK_LEDS_OBJS) $(LIBDEP)
	$(XCC) $(MEMOPTS) -o $@ $(BLINK_LEDS_OBJS)

check_mdelay.ihx: $(CHECK_MDELAY_OBJS) $(LIBDEP)
	$(XCC) $(MEMOPTS) -o $@ $(CHECK_MDELAY_OBJS)

check_udelay.ihx: $(CHECK_UDELAY_OBJS) $(LIBDEP)
	$(XCC) $(MEMOPTS) -o $@ $(CHECK_UDELAY_OBJS)

# std.ihx: $(USRP_OBJS) $(LIB_OBJS)
# 	$(XCC) $(LINKOPTS) -o $@ $(USRP_OBJS)

usrp_main.ihx: $(USRP_OBJS) $(LIB_OBJS)
	$(XCC) $(LINKOPTS) -o $@ $^

%.rel: %.c 
	$(XCC) $(INC) $(DEFINES) -c -o $@ $<

%.rel: %.a51
	test -f `basename '$<'` || ln -s '$<' .
	$(XAS) `basename '$<'`

clean:
	rm -f *.asm *.ihx *.lnk *.lst *.map *.mem *.rel *.rst *.sym *~

install:
	cp usrp_main.ihx /usr/local/share/usrp/rev4/std_new.ihx
#usrp_main.rel: ../include/usrp_gpif_inline.h


