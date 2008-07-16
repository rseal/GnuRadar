#ifndef CHANNELINTERFACE_H
#define CHANNELINTERFACE_H

#include <FL/Fl.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Tabs.h>

#include <boost/lexical_cast.hpp>
#include <boost/shared_ptr.hpp>

#include "ChannelGroup.h"

#include <iostream>
#include <vector>

using boost::lexical_cast;
using std::auto_ptr;
using std::vector;
using std::string;

class ChannelInterface: public Fl_Tabs 
{
    typedef boost::shared_ptr<ChannelGroup> ChannelGroupPtr;
    Fl_Color windowColor_;
    static void UpdateDDC(Fl_Widget* flw, void* userData){
	//UserInterface* userInterface = reinterpret_cast<UserInterface*>(userData);
	//userInterface->UpdateParameters();
    }
    vector<ChannelGroupPtr> channelArray_;
    vector<string> labelArray_;

public:
    ChannelInterface(int X, int Y, int width, int height, const char* label);
};
#endif
