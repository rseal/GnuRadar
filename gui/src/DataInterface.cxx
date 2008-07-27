#include "../include/DataInterface.h"

DataInterface::DataInterface(int x, int y, int width, int height,
			     const char* label):
    Fl_Group(x, y, width, height, label)
{
    int x0 = x+5;
    int y0 = y+5;
    int w0 = 230;
    int h0 = 100;

    dataWindowInterface_ = auto_ptr<DataWindowInterface>(new DataWindowInterface(x0+170,y0+5,w0,h0,NULL));
    dataWindowInterface_->box(FL_ENGRAVED_BOX);
    this->add(dataWindowInterface_.get());

    addButton_ = auto_ptr<Fl_Button>(new Fl_Button(x0+10,y0+70,70,25,"Add"));
    addButton_->box(FL_PLASTIC_DOWN_BOX);
    this->add(addButton_.get());

    removeButton_ = auto_ptr<Fl_Button>(new Fl_Button(x0+90,y0+70,70,25,"Remove"));
    removeButton_->box(FL_PLASTIC_DOWN_BOX);
    this->add(removeButton_.get());
    
    ippInput_ = auto_ptr<Fl_Int_Input>(new Fl_Int_Input(x0+30,y0+20,50,25,"IPP"));
    this->add(ippInput_.get());

    unitsChoice_ = auto_ptr<Fl_Choice>(new Fl_Choice(x0+90,y0+20,70,25,NULL));
    unitsChoice_->box(FL_PLASTIC_DOWN_BOX);
    unitsChoice_->add("msec");
    unitsChoice_->add("usec");
    unitsChoice_->add("Km");
    unitsChoice_->value(0);
    this->add(unitsChoice_.get());

    this->end();
}


void DataInterface::Add(const int& start, const int& size, const string& label){

}

void DataInterface::Remove(const string& label){

}

void DataInterface::Modify(const int& start, const int& size, const string& label){

}

void DataInterface::Units(const int& units){

}
