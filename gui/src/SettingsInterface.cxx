#include "../include/SettingsInterface.h"
#include <iostream>

SettingsInterface::SettingsInterface(int x, int y, int width, int height, 
				     const char* label, UsrpParameters& usrpParameters):
    usrpParameters_(usrpParameters), Fl_Group(x,y,width,height,label)
{
    //this->labeltype(FL_NORMAL_LABEL);
    //this->align(FL_ALIGN_TOP);
    
    int x0 = x + 100;
    int y0 = y + 20;
    int w0 = 55;
    int w1 = 80;
    int h1 = 25;
    int sp0 = w1+50;
    int sp1 = 40;
    int sp2 = w1+120;
    Fl_Color wColor_ = fl_rgb_color(220,220,220);
									
    this->color(wColor_);

    sampleRate_ = auto_ptr<Fl_Float_Input>(new Fl_Float_Input(x0, y0, w0, h1, "Sample Rate"));
    sampleRate_->value(usrpParameters_.SampleRateString());
    sampleRate_->callback(SettingsInterface::UpdateSampleRate,this);
    sampleRate_->color(FL_WHITE);
    this->add(sampleRate_.get());

    units1_ = auto_ptr<Fl_Output>(new Fl_Output(x0+60,y0, 40, h1));
    units1_->value("MHz");
    units1_->color(wColor_);
    units1_->box(FL_NO_BOX);
    this->add(units1_.get());

    //add channel options to Fl_Choice widget
    vector<string> chNum;
    chNum.push_back("1");
    chNum.push_back("2");
    chNum.push_back("4");

    channels_ = auto_ptr<Fl_Choice>( new Fl_Choice(x0+sp2, y0, w0, h1, "Channels"));
    channels_->add(chNum[0].c_str(),0,0);
    channels_->add(chNum[1].c_str(),0,0);
    channels_->add(chNum[2].c_str(),0,0);
    channels_->value(0);
    channels_->callback(SettingsInterface::UpdateChannel,this);
    this->add(channels_.get());

    decimation_ = auto_ptr<Fl_Value_Slider>(new Fl_Value_Slider(x0, y0+sp1, w1, h1, "Decimation"));
    decimation_->align(FL_ALIGN_LEFT);
    decimation_->type(FL_HOR_NICE_SLIDER);
    decimation_->step(2);
    decimation_->range(8,256);
    decimation_->value(8);
    decimation_->color(FL_WHITE);
    decimation_->callback(SettingsInterface::UpdateDecimation,this);
    this->add(decimation_.get());

    bandwidth_ = auto_ptr<Fl_Output>(new Fl_Output(x0+sp2, y0+sp1, w0, h1, "Bandwidth"));
    bandwidth_->value("8");
    bandwidth_->color(wColor_);
    bandwidth_->align(FL_ALIGN_LEFT);
    this->add(bandwidth_.get());

    units2_ = auto_ptr<Fl_Output>(new Fl_Output(x0+sp2+60,y0+sp1, 40, h1));
    units2_->value("MHz");
    units2_->color(wColor_);
    units2_->box(FL_NO_BOX);
    this->add(units2_.get());

    this->end();
};
