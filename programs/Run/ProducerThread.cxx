#include <gnuradar/ProducerThread.h>

void ProducerThread::Run()
{
    device_.StartDevice(address_,bytes_);
}
