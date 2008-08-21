#ifndef STRING_FORMAT_H
#define STRING_FORMAT_H

#include <string>
using std::string;

struct StringFormat{
public:
    static const string SetPrecision(const string& str, const int& precision);
};


#endif
