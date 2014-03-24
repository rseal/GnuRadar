#include <ConsumerThread.h>
#include <cstring>

//redefine run method for threading
void ConsumerThread::Run(){ 
    memcpy(destination_,address_,bytes_);
}
