////////////////////////////////////////////////////////////////////////////////
///DataGroup.h
///
///Used to add/remove data window used in data acquisition
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef DATA_GROUP_H
#define DATA_GROUP_H

#include <FL/Fl_Group.h>
#include <FL/Fl_Int_Input.h>
#include <FL/Fl_Choice.h>
#include <memory>
#include <boost/lexical_cast.hpp>

using boost::lexical_cast;
using std::auto_ptr;

///Class definition
class DataGroup: public Fl_Group{
    int start_;
    int size_;
    int units_;

    auto_ptr<Fl_Int_Input> startInput_;
    auto_ptr<Fl_Int_Input> sizeInput_;
    auto_ptr<Fl_Choice> unitChoice_;

public:
    ///Constructor
    DataGroup(int x, int y, int width, int height, const char* label);
   
    void Start(const int& start);
    const int& Start() {return start_;}
    
    void Size(const int& size);
    const int& Size() {return size_;}
    
    void Units(const int& units);
    const int& Units() { return units_;}

    enum{SAMPLES, USEC, KILOMETERS};
};

#endif
