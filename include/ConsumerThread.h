#ifndef CONSUMER_THREAD_H
#define CONSUMER_THREAD_H

#include <gnuradar/BaseThread.h>
#include <gnuradar/SThread.h>
#include <simpleHeader/Shs.h>
#include <simpleHeader/Time.h>

class ConsumerThread: public BaseThread, public SThread{
    void* destination_;
    SimpleHeader<short,2>& shs_;

public:
    
    ConsumerThread(const int& bytes, void* destination, SimpleHeader<short,2>& shs)
	:BaseThread(bytes),SThread(),destination_(destination),shs_(shs){
    }

    virtual void Stop(){ 
	//cleanup code for hardware here
    }

    virtual void RequestData(void* address){ 
	address_ = address;
	//run thread called here - might have to sync here as well
	this->Start();
    }
    
    //redefine run method locally for threading - this provides 
    //modularity and a clean interface for testing/verification
    virtual void Run();
    
};    

#endif
