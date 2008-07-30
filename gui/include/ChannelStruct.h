#ifndef CHANNEL_STRUCT_H
#define CHANNEL_STRUCT_H
//each USRP channel defines the down-conversion frequency
//and phase
struct ChannelStruct{
public:
    float ddc;
    float phase;
};

#endif
