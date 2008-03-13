#ifndef GNURADAR_SETTINGS_H
#define GNURADAR_SETTINGS_H

#include <iostream>

struct GnuRadarSettings{

    bool ValidChannel(int channel){ return !(channel < 0 || channel > numChannels);}

public:
    GnuRadarSettings():whichBoard(0),decimationRate(8),numChannels(1),
		       mux(-1),mode(0),fUsbBlockSize(0),fUsbNblocks(0),
		       fpgaFileName(""),firmwareFileName(""),clockRate(64e6)
	{
	    for(int i=0; i<4; ++i){
		tuningFrequency[i] = 0;
		ddcPhase[i] = 0;
	    }
	}

    int whichBoard;
    int decimationRate;
    int numChannels;
    int mux;
    int mode;
    int fUsbBlockSize;
    int fUsbNblocks;
    string fpgaFileName;
    string firmwareFileName;
    double tuningFrequency[4];
    int fpgaMode;
    int ddcPhase[4];
    int format;
    int clockRate;
    
    void Tune(int channel, int frequency){
	if(ValidChannel(channel)) tuningFrequency[channel]=frequency;
	else std::cout << "GnuRadarSettings: Tune Error - invalid channel number " << std::endl;
    }

    void Phase(int channel, int phase){
	if(ValidChannel(channel)) ddcPhase[channel]=phase;
    }

    const int& Tune(int channel){
	return ValidChannel(channel) ? tuningFrequency[channel] : 0;
    }

    const int& Phase(int channel){
	return ValidChannel(channel) ? ddcPhase[channel] : 0;
    }

};

#endif
