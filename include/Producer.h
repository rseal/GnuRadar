#include <gnuradar/BaseThread.h>
#include <gnuradar/SThread.h>

class ProducerThread, public BaseThread, public SThread{
    int& bytes_;
    int& shMemKey_;
    int  status_;
    std:string error_;

public:
    ProducerThread(int& bytes,int& shMemKey):bytes_(bytes),shMemKey_(shMemKey){
    }
    const int&         Status() { return status_;}
    const std::string& Error()  { return error_;}
    void Stop(){ 
      //cleanup code for hardware here
    }
    void ProduceData(void* address){ 
        //get data from hardware and write to memory location
    }
    void ProduceData(const std:string& fileName){
	//get data from hardware and write to file (tmpfs)
    }

};
