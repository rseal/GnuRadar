GnuRadar Project 
Date: August 08, 2010
Version: 0.99_08-AUG-2010
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

Programs:

Currently, there are 4 primary programs of interest:

1. gradar-config: Configuration GUI to setup the receiver.
2. gradar-verify: Validation tool to ensure that both receiver and pulse
   generator are properly synchronized.
3. gradar-run: Data collection tool for the USRP receiver.
4. gradar-replay: Data replay tool for HDF5 files. Requires rtPlotter for
   display. 

Dependencies:

1. Latest version of the boost libraries.
2. Latest version of gnuradio.
3. Latest version of boost-book ( optional ).
4. Latest version of FLTK1.
5. Latest CommandLineParser library ( see local repo ).
6. Latest HDF5R library ( see local repo ).
7. Latest scons ( python-based build tool ).

Installation:

GNURadio:

To help ease gnuradio installation difficulties, a configuration script is
located in the scripts directory. To install gnuradio, do the following:

1. As root, cd to /usr/local and run 
      "git clone http://gnuradio.org/git/gnuradio.git"
2. Copy the gnuradar_configure.sh script to /usr/local/gnuradio.
3. Cd into /usr/local/gnuradio and run "./gnuradar_configure.sh"

GNURadar:

1. First you will have to install the gnuradar development headers. Go to the
   root project directory, login in as root, and type 'scons install-headers'.

2. After successfully installing gnuradio and all other dependencies, simply
   go to the root project directory and run "scons". All executables will be
   placed in the root's bin directory. Eventually these will be installed in
   /usr/local/bin when code development begins to stabilize.
   'scons'.

Developer Notes:

Any time headers are modified, added, or removed; you must run 'scons
install-headers' to refresh the header location. 

