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
#ifndef CONFIG_FILE_H
#define CONFIG_FILE_H

#include <gnuradar/Units.h>
#include <gnuradar/GnuRadarTypes.hpp>
#include <gnuradar/xml/XmlConfigParser.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/algorithm/string/case_conv.hpp>
#include <boost/cstdint.hpp>
#include <cmath>
#include <vector>
#include <map>

using boost::lexical_cast;
using std::vector;
using std::endl;
using std::cout;

///channel structure
struct Channel {
public:
    double ddc;
    int ddcUnits;
    double phase;
    double phaseUnits;
};

///window structure
struct Window {
public:
    string name;
    unsigned int start;
    unsigned int stop;
    double units;

    unsigned int Size() {
        return stop - start;
    }
};

///main structure
struct ConfigFile {
    double sampleRate_;
    int numChannels_;
    float ipp_;
    int numWindows_;
    int decimation_;
    int ippLength_;
    int windowLength_;
    double outputRate_;
    double ippUnits_;
    string fpgaImage_;
    string dataFileBaseName_;
    vector<Channel> channels_;
    vector<Window> windows_;

    XmlConfigParser parser_;

    //window conversion factor
    const double WCF ( const string& units ) {

        std::map<std::string, double> map;
        map["samples"] = 1.0;
        map["usec"] = 1e-6;
        map["km"] = 2e-5 / 3.0;

        string unitStr = units;
        boost::to_lower ( unitStr );

        std::map<std::string, double>::iterator iter =
            map.find ( unitStr );

        if ( iter == map.end() ) {
            throw std::runtime_error (
                " Failed to convert window units " + units );
        }

        return iter->second;
    }

public:

    explicit ConfigFile ( const string& fileName ) :
            windowLength_ ( 0 ), parser_ ( fileName ) {

        Units units;

        sampleRate_       = parser_.Get<double> ( "sample_rate" );
        decimation_       = parser_.Get<int> ( "decimation" );
        outputRate_       = sampleRate_ / decimation_;
        numChannels_      = parser_.Get<int> ( "num_channels" );
        numWindows_       = parser_.Get<int> ( "num_windows" );
        ippLength_        = parser_.Get<int> ( "ipp" );
        ippUnits_         = units ( parser_.Get<string> ( "ipp_units" ) );
        ipp_              = ippLength_ * ippUnits_;
        fpgaImage_        = parser_.Get<string> ( "fpga_image_file" );
        dataFileBaseName_ = parser_.Get<string> ( "base_file_name" );

        string idx;
        double factor;

        for ( int i = 0; i < gnuradar::USRP_MAX_CHANNELS; ++i ) {
            Channel ch;
            idx           = lexical_cast<string> ( i );
            ch.ddc        = parser_.Get<double> ( "frequency_" + idx );
            ch.ddcUnits   = units (
                                parser_.Get<string> ( "frequency_units_" + idx ) );
            ch.ddc       *= ch.ddcUnits;
            ch.phase      = parser_.Get<double> ( "phase_" + idx );
            ch.phaseUnits = units ( parser_.Get<string> ( "phase_units_" + idx ) );
            //phase in degrees
            ch.phase     *= ch.phaseUnits;
            channels_.push_back ( ch );
        }

        for ( int i = 0; i < numWindows_; ++i ) {
            Window win;
            idx       = lexical_cast<string> ( i );
            win.name  = parser_.Get<string> ( "name_" + idx );
            win.start = parser_.Get<int> ( "start_" + idx );
            win.stop  = parser_.Get<int> ( "stop_" + idx );
            factor    = WCF ( parser_.Get<string> ( "units_" + idx ) );
            //convert units to samples
            win.start = static_cast<int> ( win.start * factor );
            win.stop  = static_cast<int> ( win.stop * factor );
            windows_.push_back ( win );
            windowLength_ = win.stop - win.start;
        }
    }

    const int    Phase ( const int num )       {
        return channels_[num].phase;
    }
    const double& DDC ( const int num )         {
        return channels_[num].ddc;
    }
    const string& WindowName ( const int num )  {
        return windows_[num].name;
    }
    const int    WindowStart ( const int num ) {
        return windows_[num].start;
    }
    const int    WindowStop ( const int num )  {
        return windows_[num].stop;
    }
    const int    WindowLength()              {
        return windowLength_;
    }
    const double& SampleRate()                {
        return sampleRate_;
    }
    const double& OutputRate()                {
        return outputRate_;
    }
    const double& Decimation()                {
        return decimation_;
    }
    const int    NumChannels()               {
        return numChannels_;
    }
    const int    NumWindows()                {
        return numWindows_;
    }
    const double& Bandwidth()                 {
        return outputRate_;
    }
    const float&  IPP()                       {
        return ipp_;
    }
    const string& FPGAImage()                 {
        return fpgaImage_;
    }
    const vector<Window>& Windows()           {
        return windows_;
    }

    // returns the hardware's output rate in BPS.
    const long BytesPerSecond() {
        return numChannels_ * gnuradar::BYTES_PER_COMPLEX_SAMPLE *
               ceil ( windowLength_ / ipp_ );
    }
};

#endif


