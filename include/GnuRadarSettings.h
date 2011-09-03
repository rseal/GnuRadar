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
#ifndef GNURADAR_SETTINGS_H
#define GNURADAR_SETTINGS_H

#include <iostream>
#include <vector>

namespace gnuradar{


struct GnuRadarSettings {

    bool ValidChannel ( int channel ) {
        return ! ( channel < 0 || channel > numChannels );
    }

public:
    GnuRadarSettings() : whichBoard ( 0 ), decimationRate ( 8 ), numChannels ( 1 ),
            mux ( -1 ), mode ( 0 ), fUsbBlockSize ( 0 ), fUsbNblocks ( 0 ), fpgaFileName ( "" ),
            firmwareFileName ( "" ), tuningFrequency ( 4, 0.0 ), ddcPhase ( 4, 0.0 ), clockRate ( 64e6 ) {}

    int whichBoard;
    int decimationRate;
    int numChannels;
    int mux;
    int mode;
    int fUsbBlockSize;
    int fUsbNblocks;
    std::string fpgaFileName;
    std::string firmwareFileName;
    std::vector<double> tuningFrequency;
    int fpgaMode;
    std::vector<double> ddcPhase;
    int format;
    double clockRate;

    void Tune ( int channel, double frequency ) {
        if ( ValidChannel ( channel ) ) tuningFrequency[channel] = frequency;
        else std::cout << "GnuRadarSettings: Tune Error - invalid channel number " << std::endl;
    }

    void Phase ( int channel, double phase ) {
        if ( ValidChannel ( channel ) ) ddcPhase[channel] = phase;
        else std::cout << "GnuRadarSettings: Phase Error - invalid channel number " << std::endl;
    }

    const double& Tune ( int channel ) {
        return ValidChannel ( channel ) ? tuningFrequency[channel] : 0;
    }

    const double& Phase ( int channel ) {
        return ValidChannel ( channel ) ? ddcPhase[channel] : 0;
    }

};
   typedef boost::shared_ptr<GnuRadarSettings> GnuRadarSettingsPtr;
};

#endif
