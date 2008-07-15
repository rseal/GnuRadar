#ifndef USRP_CONFIG_GUI_H
#define USRP_CONFIG_GUI_H

#include <FL/Fl.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Button.H>
#include <FL/Fl_Tabs.H>
#include <FL/Fl_Input.H>
#include <FL/Fl_Float_Input.H>

#include <FL/Fl_Output.H>
#include <FL/Fl_File_Browser.H>
#include <FL/Fl_Window.h>
#include <FL/Fl_Value_Slider.h>
#include <FL/Fl_Choice.h>

#include <gnuradar/UsrpParameters.h>
#include <boost/lexical_cast.hpp>
#include <boost/shared_ptr.hpp>

#include <iostream>
#include <vector>

#include "ChannelInterface.h"
#include "SettingsInterface.h"

using std::auto_ptr;
using std::vector;
using boost::shared_ptr;

class UserInterface : public Fl_Window 
{
    const int maxChannels_;
    UsrpParameters usrpParameters_;

    auto_ptr<SettingsInterface> settingsInterface_;

    typedef shared_ptr<ChannelInterface> ChannelInterfacePtr;
    vector<ChannelInterfacePtr> channelGroupPtr_;

    auto_ptr<ChannelInterface> channelGroup_;

    Fl_Color windowColor_;
    Fl_Color buttonColor_;
    Fl_Color tabColor_;

    auto_ptr<Fl_Button>       buttonQuit_;
    auto_ptr<Fl_Button>       buttonSave_;
    auto_ptr<Fl_Button>       buttonApply_;

    auto_ptr<Fl_Tabs>         tabWindow_;
    auto_ptr<Fl_Group>        tab1Group_;
    auto_ptr<Fl_Group>        tab2Group_;
    auto_ptr<Fl_File_Browser> fileBrowserFPGA_;
    auto_ptr<Fl_Float_Input>  tab1Input1_;
//    auto_ptr<Fl_Input>        tab1Input2_;
    auto_ptr<Fl_Input>        tab1Input3_;
    auto_ptr<Fl_Input>        tab1Input4_;
    auto_ptr<Fl_Output>       tab1Output1_;
    auto_ptr<Fl_Input>        tab2Input1_;
    auto_ptr<Fl_Input>        tab2Input2_;
    auto_ptr<Fl_Input>        tab2Input3_;
    auto_ptr<Fl_Input>        tab2Input4_;
    auto_ptr<Fl_Input>        tab2Input5_;
    auto_ptr<Fl_Value_Slider> tab1Slider_;
    auto_ptr<Fl_Choice>       tab1Channels_;

    
   static void Quit(Fl_Widget* flw){
       std::cout << "quit" << std::endl;
       exit(0);
    }

    static void UpdateDecimation(Fl_Widget* flw, void* userData){
	UserInterface* userInterface = reinterpret_cast<UserInterface*>(userData);
	userInterface->UpdateParameters();
    }

    static void UpdateSampleRate(Fl_Widget* flw, void* userData){
	UserInterface* userInterface = reinterpret_cast<UserInterface*>(userData);
	userInterface->UpdateParameters();
    }

    void UpdateParameters(){
	float sampleRate = lexical_cast<float>(tab1Input1_->value())*1e6;
	int decimation = tab1Slider_->value();
	usrpParameters_.SampleRate(sampleRate);
	usrpParameters_.Decimation(decimation);
	tab1Output1_->value(usrpParameters_.BandwidthString());
	cout << "Bandwidth = " << usrpParameters_.BandwidthStringFancy() << endl;
    }

    static void UpdateChannel(Fl_Widget* flw, void* userData){
	Fl_Choice* channel = reinterpret_cast<Fl_Choice*>(flw);
	int numChannels = lexical_cast<int>(channel->text());
    };

public:
    UserInterface(int X, int Y);
};
#endif
