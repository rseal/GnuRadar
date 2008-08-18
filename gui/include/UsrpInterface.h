////////////////////////////////////////////////////////////////////////////////
///UsrpInterface.h
///
///Primary Display window for USRP configuration GUI interface.
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef USRP_CONFIG_GUI_H
#define USRP_CONFIG_GUI_H

#include <FL/Fl.H>
#include <FL/Fl_Button.H>
#include <FL/Fl_Menu_Bar.H>
#include <FL/Fl_Menu_Item.H>
#include <FL/Fl_File_Browser.H>
#include <FL/Fl_Window.h>
#include <FL/Fl_Group.h>
#include <FL/Fl_File_Chooser.H>

#include <boost/lexical_cast.hpp>
#include <boost/shared_ptr.hpp>

#include <iostream>
#include <vector>

#include "ChannelInterface.h"
#include "SettingsInterface.h"
#include "HeaderInterface.h"
#include "DataInterface.h"
#include "UsrpConfigStruct.h"
#include "Parser.h"

using std::auto_ptr;
using boost::shared_ptr;
using std::vector;

///Provides a container and display interface for the 
///USRP data collection system.
class UsrpInterface : public Fl_Window 
{
    const int maxChannels_;
    //int numChannels_;
    UsrpConfigStruct usrpConfigStruct_;

    auto_ptr<Fl_Menu_Bar> menuBar_;
    auto_ptr<SettingsInterface> settingsInterface_;
    auto_ptr<ChannelInterface> channelTab_;
    auto_ptr<HeaderInterface> headerInterface_;
    auto_ptr<DataInterface> dataInterface_;

    Fl_Color windowColor_;
    Fl_Color buttonColor_;
    Fl_Color tabColor_;

    auto_ptr<Fl_Button>       buttonQuit_;
    auto_ptr<Fl_Button>       buttonSave_;
    auto_ptr<Fl_Button>       buttonLoad_;
    auto_ptr<Fl_File_Browser> fileBrowserFPGA_;
    auto_ptr<Fl_Group> fpgaGroup_;

    ///Callback for Quit button
    static void QuitClicked(Fl_Widget* flw, void* userData){
	UsrpInterface* userInterface = reinterpret_cast<UsrpInterface*>(userData);
	std::cout << "Goodbye" << std::endl;
	exit(0);
    }

    ///Callback for Load button
    static void LoadClicked(Fl_Widget* flw, void* userData){
	UsrpInterface* usrpInterface = reinterpret_cast<UsrpInterface*>(userData);
	//really screwed up way to catch exception - until I find the proper method
	string str;
	try { 
	    string str2(fl_file_chooser("Choose USRP Configuration File", "*.ucf", NULL));
	    str = str2;
	}
	catch(std::exception){
	    cerr << "UsrpInterface::LoadClicked - Empty string" << endl;
	}
	
	if(str.size() != 0) Parser parser(str);
    };
    
    ///Callback for Save button
    static void SaveClicked(Fl_Widget* flw, void* userData){
	UsrpInterface* usrpInterface = reinterpret_cast<UsrpInterface*>(userData);
	string str;
	try { 
	    string str2(fl_file_chooser("Choose USRP Configuration File", "*.ucf", NULL));
	    str = str2;
	}
	catch(std::exception){
	    cerr << "UsrpInterface::SaveClicked - Empty string" << endl;
	}
	
	if(str.size() != 0){
	    Parser parser(str);
	    usrpInterface->WriteFile(parser);
	}
    };

    ///Callback used to update channel settings
    static void UpdateChannels(Fl_Widget* flw, void* userData){
 	SettingsInterface* siPtr = reinterpret_cast<SettingsInterface*>(flw);
	CustomTab* ctPtr         = reinterpret_cast<CustomTab*>(userData);
 	int numChannels          = siPtr->NumChannels();
 	int index                = 0;
	for(int i=0; i<4; ++i) ctPtr->Disable(i);
	for(index=0; index<numChannels; ++index) ctPtr->Enable(index);
    }

    ///Not currently implemented
    void WriteFile(Parser& parser);

public:
    ///Contstructor
    UsrpInterface(int X, int Y);
    ~UsrpInterface(){exit(0);};
};
#endif
