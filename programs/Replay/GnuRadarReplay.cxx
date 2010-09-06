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
#include <HDF5/HDF5.hpp>
#include <HDF5/Complex.hpp>
#include <clp/CommandLineParser.hpp>
#include <gnuradar/SThread.h>
#include <string>
#include <fstream>
#include <vector>

using namespace thread;
using namespace hdf5;

class Viewer: public SThread {

    ComplexHDF5 cpx_;
    HDF5 h5File_;

    typedef short Int16;
    int numTables_;
    int sleep_;
    int offset_;
    float sampleRate_;
    string startTime_;
    int channels_;
    vector<hsize_t> dims_;
    vector<complex_t> buffer_;

public:
    Viewer ( const string& fileName ) : h5File_ ( fileName + "_", hdf5::READ ) {

        dims_ = h5File_.TableDims();
        buffer_.resize ( dims_[0]*dims_[1] );

        cout << "-------------------- DESCRIPTION --------------------" << endl;
        cout << h5File_.Description() << endl;
        h5File_.ReadTable<complex_t> ( 0, buffer_, cpx_.GetRef() );
        cout << "-----------------------------------------------------\n" << endl;
        h5File_.ReadAttrib<float> ( "SAMPLE_RATE", sampleRate_, H5::PredType::NATIVE_FLOAT );
        h5File_.ReadAttrib<int> ( "CHANNELS", channels_, H5::PredType::NATIVE_INT );
        startTime_ = h5File_.ReadStrAttrib ( "START_TIME" );
        cout << "Sample Rate = " << sampleRate_ << endl;
        cout << "Start Time  = " << startTime_ << endl;
        cout << "Channels    = " << channels_ << endl;

        sleep_ = 10;
        offset_ = 0;
        numTables_ = h5File_.NumTables();
    }

    void RefreshRate ( const int& ms ) {
        sleep_ = ms;
    }
    void Offset ( const int& offset ) {
        offset_ = offset;
    }

    void Run() {

        int ipp = dims_[0];
        int rangeCells = dims_[1];

        int table = 0;

        cout << "IPPs    = " << ipp << endl;
        cout << "Range Cells = " << rangeCells << endl;

        while ( table != numTables_ ) {
            h5File_.ReadTable<complex_t> ( 0, buffer_, cpx_.GetRef() );
            for ( int i = 0; i < ipp; ++i ) {
                ofstream out ( "/dev/shm/splot.buf", ios::out );
                for ( int j = offset_; j < rangeCells; ++j ) {
                    float x = j - offset_;
                    float rs = buffer_[i*rangeCells + j*channels_].real * 1.0f;
                    out.write ( reinterpret_cast<char*> ( &x ), sizeof ( float ) );
                    out.write ( reinterpret_cast<char*> ( &rs ), sizeof ( float ) );
                }
                out.close();
                Sleep ( thread::MSEC, sleep_ );
            }
            ++table;
        }
    }
};

int main ( int argc, char** argv )
{
    typedef short Int16;
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
    refreshRate = clp.GetArgValue<int> ( "r" );
    offset = clp.GetArgValue<int> ( "o" );

    Viewer view ( fileName );
    view.RefreshRate ( refreshRate );
    view.Offset ( offset );
    view.Start();
    view.Wait();

    return 0;
}

