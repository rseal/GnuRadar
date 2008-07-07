#include <gnuradar/ConsumerThread.h>
#include <simpleHeader/Time.h>

//redefine run method for threading
// void ConsumerThread::Run(){ 
//     static bool keywordInit = false;
//     Time time;

//     if(!keywordInit){
// 	//create constants in data table shs_
// 	shs_.data.Add("TIME", time.GetTime(), "System time (CDT)");
// 	keywordInit = true;
//     } 
//     else{
// 	shs_.data.Value("TIME", time.GetTime(), "System time (CDT)");
//     }    

//     shs_.WriteTable(reinterpret_cast<short*>(address_),bytes_);
// }

