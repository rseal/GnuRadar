INCLUDE_DIR=../include
SRC_DIR=../src
#uncomment these two for use with valgrind and gdb
DEBUG_FLAGS = #-g -O0
DEBUG_EXT = #-debug
OBJS = ChannelInterface.o UsrpInterface.o SettingsInterface.o ChannelGroup.o CustomTab.o

all: CustomTab SettingsInterface ChannelGroup ChannelInterface UsrpInterface usrp-config

CustomTab: $(SRC_DIR)/CustomTab.cxx $(INCLUDE_DIR)/CustomTab.h
	@echo "BUILDING ---> CustomTab.o"
	@g++ `fltk-config --cxxflags` $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx

SettingsInterface: $(SRC_DIR)/SettingsInterface.cxx $(INCLUDE_DIR)/SettingsInterface.h 
	@echo "BUILDING ---> SettingsInterface.o"
	@g++ `fltk-config --cxxflags` $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx

ChannelGroup: $(SRC_DIR)/ChannelGroup.cxx $(INCLUDE_DIR)/ChannelGroup.h 
	@echo "BUILDING ---> ChannelGroup.o"
	@g++ `fltk-config --cxxflags` $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx

ChannelInterface: $(SRC_DIR)/ChannelInterface.cxx $(INCLUDE_DIR)/ChannelInterface.h 
	@echo "BUILDING ---> ChannelInterface.o"
	@g++ `fltk-config --cxxflags` $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

UsrpInterface: $(SRC_DIR)/UsrpInterface.cxx $(INCLUDE_DIR)/UsrpInterface.h
	@echo "BUILDING ---> usrp-config-gui.o"
	@g++ `fltk-config --cxxflags` $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

usrp-config: $(SRC_DIR)/usrp-config.cxx $(SRC_DIR)/UsrpInterface.cxx $(INCLUDE_DIR)/UsrpInterface.h \
	../../include/UsrpParameters.h
	@echo "BUILDING ---> usrp-config"
	@g++ `fltk-config --cxxflags` $(DEBUG_FLAGS) -o ../bin/usrp-config$(DEBUG_EXT) \
	$(OBJS) `fltk-config --ldflags` $(SRC_DIR)/usrp-config.cxx

clean: 
	@echo "Cleaned USRP-CONFIG Project"
	@rm -rf *~ ../bin/usrp-config usrp-config-gui.o ../bin/usrp-config-debug usrp-config-gui-debug \
	$(OBJS) ../src/*~ ../include/*~ ../../include/*~ 




