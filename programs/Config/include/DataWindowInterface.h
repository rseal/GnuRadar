// Copyright (c) 2010 Ryan Seal <rlseal -at- gmail.com>
//
// This file is part of GnuRadar Software.
//
// GnuRadar is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//  
// GnuRadar is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with GnuRadar.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////////////
///DataWindowInterface.h
///
///Used to add/remove data window used in data acquisition
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef DATA_WINDOW_INTERFACE_H
#define DATA_WINDOW_INTERFACE_H

#include <FL/Fl_Int_Input.H>
#include <FL/Fl_Choice.h>
#include <FL/fl_ask.H>
#include "CustomTab.h"
#include "DataGroup.h"
#include "UsrpConfigStruct.h"
#include "DataWindowStruct.h"
#include "DataWindowPredicate.h"

#include <boost/shared_ptr.hpp>
#include <iostream>
#include <vector>

using std::cout;
using std::endl;
using std::string;
using std::vector;
using boost::shared_ptr;

namespace USRP{
    typedef shared_ptr<DataGroup> DataGroupPtr;
};

///\todo Add rule checking to DataWindowInterface

///Class definition
class DataWindowInterface : public CustomTab
{
    vector<USRP::DataGroupPtr> dataGroupArray_;
    UsrpConfigStruct& usrpConfigStruct_;
    int numWindows_;
    bool defaultWindow_;
    bool arrayTouched_;
    int x0_;
    int y0_;
    int w0_;
    int h0_;

    static void Update(Fl_Widget* flw, void* userData){
	DataGroup* dgPtr = reinterpret_cast<DataGroup*>(flw);

	const int& id = dgPtr->ID();
	cout << "DataWindowInterface::Update - state change from ID " << id << endl;

	UsrpConfigStruct* ucsPtr = reinterpret_cast<UsrpConfigStruct*>(userData);
	USRP::WindowVector& dws = ucsPtr->WindowRef();

	//make sure positive values exist for window parameters
	if(dgPtr->WindowValid()){
	    dws[id].name  = dgPtr->Label();
	    dws[id].start = dgPtr->Start();
	    dws[id].size  = dgPtr->Size();
	    dws[id].units = dgPtr->Units();
	}
	else{
	    cerr << "DataWindowInterface::Update - invalid window settings detected "
		 << "in window " << id << " - global structure not updated." << endl;
	}

    }
    
    void RemoveAll();

public:
    ///Constructor
    DataWindowInterface(UsrpConfigStruct& usrpConfigStruct, int x, int y,
			int width=325, int height=245, const char* label=NULL);
    void Add(const string& label);
    void Remove(const string label);
    void Modify(const string oldLabel, const string newLabel);
    void Units(const int& units);

    void Load();
};


#endif
