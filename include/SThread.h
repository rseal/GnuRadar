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
#ifndef STHREAD_H
#define STHREAD_H

#include <gnuradar/Mutex.hpp>
#include <gnuradar/Condition.hpp>
#include <gnuradar/Lock.h>

#include <iostream>
#include <time.h>
#include <errno.h>
#include <pthread.h>

namespace thread {

// units of time for sleep 
enum { USEC, MSEC, SEC};

class SThread {

public:

    SThread() {
        pthread_mutex_init ( &mutex_, NULL );
        pthread_attr_init ( &attr_ );
        pthread_cond_init ( &condition_, NULL );
    }

    virtual ~SThread() { } 
    virtual void Run() = 0;

    static void* Init ( void* _this ) {
        SThread* p_object = reinterpret_cast<SThread*> ( _this );
        p_object->Run();
        return NULL;
    }

    void Start() {
        int status = -1;
        status = pthread_create ( &p_sthread_, NULL, Init, this );
        if ( status < 0 )
            std::cerr << "STHREAD: thread creation failed" << std::endl;
    }

    void Wait() {
        pthread_join ( p_sthread_, NULL );
    }

    void Detach() {
        pthread_detach ( p_sthread_ );
    }

    void Destroy() {
        int status;
        pthread_exit ( reinterpret_cast<void*> ( &status ) );
    }

    void Lock ( pthread_mutex_t& mutex ) {
        pthread_mutex_lock ( &mutex );
    }

    void Unlock ( pthread_mutex_t& mutex ) {
        pthread_mutex_unlock ( &mutex );
    }

    void Pause() {
        ScopedPThreadLock Lock ( mutex_ );
        pthread_cond_wait ( &condition_, &mutex_ );
    }

    void Wake() {
        pthread_cond_signal ( &condition_ );
    }

    // alternative to share condition variable between 
    // threads
    void Wake( Condition& condition, Mutex& mutex ){
       ScopedLock lock( mutex );
       pthread_cond_signal( &condition.Get() );
    }

    // alternative to share condition variable between 
    // threads
    void Pause( Condition& condition, Mutex& mutex)
    {
       ScopedLock lock ( mutex );
       pthread_cond_wait( &condition.Get(), &mutex.Get() );
    }

    void Sleep ( int _type = USEC, long _value = 1000L ) {
        int status = 0;

        clock_gettime ( CLOCK_REALTIME , &cTime_ );

        switch ( _type ) {
        case USEC:
            fTime_ = cTime_;
            fTime_.tv_nsec += 1000L * _value;
            break;
        case MSEC:
            fTime_ = cTime_;
            fTime_.tv_nsec += _value * 1000000L;

            //hack to fix overflow problem
            if ( fTime_.tv_nsec > 1000000000L ) {
                fTime_.tv_nsec -= 1000000000L;
                fTime_.tv_sec++;
            }
            break;
        case SEC:
            fTime_ = cTime_;
            fTime_.tv_sec = cTime_.tv_sec + _value;
            break;
        default:
            std::cerr << "STHREAD: invalid sleep value. default to 1 sec" 
               << std::endl;
            fTime_ = cTime_;
            fTime_.tv_sec += 1;
        }

        ScopedPThreadLock Lock ( mutex_ );
        while ( status != ETIMEDOUT ) {
            status  = pthread_cond_timedwait ( &condition_, &mutex_, &fTime_ );
        }

    }

    void Priority ( int _value );
    void SetCondition ( int _value );

protected:
    pthread_t p_sthread_;
    pthread_mutex_t mutex_;
    pthread_attr_t attr_;
    pthread_cond_t condition_;
    timeval time_now_;
    timespec timeout_;
    timespec newTime_;
    timespec cTime_;
    timespec fTime_;
};
};
#endif
