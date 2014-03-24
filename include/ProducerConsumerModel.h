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

#include <SynchronizedBufferManager.hpp>
#include <ProducerThread.h>
#include <ConsumerThread.h>
#include <ProducerConsumerExceptions.h>
#include <Mutex.hpp>
#include <Condition.hpp>
#include <boost/shared_ptr.hpp>

#include <iostream>

namespace gnuradar {

	static const std::string BUFFER_BASE_NAME = "GnuRadar";

	thread::MutexPtr mutex_;
	thread::ConditionPtr condition_;

	typedef boost::shared_ptr<ProducerThread> ProducerThreadPtr;
	typedef boost::shared_ptr<ConsumerThread> ConsumerThreadPtr;

	struct ProducerConsumerModel {

		typedef boost::shared_ptr<SynchronizedBufferManager> 
			SynchronizedBufferManagerPtr; 
		typedef boost::shared_ptr<HDF5> Hdf5Ptr;

		thread::MutexPtr mutex_;
		thread::ConditionPtr condition_;

		SynchronizedBufferManagerPtr bufferManager_;
		ProducerThreadPtr producer_;
		ConsumerThreadPtr consumer_;

		public:

		void Initialize(
				SynchronizedBufferManagerPtr bufferManager,
				ProducerThreadPtr producer,
				ConsumerThreadPtr consumer)
		{
			bufferManager_ = bufferManager;
			producer_ = producer;
			consumer_ = consumer;

			mutex_ = thread::MutexPtr( new thread::Mutex() );
			condition_ = thread::ConditionPtr( new thread::Condition() );

			producer_->Mutex( mutex_ );
			producer_->Condition( condition_ );
			consumer_->Mutex( mutex_ );
			consumer_->Condition( condition_ );
		}

		/// start producer thread
		void Start() {

			// crank up threads and fall through
			consumer_->Start();
			consumer_->Detach();
			producer_->Start();
			producer_->Detach();

		}

		/// Stop the producer and consumer.
		void Stop ( void ) {

			std::cout << "ProducerConsumerModel: System Stop " << std::endl;
			// each thread should wait until all operations 
			// have completed before exiting.
			consumer_->Stop();
			producer_->Stop();
		}

		// status information for diagno)stics
		int Head()           { return bufferManager_->Head();           } 
		int Tail()           { return bufferManager_->Tail();           } 
		int Depth()          { return bufferManager_->Depth();          } 
		int NumBuffers()     { return bufferManager_->NumBuffers();     } 
		int BytesPerBuffer() { return bufferManager_->BytesPerBuffer(); } 
		bool OverFlow()      { return bufferManager_->OverFlow();       } 
	};
};
#endif
