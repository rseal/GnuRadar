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
#include <gnuradar/GnuRadarCommand.hpp>
#include <gnuradar/ProducerConsumerModel.h>
#include <gnuradar/Device.h>
#include <gnuradar/GnuRadarDevice.h>
#include <gnuradar/ProducerThread.h>
#include <gnuradar/ConsumerThread.h>
#include <gnuradar/xml/XmlPacket.hpp>

namespace gnuradar {
namespace command {

class Start : public GnuRadarCommand {

    static const int NUM_BUFFERS = 20;

    typedef boost::tokenizer< boost::char_separator<char> > Tokenizer;

    // setup shared pointers to extend life beyond this call
    typedef boost::shared_ptr< ProducerConsumerModel > ProducerConsumerModelPtr;
    ProducerConsumerModelPtr pcModel_;
    typedef boost::shared_ptr< ProducerThread > ProducerThreadPtr;
    typedef boost::shared_ptr< ConsumerThread > ConsumerThreadPtr;
    typedef boost::shared_ptr< GnuRadarDevice > GnuRadarDevicePtr;
    typedef boost::shared_ptr< Device > DevicePtr;

    // pull settings from the configuration file
    const GnuRadarSettings GetSettings( ConfigFile& configuration ) {

        GnuRadarSettings settings;

        //Program GNURadio
        for ( int i = 0; i < configuration.NumChannels(); ++i ) {
            settings.Tune ( i, configuration.DDC ( i ) );
        }

        settings.numChannels    = configuration.NumChannels();
        settings.decimationRate = configuration.Decimation();
        settings.fpgaFileName   = configuration.FPGAImage();

        //change these as needed
        settings.fUsbBlockSize  = 0;
        settings.fUsbNblocks    = 0;
        settings.mux            = 0xf0f0f1f0;

        return settings;
    }

    const void SetupHDF5( ConfigFile& configuration, 
          std::string&    )
    {
       std::string fileSet = configuration.DataFileBaseName();
       
       h5File = Hdf5Ptr ( new HDF5 ( fileSet + "_", hdf5::WRITE ) );

       h5File->Description ( "GnuRadar Software" + configuration.Version() );
       h5File->WriteStrAttrib ( "START_TIME", currentTime.GetTime() );
       h5File->WriteStrAttrib ( "INSTRUMENT", configuration.Receiver() );
       h5File->WriteAttrib<int> ( "CHANNELS", configuration.NumChannels(),
             H5::PredType::NATIVE_INT, H5::DataSpace() );
       h5File->WriteAttrib<double> ( "SAMPLE_RATE", configuration.SampleRate(),
             H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );
       h5File->WriteAttrib<double> ( "BANDWIDTH", configuration.Bandwidth(),
             H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );
       h5File->WriteAttrib<int> ( "DECIMATION", configuration.Decimation(),
             H5::PredType::NATIVE_INT, H5::DataSpace() );
       h5File->WriteAttrib<double> ( "OUTPUT_RATE", configuration.OutputRate(),
             H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );
       h5File->WriteAttrib<double> ( "IPP", configuration.IPP(),
             H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );
       h5File->WriteAttrib<double> ( "RF", configuration.TxCarrier() , 
             H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );

       for ( int i = 0; i < configuration.NumChannels(); ++i ) {
          h5File->WriteAttrib<double> ( 
                "DDC" + lexical_cast<string> ( i ),
                configuration.DDC ( i ), H5::PredType::NATIVE_DOUBLE, 
                H5::DataSpace() 
                );
       }

       h5File->WriteAttrib<int> ( 
             "SAMPLE_WINDOWS", configuration.NumWindows(),
             H5::PredType::NATIVE_INT, H5::DataSpace()
             );

       for ( int i = 0; i < configuration.NumWindows(); ++i ) {

          h5File->WriteAttrib<int> ( 
                configuration.WindowName ( i ) + "_START", 
                configuration.WindowStart ( i ),
                H5::PredType::NATIVE_INT, H5::DataSpace()
                );

          h5File->WriteAttrib<int> ( 
                configuration.WindowName ( i ) + "_STOP", 
                configuration.WindowStop ( i ),
                H5::PredType::NATIVE_INT, H5::DataSpace()
                );
       }
    }

   public:

    Start( ProducerConsumerModelPtr pcModel ): 
       GnuRadarCommand( "start" ), pcModel_( pcModel ) {
       }

    virtual void Execute( const xml::XmlPacketArgs& args ) {

       xml::XmlPacketArgs::const_iterator iter = args.find("file_name");
       
       if( iter == args.end() )
       {
          throw std::runtime_error( "Start command parsing failure - "
                "check message arguments");
       }

       std::string fileName = iter->second; 

       ConfigFile configFile( fileName );
       const int bufferSize = configFile.BytesPerSecond();

       // create a device to communicate with hardware
       GnuRadarDevicePtr grDevice(
             new GnuRadarDevice( GetSettings( configFile ))
             );

       // setup producer thread
       gnuradar::ProducerThreadPtr producerThread (
             new ProducerThread ( bufferSize , grDevice ));

       // setup consumer thread
       gnuradar::ConsumerThreadPtr consumerThread (
             new ConsumerThread ( bufferSize , buffer, h5File, dimVector )
             );

       // create a producer/consumer model for streaming data
       pcModel_ = ProducerConsumerModelPtr(
             new ProducerConsumerModel(
                "GnuRadar",
                NUM_BUFFERS,
                bufferSize,
                producerThread,
                consumerThread
                )
             );

       // start consumer thread
       pcModel_->RequestData();

       // start producer thread
       pcModel_->Start();
    }
};
};
};

#endif
