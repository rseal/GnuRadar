#ifndef SYNCHRONIZED_BUFFER_MANAGER
#define SYNCHRONIZED_BUFFER_MANAGER

#include <gnuradar/Lock.h>
#include <gnuradar/SharedMemory.h>
#include <gnuradar/Mutex.hpp>

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

    SynchronizedBufferManager (
        SharedArray& array,
        const int numBuffers,
        const int bytesPerBuffer ) : 
       array_ ( array ), numBuffers_ ( numBuffers ), 
       bytesPerBuffer_ ( bytesPerBuffer ), head_ ( 0 ), tail_ ( 0 ), 
       depth_ ( 0 )
    {
    }

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

    const int Depth()
    {
       thread::ScopedLock lock( mutex_ );
        return depth_;
    }

    const int BytesPerBuffer() { return bytesPerBuffer_; }
    const int NumBuffers() { return numBuffers_; }
    const int Head() { return head_; }
    const int Tail() { return tail_; }
    
    void* WriteTo() { 
       std::cout << "requesting write to " << array_[head_]->GetPtr() << std::endl;
       std::cout << "head = " << head_ << std::endl;
       return reinterpret_cast< void*>( array_[head_]->GetPtr() );
    }

    void* ReadFrom() { 
       return reinterpret_cast< void*>( array_[tail_]->GetPtr() );
    }

    const bool OverFlow() {
       return depth_ > numBuffers_; 
    }

    /// Returns true if data is available - thread safe
    const bool DataAvailable() {
       thread::ScopedLock scopedLock ( mutex_ );
       return ( depth_ != 0 ) ? true : false;
    }
};

#endif

