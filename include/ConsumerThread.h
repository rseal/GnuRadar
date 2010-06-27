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
#ifndef CONSUMER_THREAD_H
#define CONSUMER_THREAD_H

#include <gnuradar/BaseThread.h>
#include <gnuradar/SThread.h>
#include<HDF5/HDF5.hpp>
#include<HDF5/Complex.hpp>
#include<HDF5/Time.hpp>

class ConsumerThread: public BaseThread, public SThread{
    void* destination_;
    boost::shared_ptr<HDF5> h5File_;
    ComplexHDF5 cpx_;
    H5::DataSpace space_;
    Time time_;

public:
    
    ConsumerThread(const int& bytes, void* destination, boost::shared_ptr<HDF5> const h5File, vector<hsize_t>& dims)
	:BaseThread(bytes),SThread(),destination_(destination),h5File_(h5File), space_(2,&dims[0]){
    }

    virtual void Stop(){ 
	//cleanup code for hardware here
    }

    virtual void RequestData(void* address){ 
	address_ = address;
	//run thread called here - might have to sync here as well
	this->Start();
    }
    
    //redefine run method locally for threading - this provides 
    //modularity and a clean interface for testing/verification
    virtual void Run();
    
};    

#endif
