#include "../include/HeaderInterface.h"

HeaderInterface::HeaderInterface(int x, int y, int width, int height, const char* label): 
    Fl_Group(x,y,width,height,label){

    int x0=x+150;
    int y0=y+20;
    int w0=150;
    int h0=25;
    int sp=15;
    int numInputs=5;
   

    for(int i=0; i<numInputs; ++i){
	InputPtr ip = InputPtr(new Fl_Input(x0,y0+i*(h0+sp),w0,h0));
	inputArray_.push_back(ip);
    }

    inputArray_[0]->label("Institution Name");
    inputArray_[1]->label("Observer");
    inputArray_[2]->label("Object of Observation");
    inputArray_[3]->label("Observing Instrument");
    inputArray_[4]->label("Collection Instrument");
}
