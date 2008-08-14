////////////////////////////////////////////////////////////////////////////////
///DataWindowStruct.h
///
///
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef DATA_WINDOW_STRUCT_H
#define DATA_WINDOW_STRUCT_H
#include <iostream>
using std::cout;
using std::endl;

///Describes an arbitrary number of windows that determine 
///which portions of data to collect.
struct DataWindowStruct{
    int start;
    int size;
    int units;
    DataWindowStruct(): start(0), size(0), units(0) {}
    void Print(){
	cout << "start  = " << start << "\n"
	     << "size   = " << size << "\n"
	     << "units  = " << units << endl;
    }
};
#endif
