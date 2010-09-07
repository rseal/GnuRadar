GnuRadar Project 
Date: August 29, 2010
Version: 1.0.0_08-AUG-2010
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

Currently, there are 4 primary programs of interest:

1. gradar-configure : Configuration GUI to setup the receiver.
2. gradar-verify: Validation tool to ensure that both receiver and pulse
   generator are properly synchronized.
3. gradar-run : Data collection tool for the USRP receiver.
4. gradar-replay: Data replay tool for HDF5 files. Requires rtPlotter for
   display. 

Dependencies:

1. Latest version of the boost libraries ( http://www.boost.org ).
2. Latest version of gnuradio ( http://gnuradio.org/git/gnuradio.git ).
3. Latest scons ( http://www.scons.org ).
4. Latest version of Sun Java Java Runtime Environment 
   ( http://www.oracle.com/technetwork/java/javase/downloads/index.html#need).

Optional:

1. Latest version of boost-book ( http://www.boost.org/doc/libs/1_44_0/doc/html/boostbook.html ).


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

2. From the root project directory:
   a. git submodule init
   b. git submodule update
   c. cd deps/hdf5r, login as root, run "scons install-headers".
   d. cd deps/clp, login as root, run "scons install-headers".

3. The tinyxml project is included under the deps directory. CD to this
   directory, run "scons", login as root, run "scons install". This will
   install the necessary headers and the compiled library. 

4. After successfully installing gnuradio and all other dependencies, simply
   go to the root project directory and run "scons", login as root and run
   "scons install". This will install all binaries in /usr/local/bin by
   default ( edit the SConstruct file if you're not happy with that ). All
   binaries are prefixed with "gradar-", so you can type "gradar" followed by
   TAB a few times to see what programs are available.

Developer Notes:

Any time headers are modified, added, or removed; you must run 'scons
install-headers' to refresh the header location. It's actually much easier to
write a short bash script to create soft links to the include directory. Any
changes using this method will be picked up by scons and udpated as needed.
