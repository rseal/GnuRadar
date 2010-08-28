// Copyright (c) 2010 Ryan Seal <rlseal -at- gmail.com>
//
// This file is part of GnuRadar Software.
//
// GnuRadar is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//  
// GnuRadar is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with GnuRadar.  If not, see <http://www.gnu.org/licenses/>.
INC_DIR=../include
SRC_DIR=../src
#uncomment these two for use with valgrind and gdb
DEBUG_FLAGS = #-g -O0
DEBUG_EXT = #-debug
CXX_FLAGS=`fltk-config --cxxflags`
OBJS = StringFormat CustomTab ChannelGroup ChannelInterface SettingsInterface \
       HeaderInterface DataGroup DataWindowInterface DataInterface \
       UsrpInterface
OBJS_O = $(OBJS:=.o)

all:  usrp-config $(OBJS)

StringFormat: $(SRC_DIR)/$(@:=.cxx) $(INC_DIR)/$(@:=.h)
	@echo "BUILDING ---> "$@
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$(@:=.cxx)

CustomTab: $(SRC_DIR)/$(@:=.cxx) $(INC_DIR)/$(@:=.h)
	@echo "BUILDING ---> "$@
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$(@:=.cxx)

ChannelGroup: $(SRC_DIR)/$(@:=.cxx) $(INC_DIR)/$(@:=.h)
	@echo "BUILDING ---> "$@
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx

ChannelInterface: $(SRC_DIR)/$(@:=.cxx) $(INC_DIR)/$(@:=.h) 
	@echo "BUILDING ---> "$@
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

SettingsInterface: $(SRC_DIR)/$(@:=.cxx) $(INC_DIR)/$(@:=.h) 
	@echo "BUILDING ---> "$@
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx

HeaderInterface: $(SRC_DIR)/$(@:=.cxx) $(INC_DIR)/$(@:=.h)
	@echo "BUILDING ---> "$@
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

DataGroup: $(SRC_DIR)/$(@:=.cxx) $(INC_DIR)/$(@:=.h)
	@echo "BUILDING ---> "$@
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

DataWindowInterface: $(SRC_DIR)/$(@:=.cxx) $(INC_DIR)/$(@:=.h)
	@echo "BUILDING ---> "$@
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

DataInterface: $(SRC_DIR)/$(@:=.cxx) $(INC_DIR)/$(@:=.h) $(@:=.o)
	@echo "BUILDING ---> "$@
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

UsrpInterface: $(SRC_DIR)/$(@:=.cxx) $(INC_DIR)/$(@:=.h) $(@:=.o)
	@echo "BUILDING ---> "$@
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -c $(SRC_DIR)/$@.cxx 

usrp-config: $(OBJS) $(SRC_DIR)/usrp-config.cxx 
	@echo "BUILDING ---> usrp-config"
	@g++ $(CXX_FLAGS) $(DEBUG_FLAGS) -o ../bin/usrp-config$(DEBUG_EXT) \
	$(OBJS:=.o) `fltk-config --ldflags` $(SRC_DIR)/usrp-config.cxx

clean: 
	@echo "Cleaned USRP-CONFIG Project"
	@rm -rf *~ ../bin/usrp-config usrp-config-gui.o ../bin/usrp-config-debug usrp-config-gui-debug \
	$(OBJS:=.o) ../src/*~ ../include/*~ ../../include/*~ 




