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
#include "GnuRadarVerify.hpp"
#include <boost/lexical_cast.hpp>

using std::string;
using std::vector;
using boost::lexical_cast;
using namespace gnuradar;

int main ( int argc, char** argv )
{
    bool overFlow = false;

    CommandLineParser clp ( argc, argv );
    Arg arg1 ( "f", "configuration file name", 1, true );
    Switch sw1 ( "h", "print this message", false );
    Switch sw2 ( "help", "print this message", false );
    clp.AddSwitch ( sw1 );
    clp.AddSwitch ( sw2 );
    clp.AddArg ( arg1 );
    clp.Parse();

    if ( clp.SwitchSet ( "h" ) || clp.SwitchSet ( "help" ) ) {
        clp.PrintHelp();
        exit ( 0 );
    }

    clp.Validate();

    string fileName = clp.GetArgValue<string> ( "f" );

    //parse configuration file
    ConfigFile cf ( fileName );

    // buffer one second's worth of data
    buffer.resize ( cf.BytesPerSecond() / sizeof ( gnuradar::iq_t ) );
    void* bufferPtr = &buffer[0];

    // set require gnuradar settings.
    GnuRadarSettings settings;

    settings.numChannels    = cf.NumChannels();
    settings.decimationRate = cf.Decimation();
    settings.fpgaFileName   = cf.FPGAImage();
    settings.fUsbBlockSize  = 0;
    settings.fUsbNblocks    = 0;
    settings.mux            = 0xf3f2f1f0;

    for ( int i = 0; i < cf.NumChannels(); ++i ) {
       settings.Tune ( i, cf.DDC ( i ) );
       settings.Phase ( i, cf.Phase ( i ) );
    }

    cout << "NumChannels = " << settings.numChannels << endl;
    // create a USRP object.
    usrp_standard_rx_sptr usrp = usrp_standard_rx::make (
                                     settings.whichBoard,
                                     settings.decimationRate,
                                     settings.numChannels,
                                     settings.mux,
                                     settings.mode,
                                     settings.fUsbBlockSize,
                                     settings.fUsbNblocks,
                                     settings.fpgaFileName,
                                     settings.firmwareFileName
                                 );

    //check to see if device is connected
    if ( usrp.get() == 0 ) {
       throw std::runtime_error (
           "GnuRadarVerify: No USRP device found - please check your "
           "connections.\n"
       );
    }

    // setup frequency and phase for each ddc
    for ( int i = 0; i < settings.numChannels; ++i ) {
        usrp->set_rx_freq ( i, settings.Tune ( i ) );
        usrp->set_ddc_phase ( i, 0 );
    }

    //set all gain to 0dB by default
    for ( unsigned int i = 0; i < gnuradar::USRP_MAX_CHANNELS; ++i )
        usrp->set_pga ( i, 0 );

    // initialize data collection and flush FX2 buffer.
    usrp->start();
    usrp->read ( bufferPtr, gnuradar::FX2_FLUSH_FIFO_SIZE_BYTES, &overFlow );

    // resize buffer aligned on required byte boundary - 512 bytes
    int byteRequest = cf.BytesPerSecond();
    int alignedBytes = byteRequest % gnuradar::BUFFER_ALIGNMENT_SIZE_BYTES;
    int alignedByteRequest = byteRequest - alignedBytes;
    buffer.resize ( alignedByteRequest / sizeof ( gnuradar::iq_t ) );

    //read data from USRP
    int bytesRead = usrp->read ( bufferPtr, alignedByteRequest, &overFlow );

    if ( bytesRead != alignedByteRequest ) {
        throw std::runtime_error (
            "GnuRadarVerify: Number of bytes read is not equal to the "
            "number of requested bytes.\n Expected " +
            lexical_cast<string> ( alignedByteRequest ) + " Found " +
            lexical_cast<string> ( bytesRead )  + "\n"
        );
    }

    int stride = cf.NumChannels() * 2;

    Buffer channelBuffer ( buffer.size() / stride );
    BufferIterator bufferIter = buffer.begin();
    BufferIterator channelBufferIter = channelBuffer.begin();

    while ( bufferIter != buffer.end() ) {
        *channelBufferIter = *bufferIter;
        bufferIter += stride ;
        ++channelBufferIter;
    }

    // validate collected window sizes with those in configuration file.
    WindowValidator windowValidator_;
    bool valid = windowValidator_.Validate ( channelBuffer, cf.Windows() );

    if ( !valid ) {
        cout << " GnuRadar window verification failed. \n";
        windowValidator_.PrintResults ( cout );
    } else {
        cout << " GnuRadar window verification passed. \n";
    }

    return EXIT_SUCCESS;
}
