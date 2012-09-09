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
#ifndef CONSUMER_THREAD_H
#define CONSUMER_THREAD_H

#include <boost/shared_ptr.hpp>
#include <boost/filesystem.hpp>

#include <gnuradar/Condition.hpp>
#include <gnuradar/Mutex.hpp>
#include <gnuradar/SynchronizedBufferManager.hpp>
#include <gnuradar/BaseThread.h>
#include <gnuradar/SThread.h>
#include <gnuradar/yaml/SharedBufferHeader.hpp>

#include<hdf5r/HDF5.hpp>
#include<hdf5r/Complex.hpp>
#include<hdf5r/Time.hpp>

#include <fstream>

class ConsumerThread: public BaseThread, public thread::SThread {
   
   typedef boost::shared_ptr< SynchronizedBufferManager > 
      SynchronizedBufferManagerPtr;
   typedef boost::shared_ptr< yml::SharedBufferHeader >
      SharedBufferHeaderPtr;

   SynchronizedBufferManagerPtr bufferManager_;
   boost::shared_ptr<HDF5> h5File_;
   ComplexHDF5 cpx_;
   H5::DataSpace space_;
   SharedBufferHeaderPtr header_;
   Time time_;

   public:

   ConsumerThread (
         SynchronizedBufferManagerPtr bufferManager,
         SharedBufferHeaderPtr header,
         boost::shared_ptr<HDF5> h5File,
         std::vector<hsize_t> dims
         ) : 
      BaseThread ( bufferManager->BytesPerBuffer() ), thread::SThread(), 
      bufferManager_( bufferManager ), header_( header ), h5File_ ( h5File ),
      space_ ( 2, &dims[0] ) { }

   virtual void Stop() {
      running_ = false;
      this->Wake( *BaseThread::condition_, *BaseThread::mutex_ );
      this->Wait();
   }

   virtual void RequestData ( void* address ) {}

   //redefine run method locally for threading - this provides
   //modularity and a clean interface for testing/verification
   virtual void Run();
};

#endif
