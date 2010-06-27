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

#include<gnuradar/GnuRadarSettings.h>
#include <gnuradar/Device.h>
#include <gnuradar/StreamBuffer.hpp>

#include <boost/cstdint.hpp>
#include<usrp_standard.h>

#include <iostream>
#include <vector>
#include <cstring>
#include <fstream>

using std::memcpy;
using std::vector;
using std::cout;
using std::cerr;

class GnuRadarDevice: public Device{
   usrp_standard_rx_sptr usrp_;
   GnuRadarSettings grSettings_;
   bool overrun_;
   bool firstCall_;
   StreamBuffer<int16_t> stBuf_;
   vector<int> sequence_;

   public:
   GnuRadarDevice(const GnuRadarSettings& grSettings): 
      grSettings_(grSettings),overrun_(false),firstCall_(true),
      sequence_(grSettings.numChannels,16384){

         usrp_ = usrp_standard_rx::make(
               grSettings_.whichBoard,
               grSettings_.decimationRate,
               grSettings_.numChannels,
               grSettings_.mux,
               grSettings_.mode,
               grSettings_.fUsbBlockSize,
               grSettings_.fUsbNblocks,
               grSettings_.fpgaFileName,
               grSettings_.firmwareFileName
               );
         cout << "Requested bit image " << grSettings_.fpgaFileName << endl;
         
         //check to see if device is connected
         if(usrp_.get()==0){ 
            cout << "no USRP found - check your connections" << endl;
            exit(0);
         }

         for(int i=0; i<grSettings_.numChannels; ++i){
            usrp_->set_rx_freq(i,grSettings_.Tune(i));
            usrp_->set_ddc_phase(i,0);
         }

         //set all gain to 0dB by default	
         for(int i=0; i<4; ++i)
            usrp_->set_pga(i,0);
      }

   //Thread to request data from USRP device
   virtual void StartDevice(void* address, const int bytes){

      int bytesRead;
      int byteAlign = bytes;
      //cout << "GnuRadarDevice::Start bytes = " << bytes << endl;

      //start data collection and flush fx2 buffer
      if(firstCall_){

        cout << "bytes = " << bytes << endl;
        cout << "iq    = " << bytes/sizeof(int16_t) << endl;
         // Initialize stream buffer
         stBuf_.Init(bytes/sizeof(int16_t),512);
        
        cout << "pad   = " << stBuf_.Padding() << endl;
         // syncSize = user request + alignment + extra samples for sync
         int syncSize = 5*(bytes/sizeof(int16_t) + stBuf_.Padding())/4;

         //create temporary buffer to sync data
         int16_t buf[syncSize];
         void* bufPtr = reinterpret_cast<void*>(&buf[0]);

         //(1) initialize usrp for data collection
         //(2) read 512 bytes to clear FX2 buffer
         //(3) read syncSize samples to temporary buffer for data sync
         usrp_->start();
         usrp_->read(bufPtr,syncSize*sizeof(int16_t),&overrun_);

         cout << "size of buffer write is " << syncSize*sizeof(int16_t)/4 << " bytes" << endl;

         //ofstream out1("/home/rseal/streamDebug1.dat", ofstream::binary);
         //for(int i=0; i<syncSize/4; ++i)
         //    out1.write(reinterpret_cast<char*>(&buf[i*sizeof(int16_t)]), sizeof(int16_t));
         //out1.close();


         usrp_->read(bufPtr,syncSize*sizeof(int16_t),&overrun_);

         //ofstream out2("/home/rseal/streamDebug2.dat", ofstream::binary);
         //for(int i=0; i<syncSize; ++i)
         //    out2.write(reinterpret_cast<char*>(&buf[i*sizeof(int16_t)]), sizeof(int16_t));
         //out2.close();

         //call stream buffer sync member - will copy synchronized portion of stream to 
         //internal buffers and adjust pointers accordingly
         stBuf_.Sync(bufPtr, syncSize, sequence_);

         //Transfer data to shared memory buffer
         memcpy(address,stBuf_.ReadPtr(), stBuf_.ReadSize());
         stBuf_.UpdateRead();

         firstCall_ = false;
      }
      else{

         cout << "Writing data to shared memory" << endl;

         //read data from USRP
         bytesRead = usrp_->read(stBuf_.WritePtr(), stBuf_.WriteSize(), &overrun_);
         stBuf_.UpdateWrite();

         //Transfer data to shared memory buffer
         memcpy(address,stBuf_.ReadPtr(), stBuf_.ReadSize());
         stBuf_.UpdateRead();

         if(overrun_){
            cout << "data overrun - you are losing data" << endl;
            //throw exception here
         }
      }
   }
   
   //stop data collection
   virtual void StopDevice(){usrp_->stop();}
};
#endif
