////////////////////////////////////////////////////////////////////////////////
///ChannelGroup.cxx
///
///Groups ddc and phase inputs together.
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#include "../include/ChannelGroup.h"

///Constructor
ChannelGroup::ChannelGroup(const int& id, int x, int y, int width, int height, 
			   const char* label):
    Fl_Group( x, y, width, height, label), id_(id)
{
    int x0=x+80;
    int y0=y+20;
    int w0=50;
    int w1=70;
    int h0=25;
    int sp0=40;

    ddc_ = auto_ptr<Fl_Float_Input>(new Fl_Float_Input(x0, y0, w1, h0,"Frequency"));
    ddc_->callback(ChannelGroup::Update,this);
    ddc_->value("0.0");
    this->add(ddc_.get());

    ddcUnits_ = auto_ptr<Fl_Choice>(new Fl_Choice(x0+w0+25, y0, w1, h0, ""));
    ddcUnits_->add("MHz",0,0);
    ddcUnits_->add("kHz",0,0);
    ddcUnits_->add("hz",0,0);
    ddcUnits_->value(0);
    ddcUnits_->callback(ChannelGroup::Update,this);
    this->add(ddcUnits_.get());

    phase_ = auto_ptr<Fl_Float_Input>(new Fl_Float_Input(x0, y0+sp0, w1, h0, "Phase"));
    phase_->callback(ChannelGroup::Update,this);
    phase_->value("0.0");
    this->add(phase_.get());

    phaseUnits_ = auto_ptr<Fl_Choice>(new Fl_Choice(x0+w0+25, y0+sp0, w1, h0, ""));
    phaseUnits_->add("Deg",0,0);
    phaseUnits_->add("Rad",0,0);
    phaseUnits_->value(0);
    phaseUnits_->callback(ChannelGroup::Update,this);
    this->add(phaseUnits_.get());

    this->end();
}
