#ifndef PRODUCER_CONSUMER_MODEL_H
#define PRODUCER_CONSUMER_MODEL_H

#include <gnuradar/ProducerThread.h>
#include <gnuradar/ConsumerThread.h>
#include <gnuradar/Lock.h>
#include <gnuradar/ProducerConsumerExceptions.h>
#include <gnuradar/SThread.h>
#include <gnuradar/Device.h>

#include <boost/shared_ptr.hpp>
#include <boost/lexical_cast.hpp>

#include <iostream>
#include <vector>

#include<HDF5/HDF5.hpp>
#include<HDF5/Complex.hpp>

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
   Device& device_;

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

   std::vector<boost::shared_ptr<SharedMemory> > bufferPtr_;
   bool stop_;
   bool stopProducer_;
   bool stopConsumer_;
   bool overFlow_;

   std::string FileName(){
      //lock head_ variable
      ScopedLock scopedLock(mutex_);
      return baseFileName_ + boost::lexical_cast<string>(head_) + ".buf";
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
      cout << endl << ">>> head = " << head_ << " tail = " << tail_ << " depth = " << depth_ << endl;
   }

   public:
   ProducerConsumerModel
      ( 
       const int& bytes, 
       void* destination, 
       const int& buffers, 
       const int& dataWidth, 
       const std::string baseFileName, 
       Device& device, 
       boost::shared_ptr<HDF5> const h5File, 
       std::vector<hsize_t>& dims
      )
      :  bytes_(bytes), destination_(destination),buffers_(buffers), 
      baseFileName_(baseFileName), device_(device), head_(),
      tail_(),depth_(),dataWidth_(dataWidth),stop_(false),
      stopProducer_(false),stopConsumer_(false),overFlow_(false)
   {
      //create producer and consumer
      pThread_.reset(new ProducerThread(bytes_,device_));
      cThread_.reset(new ConsumerThread(bytes_,destination_, h5File, dims));

      //create std::vector of memory buffers in /dev/shm using POSIX shared memory (tmpfs)
      for(int i=0; i<buffers_; ++i){
         std::string bufferStr = baseFileName_ + boost::lexical_cast<string>(i) + ".buf";
         boost::shared_ptr<SharedMemory> bufPtr(new SharedMemory(bufferStr, bytes_, SHM::CreateShared, 0666));
         bufferPtr_.push_back(bufPtr);
      }
   }

   virtual void Run(){

      stopProducer_ = false;
      stopConsumer_ = false;

      //Run Until User Tells Us To Stop
      while(!stopProducer_){
         if(OverFlow()) throw PCException::OverFlow();
         //Request Data From Hardware And Return Error Status
         pThread_->RequestData((bufferPtr_[head_])->GetPtr());
         //cout << "producer thread " << head_ << endl;
         //Sync Thread To Keep Data Streaming Properly
         pThread_->Wait();
         //Increment Head
         IncrementHead();
         IncrementDepth();
         //wake up consumer
         cThread_->Wake();
         //sleep(1);
      }
      pThread_->Stop();
      cout << "ProducerConsumerModel: Producer Stopped" << endl;

   }

   void RequestData(void* memory){

      while(!stopConsumer_){

         if(!DataAvailable()) cThread_->Pause();

         cThread_->RequestData((bufferPtr_[tail_])->GetPtr());
         Debug();
         cThread_->Wait();
         IncrementTail();
         DecrementDepth();
      }
      cout << "ProducerConsumerModel: Consumer Stopped" << endl;
   }

   const bool& OverFlow() { return overFlow_;}

   void Stop(void){ 
      stopConsumer_=true;
      cThread_->Wait();
      stopProducer_ = true;
      cout << "ProducerConsumerModel: System Stop activated" << endl;
   } 
};

#endif
