#ifndef SCHEULDER_H
#define SCHEDULER_H

#include <iostream>
#include <stdint.h>
#include <sys/time.h>
#include <SThread.h>
#include "timer_us.h"
using namespace thread;

#define NS_THRES_DEFAULT 1*ONE_E6;      // default of 1 ms seems to be okay for our system

class Scheduler {

    long interval_us_;          // time interval in us
    int ns_thres_;              // "close enough" threshold in ns to complete the run
    bool debug_;        // debugging messages enabled?

public:

    Scheduler() : 
        interval_us_( 15/60*ONE_E6 ), debug_( false ) { Run(); };
    
    Scheduler( int interval_s ) : 
        interval_us_( interval_s*ONE_E6 ), debug_( false ) { Run(); };

    Scheduler( int interval_s, bool debug ) : 
        interval_us_( interval_s*ONE_E6 ), debug_( debug ) { Run(); };

    void Run () {

        bool end = false;
        ns_thres_ = NS_THRES_DEFAULT;
        uint64_t target = 0;

        timeval tv;
        timespec te;

        // The idea here is that we get the current time and the target time (at multiples of
        //  interval_s), find the difference, and then wait half that time and repeat.  Once this 
        //  "waiting" time is below the threshold (ns_thres_), we go ahead and let the scheduler
        //  finish and the calling program can execute whatever it needs to.

        while(!end)  {
            gettimeofday( &tv, NULL );

            uint64_t startTime = tv.tv_usec + (uint64_t)(tv.tv_sec)*ONE_E6;

            if( startTime > target && target > 0 ) // failsafe end condition - sometimes the 
                break;                     //  threshold isn't really enough

            uint64_t waitTime = interval_us_ - (startTime % interval_us_);

            if(target == 0) 
                target = startTime + waitTime;

            if(debug_) std::cout << "waitTime: " << waitTime << "us" << std::endl;

            waitTime /= 2;
            te.tv_sec = waitTime / ONE_E6;
            te.tv_nsec = waitTime*ONE_E3 % ONE_E9;
            
            nanosleep( &te, NULL );

            if( (te.tv_sec < 1 && te.tv_nsec < ns_thres_) ) end = true; // desired end condition
        }
    
        if(debug_) {
            if(!end)
                std::cout << "Scheduler started late... :-(" << std::endl;
            else 
                std::cout << "Scheduler finished. Now back to your regularly scheduled program. :-)" << std::endl;
        }
    }
};
#endif

