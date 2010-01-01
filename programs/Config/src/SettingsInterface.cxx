////////////////////////////////////////////////////////////////////////////////
///SettingsInterface.cxx
///
///Provides interactive formatting and display of sample rate, bandwidth, 
///and decimation 
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#include "../include/SettingsInterface.h"
#include <iostream>

using namespace std;
using namespace boost;

///Constructor 
SettingsInterface::SettingsInterface(int x, int y, int width, int height, 
				     const char* label, UsrpConfigStruct& usrpConfigStruct):
    Fl_Group(x,y,width,height,label), usrpConfigStruct_(usrpConfigStruct)
{
    settingsCompute_ = unique_ptr<SettingsCompute>(new SettingsCompute);
    
    int x0 = x + 100;
    int y0 = y + 20;
    int w0 = 60;
    int w1 = 80;
    int h1 = 25;
    //int sp0 = w1+50;
    int sp1 = 40;
    int sp2 = w1+120;
    Fl_Color wColor_ = fl_rgb_color(220,220,220);
    color1_ = fl_rgb_color(180,180,180);									

    sampleRate_ = unique_ptr<Fl_Float_Input>(new Fl_Float_Input(x0, y0, w0, h1, "Sample Rate"));
    string str = lexical_cast<string>(settingsCompute_->SampleRate()/1e6);
    sampleRate_->value(str.c_str());
    sampleRate_->callback(SettingsInterface::UpdateSampleRate,this);
    sampleRate_->color(FL_WHITE);
    this->add(sampleRate_.get());

    units1_ = unique_ptr<Fl_Output>(new Fl_Output(x0+65,y0, 40, h1));
    units1_->value("MHz");
    units1_->clear_visible_focus();
    units1_->color(wColor_);
    units1_->box(FL_PLASTIC_UP_BOX);
    this->add(units1_.get());

    //add channel options to Fl_Choice widget
    vector<string> chNum;
    chNum.push_back("1");
    chNum.push_back("2");
    chNum.push_back("4");

    channels_ = unique_ptr<Fl_Choice>( new Fl_Choice(x0+sp2, y0, w0, h1, "Channels"));
    channels_->add(chNum[0].c_str(),0,0);
    channels_->add(chNum[1].c_str(),0,0);
    channels_->add(chNum[2].c_str(),0,0);
    channels_->value(0);
    channels_->box(FL_PLASTIC_UP_BOX);
    channels_->callback(SettingsInterface::UpdateChannel,this);
    this->add(channels_.get());

    decimation_ = unique_ptr<Fl_Value_Slider>(new Fl_Value_Slider(x0, y0+sp1, w1+25, h1, "Decimation"));
    decimation_->align(FL_ALIGN_LEFT);
    decimation_->type(FL_HOR_NICE_SLIDER);
    decimation_->textsize(14);
    decimation_->step(2);
    decimation_->range(8,256);
    decimation_->value(8);
    decimation_->box(FL_PLASTIC_UP_BOX);
    decimation_->color(FL_WHITE);
    decimation_->callback(SettingsInterface::UpdateDecimation,this);
    this->add(decimation_.get());

    bandwidth_ = unique_ptr<Fl_Output>(new Fl_Output(x0+sp2, y0+sp1, w0, h1, "Bandwidth"));
    bandwidth_->value("8");
    bandwidth_->clear_visible_focus();
    bandwidth_->box(FL_PLASTIC_UP_BOX);
    bandwidth_->color(wColor_);
    bandwidth_->align(FL_ALIGN_LEFT);
    this->add(bandwidth_.get());

    units2_ = unique_ptr<Fl_Output>(new Fl_Output(x0+sp2+65,y0+sp1, 40, h1));
    units2_->value("MHz");
    units2_->clear_visible_focus();
    units2_->box(FL_PLASTIC_UP_BOX);
    this->add(units2_.get());

    this->end();
};

///Updates all parameters defined in SettingsInterface class
void SettingsInterface::UpdateParameters(){
    float sampleRate = lexical_cast<float>(sampleRate_->value())*1000000.0f;
    int decimation   = decimation_->value();
    int channels     = lexical_cast<int>(channels_->text());
	
    //this should perform bounds checking and validation
    //so anywhere else is redundant
    settingsCompute_->SampleRate(sampleRate);
    settingsCompute_->Decimation(decimation);
    settingsCompute_->Channels(channels);
    float bw = settingsCompute_->Bandwidth();
    string unitsStr;

    if(settingsCompute_->ValidateParameters()){
	//update global structure
	usrpConfigStruct_.sampleRate  = settingsCompute_->SampleRate();
	usrpConfigStruct_.decimation  = settingsCompute_->Decimation();
	usrpConfigStruct_.numChannels = settingsCompute_->Channels();
    }
    else{
	cerr << "SettingsInterface::UpdateParameters - invalide parameter(s) detected" 
	     << " - global structure not updated" << endl;

    }

    if(bw >= 1e6){
	bw = bw/1000000.0f;
	unitsStr = "MHz";
    }
    else if(bw >= 1e3){
	bw = bw/1000.0f;
	unitsStr = "KHz";
    }
    else unitsStr = "Hz";
	
    units2_->value("");
    units2_->value(unitsStr.c_str());
    string str = lexical_cast<string>(bw);
	
    //limit float precision to 2 decimal places
    uint index = str.find(".");

    //correct indexing bug when only tenths exist
    if(str.length() < index+3 && index != string::npos)
	str += "0";
	
    if(index != string::npos) str.erase(index+3);
    bandwidth_->value(str.c_str());

    //parameters changed - activate SettingsInterface::callback()
    this->do_callback();
}

void SettingsInterface::SampleRate(const float& sampleRate){
    settingsCompute_->SampleRate(sampleRate);
    string str = lexical_cast<string>(settingsCompute_->SampleRate()/1e6);
    str = StringFormat::SetPrecision(str,3);
    sampleRate_->value(str.c_str());
}

void SettingsInterface::Decimation(const int& decimation){
    settingsCompute_->Decimation(decimation);
    decimation_->value(settingsCompute_->Decimation());
}

void SettingsInterface::NumChannels(const int& numChannels){
    int index=1;
    switch(numChannels){
    case 1: index =0; break;
    case 2: index =1; break;
    case 4: index =2; break;
    }
    settingsCompute_->Channels(numChannels);
    channels_->value(index);
}

