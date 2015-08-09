#ifndef TIMER_US_H
#define TIMER_US_H

#include <sys/time.h>

uint64_t timer_us()
{
    timeval tv;
    gettimeofday(&tv, NULL);

    uint64_t ret = tv.tv_usec;
    ret += (tv.tv_sec * 1000000);

    return ret;
}
#endif 
