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
#include <iostream>

using boost::lexical_cast;
using std::auto_ptr;

///Class definition
class DataGroup: public Fl_Group{
    const int id_;
    int start_;
    int size_;
    int units_;

    auto_ptr<Fl_Int_Input> startInput_;
    auto_ptr<Fl_Int_Input> sizeInput_;
    auto_ptr<Fl_Choice> unitChoice_;
    
    static void Update(Fl_Widget* flw, void* userData){
	DataGroup* dgPtr = reinterpret_cast<DataGroup*>(userData);
	dgPtr->do_callback();
	std::cout << "DataGroup::Update called from ID " << dgPtr->id_ << std::endl;
    }

public:
    ///Constructor
    DataGroup(const int& id, int x, int y, int width, int height, const char* label);
   
    void Start(const int& start);
    const int Start() {return lexical_cast<int>(startInput_->value());}
    
    void Size(const int& size);
    const int Size() {return lexical_cast<int>(sizeInput_->value());}
    
    void Units(const int& units);
    const int Units() { return unitChoice_->value();}

    const int& ID() { return id_;}

    enum{SAMPLES, USEC, KILOMETERS};
};

#endif
