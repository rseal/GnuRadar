#include <gnuradar/ProducerConsumerModel.h>

int main(){
    //ProducerConsumerModel(const int& bytes, const int& buffers, const int& dataWidth, const std::string baseFileName):
    const int kb = 1024;
    const int Mb = kb*kb;
    const int bufferSize = 40*Mb;
    const int numBuffers = 10;

    //create consumer buffer 
    int* buffer = new int[bufferSize/sizeof(int)];

    ProducerConsumerModel pcmodel(bufferSize,buffer,numBuffers,sizeof(int),"testBuffer");
    pcmodel.Start();
    int i=0;
    while(true){
	switch(i){
	case 0: usleep(850000);break;
	case 1: usleep(2250000);break;
	case 2: usleep(750000);break;
	case 3: usleep(250000);break;
	}
	
	if(++i==4) i=0;
	pcmodel.RequestData(buffer);
    }
	//pcmodel.Wait();

    return 0;
};
