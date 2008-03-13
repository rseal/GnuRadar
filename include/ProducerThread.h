#ifndef PRODUCER_THREAD_H
#define PRODUCER_THREAD_H

#include <gnuradar/BaseThread.h>
#include <gnuradar/SThread.h>
#include <gnuradar/Device.h>

//added generic device class so producer can act properly
//by calling thread using generic calls to start and stop
//this means that user will now define functionality inside
//device class as opposed to the sthread Run() function

class ProducerThread: public BaseThread, public SThread{
    Device& device_;

public:
    ProducerThread(const int& bytes, Device& device):
	BaseThread(bytes),SThread(),device_(device){
    }

    virtual void Stop(){ 
	device_.Stop();
    }

    virtual void RequestData(void* address){
	address_ = address;
	this->Start();
    }
    
    //run now calls device class start() member to 
    //modularize system - i.e. define device class
    //start() for functionality
    virtual void Run(){
       	device_.Start(address_,bytes_);
    }

};    

#endif
