#ifndef USRP_CONFIG_GUI_H
#define USRP_CONFIG_GUI_H

#include <FL/Fl.H>
#include <FL/Fl_Button.H>
#include <FL/Fl_Menu_Bar.H>
#include <FL/Fl_Menu_Item.H>
#include <FL/Fl_File_Browser.H>
#include <FL/Fl_Window.h>
#include <FL/Fl_Group.h>

#include <gnuradar/UsrpParameters.h>
#include <boost/lexical_cast.hpp>
#include <boost/shared_ptr.hpp>

#include <iostream>
#include <vector>

#include "ChannelInterface.h"
#include "SettingsInterface.h"
#include "HeaderInterface.h"

using std::auto_ptr;
using boost::shared_ptr;
using std::vector;

class UsrpInterface : public Fl_Window 
{
    const int maxChannels_;
    int numChannels_;

    UsrpParameters usrpParameters_;

    auto_ptr<Fl_Menu_Bar> menuBar_;
    auto_ptr<SettingsInterface> settingsInterface_;
    auto_ptr<ChannelInterface> channelTab_;
    auto_ptr<HeaderInterface> headerInterface_;

    Fl_Color windowColor_;
    Fl_Color buttonColor_;
    Fl_Color tabColor_;

    auto_ptr<Fl_Button>       buttonQuit_;
    auto_ptr<Fl_Button>       buttonSave_;
    auto_ptr<Fl_Button>       buttonApply_;
    auto_ptr<Fl_File_Browser> fileBrowserFPGA_;
    auto_ptr<Fl_Group> fpgaGroup_;

    static void Quit(Fl_Widget* flw, void* userData){
	UsrpInterface* userInterface = reinterpret_cast<UsrpInterface*>(userData);
	std::cout << "Goodbye" << std::endl;
	//call gui's dtor to release allocated memory
	userInterface->~UsrpInterface();
    }

    static void NumChannels(Fl_Widget* flw, void* userData){
 	Fl_Choice* w = reinterpret_cast<Fl_Choice*>(flw);
 	CustomTab* channelTab = reinterpret_cast<CustomTab*>(userData);
 	int numChannels = lexical_cast<int>(w->text());
 	int index = 0;

	for(int i=0; i<4; ++i)
	    channelTab->Disable(i);

	for(index=0; index<numChannels; ++index){
	    channelTab->Enable(index);
	}
	
    }
	
public:
    UsrpInterface(int X, int Y);
    ~UsrpInterface(){exit(0);};
};
#endif
