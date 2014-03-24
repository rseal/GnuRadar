// Copyright (c) 2012 Ryan Seal <rlseal -at- gmail.com>
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
#ifndef SYNCHRONIZED_BUFFER_MANAGER
#define SYNCHRONIZED_BUFFER_MANAGER

#include <Lock.h>
#include <SharedMemory.h>
#include <Mutex.hpp>

#include <boost/shared_ptr.hpp>
#include <vector>

class SynchronizedBufferManager
{
    typedef boost::shared_ptr<SharedMemory> SharedBufferPtr;
    typedef std::vector<SharedBufferPtr> SharedArray;
    SharedArray& array_;

    thread::Mutex mutex_;

    const int numBuffers_;
    const int bytesPerBuffer_;
    int head_;
    int tail_;
    int depth_;

public:

    SynchronizedBufferManager ( SharedArray& array, const int numBuffers, 
          const int bytesPerBuffer ) : array_ ( array ), 
    numBuffers_ ( numBuffers ), bytesPerBuffer_ ( bytesPerBuffer ), 
    head_ ( 0 ), tail_ ( 0 ), depth_ ( 0 ) { }

    void IncrementHead()
    {
       thread::ScopedLock lock ( mutex_ );
        if ( ++head_ == numBuffers_ ) head_ = 0;
        ++depth_;
    }

    void IncrementTail()
    {
       thread::ScopedLock lock ( mutex_ );
        if ( ++tail_ == numBuffers_ ) tail_ = 0;
        --depth_;
    }

    int Depth()
    {
       thread::ScopedLock lock( mutex_ );
        return depth_;
    }

    int BytesPerBuffer() { return bytesPerBuffer_; }
    int NumBuffers() { return numBuffers_; }
    int Head() { return head_; }
    int Tail() { return tail_; }
    
    void* WriteTo() { 
       return reinterpret_cast< void*>( array_[head_]->GetPtr() );
    }

    void* ReadFrom() { 
       return reinterpret_cast< void*>( array_[tail_]->GetPtr() );
    }

    bool OverFlow() {
       return depth_ > numBuffers_; 
    }

    /// Returns true if data is available - thread safe
    bool DataAvailable() {
       thread::ScopedLock scopedLock ( mutex_ );
       return ( depth_ != 0 ) ? true : false;
    }
};

#endif

