#ifndef DATA_WINDOW_INTERFACE_H
#define DATA_WINDOW_INTERFACE_H

//#include <FL/Fl.H>
#include <FL/Fl_Int_Input.H>
#include <FL/Fl_Choice.h>

#include "CustomTab.h"
#include "DataGroup.h"

//#include <boost/lexical_cast.hpp>
#include <boost/shared_ptr.hpp>

#include <iostream>
#include <vector>

using std::cout;
using std::endl;
using std::string;
using std::vector;
using boost::shared_ptr;

//contains the following components
// institution name      - fl_input
// observer              - fl_input
// object of observation - fl_input
// observing instrument  - fl_input
// collection instrument - fl_input

class DataWindowInterface : public CustomTab
{
    typedef shared_ptr<DataGroup> DataGroupPtr;
    vector<DataGroupPtr> dataGroupArray_;

public:
    DataWindowInterface(int x, int y, int width=325, int height=245, const char* label=NULL);
    void Add(const int& start, const int& size, const string& label);
    void Remove(const string& label);
    void Modify(const int& start, const int& size, const string& label);
    void Units(const int& units);
};
#endif
