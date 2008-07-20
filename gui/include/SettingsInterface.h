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

#include <gnuradar/UsrpParameters.h>
#include <boost/lexical_cast.hpp>
#include <boost/shared_ptr.hpp>

#include <iostream>
#include <vector>

using std::cout;
using std::endl;
using std::auto_ptr;
using std::string;
using std::vector;

class SettingsInterface : public Fl_Group
{
    UsrpParameters& usrpParameters_;

    //contains the following components
    // sample rate - fl_float_input
    // decimation  - fl_value_slider
    // bandwidth   - fl_output
    // channels    - fl_choice
    Fl_Color color1_;

    auto_ptr<Fl_Output> units1_;
    auto_ptr<Fl_Output> units2_;
    auto_ptr<Fl_Float_Input> sampleRate_;
    auto_ptr<Fl_Value_Slider> decimation_;
    auto_ptr<Fl_Output> bandwidth_;
    auto_ptr<Fl_Choice> channels_;

    static void UpdateDecimation(Fl_Widget* flw, void* userData){
	SettingsInterface* settingsInterface = reinterpret_cast<SettingsInterface*>(userData);
	settingsInterface->UpdateParameters();
    }

    static void UpdateSampleRate(Fl_Widget* flw, void* userData){
	SettingsInterface* settingsInterface = reinterpret_cast<SettingsInterface*>(userData);
	settingsInterface->UpdateParameters();
    }


    void UpdateParameters(){
	float sampleRate = lexical_cast<float>(sampleRate_->value())*1000000.0f;
	int decimation = decimation_->value();
	int channels = lexical_cast<int>(channels_->text());
	usrpParameters_.SampleRate(sampleRate);
	usrpParameters_.Decimation(decimation);
	usrpParameters_.Channels(channels);
	float bw = usrpParameters_.Bandwidth();
	string unitsStr;

	if(bw >= 1e6){
	    bw = bw/1000000.0f;
	    unitsStr = "MHz";
	}
	else 
	    if(bw >= 1e3){
		bw = bw/1000.0f;
		unitsStr = "KHz";
	    }
	    else unitsStr = "Hz";
	
	units2_->value("");
	units2_->value(unitsStr.c_str());
	string str = lexical_cast<string>(bw);
	bandwidth_->value(str.c_str());
//	this->redraw();
    }

    static void UpdateChannel(Fl_Widget* flw, void* userData){
	//Fl_Choice* channel = reinterpret_cast<Fl_Choice*>(flw);
	//int numChannels = lexical_cast<int>(channel->text());
	SettingsInterface* settingsInterface = reinterpret_cast<SettingsInterface*>(userData);
	settingsInterface->UpdateParameters();
    };

public:
    SettingsInterface(int x, int y, int width, int height, const char* label,
		      UsrpParameters& usrpParameters);
	

    const int NumChannels(){ return lexical_cast<int>(channels_->text());}
    Fl_Choice* ChannelRef() { return channels_.get();}
};
#endif
