////////////////////////////////////////////////////////////////////////////////
///DataWindowInterface.cxx
///
///Used to add/remove data window used in data acquisition
///
///Author: Ryan Seal
///Modified: 08/18/08
////////////////////////////////////////////////////////////////////////////////
#include "../include/DataWindowInterface.h"

///Constructor
DataWindowInterface::DataWindowInterface(
    UsrpConfigStruct& usrpConfigStruct, int x, int y, int width, int height, 
    const char* label
    ):
    CustomTab(x,y,width,height,label), usrpConfigStruct_(usrpConfigStruct),
    numWindows_(0), defaultWindow_(true)
{
    x0_ = x + 5;
    y0_ = y + 15;
    w0_ = 220;
    h0_ = 70;

    DataGroupPtr dgp = DataGroupPtr(new DataGroup(0,x0_,y0_, w0_, h0_, "SampleWindow"));
    dgp->callback(DataWindowInterface::Update, &usrpConfigStruct_);
    dataGroupArray_.push_back(dgp);
    this->add(dataGroupArray_[0].get());
    this->end();

    USRP::WindowVector& window = usrpConfigStruct_.WindowRef();
    window.push_back(DataWindowStruct());
}

///Adds a new window to the interface.
void DataWindowInterface::Add(const string& label){

    numWindows_ = dataGroupArray_.size();
    USRP::WindowVector& window = usrpConfigStruct_.WindowRef();

    if(numWindows_ == 1 && defaultWindow_){
	dataGroupArray_[0]->copy_label(label.c_str());
	defaultWindow_ = false;
    }
    else{
	//add new window
	DataGroupPtr dgp = 
	    DataGroupPtr(new DataGroup(++numWindows_-1, x0_,y0_, w0_, h0_, ""));
	dgp->copy_label(label.c_str());
	dgp->callback(DataWindowInterface::Update,&usrpConfigStruct_);
	dataGroupArray_.push_back(dgp);
	this->add(dataGroupArray_[dataGroupArray_.size()-1].get());
	//insert new, blank window into vector
	window.push_back(DataWindowStruct());
    }
    this->redraw();
}

///Removes a window from the existing list.
///If a single window exists, it is removed and replaced 
///by the default window, which is created in the constructor
void DataWindowInterface::Remove(const string label){
    	
    USRP::WindowVector& window = usrpConfigStruct_.WindowRef();
	
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
		//super kludge for now
		USRP::WindowVector::iterator it2 = window.begin() + it->get()->ID();
		window.erase(it2);
		this->remove(it->get());
		dataGroupArray_.erase(it);
	    }
	    break;
	}
	++it;
    }
    //debug only 
    //for(int i=0; i<window.size(); ++i)
    //window[i].Print();
    this->redraw();
	
    cout << "DataWindowInterface::Remove - " << window.size() << " windows remain" << endl;
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



