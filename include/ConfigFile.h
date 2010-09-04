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
#include <gnuradar/ReceiveWindow.hpp>
#include <gnuradar/ReceiveChannel.hpp>
#include <gnuradar/GnuRadarTypes.hpp>
#include <gnuradar/xml/XmlConfigParser.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/cstdint.hpp>
#include <iostream>
#include <cmath>
#include <vector>
#include <map>

///main structure
struct ConfigFile {

    double sampleRate_;
    int numChannels_;
    double ipp_;
    int numWindows_;
    int decimation_;
    double outputRate_;
    double ippUnits_;
    double txCarrier_;
    std::string fpgaImage_;
    std::string dataFileBaseName_;
    std::string version_;
    std::string receiver_;
    int samplesPerIpp_;

    std::vector<ReceiveChannel> channels_;
    std::vector<ReceiveWindow> windows_;

    XmlConfigParser parser_;

public:

    explicit ConfigFile ( const std::string& fileName ) :
            samplesPerIpp_ ( 0 ), parser_ ( fileName ) {

        Units units;

        version_          = parser_.Get<std::string> ( "version" );
        receiver_ = parser_.Get<std::string> ( "receiver" );
        sampleRate_       = parser_.Get<double> ( "sample_rate" ) * 1e6;
        decimation_       = parser_.Get<int> ( "decimation" );
        outputRate_       = sampleRate_ / decimation_;
        numChannels_      = parser_.Get<int> ( "num_channels" );
        numWindows_       = parser_.Get<int> ( "num_windows" );
        ippUnits_         = units ( parser_.Get<std::string> ( "ipp_units" ) );
        ipp_              = parser_.Get<double> ( "ipp" ) * ippUnits_;
        txCarrier_ = parser_.Get<double> ( "tx_carrier" ) * 1e6;
        fpgaImage_        = parser_.Get<std::string> ( "fpga_image_file" );
        dataFileBaseName_ = parser_.Get<std::string> ( "base_file_name" );

        double factor;

        std::string idx;
        for ( int i = 0; i < gnuradar::USRP_MAX_CHANNELS; ++i ) {

            idx = lexical_cast<std::string> ( i );

            ReceiveChannel channel (
                parser_.Get<double> ( "frequency_" + idx ),
                parser_.Get<std::string> ( "frequency_units_" + idx ),
                parser_.Get<double> ( "phase_" + idx ),
                parser_.Get<std::string> ( "phase_units_" + idx )
            );

            channels_.push_back ( channel );
        }

        for ( int i = 0; i < numWindows_; ++i ) {

            idx = lexical_cast<std::string> ( i );

            ReceiveWindow window (
                parser_.Get<std::string> ( "name_" + idx ),
                parser_.Get<double> ( "start_" + idx ),
                parser_.Get<double> ( "stop_" + idx ),
                parser_.Get<std::string> ( "units_" + idx ),
                sampleRate_
            );

            windows_.push_back ( window );
            samplesPerIpp_ += window.Size();
        }
    }

    const int    Phase ( const int num ) {
        return channels_[num].Phase();
    }

    const double& DDC ( const int num ) {
        return channels_[num].Frequency();
    }

    const std::string& WindowName ( const int num )  {
        return windows_[num].Name();
    }

    const int    WindowStart ( const int num ) {
        return windows_[num].Start();
    }

    const int    WindowStop ( const int num )  {
        return windows_[num].Stop();
    }

    const double& SampleRate() {
        return sampleRate_;
    }

    const double& OutputRate() {
        return outputRate_;
    }

    const double& Decimation() {
        return decimation_;
    }

    const int    NumChannels() {
        return numChannels_;
    }

    const int    NumWindows() {
        return numWindows_;
    }

    const double Bandwidth() {
        return outputRate_;
    }

    const double  IPP() {
        return ipp_;
    }

    const double TxCarrier() {
        return txCarrier_;
    }

    const std::string& FPGAImage() {
        return fpgaImage_;
    }

    const std::vector<ReceiveWindow>& Windows() {
        return windows_;
    }

    const std::string& Version() {
        return version_;
    }

    const std::string& DataFileBaseName() {
        return dataFileBaseName_;
    }

    const std::string& Receiver() {
        return receiver_;
    }

    const int SamplesPerIpp() {
        return samplesPerIpp_;
    }

    // returns the hardware's output rate in BPS.
    const long BytesPerSecond() {
        return numChannels_ * gnuradar::BYTES_PER_COMPLEX_SAMPLE *
               ceil ( samplesPerIpp_ / ipp_ );
    }
};

#endif


