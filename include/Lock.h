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
#ifndef LOCK_H
#define LOCK_H

using namespace std;
#include <pthread.h>

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


class Mutex {
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
};

class ScopedLock {
    Mutex& mutex_;
public:
    ScopedLock ( Mutex& mutex ) : mutex_ ( mutex ) {
        mutex_.Lock();
    }
    ~ScopedLock() {
        mutex_.Unlock();
    }
};

class ScopedPThreadLock {
    pthread_mutex_t& mutex_;
public:
    ScopedPThreadLock ( pthread_mutex_t& mutex ) : mutex_ ( mutex ) {
        pthread_mutex_lock ( &mutex_ );
    }
    ~ScopedPThreadLock() {
        pthread_mutex_unlock ( &mutex_ );
    }
};

#endif
