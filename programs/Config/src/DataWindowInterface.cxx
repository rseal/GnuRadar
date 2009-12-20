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
    this->Add("SampleWindow");
}

///Adds a new window to the interface.
void DataWindowInterface::Add(const string& label){
    cout << "DataWindowInterface::Add" << endl;
    numWindows_ = dataGroupArray_.size();
    USRP::WindowVector& window = usrpConfigStruct_.WindowRef();

    //overwrite default window
    if(numWindows_ == 1 && defaultWindow_){
	this->remove(dataGroupArray_[0].get());
  	dataGroupArray_.resize(0);
  	window.resize(0);
	numWindows_ = 0;
  	defaultWindow_ = false;
      }

    //add new window
    USRP::DataGroupPtr dgp = 
	USRP::DataGroupPtr(new DataGroup(numWindows_, x0_,y0_, w0_, h0_, ""));
    DataWindowStruct dws;
    dws.name = label;
    dws.id   = numWindows_;
    dgp->DataWindow(dws);
    dgp->callback(DataWindowInterface::Update,&usrpConfigStruct_);
    dataGroupArray_.push_back(dgp);
    this->add(dataGroupArray_[numWindows_].get());
    //insert new, blank window into vector
    window.push_back(dws);
    this->redraw();

//     for(int i=0; i<window.size(); ++i)
// 	window[i].Print();
}

///Removes a window from the existing list.
///If a single window exists, it is removed and replaced 
///by the default window, which is created in the constructor
void DataWindowInterface::Remove(const string label){

    USRP::WindowVector& window = usrpConfigStruct_.WindowRef();
    
    //find widget matching requested label
    vector<USRP::DataGroupPtr>::iterator iter = 
	find_if(dataGroupArray_.begin(), dataGroupArray_.end(), FindDataWindow(label));
    
//    cout << "Found " << (*iter)->Label() << endl;
 
    //if iter exists, remove widget
    if(iter != dataGroupArray_.end()){
	window.erase(window.begin() + (*iter)->ID());
	this->remove(iter->get());
	dataGroupArray_.erase(iter);
	//if last widget, restore sample widget
	if(!dataGroupArray_.size()){
	    this->Add("SampleWindow");
	    defaultWindow_ = true;
	}

	//kludge to keep tab removal from crashing CustomTab
	//FIXME
	this->value(0);
    }

//debug only
    cout << "DataWindowInterface::Remove" << endl; 
//     for(int i=0; i<window.size(); ++i)
// 	window[i].Print();
//    this->redraw();
}

///Removes all stored windows from GUI.
void DataWindowInterface::RemoveAll(){
    
    vector<USRP::DataGroupPtr>::iterator iter = dataGroupArray_.begin();
    while(iter != dataGroupArray_.end()){
	this->remove(iter->get());
	dataGroupArray_.erase(iter);
    }
}

///Loads user-defined windows from configuration file.
void DataWindowInterface::Load(){
    numWindows_ = dataGroupArray_.size();
    USRP::WindowVector& window = usrpConfigStruct_.WindowRef();
   
    //clear all windows before loading file
    RemoveAll();

    //if file contains no windows - exit
    if(!window.size()){
	cerr << "DataWindowInterface::Load - no windows found" << endl;
	return;
    }

    //load windows
    for(int i=0; i<window.size(); ++i){
	USRP::DataGroupPtr dgp = 
	    USRP::DataGroupPtr(new DataGroup(i, x0_,y0_, w0_, h0_, ""));
	dgp->DataWindow(window[i]);
	dgp->callback(DataWindowInterface::Update,&usrpConfigStruct_);
	dataGroupArray_.push_back(dgp);
	this->add(dataGroupArray_[i].get());
    }
    this->redraw();
}
