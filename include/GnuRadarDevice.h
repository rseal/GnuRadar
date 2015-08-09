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
#ifndef GNURADARDEVICE_H
#define GNURADARDEVICE_H

#include<GnuRadarSettings.h>
#include <Device.h>
#include <StreamBuffer.hpp>

#include <boost/cstdint.hpp>
#include <boost/shared_ptr.hpp>
#include <usrp/standard.h>

#include <iostream>
#include <vector>
#include <cstring>
#include <fstream>
#include <stdexcept>

namespace gnuradar{

/// Device class providing access to the USRP data stream.
class GnuRadarDevice: public Device {

    // define width of I/Q components
    typedef int16_t iq_t;

    // define synchro buffer
    typedef StreamBuffer< iq_t > SynchronizationBuffer;
    typedef boost::shared_ptr< SynchronizationBuffer >

    SynchronizationBufferPtr;
    SynchronizationBufferPtr synchroBuffer_;

    // define constants
    const int ALIGNMENT_SIZE;
    const int ALIGNMENT_SIZE_BYTES;
    const int FX2_FLUSH_FIFO_SIZE_BYTES;

    // define flags
    bool overFlow_;
    bool dataSynchronized_;

    //StreamBuffer<int16_t> stBuf_;
    std::vector<int> sequence_;

   protected:

    // this is a gnuradio pointer of some sort.
    // older versions did not use this.
    usrp_standard_rx_sptr usrp_;

    // configuration settings class
    GnuRadarSettingsPtr grSettings_;



   public:

    /// Constructor.
    GnuRadarDevice ( GnuRadarSettingsPtr grSettings ) :
       ALIGNMENT_SIZE ( 256 ),
       ALIGNMENT_SIZE_BYTES ( ALIGNMENT_SIZE*sizeof ( iq_t ) ),
       FX2_FLUSH_FIFO_SIZE_BYTES ( 2048 ),
       grSettings_ ( grSettings ),
       overFlow_ ( false ),
       dataSynchronized_ ( false ),
       sequence_ ( grSettings->numChannels, 16384 ) {

          // static helper function to initialize USRP settings
          usrp_ = usrp_standard_rx::make (
                grSettings_->whichBoard,
                grSettings_->decimationRate,
                grSettings_->numChannels,
                grSettings_->mux,
                grSettings_->mode,
                grSettings_->fUsbBlockSize,
                grSettings_->fUsbNblocks,
                grSettings_->fpgaFileName,
                grSettings_->firmwareFileName
                );

          //check to see if device is connected
          if ( usrp_.get() == 0 ) {
             throw std::runtime_error( "No USRP found - check your connections" );
             //exit ( 0 );
          }

          // setup frequency and phase for each ddc
          for ( int i = 0; i < grSettings_->numChannels; ++i ) {
             usrp_->set_rx_freq ( i, grSettings_->Tune ( i ) );
             usrp_->set_ddc_phase ( i, 0 );
          }

          //set all gain to 0dB by default
          // TODO: Make this programmable from the top-level at some point.
          for ( int i = 0; i < 4; ++i )
             usrp_->set_pga ( i, 0 );
       }

    /// This method is called from the Producer thread and transfers
    /// data from the hardware device to a specified buffer given
    /// by the address and bytes parameters.
    ///
    ///\param address shared memory write address.
    ///\param bytes number of bytes to write.
    virtual int RequestData ( void* address, const int bytes ) {

       bool overrun;
       int bytes_read = -1;
       int readRequestSizeSamples = bytes / sizeof ( iq_t );

       //start data collection and flush fx2 buffer
       if ( !dataSynchronized_ ) {

          // Initialize stream buffer
          synchroBuffer_ = SynchronizationBufferPtr (
                new SynchronizationBuffer (
                   readRequestSizeSamples,
                   ALIGNMENT_SIZE,
                   sequence_
                   )
                );

          //create temporary buffer to sync data
          iq_t buf[FX2_FLUSH_FIFO_SIZE_BYTES/sizeof ( iq_t ) ];

          // Read some data to flush the FX2 buffers in the USRP.
          // This data is discarded.
          usrp_->start();
          usrp_->read ( buf, FX2_FLUSH_FIFO_SIZE_BYTES, &overFlow_ );

          // write aligned data into the synchro buffer
          bytes_read = usrp_->read (
                synchroBuffer_->WritePtr(),
                synchroBuffer_->WriteSizeBytes(),
                &overrun
                );

          // capture error and return if true
          if( bytes_read < 0)
          {
             return bytes_read;
          }

          // synchronize the data stream
          synchroBuffer_->Sync();

          dataSynchronized_ = true;
       } 

       //read data from USRP
       bytes_read = usrp_->read (
             synchroBuffer_->WritePtr(),
             synchroBuffer_->WriteSizeBytes(),
             &overFlow_
             );

       // capture error and return if true
       if( bytes_read < 0)
       {
          return bytes_read;
       }

       //Transfer data to shared memory buffer
       memcpy (
             address,
             synchroBuffer_->ReadPtr(),
             synchroBuffer_->ReadSizeBytes()
             );

       // update read and write pointers
       synchroBuffer_->Update();

       if ( overFlow_ ) {
          //TODO: throw exception here
          std::cerr << "GnuRadarDevice: Data overflow detected !!!"
             << std::endl;
       }

       return bytes_read;
    }

    /// Stops data collection.
    virtual void Stop() {

       usrp_->stop();

       // reset synchronization flag
       dataSynchronized_ = false;
    }
};
};
#endif
