#ifndef DEVICE_H
#define DEVICE_H

//interface for data source hardware
class Device {
public:
    virtual void StartDevice(void* address, const int bytes)=0;
    virtual void StopDevice()=0;
};


#endif
