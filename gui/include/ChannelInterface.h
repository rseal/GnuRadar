#ifndef CHANNELINTERFACE_H
#define CHANNELINTERFACE_H

#include <FL/Fl.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Float_Input.H>
#include <FL/Fl_Choice.h>

#include <gnuradar/UsrpParameters.h>
#include <boost/lexical_cast.hpp>

#include <iostream>
#include <vector>

using std::auto_ptr;
using std::vector;

class ChannelInterface: public Fl_Group 
{
    UsrpParameters& usrpParameters_;

    Fl_Color windowColor_;
    Fl_Color buttonColor_;
    Fl_Color tabColor_;

    auto_ptr<Fl_Group>        group_;
    auto_ptr<Fl_Input>        ddc_;
    auto_ptr<Fl_Choice>       units_;
    
    
    static void Quit(Fl_Widget* flw){
	std::cout << "quit" << std::endl;
	exit(0);
    }

    static void UpdateDDC(Fl_Widget* flw, void* userData){
	//UserInterface* userInterface = reinterpret_cast<UserInterface*>(userData);
	//userInterface->UpdateParameters();
    }

public:
    ChannelInterface(int X, int Y, int width, int height, 
		     const char* label, UsrpParameters& usrpParameters);

};
#endif
