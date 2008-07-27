#ifndef CHANNELGROUP_H
#define CHANNELGROUP_H

#include <FL/Fl.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Float_Input.H>
#include <FL/Fl_Choice.h>
#include <boost/lexical_cast.hpp>
#include <memory>

using std::auto_ptr;

class ChannelGroup: public Fl_Group 
{
    auto_ptr<Fl_Float_Input>  ddc_;
    auto_ptr<Fl_Choice>       ddcUnits_;
    auto_ptr<Fl_Float_Input>  phase_;
    auto_ptr<Fl_Choice>       phaseUnits_;

public:
    ChannelGroup(int X, int Y, int width, int height, 
		     const char* label);

};

#endif
