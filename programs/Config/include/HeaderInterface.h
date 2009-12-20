////////////////////////////////////////////////////////////////////////////////
///HeaderInterface.h
///
///Records and displays information required for Header system. 
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef HEADER_INTERFACE_H
#define HEADER_INTERFACE_H

#include <FL/Fl.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Input.H>

#include "UsrpConfigStruct.h"
#include "HeaderStruct.h"

#include <boost/shared_ptr.hpp>
#include <iostream>
#include <vector>
#include <memory>

using std::cout;
using std::endl;
using std::string;
using std::vector;
using boost::shared_ptr;
using std::auto_ptr;

//contains the following components
// institution name      - fl_input
// observer              - fl_input
// object of observation - fl_input
// observing instrument  - fl_input
// collection instrument - fl_input

///Class Definition
class HeaderInterface : public Fl_Group
{
    UsrpConfigStruct& usrpConfigStruct_;
    auto_ptr<HeaderStruct> headerStruct_;
    typedef shared_ptr<Fl_Input> InputPtr;
    vector<InputPtr> inputArray_;

public:
    HeaderInterface(UsrpConfigStruct& usrpConfigStruct,
		    int x, int y, int width=325, int height=245, 
		    const char* label=NULL);

    static void Update(Fl_Widget* flw, void* userData){
	HeaderInterface* hiPtr = reinterpret_cast<HeaderInterface*>(userData);
	
	HeaderStruct& header = hiPtr->usrpConfigStruct_.HeaderRef();

	header.institution = hiPtr->inputArray_[0]->value();
	header.observer    = hiPtr->inputArray_[1]->value();
	header.object      = hiPtr->inputArray_[2]->value();
	header.radar       = hiPtr->inputArray_[3]->value();
	header.receiver    = hiPtr->inputArray_[4]->value();
	//debug only
//	header.Print();
    }

    void Load(const HeaderStruct& header){
        inputArray_[0]->value(header.institution.c_str());
        inputArray_[1]->value(header.observer.c_str());
        inputArray_[2]->value(header.object.c_str());
        inputArray_[3]->value(header.radar.c_str());
        inputArray_[4]->value(header.receiver.c_str());
    }
};
#endif

