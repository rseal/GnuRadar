#include <gnuradar/ConsumerThread.h>

//redefine run method for threading - define this external for 
//modularity
void ConsumerThread::Run(){
   h5File_->CreateTable(cpx_.GetRef(), space_);
   h5File_->WriteTStrAttrib("TIME", time_.GetTime());
   h5File_->WriteTable(reinterpret_cast<void*>(address_));
}
