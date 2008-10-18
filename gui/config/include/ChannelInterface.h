////////////////////////////////////////////////////////////////////////////////
///ChannelInterface.h
///
///Provides formatting and display of NCO and Phase information for each channel
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef CHANNELINTERFACE_H
#define CHANNELINTERFACE_H

#include <FL/Fl.H>
#include <FL/Fl_Group.H>

#include "ChannelGroup.h"
#include "CustomTab.h"
#include "UsrpConfigStruct.h"

#include <boost/lexical_cast.hpp>
#include <boost/shared_ptr.hpp>
#include <iostream>
#include <vector>

using boost::lexical_cast;
using std::auto_ptr;
using std::vector;
using std::string;
using std::cerr;
using std::cout;
using std::endl;

///\todo Add rule checking to ChannelInterface

///Class definition
class ChannelInterface: public CustomTab 
{
    typedef boost::shared_ptr<ChannelGroup> ChannelGroupPtr;
    UsrpConfigStruct& usrpConfigStruct_;
    Fl_Color windowColor_;
    vector<Fl_Color> colorVector_;

    vector<ChannelGroupPtr> channelArray_;

    static void Update(Fl_Widget* flw, void* userData){
	ChannelGroup*     cgPtr = reinterpret_cast<ChannelGroup*>(flw);
	UsrpConfigStruct* ucPtr = reinterpret_cast<UsrpConfigStruct*>(userData);
	//which channel is calling?
	const int& id = cgPtr->ID();

	const float& sampleRate = ucPtr->sampleRate;
	USRP::ChannelVector& channels = ucPtr->ChannelRef();

	if(cgPtr->ChannelValid(sampleRate)){
	    channels[id].ddc        = cgPtr->DDC();
	    channels[id].ddcUnits   = cgPtr->DDCUnits();
	    channels[id].phase      = cgPtr->Phase();
	    channels[id].phaseUnits = cgPtr->PhaseUnits();
	}
	else{
	    cerr << "ChannelInterface::Update - invalid channel setting detected"
		 << " - global structure not updated." << endl;
	}

	//debug only
	//for(int i=0; i<4; ++i)
	//    channels[i].Print();
	//cout << "ChannelInterface::Update - channel " << id << endl;
    }

public:
    ///Constructor
    ChannelInterface(UsrpConfigStruct& usrpConfigStruct, int X, int Y,
		     int width, int height, const char* label);

    void Load(const USRP::ChannelVector& channels);
    
};

#endif
