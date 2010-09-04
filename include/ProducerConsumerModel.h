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

namespace gnuradar {

typedef boost::shared_ptr<ProducerThread> ProducerThreadPtr;
typedef boost::shared_ptr<ConsumerThread> ConsumerThreadPtr;

struct ProducerConsumerModel: public SThread {

    int numBuffers_;
    int bytesPerBuffer_;
    std::string baseFileName_;

    typedef boost::shared_ptr<SharedMemory> SharedMemoryPtr;
    typedef std::vector<SharedMemoryPtr> SharedMemoryVector;

    SharedMemoryVector bufferArray_;
    ProducerThreadPtr producerThread_;
    ConsumerThreadPtr consumerThread_;

    int head_;
    int tail_;
    int depth_;

    Mutex mutex_;
    void* memBuffer;
    void* memIndex;
    int error_;

    bool stop_;
    bool stopProducer_;
    bool stopConsumer_;
    bool overFlow_;

    /// Returns the FileName - thread safe
    std::string FileName() {
        ScopedLock scopedLock ( mutex_ );
        return baseFileName_ + boost::lexical_cast<string> ( head_ ) + ".buf";
    }

    /// Increments the buffer head - thread safe
    void IncrementHead() {
        ScopedLock scopedLock ( mutex_ );
        if ( depth_ == numBuffers_ ) overFlow_ = true;
        if ( ++head_ == numBuffers_ ) head_ = 0;
    }

    /// Increments the buffer tail - thread safe
    void IncrementTail() {
        ScopedLock scopedLock ( mutex_ );
        if ( ++tail_ == numBuffers_ ) tail_ = 0;
    }

    /// Increases the buffer depth - thread safe
    void IncrementDepth() {
        ScopedLock scopedLock ( mutex_ );
        ++depth_;
    }

    /// Decreases buffer depth - thread safe
    void DecrementDepth() {
        ScopedLock scopedLock ( mutex_ );
        --depth_;
    }

    /// Returns true if data is available - thread safe
    bool DataAvailable() {
        ScopedLock scopedLock ( mutex_ );
        return ( depth_ != 0 ) ? true : false;
    }

    void CreateSharedBuffers() {

        // setup shared memory buffers
        for ( int i = 0; i < numBuffers_; ++i ) {

            // create unique buffer file names
            std::string bufferName = baseFileName_ +
                                     boost::lexical_cast<string> ( i ) + ".buf";

            // create shared buffers
            SharedMemoryPtr bufPtr (
                new SharedMemory (
                    bufferName,
                    bytesPerBuffer_,
                    SHM::CreateShared,
                    0666 )
            );

            // store buffer in a vector
            bufferArray_.push_back ( bufPtr );
        }

    }

    /// track variables for debugging/testing - thread safe
    void Debug() {

        ScopedLock scopedLock ( mutex_ );
        cout
            << endl << ">>> head = "
            << head_ << " tail = "
            << tail_ << " depth = "
            << depth_
            << endl;
    }

    void Initialize (
        const std::string& baseFileName,
        const int numBuffers,
        const int bytesPerBuffer,
        ProducerThreadPtr producerThread,
        ConsumerThreadPtr consumerThread
    ) {

        baseFileName_ =  baseFileName;
        numBuffers_  = numBuffers;
        bytesPerBuffer_  = bytesPerBuffer;

        // initialize buffer markers
        head_ = 0;
        tail_ = 0;
        depth_ = 0;

        // initialize flags
        stop_ = false;
        stopProducer_ = false;
        stopConsumer_ = false;
        overFlow_ = false;

        //create producer and consumer
        producerThread_ = producerThread;
        consumerThread_ = consumerThread;

        CreateSharedBuffers();

    }
public:

    ProducerConsumerModel() {}

    /// Constructor
    ProducerConsumerModel (
        const std::string& baseFileName,
        const int numBuffers,
        const int bytesPerBuffer,
        ProducerThreadPtr producerThread,
        ConsumerThreadPtr consumerThread
    ) {

        Initialize ( baseFileName, numBuffers, bytesPerBuffer, producerThread,
                     consumerThread );
    }

    /// start producer thread
    virtual void Run() {

        stopProducer_ = false;
        stopConsumer_ = false;

        //Run Until User Tells Us To Stop
        while ( !stopProducer_ ) {

            // if the buffer overflows - throw an exception
            if ( OverFlow() ) throw PCException::OverFlow();

            //Request Data From Hardware And Return Error Status
            producerThread_->RequestData ( ( bufferArray_[head_] )->GetPtr() );

            //Sync Thread To Keep Data Streaming Properly
            producerThread_->Wait();

            IncrementHead();
            IncrementDepth();

            //wake up consumer
            consumerThread_->Wake();
        }

        producerThread_->Stop();
        cout << "ProducerConsumerModel: Producer Stopped" << endl;
    }

    /// start consumer thread
    void RequestData() {

        while ( !stopConsumer_ ) {

            // if no data is available - wait for signal
            if ( !DataAvailable() ) consumerThread_->Pause();

            // Request data from the shared buffer
            consumerThread_->RequestData ( ( bufferArray_[tail_] )->GetPtr() );

            // print debug information
            // TODO: Replace this and implement some sort of port
            // accessible status calls
            //Debug();

            // wait for thread to complete before continuing
            consumerThread_->Wait();

            // update pointers
            IncrementTail();
            DecrementDepth();
        }

        cout << "ProducerConsumerModel: Consumer Stopped" << endl;
    }

    /// Return true if numBuffers have overflowed.
    const bool& OverFlow() {
        return overFlow_;
    }

    /// Stop the producer and consumer.
    void Stop ( void ) {
        stopConsumer_ = true;
        consumerThread_->Wait();
        stopProducer_ = true;
        cout << "ProducerConsumerModel: System Stop activated" << endl;
    }

    const int& Head() { return head_; }
    const int& Tail() { return tail_; }
    const int& Depth() { return depth_; }
    const int& NumBuffers() { return numBuffers_; }
    const int& BytesPerBuffer() { return bytesPerBuffer_; }
};
};
#endif
