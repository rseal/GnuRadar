////////////////////////////////////////////////////////////////////////////////
///ChannelStruct.h
///
///
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef CHANNEL_STRUCT_H
#define CHANNEL_STRUCT_H
///Each USRP channel defines the down-conversion frequency
///and phase.
struct ChannelStruct{
public:
    float ddc;
    int ddcUnits;
    float phase;
    int phaseUnits;
};

#endif
