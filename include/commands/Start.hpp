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

#include <gnuradar/ConfigFile.h>
#include <gnuradar/GnuRadarCommand.hpp>
#include <gnuradar/ProducerConsumerModel.h>
#include <gnuradar/Device.h>
#include <gnuradar/GnuRadarDevice.h>
#include <gnuradar/xml/XmlPacket.hpp>
#include <gnuradar/SynchronizedBufferManager.hpp>
#include <gnuradar/SharedMemory.h>
#include <gnuradar/Constants.hpp>

#include <vector>
#include <boost/shared_ptr.hpp>
#include <boost/scoped_ptr.hpp>
#include <boost/filesystem.hpp>

namespace gnuradar {
namespace command {

class Start : public GnuRadarCommand {

    typedef boost::shared_ptr<SharedMemory> SharedBufferPtr;
    typedef std::vector<SharedBufferPtr> SharedArray;
    typedef boost::shared_ptr<HDF5> Hdf5Ptr;
    typedef boost::shared_ptr<SynchronizedBufferManager> 
       SynchronizedBufferManagerPtr;
    typedef boost::shared_ptr< ProducerConsumerModel > PCModelPtr;
    typedef boost::shared_ptr< ProducerThread > ProducerThreadPtr;
    typedef boost::shared_ptr< ConsumerThread > ConsumerThreadPtr;
    typedef boost::shared_ptr< GnuRadarDevice > GnuRadarDevicePtr;
    typedef boost::shared_ptr< GnuRadarSettings > GnuRadarSettingsPtr;
    typedef boost::shared_ptr< Device > DevicePtr;

    // setup shared pointers to extend life beyond this call
    PCModelPtr pcModel_;
    gnuradar::ProducerThreadPtr producer_;
    gnuradar::ConsumerThreadPtr consumer_;
    SynchronizedBufferManagerPtr bufferManager_;
    Hdf5Ptr hdf5_;
    SharedArray array_;

    void CheckForExistingFileSet ( const std::string& fileSet ) 
       throw( std::runtime_error )
    {

       boost::filesystem::path file ( fileSet + "_0000.h5" );

       if ( boost::filesystem::exists ( file ) ) {
          throw std::runtime_error( "HDF5 File set " + fileSet + 
                " exists and cannot be overwritten. Change your "
                "base file set name and try again");
       }
    }

    void CreateSharedBuffers( const int bytesPerBuffer ) {

       // setup shared memory buffers
       for ( int i = 0; i < constants::NUM_BUFFERS; ++i ) {

          // create unique buffer file names
          std::string bufferName = constants::BUFFER_BASE_NAME +
             boost::lexical_cast<string> ( i ) + ".buf";

          // create shared buffers
          SharedBufferPtr bufPtr (
                new SharedMemory (
                   bufferName,
                   bytesPerBuffer,
                   SHM::CreateShared,
                   0666 )
                );

          // store buffer in a vector
          array_.push_back ( bufPtr );
       }
    }

    // pull settings from the configuration file
    GnuRadarSettingsPtr GetSettings( ConfigFile& configuration ) {

       GnuRadarSettingsPtr settings( new GnuRadarSettings() );

       //Program GNURadio
       for ( int i = 0; i < configuration.NumChannels(); ++i ) {
          settings->Tune ( i, configuration.DDC ( i ) );
       }

       settings->numChannels    = configuration.NumChannels();
       settings->decimationRate = configuration.Decimation();
       settings->fpgaFileName   = configuration.FPGAImage();

       //change these as needed
       settings->fUsbBlockSize  = 0;
       settings->fUsbNblocks    = 0;
       settings->mux            = 0xf0f0f1f0;

       return settings;
    }

