////////////////////////////////////////////////////////////////////////////////
///DataWindowInterface.cxx
///
///Used to add/remove data window used in data acquisition
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#include "../include/DataWindowInterface.h"

///Constructor
DataWindowInterface::DataWindowInterface(int x, int y, int width, int height, const char* label):
    CustomTab(x,y,width,height,label), defaultWindow_(true)
{
    x0_ = x + 5;
    y0_ = y + 15;
    w0_ = 220;
    h0_ = 70;

    DataGroupPtr dgp = DataGroupPtr(new DataGroup(x0_,y0_, w0_, h0_, "SampleWindow"));
    dataGroupArray_.push_back(dgp);
    this->add(dataGroupArray_[0].get());
    this->end();

}

///Adds a new window to the interface.
void DataWindowInterface::Add(const string& label){

    //one window if created with class instance
    //to give user an example of a data window
    //this window will be overwritten when add is called
    //must be replaced by example when array is empty
    if(dataGroupArray_.size() == 1 && defaultWindow_){
	dataGroupArray_[0]->copy_label(label.c_str());
	defaultWindow_ = false;
    }
    else{
	DataGroupPtr dgp = DataGroupPtr(new DataGroup(x0_,y0_, w0_, h0_, ""));
	dgp->copy_label(label.c_str());
	dataGroupArray_.push_back(dgp);
	this->add(dataGroupArray_[dataGroupArray_.size()-1].get());
    }
}

///Removes a window from the existing list.
///If a single window exists, it is removed and replaced 
///by the default window, which is created in the constructor
void DataWindowInterface::Remove(const string label){
    
    //search array for label and remove if found
    //if last element - replace with default window
    vector<DataGroupPtr>::iterator it = dataGroupArray_.begin();
    while(it != dataGroupArray_.end()){
	if(label.compare((*it)->label()) == 0){
	    if(dataGroupArray_.size() == 1){
		dataGroupArray_[0]->copy_label("SampleWindow");
		defaultWindow_ = true;
	    }
	    else{
		//gotta remove widget from group or segfault
		this->remove(it->get());
		dataGroupArray_.erase(it);
	    }
	    break;
	}
	++it;
    }
}

///Not currently used
void DataWindowInterface::Modify(const string oldLabel, const string newLabel){
    
    //search for oldLabel and replace with newLabel
    for(int i=0; i<dataGroupArray_.size(); ++i){
	if(oldLabel.compare(dataGroupArray_[i]->label()) == 0)
	    dataGroupArray_[i]->copy_label(newLabel.c_str());
    }
	
}

///Not currently used
void DataWindowInterface::Units(const int& units){}



