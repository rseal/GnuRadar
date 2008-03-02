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
