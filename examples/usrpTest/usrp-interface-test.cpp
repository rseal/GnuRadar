#include <usrp_standard.h>
#include <iostream>
#include <sys/time.h>
#include <fstream>
#include <sstream>


using std::cout;
using std::endl;
using namespace std;

int main(void)
{
    int numBuffers=10;
    int bytesRead=0;
    //16-bit I and Q
    int dataLength = 512*4;
    //data width (bytes)
    int dataWidth = sizeof(short);

    int samplesPerBuffer = dataLength / dataWidth;

    //create buffer
    short* dataBuffer = new short[dataLength*numBuffers];
    //overrun detection pointer
    bool overrun(false);

    usrp_standard_rx* usrp = usrp_standard_rx::make(0,16);
    usrp->set_rx_freq(0,9.9e6);
    usrp->start();
    sleep(1);
    //for(int i=0; i<16384; ++i){
//	for(int j=0; j<16384; ++j){}
    //  }
    short* address=0;
    for(int i=0; i<numBuffers; ++i){
	address = dataBuffer + dataLength*i;
	cout << "address = " << address << endl;
	bytesRead = usrp->read(reinterpret_cast<void*>(address), dataLength*2, &overrun);	
    }

    cout << "bytes read = " << bytesRead << endl;
    cout << "overrun = " << overrun << endl;
    //delay(5);
    usrp->stop();

//     for(int i=0; i<dataLength; ++i)
// 	cout << "data[" << i <<"] = " << dataBuffer[i] << endl;


    for(int i=0; i<numBuffers; ++i){
	ostringstream index;
	index << i;
	string fileName;
	fileName= "testdata";
	fileName = fileName + index.str() + ".dat";
	ofstream out(fileName.c_str(), ios::out);
	if(!out) cout << "couldn't open file" << endl;
	else{
	    //plot only I component
	    for(int j=0; j<samplesPerBuffer/2; ++j)
		out << dataBuffer[2*j + i*samplesPerBuffer] << endl;
	}	
	index.clear();
    }
    return 0;
}
