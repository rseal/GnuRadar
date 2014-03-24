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

#include <Mutex.hpp>
#include <Condition.hpp>
#include <Lock.h>

#include <iostream>
#include <map>
#include <time.h>
#include <errno.h>
#include <pthread.h>

namespace thread {

	// units of time for sleep 
	enum { NSEC, USEC, MSEC, SEC};

	const static long ONE_E0=1L;
	const static long ONE_E3=1000L;
	const static long ONE_E6=1000000L;
	const static long ONE_E9=1000000000L;


	class SThread {

		std::map< long, double > unitMap_;

		public:

		SThread() {
			pthread_mutex_init ( &mutex_, NULL );
			pthread_attr_init ( &attr_ );
			pthread_cond_init ( &condition_, NULL );
			unitMap_[ NSEC ] = ONE_E9;
			unitMap_[ USEC ] = ONE_E6;
			unitMap_[ MSEC ] = ONE_E3;
			unitMap_[ SEC ] = ONE_E0;
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

		void Sleep ( int type = USEC, long value = ONE_E3 ) {

			double time = value;
			double multiplier = unitMap_.find( type )->second;

			fTime_.tv_sec = 0;
			fTime_.tv_nsec = 0;

			while( time >= multiplier ){ 
				time -= multiplier;
				fTime_.tv_sec += 1;
			}

			fTime_.tv_nsec = thread::ONE_E9*time/multiplier;

			ScopedPThreadLock lock ( mutex_ );
			nanosleep(&fTime_, NULL);
		}

		void Priority ( int value );
		void SetCondition ( int value );

		protected:
		pthread_t p_sthread_;
		pthread_mutex_t mutex_;
		pthread_attr_t attr_;
		pthread_cond_t condition_;
		timeval time_now_;
		timespec cTime_;
		timespec fTime_;
	};
};
#endif
