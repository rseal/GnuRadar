#ifndef CHANNELINTERFACE_H
#define CHANNELINTERFACE_H

#include <FL/Fl.H>
#include <FL/Fl_Group.H>
//#include <FL/Fl_Tabs.h>
#include "CustomTab.h"

#include <boost/lexical_cast.hpp>
#include <boost/shared_ptr.hpp>

#include "ChannelGroup.h"

#include <iostream>
#include <vector>

using boost::lexical_cast;
using std::auto_ptr;
using std::vector;
using std::string;
using std::cerr;
using std::cout;
using std::endl;

class ChannelInterface: public CustomTab 
{
    typedef boost::shared_ptr<ChannelGroup> ChannelGroupPtr;
    Fl_Color windowColor_;
    vector<Fl_Color> colorVector_;

    static void UpdateDDC(Fl_Widget* flw, void* userData){
	//UserInterface* userInterface = reinterpret_cast<UserInterface*>(userData);
	//userInterface->UpdateParameters();
    }
    vector<ChannelGroupPtr> channelArray_;
    vector<string> labelArray_;

public:
    ChannelInterface(int X, int Y, int width, int height, const char* label);
};
//    void Enable(const int& channel, const bool& enable);};
#endif
