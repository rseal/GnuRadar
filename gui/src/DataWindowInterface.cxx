#include "../include/DataWindowInterface.h"

DataWindowInterface::DataWindowInterface(int x, int y, int width, int height, const char* label):
    CustomTab(x,y,width,height,label), firstWindow_(true), arrayTouched_(false)
{
    x0_ = x + 5;
    y0_ = y + 15;
    w0_ = 220;
    h0_ = 70;

    DataGroupPtr dgp = DataGroupPtr(new DataGroup(x0_,y0_, w0_, h0_, "Data"));
    dataGroupArray_.push_back(dgp);
    this->add(dataGroupArray_[0].get());
    this->end();

}

void DataWindowInterface::Add(const string& label){

    //one window if created with class instance
    //to give user an example of a data window
    //this window will be overwritten when add is called
    //must be replaced by example when array is empty
    if((arrayTouched_ && dataGroupArray_.size() == 1) || 
       firstWindow_){
	dataGroupArray_[0]->copy_label(label.c_str());
	firstWindow_ = false;
	arrayTouched_ = false;
    }
    else{
	DataGroupPtr dgp = DataGroupPtr(new DataGroup(x0_,y0_, w0_, h0_, ""));
	dgp->copy_label(label.c_str());
	dataGroupArray_.push_back(dgp);
	this->add(dataGroupArray_[dataGroupArray_.size()-1].get());
	arrayTouched_ = true;
    }

    this->draw();

}

void DataWindowInterface::Remove(const string label){
    
    //search array for label and remove if found
    if(dataGroupArray_.size() == 1) dataGroupArray_[0]->copy_label("Data");
    else{
	vector<DataGroupPtr>::iterator it = dataGroupArray_.begin();
	while(it != dataGroupArray_.end()){
	    if(label.compare((*it)->label()) == 0){
		//gotta remove widget from group or segfault
		this->remove(it->get());
		//delete this widget from the array
		dataGroupArray_.erase(it);
		this->draw();
		break;
	    }
	    ++it;
	}
    }
}

void DataWindowInterface::Modify(const string oldLabel, const string newLabel){
    
    //search for oldLabel and replace with newLabel
    for(int i=0; i<dataGroupArray_.size(); ++i){
	if(oldLabel.compare(dataGroupArray_[i]->label()) == 0)
	    dataGroupArray_[i]->copy_label(newLabel.c_str());
    }
	
}

void DataWindowInterface::Units(const int& units){}



