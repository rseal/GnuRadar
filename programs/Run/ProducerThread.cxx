#include <gnuradar/ProducerThread.h>

void ProducerThread::Run()
{
    device_.Start(address_,bytes_);
}
