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
#ifndef START_HPP
#define START_HPP

#include <boost/tokenizer.hpp>

#include <gnuradar/ConfigFile.h>
#include <gnuradar/GnuRadarCommand.h>
#include <gnuradar/ProducerConsumerModel.h>
#include <gnuradar/ProducerThread.h>
#include <gnuradar/ConsumerThread.h>

namespace gnuradar {
namespace command {

class Start : public GnuRadarCommand {

    static const int NUM_BUFFERS = 20;

    typedef boost::tokenizer< boost::char_separator<char> > Tokenizer;

    // setup shared pointers to extend life beyond this call
    typedef boost::shared_ptr< ProducerConsumerModel > ProducerConsumerModelPtr;
    ProducerConsumerModel pcModel_;
    typedef boost::shared_ptr< ProducerThread > ProducerThreadPtr;
    typedef boost::shared_ptr< ConsumerThread > ConsumerThreadPtr;

    // pull settings from the configuration file
    const GnuRadarSettings GetSettings( ConfigFile& config ) {

        GnuRadarSettings settings;

        //Program GNURadio
        for ( int i = 0; i < cf.NumChannels(); ++i ) {
            settings.Tune ( i, cf.DDC ( i ) );
        }

        settings.numChannels    = cf.NumChannels();
        settings.decimationRate = cf.Decimation();
        settings.fpgaFileName   = cf.FPGAImage();

        //change these as needed
        settings.fUsbBlockSize  = 0;
        settings.fUsbNblocks    = 0;
        settings.mux            = 0xf0f0f1f0;

        return settings;
    }

    const void SetupHDF5( ConfigFile& configuration, 
          std::string&    )
    {
       
       h5File = Hdf5Ptr ( new HDF5 ( dataSet + "_", hdf5::WRITE ) );

       h5File->Description ( "USRP Radar Receiver" );
       h5File->WriteStrAttrib ( "START_TIME", currentTime.GetTime() );
       h5File->WriteStrAttrib ( "INSTRUMENT", "GNURadio Rev4.5" );
       h5File->WriteAttrib<int> ( "CHANNELS", cf.NumChannels(),
             H5::PredType::NATIVE_INT, H5::DataSpace() );
       h5File->WriteAttrib<double> ( "SAMPLE_RATE", cf.SampleRate(),
             H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );
       h5File->WriteAttrib<double> ( "BANDWIDTH", cf.Bandwidth(),
             H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );
       h5File->WriteAttrib<int> ( "DECIMATION", cf.Decimation(),
             H5::PredType::NATIVE_INT, H5::DataSpace() );
       h5File->WriteAttrib<double> ( "OUTPUT_RATE", cf.OutputRate(),
             H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );
       h5File->WriteAttrib<double> ( "IPP", ceil ( cf.IPP() ),
             H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );
       h5File->WriteAttrib<double> ( "RF", 49.80e6, H5::PredType::NATIVE_DOUBLE,
             H5::DataSpace() );

       for ( int i = 0; i < cf.NumChannels(); ++i ) {
          h5File->WriteAttrib<double> ( 
                "DDC" + lexical_cast<string> ( i ),
                cf.DDC ( i ), H5::PredType::NATIVE_DOUBLE, H5::DataSpace() 
                );
       }

       h5File->WriteAttrib<int> ( 
             "SAMPLE_WINDOWS", cf.NumWindows(),
             H5::PredType::NATIVE_INT, H5::DataSpace()
             );

       for ( int i = 0; i < cf.NumWindows(); ++i ) {

          h5File->WriteAttrib<int> ( 
                cf.WindowName ( i ) + "_START", cf.WindowStart ( i ),
                H5::PredType::NATIVE_INT, H5::DataSpace()
                );

          h5File->WriteAttrib<int> ( 
                cf.WindowName ( i ) + "_SIZE", cf.WindowSize ( i ),
                H5::PredType::NATIVE_INT, H5::DataSpace()
                );
       }
    }

   public:

    Start( ProducerConsumerModelPtr pcModel, std::string& fileName ):
       pcModel_( pcModel ) {

          ConfigFile configFile( fileName );
          const int bufferSize = cf.BytesPerSecond();

          // create a device to communicate with hardware
          GnuRadarDevicePtr grDevice(
                new GnuRadarDevice( GetSettings( configFile ))
                );

          // setup producer thread
          gnuradar::ProducerThreadPtr producerThread (
                new ProducerThread ( bufferSize , grDevice )
                );

          // setup consumer thread
          gnuradar::ConsumerThreadPtr consumerThread (
                new ConsumerThread ( bufferSize , buffer, h5File, dimVector )
                );

          // create a producer/consumer model for streaming data
          pcModel = gnuradar::ProducerConsumerModelPtr(
                new ProducerConsumerModel(
                   "GnuRadar",
                   NUM_BUFFERS,
                   bufferSize,
                   producerThread,
                   consumerThread
                   )
                );
       }

    virtual void Execute( std::string& args ) {
       // start consumer thread
       pcModel.RequestData();

       // start producer thread
       pcModel.Start();
    }
};
};
