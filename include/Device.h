#ifndef DEVICE_H
#define DEVICE_H

//interface for data source hardware
class Device{
public:
    virtual void Start(void* address, const int bytes)=0;
    virtual void Stop()=0;
};


#endif
