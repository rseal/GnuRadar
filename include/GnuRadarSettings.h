#ifndef GNURADAR_SETTINGS_H
#define GNURADAR_SETTINGS_H

#include <iostream>

struct GnuRadarSettings{

   bool ValidChannel(int channel){ return !(channel < 0 || channel > numChannels);}

   public:
   GnuRadarSettings():whichBoard(0),decimationRate(8),numChannels(1),
   mux(-1),mode(0),fUsbBlockSize(0),fUsbNblocks(0),fpgaFileName(""),
   firmwareFileName(""),tuningFrequency(4,0.0), ddcPhase(4,0.0),clockRate(64e6)
   {}

   int whichBoard;
   int decimationRate;
   int numChannels;
   int mux;
   int mode;
   int fUsbBlockSize;
   int fUsbNblocks;
   string fpgaFileName;
   string firmwareFileName;
   vector<double> tuningFrequency;
   int fpgaMode;
   vector<double> ddcPhase;
   int format;
   double clockRate;

   void Tune(int channel, double frequency){
      if(ValidChannel(channel)) tuningFrequency[channel]=frequency;
      else std::cout << "GnuRadarSettings: Tune Error - invalid channel number " << std::endl;
   }

   void Phase(int channel, double phase){
      if(ValidChannel(channel)) ddcPhase[channel]=phase;
   }

   const double& Tune(int channel){
      return ValidChannel(channel) ? tuningFrequency[channel] : 0;
   }

   const double& Phase(int channel){
      return ValidChannel(channel) ? ddcPhase[channel] : 0;
   }

};

#endif
