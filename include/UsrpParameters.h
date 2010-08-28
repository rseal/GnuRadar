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
#ifndef USRPPARAMETERS_H
#define USRPPARAMETERS_H

#include <iostream>
#include <boost/lexical_cast.hpp>

using std::cout;
using std::endl;
using std::string;
using boost::lexical_cast;

struct UsrpParameters {

    float sampleRate_;
    int   decimation_;
    float bandwidth_;
    int   channels_;

    const bool ValidateParameters() {
        bool valid ( true );
        if ( sampleRate_ < 1e6 || sampleRate_ > 64e6 ) valid = false;
        if ( decimation_ % 2 != 0 ) valid = false;
        if ( decimation_ < 8 || decimation_ > 256 ) valid = false;
        return valid;
    }

    Update() {
        if ( ValidateParameters() )
            bandwidth_ = sampleRate_ / ( channels_ * decimation_ );
        else
            cout << "Invalid input parameter given - NO CHANGES MADE" << endl;
    }

public:
    UsrpParameters() : sampleRate_ ( 64e6 ), decimation_ ( 8 ), bandwidth_ ( 8e6 ), channels_ ( 1 ) {}

    const float& SampleRate()       {
        return sampleRate_;
    }
    const char*  SampleRateString() {
        string str = lexical_cast<string> ( sampleRate_ / 1e6 );
        return str.c_str();
    }
    const int   Decimation()       {
        return decimation_;
    }
    const float& Bandwidth()        {
        return bandwidth_;
    }
    const int   Channels()         {
        return channels_;
    }

    const char* BandwidthString()   {
        string str = lexical_cast<string> ( bandwidth_ / 1000000.0f ).c_str();
        const char* hack = str.c_str();
        return hack;
    }

    const char* BandwidthStringFancy() {
        string bw, units;
        if ( bandwidth_ >= 1e6 ) {
            units = " MHz";
            bw = lexical_cast<string> ( bandwidth_ / 1000000.0f );
        } else if ( bandwidth_ >= 1e3 ) {
            units = " KHz";
            bw = lexical_cast<string> ( bandwidth_ / 1000.0f );
        } else {
            units = " Hz";
            bw = lexical_cast<string> ( bandwidth_ );
        }
        string temp = bw + units;
        return temp.c_str();
    }

    void Decimation ( const int decimation ) {
        if ( ( decimation % 2 != 0 ) || ( decimation < 8 ) || ( decimation > 256 ) )
            cout << "ERROR: invalid decimation value" << endl;
        else
            decimation_ = decimation;

        Update();
    }

    void SampleRate ( const float& sampleRate ) {
        if ( ( sampleRate < 1e6 ) || ( sampleRate > 64e6 ) )
            cout << "ERROR: invalid sample rate" << endl;
        else
            sampleRate_ = sampleRate;

        Update();
    }

    void Channels ( const int channels ) {
        if ( ( channels != 1 ) && ( channels != 2 ) && ( channels != 4 ) )
            cout << "ERROR: invalid number of channels selected" << endl;
        else
            channels_ = channels;

        Update();
    }
};

#endif
