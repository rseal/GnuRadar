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

class BaseThread{
public:
    BaseThread(const int& bytes):bytes_(bytes){}
    virtual const int&         Status() { return status_;}
    virtual const std::string& Error()  { return error_;}
    //abstract classes 
    virtual void Stop()=0;
    virtual void RequestData(void* address)=0;
protected:
    void* address_;
    const int& bytes_;
    int  status_;
    std::string error_;
};

#endif
