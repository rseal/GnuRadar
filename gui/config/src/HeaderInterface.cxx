////////////////////////////////////////////////////////////////////////////////
///HeaderInterface.cxx
///
///Records and displays information required for Header system. 
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#include "../include/HeaderInterface.h"

///Constructor
HeaderInterface::HeaderInterface(UsrpConfigStruct& usrpConfigStruct, int x, 
				 int y, int width, int height, 
				 const char* label):
    Fl_Group(x,y,width,height,label), usrpConfigStruct_(usrpConfigStruct) 
{

    int x0=x+150;
    int y0=y+20;
    int w0=150;
    int h0=25;
    int sp=15;
    int numInputs=5;
   
    headerStruct_ = auto_ptr<HeaderStruct>(new HeaderStruct);

    for(int i=0; i<numInputs; ++i){
	InputPtr ip = InputPtr(new Fl_Input(x0,y0+i*(h0+sp),w0,h0));
	inputArray_.push_back(ip);
    }

    inputArray_[0]->label("Institution");
    inputArray_[1]->label("Observer");
    inputArray_[2]->label("Object");
    inputArray_[3]->label("Radar");
    inputArray_[4]->label("Receiver");
        
    for(int i=0; i<numInputs; ++i)
	inputArray_[i]->callback(HeaderInterface::Update,this);
}
