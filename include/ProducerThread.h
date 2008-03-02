#ifndef PRODUCER_THREAD_H
#define PRODUCER_THREAD_H

#include <gnuradar/BaseThread.h>
#include <gnuradar/SThread.h>

class ProducerThread: public BaseThread, public SThread{
public:
    ProducerThread(const int& bytes):BaseThread(bytes),SThread(){
    }
    virtual void Stop(){ 
	//cleanup code for hardware here
    }
    virtual void RequestData(void* address){
	address_ = address;
	//call run thread here
	this->Start();
    }

    //redefine run method for threading - define this external for 
    //modularity
    virtual void Run(); 
};    

#endif
