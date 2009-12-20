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
   virtual void Start(void* address, const int bytes){

      int bytesRead;
      int byteAlign = bytes;
      cout << "GnuRadarDevice::Start bytes = " << bytes << endl;

      //start data collection and flush fx2 buffer
      if(firstCall_){

         // Initialize stream buffer
         stBuf_.Init(bytes/sizeof(int16_t),512);

         // syncSize = user request + alignment + extra samples for sync
         int syncSize = bytes/sizeof(int16_t) + stBuf_.Padding() + stBuf_.Padding()*6;

         //create temporary buffer to sync data
         int16_t buf[syncSize];
         void* bufPtr = reinterpret_cast<void*>(&buf[0]);

         //(1) initialize usrp for data collection
         //(2) read 512 bytes to clear FX2 buffer
         //(3) read syncSize samples to temporary buffer for data sync
         usrp_->start();
         usrp_->read(bufPtr,512,&overrun_);
         usrp_->read(bufPtr,syncSize*sizeof(int16_t),&overrun_);

         //call stream buffer sync member - will copy synchronized portion of stream to 
         //internal buffers and adjust pointers accordingly
         stBuf_.Sync(bufPtr, syncSize, sequence_);

         //Transfer data to shared memory buffer
         memcpy(address,stBuf_.ReadPtr(), stBuf_.ReadSize());
         stBuf_.UpdateRead();

         firstCall_ = false;
      }
      else{

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
   virtual void Stop(){usrp_->stop();}
};
#endif
