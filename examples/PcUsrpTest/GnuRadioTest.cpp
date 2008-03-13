#include <gnuradar/ProducerConsumerModel.h>
#include <usrp_standard.h>
#include <gnuradar/GnuRadarDevice.h>
#include <gnuradar/GnuRadarSettings.h>
#include <gnuradar/SThread.h>

class Consume: public SThread{
    ProducerConsumerModel& pcModel_;
    void* buffer_;
public:
    Consume(ProducerConsumerModel& pcModel, void* buffer): pcModel_(pcModel),
								 buffer_(buffer){
	this->Start();
    }

    virtual void Run(){
	while(true){
	    pcModel_.RequestData(buffer_);
	}
    }
};
//patch-in class for now. Fix later
// class Console: public SThread{
//     std::string prompt_;
//     std::string input_;
//     bool quit_;

// public:
//     Console():prompt_(">>>"), input_(""), quit_(false){}

//     virtual void Run(){
// 	while(!quit_){
// 	    cout << prompt_ << endl;
// 	    cin >> input_;
// 	    if(input_ == "quit") quit_ = true;
// 	}
//     }

//     const bool Running() { return !quit_;}
// };

int main(){

    //Initialize classes
    const int kb = 1024;
    const int Mb = kb*kb;
    const int bufferSize = 100*kb;
    const int numBuffers = 10;

    //create consumer buffer - destination 
    int* buffer = new int[bufferSize/sizeof(int)];

    //Parse GNURadio configuration file here (gcf) with Parser Class
    GnuRadarSettings settings;
    settings.Tune(0,10e6);
    settings.decimationRate = 16;
    settings.fUsbBlockSize = 0;
    settings.fUsbNblocks = 0;

    GnuRadarDevice grDevice(settings);

    ProducerConsumerModel pcmodel(bufferSize,buffer,numBuffers,sizeof(int),"testBuffer",grDevice);
    pcmodel.Start();
    int i=0;
  
    //Consume consume(pcmodel,buffer);

    // while(true){ sleep(10);}
    //Console console;
    //console.Start();
    pcmodel.RequestData(buffer);
    //while(true){ pcmodel.RequestData(buffer);}

//    pcmodel.Stop();
    pcmodel.Wait();
    return 0;
};


