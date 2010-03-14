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

///Provides a container and display interface for the 
///USRP data collection system.
class UsrpInterface : public Fl_Window 
{
    std::vector<string> phaseStr;
    std::vector<string> ddcStr;
    std::vector<string> windowStr;
    std::vector<string> ippStr;
    
    const int maxChannels_;
    UsrpConfigStruct usrpConfigStruct_;

    boost::shared_ptr<Fl_Menu_Bar> menuBar_;
    boost::shared_ptr<SettingsInterface> settingsInterface_;
    boost::shared_ptr<ChannelInterface> channelTab_;
    boost::shared_ptr<HeaderInterface> headerInterface_;
    boost::shared_ptr<DataInterface> dataInterface_;

    Fl_Color windowColor_;
    Fl_Color buttonColor_;
    Fl_Color tabColor_;

    boost::shared_ptr<Fl_Button>       buttonQuit_;
    boost::shared_ptr<Fl_Button>       buttonSave_;
    boost::shared_ptr<Fl_Button>       buttonLoad_;
    boost::shared_ptr<Fl_File_Browser> fileBrowserFPGA_;
    boost::shared_ptr<Fl_Group> fpgaGroup_;

    ///Callback for Quit button
    static void QuitClicked(Fl_Widget* flw, void* userData){
	//UsrpInterface* userInterface = reinterpret_cast<UsrpInterface*>(userData);
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
	
	if(str.size() != 0){
	    Parser parser(str);
	    usrpInterface->LoadFile(parser);
	}
	//fill GUI forms with global structure here
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

    void WriteFile(Parser& parser);
    void LoadFile(Parser& parser);
    void UpdateGUI();

    int Find(const std::vector<string>& vec, const string& value){
	int ret=0;
	for(uint i=0; i<vec.size(); ++i){
	    if(value == vec[i]){
		ret = i;
		break;
	    }
	}
	return ret;
    }
	
public:
    ///Constructor
    UsrpInterface(int X, int Y);
    ~UsrpInterface(){exit(0);};
};
#endif
