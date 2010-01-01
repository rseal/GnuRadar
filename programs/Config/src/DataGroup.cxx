////////////////////////////////////////////////////////////////////////////////
///DataGroup.cxx
///
///Used to add/remove data window used in data acquisition
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#include "../include/DataGroup.h"

using namespace std;
///Constructor
DataGroup::DataGroup(const int& id, int x, int y, int width, int height, const char* label):
    Fl_Group(x, y, width, height, label){
 
    dataWindow_.id = id;

    int x0=x+50;
    int y0=y+15;
    int w0=80;
    int h0=25;
    int sp=30;

    //this->box(FL_ENGRAVED_BOX);

    startInput_ = unique_ptr<Fl_Int_Input>(new Fl_Int_Input(x0, y0, w0, h0, "Start"));
    startInput_->align(FL_ALIGN_LEFT);
    startInput_->callback(DataGroup::UpdateStart, this);
    this->add(startInput_.get());

    sizeInput_ = unique_ptr<Fl_Int_Input>(new Fl_Int_Input(x0, y0+sp, w0, h0, "Size"));
    sizeInput_->align(FL_ALIGN_LEFT);
    sizeInput_->callback(DataGroup::UpdateSize, this);
    this->add(sizeInput_.get());

    unitChoice_ = unique_ptr<Fl_Choice>(new Fl_Choice(x0+85, y0, 80, h0, "Units"));
    unitChoice_->add("SMPL");
    unitChoice_->add("usec");
    unitChoice_->add("Km");
    unitChoice_->align(FL_ALIGN_BOTTOM);
    unitChoice_->callback(DataGroup::UpdateChoice, this);
    unitChoice_->value(0);
    this->add(unitChoice_.get());
   
    this->end();

    //initialize window labels
    this->Start(0);
    this->Size(0);
    this->Units(USEC);
}

void DataGroup::Label(const string& label){
    dataWindow_.name = label;
    this->copy_label(label.c_str());
}

///Defines window start    
void DataGroup::Start(const int& start){
    dataWindow_.start = start;
    //start_ = start;
    std::string str = lexical_cast<std::string>(start);
    startInput_->value(str.c_str());
}
    
///Defines window size
void DataGroup::Size(const int& size){
    dataWindow_.size = size;
    std::string str = lexical_cast<std::string>(size); 
    sizeInput_->value(str.c_str());
}
    
///Defines window units
void DataGroup::Units(const int& units){
    dataWindow_.units = units;
    
    switch(units){
    case SAMPLES:
	unitChoice_->value(0);
	break;
    case USEC:
	unitChoice_->value(1);
	break;
    case KILOMETERS:
	unitChoice_->value(2);
	break;
    default:
	unitChoice_->value(0);
	break;
    }

}
