#include <ProducerThread.h>

//redefine run method for threading
void ProducerThread::Run(){ 
    int* temp = reinterpret_cast<int*>(address_);
    for(int i=0; i<bytes_/sizeof(int); ++i){
	temp[i]=i;
    }
    sleep(1);
}
