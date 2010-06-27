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
