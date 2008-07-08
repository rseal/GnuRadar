#ifndef CONSOLE_H
#define CONSOLE_H
#include <gnuradar/SThread.h>
#include <gnuradar/ProducerConsumerModel.h>

class Console: public SThread{
  ProducerConsumerModel& pcmodel_;
  std::string input_;
  bool quit_;

public:

  Console(ProducerConsumerModel& pcmodel): pcmodel_(pcmodel),quit_(false){this->Start();}
  virtual void Run(){
    while(true){
      cout << ">>>";
      cin >> input_;
      if(input_ == "quit") pcmodel_.Stop();
      sleep(1);
    }
  }
};

#endif