    Hdf5Ptr SetupHDF5( ConfigFile& configuration ) throw( H5::Exception )
    {
       std::string fileSet = configuration.DataFileBaseName();
       Hdf5Ptr h5File_( new HDF5 ( fileSet + "_", hdf5::WRITE ) );

       h5File_->Description ( "GnuRadar Software" + configuration.Version() );
       h5File_->WriteStrAttrib ( "START_TIME", currentTime.GetTime() );
       h5File_->WriteStrAttrib ( "INSTRUMENT", configuration.Receiver() );
       h5File_->WriteAttrib<int> ( "CHANNELS", configuration.NumChannels(),
             H5::PredType::NATIVE_INT, H5::DataSpace() );
       h5File_->WriteAttrib<double> ( "SAMPLE_RATE", configuration.SampleRate(),
             H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );
       h5File_->WriteAttrib<double> ( "BANDWIDTH", configuration.Bandwidth(),
             H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );
       h5File_->WriteAttrib<int> ( "DECIMATION", configuration.Decimation(),
             H5::PredType::NATIVE_INT, H5::DataSpace() );
       h5File_->WriteAttrib<double> ( "OUTPUT_RATE", configuration.OutputRate(),
             H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );
       h5File_->WriteAttrib<double> ( "IPP", configuration.IPP(),
             H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );
       h5File_->WriteAttrib<double> ( "RF", configuration.TxCarrier() , 
             H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );

       for ( int i = 0; i < configuration.NumChannels(); ++i ) {
          h5File_->WriteAttrib<double> ( 
                "DDC" + lexical_cast<string> ( i ),
                configuration.DDC ( i ), H5::PredType::NATIVE_DOUBLE, 
                H5::DataSpace() 
                );
       }

       h5File_->WriteAttrib<int> ( 
             "SAMPLE_WINDOWS", configuration.NumWindows(),
             H5::PredType::NATIVE_INT, H5::DataSpace()
             );

       for ( int i = 0; i < configuration.NumWindows(); ++i ) {

          h5File_->WriteAttrib<int> ( 
                configuration.WindowName ( i ) + "_START", 
                configuration.WindowStart ( i ),
                H5::PredType::NATIVE_INT, H5::DataSpace()
                );

          h5File_->WriteAttrib<int> ( 
                configuration.WindowName ( i ) + "_STOP", 
                configuration.WindowStop ( i ),
                H5::PredType::NATIVE_INT, H5::DataSpace()
                );
       }

       return h5File_;
    }

   public:

    Start( PCModelPtr pcModel): GnuRadarCommand( "start" ), pcModel_( pcModel )
    {}

    virtual const std::string Execute( const xml::XmlPacketArgs& args ) {

       // reset any existing configuration
       producer_.reset();
       consumer_.reset();
       bufferManager_.reset();
       hdf5_.reset();
       array_.clear();

       std::string response;
       std::string fileName = command::ParseArg( "file_name", args );

       ConfigFile configFile( fileName );
       const int bufferSize = configFile.BytesPerSecond();

       // create a response packet and return to requester
       std::string destination = command::ParseArg( "source", args );
       xml::XmlPacketArgs responsePacket;
       responsePacket["destination"] = destination;
       responsePacket["type"] = "response";
       gnuradar::xml::XmlPacket packet("gnuradar_server");

       try{

          CheckForExistingFileSet ( configFile.DataFileBaseName() ) ;

          // setup HDF5 attributes and file set.
          hdf5_ = SetupHDF5( configFile );

          // read and parse configuration file.
          GnuRadarSettingsPtr settings = GetSettings( configFile );

          // create a device to communicate with hardware
          GnuRadarDevicePtr gnuRadarDevice( new GnuRadarDevice( settings ) );

          // setup shared memory buffers
          CreateSharedBuffers( bufferSize );

          // setup the buffer manager
          bufferManager_ = SynchronizedBufferManagerPtr( 
                new SynchronizedBufferManager( 
                   array_, constants::NUM_BUFFERS, bufferSize) );

          // setup table dimensions column = samples per ipp , row = IPP number
          vector<hsize_t> dims;
          dims.push_back( static_cast<int>( ceil( 1.0 / configFile.IPP() ) ) );
          dims.push_back ( 
                static_cast<int> ( 
                   configFile.SamplesPerIpp() * configFile.NumChannels() ) 
                );

          // setup producer thread
          producer_ = gnuradar::ProducerThreadPtr (
                new ProducerThread ( bufferManager_, gnuRadarDevice ) );

          // setup consumer thread
          consumer_ = gnuradar::ConsumerThreadPtr(
                new ConsumerThread ( bufferManager_ , hdf5_, dims ) );

          // new model
          pcModel_->Initialize( bufferManager_, producer_, consumer_);

          // start producer thread
          pcModel_->Start();

          responsePacket["value"] = "OK";
          responsePacket["message"] = "Data collection successfully started.";
          response = packet.Format( responsePacket );

       }
       catch( std::runtime_error& e ){

          responsePacket["value"] = "ERROR";
          responsePacket["message"] = e.what();
          response = packet.Format( responsePacket );

       }
       catch( H5::Exception& e ){

          responsePacket["value"] = "ERROR";
          responsePacket["message"] = e.getDetailMsg();
          response = packet.Format( responsePacket );
       }

       return response;
    }
};
};
};

#endif
