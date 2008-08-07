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
///Describes an arbitrary number of windows that determine 
///which portions of data to collect.
struct DataWindowStruct{
    int start_;
    int size_;
    int units_;
public:
    DataWindowStruct(const int& start, const int& size, const int& units):
	start_(start), size_(size), units_(units){}
};
#endif
