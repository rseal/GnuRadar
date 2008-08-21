#ifndef DATAWINDOW_PREDICATE_H
#define DATAWINDOW_PREDICATE_H

#include <string>
#include "DataWindowInterface.h"
#include <boost/shared_ptr.hpp>

using std::string;

class FindDataWindow{
    const string& name_;
public:
    FindDataWindow(const string& name): name_(name){}

    const bool operator()(boost::shared_ptr<DataGroup> dgp ){
	const DataWindowStruct& dws = dgp->DataWindowRef();
	return dws.name == name_;
    }
};

#endif
