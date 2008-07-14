#include "../include/ChannelInterface.h"

ChannelInterface::ChannelInterface(int x, int y, int width, int height, 
				   const char* label, UsrpParameters& usrpParameters):
    Fl_Group(x,y,width,height,label), usrpParameters_(usrpParameters)
{
};
