INC_DIR=../include
SRC_DIR=../src
#uncomment these two for use with valgrind and gdb
DEBUG_FLAGS = #-g -O0
DEBUG_EXT = #-debug
CXX_FLAGS=`fltk-config --cxxflags`
OBJS = CustomTab ChannelGroup ChannelInterface SettingsInterface \
       HeaderInterface DataGroup DataWindowInterface DataInterface \
       UsrpInterface

all:  usrp-config CustomTab ChannelGroup ChannelInterface \
      SettingsInterface HeaderInterface DataGroup \
      DataWindowInterface DataInterface UsrpInterface 

CustomTab: $(SRC_DIR)/CustomTab.cxx $(INC_DIR)/CustomTab.h
	@echo "BUILDING ---> "$@.o
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx

ChannelGroup: $(SRC_DIR)/ChannelGroup.cxx $(INC_DIR)/ChannelGroup.h 
	@echo "BUILDING ---> "$@.o
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx

ChannelInterface: $(SRC_DIR)/ChannelInterface.cxx $(INC_DIR)/ChannelInterface.h 
	@echo "BUILDING ---> "$@.o
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

SettingsInterface: $(SRC_DIR)/SettingsInterface.cxx $(INC_DIR)/SettingsInterface.h 
	@echo "BUILDING ---> "$@.o
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx

HeaderInterface: $(SRC_DIR)/HeaderInterface.cxx $(INC_DIR)/HeaderInterface.h
	@echo "BUILDING ---> "$@.o
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

DataGroup: $(SRC_DIR)/DataGroup.cxx $(INC_DIR)/DataGroup.h
	@echo "BUILDING ---> "$@.o
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

DataWindowInterface: $(SRC_DIR)/DataWindowInterface.cxx $(INC_DIR)/DataWindowInterface.h 
	@echo "BUILDING ---> "$@.o
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

DataInterface: $(SRC_DIR)/DataInterface.cxx $(INC_DIR)/DataInterface.h 
	@echo "BUILDING ---> "$@.o
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

UsrpInterface: $(SRC_DIR)/UsrpInterface.cxx $(INC_DIR)/UsrpInterface.h 
	@echo "BUILDING ---> "$@.o
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

usrp-config: $(SRC_DIR)/usrp-config.cxx $(OBJS)
	@echo "BUILDING ---> usrp-config"
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -o ../bin/usrp-config$(DEBUG_EXT) \
	$(OBJS:=.o) `fltk-config --ldflags` $(SRC_DIR)/usrp-config.cxx

clean: 
	@echo "Cleaned USRP-CONFIG Project"
	@rm -rf *~ ../bin/usrp-config usrp-config-gui.o ../bin/usrp-config-debug usrp-config-gui-debug \
	$(OBJS) ../src/*~ ../include/*~ ../../include/*~ 




