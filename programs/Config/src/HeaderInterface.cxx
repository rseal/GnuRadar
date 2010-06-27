// Copyright (c) 2010 Ryan Seal <rlseal -at- gmail.com>
//
// This file is part of GnuRadar Software.
//
// GnuRadar is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//  
// GnuRadar is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with GnuRadar.  If not, see <http://www.gnu.org/licenses/>.
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
