////////////////////////////////////////////////////////////////////////////////
///SettingsInterface.h
///
///Provides interactive formatting and display of sample rate, bandwidth, 
///and decimation 
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef SETTINGS_INTERFACE_H
#define SETTINGS_INTERFACE_H

#include <FL/Fl.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Input.H>
#include <FL/Fl_Float_Input.H>
#include <FL/Fl_Output.H>
#include <FL/Fl_Value_Slider.h>
#include <FL/Fl_Choice.h>
#include <FL/Fl_Window.h>

#include <boost/lexical_cast.hpp>
#include <boost/shared_ptr.hpp>

#include "UsrpConfigStruct.h"
#include "SettingsCompute.h"

#include <iostream>
#include <vector>

using std::cout;
using std::endl;
using std::auto_ptr;
using std::string;
using std::vector;

///Class definition
class SettingsInterface : public Fl_Group
{
    Fl_Color color1_;

    UsrpConfigStruct& usrpConfigStruct_;
    auto_ptr<SettingsCompute> settingsCompute_;
    auto_ptr<Fl_Output>       units1_;
    auto_ptr<Fl_Output>       units2_;
    auto_ptr<Fl_Float_Input>  sampleRate_;
    auto_ptr<Fl_Value_Slider> decimation_;
    auto_ptr<Fl_Output>       bandwidth_;
    auto_ptr<Fl_Choice>       channels_;

    ///Callback to update decimation value
    static void UpdateDecimation(Fl_Widget* flw, void* userData){
	SettingsInterface* settingsInterface = reinterpret_cast<SettingsInterface*>(userData);
	settingsInterface->UpdateParameters();
    }

    //Callback to update sample rate
    static void UpdateSampleRate(Fl_Widget* flw, void* userData){
	SettingsInterface* settingsInterface = reinterpret_cast<SettingsInterface*>(userData);
	settingsInterface->UpdateParameters();
    }

    ///Returns current sample rate
    //    const float SampleRate() { return settingsCompute_->SampleRate();}
    ///Returns current decimation rate
    //const int   Decimation() { return settingsCompute_->Decimation();}

    ///Updates all parameters defined in SettingsInterface class
    void UpdateParameters(){
	float sampleRate = lexical_cast<float>(sampleRate_->value())*1000000.0f;
	int decimation   = decimation_->value();
	int channels     = lexical_cast<int>(channels_->text());
	settingsCompute_->SampleRate(sampleRate);
	settingsCompute_->Decimation(decimation);
	settingsCompute_->Channels(channels);
	float bw = settingsCompute_->Bandwidth();
	string unitsStr;

	//update global structure
	usrpConfigStruct_.SampleRate(sampleRate);
	usrpConfigStruct_.Decimation(decimation);
	usrpConfigStruct_.NumChannels(channels);
	
	if(bw >= 1e6){
	    bw = bw/1000000.0f;
	    unitsStr = "MHz";
	}
	else if(bw >= 1e3){
	    bw = bw/1000.0f;
	    unitsStr = "KHz";
	}
	else unitsStr = "Hz";
	
	units2_->value("");
	units2_->value(unitsStr.c_str());
	string str = lexical_cast<string>(bw);
	
	//limit float precision to 2 decimal places
	int index = str.find(".");

	//correct indexing bug when only tenths exist
	if(str.length() < index+3 && index != string::npos)
	    str += "0";
	
	if(index != string::npos) str.erase(index+3);
	bandwidth_->value(str.c_str());

	//parameters changed - activate SettingsInterface::callback()
	this->do_callback();
    }

    ///Callback to update channels
    static void UpdateChannel(Fl_Widget* flw, void* userData){
	SettingsInterface* settingsInterface = 
	    reinterpret_cast<SettingsInterface*>(userData);
	settingsInterface->UpdateParameters();
    }

public:
    ///Constructor
    SettingsInterface(int x, int y, int width, int height, const char* label,
	UsrpConfigStruct& usrpConfigStruct);
    ///Returns number of defined channels
    const int NumChannels(){ return lexical_cast<int>(channels_->text());}
};
#endif
