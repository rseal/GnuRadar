#ifndef MUTEX_HPP
#define MUTEX_HPP

#include <pthread.h>
#include <iostream>

#include <boost/shared_ptr.hpp>

namespace thread{

class MutexException {
public:
    virtual void PrintError() {
        std::cerr << "Mutex Exception" << std::endl;
    }
    virtual ~MutexException() {}
};

class LockException: public MutexException {
public:
    virtual void PrintError() {
        std::cerr << "Lock Exception" << std::endl;
    }
};

class UnlockException: public MutexException {
public:
    virtual void PrintError() {
        std::cerr << "Unlock Exception" << std::endl;
    }
};

struct Mutex {
    pthread_mutex_t mutex_;
    pthread_mutexattr_t attr_;
public:
    Mutex() : mutex_() {
        pthread_mutexattr_init ( &attr_ );
        pthread_mutexattr_setpshared ( &attr_, PTHREAD_PROCESS_SHARED );
        pthread_mutex_init ( &mutex_, &attr_ );
    }
    ~Mutex() {
        pthread_mutex_destroy ( &mutex_ );
    }

    void Lock() {
        if ( pthread_mutex_lock ( &mutex_ ) ) throw LockException();
    }

    void Unlock() {
        if ( pthread_mutex_unlock ( &mutex_ ) ) throw UnlockException();
    }

    // compatibility member
    pthread_mutex_t& Get() { return mutex_; }
};

   typedef boost::shared_ptr<Mutex> MutexPtr;

};
#endif
