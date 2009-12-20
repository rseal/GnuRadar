////////////////////////////////////////////////////////////////////////////////
///ChannelInterface.cxx
///
///Provides formatting and display of NCO and Phase information for each channel
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#include "../include/ChannelInterface.h"

///Constructor
ChannelInterface::ChannelInterface(UsrpConfigStruct& usrpConfigStruct,
				   int x, int y, int width, int height, 
				   const char* label): 
    CustomTab(x,y,width,height,label), usrpConfigStruct_(usrpConfigStruct)
{
    colorVector_.push_back(fl_rgb_color(230,230,230));
    colorVector_.push_back(fl_rgb_color(100,100,100));

    for(int i=0; i<4; ++i){
	string str = "Channel " + lexical_cast<string>(i+1);
	ChannelGroupPtr cgPtr(new ChannelGroup(i,x+15,y+20,230,100,""));
	cgPtr->copy_label(str.c_str());
	cgPtr->callback(ChannelInterface::Update,&usrpConfigStruct_);
	channelArray_.push_back(cgPtr);
	this->add(channelArray_[i].get());
    }
    this->end();
};

void ChannelInterface::Load(const USRP::ChannelVector& channels){
 
   for(int i=0; i<4; ++i){
	channelArray_[i]->DDC(channels[i].ddc);
	channelArray_[i]->DDCUnits(channels[i].ddcUnits);
	channelArray_[i]->Phase(channels[i].phase);
	channelArray_[i]->PhaseUnits(channels[i].phaseUnits);
    }
}
