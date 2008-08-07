////////////////////////////////////////////////////////////////////////////////
///ChannelGroup.h
///
///Groups ddc and phase inputs together.
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef CHANNELGROUP_H
#define CHANNELGROUP_H

#include <FL/Fl.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Float_Input.H>
#include <FL/Fl_Choice.h>
#include <boost/lexical_cast.hpp>
#include <memory>

using std::auto_ptr;
using boost::lexical_cast;

///Class definition
class ChannelGroup: public Fl_Group 
{
    auto_ptr<Fl_Float_Input>  ddc_;
    auto_ptr<Fl_Choice>       ddcUnits_;
    auto_ptr<Fl_Float_Input>  phase_;
    auto_ptr<Fl_Choice>       phaseUnits_;

public:
    ///Constructor
    ChannelGroup(int X, int Y, int width, int height, 
		     const char* label);

    const float DDC()        { return lexical_cast<float>(ddc_->value());}
    const int   DDCUnits()   { return ddcUnits_->value();}
    const float Phase()      { return lexical_cast<float>(phase_->value());}
    const int   PhaseUnits() { return phaseUnits_->value();}
};

#endif
