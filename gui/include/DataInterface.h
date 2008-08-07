////////////////////////////////////////////////////////////////////////////////
///DataInterface.h
///
///Used to add/remove data window used in data acquisition
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef DATA_INTERFACE_H
#define DATA_INTERFACE_H

//#include <FL/Fl.H>
#include <FL/Fl_Int_Input.H>
#include <FL/Fl_Choice.h>
#include <FL/Fl_Button.h>
#include <FL/fl_ask.H>

#include "DataWindowInterface.h"
#include "UsrpConfigStruct.h"

#include <iostream>
#include <boost/lexical_cast.hpp>

using std::auto_ptr;
using std::cout; 
using std::endl;
using boost::lexical_cast;

class DataInterface : public Fl_Group
{
    UsrpConfigStruct& usrpConfigStruct_;
    auto_ptr<DataWindowInterface> dataWindowInterface_;
    auto_ptr<Fl_Button> addButton_;
    auto_ptr<Fl_Button> removeButton_;
    auto_ptr<Fl_Int_Input> ippInput_;
    auto_ptr<Fl_Choice> unitsChoice_;

    static void AddClicked(Fl_Widget* flw, void* userData){
	DataWindowInterface* dwi = reinterpret_cast<DataWindowInterface*>(userData);

	//really screwed up way to catch exception - until I find the proper method
	string str;
	try { 
	    string str2(fl_input("Enter a label for new data window."));
	    str = str2;
	}
	catch(std::exception){
	    cout << "DataInterface::AddClicked - Empty string" << endl;
	}
	
	if(str.size() != 0) dwi->Add(str.c_str());
    }

    static void RemoveClicked(Fl_Widget* flw, void* userData){
	DataWindowInterface* dwi = reinterpret_cast<DataWindowInterface*>(userData);

	//really screwed up way to catch exception - until I find the proper method
	string str;
	try { 
	    string str2(fl_input("Enter the label for removal."));
	    str = str2;
	}
	catch(std::exception){
	    cerr << "DataInterface::RemoveClicked - Empty string" << endl;
	}
	
	if(str.size() != 0) dwi->Remove(str.c_str());

    }

    static void Update(Fl_Widget* flw, void* userData){
	DataInterface* dwiPtr = reinterpret_cast<DataInterface*>(userData);
	int ipp = lexical_cast<int>(dwiPtr->ippInput_->value());
	int units = dwiPtr->unitsChoice_->value();
	//update global structure
	dwiPtr->usrpConfigStruct_.IPP(ipp,units);
	cout << "DataInterface::Update" << endl;
    }
public:
    DataInterface(UsrpConfigStruct& usrpConfigStruct, int x, int y, 
		  int width=325, int height=245, const char* label=NULL);
};
#endif
