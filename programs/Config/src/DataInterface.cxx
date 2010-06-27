////////////////////////////////////////////////////////////////////////////////
///DataInterface.cxx
///
///Used to add/remove data window used in data acquisition
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#include "../include/DataInterface.h"

using namespace std;
using namespace boost;

///Constructor
DataInterface::DataInterface(UsrpConfigStruct& usrpConfigStruct, int x, int y,
			     int width, int height, const char* label):
    Fl_Group(x, y, width, height, label), usrpConfigStruct_(usrpConfigStruct)
{
    int x0 = x+5;
    int y0 = y+5;
    int w0 = 230;
    int h0 = 100;

    dataWindowInterface_ = 
	boost::shared_ptr<DataWindowInterface>(new DataWindowInterface(usrpConfigStruct_, 
							      x0+170, y0+5,
							      w0, h0, NULL));
    dataWindowInterface_->box(FL_ENGRAVED_BOX);
    this->add(dataWindowInterface_.get());

    addButton_ = boost::shared_ptr<Fl_Button>(new Fl_Button(x0+10,y0+70,70,25,"Add"));
    addButton_->box(FL_PLASTIC_DOWN_BOX);
    addButton_->callback(DataInterface::AddClicked,
			 dataWindowInterface_.get());
    this->add(addButton_.get());

    removeButton_ = boost::shared_ptr<Fl_Button>(new Fl_Button(x0+90,y0+70,70,25,"Remove"));
    removeButton_->box(FL_PLASTIC_DOWN_BOX);
    removeButton_->callback(DataInterface::RemoveClicked,
			    dataWindowInterface_.get());
    this->add(removeButton_.get());
    
    ippInput_ = boost::shared_ptr<Fl_Int_Input>(new Fl_Int_Input(x0+30,y0+20,50,25,"IPP"));
    ippInput_->callback(DataInterface::Update,this);
    ippInput_->value("10");
    this->add(ippInput_.get());

    unitsChoice_ = boost::shared_ptr<Fl_Choice>(new Fl_Choice(x0+90,y0+20,70,25,NULL));
    unitsChoice_->box(FL_PLASTIC_DOWN_BOX);
    unitsChoice_->callback(DataInterface::Update,this);
    unitsChoice_->add("msec");
    unitsChoice_->add("usec");
    unitsChoice_->add("Km");
    unitsChoice_->value(0);
    this->add(unitsChoice_.get());

    this->end();
}

void DataInterface::IPP(const int& ipp){
    if(ipp > 0){
	ippInput_->value(lexical_cast<string>(ipp).c_str());
    }
    else cerr << "DataInterface::IPP - invalid ipp choice -"
	      << " no changes made" << endl;
}

void DataInterface::IPPUnits(const int& ippUnits){
    if(ippUnits >=0 && ippUnits <= 2)
	unitsChoice_->value(ippUnits);
    else cerr << "DataInterface::IPPUnits - invalid ipp units choice -"
	      << " no changes made" << endl;
}
