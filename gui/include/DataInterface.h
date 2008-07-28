#ifndef DATA_INTERFACE_H
#define DATA_INTERFACE_H

//#include <FL/Fl.H>
#include <FL/Fl_Int_Input.H>
#include <FL/Fl_Choice.h>
#include <FL/Fl_Button.h>
#include <FL/fl_ask.H>

#include "DataWindowInterface.h"

//#include <boost/lexical_cast.hpp>
//#include <boost/shared_ptr.hpp>

#include <iostream>
//#include <vector>

using std::auto_ptr;
using std::cout; 
using std::endl;

class DataInterface : public Fl_Group
{
    auto_ptr<DataWindowInterface> dataWindowInterface_;
    auto_ptr<Fl_Button> addButton_;
    auto_ptr<Fl_Button> removeButton_;
    auto_ptr<Fl_Int_Input> ippInput_;
    auto_ptr<Fl_Choice> unitsChoice_;

    static void AddClicked(Fl_Widget* flw, void* userData){
	DataWindowInterface* dwi = reinterpret_cast<DataWindowInterface*>(userData);
	dwi->Add(fl_input("Enter a label for this data window."));
    }

    static void RemoveClicked(Fl_Widget* flw, void* userData){
	DataWindowInterface* dwi = reinterpret_cast<DataWindowInterface*>(userData);
	dwi->Remove(fl_input("Enter a label for this data window."));
    }

public:
    DataInterface(int x, int y, int width=325, int height=245, const char* label=NULL);
};
#endif
