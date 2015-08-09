GnuRadar Project 
Date: August 9, 2015
Version: 1.0.0_09-AuG-2015
Author: Ryan Seal

The pisco branch removes all java and zmq requirements, using only a command-line
interface. The main entry point of the program is located in program/Run/IonosondeRxRun

Dependencies:

1. Latest version of the boost libraries ( http://www.boost.org ).
3. Waf build system.
4. HDF5 library.
7. yaml-cpp parser.
   a. gnuradar v2.0 uses yaml-cpp 0.5.2-2
8. local deps in github repository ( see below ).

Local Dependency installation:

1. From the root project directory:
   a. git submodule init
   b. git submodule update

Primary installation:

1. Configure build system as <user> : "waf configure build -j<num_processors+1>"
2. Install executables as <root>    : "waf install"

The following steps only need to be executed once:

3. Install user configuration file as <user> : "waf setup_user"
4. Add each user to the "usrp" group for device access permission : 
   a. groupadd usrp
   b. gpasswd -a <username> usrp

Networking Notes:

For good measure, and future-proofing, add the following lines to your
/etc/services file:

gnuradar	54320/tcp 	gradar		#gnuradar status service
gnuradar	54321/tcp 	gradar		#gnuradar control service
