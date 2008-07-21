INC_DIR=../include
SRC_DIR=../src
#uncomment these two for use with valgrind and gdb
DEBUG_FLAGS = #-g -O0
DEBUG_EXT = #-debug
CXX_FLAGS=`fltk-config --cxxflags`
OBJS = ChannelInterface.o UsrpInterface.o SettingsInterface.o ChannelGroup.o CustomTab.o

all: CustomTab SettingsInterface ChannelGroup ChannelInterface UsrpInterface usrp-config

CustomTab: $(SRC_DIR)/CustomTab.cxx $(INC_DIR)/CustomTab.h
	@echo "BUILDING ---> CustomTab.o"
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx

SettingsInterface: $(SRC_DIR)/SettingsInterface.cxx $(INC_DIR)/SettingsInterface.h 
	@echo "BUILDING ---> SettingsInterface.o"
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx

ChannelGroup: $(SRC_DIR)/ChannelGroup.cxx $(INC_DIR)/ChannelGroup.h 
	@echo "BUILDING ---> ChannelGroup.o"
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx

ChannelInterface: $(SRC_DIR)/ChannelInterface.cxx $(INC_DIR)/ChannelInterface.h 
	@echo "BUILDING ---> ChannelInterface.o"
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

UsrpInterface: $(SRC_DIR)/UsrpInterface.cxx $(INC_DIR)/UsrpInterface.h
	@echo "BUILDING ---> usrp-config-gui.o"
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

usrp-config: $(SRC_DIR)/usrp-config.cxx $(SRC_DIR)/UsrpInterface.cxx $(INC_DIR)/UsrpInterface.h \
	../../include/UsrpParameters.h $(OBJS)
	@echo "BUILDING ---> usrp-config"
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -o ../bin/usrp-config$(DEBUG_EXT) \
	$(OBJS) `fltk-config --ldflags` $(SRC_DIR)/usrp-config.cxx

clean: 
	@echo "Cleaned USRP-CONFIG Project"
	@rm -rf *~ ../bin/usrp-config usrp-config-gui.o ../bin/usrp-config-debug usrp-config-gui-debug \
	$(OBJS) ../src/*~ ../include/*~ ../../include/*~ 




