////////////////////////////////////////////////////////////////////////////////
///UsrpConfigStruct.h
///
///Provides necessary rule checking and conversions for displayed/stored 
///configuration data.
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef USRP_CONFIG_H
#define USRP_CONFIG_H

#include <iostream>
#include <vector>
#include <boost/lexical_cast.hpp>

#include "ChannelStruct.h"
#include "DataWindowStruct.h"
#include "HeaderStruct.h"

using std::string;
using std::vector;
using boost::lexical_cast;
using std::cerr;
using std::endl;

namespace USRP{
    typedef vector<DataWindowStruct> WindowVector;
    typedef vector<ChannelStruct> ChannelVector;
};

///Global configuration structure 
struct UsrpConfigStruct{
private:
    bool validSampleRate_;
    USRP::WindowVector  windows_;
    USRP::ChannelVector channels_;
    HeaderStruct header_;

public:

    UsrpConfigStruct(): validSampleRate_(false),channels_(4),
			sampleRate(64e6),decimation(8),numChannels(1),
			ipp(0),fpgaImage("../../fpga/std_4rx_0tx.rbf"){}

    USRP::ChannelVector& ChannelRef() { return channels_;} //validation complete - mostly
    USRP::WindowVector& WindowRef() { return windows_;}
    HeaderStruct& HeaderRef() { return header_;} //no need - for now
    
    float sampleRate;   //validation complete
    int decimation;     //validation complete
    int numChannels;    //validation complete
    int ipp;            //validation complete
    int ippUnits;       //validation complete
    string fpgaImage;   //no need - for now
};

#endif
