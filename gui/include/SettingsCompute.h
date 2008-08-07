////////////////////////////////////////////////////////////////////////////////
///SettingsCompute.h
///
///Formats and verifies proper sample rate / bandwidth / decimation settings.
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef SETTINGS_COMPUTE_H
#define SETTINGS_COMPUTE_H

#include <iostream>
#include <boost/lexical_cast.hpp>

using std::cout;
using std::endl;
using std::string;
using boost::lexical_cast;


///Validates selected parameters and formats for display as needed.
struct SettingsCompute{

    float sampleRate_;
    int   decimation_;
    float bandwidth_;
    int   channels_;

    ///Checks all parameters and returns true if valid
    const bool ValidateParameters() { 
        bool valid(true);
	if(sampleRate_ < 1e6 || sampleRate_ > 64e6) valid = false;
	if(decimation_%2 != 0) valid = false;
	if(decimation_ < 8 || decimation_ > 256) valid = false;
	return valid;
    }

    ///Update system's bandwidth bassed on channel, sample rate, and decimation 
    ///settings.
    void Update(){
	if(ValidateParameters())
	    bandwidth_ = sampleRate_ / (channels_ * decimation_);
	else
	    cout << "Invalid input parameter given - NO CHANGES MADE" << endl;
    }

public:
    ///Constructor
    SettingsCompute(): sampleRate_(64e6), decimation_(8), bandwidth_(8e6), channels_(1){}

    ///Returns sample rate
    const float& SampleRate()       { return sampleRate_;}
    ///Returns string representation of sample rate
    const char*  SampleRateString() { 
	string str = lexical_cast<string>(sampleRate_/1e6);
	return str.c_str();
    }
    ///Returns decimation
    const int&   Decimation()       { return decimation_;}
    ///Returns bandwidth
    const float& Bandwidth()        { return bandwidth_;}
    ///Returns channels
    const int&   Channels()         { return channels_;}
    ///Returns string representation of bandwidth
    const char* BandwidthString()   {
	string str = lexical_cast<string>(bandwidth_/1000000.0f).c_str();
	const char* hack = str.c_str();
	return hack;
    }

    ///Not currently used??
    const char* BandwidthStringFancy() {
	string bw,units;
	if(bandwidth_ >= 1e6){
	    units = " MHz";
	    bw = lexical_cast<string>(bandwidth_/1000000.0f);
	}
	else
	    if(bandwidth_ >= 1e3){
		units = " KHz";
		bw = lexical_cast<string>(bandwidth_/1000.0f);
	    }
	    else{
		units = " Hz";
		bw = lexical_cast<string>(bandwidth_);
	    }
	string temp = bw + units;
	return temp.c_str();
    }

    ///Validates and sets decimation settings
    void Decimation(const int& decimation) { 
	if((decimation%2 != 0) || (decimation < 8) || (decimation > 256)) 
	    cout << "ERROR: invalid decimation value" << endl;
	else
	    decimation_ = decimation;

	Update();
    }
	
    ///Validates and sets sample rate settings
    void SampleRate(const float& sampleRate) { 
	if((sampleRate < 1e6) || (sampleRate > 64e6)) 
	    cout << "ERROR: invalid sample rate" << endl;
	else
	    sampleRate_ = sampleRate;

	Update();
    }

    ///Validates and sets channel settings
    void Channels(const int& channels){
	if((channels != 1) && (channels != 2) && (channels != 4)) 
	    cout << "ERROR: invalid number of channels selected" << endl;
	else
	    channels_ = channels;
	
	Update();
    }
};
	
#endif
