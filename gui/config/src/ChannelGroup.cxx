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
    Fl_Group( x, y, width, height, label), id_(id), pi_(22.0f/7.0f)
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

///\todo Determine precision of frequency and phase settings for USRP and 
/// create limits.
const bool ChannelGroup::ChannelValid(const float& sampleRate){
    bool valid = true;
    float ddc;
    const float fs = sampleRate/2.0f;
    float phase = Phase();
    float maxDeg = 360.0f;
    float maxRad = 2*pi_;

    //get multiplier for ddc frequency
    switch(PhaseUnits()){
    case 0: ddc = DDC()*1e6;
	break;
    case 1: ddc = DDC()*1e3;
	break;
    case 2: ddc = DDC();
    }

    if(ddc > fs || ddc < -fs){
	cerr << "ChannelGroup::ValidateChannel - ddc setting is greater than nyquist rate" 
	     << endl;
	valid = false;
	goto exit;
    }


    if(!phaseUnits_->value()){
	if(phase > maxDeg){
	    cerr << "ChannelGroup::ValidateChannel - phase is greater "
		 << "than 360 deg - wrapping" << endl;
	    //adjust phase
	    while(phase > maxDeg && phase >= 0)	phase -= maxDeg;
	    phase_->value(lexical_cast<string>(phase).c_str());
	}

	if(phase < 0){
	    cerr << "ChannelGroup::ValidateChannel - negative phase"
		 << " entered - adjusting" << endl;
	    while(phase < 0) phase += maxDeg;
	    phase_->value(lexical_cast<string>(phase).c_str());
	}
    }
    else{
	if(phase > maxRad){
	    cerr << "ChannelGroup::ValidateChannel - phase is greater than 2 pi - wrapping"
		 << endl;

	    //adjust phase
	    while(phase > maxRad && phase >= 0) phase -= maxRad;
	    phase_->value(lexical_cast<string>(phase).c_str());
	}

	if(phase < 0){
	    cerr << "ChannelGroup::ValidateChannel - negative phase entered - adjusting"
		 << endl;
	    //adjust phase
	    while(phase < 0) phase += maxRad;
	    phase_->value(lexical_cast<string>(phase).c_str());
	}
    }

exit:
    return valid;
}

void ChannelGroup::DDC(const float& ddc){
    string str = lexical_cast<string>(ddc);
    str = StringFormat::SetPrecision(str,3);
    ddc_->value(str.c_str());
}

void ChannelGroup::DDCUnits(const int& ddcUnits){
    ddcUnits_->value(ddcUnits);
}

void ChannelGroup::Phase(const float& phase){
    string str = lexical_cast<string>(phase);
    str = StringFormat::SetPrecision(str,3);
    phase_->value(str.c_str());
}

void ChannelGroup::PhaseUnits(const int& phaseUnits){
    phaseUnits_->value(phaseUnits);
}
