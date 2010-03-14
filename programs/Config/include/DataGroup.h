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
#include <boost/lexical_cast.hpp>
#include <boost/shared_ptr.hpp>
#include <iostream>
#include "DataWindowStruct.h"


///Class definition
class DataGroup: public Fl_Group{
    DataWindowStruct dataWindow_;
    boost::shared_ptr<Fl_Int_Input> startInput_;
    boost::shared_ptr<Fl_Int_Input> sizeInput_;
    boost::shared_ptr<Fl_Choice> unitChoice_;
    
    static void UpdateStart(Fl_Widget* flw, void* userData){
	Fl_Int_Input* startPtr = reinterpret_cast<Fl_Int_Input*>(flw);
	DataGroup* dgPtr = reinterpret_cast<DataGroup*>(userData);
	dgPtr->dataWindow_.start = boost::lexical_cast<int>(startPtr->value());
	dgPtr->do_callback();
    }

    static void UpdateSize(Fl_Widget* flw, void* userData){
	Fl_Int_Input* startPtr = reinterpret_cast<Fl_Int_Input*>(flw);
	DataGroup* dgPtr = reinterpret_cast<DataGroup*>(userData);
	dgPtr->dataWindow_.size = boost::lexical_cast<int>(startPtr->value());
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
   
    void Label(const std::string& label);
    const std::string Label() { return dataWindow_.name;}
    
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
	startInput_->value(boost::lexical_cast<std::string>(dws.start).c_str());
	sizeInput_->value(boost::lexical_cast<std::string>(dws.size).c_str());
	unitChoice_->value(dws.units);
    }

    enum{SAMPLES, USEC, KILOMETERS};
};

#endif
