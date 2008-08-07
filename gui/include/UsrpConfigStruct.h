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


///Global configuration structure 
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
    void SampleRate(const float& sampleRate); //complete
    void NumChannels(const int& numChannels); //complete
    void IPP(const int& ipp, const int& units); //complete
    void FPGAImage(const string& fpgaImage); //use default for now
    void DataWindow(const int& start, const int& size, const int& units);
    void Header(const HeaderStruct header); //complete
    void Decimation(const int& decimation); //complete
};

#endif
