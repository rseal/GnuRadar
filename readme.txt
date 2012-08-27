GnuRadar Project 
Date: August 22, 2012
Version: 3.0.0_22-AuG-2012
Author: Ryan Seal

Introduction:

The GnuRadar project is a derivative work of the original USRP software
project by Ettus. This software features the following:

1. External trigger for pulsed radar recording.
2. Data tags inserted into the data stream for proper data alignment.
3. HDF5-based data recording. 
4. Parameter based configuration program for radar mode configuration.
5. CLI-based run-time software to start/stop data recording. 
6. C++ interface currently functional with the Basic RX daughterboard.
7. Both command line and GUI-based programs for configuration,verification,
   data collection.

Programs:

1. gradar-configure : Configuration GUI to setup the receiver.
2. gradar-verify: Validation tool to ensure that both receiver and pulse
   generator are properly synchronized.
3. gradar-run : Data collection tool for the USRP receiver.
4. gradar-replay: Data replay tool for HDF5 files. Requires rtPlotter for
   display. 

Dependencies:

1. Latest version of the boost libraries ( http://www.boost.org ).
2. Sun Java Version 1.6
3. Waf build system.
4. HDF5 library.
5. protobuf ( i.e google protocol buffers )
6. zeromq ( a.k.a 0MQ )
7. local deps in github repository ( see below ).

Local Dependency installation:

1. From the root project directory:
   a. git submodule init
   b. git submodule update
   c. cd deps/hdf5r, login as root, run "waf install_headers".
   d. cd deps/clp, login as root, run "waf install_headers".


Primary installation:

1. Configure build system as <user> : "waf configure"
2. Install headers as <root>        : "waf install_headers"
3. Build project as <user>          : "waf build -j<num_threads>"
4. Install executables as <root>    : "waf install"

The following steps only need to be executed once:

5. Install user configuration file as <user> : "waf setup_user"
6. Add each user to the "usrp" group for device access permission : 
   a. groupadd usrp
   b. gpasswd -a <username> usrp

Developer Notes:

Use "waf install_symlinks" to setup a link to header files in /usr/local/include/gnuradar.

Networking Notes:

For good measure, and future-proofing, add the following lines to your
/etc/services file:

gnuradar	54321/udp 	gradar		#gnuradar comm service
gnuradar	54321/tcp 	gradar		#gnuradar comm service
