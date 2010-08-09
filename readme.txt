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
2. Latest version of boost jam ( bjam ).
3. Latest version of boost-book ( optional ).
4. Latest version of FLTK1.
5. Latest CommandLineParser library ( see local repo ).
6. Latest HDF5R library ( see local repo ).
7. Latest scons ( python-based build tool ).

Installation:

1. Currently you can build the system using boost-build (bjam) by running the
command in the root directory. This will go away very soon.
2. The newer build system uses scons. Go to the 'programs' directory and type
   'scons'.

A new java-based wrapper has been written for the gradar-verify program. I've
not had the chance to create an official executable just yet, but you can use
the program by running 'java -jar gradar-verify.jar' if you want to use it. 

TODO:
1. Finish scons implementation.
2. Create install script for binaries.
3. Create a script to run java packages.

