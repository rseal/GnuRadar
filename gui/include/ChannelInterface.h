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

///Class definition
class ChannelInterface: public CustomTab 
{
    typedef boost::shared_ptr<ChannelGroup> ChannelGroupPtr;
    UsrpConfigStruct& usrpConfigStruct_;
    Fl_Color windowColor_;
    vector<Fl_Color> colorVector_;

    vector<ChannelGroupPtr> channelArray_;

    static void Update(Fl_Widget* flw, void* userData){
	ChannelGroup* cgPtr = reinterpret_cast<ChannelGroup*>(flw);
	UsrpConfigStruct* ucPtr = reinterpret_cast<UsrpConfigStruct*>(userData);
	//which channel is calling?
	int id = cgPtr->ID();
	//update global structure for this channel
	ucPtr->Channel(id, 
		       cgPtr->DDC(),
		       cgPtr->DDCUnits(),
		       cgPtr->Phase(),
		       cgPtr->PhaseUnits());
	cout << "ChannelInterface::Update" << endl;
    }

public:
    ///Constructor
    ChannelInterface(UsrpConfigStruct& usrpConfigStruct, int X, int Y,
		     int width, int height, const char* label);
    
    ///Returns DDC frequency for selected channel
//     const float DDC(const int& chNum) {
// 	ChannelGroup* cg = reinterpret_cast<ChannelGroup*>(this->child(chNum));
// 	if(ChannelValid(chNum)) return cg->DDC();
	
// 	cerr << "ChannelInterface::DDC - invalid channel requested" << endl;
// 	return 0.0f;
//     };

    ///Returns DDC units for selected channel
//     const int DDCUnits(const int& chNum) {
// 	ChannelGroup* cg = reinterpret_cast<ChannelGroup*>(this->child(chNum));
// 	if(ChannelValid(chNum)) return cg->DDCUnits();
	
// 	cerr << "ChannelInterface::DDCUnits - invalid channel requested" << endl;
// 	return 0;
//     };

    ///Returns Phase for selected channel
//     const float Phase(const int& chNum) {
// 	ChannelGroup* cg = reinterpret_cast<ChannelGroup*>(this->child(chNum));
// 	if(ChannelValid(chNum)) return cg->Phase();
	
// 	cerr << "ChannelInterface::Phase - invalid channel requested" << endl;
// 	return 0.0f;
//     };

    ///Returns phase units for selected channel
//     const float PhaseUnits(const int& chNum) {
// 	ChannelGroup* cg = reinterpret_cast<ChannelGroup*>(this->child(chNum));
// 	if(ChannelValid(chNum)) return cg->DDC();
	
// 	cerr << "ChannelInterface::PhaseUnits - invalid channel requested" << endl;
// 	return 0.0f;
//     };	    
};

#endif
