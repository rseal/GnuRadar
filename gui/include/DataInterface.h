#ifndef DATA_INTERFACE_H
#define DATA_INTERFACE_H

//#include <FL/Fl.H>
#include <FL/Fl_Int_Input.H>
#include <FL/Fl_Choice.h>
#include <FL/Fl_Button.h>

#include "DataWindowInterface.h"

//#include <boost/lexical_cast.hpp>
//#include <boost/shared_ptr.hpp>

//#include <iostream>
//#include <vector>

using std::auto_ptr;

class DataInterface : public Fl_Group
{
    auto_ptr<DataWindowInterface> dataWindowInterface_;
    auto_ptr<Fl_Button> addButton_;
    auto_ptr<Fl_Button> removeButton_;
    auto_ptr<Fl_Int_Input> ippInput_;
    auto_ptr<Fl_Choice> unitsChoice_;


public:
    DataInterface(int x, int y, int width=325, int height=245, const char* label=NULL);
    void Add(const int& start, const int& size, const string& label);
    void Remove(const string& label);
    void Modify(const int& start, const int& size, const string& label);
    void Units(const int& units);
    enum {SAMPLES,USEC,KILOMETERS};
};
#endif
