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

class ChannelInterface: public CustomTab 
{
    typedef boost::shared_ptr<ChannelGroup> ChannelGroupPtr;
    Fl_Color windowColor_;
    vector<Fl_Color> colorVector_;

//     static void UpdateDDC(Fl_Widget* flw, void* userData){
// 	//UserInterface* userInterface = reinterpret_cast<UserInterface*>(userData);
// 	//userInterface->UpdateParameters();
//     }
    vector<ChannelGroupPtr> channelArray_;
    const bool ChannelValid(const int& chNum) { return chNum >= 0 || chNum <= 3;}

public:
    ChannelInterface(int X, int Y, int width, int height, const char* label);
    
    const float DDC(const int& chNum) {
	ChannelGroup* cg = reinterpret_cast<ChannelGroup*>(this->child(chNum));
	if(ChannelValid(chNum)) return cg->DDC();
	
	cerr << "ChannelInterface::DDC - invalid channel requested" << endl;
	return 0.0f;
    };

    const int DDCUnits(const int& chNum) {
	ChannelGroup* cg = reinterpret_cast<ChannelGroup*>(this->child(chNum));
	if(ChannelValid(chNum)) return cg->DDCUnits();
	
	cerr << "ChannelInterface::DDCUnits - invalid channel requested" << endl;
	return 0;
    };

    const float Phase(const int& chNum) {
	ChannelGroup* cg = reinterpret_cast<ChannelGroup*>(this->child(chNum));
	if(ChannelValid(chNum)) return cg->Phase();
	
	cerr << "ChannelInterface::Phase - invalid channel requested" << endl;
	return 0.0f;
    };

    const float PhaseUnits(const int& chNum) {
	ChannelGroup* cg = reinterpret_cast<ChannelGroup*>(this->child(chNum));
	if(ChannelValid(chNum)) return cg->DDC();
	
	cerr << "ChannelInterface::PhaseUnits - invalid channel requested" << endl;
	return 0.0f;
    };	    
};

#endif
