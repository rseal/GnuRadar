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
#ifndef PRODUCER_THREAD_H
#define PRODUCER_THREAD_H

#include <gnuradar/BaseThread.h>
#include <gnuradar/SThread.h>
#include <gnuradar/Device.h>

//added generic device class so producer can act properly
//by calling thread using generic calls to start and stop
//this means that user will now define functionality inside
//device class as opposed to the sthread Run() function

class ProducerThread: public BaseThread, public SThread{
    Device& device_;

public:
    ProducerThread(const int& bytes, Device& device):
	BaseThread(bytes),SThread(),device_(device){
    }

    virtual void Stop(){ 
	device_.StopDevice();
    }

    virtual void RequestData(void* address){
	address_ = address;
	this->Start();
    }
    
    //run now calls device class start() member to 
    //modularize system - i.e. define device class
    //start() for functionality
    virtual void Run();

};    

#endif
