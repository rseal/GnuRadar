
all: usrp-config-gui usrp-config
debug: usrp-config-gui-debug usrp-config-debug

usrp-config-gui: usrp-config-gui.cxx usrp-config-gui.h
	g++ `fltk-config --cxxflags` -c usrp-config-gui.cxx 

usrp-config-gui-debug: usrp-config-gui.cxx usrp-config-gui.h
	g++ `fltk-config --cxxflags` -g -O0 -c usrp-config-gui.cxx 

usrp-config: usrp-config.cxx usrp-config-gui.cxx usrp-config-gui.h
	g++ `fltk-config --cxxflags` -o usrp-config usrp-config-gui.o `fltk-config --ldflags` usrp-config.cxx

usrp-config-debug: usrp-config.cxx usrp-config-gui.cxx usrp-config-gui.h
	g++ `fltk-config --cxxflags` -O0 -g -o usrp-config-debug usrp-config-gui.o `fltk-config --ldflags` usrp-config.cxx

clean: 
	@echo "Cleaned USRP-CONFIG Project"
	@rm -rf *~ usrp-config usrp-config-gui.o usrp-config-debug usrp-config-gui-debug



