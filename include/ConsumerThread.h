#ifndef CONSUMER_THREAD_H
#define CONSUMER_THREAD_H

#include <gnuradar/BaseThread.h>
#include <gnuradar/SThread.h>

class ConsumerThread: public BaseThread, public SThread{
    void* destination_;
public:
    ConsumerThread(const int& bytes, void* destination):BaseThread(bytes),SThread(),destination_(destination){
    }
    virtual void Stop(){ 
      //cleanup code for hardware here
    }
    virtual void RequestData(void* address){ 
	address_ = address;
	//run thread called here - might have to sync here as well
	this->Start();
    }
    
    //redefine run method for threading - define this external for 
    //modularity
    virtual void Run();
    //{
    //get data from hardware and write to memory location
    //}
};    

#endif
