#ifndef GNURADARDEVICE_H
#define GNURADARDEVICE_H

#include<gnuradar/GnuRadarSettings.h>
#include<gnuradar/DataFormat.h>
#include <gnuradar/Device.h>

#include <iostream>
#include<usrp_standard.h>

class GnuRadarDevice: public Device{
    std::auto_ptr<usrp_standard_rx> usrp_;
    GnuRadarSettings grSettings_;
    bool overrun_;
    bool firstCall_;
public:
    GnuRadarDevice(const GnuRadarSettings& grSettings): 
	grSettings_(grSettings),overrun_(false),firstCall_(true){

	usrp_.reset(usrp_standard_rx::make(
			grSettings_.whichBoard,
			grSettings_.decimationRate,
			grSettings_.numChannels,
			grSettings_.mux,
			grSettings_.mode,
 			grSettings_.fUsbBlockSize,
			grSettings_.fUsbNblocks,
			grSettings_.fpgaFileName,
			grSettings_.firmwareFileName
			));
	
	//check to see if device is connected
	if(usrp_.get()==0){ 
	    cout << "no USRP found - check your connections" << endl;
	    exit(0);
	}

	//	usrp_->set_decim_rate(grSettings_.decimationRate);
	//	usrp_->set_nchannels(grSettings_.numChannels);
	//	usrp_->set_mux(grSettings_.mux);
	for(int i=0; i<grSettings_.numChannels; ++i){
	  usrp_->set_rx_freq(i,grSettings_.Tune(i));
	  usrp_->set_ddc_phase(i,0);
	}


	usrp_->start();
    }

    virtual void Start(void* address, const int bytes){

	int bytesRead;

	//start data collection and flush fx2 buffer
	if(firstCall_){
	    usrp_->start();
	    usrp_->read(address,512,&overrun_);
	    firstCall_ = false;
	}

	//read n bytes from data stream and pass to address
	bytesRead = usrp_->read(reinterpret_cast<void*>(address), bytes, &overrun_);	
	
	if(bytesRead != bytes){
	    //error here
	}

	if(overrun_){
	    cout << "data overrun - you are losing data" << endl;
	    //throw exception here
	}
    }

//stop data collection
    virtual void Stop(){
	usrp_->stop();
    };
};
#endif
