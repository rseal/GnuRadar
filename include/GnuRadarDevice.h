#ifndef GNURADARDEVICE_H
#define GNURADARDEVICE_H

#include<gnuradar/GnuRadarSettings.h>
#include<gnuradar/DataFormat.h>
#include <gnuradar/Device.h>
#include <gnuradar/Align.h>
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
    auto_ptr<usrp_standard_rx> usrp_;
    GnuRadarSettings grSettings_;
    bool overrun_;
    bool firstCall_;
    Align<int16_t> align_;
    vector<int> sequence_;

public:
    GnuRadarDevice(const GnuRadarSettings& grSettings): 
	grSettings_(grSettings),overrun_(false),firstCall_(true),
	sequence_(grSettings.numChannels,16384),align_(){

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
	
//	usrp_->start();
    }

    //Thread to request data from USRP device
    virtual void Start(void* address, const int bytes){

	int bytesRead;
	
	//start data collection and flush fx2 buffer
	if(firstCall_){
 	    usrp_->start();
	    align_.Init(bytes/sizeof(short),sequence_,8192);
 	    firstCall_ = false;
 	}
	
	//Get data from USRP
	bytesRead = usrp_->read(align_.WritePtr(), align_.RequestSize()*sizeof(short), &overrun_);
	cout << "PreAlign = " << *(align_.WritePtr()) << endl;
	align_.AlignData();
	cout << "dTest = " << *(align_.ReadPtr()) << endl;

	//Transfer data to shared memory buffer
	memcpy(address,align_.ReadPtr(),bytes);
	cout << "dTest2= " << *(reinterpret_cast<short*>(address)) << endl;

	//read n bytes from data stream and pass to address
//	bytesRead = usrp_->read(reinterpret_cast<void*>(address), bytes, &overrun_);	
	
	if(bytesRead != bytes){
	    cout << "USRP::READ mismatch " << bytes << ":" << bytesRead << endl;
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
