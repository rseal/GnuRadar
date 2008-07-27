#include "../include/DataGroup.h"

DataGroup::DataGroup(int x, int y, int width, int height, const char* label):
    Fl_Group(x, y, width, height, label){
 
    int x0=x+50;
    int y0=y+15;
    int w0=80;
    int h0=25;
    int sp=30;

    //this->box(FL_ENGRAVED_BOX);

    startInput_ = auto_ptr<Fl_Int_Input>(new Fl_Int_Input(x0, y0, w0, h0, "Start"));
    startInput_->align(FL_ALIGN_LEFT);
    this->add(startInput_.get());

    sizeInput_ = auto_ptr<Fl_Int_Input>(new Fl_Int_Input(x0, y0+sp, w0, h0, "Size"));
    sizeInput_->align(FL_ALIGN_LEFT);
    this->add(sizeInput_.get());

    unitChoice_ = auto_ptr<Fl_Choice>(new Fl_Choice(x0+85, y0, 80, h0, "Units"));
    unitChoice_->add("SMPL");
    unitChoice_->add("usec");
    unitChoice_->add("Km");
    unitChoice_->align(FL_ALIGN_BOTTOM);
    unitChoice_->value(0);
    this->add(unitChoice_.get());
   
    this->end();
   
}
   
void DataGroup::Start(const int& start){
    start_ = start;
    startInput_->label(lexical_cast<char*>(start_));
}
    
void DataGroup::Size(const int& size){
    size_ = size;
    sizeInput_->label(lexical_cast<char*>(size_));
}
    
void DataGroup::Units(const int& units){
    units_ = units;

    switch(units_){
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
