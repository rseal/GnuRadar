////////////////////////////////////////////////////////////////////////////////
///ChannelStruct.h
///
///
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef CHANNEL_STRUCT_H
#define CHANNEL_STRUCT_H
#include <iostream>
using std::cout;
using std::endl;
///Each USRP channel defines the down-conversion frequency
///and phase.
struct ChannelStruct{
public:
    float ddc;
    int ddcUnits;
    float phase;
    int phaseUnits;
    void Print(){
	cout << "ddc        = " << ddc        << "\n"
	     << "ddcUnits   = " << ddcUnits   << "\n" 
	     << "phase      = " << phase      << "\n"
	     << "phaseUnits = " << phaseUnits << endl;
    } 
};

#endif
