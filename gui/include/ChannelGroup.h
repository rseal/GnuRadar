#ifndef CHANNELGROUP_H
#define CHANNELGROUP_H

#include <FL/Fl.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Float_Input.H>
#include <FL/Fl_Choice.h>

//#include <gnuradar/UsrpParameters.h>
#include <boost/lexical_cast.hpp>

#include <iostream>
#include <vector>

using std::auto_ptr;
using std::vector;

class ChannelGroup: public Fl_Group 
{
//    UsrpParameters& usrpParameters_;

    auto_ptr<Fl_Float_Input>  ddc_;
    auto_ptr<Fl_Choice>       ddcUnits_;
    auto_ptr<Fl_Float_Input>  phase_;
    auto_ptr<Fl_Choice>       phaseUnits_;
    

    static void UpdateDDC(Fl_Widget* flw, void* userData){
	//UserInterface* userInterface = reinterpret_cast<UserInterface*>(userData);
	//userInterface->UpdateParameters();
    }

    static void UpdateDDCUnits(Fl_Widget* flw, void* userData){
	//UserInterface* userInterface = reinterpret_cast<UserInterface*>(userData);
	//userInterface->UpdateParameters();
    }
    static void UpdatePhase(Fl_Widget* flw, void* userData){
	//UserInterface* userInterface = reinterpret_cast<UserInterface*>(userData);
	//userInterface->UpdateParameters();
    }
    static void UpdatePhaseUnits(Fl_Widget* flw, void* userData){
	//UserInterface* userInterface = reinterpret_cast<UserInterface*>(userData);
	//userInterface->UpdateParameters();
    }

public:
//     ChannelGroup(int X, int Y, int width, int height, 
// 		     const char* label, UsrpParameters& usrpParameters);
    ChannelGroup(int X, int Y, int width, int height, 
		     const char* label);

};

#endif
