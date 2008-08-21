#include "../include/StringFormat.h"

const string StringFormat::SetPrecision(const string& str, const int& precision){
    string s = str;
    int index = s.find(".");
    if(index != string::npos){
	s.erase(index+precision+1,s.size()-1);
    }
    return s;
}
