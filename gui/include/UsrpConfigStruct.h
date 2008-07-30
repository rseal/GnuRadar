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


//primary configuration structure 
struct UsrpConfigStruct{
private:
    bool validSampleRate_;
    vector<ChannelStruct> channels_;
    vector<DataWindowStruct> windows_;
    HeaderStruct header_;
    float sampleRate_;
    int decimation_;
    int numChannels_;
    int ipp_;
    int ippUnits_;
    string fpgaImage_;

public:
    UsrpConfigStruct(); 
    void Channel(const int& chNum, const float& ddc, const float& phase);
    void SampleRate(const float& sampleRate);
    void NumChannels(const int& numChannels);
    void IPP(const int& ipp, const int& units);
    void FPGAImage(const string& fpgaImage);
    void DataWindow(const int& start, const int& size, const int& units);
    void Header(const HeaderStruct& header);
};

#endif
