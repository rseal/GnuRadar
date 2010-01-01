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
#include "DataWindowStruct.h"

// struct DataWindowStruct{
//     string name;
//     int start;
//     int size;
//     int units;
//     DataWindowStruct(): start(0), size(0), units(0) {}
//     void Print(){
// 	cout << "name = " << name << "\n" 
// 	     << "start  = " << start << "\n"
// 	     << "size   = " << size << "\n"
// 	     << "units  = " << units << endl;
//     }
// };

using boost::lexical_cast;
using std::string;

///Class definition
class DataGroup: public Fl_Group{
    DataWindowStruct dataWindow_;
    std::unique_ptr<Fl_Int_Input> startInput_;
    std::unique_ptr<Fl_Int_Input> sizeInput_;
    std::unique_ptr<Fl_Choice> unitChoice_;
    
//     static void Update(Fl_Widget* flw, void* userData){
// 	DataGroup* dgPtr = reinterpret_cast<DataGroup*>(userData);
// 	dgPtr->do_callback();
// 	std::cout << "DataGroup::Update called from ID " << dgPtr->dataWindow_.id << std::endl;
//     }
    
    static void UpdateStart(Fl_Widget* flw, void* userData){
	Fl_Int_Input* startPtr = reinterpret_cast<Fl_Int_Input*>(flw);
	DataGroup* dgPtr = reinterpret_cast<DataGroup*>(userData);
	dgPtr->dataWindow_.start = lexical_cast<int>(startPtr->value());
	dgPtr->do_callback();
    }

    static void UpdateSize(Fl_Widget* flw, void* userData){
	Fl_Int_Input* startPtr = reinterpret_cast<Fl_Int_Input*>(flw);
	DataGroup* dgPtr = reinterpret_cast<DataGroup*>(userData);
	dgPtr->dataWindow_.size = lexical_cast<int>(startPtr->value());
	dgPtr->do_callback();
    }

    static void UpdateChoice(Fl_Widget* flw, void* userData){
	Fl_Choice* startPtr = reinterpret_cast<Fl_Choice*>(flw);
	DataGroup* dgPtr = reinterpret_cast<DataGroup*>(userData);
	dgPtr->dataWindow_.units = startPtr->value();
	dgPtr->do_callback();
    }

public:
    ///Constructor
    DataGroup(const int& id, int x, int y, int width, int height, const char* label);
   
    void Label(const string& label);
    const string Label() { return dataWindow_.name;}
    
    void Start(const int& start);
    const int Start() {return dataWindow_.start;}
    
    void Size(const int& size);
    const int Size() {return dataWindow_.size;}
    
    void Units(const int& units);
    const int Units() { return dataWindow_.units;}

    const int& ID() { return dataWindow_.id;}

    const bool WindowValid() {return dataWindow_.start >= 0 && dataWindow_.size >= 0;}

    DataWindowStruct& DataWindowRef() { return dataWindow_;}

    void DataWindow(const DataWindowStruct& dws) {
	dataWindow_ = dws;
	this->copy_label(dws.name.c_str());
	startInput_->value(lexical_cast<string>(dws.start).c_str());
	sizeInput_->value(lexical_cast<string>(dws.size).c_str());
	unitChoice_->value(dws.units);
    }

    enum{SAMPLES, USEC, KILOMETERS};
};

#endif
