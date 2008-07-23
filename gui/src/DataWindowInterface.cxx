#include "../include/DataWindowInterface.h"

DataWindowInterface::DataWindowInterface(int x, int y, int width, int height, const char* label):
    CustomTab(x,y,width,height,label)
{
    int x0 = x + 5;
    int y0 = y + 20;
    int w0 = 220;
    int h0 = 70;

    DataGroupPtr dgp = DataGroupPtr(new DataGroup(x0,y0, w0, h0, "Data"));
    dataGroupArray_.push_back(dgp);
    this->add(dataGroupArray_[0].get());

    this->end();

}


