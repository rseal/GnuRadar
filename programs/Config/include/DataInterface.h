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

#include <FL/Fl_Int_Input.H>
#include <FL/Fl_Choice.h>
#include <FL/Fl_Button.h>
#include <FL/fl_ask.H>
#include "DataWindowInterface.h"
#include "UsrpConfigStruct.h"
#include <iostream>
#include <boost/lexical_cast.hpp>
#include <boost/shared_ptr.hpp>

///Class definition
class DataInterface : public Fl_Group
{
    UsrpConfigStruct& usrpConfigStruct_;
    boost::shared_ptr<DataWindowInterface> dataWindowInterface_;
    boost::shared_ptr<Fl_Button> addButton_;
    boost::shared_ptr<Fl_Button> removeButton_;
    boost::shared_ptr<Fl_Int_Input> ippInput_;
    boost::shared_ptr<Fl_Choice> unitsChoice_;

    ///Callback for Add button
    static void AddClicked(Fl_Widget* flw, void* userData){
	DataWindowInterface* dwi = reinterpret_cast<DataWindowInterface*>(userData);

	//really screwed up way to catch exception - until I find the proper method
	string str;
	try { 
	    string str2(fl_input("Enter a label for new data window."));
	    str = str2;
	}
	catch(std::exception){
	    std::cout << "DataInterface::AddClicked - Empty string" << std::endl;
	}
	
	if(str.size() != 0) dwi->Add(str.c_str());
    }

    ///Callback for Remove Button
    static void RemoveClicked(Fl_Widget* flw, void* userData){
	DataWindowInterface* dwi = reinterpret_cast<DataWindowInterface*>(userData);

	//really screwed up way to catch exception - until I find the proper method
	string str;
	try { 
	    string str2(fl_input("Enter the label for removal."));
	    str = str2;
	}
	catch(std::exception){
	    cerr << "DataInterface::RemoveClicked - Empty string" << std::endl;
	}
	
	if(str.size() != 0) dwi->Remove(str.c_str());
    }

    ///Callback to Update IPP and units
    static void Update(Fl_Widget* flw, void* userData){
	DataInterface* dwiPtr = reinterpret_cast<DataInterface*>(userData);

	int ipp = boost::lexical_cast<int>(dwiPtr->ippInput_->value());
	int units = dwiPtr->unitsChoice_->value();

	//validate ipp choice
	if(ipp > 0){
	    //update global structure
	    dwiPtr->usrpConfigStruct_.ipp = ipp;
	    dwiPtr->usrpConfigStruct_.ippUnits = units;
	}
	else{
	    cerr << "DataInterface::Update - invalid ipp chosen "
		 << "- global structure not updated." << std::endl;
	}
    }
public:
    ///Constructor
    DataInterface(UsrpConfigStruct& usrpConfigStruct, int x, int y, 
		  int width=325, int height=245, const char* label=NULL);

    DataWindowInterface& DataWindowRef() { return *dataWindowInterface_.get();}
    void IPP(const int& ipp);
    void IPPUnits(const int& ippUnits);

};
#endif
