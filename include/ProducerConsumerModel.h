#ifndef PRODUCER_CONSUMER_MODEL_H
#define PRODUCER_CONSUMER_MODEL_H

#include <gnuradar/ProducerThread.h>
#include <gnuradar/ConsumerThread.h>
#include <gnuradar/Lock.h>
#include <gnuradar/ProducerConsumerExceptions.h>
#include <gnuradar/SThread.h>
#include <boost/shared_ptr.hpp>
#include <iostream>
#include <sstream>
#include <vector>

using std::string;
using std::vector;
using boost::shared_ptr;

//notes
//To use this model properly, instantiate this class in your main code.
//You must define the Run() functions for both ConsumerThread and ProducerThread
//classes. These create the threads needed for proper operation. The producer
//will retrieve data from the source and place in an intermediate buffer. The 
//consumer will request data from the intemediate buffer as needed. The consumer
//must be able to call data at least as fast as the producer can produce it. Many
//times the consumer will be able to read rapidly for short bursts and the buffer
//is available to average these bursty reads so you don't overflow and lose data 
//due to unseen latencies.

struct ProducerConsumerModel: public SThread {
    const int& bytes_;
    const int& buffers_;
    const std::string& baseFileName_;
    std::auto_ptr<ProducerThread> pThread_;
    std::auto_ptr<ConsumerThread> cThread_;
    int head_;
    int tail_;
    int depth_;
    Mutex mutex_;
    void* memBuffer;
    void* memIndex;
    void* destination_;
    const int& dataWidth_;
    int error_;

    vector< boost::shared_ptr<SharedMemory> > bufferPtr_;
    bool stop_;
    bool overFlow_;
  
    
    std::string FileName(){
	//lock head_ variable
	ScopedLock scopedLock(mutex_);
	std::ostringstream ostr;
	ostr << head_;
	return baseFileName_ + ostr.str() + ".buf";
    }

    //lock head variable
    void IncrementHead(){
	ScopedLock scopedLock(mutex_);
	if(depth_ == buffers_) overFlow_ = true;
	if(++head_ == buffers_) head_=0;
    }

    //lock tail variable for update
    void IncrementTail(){
	ScopedLock scopedLock(mutex_);
	if(++tail_ == buffers_) tail_=0;
    }

    void IncrementDepth(){
	ScopedLock scopedLock(mutex_);
	++depth_;
    }

    void DecrementDepth(){
	ScopedLock scopedLock(mutex_);
	--depth_;
    }

    bool DataAvailable(){
	ScopedLock scopedLock(mutex_);
	return (depth_ != 0) ? true:false;
    }

    //track variables for debugging/testing
    void Debug(){
	ScopedLock scopedLock(mutex_);
	cout << "head = " << head_ << " tail = " << tail_ << " depth = " << depth_ << endl;
    }

public:
    ProducerConsumerModel(const int& bytes, void* destination, 
			  const int& buffers, const int& dataWidth, 
			  const std::string baseFileName):
	bytes_(bytes), destination_(destination),buffers_(buffers), 
	baseFileName_(baseFileName),head_(),tail_(),depth_(),
	dataWidth_(dataWidth),stop_(false),overFlow_(false){

	//create producer and consumer
	pThread_.reset(new ProducerThread(bytes_));
	cThread_.reset(new ConsumerThread(bytes_,destination_));
	
	//create vector of memory buffers in /dev/shm using POSIX shared memory (tmpfs)
	for(int i=0; i<buffers_; ++i){
	    std::ostringstream ostr;
	    ostr << i;
	    string bufferStr = baseFileName_ + ostr.str() + ".buf";
	    boost::shared_ptr<SharedMemory> bufPtr(new SharedMemory(bufferStr, bytes_, SHM::CreateShared, 0666));
	    bufferPtr_.push_back(bufPtr);
	}
    }
   
    virtual void Run(){
	//Run Until User Tells Us To Stop
	while(!stop_){
	    if(OverFlow()) throw PCException::OverFlow();
	    //Request Data From Hardware And Return Error Status
	    pThread_->RequestData((bufferPtr_[head_])->GetPtr());
	    //Sync Thread To Keep Data Streaming Properly
	    pThread_->Wait();
	    //Increment Head
	    IncrementHead();
	    IncrementDepth();
	    //wake up consumer
	    cThread_->Wake();
	    //sleep(1);
	}
    }

    void RequestData(void* memory){
	if(DataAvailable()){
	    cThread_->RequestData((bufferPtr_[tail_])->GetPtr());
	    Debug();
	    cThread_->Wait();
	    IncrementTail();
	    DecrementDepth();
	}else{
	    cThread_->Sleep();
	    cout << "consumer sleeping" << endl;
	}
    }
    
    const bool& OverFlow() { return overFlow_;}

};

#endif
