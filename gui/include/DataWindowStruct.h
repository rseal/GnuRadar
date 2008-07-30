#ifndef DATA_WINDOW_STRUCT_H
#define DATA_WINDOW_STRUCT_H
//describes an arbitrary number of windows that determine 
//which portions of data to collect.
struct DataWindowStruct{
    int start_;
    int size_;
    int units_;
public:
    DataWindowStruct(const int& start, const int& size, const int& units):
	start_(start), size_(size), units_(units){}
};
#endif
