INCLUDE_DIR=../include
SRC_DIR=../src

all: settings-interface-gui channel-group-gui channel-interface-gui usrp-config-gui usrp-config
debug: usrp-config-gui-debug usrp-config-debug

usrp-config-gui: $(SRC_DIR)/usrp-config-gui.cxx $(INCLUDE_DIR)/usrp-config-gui.h
	g++ `fltk-config --cxxflags` -c $(SRC_DIR)/usrp-config-gui.cxx 

usrp-config-gui-debug: $(SRC_DIR)/usrp-config-gui.cxx $(INCLUDE_DIR)/usrp-config-gui.h
	g++ `fltk-config --cxxflags` -g -O0 -c $(SRC_DIR)/usrp-config-gui.cxx 

usrp-config: $(SRC_DIR)/usrp-config.cxx $(SRC_DIR)/usrp-config-gui.cxx $(INCLUDE_DIR)/usrp-config-gui.h \
	../../include/UsrpParameters.h
	g++ `fltk-config --cxxflags` -o ../bin/usrp-config usrp-config-gui.o ChannelInterface.o \
	SettingsInterface.o ChannelGroup.o `fltk-config --ldflags` $(SRC_DIR)/usrp-config.cxx

channel-group-gui: $(SRC_DIR)/ChannelGroup.cxx $(INCLUDE_DIR)/ChannelGroup.h 
	g++ `fltk-config --cxxflags` -c $(SRC_DIR)/ChannelGroup.cxx

channel-interface-gui: $(SRC_DIR)/ChannelInterface.cxx $(INCLUDE_DIR)/ChannelInterface.h 
	g++ `fltk-config --cxxflags` -c $(SRC_DIR)/ChannelInterface.cxx 

settings-interface-gui: $(SRC_DIR)/SettingsInterface.cxx $(INCLUDE_DIR)/SettingsInterface.h 
	g++ `fltk-config --cxxflags` -c $(SRC_DIR)/SettingsInterface.cxx

usrp-config-debug: $(SRC_DIR)/usrp-config.cxx $(SRC_DIR)/usrp-config-gui.cxx $(INCLUDE_DIR)/usrp-config-gui.h
	g++ `fltk-config --cxxflags` -O0 -g -o usrp-config-debug usrp-config-gui.o `fltk-config --ldflags` \
	$(SRC_DIR)/usrp-config.cxx

clean: 
	@echo "Cleaned USRP-CONFIG Project"
	@rm -rf *~ ../bin/usrp-config usrp-config-gui.o ../bin/usrp-config-debug usrp-config-gui-debug \
	ChannelInterface.o ../src/*~ ../include/*~ ../../include/*~ SettingsInterface.o ChannelGroup.o




