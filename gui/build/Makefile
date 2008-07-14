INCLUDE_DIR=../include
SRC_DIR=../src

all: channel-interface-gui usrp-config-gui usrp-config
debug: usrp-config-gui-debug usrp-config-debug

usrp-config-gui: $(SRC_DIR)/usrp-config-gui.cxx $(INCLUDE_DIR)/usrp-config-gui.h
	g++ `fltk-config --cxxflags` -c $(SRC_DIR)/usrp-config-gui.cxx 

usrp-config-gui-debug: $(SRC_DIR)/usrp-config-gui.cxx $(INCLUDE_DIR)/usrp-config-gui.h
	g++ `fltk-config --cxxflags` -g -O0 -c $(SRC_DIR)/usrp-config-gui.cxx 

usrp-config: $(SRC_DIR)/usrp-config.cxx $(SRC_DIR)/usrp-config-gui.cxx $(INCLUDE_DIR)/usrp-config-gui.h \
	../../include/UsrpParameters.h
	g++ `fltk-config --cxxflags` -o ../bin/usrp-config usrp-config-gui.o ChannelInterface.o `fltk-config --ldflags` \
	$(SRC_DIR)/usrp-config.cxx

channel-interface-gui: $(SRC_DIR)/ChannelInterface.cxx $(INCLUDE_DIR)/ChannelInterface.h 
	g++ `fltk-config --cxxflags` -c $(SRC_DIR)/ChannelInterface.cxx

usrp-config-debug: $(SRC_DIR)/usrp-config.cxx $(SRC_DIR)/usrp-config-gui.cxx $(INCLUDE_DIR)/usrp-config-gui.h
	g++ `fltk-config --cxxflags` -O0 -g -o usrp-config-debug usrp-config-gui.o `fltk-config --ldflags` \
	$(SRC_DIR)/usrp-config.cxx

clean: 
	@echo "Cleaned USRP-CONFIG Project"
	@rm -rf *~ ../bin/usrp-config usrp-config-gui.o ../bin/usrp-config-debug usrp-config-gui-debug \
	ChannelInterface.o ../src/*~ ../include/*~ ../../include/*~



