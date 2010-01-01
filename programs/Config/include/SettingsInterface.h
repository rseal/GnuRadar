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
#include "StringFormat.h"

#include <iostream>
#include <vector>

using std::cout;
using std::endl;
using std::string;
using std::vector;

///Class definition
class SettingsInterface : public Fl_Group
{
    Fl_Color color1_;

    UsrpConfigStruct& usrpConfigStruct_;
    std::unique_ptr<SettingsCompute> settingsCompute_;
    std::unique_ptr<Fl_Output>       units1_;
    std::unique_ptr<Fl_Output>       units2_;
    std::unique_ptr<Fl_Float_Input>  sampleRate_;
    std::unique_ptr<Fl_Value_Slider> decimation_;
    std::unique_ptr<Fl_Output>       bandwidth_;
    std::unique_ptr<Fl_Choice>       channels_;

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


    void SampleRate(const float& sampleRate);
    void Decimation(const int& decimation);
    void NumChannels(const int& numChannels);
    void UpdateParameters();

};
#endif
