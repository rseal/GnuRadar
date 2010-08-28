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
////////////////////////////////////////////////////////////////////////////////
///SettingsCompute.h
///
///Formats and verifies proper sample rate / bandwidth / decimation settings.
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef SETTINGS_COMPUTE_H
#define SETTINGS_COMPUTE_H

#include <iostream>

///Validates selected parameters and formats for display as needed.
struct SettingsCompute {

    const static unsigned int MIN_DECIMATION_RATE = 8;
    const static unsigned int MAX_DECIMATION_RATE = 256;
    const static double MIN_SAMPLE_RATE = 1e6;
    const static double MAX_SAMPLE_RATE = 64e6;

    double sampleRate_;
    int   decimation_;
    double bandwidth_;
    int   channels_;

    ///Update system's bandwidth bassed on channel, sample rate, and decimation
    ///settings.
    void Update() {
        if ( ValidateParameters() )
            bandwidth_ = sampleRate_ / ( channels_ * decimation_ );
        else
            std::cerr
                << "Invalid input parameter given - NO CHANGES MADE" << std::endl;
    }

    template< typename T >
    const bool BoundCheck ( const T value, const T min, const T max ) {
        return ( value >= min && value <= max );
    }

    template< typename T >
    void PrintError ( const std::string& message, const T value, const T min,
                      const T max ) {

        cerr
            << message << "\n"
            << "value = " << value << " valid ranges are ("
            << min << ","
            << max << ").\n";
    }
public:

    ///Constructor
    SettingsCompute() : sampleRate_ ( MAX_SAMPLE_RATE ),
            decimation_ ( MIN_DECIMATION_RATE ), bandwidth_ ( 8e6 ), channels_ ( 1 ) {}

    ///Returns sample rate
    const double SampleRate()       {
        return sampleRate_;
    }
    ///Returns decimation
    const int   Decimation()       {
        return decimation_;
    }
    ///Returns bandwidth
    const double Bandwidth()        {
        return bandwidth_;
    }
    ///Returns channels
    const int   Channels()         {
        return channels_;
    }

    ///Validates and sets decimation settings
    void Decimation ( const int decimation ) {

        bool bounded = BoundCheck<int> ( decimation, MIN_DECIMATION_RATE,
                                         MAX_DECIMATION_RATE );

        bool even = decimation % 2 == 0;

        if ( !bounded || !even )
            PrintError<int> ( "ERROR: Invalid Decimation ", decimation,
                              MIN_DECIMATION_RATE, MAX_DECIMATION_RATE );
        else
            decimation_ = decimation;

        Update();
    }

    ///Validates and sets sample rate settings
    void SampleRate ( const double sampleRate ) {

        bool bounded = BoundCheck<double> ( sampleRate, MIN_SAMPLE_RATE,
                                            MAX_SAMPLE_RATE );

        if ( !bounded )
            PrintError<double> ( "ERROR: Invalid Sample rate ", sampleRate,
                                 MIN_SAMPLE_RATE, MAX_SAMPLE_RATE );
        else
            sampleRate_ = sampleRate;

        Update();
    }

    ///Validates and sets channel settings
    void Channels ( const int channels ) {
        if ( ( channels != 1 ) && ( channels != 2 ) && ( channels != 4 ) )
            std::cerr << "ERROR: invalid number of channels selected" << std::endl;
        else
            channels_ = channels;

        Update();
    }

    ///Checks all parameters and returns true if valid.
    const bool ValidateParameters() {

        bool sampleRateBounded = BoundCheck<double> ( sampleRate_,
                                 MIN_SAMPLE_RATE, MAX_SAMPLE_RATE );
        bool even = decimation_ % 2 == 0;
        bool decimationBounded = BoundCheck<double> ( decimation_,
                                 MIN_DECIMATION_RATE, MAX_DECIMATION_RATE );

        return ( sampleRateBounded && even && decimationBounded );
    }
};

#endif
