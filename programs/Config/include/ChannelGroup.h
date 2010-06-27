// Copyright (c) 2010 Ryan Seal <rlseal -at- gmail.com>
//
// This file is part of GnuRadar Software.
//
// GnuRadar is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//  
// GnuRadar is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with GnuRadar.  If not, see <http://www.gnu.org/licenses/>.
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
#include <boost/shared_ptr.hpp>
#include <iostream>
#include "StringFormat.h"

///\todo Add rule checking to ChannelGroup 

///Class definition
class ChannelGroup: public Fl_Group 
{
    const int id_;
    const float pi_;
    boost::shared_ptr<Fl_Float_Input>  ddc_;
    boost::shared_ptr<Fl_Choice>       ddcUnits_;
    boost::shared_ptr<Fl_Float_Input>  phase_;
    boost::shared_ptr<Fl_Choice>       phaseUnits_;

    static void Update(Fl_Widget* flw, void* userData){
	ChannelGroup* cgPtr = reinterpret_cast<ChannelGroup*>(userData);
	cgPtr->do_callback();
    }

public:
    ///Constructor
    ChannelGroup(const int& id, int X, int Y, int width, int height, 
		     const char* label);
    const int&  ID() { return id_;}
    const double DDC()        { return boost::lexical_cast<double>(ddc_->value());}
    const int   DDCUnits()   { return ddcUnits_->value();}
    const double Phase()      { return boost::lexical_cast<double>(phase_->value());}
    const int   PhaseUnits() { return phaseUnits_->value();}
    const bool  ChannelValid(const float& sampleRate);

    void DDC(const double& ddc);
    void DDCUnits(const int& ddcUnits);
    void Phase(const double& phase);
    void PhaseUnits(const int& phaseUnits);

};

#endif
