#ifndef HEADER_STRUCT_H
#define HEADER_STRUCT_H

#include <iostream>
using std::string;

//holds keywords necessary for simple header creation
struct HeaderStruct{
public:
    string institution;
    string observer;
    string object;
    string radar;
    string receiver;
};
#endif