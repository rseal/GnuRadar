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

class HeaderInterface : public Fl_Group
{
    typedef shared_ptr<Fl_Input> InputPtr;
    vector<InputPtr> inputArray_;

public:
    HeaderInterface(int x, int y, int width=325, int height=245, const char* label=NULL);
};
#endif

