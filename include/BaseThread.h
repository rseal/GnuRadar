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
#ifndef BASE_THREAD_H
#define BASE_THREAD_H

#include <gnuradar/SharedMemory.h>
#include <gnuradar/SThread.h>
#include <gnuradar/Mutex.hpp>
#include <gnuradar/Condition.hpp>

/// Abstract class for use with Producer and Consumer threads.
class BaseThread {

public:

    // Constructor.
    BaseThread ( const int bytes ) : bytes_ ( bytes ),
    running_(false){}

    // abstract members
    virtual const int Status() {
        return status_;
    }

    virtual const std::string& Error()  {
        return error_;
    }

    //virtual members
    virtual void Stop() = 0;
    virtual void RequestData ( void* address ) = 0;

    void Mutex( thread::MutexPtr mutex ) { mutex_ = mutex; }
    void Condition( thread::ConditionPtr condition ) { condition_ = condition; }

protected:

    void* address_;
    const int bytes_;
    int  status_;
    std::string error_;
    bool running_;

    thread::MutexPtr mutex_;
    thread::ConditionPtr condition_;

};

#endif
