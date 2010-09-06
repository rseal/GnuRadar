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

#include "GnuRadarRun.hpp"
#include <boost/lexical_cast.hpp>
#include <boost/filesystem.hpp>
#include <cmath>
#include <gnuradar/Mutex.hpp>
#include <gnuradar/Condition.hpp>
#include <gnuradar/SynchronizedBufferManager.hpp>
#include <gnuradar/SharedMemory.h>

using namespace boost;
using namespace gnuradar;

void CheckForExistingFileSet ( std::string& fileSet )
{

    boost::filesystem::path file ( fileSet + "_0000.h5" );

    if ( boost::filesystem::exists ( file ) ) {
        std::cerr
            << "The chosen file set name <" + fileSet +
            "> already exists. Correct the problem and try again. "
            << endl;
        exit ( 1 );
    }

}

int main ( int argc, char** argv )
{
    typedef boost::shared_ptr<SharedMemory> SharedBufferPtr;
    typedef std::vector<SharedBufferPtr> SharedArray;
    SharedArray array;

    typedef boost::shared_ptr< SynchronizedBufferManager > 
      SynchronizedBufferManagerPtr;

   SynchronizedBufferManagerPtr bufferManager;

   thread::MutexPtr mutex_;
   thread::ConditionPtr condition_;

   //class to handle command line options/parsing
   CommandLineParser clp ( argc, argv );
   Arg arg1 ( "f", "configuration file name", 1, false, "test.ucf" );
   Arg arg2 ( "d", "base file name", 1, true );
   Switch sw1 ( "h", "print this message", false );
   Switch sw2 ( "help", "print this message", false );
   clp.AddSwitch ( sw1 );
   clp.AddSwitch ( sw2 );
   clp.AddArg ( arg1 );
   clp.AddArg ( arg2 );
   clp.Parse();

   // if help requested - display and exit
   if ( clp.SwitchSet ( "h" ) || clp.SwitchSet ( "help" ) ) {
      clp.PrintHelp();
      exit ( 0 );
   }

   // validate required settings
   clp.Validate();

   // convert command-line arguments
   fileName = clp.GetArgValue<string> ( "f" );
   dataSet  = clp.GetArgValue<string> ( "d" );

   CheckForExistingFileSet ( dataSet );

   //parse configuration file
   ConfigFile cf ( fileName );

   // compute the pulse repetition frequency
   const float PRF = ceil ( 1.0f / cf.IPP() );
   //buffersize in bytes
   const int BUFFER_SIZE = cf.BytesPerSecond();

   // setup shared memory buffers
   for ( int i = 0; i < constants::NUM_BUFFERS; ++i ) {

      // create unique buffer file names
      std::string bufferName = constants::BUFFER_BASE_NAME +
         boost::lexical_cast<string> ( i ) + ".buf";

      // create shared buffers
      SharedBufferPtr bufPtr (
            new SharedMemory (
               bufferName,
               BUFFER_SIZE,
               SHM::CreateShared,
               0666 )
            );

      // store buffer in a vector
      array.push_back ( bufPtr );
   }

   // initialize buffer manager
   bufferManager = SynchronizedBufferManagerPtr( 
         new SynchronizedBufferManager( array, constants::NUM_BUFFERS, 
            BUFFER_SIZE ) 
         );

   cout
      << "PRF        = " << PRF             << "\n"
      << "BPS        = " << BPS             << "\n"
      << "BufferSize = " << BUFFER_SIZE     << "\n"
      << "sampleRate = " << cf.SampleRate() << "\n"
      << "Decimation = " << cf.Decimation() << "\n"
      << "OutputRate = " << cf.OutputRate() << "\n"
      << endl;

   for ( int i = 0; i < cf.NumWindows(); ++i ) {
      cout
         << "Window: " << cf.WindowName ( i )  << "\n"
         << "Start = " << cf.WindowStart ( i ) << "\n"
         << "Size  = " << cf.WindowStop ( i )  << "\n"
         << endl;
   }

   cout << "Samples per IPP = " << cf.SamplesPerIpp() << endl;

   for ( int i = 0; i < cf.NumChannels(); ++i )
      cout << "ddc" + lexical_cast<string> ( i ) << " = " << cf.DDC ( i ) << endl;

   // dimension 0 holds the number of IPPs per second ( or PRF )
   // dimension 1 contains the number of samples captured in a single IPP
   dimVector.push_back ( static_cast<int> ( PRF ) );
   dimVector.push_back ( static_cast<int> (
            cf.SamplesPerIpp() *cf.NumChannels() ) );

   //create consumer buffer - destination
   buffer = new gnuradar::iq_t[ BUFFER_SIZE /sizeof ( gnuradar::iq_t ) ];

   cout
      << "--------------------Settings----------------------" << "\n"
      << "Sample Rate                 = " << cf.SampleRate()  << "\n"
      << "Bandwidth                   = " << cf.Bandwidth()   << "\n"
      << "Decimation                  = " << cf.Decimation()  << "\n"
      << "Output Rate                 = " << cf.OutputRate()  << "\n"
      << "Number of Channels          = " << cf.NumChannels() << "\n"
      << "Bytes Per Second (System)   = " << BPS              << "\n"
      << "BufferSize                  = " << BUFFER_SIZE      << "\n"
      << "IPP                         = " << cf.IPP()
      << endl;

   for ( int i = 0; i < cf.NumChannels(); ++i )
      cout << "Channel[" << i << "] Tuning Frequency = " << cf.DDC ( i ) << endl;

   cout << "--------------------Settings----------------------\n\n" << endl;

   //write a test file for demonstration purposes
   //header = new SimpleHeaderSystem(dataSet, File::WRITE, File::BINARY);
   h5File = Hdf5Ptr ( new HDF5 ( dataSet + "_", hdf5::WRITE ) );

   h5File->Description ( "USRP Radar Receiver" );
   h5File->WriteStrAttrib ( "START_TIME", currentTime.GetTime() );
   h5File->WriteStrAttrib ( "INSTRUMENT", "GNURadio Rev4.5" );

   h5File->WriteAttrib<int> ( "CHANNELS", cf.NumChannels(),
         H5::PredType::NATIVE_INT, H5::DataSpace()
         );

   h5File->WriteAttrib<double> ( "SAMPLE_RATE", cf.SampleRate(),
         H5::PredType::NATIVE_DOUBLE, H5::DataSpace()
         );

   h5File->WriteAttrib<double> ( "BANDWIDTH", cf.Bandwidth(),
         H5::PredType::NATIVE_DOUBLE, H5::DataSpace()
         );

   h5File->WriteAttrib<int> ( "DECIMATION", cf.Decimation(),
         H5::PredType::NATIVE_INT, H5::DataSpace()
         );

   h5File->WriteAttrib<double> ( "OUTPUT_RATE", cf.OutputRate(),
         H5::PredType::NATIVE_DOUBLE, H5::DataSpace()
         );

   h5File->WriteAttrib<double> ( "IPP", ceil ( cf.IPP() ), H5::PredType::NATIVE_DOUBLE,
         H5::DataSpace()
         );

   // FIXME - RF carrier frequency should be in the configuration file.
   h5File->WriteAttrib<double> ( "RF", cf.SampleRate(), H5::PredType::NATIVE_DOUBLE,
         H5::DataSpace()
         );

   for ( int i = 0; i < cf.NumChannels(); ++i ) {

      h5File->WriteAttrib<double> ( "DDC" + lexical_cast<string> ( i ),
            cf.DDC ( i ), H5::PredType::NATIVE_DOUBLE, H5::DataSpace() );
   }

   h5File->WriteAttrib<int> ( "SAMPLE_WINDOWS", cf.NumWindows(),
         H5::PredType::NATIVE_INT, H5::DataSpace()
         );

   for ( int i = 0; i < cf.NumWindows(); ++i ) {

      h5File->WriteAttrib<int> ( cf.WindowName ( i ) + "_START", cf.WindowStart ( i ),
            H5::PredType::NATIVE_INT, H5::DataSpace()
            );

      h5File->WriteAttrib<int> ( cf.WindowName ( i ) + "_SIZE", cf.WindowStop ( i ),
            H5::PredType::NATIVE_INT, H5::DataSpace()
            );
   }

   gnuradar::GnuRadarSettingsPtr settings( new gnuradar::GnuRadarSettings() );
   //Program GNURadio
   for ( int i = 0; i < cf.NumChannels(); ++i ) settings->Tune ( i, cf.DDC ( i ) );

   settings->numChannels    = cf.NumChannels();
   settings->decimationRate = cf.Decimation();
   settings->fpgaFileName   = cf.FPGAImage();

   //change these as needed
   settings->fUsbBlockSize  = 0;
   settings->fUsbNblocks    = 0;
   settings->mux            = 0xf0f0f1f0;

   GnuRadarDevicePtr grDevice( new gnuradar::GnuRadarDevice ( settings ) );

   // setup producer thread
   gnuradar::ProducerThreadPtr producerThread (
         new ProducerThread ( bufferManager, grDevice )
         );

   // setup consumer thread
   gnuradar::ConsumerThreadPtr consumerThread (
         new ConsumerThread ( bufferManager, h5File, dimVector )
         );

   //Initialize Producer/Consumer Model
   gnuradar::ProducerConsumerModel pcmodel;
   
   pcmodel.Initialize( bufferManager, producerThread, consumerThread );

   //this is the primary system loop - console controls operation
   cout << "Starting Data Collection... type <quit> to exit" << endl;
   //Console console ( pcmodel );
   //pcmodel.Start();
   //pcmodel.RequestData();
   //pcmodel.Wait();
   cout << "Stopping Data Collection... Exiting Program" << endl;

   return 0;
};


