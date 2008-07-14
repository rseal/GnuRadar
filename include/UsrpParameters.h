#ifndef USRPPARAMETERS_H
#define USRPPARAMETERS_H

#include <iostream>
#include <boost/lexical_cast.hpp>

using std::cout;
using std::endl;
using std::string;
using boost::lexical_cast;

struct UsrpParameters{

    float sampleRate_;
    int   decimation_;
    float bandwidth_;
    
    const bool ValidateParameters() { 
        bool valid(true);
	if(sampleRate_ < 1e6 || sampleRate_ > 64e6) valid = false;
	if(decimation_%2 != 0) valid = false;
	if(decimation_ < 8 || decimation_ > 256) valid = false;
	return valid;
    }

    Update(){
	if(ValidateParameters())
	    bandwidth_ = sampleRate_ / decimation_;
	else
	    cout << "Invalid input parameter given - NO CHANGES MADE" << endl;
    }

public:
    UsrpParameters(): sampleRate_(64e6), decimation_(8), bandwidth_(8e6){}

    const float& SampleRate()       { return sampleRate_;}
    const char*  SampleRateString() { return lexical_cast<string>(sampleRate_/1e6).c_str();}
    const int&   Decimation()       { return decimation_;}
    const float& Bandwidth()        { return bandwidth_;}

    const char* BandwidthString()   {
	return lexical_cast<string>(static_cast<float>(bandwidth_/1e6)).c_str();
    }

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

    void Decimation(const int& decimation) { 
	if((decimation%2 != 0) || (decimation < 8) || (decimation > 256)) 
	    cout << "ERROR: invalid decimation value" << endl;
	else
	    decimation_ = decimation;

	Update();
    }
	
    void SampleRate(const float& sampleRate) { 
	if((sampleRate < 1e6) || (sampleRate > 64e6)) 
	    cout << "ERROR: invalid sample rate" << endl;
	else
	    sampleRate_ = sampleRate;

	Update();
    }
};
	
#endif
