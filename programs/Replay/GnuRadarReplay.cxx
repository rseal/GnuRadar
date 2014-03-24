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
#include <string>
#include <fstream>
#include <vector>

#include <boost/lexical_cast.hpp>

#include <HDF5.hpp>
#include <Complex.hpp>

#include <CommandLineParser.hpp>

#include <SThread.h>
#include <SharedMemory.h>
#include <SynchronizedBufferManager.hpp>
#include <Constants.hpp>
#include <yaml/SharedBufferHeader.hpp>

using namespace thread;
using namespace hdf5;
using namespace gnuradar;

class Viewer: public SThread {

    typedef boost::shared_ptr<SharedMemory> SharedBufferPtr;
    typedef std::vector<SharedBufferPtr> SharedArray;
    typedef boost::shared_ptr<SynchronizedBufferManager> 
       BufferManagerPtr;
    typedef boost::shared_ptr<yml::SharedBufferHeader> 
       SharedBufferHeaderPtr;

    BufferManagerPtr bufferManager_;
    SharedBufferHeaderPtr header_;
    ComplexHDF5 cpx_;
    HDF5 h5File_;

    int numTables_;
    long sleep_;
    int offset_;
    int bufferSize_;
    float sampleRate_;
    string startTime_;
    int channels_;
    vector<hsize_t> dims_;
    SharedArray array_;

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
public:
    Viewer ( const string& fileName ) : h5File_ ( fileName , hdf5::READ ) {

        dims_ = h5File_.TableDims();
        const int bytesPerBuffer = dims_[0]*dims_[1]*sizeof(complex_t);
        int sampleWindows;
        string windowName;
        int windowStart;
        int windowStop;


        CreateSharedBuffers( bytesPerBuffer );

        cout << "-------------------- DESCRIPTION --------------------" << endl;
        cout << h5File_.Description() << endl;
        //h5File_.ReadTable<complex_t> ( 0, buffer_, cpx_.GetRef() );
        cout << "-----------------------------------------------------\n" << endl;
        h5File_.ReadAttrib<float> ( "SAMPLE_RATE", sampleRate_, H5::PredType::NATIVE_FLOAT );
        h5File_.ReadAttrib<int> ( "CHANNELS", channels_, H5::PredType::NATIVE_INT );
        h5File_.ReadAttrib<int> ("SAMPLE_WINDOWS", sampleWindows, H5::PredType::NATIVE_INT);
        startTime_ = h5File_.ReadStrAttrib ( "START_TIME" );
        numTables_ = h5File_.NumTables();

        header_ = SharedBufferHeaderPtr( 
              new yml::SharedBufferHeader( 
                 constants::NUM_BUFFERS, 
                 bytesPerBuffer,
                 sampleRate_,
                 channels_,
                 dims_[0], 
                 dims_[1]));

        // TODO: Need to fix HDF5 window handling - it's not very robust.
        for( int i=0; i< sampleWindows; ++i)
        {
           h5File_.ReadAttrib<int> ("RxWin_START", windowStart, H5::PredType::NATIVE_INT);
           h5File_.ReadAttrib<int> ("RxWin_STOP", windowStop, H5::PredType::NATIVE_INT);
           windowName = "RxWin";
           header_->AddWindow( windowName, windowStart, windowStop );
        }

        header_->Write(0,0,0);

        // setup buffer manager
        bufferManager_ = 
           BufferManagerPtr( 
              new SynchronizedBufferManager( 
                 array_, 
                 constants::NUM_BUFFERS, 
                 bytesPerBuffer) 
              );

        cout << "Sample Rate      = " << sampleRate_ << endl;
        cout << "Start Time       = " << startTime_ << endl;
        cout << "Channels         = " << channels_ << endl;
        cout << "Number of Tables = " << numTables_ << endl;

        sleep_ = 1000;
        offset_ = 0;
    }

    void RefreshRate ( const long ms ) {
        sleep_ = ms;
    }

    void Offset ( const int offset ) {
        offset_ = offset;
    }

    void Run() {

        int table = 0;

        while ( table != numTables_ ) {
            cout << "Reading table " << table << endl;

            h5File_.ReadTable<complex_t> ( 
                  table, bufferManager_->WriteTo(), cpx_.GetRef() );


            header_->Write( 
                  bufferManager_->Head(),
                  bufferManager_->Tail(),
                  bufferManager_->Depth());

            bufferManager_->IncrementHead();
            bufferManager_->IncrementTail();

            //for ( int i = 0; i < ipp; ++i ) {
            //    ofstream out ( "/dev/shm/splot.buf", ios::out );
            //    for ( int j = offset_; j < rangeCells; ++j ) {
            //        float x = j - offset_;
            //        float rs = buffer_[i*rangeCells + j*channels_].real * 1.0f;
            //        out.write ( reinterpret_cast<char*> ( &x ), sizeof ( float ) );
            //        out.write ( reinterpret_cast<char*> ( &rs ), sizeof ( float ) );
            //    }
            //    out.close();
            Sleep ( thread::MSEC, sleep_ );
            //}
            ++table;
        }
    }
};

int main ( int argc, char** argv )
{
    string fileName;
    int refreshRate;
    int offset;
    //class to handle command line options/parsing
    CommandLineParser clp ( argc, argv );
    Arg arg1 ( "f", "file to view", 1, true );
    Arg arg2 ( "r", "refresh rate", 1, false, "100" );
    Arg arg3 ( "o", "offset", 1, false, "0" );
    Switch sw1 ( "h", "print this message", false );
    Switch sw2 ( "help", "print this message", false );
    clp.AddSwitch ( sw1 );
    clp.AddSwitch ( sw2 );
    clp.AddArg ( arg1 );
    clp.AddArg ( arg2 );
    clp.AddArg ( arg3 );
    clp.Parse();

    if ( clp.SwitchSet ( "h" ) || clp.SwitchSet ( "help" ) ) {
        clp.PrintHelp();
        exit ( 0 );
    }

    clp.Validate();

    fileName = clp.GetArgValue<string> ( "f" );
    refreshRate = clp.GetArgValue<long> ( "r" );
    offset = clp.GetArgValue<int> ( "o" );

    Viewer view ( fileName );
    view.RefreshRate ( refreshRate );
    view.Offset ( offset );
    view.Start();
    view.Wait();

    return 0;
}

